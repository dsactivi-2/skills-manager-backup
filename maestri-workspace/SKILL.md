---
name: maestri-workspace
description: Create new Maestri workspaces and floors from the command line, optionally cloning an existing workspace as a starting point, land or delete a floor when its work is done, and post a floor's status. Use when the user asks to provision, spin up, or scaffold a new workspace, project environment, or isolated floor, or to land, merge back, or remove a floor, and whenever you are working on a task on a floor, to keep its status current.
user-invocable: true
---

# Maestri Workspace Provisioning

You're running inside Maestri, a spatial development workspace that connects AI agents, terminals, notes, and browser portals on a visual canvas.
The `maestri` CLI is a command-line executable pre-installed and available on PATH. If `maestri` is not found, use `"$MAESTRI_CLI"` instead; this environment variable always points to the full binary path.

Workspaces are standalone canvases, each rooted in its own project directory — isolation *between* projects. Floors are levels inside one workspace, optionally backed by a git worktree of its repository — isolation *within* a project. Use these commands to provision either without leaving the terminal, e.g. to set up a ready-to-work environment for a brand-new project the user just scaffolded.

These commands require **Maestro Mode** on your terminal, except `maestri floor status`, which any agent uses for the floor it is on. If a command returns "This terminal is not the Maestro", the user must toggle Maestro on your terminal in the canvas to unlock it.

## Floor status (any agent)

When you work on a task on a floor, keep that floor's status current with `maestri floor status`. It is the line the user glances at in the sidebar to see how things stand, so post when you start, at a real milestone, when you need the user (`--state blocked`), and when the work is ready (`--state review`). Moving to `blocked`, `review` or `done` also sends the user a notification, so reach for those states only when they are true. One short line in plain words; don't post every step. The full command is under Commands below.

## Scope & safety

- Creation and filing are additive and reversible. Renaming is allowed too — it's a label change, nothing underneath moves. Workspaces have deliberately **no delete command** — removing one stays in the UI, on explicit user action.
- Floors are the one exception: `maestri floor land` and `maestri floor delete` change the user's project (a merge into their branch, a deleted clone and branch). **Run them only when the user asks, or after confirming with them** — a floor reporting `review` is ready for the user to decide, not a signal to land it yourself.
- Creation is always silent: nothing changes on the user's screen. The new workspace or floor simply appears in the sidebar, ready when the user opens it.
- The target directory must already exist — create the folder (and `git init` if wanted) before calling `workspace create`.

## A New Floor mention

A prompt that carries `<maestri-create-floor skill="maestri-workspace" />` comes from the composer's New Floor action: the person wants a floor for the task the prompt describes. Create it with `maestri floor create`, named for the task in a few words (its branch follows the name), with no other flags unless the prompt asks. When the task is reviewing a pull request, pass `--pull-request` with its number or link instead of a name. If the prompt also asks for the work, recruit an agent onto the new floor for it (`maestri recruit "Name" --floor "Floor"`, from the maestri-manager skill) instead of doing it from your own floor. Reply with the floor's name and branch.

## Commands

### `maestri workspace create "Name" --dir PATH [--from "Source Workspace"] [--group "Group"] [--folder "Folder"]`

Creates a new workspace rooted at PATH.

- `--from "Source Workspace"` — clone an existing workspace as the starting point: its full canvas layout (terminals, notes, file trees, floors, connections) is deep-copied, and every path under the source's working directory is retargeted onto PATH. Terminals start fresh — no scrollback, nothing running — and boot when the user first opens the workspace. Paths pointing outside the source's directory are kept as-is.
- `--group "Group"` — file the workspace under a sidebar group, creating the group if it doesn't exist yet.
- `--folder "Folder"` — file the workspace inside a sidebar folder. Alone, the folder is matched anywhere in the sidebar (created at the sidebar root when missing); with `--group`, the folder lives inside that group; with `--root`, only folders at the sidebar root are matched. If a bare folder name matches more than one folder, the command asks you to add `--group` or `--root` to disambiguate.
- Without `--from`, the workspace starts with an empty canvas.

