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
the surrounding text). After step 3, ask Claude `/rh-setup-compute` to go
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

## 5. Connect from anywhere

- **Claude Desktop:** Code tab → the session list shows sessions from
  `research-hub@<server>` (computer icon, green dot when online). Start new
  sessions there; each runs on the lab server.
- **Browser:** claude.ai/code, same list.
- **Phone:** Claude app → Code.

Enable push notifications once, in any session on the server:
`/config` → **Push when actions required** and **Push when Claude decides**.

## 6. First steps

In a new session:
- `/rh-import-project` for each existing project (links its code, maps it), or
  `/rh-new-project`.
- Paste meeting notes (or a photo) → `/rh-meeting` → `/rh-plan` → approve →
  `/rh-design` → approve → "go" → `/rh-implement` runs while you're away.

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
| No session in the list | `tmux attach -t research-hub` on the server: is `hub.sh` running? Any error? |
| "Remote Control is disabled by your organization's policy" | Team/Enterprise: ask an Owner to enable it |
| "requires a claude.ai subscription" | `claude auth login` with the claude.ai account; unset API-key variables |
| "Workspace not trusted" | Run `hub.sh` attached in tmux once and answer the prompt |
| Claude keeps asking permission for a command | Add it to `allow` in `~/research-hub/.claude/settings.json` |
| `repos/x` BROKEN in `rh repos` | The code moved: `rh unlink-repo x && rh link-repo <new path> --name x` |
| Push fails | Expected without GitHub credentials on the server; push yourself from the worktree |
| `rh update`: "has local changes" | You edited the kit itself: commit or stash in the kit dir, then rerun |
| `<file>.kit-new` next to a hub file | Kit change that couldn't be merged automatically: `/rh-update` |
