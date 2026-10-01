# 0001. Write the hooks as Windows PowerShell scripts in exec form

Date: 2026-10-01
Status: accepted

## Context
The plugin runs on Windows. Git Bash is optional there, and without it Claude Code uses its PowerShell tool, so a hook written for Bash may have nothing to run on. Node.js is present wherever Claude Code is installed through npm, but not with the native installer. Python is not guaranteed at all. Hook commands in shell form also break when the plugin path contains spaces.

## Options considered
- Windows PowerShell 5.1 scripts started in exec form (`powershell.exe` with an `args` array).
- Node.js scripts.
- Bash scripts.
- Python scripts.

## Decision
Write every hook as a PowerShell script that runs on Windows PowerShell 5.1 and PowerShell 7, started in exec form with `-NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File`. Keep the scripts ASCII-only, read stdin and write stdout as UTF-8 bytes, and filter calls with `if` patterns in hooks.json so only matching commands start a process.

## Consequences
- Good: nothing to install on Windows, no quoting problems with spaces in paths, and one implementation for both the Bash and PowerShell tools.
- Bad: each guarded call costs a PowerShell start, roughly half a second. The plugin needs Claude Code 2.1.176 or later for exec form and path patterns in `if` filters. On macOS or Linux, users must install PowerShell 7 and change `powershell.exe` to `pwsh`.
- Follow-ups: keep the ASCII-only rule enforced by the tests, because PowerShell 5.1 reads BOM-less files in the ANSI code page.
