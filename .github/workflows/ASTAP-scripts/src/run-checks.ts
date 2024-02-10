import { Octokit } from "octokit";
import { format } from "date-fns";
import { getLastCommitByAuthor, log, prExists } from "./tools";

const baseBranch = "main";
const targetBranch = "imported";
const authorEmail = "han.k@hnsky.org";

export const runChecks = async (octokit: Octokit, owner: string, repo: string, printFormatted = true) => {
  const ret = { errors: [], outputs: [], logs: [] };

  log("RunChecks", "[General] Get last commit on " + targetBranch + " from " + authorEmail + "...", ret.logs, printFormatted);
  const time0Process = Date.now();
  const importedCommit = await getLastCommitByAuthor(octokit, owner, repo, targetBranch, authorEmail);
  if (!importedCommit) {
    ret.errors.push(`No commit found for ${authorEmail} on ${targetBranch}.`);
    return ret;
  }
  log("RunChecks", "[General] Last commit retrieved! (" + (Date.now() - time0Process) + "ms)", ret.logs, printFormatted);

  log("RunChecks", "[General] Get last commit on " + targetBranch + " from " + authorEmail + "...", ret.logs, printFormatted);
  const time1Process = Date.now();
  const mainCommit = await getLastCommitByAuthor(octokit, owner, repo, baseBranch, authorEmail);
  if (!mainCommit) {
    ret.errors.push("Failed to retrieve main commit by " + authorEmail + ".");
    return ret;
  }
  log("RunChecks", "[General] Last commit retrieved! (" + (Date.now() - time1Process) + "ms)", ret.logs, printFormatted);

  log("RunChecks", "[General] Determination of information...", ret.logs, printFormatted);
  const time2Process = Date.now();
  const mainCommitDate = new Date(mainCommit.commit.author.date);
  mainCommitDate.setDate(mainCommitDate.getDate() + 1);
  mainCommitDate.setHours(0, 0, 0, 0);
  const formattedMainCommitDate = format(new Date(mainCommitDate), "yyyy-MM-dd");
  ret.outputs.push({ key: "firstCommitDate", value: formattedMainCommitDate });

  const isLastCommitOnMain = mainCommit.sha === importedCommit.sha;

  const isPRExists = await prExists(octokit, owner, repo, `${owner}:${targetBranch}`, baseBranch);

  ret.outputs.push({ key: "needUpdate", value: !isLastCommitOnMain && !isPRExists });

  log("RunChecks", "[General] Finished! (" + (Date.now() - time2Process) + "ms)", ret.logs, printFormatted);

  log("RunChecks", "[General] Total Time: " + (Date.now() - time0Process) + "ms", ret.logs, printFormatted);
  if (printFormatted) console.log(`${JSON.stringify(JSON.stringify(ret))}`);
  else console.log(ret);

  return ret;
};
