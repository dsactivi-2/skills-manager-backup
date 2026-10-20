---
name: node-package-installation
description: Use when installing Node packages. Resolve scope and verify.
---

# Node Package Installation

## Procedure

1. Identify the requested artifact before installing it.
   - `npx skills add <source>` installs an agent skill, not an application dependency.
   - `npm install <package>` installs a Node.js package for an application or a global Node environment.
2. Determine scope from the active project. Install application libraries in that project's root so its manifest and lockfile record the dependency.
3. If no project is active, ask the user to provide a target project or explicitly choose global scope. Do not silently install a library into the home directory or globally.
4. Run the requested install command in the chosen scope. If the clone sits under a parent `pnpm-workspace.yaml` (including `$HOME`), `pnpm install` is a no-op there — use `pnpm install --ignore-workspace` so `node_modules` lands in the clone.
5. Verify the exact package and version after installation:
   - Project scope: `npm ls --depth=0 <package>` in the project root, or `ls node_modules/<package>/package.json` when pnpm reports success without creating that directory.
   - Global scope: `npm ls -g --depth=0 <package>`.
   - pnpm `ERR_PNPM_IGNORED_BUILDS`: `pnpm approve-builds --all --ignore-workspace` then reinstall; do not treat the error as a finished install.
6. Report the resolved scope, package version, and installation path concisely.

## Pitfalls

- Separate agent-skill installation from Node dependency installation before executing; both may use `npx` or `npm`, but they modify different systems.
- Ask for explicit global scope when no project is selected; libraries installed globally are not recorded in an application's manifest or lockfile.
- Verify with `npm ls` after installation; a successful installer exit does not by itself identify the installed version or location.
