# Setup

Everything is installed on the **lab server** (the machine where your code
bases live and where you already run Claude Code). Your laptop and phone only
display the chat.

```
laptop / phone ──HTTPS──► Anthropic ◄──HTTPS (outbound only)── lab server
 (Claude Desktop,                                               claude remote-control
  claude.ai/code, app)                                          + hub + linked repos
```

## SSH: what you need (and don't)

- **Day-to-day: no SSH.** Remote Control works through outbound HTTPS from the
  lab server; your laptop never SSHes in to chat with Claude.
- **Once (and after a server reboot): SSH to the lab server** to install and to
  start the Remote Control server. Your current way (bastion + password) is
  fine. To make it one command, put this in `~/.ssh/config` on your laptop:

  ```
  Host bastion
      HostName <bastion-host>
      User <your-user>

  Host lab
      HostName <lab-server-host>
      User <your-user>
      ProxyJump bastion
  ```
  Then `ssh lab` asks for both passwords and you're in.
- **Claude itself never uses SSH.** The hub denies `ssh`, `scp`, `sbatch`,
  `oarsub`. You launch jobs on OAR and Jean Zay yourself, following the guides
  Claude writes. No keys are copied anywhere.
- **git push from the lab server:** Claude pushes `block/...` branches to
  GitHub. That only works unattended if `git push` from the lab server doesn't
  ask for a password (an SSH key for GitHub, or an HTTPS credential helper with
  a token). If it does ask, Claude doesn't hang: it commits locally, records
  "not pushed", and tells you the command to run. Setting this up is optional.

## 1. Install the kit

```bash
ssh lab
git clone <your-github>/research-kit.git ~/tools/research-kit
cd ~/tools/research-kit
./install.sh --hub ~/research-hub     # skills + rh + a new hub
rh doctor
```

If `rh doctor` says `~/.local/bin` isn't on your PATH, add
`export PATH="$HOME/.local/bin:$PATH"` to `~/.bashrc` and log in again.

Optional: make the hub its own **private** GitHub repo (meeting notes can be
sensitive): create an empty private repo, then
`cd ~/research-hub && git remote add origin <url> && git push -u origin HEAD`.

## 2. Fill `~/research-hub/compute.yaml`

Replace every `TODO` (results paths, OAR frontend and resources, Jean Zay
account, QoS, modules). No passwords or keys go in this file. `rh doctor`
counts the TODOs left. Claude never guesses these values: anything left as
TODO stays TODO in the generated scripts.

If you already used this machine for your experiments, `rh suggest-compute`
lists values found in your repos' launch scripts, shell history and Claude Code
transcripts, with where each came from (it prints only the matched values, never
the surrounding text). Once you have a research-hub session (step 5), type `/rh-setup-compute` there to go
through them with you and fill the file; it writes only what you confirm.

The file is git-ignored: it never goes into the hub's git or to GitHub.

## 3. Log Claude Code in with your claude.ai account

```bash
claude        # then /login, choose the claude.ai account option
```
Remote Control needs a claude.ai login (Pro, Max, Team, Enterprise), not an
API key: unset `ANTHROPIC_API_KEY` / `ANTHROPIC_BASE_URL` if `rh doctor` warns.
On a **Team or Enterprise** plan, an organization Owner must first turn on
**Remote Control** in the Claude Code admin settings.

## 4. Start the always-on server (first time: attached)

```bash
tmux new -s research-hub "bash ~/research-hub/hub.sh"
```
Answer the one-time prompts (enable Remote Control, trust the folder). When it
shows a session URL, it's running. Detach with `Ctrl+B` then `D`. You can
close SSH; the server keeps running.

**Restart after reboots** (`crontab -e`):
```
@reboot tmux new-session -d -s research-hub "bash -lc '$HOME/research-hub/hub.sh'"
```
`hub.sh` also restarts the server if it exits (e.g. after a network outage).

## 5. Open a session on the server

In **Claude Desktop**: start a new **Code** session. In the environment picker
(it offers "This computer", "Remote Control", and your servers), choose
**research-hub** on your server (the name of the machine where you ran
`hub.sh`, e.g. `decore2`). That session runs on the server, inside
`~/research-hub`: it has the kit's skills, the hub's `CLAUDE.md`, your repos.

Don't pick "This computer": that runs on your desktop, where neither the kit
nor your code is.

The same works from claude.ai/code in a browser and from the Claude phone app.
Without the desktop app, SSH to the server and run
`cd ~/research-hub && claude`: same thing, in the terminal.

Enable push notifications once, in such a session: type `/config` and turn on
**Push when actions required** and **Push when Claude decides**.

## 6. Where to type what

