# agent-gate.ps1
# PreToolUse hook for the Agent tool (called Task in older versions).
# Every subagent spawn asks the user first. Built-in Explore and fork agents,
# and Opus subagents, are blocked unless the user turns them back on with
# SENIOR_ENGINEER_ALLOW_BUILTIN_AGENTS=1 or SENIOR_ENGINEER_ALLOW_OPUS_SUBAGENTS=1.
# Keep this file ASCII-only.

[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path (Join-Path $PSScriptRoot 'lib') 'HookIO.psm1') -Force -DisableNameChecking

try {
    $hookInput = Read-HookInput
    $type = [string](Get-HookValue $hookInput 'tool_input.subagent_type')
    $model = [string](Get-HookValue $hookInput 'tool_input.model')
    $task = [string](Get-HookValue $hookInput 'tool_input.description')

    if ([string]::IsNullOrWhiteSpace($type)) { $type = 'general-purpose' }
    $type = $type.Trim()
    $typeKey = $type.ToLowerInvariant()
    $modelKey = $model.Trim().ToLowerInvariant()

    $allowBuiltin = ([Environment]::GetEnvironmentVariable('SENIOR_ENGINEER_ALLOW_BUILTIN_AGENTS') -eq '1')
    $allowOpus = ([Environment]::GetEnvironmentVariable('SENIOR_ENGINEER_ALLOW_OPUS_SUBAGENTS') -eq '1')

    if (-not $allowBuiltin -and $typeKey -eq 'explore') {
        Write-PreToolUseDecision -Decision 'deny' -Reason "senior-engineer: the built-in Explore agent runs on this session's model (Opus in planning sessions). Use senior-engineer:scout (Haiku, read-only) with a brief from the delegation skill."
        exit 0
    }
    if (-not $allowBuiltin -and $typeKey -eq 'fork') {
        Write-PreToolUseDecision -Decision 'deny' -Reason 'senior-engineer: a fork subagent copies the whole conversation. Write a scoped brief for senior-engineer:scout, implementer, or reviewer instead (delegation skill).'
        exit 0
    }
    if (-not $allowOpus -and $modelKey.Contains('opus')) {
        Write-PreToolUseDecision -Decision 'deny' -Reason 'senior-engineer: Opus subagents are off. Use haiku for searches and sonnet for implementing or reviewing, or leave the model unset to use the agent default.'
        exit 0
    }

    $modelShown = $model.Trim()
    if ($modelShown.Length -eq 0) { $modelShown = 'agent default' }
    $taskShown = $task.Trim()
    if ($taskShown.Length -eq 0) { $taskShown = '(no description)' }
    if ($taskShown.Length -gt 120) { $taskShown = $taskShown.Substring(0, 117) + '...' }

    $reason = 'senior-engineer: approve subagent? type=' + $type + ' model=' + $modelShown + ' task=' + $taskShown + '. Rule: at most 3 per batch, then a check-in.'
    if ($typeKey -eq 'general-purpose' -or $typeKey -eq 'plan') {
        $reason = $reason + ' Note: ' + $type + ' inherits the session model.'
    }
    Write-PreToolUseDecision -Decision 'ask' -Reason $reason
    exit 0
}
catch {
    Write-GuardError -GuardName 'agent gate' -ErrorRecord $_
    exit 0
}
