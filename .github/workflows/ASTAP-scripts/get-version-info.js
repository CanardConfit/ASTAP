const fs = require('fs');
const cheerio = require('cheerio');
const axios = require('axios');
const { exit } = require('process');
const git = require('isomorphic-git');
const { DateTime } = require("luxon");

const specificDate = process.argv[2] || '';

if (specificDate === "") {
    console.log("No specific date specified.");
    exit(1);
}

axios.get('https://www.hnsky.org/history_astap').then(async response => {
    const $ = cheerio.load(response.data)

    const paragraphs = $('p[style="text-align: left;"], p[align="left"], big');

    let listDates = [];

    paragraphs.each((index, paragraph) => {
        const bigElements = $('> big', paragraph);
        const spanElements = $('> span', paragraph);

        const firstBigText = $(bigElements[0]).text();
        const secondBigText = $(bigElements[1]).text();
        let spans = spanElements.text().trim();

        if (bigElements[2])
            spans += $(bigElements[2]).text();

        const dateRegex = /ASTAP_\d{4}\.\d{2}\.\d{2}(.*$)/;
        let reg = dateRegex.exec(firstBigText);
        if (reg) {
            if (reg[1]) {
                spans += reg[1];
                reg[0] = reg[0].replace(reg[1], "").trim();
            }

            reg[0] = reg[0].replace(" ", "").replace("ASTAP_", "").replace(/\./g, '-').trim();

            const date = reg[0];
            const content = secondBigText.replace(/(\r\n|\n|\r)/gm, " ") + spans.replace(/(\r\n|\n|\r)/gm, " ").trim();
            listDates.push({date: date, content: content});
        }
    });

    const commitsRaw = await git.log({ fs, dir: "../../../", ref: "refs/remotes/origin/imported", since: new Date(specificDate) })
    const commits = commitsRaw.map(commit => {
        let date = DateTime.fromSeconds(commit.commit.author.timestamp, {zone: `UTC${commit.commit.author.timezoneOffset/60}`});

        if (date.toFormat("yyyy-MM-dd") === specificDate) {
            return null;
        }

        let title = commit.commit.message.replace("\n", "").replaceAll("'", "");
        let content = listDates.find(d => d.date === title.replace("v", "").replaceAll(".", "-"));
        return {
            date: date.toFormat("yyyy-MM-dd HH:mm:ss ZZ"),
            commit: commit.oid,
            title: title,
            content: content ? content.content : "Nothing found about this version"
        };
    }).filter(commit => commit !== null);

    console.log(`${JSON.stringify(JSON.stringify(commits))}`);

});
