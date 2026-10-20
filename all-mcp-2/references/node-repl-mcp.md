# Node Repl Tools Reference

## js

Run JavaScript in a persistent Node-backed kernel with top-level await. This is the JavaScript execution tool for the `node_repl` MCP server; use it whenever instructions say to use `node_repl`, the Node REPL MCP, or run Node REPL code. If `timeout_ms` is omitted, execution times out after 30000 ms (30 seconds); pass a larger `timeout_ms` for slow browser automation or other long-running operations. Use `nodeRepl.cwd`, `nodeRepl.homeDir`, and `nodeRepl.tmpDir` to inspect host paths. Use `nodeRepl.requestMeta` to inspect the current MCP request `_meta` object during a tool call. Use `nodeRepl.setResponseMeta(meta)` to attach top-level MCP result `_meta`; repeated calls shallow-merge object keys for the current tool call. Use `nodeRepl.write(text)` when you want exact text output in the tool result; it writes the string exactly as given and does not append a newline. Prefer it over `console.log(...)` for final output, JSON, or other text you plan to consume programmatically. `console.log(...)` is still useful for ad hoc debugging or object inspection because it formats values and appends line breaks automatically. Use `await nodeRepl.emitImage(imageLike)` to return images; each call adds one image to the outer tool result, so call it multiple times to emit multiple images. Supported image inputs are a data URL, inferred PNG/JPEG/WebP bytes, or `{ bytes, mimeType }`. Saved references to `nodeRepl.write(...)` and `nodeRepl.emitImage(...)` stay reusable across calls, but async callbacks that fire after a call finishes still fail because no exec is active. Top-level bindings persist across calls until `js_reset`. If a call throws, prior bindings remain available and bindings that finished initializing before the throw often remain reusable. For reusable names that may be assigned again later, prefer top-level `var name = ...`; `var` can be redeclared across calls. If you hit `SyntaxError: Identifier 'x' has already been declared`, reuse the existing binding if possible, reassign it only if it was declared with `let` or `var`, or pick a new name instead of resetting immediately; a previous `const x` cannot be changed into `var x`. Use a short `{ ... }` block only for temporary scratch names, and do not wrap an entire call in block scope if you want those names reusable later. Use dynamic imports like `await import("playwright")`, `await import("pkg")`, or `await import("./file.js")`; top-level static `import` is not supported. Import packages by package name after installing them into a directory added with `js_add_node_module_dir`, `NODE_REPL_NODE_MODULE_DIRS`, or the working directory. Do not import package entrypoints by filesystem path such as `./node_modules/playwright/index.mjs`. Imported local files must be ESM `.js` or `.mjs` files and run in the context chosen at their dynamic-import boundary, so they can also use `nodeRepl.*`, the captured `console`, and `import.meta` helpers. Bare package imports always resolve from the REPL-wide search roots (`NODE_REPL_NODE_MODULE_DIRS`, then directories later added with `js_add_node_module_dir`, then cwd), not relative to the imported file's location. Imported local files may statically import other local `.js` / `.mjs` files, available packages, and allowed Node builtins. `import.meta.resolve()` returns importable strings such as `file://...`, bare package names, and `node:...` specifiers. Local file modules reload between execs. `node:` builtins are generally available via dynamic import, but `process` / `node:process` remains blocked for now because the current Rust-server-to-Node-child transport runs over stdio and raw process streams can corrupt it. Prefer `nodeRepl.write(text)` for text output and `nodeRepl.emitImage(...)` for images.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| code | string | Yes | JavaScript source to execute in the persistent Node-backed kernel. The code runs with top-level await and can use the `nodeRepl` helpers. Examples: `nodeRepl.write(nodeRepl.cwd)`, `const { chromium } = await import("playwright")`, or `await nodeRepl.emitImage(pngBuffer)`. |
| timeout_ms | integer | No | Optional execution timeout in milliseconds. Defaults to 30000 (30 seconds) when omitted. |
| title | string | No | Short user-facing description of what this code block is doing. Use a few words, for example `Inspect package metadata` or `Render chart preview`. |

### Example

```bash
python3 scripts/call-tool.py js '{"code":"...","timeout_ms":0,"title":"..."}'
```

---

## js_add_node_module_dir

Add an absolute `node_modules` directory to the REPL-wide Node module search roots for future package imports. The directory stays available for this MCP server lifetime, including after `js_reset`. Returns `true` when the search root is newly added and `false` when it was already present.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| path | string | Yes | Absolute path to a node_modules directory to add to Node package resolution. |

### Example

```bash
python3 scripts/call-tool.py js_add_node_module_dir '{"path":"..."}'
```

---

## js_reset

Reset the persistent JavaScript kernel and clear all bindings created by prior `js` calls. Use this when you need a clean state, or when reusing existing bindings, top-level `var` declarations, or fresh names cannot recover from conflicting declarations.

### Parameters

No parameters required.

### Example

```bash
python3 scripts/call-tool.py js_reset '{}'
```

---

