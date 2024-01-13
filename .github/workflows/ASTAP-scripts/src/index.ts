import { Argument, Command } from "commander";
import { getVersionsInfo } from "./get-version-info";
import { createPullRequest } from "./create-pull-request";
import { createOctokit } from "./tools";
import { runChecks } from "./run-checks";
import { autoMerge } from "./auto-merge";

const program = new Command();

const repo = "ASTAP-dev";
const author = "CanardConfit";

program
  .name("astap-scripts")
  .version("2.0.0")
  .description("CLI scripts used by github actions on the ASTAP repository.")
  .option("-t, --token <token>", "Token of GitHub for Octokit.");

program
  .command("runChecks")
  .addArgument(
    new Argument("[printJsonFormat]", "Specify if you prefer a JSON at the end of the program or live log.")
      .argParser<boolean>((value) => value == "true")
      .default(true),
  )
  .description("Runs tests to verify that a PR must be created")
  .addHelpCommand(
    "after",
    `
    Example:
    $ runChecks
    $ runChecks false
  `,
  )
  .action(async (printJsonFormat) => {
    const time = Date.now();
    await runChecks(createOctokit(program.opts()), author, repo, printJsonFormat);
    if (printJsonFormat) console.info("[Main] [Command] Command took : " + (Date.now() - time) + "ms");
  });

program
  .command("getVersionsInfo")
  .addArgument(new Argument("<specifiedDate>", "Date of versions from which we retrieve").argParser<Date>((value) => new Date(value)))
  .addArgument(
    new Argument("[printJsonFormat]", "Specify if you prefer a JSON at the end of the program or live log.")
      .argParser<boolean>((value) => value == "true")
      .default(true),
  )
  .description("Retrieves information about versions released since the specified date")
  .addHelpCommand(
    "after",
    `
    Example:
    $ getVersionsInfo 2023-10-08
    $ getVersionsInfo 2023-10-08 false
  `,
  )
  .action(async (specifiedDate, printJsonFormat) => {
    const time = Date.now();
    await getVersionsInfo(specifiedDate, createOctokit(program.opts()), author, repo, printJsonFormat);
    if (printJsonFormat) console.info("[Main] [Command] Command took : " + (Date.now() - time) + "ms");
  });

program
  .command("createPullRequest")
  .addArgument(
    new Argument("<runChecks>", "Allows you to choose whether createPullRequest calls runChecks.").argParser<boolean>((value) => value == "true"),
  )
  .addArgument(
    new Argument(
      "[specifiedDate]",
      "If filled, createPullRequest will self execute getVersionInfo, and it's the date of versions from which we retrieve.",
    )
      .argParser<Date | null>((value) => (value != "" ? new Date(value) : null))
      .default(""),
  )
  .addArgument(new Argument("[raw]", "If filled, createPullRequest need the return of getVersionsInfo script.").default(""))
  .description("Create a Pull Request.")
  .addHelpCommand(
    "after",
    `
    Example:
    $ createPullRequest true -t <token>
    $ createPullRequest false 2023-12-05 -t <token>
    $ createPullRequest false 2023-12-05 "{JSON OF GETVERSIONINFO}" -t <token>
  `,
  )
  .action(async (runChecks, specifiedDate, raw) => {
    const time = Date.now();
    if (raw == "" && !specifiedDate && !runChecks) {
      program.error("[specifiedDate] must be filled if [raw] is not filled and <runChecks> false.");
      return;
    }
    if (!program.opts().token) {
      program.error("You need a token for creating pull request.");
      return;
    }
    await createPullRequest(createOctokit(program.opts()), author, repo, runChecks, raw, specifiedDate);
    console.info("[Main] [Command] Command took : " + (Date.now() - time) + "ms");
  });

program
  .command("autoMerge")
  .addArgument(
    new Argument("<forceMerge>", "Allows you to choose if program ignore wait time or not.").argParser<boolean>((value) => value == "true"),
  )
  .addArgument(
    new Argument("[printJsonFormat]", "Specify if you prefer a JSON at the end of the program or live log.")
      .argParser<boolean>((value) => value == "true")
      .default(true),
  )
  .description("Auto-Merge automated PR if time of wait is done.")
  .addHelpCommand(
    "after",
    `
    Example:
    $ autoMerge false -t <token>
    $ autoMerge true -t <token>
  `,
  )
  .action(async (forceMerge, printJsonFormat) => {
    const time = Date.now();
    if (!program.opts().token) {
      program.error("You need a token for merge pull request.");
      return;
    }
    await autoMerge(createOctokit(program.opts()), author, repo, forceMerge, printJsonFormat);
    if (printJsonFormat) console.info("[Main] [Command] Command took : " + (Date.now() - time) + "ms");
  });

program.parse();