The user's "template" is just a normal workspace — suggest they keep one laid out the way they like and clone it by name:

```
maestri workspace create "Acme Churn Analysis" --dir ~/Work/acme-churn --from "Data Project Template" --group "Data Projects"
maestri workspace create "Q3 Report" --dir ~/Work/q3 --group "Data Projects" --folder "Reports"
```

### `maestri workspace move "Name" --group "Group" | --folder "Folder" | --root`

Refiles an existing workspace in the sidebar. Same destination rules as `create`: groups and folders are created when missing, `--group` + `--folder` scopes the folder to that group, `--root` + `--folder` scopes it to the sidebar root, and `--root` alone moves the workspace out of any group or folder. This only reorganizes the sidebar — the workspace itself is untouched.

```
maestri workspace move "Acme Churn Analysis" --folder "Archive 2026"
maestri workspace move "Q3 Report" --folder "Reports" --root
maestri workspace move "Scratch" --root
```

### `maestri workspace rename "Current Name" "New Name"`

Renames an existing workspace in the sidebar. Only the label changes — the canvas, its floors, and its working directory are untouched. The new name must not collide with another workspace (a case-only change like `"acme"` → `"Acme"` is fine). Unknown names fail with the list of valid names to run first.

```
maestri workspace rename "Acme Churn Analysis" "Acme Churn v2"
```

### `maestri workspace list`

Prints the sidebar hierarchy exactly as the user sees it — Pinned first, then the root workspaces and folders in order, then each group with its folders — with every workspace's directory and floor count, marking the one your terminal lives in. Empty groups and folders are listed too, so the output doubles as a map of valid filing destinations. Run it before `create` or `move` to pick a free name, the exact `--from` source, and where the workspace should live.

### `maestri floor create "Name" [--branch NAME] [--existing-branch] [--copy] [--no-git] [--copy-ground]`

Adds a floor to **your own workspace**. By default the floor gets git isolation when the workspace is a git repository: a **git worktree** of the project on its own branch, in `.maestri/floors` beside the project, so work there can't disturb the ground floor. This works on the Mac and in SSH, Docker and custom-runtime workspaces, where the worktree is made on that machine. Where the disk supports copy-on-write (APFS, btrfs, XFS) the ground's files, dependencies and local settings included, are cloned into it, so it is ready at once; elsewhere it is a clean checkout and setup hooks install what it needs. The worktree shares the project's history: its branch and commits are in the project from the start. When the workspace can't support isolation (not a repository, or a Docker sandbox), a plain floor is created instead and the response says so.

- `--branch NAME` — branch for the floor (default: a slug of the floor name). Fails if the branch already exists.
- `--existing-branch` — check out an existing branch instead of creating one. A worktree can't take the branch Ground has checked out; add `--copy` for that.
- `--copy` — instead of a worktree, Maestri creates a fully isolated clone of the repository, exactly as it is right now (on the Mac, copy-on-write on APFS). Because it's separate, it can check out the same branch as Ground, and landing the floor transfers its work back to Ground. Use it for that, or when the user asks for full isolation; a worktree is the right choice for most work.
- `--no-git` — skip isolation and share the ground directory.
- `--copy-ground` — start the floor with a copy of the ground floor's canvas layout.

```
maestri floor create "Refactor Auth" --branch refactor-auth
maestri floor create "Scratch" --no-git
```

### `maestri floor create ["Name"] --pull-request NUMBER|URL [--copy] [--copy-ground]`

