Add one or more Swift source files to the Aura Xcode project via the Xcode MCP server.

## Usage

```
/add-to-xcode [--target <TargetName>] <file> [<file> ...]
```

- `--target` is accepted for compatibility but ignored — XcodeWrite handles project membership automatically.
- File paths must be relative to `ios/Aura/` (e.g. `Models/Log/SleepEntry.swift`).
- Multiple files can be listed in a single invocation.

## Arguments

$ARGUMENTS

## Procedure

1. Parse the arguments: discard any `--target <name>` flag and collect the remaining tokens as file paths relative to `ios/Aura/`.

2. Call `XcodeListWindows` (no parameters) to get the active tab identifier. Use the `tabIdentifier` from the first result.

3. For each file path:
   a. Read the file content from disk at `ios/Aura/<path>`.
   b. Call `XcodeWrite` with:
      - `tabIdentifier`: value from step 2
      - `filePath`: `Aura/Aura/<path>` (e.g. `Aura/Aura/Models/Log/SleepEntry.swift`)
      - `content`: the file content read in step a

4. Report the added files to the user.
