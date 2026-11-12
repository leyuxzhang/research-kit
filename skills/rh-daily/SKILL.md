---
name: rh-daily
description: Write a very short report of what I did on my last work day (or a day I name) across all projects — what moved, what's waiting, what needs me, and the first step for today — save it in the hub, and offer to publish it to Notion. Use whenever I ask what I did yesterday or last time, for a daily report, a recap, a "where was I", or at the start of a work day when I ask for one.
---

# Daily report

## 1. Facts
- `rh activity` (last work day before today), or `rh activity --day YYYY-MM-DD`
  for a day I name. It lists hub commits, plans touched (with their status
  now), commits in the linked code bases, desktop answers, and desktop
  requests still waiting.
- `rh status` for what's waiting on me now.
- If something needs context (a commit subject is unclear), read the file it
  touched; don't guess.

## 2. Write `reports/daily/<day>.md` (at the hub root)
Very short: 5-8 lines in total, no preamble.
```
# <day> (<weekday>)
**Done:** <one line per project that moved: what, concretely>
**In progress / waiting:** <blocks implementing, jobs I launched, desktop requests>
**Needs you:** <approvals, results to bring back, failures>
**First step today:** <one concrete action>
```
- Only facts from step 1. A day with nothing in it says so in one line.
- No line for a project that didn't move.
- Write in English unless I ask for another language.

Show me the report in the chat, then commit:
`git add reports/daily/<day>.md && git commit -m "daily: <day>"`.

## 3. Offer Notion
Ask: "Publish to Notion?" Only if I say yes:
```bash
rh ask-local --notion write "Under the home page, find the subpage 'Rapports quotidiens', or create it if it doesn't exist. Under it, create a page titled '<day> – Rapport quotidien' with exactly this content: <the report, verbatim>"
```
(no `--project`: the daily report is hub-wide). Give the Bash call a 600000 ms
timeout: I have to click Yes on my desktop first.
- Done: add `Notion: <link>` at the end of the report file and commit.
- "queued" (desktop offline) or "still running" (I haven't clicked yet): tell
  me in one line; nothing else to do.
- "refused": leave it; don't ask again for this report.
