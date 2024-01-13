import { Octokit } from "octokit";
import { format } from "date-fns";
import { getVersionsInfo } from "./get-version-info";
import { log } from "./tools";
import { runChecks } from "./run-checks";
import { exit } from "process";

export const createPullRequest = async (
  octokit: Octokit,
  owner: string,
  repo: string,
  runChecks_b: boolean,
  raw = "",
  specifiedDate: Date = null,
) => {
  log("CreatePullRequest", "[Run Checks] Run checks...", [], false);
  const time00Process = Date.now();
  // Check if a PR is necessary
  if (runChecks_b) {
    const checks = await runChecks(octokit, owner, repo, false);
    if (checks.errors.length > 0) {
      checks.errors.forEach((error) => console.error("CreatePullRequest", "[Run Checks] " + error));
      exit(-1);
    }
    if (!checks.outputs.find((value) => value.key == "needUpdate").value) {
      log("CreatePullRequest", "[General] No need to update.", [], false);
      return;
    }
    specifiedDate = new Date(checks.outputs.find((value) => value.key == "firstCommitDate").value);
  }
  log("CreatePullRequest", "[Run Checks] Checked! (" + (Date.now() - time00Process) + "ms)", [], false);

  // Parsing data from getVersionInfo
  log("CreatePullRequest", "[Prepare PR] Parsing getVersionInfo data...", [], false);
  const time0Process = Date.now();

  const versionsRaw = raw != "" ? JSON.parse(raw) : await getVersionsInfo(specifiedDate, octokit, owner, repo, false);
  const versions = {};
  log("CreatePullRequest", "[Prepare PR] Data parsed! (" + (Date.now() - time0Process) + "ms)", [], false);

  // Gathering commits
  log("CreatePullRequest", "[Prepare PR] Gathering commits...", [], false);
  const time1Process = Date.now();
  versionsRaw.commits.forEach(function (a: { title: string; content: string; commit: unknown }) {
    const title = a.title.replace("v", "");
    versions[title] = versions[title] || { commits: new Set(), content: a.content.trim() };
    versions[title].commits.add(a.commit);
  });
  log("CreatePullRequest", "[Prepare PR] Gathering commits finished! (" + (Date.now() - time1Process) + "ms)", [], false);

  // Creation of the changelog
  log("CreatePullRequest", "[Prepare PR] Creating changelog...", [], false);
  const time2Process = Date.now();
  let changelog = "";
  for (const key in versions) {
    const commits = Array.from(versions[key].commits).join(") (");
    const content = versions[key].content;

    changelog += `### ASTAP_${key} (${commits})\n\n${content}\n\n`;
  }
  log("CreatePullRequest", "[Prepare PR] Changelog finished! (" + (Date.now() - time2Process) + "ms)", [], false);

  // Definition of the merge date
  const currentDate = new Date();
  const mergeDate = new Date();
  const hours = 10;
  mergeDate.setTime(mergeDate.getTime() + hours * 60 * 60 * 1000);
  log("CreatePullRequest", "[General] Merge date is after " + format(mergeDate, "yyyy-MM-dd HH:mm:ss"), [], false);

  // Pull Request creation
  log("CreatePullRequest", "[PR] Creating pull request...", [], false);
  const time3Process = Date.now();
  const result = await octokit.rest.pulls.create({
    title: "[Automation] [" + format(currentDate, "yyyy-MM-dd") + "] Mirroring from the Mercury repo",
    owner,
    repo,
    head: "imported",
    base: "main",
    body: [
      "## Changelog",
      "",
      changelog,
      "",
      "",
      "> **NOTE**: This PR is automatically generated and will be automatically merged after **" + format(mergeDate, "yyyy-MM-dd HH:mm:ss") + "**.",
    ].join("\n"),
  });
  log("CreatePullRequest", "[PR] Pull request created! (" + (Date.now() - time3Process) + "ms)", [], false);

  // Add labels to Pull Request
  log("CreatePullRequest", "[PR] Adding labels to PR...", [], false);
  const time4Process = Date.now();
  await octokit.rest.issues.addLabels({
    owner,
    repo,
    issue_number: result.data.number,
    labels: ["mirror", "automated pr"],
  });
  log("CreatePullRequest", "[PR] Pull request completely finished! (" + (Date.now() - time4Process) + "ms)", [], false);

  log("CreatePullRequest", "[General] Total Time: " + (Date.now() - time00Process) + "ms", [], false);
};
