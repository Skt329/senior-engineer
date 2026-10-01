# shell-guard.ps1
# PreToolUse hook for the Bash and PowerShell tools. Stays silent for normal
# commands, asks the user before risky ones, and blocks history-changing git
# commands with a reason Claude can read. See lib/ShellPolicy.psm1 for rules.
# Keep this file ASCII-only.

[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$lib = Join-Path $PSScriptRoot 'lib'
Import-Module (Join-Path $lib 'HookIO.psm1') -Force -DisableNameChecking

try {
    Import-Module (Join-Path $lib 'ShellPolicy.psm1') -Force -DisableNameChecking

    $hookInput = Read-HookInput
    $command = [string](Get-HookValue $hookInput 'tool_input.command')
    if ([string]::IsNullOrWhiteSpace($command)) {
        exit 0
    }

    $final = Get-ShellGuardDecision -CommandLine $command
    if ($final.Decision -ne 'none') {
        Write-PreToolUseDecision -Decision $final.Decision -Reason $final.Reason
    }
    exit 0
}
catch {
    Write-GuardError -GuardName 'shell guard' -ErrorRecord $_
    exit 0
}
