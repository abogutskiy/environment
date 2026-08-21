## Working with repositories


The main repository is ~/srch-search-api with a remore origin `git@github.com:ppl-ai/srch-search-api`

All other local repositories are in `~/projects/`. Remote origin is `git@github.com:ppl-ai/<repo-name>`.

When asked to modify files in another repository:

1. **Check `~/projects/`** for the repo first. check {repo_name}, {repo_name}-%i
   folders first.
2. **If not found**, clone it: `git clone git@github.com:ppl-ai/<repo-name>.git ~/dev/<repo-name>` (SSH keys are configured).
3. **If found**, check for local changes (`git status`):
   - **Has uncommitted changes or is on a non-main branch**: Tell the user and ask how to proceed. Do not discard their work.
   - **Clean on main**: `git pull` to update, then make the requested changes.
   - **Clean on another branch**: Ask the user whether to switch to main or stay on the current branch.
4. **Merge conflicts**: If a file has conflict markers (e.g. `<<<<<<<`), resolve them before proceeding and show the user the resolution.

## Cleaning up old branches

When asked to clean up branches (e.g. "clean branches", "delete merged branches"):

1. `git fetch --prune` to sync remote state.
2. For each local branch (except `main`/`master` and the current branch):
   - Use `git cherry main <branch>` to check if all commits are already in main. This correctly detects squash-merged and rebased PRs (compares by patch content, not SHA).
   - **Delete** if `git cherry` shows 0 `+` lines (all changes are in main).
   - **Skip** if `git cherry` shows any `+` lines (has unique changes not in main).
3. **Before deleting**, show the user the list of branches to delete and branches to skip (with reasons). Wait for confirmation.
4. After confirmation, delete the approved branches and report the result.

## Temporary and design files

- All temporary files for the session go in `artifacts/` at the session's root directory (the repo where the session was opened), even when working on files outside that directory.
- Design requests (plans, architecture notes, deployment designs, etc.) go in `artifacts/design/` with a short but informative filename. Never delete them — update or rename if needed. If there is no such folder – create it.