| You type… | Where | Examples |
|---|---|---|
| Anything starting with `/rh-`, and plain requests | The chat box of the **research-hub session** from step 5 | `/rh-import-project`, "here are today's meeting notes" |
| Shell commands: `rh …` (no slash), `git`, `bash install.sh`, `tmux` | A **terminal on the server** (SSH) | `rh doctor`, `rh update`, `rh suggest-compute` |

You never need to type `rh …` commands in the chat: Claude runs them itself.
You only use them in a terminal to install, check (`rh doctor`) or update.

**The `/rh-…` commands take no options.** Type the command alone and Claude
asks for what it needs. You can also skip the command and say it in plain
words; Claude picks the matching skill from what you say:

| Instead of… | You can say |
|---|---|
| `/rh-import-project` | "Import my project X. The code is in /home/me/code/x" |
| `/rh-meeting` | "Notes from today's meeting with my supervisor: …" |
| `/rh-status` | "Where are my projects at?" |

If `/rh-…` commands don't show up when you type `/`, check that the session
uses the research-hub environment (not "This computer"), then on the server
run `rh doctor`: it must report the `rh-*` skills as installed in
`~/.claude/skills`. Plain-words requests work either way once the skills are
installed.

## 7. First steps

In the research-hub session:

1. **Import each existing project.** Type `/rh-import-project` (or "import my
   project X"). Claude asks for the project name, a one-line goal, and the path
   of each code base **on the server**. It links the code where it is (never
   moves or copies it), reads it, and writes a map of it. Check the summary it
   gives and correct anything wrong.
2. **Fill compute.yaml.** Type `/rh-setup-compute`. Claude shows values found
   on the server and asks you to confirm each one.
3. **Day to day:** paste meeting notes (or a photo) → `/rh-meeting` →
   `/rh-plan` → you approve → `/rh-design` → you approve → say "go" →
   `/rh-implement` runs while you're away. `/rh-status` shows where everything
   is.

## 8. Let Claude read files on your desktop (optional)

Claude runs on the server and can't see your desktop. With the **bridge**, it
can ask a read-only Claude on your desktop to read and analyze files there
(notes, images, .csv, documents), and gets back only that agent's answer. Your
files never leave the desktop. The local agent can only read the folders you
list; it can't write, run commands, or go on the web.

You need, on the desktop: Python, and Claude Code (the VS Code extension is
enough: the bridge finds its `claude.exe`). On the server: the kit up to date
(`rh update`, server terminal).

**Once, in PowerShell on your desktop:**
```powershell
git clone https://github.com/<you>/research-kit.git $HOME\tools\research-kit
cd $HOME\tools\research-kit
python bin\rh bridge --ssh lab --folder "C:\Users\<you>\Documents\Meetings" --folder "C:\Users\<you>\Documents\Results"
```
- `--ssh`: the name you type after `ssh` to reach the server (`lab` if you use
  the `~/.ssh/config` from the top of this page).
- `--folder`: each folder the local agent may read (repeat it). Saved: next
  time you don't need to give them again. Giving `--folder` again replaces the list.

It connects to the server: type your passwords as usual. When it prints
**Bridge ready**, leave the window open (minimized is fine). Each question from
the server appears there as one line.

**Each day, in PowerShell on your desktop:**
```powershell
cd $HOME\tools\research-kit; python bin\rh bridge
```
Stop it with Ctrl+C or by closing the window. To update the desktop copy of
the kit: `git pull` in that folder.

**In the research-hub session:** just say what you need ("read my notes from
the 28 October meeting on my desktop and ingest them"), or type `/rh-local`.
- Answers are saved in the project under `local/`, and listed in `sources.md`.
- If the bridge isn't running, the question is queued in the project's
  `requests.md` and answered automatically the next time you start the bridge.
  `/rh-status` shows what's waiting.

## 9. Zotero (optional)

Claude can search your Zotero library and read the full text of papers, from
the server, through the Zotero Web API. This needs your library (and its files)
synced to zotero.org, and a read-only API key that only you handle.

1. **In a browser:** go to <https://www.zotero.org/settings/keys>. Note your
   user ID shown there (`ZOTERO_LIBRARY_ID`). Create a new private key with
   read access to your library and **no write access**.
2. **Server terminal:** install `uv` (provides `uvx`, which runs the Zotero
   server; no admin rights needed), unless `uvx --version` already works:
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```
3. **Server terminal:** create your private env file and put the two values in it:
   ```bash
   mkdir -p ~/.config/research-kit
   install -m 600 /dev/null ~/.config/research-kit/env   # readable by you only
   nano ~/.config/research-kit/env
   ```
   ```
   ZOTERO_API_KEY=<the key>
   ZOTERO_LIBRARY_ID=<your user ID>
   ```
   Claude is not allowed to read this file. `hub.sh` loads it.
4. **Server terminal:** `rh zotero-enable` (registers the Zotero tools in the hub), then restart the hub server:
   ```bash
   tmux kill-session -t research-hub
   tmux new -d -s research-hub "bash -lc '$HOME/research-hub/hub.sh'"
   ```
5. **In a new research-hub session:** type `/mcp`; `zotero` should be listed as
   connected. Then ask, e.g., "find my Zotero papers on subword tokenization".

The Zotero tools can search, give an item's metadata, and its full text. They
don't return your notes or annotations.

## 10. Sharing the server with your lab

Claude itself uses little: the model runs at Anthropic, and on the server
Claude Code mostly waits. What uses the machine is what it runs (tests,
analysis scripts, installs). `hub.sh` makes all of it polite:
- low CPU and disk priority (`nice`, `ionice`): other people's work goes first;
- math libraries limited to `lab_server.max_threads` threads (default 4);
- with `lab_server.smoke_test: cpu`, GPUs are hidden from everything Claude runs.

Change these in `compute.yaml`, then restart `hub.sh` (commands in step 9.4).
Claude never launches training here, and runs one unattended `/rh-implement`
at a time. `rh doctor` lists worktrees whose branch is already merged:
remove them to free disk space.

## Using it on another machine

Clone and install the kit, clone your hub repo, run `rh init-hub <hub path>`
(registers it and adds a blank `compute.yaml`), then re-link the code bases
that live on that machine (`rh link-repo <path>` — the projects refer to repos
by name, so nothing else changes). Fill that machine's `compute.yaml`.

## Updating

```bash
rh update            # pull the kit, re-link skills, merge into hub files
rh update --dry-run  # preview only
```
Kit installed before `rh update` existed: run once
```bash
cd ~/tools/research-kit
git -c core.fileMode=false pull     # ignore `chmod +x` done on the scripts
python3 bin/rh update --no-pull
```
(A plain `git pull` refuses there, because the scripts were made executable
locally with `chmod +x`.)

Your edits to the hub's `CLAUDE.md`, `settings.json`, `hub.sh` and
`compute.yaml` are kept: kit changes are merged in. If a file can't be merged
automatically, yours is kept and the kit's version is written next to it as
`<file>.kit-new`; ask Claude `/rh-update` to merge it with you. Nothing is
committed: review with `git status` / `git diff` in the hub and commit yourself.
If `hub.sh` changed, restart the tmux session (the command is printed).

## Private compute.yaml

Hubs created before compute.yaml was git-ignored committed it. `rh update`
untracks it (the file stays on disk); commit that removal. It is still in past
commits, so if the hub was pushed, rewrite its history yourself:
```bash
pip install git-filter-repo
cd ~/research-hub
git filter-repo --path compute.yaml --invert-paths   # removes the 'origin' remote
git remote add origin <url>
git push --force --all
```
Other clones of the hub must then be re-cloned. `rh doctor` warns while the
file is still in the history.

## Troubleshooting

| Symptom | Fix |
|---|---|
| No research-hub option in the environment picker | `tmux attach -t research-hub` on the server: is `hub.sh` running? Any error? |
| "Remote Control is disabled by your organization's policy" | Team/Enterprise: ask an Owner to enable it |
| "requires a claude.ai subscription" | `claude auth login` with the claude.ai account; unset API-key variables |
| "Workspace not trusted" | Run `hub.sh` attached in tmux once and answer the prompt |
| Claude keeps asking permission for a command | Add it to `allow` in `~/research-hub/.claude/settings.json` |
| `repos/x` BROKEN in `rh repos` | The code moved: `rh unlink-repo x && rh link-repo <new path> --name x` |
| Push fails | Expected without GitHub credentials on the server; push yourself from the worktree |
| `git pull` in the kit: "local changes … would be overwritten" (`bin/rh`, `install.sh`) | Only the `chmod +x` permissions differ: `git -c core.fileMode=false pull`, or just use `rh update` |
| `rh update`: "has local changes" | You edited the kit itself: commit or stash in the kit dir, then rerun |
| `<file>.kit-new` next to a hub file | Kit change that couldn't be merged automatically: `/rh-update` |
| Bridge: "ssh ended before the bridge was registered" | Check that `ssh lab` works from PowerShell, and that the server's kit is up to date (`rh update`, then `rh doctor`, server terminal) |
| Claude says your desktop is offline / request queued | Start the bridge on the desktop (step 8); queued requests are answered automatically |
| Bridge: "Claude Code not found" | Install the Claude Code VS Code extension, or pass `--claude <path to claude.exe>` |
| `zotero` missing or failed in `/mcp` | `uvx --version` and the two values in `~/.config/research-kit/env` (server terminal), then restart hub.sh (step 9.4) |
