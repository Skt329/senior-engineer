# file-guard.ps1
# PreToolUse hook for Read, Edit, Write and MultiEdit. Blocks reading secret
# files, and asks before edits to environment files or CI configuration.
# hooks.json only starts this script for matching paths; the checks below
# make the final call. Keep this file ASCII-only.

[CmdletBinding()]
param()

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path (Join-Path $PSScriptRoot 'lib') 'HookIO.psm1') -Force -DisableNameChecking

function Test-EnvFile {
    param([string] $BaseName)
    if ($BaseName -eq '.env') { return $true }
    if (-not $BaseName.StartsWith('.env.')) { return $false }
    foreach ($safe in @('.example', '.sample', '.template', '.dist')) {
        if ($BaseName.EndsWith($safe)) { return $false }
    }
    return $true
}

function Test-SecretFile {
    param([string] $BaseName)
    if (Test-EnvFile -BaseName $BaseName) { return $true }
    foreach ($extension in @('.pem', '.key', '.p12', '.pfx', '.jks', '.keystore')) {
        if ($BaseName.EndsWith($extension)) { return $true }
    }
    if (($BaseName.StartsWith('id_rsa') -or $BaseName.StartsWith('id_ed25519')) -and -not $BaseName.EndsWith('.pub')) { return $true }
    if ($BaseName.Contains('service-account') -and $BaseName.EndsWith('.json')) { return $true }
    if ($BaseName -eq 'credentials.json') { return $true }
    return $false
}

function Test-CiConfig {
    param([string] $NormalizedPath, [string] $BaseName)
    if ($NormalizedPath.Contains('/.github/workflows/') -or $NormalizedPath.StartsWith('.github/workflows/')) { return $true }
    return (@('cloudbuild.yaml', 'cloudbuild.yml') -contains $BaseName)
}

try {
    $hookInput = Read-HookInput
    $toolName = [string](Get-HookValue $hookInput 'tool_name')
    $path = [string](Get-HookValue $hookInput 'tool_input.file_path')
    if ([string]::IsNullOrWhiteSpace($path)) {
        exit 0
    }

    $normalized = $path.Replace([char]92, '/').ToLowerInvariant()
    $baseName = $normalized.Substring($normalized.LastIndexOf('/') + 1)

    if ($toolName -eq 'Read') {
        if (Test-SecretFile -BaseName $baseName) {
            Write-PreToolUseDecision -Decision 'deny' -Reason ('senior-engineer: reading secret files is blocked (' + $path + '). Ask the user for the variable names, or read a .env.example file instead.')
        }
        exit 0
    }

    if (@('Edit', 'Write', 'MultiEdit') -contains $toolName) {
        if (Test-EnvFile -BaseName $baseName) {
            Write-PreToolUseDecision -Decision 'ask' -Reason ('senior-engineer: this edits an environment file (' + $path + '). Approve only if you asked for it.')
        }
        elseif (Test-CiConfig -NormalizedPath $normalized -BaseName $baseName) {
            Write-PreToolUseDecision -Decision 'ask' -Reason ('senior-engineer: this changes CI or build configuration (' + $path + '). Approve only if you asked for it.')
        }
    }
    exit 0
}
catch {
    Write-GuardError -GuardName 'file guard' -ErrorRecord $_
    exit 0
}
