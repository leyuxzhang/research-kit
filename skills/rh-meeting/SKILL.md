---
name: rh-meeting
description: Ingest meeting notes into a project — raw notes typed in the chat, a pasted transcript, an attached file, or a photo of handwritten notes or a whiteboard — keep them verbatim and turn them into objectives, ideas, decisions, action items, and impacts on existing plans. Use whenever I share or start writing notes from a meeting, supervisor discussion, brainstorming, or research idea, even if I don't say "meeting".
---

# Ingest meeting notes

## 1. Which project?
Infer it from the content or the conversation; if unclear, ask (show the
project list from `rh status`). An idea that fits no project → offer
**rh-new-project** first.

## 2. Create or append
- New meeting: `rh new-meeting <project> [--slug <topic>] [--date YYYY-MM-DD]`
  (date defaults to today; ask if I imply another day).
- I'm still writing ("more notes", "add this") → append to **Raw notes** of
  today's meeting file instead of creating a new one.

## 3. Raw notes: verbatim
Copy exactly what I wrote, in my language. For a photo, transcribe it and mark
unreadable words `[?]`. For an attached file, quote its text. Never clean up,
reorder, or translate the raw section: it is the source of truth.

## 4. Structure (in English unless the project says otherwise)
Fill: Summary, Objectives, Ideas (disposition: plan / explore / parked),
Decisions, Action items, Open questions, Impact on existing plans.

For **Impact on existing plans**, read the project's active `plan.md` files and
say concretely: blocks to add, blocks to modify (what changes), blocks to drop.
Set `plans_affected` in the front-matter.

Rules:
- Separate what was **decided** from what was **suggested**. If unsure which,
  put it in Open questions.
- Don't add ideas that weren't in the notes. If you have a suggestion, add it
  under Open questions, prefixed "Claude suggests:".
- Add one dated line per decision to the Decisions log in `project.md`.

## 5. Finish
- Commit the hub: `git add -A projects/<p> && git commit -m "<p>: meeting <date>"`.
- Reply with: a 3-5 line summary, the impact on plans, and the open questions.
- Ask: "Turn this into a plan (new or update of <plan-id>)?" → **rh-plan**.
