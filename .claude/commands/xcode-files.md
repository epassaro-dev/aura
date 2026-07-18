Add, and optionally remove, Swift source files in the Aura Xcode project via the Xcode MCP server.

## Usage

```
/xcode-files [--target <TargetName>] <file> [<file> ...]
```

- File paths are relative to `ios/` (e.g. `Aura/Models/Log/SleepEntry.swift`, `AuraTests/FooTests.swift`).
- `--target` is accepted for compatibility but ignored — `XcodeWrite` infers the target from the group (`Aura/…` → app target, `AuraTests/…` → test target; verified).
- Multiple files can be listed in a single invocation.
- Requires Xcode to be running with `ios/Aura.xcodeproj` open. If it isn't, fall back to a Ruby script using the `xcodeproj` gem.

## Arguments

$ARGUMENTS

## Procedure

1. Parse the arguments: discard any `--target <name>` flag and collect the remaining tokens as file paths relative to `ios/`.

2. Call `XcodeListWindows` (no parameters) and use the `tabIdentifier` from the first result.

3. For each file, the project path is `Aura/<path>` (e.g. `Aura/Aura/Models/Log/SleepEntry.swift`, `Aura/AuraTests/FooTests.swift`).

4. If the file's parent directory is already a group in the project (check with `XcodeLS` on the parent when unsure):
   - Read the file content from disk (`ios/<path>`) and call `XcodeWrite` with `tabIdentifier`, `filePath`, and `content`. This registers the file in the project and build phase; it works whether or not the file already exists on disk.

5. If the parent directory is NOT a group in the project yet:
   - **Pitfall:** if a folder with that name already exists on disk (created outside Xcode), `XcodeMakeDir`/`XcodeWrite` will NOT adopt it — they create a duplicate `"<Name> 2"` folder on disk and in the project. Never call them while an unregistered same-name folder exists.
   - Therefore: read the contents of all affected files into memory first, move the unregistered folder out of the way (e.g. to the session scratchpad), then `XcodeMakeDir` the group, then `XcodeWrite` each file.
   - If the folder does not exist on disk at all, just `XcodeMakeDir` then `XcodeWrite`.

6. Verify every response: `success` must be true AND the returned `absolutePath`/`createdPath` must exactly match the requested path — a `" 2"` suffix means the pitfall in step 5 was hit. If so, remove the stray folder/group (`XcodeRM` + disk cleanup, check `git status` for staged strays) and redo via step 5.

7. Report the added files to the user.

## Removing files

Use `XcodeRM` with the project path (`recursive: true` for groups; `deleteFiles: true` also moves the on-disk files to Trash). It cleans up build-phase entries automatically.
