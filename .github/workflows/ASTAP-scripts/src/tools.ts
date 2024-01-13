import { Octokit } from "octokit";

export const createOctokit = (opts: { token: string }) => {
  return new Octokit({
    auth: opts.token,
    userAgent: "ASTAP-Script",
    timeZone: "Europe/Zurich",
  });
};

// Function to log what's append in functions
export const log = (script: string, message: string, logs: string[], noDirectPrint = true) => {
  const content = `[${script}] ${message}`;
  logs.push(content);
  if (!noDirectPrint) console.info(content);
};

// Function to get the last commit of a specific author on a branch
export const getLastCommitByAuthor = async (octokit: Octokit, owner: string, repo: string, branch: string, authorEmail: string) => {
  const commits = await octokit.rest.repos.listCommits({
    owner: owner,
    repo: repo,
    sha: branch,
    per_page: 1,
    author: authorEmail,
  });

  return commits.data.length > 0 ? commits.data[0] : null;
};

// Function to check if there is an open pull request for a specific branch
export const prExists = async (octokit: Octokit, owner: string, repo: string, head: string, base: string) => {
  const prs = await octokit.rest.pulls.list({
    base: base,
    head: head,
    owner: owner,
    repo: repo,
    state: "open",
  });

  return prs.data.length > 0;
};
