# session-start.ps1
# SessionStart and SubagentStart hook. Injects the always-on rules from
# context/core-rules.md (Mode Session) or context/subagent-rules.md
# (Mode Subagent) as additional context. A missing file never blocks a
# session: the script warns on stderr and exits quietly.
# Keep this file ASCII-only.

[CmdletBinding()]
param(
    [ValidateSet('Session', 'Subagent')]
    [string] $Mode = 'Session'
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path (Join-Path $PSScriptRoot 'lib') 'HookIO.psm1') -Force -DisableNameChecking

try {
    # The input is not needed; read it so Claude Code can finish writing it.
    try { $null = Read-HookText } catch { Write-Verbose ('stdin was not readable: ' + $_.Exception.Message) }

    $pluginRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $fileName = 'core-rules.md'
    $eventName = 'SessionStart'
    if ($Mode -eq 'Subagent') {
        $fileName = 'subagent-rules.md'
        $eventName = 'SubagentStart'
    }
    $path = Join-Path (Join-Path $pluginRoot 'context') $fileName
    if (-not (Test-Path -LiteralPath $path)) {
        [Console]::Error.WriteLine('senior-engineer: rules file not found: ' + $path)
        exit 0
    }
    $text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    Write-AdditionalContext -EventName $eventName -Text $text
    exit 0
}
catch {
    [Console]::Error.WriteLine('senior-engineer: session-start hook failed: ' + $_.Exception.Message)
    exit 0
}