Adds a floor to review an open pull request of the project: `42`, `#42` or its link. Maestri asks the project's host about it (the provider's CLI, such as `gh` or `glab`, signed in), brings its branch into the project and checks it out on the floor, which then follows the pull request in its landing sheet: review, checks, merge. The name defaults to `#42` and the title. When the host confirms the pull request's branch is in the project's own repository, the floor has that branch and commits pushed from it go to the pull request. Otherwise (a fork, or a host that doesn't say), the floor has a copy of its commits named `pr-42`: commits made there can't reach it. It's refused, with the reason, when the pull request isn't open, is already on a floor or being made into one, changed while it was fetched, the host has no provider that can list pull requests, or your local branch of that name went its own way or pushes somewhere else. `--branch`, `--existing-branch` and `--no-git` don't apply.

```
maestri floor create --pull-request 42
maestri floor create "Review Login Fix" --pull-request https://github.com/acme/app/pull/42
```

After creating an isolated floor you can staff it without leaving your own floor: `maestri recruit "Name" --floor "Refactor Auth" --role "..."` (from the maestri-manager skill) spawns an agent there, working inside the floor's checkout, still wired to you for `ask`/`check`.

### `maestri floor land "Name" [--into BRANCH] [--delete-branch] [--keep-floor]`

Brings the floor's branch into the project, the way the user's Land button does. **Only when the user asks, or after confirming with them.** **Run it from a terminal on the ground level**: a floor is never landed from within itself, and a terminal on any floor is refused. Landing removes the floor afterwards and keeps its branch in the project, ready to review or merge.

- `--into BRANCH`: also merge the floor's branch into BRANCH (for example `main`), like choosing a target in the landing sheet.
- `--delete-branch`: after a merge with `--into`, delete the floor's branch.
- `--keep-floor`: leave the floor in place after landing.

A land is refused, with the reason, when there is uncommitted work on the floor or on the ground, or when the merge would conflict (the files are named). Nothing is changed in that case: commit or stash the work, or resolve the conflict in the floor's clone, then land again. Ask the agent on the floor to commit its work before you land it.

```
maestri floor land "Refactor Auth"
maestri floor land "Refactor Auth" --into main --delete-branch
```

### `maestri floor delete "Name" [--keep-branch] [--force]`

Removes the floor: its terminals, notes and drawings, and its clone. The floor's branch is deleted from the project too unless `--keep-branch`. **Only when the user asks, or after confirming with them**, and **from the ground level only**, like `land`. If the clone cannot be removed the floor is left untouched and the command says why; `--force` removes the floor anyway.

```
maestri floor delete "Scratch"
maestri floor delete "Refactor Auth" --keep-branch
```

### `maestri floor list`

Lists the ground floor and every floor of your workspace with branch, clone path, node count, and status.

### `maestri floor status ["Text"] [--state working|blocked|review|done] [--progress 2/5] [--floor "Name"] [--clear]`

The one line the user sees under a floor in the sidebar: where the work there stands. Any terminal can post it for the floor it is on; only the Maestro can name another floor with `--floor` (`"Ground"` for the ground level, where a summary of the floors above belongs). `--state` defaults to `working`; moving into `blocked`, `review` or `done` notifies the user, while new text or progress in the same state does not. `--progress` takes `2/5`, `40%` or `0.4`. Without text it prints the current status; `--clear` removes it. Long lines are cut at 120 characters.

```
maestri floor status "Tests green, wiring the login screen" --progress 3/5
maestri floor status "Need a decision on the token format" --state blocked
maestri floor status "PR #412 open, ready to land" --state review
maestri floor status "2 of 3 floors in review" --floor "Ground"
```

### `maestri floor unload "Name"`

Unloads a floor, like its Unload menu item. Not the floor you are on.

```
maestri floor unload "Refactor Auth"
```

### Opening a pull request from your floor

When you open one yourself (`gh pr create`, `glab mr create`), write its description from the repository's pull request template: `gh` and `glab` skip the template once you pass a body. Look in the base branch for `pull_request_template.md` (any case, `.md`, `.txt` or no extension) in `.github/`, the root or `docs/`, then GitLab's `.gitlab/merge_request_templates/Default.md`. When a `PULL_REQUEST_TEMPLATE/` or `merge_request_templates/` folder holds several, pick the one that fits the change. Keep its headings and checklists, replace the placeholder text with what this branch actually does, and check only the boxes that are true. A screenshot or a short recording helps a visual change: with gh 2.99 or later, `--attach ./shot.png` uploads it, and a `![shot](./shot.png)` already in the body is pointed at the upload. Maestri notices the pull request when your turn ends and follows it on the floor, so there's no need to report it there yourself; a status such as `"PR #412 open" --state review` still helps.