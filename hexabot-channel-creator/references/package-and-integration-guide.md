# Package And Integration Guide

Use the target project's versions and package manager. Treat all version ranges below as illustrative until verified against installed Hexabot packages and a current official channel.

## Contents

- [Dynamic discovery](#dynamic-discovery)
- [Package contract](#package-contract)
- [Entry points](#entry-points)
- [Install and register](#install-and-register)
- [Source settings and credentials](#source-settings-and-credentials)
- [Package verification](#package-verification)
- [Runtime troubleshooting](#runtime-troubleshooting)

## Dynamic discovery

Current Hexabot v3 documentation describes these compiled discovery shapes:

```text
node_modules/@hexabot-ai/api/dist/extensions/channels/**/*.channel.js
node_modules/hexabot-channel-*/**/*.channel.js
dist/extensions/channels/**/*.channel.js
```

Verify the loader in the active Hexabot version. A source `.channel.ts` file is insufficient; the compiled `.channel.js` file must be present where the runtime scans.

For a local extension, check the TypeScript build includes its directory. For a package, check the published tarball contains the compiled handler.

## Package contract

Use a package shape like this only after reconciling it with a current sibling package:

```json
{
  "name": "hexabot-channel-acme",
  "version": "1.0.0",
  "description": "Acme channel extension for Hexabot v3.",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "exports": {
    ".": {
      "types": "./dist/index.d.ts",
      "require": "./dist/index.js",
      "import": "./dist/index.js"
    },
    "./index.channel": {
      "types": "./dist/index.channel.d.ts",
      "require": "./dist/index.channel.js",
      "import": "./dist/index.channel.js"
    }
  },
  "files": ["dist", "src", "README.md", "LICENSE.md"],
  "scripts": {
    "clean": "rimraf dist coverage",
    "build": "tsc -p tsconfig.build.json",
    "check:dist": "test -f dist/index.js && test -f dist/index.channel.js",
    "typecheck": "tsc --noEmit -p tsconfig.json",
    "test": "jest --config jest.config.ts",
    "prepublishOnly": "npm run clean && npm run build && npm run check:dist"
  },
  "peerDependencies": {
    "@hexabot-ai/api": ">=3 <4",
    "@hexabot-ai/types": ">=3 <4",
    "@nestjs/common": "^11",
    "@nestjs/core": "^11",
    "zod": "^4"
  }
}
```

Keep runtime host libraries as peer dependencies when the current official packages do. Add the provider SDK and Nest modules actually imported by the package. Mirror them in dev dependencies when local compilation and tests require them.

Check:

- Node engine and package-manager version;
- CommonJS/ESM output and `exports` compatibility;
- TypeScript module resolution and decorator settings;
- inclusion/exclusion of tests and locale files;
- license headers and license file required by the source project;
- dependency security overrides already used by sibling packages;
- exact lower bounds for APIs the implementation calls.

Do not hand-edit lockfiles. Run the target package manager when dependency changes are authorized.

## Entry points

Use `index.channel.ts` for the discoverable default-exported `@Injectable()` handler. Use `index.ts` for public helpers and types only if the package needs a normal library entry point. Ensure the build preserves the `.channel` filename.

Avoid importing monorepo-only `@/` aliases from standalone packages. Import exported APIs from `@hexabot-ai/api`, `@hexabot-ai/types`, Nest packages, the provider SDK, and relative local modules.

## Install and register

After building or installing the channel:

1. restart the Hexabot API so dynamic providers are resolved again;
2. call `GET /api/channel` and confirm the channel name and settings JSON schema appear;
3. create or update a `Source` with the exact channel name, valid settings, a unique source reference, an active state, and the intended default workflow;
4. configure the provider webhook or Gateway client for that source;
5. exercise an inbound event and an outbound reply.

For HTTP providers, the conventional endpoint is:

```text
https://<public-host>/api/webhook/<sourceRef>
```

When supported, appending a workflow ID routes the inbound event to that workflow. Verify the current controller routes before documenting this behavior.

For SDK/Gateway channels, document required intents, permissions, event subscriptions, redirect URLs, bot installation scopes, and connection requirements. Start one client per active source only after its credentials and account identifiers validate.

## Source settings and credentials

The channel metadata endpoint derives the admin form from the handler's zod source settings schema. Pass the schema to `super(channelName, schema)`. Do not create a `*.settings.ts` dynamic provider for per-source values.

Prefer credential entity references for tokens and secrets when the target Hexabot version supports them. Keep non-secret identifiers and feature flags in ordinary source settings. Validate that the selected credential contains a non-empty value before enabling a source connection.

## Package verification

Run the scripts present in the target package. A typical sequence is:

```sh
pnpm run format
pnpm run lint
pnpm run typecheck
pnpm run test
pnpm run build
pnpm run check:dist
pnpm pack --dry-run
```

Do not invent unavailable commands. If npm is the established manager, use `npm run ...` and `npm pack --dry-run`.

Inspect the tarball listing for:

- `dist/index.channel.js` and its declaration file;
- the public `dist/index.js` entry point when declared;
- required locale and metadata files;
- absence of credentials, environment files, coverage output, fixtures with personal data, and unrelated source artifacts.

## Runtime troubleshooting

- Missing from `GET /api/channel`: inspect compiled filename, loader glob, default export, `@Injectable()`, package name, package installation, and API restart.
- Missing settings form: confirm the schema is passed to `super()` and parses `{}` with defaults when that is the intended UX.
- Webhook returns 400: inspect zod issues and raw provider payload shape without logging secrets or full personal data.
- Webhook returns 401: inspect raw-body availability, source-scoped secret resolution, signature format, timestamp window, and constant-time comparison.
- HTTP 200 but no workflow runs: inspect source state/ref, default or URL workflow ID, event sender identity, event type, event context, subscriber resolution, and event-bus dispatch.
- Inbound works but replies fail: inspect capabilities, encoder mapping, recipient/thread attributes, credential source, provider permissions, public attachment access, and upstream error handling.
- Duplicate conversations: re-evaluate subscriber identity normalization and group/thread routing.
- Cross-account messages: audit all clients, caches, settings, decoders, and API requests for source-ID scoping.
