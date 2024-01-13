import { Octokit } from "octokit";
import { log } from "./tools";

export const autoMerge = async (octokit: Octokit, owner: string, repo: string, forceMerge: boolean, printFormatted = true) => {
  const ret = { errors: [], outputs: [], logs: [] };

  log("AutoMerge", "[General] Getting PRs...", ret.logs, printFormatted);
  const time0Process = Date.now();
  const listPulls = await octokit.rest.pulls.list({
    owner,
    repo,
    state: "open",
  });
  log("AutoMerge", "[General] PRs got! (" + (Date.now() - time0Process) + "ms)", ret.logs, printFormatted);

  log("AutoMerge", "[General] Listing PRs...", ret.logs, printFormatted);
  const time1Process = Date.now();
  for (const pull of listPulls.data) {
    const create = new Date(pull.created_at);
    const now = new Date();
    const t = (now.getTime() - create.getTime()) / 3600000;
    log("AutoMerge", "[General] " + pull.title, ret.logs, printFormatted);
    log("AutoMerge", "[General] " + pull.html_url, ret.logs, printFormatted);
    log("AutoMerge", "[General] " + t + " hour(s).", ret.logs, printFormatted);
    if (!forceMerge) {
      if (t < 10) {
        log("AutoMerge", "[General] " + "-> Skipped", ret.logs, printFormatted);
        continue;
      }
    } else {
      log("AutoMerge", "[General] " + "-> Forced", ret.logs, printFormatted);
    }
    let mirror = false;
    let automation = false;
    for (const label of pull.labels) {
      if (label.name === "mirror") {
        mirror = true;
      }
      if (label.name === "automated pr") {
        automation = true;
      }
    }
    log("AutoMerge", "[General] " + "Automation: " + automation, ret.logs, printFormatted);
    log("AutoMerge", "[General] " + "Mirror: " + mirror, ret.logs, printFormatted);
    if (!mirror || !automation) continue;

    try {
      const result = await octokit.rest.pulls.merge({
        owner,
        repo,
        pull_number: pull.number,
      });

      log("AutoMerge", "[General] " + "MERGE", ret.logs, printFormatted);
      log("AutoMerge", "[General] " + (result.status === 200) ? "Merged." : "Not Merged", ret.logs, printFormatted);

      log("AutoMerge", "[General] " + "CHECK", ret.logs, printFormatted);

      const resultCheck = await octokit.rest.pulls.checkIfMerged({
        owner,
        repo,
        pull_number: pull.number,
      });
      log("AutoMerge", "[General] " + (resultCheck.status === 204) ? "Merged." : "Not Merged", ret.logs, printFormatted);
    } catch (error) {
      switch (error.status) {
        case 405:
        case 404:
          ret.errors.push("[AutoMerge] [General] Pull Request was not merged.");
          break;
      }
    }
  }
  log("AutoMerge", "[General] PRs listing finished! (" + (Date.now() - time1Process) + "ms)", ret.logs, printFormatted);

  log("AutoMerge", "[General] Total Time: " + (Date.now() - time0Process) + "ms", ret.logs, printFormatted);
  if (printFormatted) console.log(`${JSON.stringify(JSON.stringify(ret))}`);
  else console.log(ret);

  return ret;
};
