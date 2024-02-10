import { Octokit } from "octokit";
import { format } from "date-fns";
import puppeteer from "puppeteer";
import { log } from "./tools";

export const getVersionsInfo = async (specifiedDate: Date, octokit: Octokit, owner: string, repo: string, printFormatted = true) => {
  // Array to store logs for monitoring
  const logs = [];

  log("GetVersionsInfo", "[General] Specified Date: " + format(specifiedDate, "yyyy-MM-dd"), logs, printFormatted);

  // Browser setup
  log("GetVersionsInfo", "[Browser] creating...", logs, printFormatted);
  const time00Process = Date.now();
  const browser = await puppeteer.launch({
    headless: "new",
    timeout: 0,
    args: ["--no-sandbox"],
  });
  const page = (await browser.pages())[0];
  await page.goto("https://www.hnsky.org/history_astap", { timeout: 0 });
  log("GetVersionsInfo", "[Browser] Init! (" + (Date.now() - time00Process) + "ms)", logs, printFormatted);

  // Extract text content from the page
  log("GetVersionsInfo", "[Browser] Go to page https://www.hnsky.org/history_astap...", logs, printFormatted);
  const time0Process = Date.now();
  const extractedText = await page.$eval("*", (el) => {
    const selection = window.getSelection();
    const range = document.createRange();
    range.selectNode(el);
    selection.removeAllRanges();
    selection.addRange(range);
    return window.getSelection().toString();
  });
  log("GetVersionsInfo", "[Browser] Page scrapped! (" + (Date.now() - time0Process) + "ms)", logs, printFormatted);

  // Close the browser
  browser.close().then();

  // Initial cleanup and splitting by lines
  log("GetVersionsInfo", "[Cleaner] Aggregate process started... ", logs, printFormatted);
  const time1Process = Date.now();
  const texts = extractedText
    .split("\n")
    .map((line) => line.trim().replaceAll(" ", "").replaceAll("  ", " "))
    .filter((text) => text !== "");
  log("GetVersionsInfo", "[Cleaner] Aggregate process finished! (" + (Date.now() - time1Process) + "ms)", logs, printFormatted);

  // Filter lines containing "ASTAP" and excluding "ß"
  log("GetVersionsInfo", "[Cleaner] Grouping process started... ", logs, printFormatted);
  const time2Process = Date.now();
  const astapLines = [];
  texts.forEach((line) => {
    if (line.includes("ASTAP")) {
      astapLines.push(line);
    } else if (astapLines.length > 0) {
      astapLines[astapLines.length - 1] += " " + line;
    }
  });
  log("GetVersionsInfo", "[Cleaner] Grouping process finished! (" + (Date.now() - time2Process) + "ms)", logs, printFormatted);

  // Filter lines containing "ASTAP" and excluding "ß"
  log("GetVersionsInfo", "[Cleaner] Filter process started... ", logs, printFormatted);
  const time3Process = Date.now();
  const filteredLines = astapLines.filter((line) => line.includes("ASTAP") && !line.includes("ß"));
  const cleanedAstapLines = filteredLines.map((line) => line.replace(/.*?(ASTAP)/, "$1").trim());
  log("GetVersionsInfo", "[Cleaner] Filter process finished! (" + (Date.now() - time3Process) + "ms)", logs, printFormatted);

  // Extract matches with regex
  log("GetVersionsInfo", "[Cleaner] Matching process started... ", logs, printFormatted);
  const time4Process = Date.now();
  const matches = [];
  cleanedAstapLines.forEach((line) => {
    const match = line.match(/(ASTAP)[\s_][a-z0-9.]*/);
    if (match) {
      const identifier = match[0];
      const content = line.replace(identifier, "").trim();
      matches.push(identifier + " " + content);
    }
  });
  log("GetVersionsInfo", "[Cleaner] Matching process finished! (" + (Date.now() - time4Process) + "ms)", logs, printFormatted);

  // Specific modifications to matches all
  log("GetVersionsInfo", "[Cleaner] Specific process started... ", logs, printFormatted);
  const time5Process = Date.now();
  matches.splice(matches.length - 4, 4);
  matches.splice(0, 1);
  matches.forEach((value, index) => {
    if (value.includes(" CLI ")) {
      matches[index] = value.replace(" CLI ", "").replaceAll("-", ".");
    } else if (value.match(/[0-9](fixed)/)) {
      matches[index] = value.replace("fixed", " Fixed");
    } else if (value.includes("ASTAP ")) {
      matches[index] = value.replace("ASTAP ", "ASTAP_");
    }
  });
  log("GetVersionsInfo", "[Cleaner] Specific process finished! (" + (Date.now() - time5Process) + "ms)", logs, printFormatted);

  // Transform matches into final list of objects
  log("GetVersionsInfo", "[Cleaner] Finish process started... ", logs, printFormatted);
  const time6Process = Date.now();
  const finalList = [];
  matches.forEach((value) => {
    const match = value.match(/(ASTAP_\S+) (.*)/);
    finalList.push({ id: match[1], content: match[2] });
  });
  log("GetVersionsInfo", "[Cleaner] Finish process finished! (" + (Date.now() - time6Process) + "ms)", logs, printFormatted);

  // Get commits from GitHub
  log("GetVersionsInfo", "[Commits] Get commits started... ", logs, printFormatted);
  const time7Process = Date.now();
  const commitsRaw = await octokit.rest.repos.listCommits({
    repo: repo,
    owner: owner,
    sha: "imported",
    since: format(specifiedDate, "yyyy-MM-dd"),
  });
  log("GetVersionsInfo", "[Commits] Get commits finished! (" + (Date.now() - time7Process) + "ms)", logs, printFormatted);

  // Aggregate and format commits
  log("GetVersionsInfo", "[Commits] Aggregate and format started... ", logs, printFormatted);
  const time8Process = Date.now();
  const commits = commitsRaw.data
    .map((commit) => {
      const date = commit.commit.author.date;
      if (date === format(specifiedDate, "yyyy-MM-dd")) {
        return null;
      }

      const title = commit.commit.message.replaceAll("\n", "").replaceAll("'", "");
      const content = finalList.find((el) => el.id === title.replace("v", "ASTAP_"));
      return {
        date: date,
        commit: commit.sha,
        title: title,
        content: content ? content.content : "Nothing found about this version",
      };
    })
    .filter((commit) => commit !== null);
  log("GetVersionsInfo", "[Commits] Aggregate and format finished! (" + (Date.now() - time8Process) + "ms)", logs, printFormatted);

  log("GetVersionsInfo", "[General] Total Time: " + (Date.now() - time00Process) + "ms", logs, printFormatted);

  const ret = { commits: commits, logs: logs };
  if (printFormatted) console.log(`${JSON.stringify(JSON.stringify(ret))}`);
  else console.log(ret);

  return ret;
};
