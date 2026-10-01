# HookIO.psm1
# Reading hook input from stdin and writing hook output to stdout.
# Claude Code sends one JSON object on stdin and reads one JSON object from
# stdout. Both directions use UTF-8 bytes so the console code page never
# matters. Keep this file ASCII-only: Windows PowerShell 5.1 reads BOM-less
# scripts in the ANSI code page.

Set-StrictMode -Version 2.0

function Read-HookText {
    <#
    .SYNOPSIS
    Reads all of stdin as UTF-8 text and drops a leading byte order mark.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param()
    $stdin = [Console]::OpenStandardInput()
    $buffer = New-Object -TypeName System.IO.MemoryStream
    try {
        $stdin.CopyTo($buffer)
    }
    finally {
        $stdin.Dispose()
    }
    $text = [System.Text.Encoding]::UTF8.GetString($buffer.ToArray())
    if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) {
        $text = $text.Substring(1)
    }
    return $text
}

function Read-HookInput {
    <#
    .SYNOPSIS
    Reads the hook's JSON input from stdin. Returns $null when stdin is empty.
    #>
    [CmdletBinding()]
    param()
    $text = Read-HookText
    if ([string]::IsNullOrWhiteSpace($text)) {
        return $null
    }
    return (ConvertFrom-Json -InputObject $text)
}

function Get-HookValue {
    <#
    .SYNOPSIS
    Returns the value at a dotted path such as 'tool_input.command', or $null
    when any part is missing. Safe under StrictMode, unlike $obj.missing.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)] $InputObject,
        [Parameter(Mandatory = $true, Position = 1)] [string] $Path
    )
    $current = $InputObject
    foreach ($part in $Path.Split('.')) {
        if ($null -eq $current) {
            return $null
        }
        $property = $current.PSObject.Properties[$part]
        if ($null -eq $property) {
            return $null
        }
        $current = $property.Value
    }
    return $current
}

function Write-HookOutput {
    <#
    .SYNOPSIS
    Writes an object to stdout as compact JSON in UTF-8 bytes.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] $Object)
    $json = ConvertTo-Json -InputObject $Object -Compress -Depth 8
    $encoding = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false
    $bytes = $encoding.GetBytes($json)
    $stdout = [Console]::OpenStandardOutput()
    try {
        $stdout.Write($bytes, 0, $bytes.Length)
        $stdout.Flush()
    }
    finally {
        $stdout.Dispose()
    }
}

function Write-PreToolUseDecision {
    <#
    .SYNOPSIS
    Writes a PreToolUse permission decision. Only deny and ask are possible:
    allow would skip the user's own permission prompts, so it is refused.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [ValidateSet('deny', 'ask')] [string] $Decision,
        [Parameter(Mandatory = $true)] [string] $Reason
    )
    $payload = [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName            = 'PreToolUse'
            permissionDecision       = $Decision.ToLowerInvariant()
            permissionDecisionReason = $Reason
        }
    }
    Write-HookOutput -Object $payload
}

function Write-AdditionalContext {
    <#
    .SYNOPSIS
    Writes text that Claude Code adds to the context of a session or subagent.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [ValidateSet('SessionStart', 'SubagentStart')] [string] $EventName,
        [Parameter(Mandatory = $true)] [string] $Text
    )
    $payload = [ordered]@{
        hookSpecificOutput = [ordered]@{
            hookEventName     = $EventName
            additionalContext = $Text
        }
    }
    Write-HookOutput -Object $payload
}

function Write-GuardError {
    <#
    .SYNOPSIS
    Turns a guard failure into an ask decision. A bug must never silently
    allow or silently block, so it becomes a question for the user.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $GuardName,
        [Parameter(Mandatory = $true)] $ErrorRecord
    )
    $message = [string]$ErrorRecord.Exception.Message
    $reason = 'senior-engineer guard error (' + $GuardName + '): ' + $message + ' Review this action yourself.'
    Write-PreToolUseDecision -Decision 'ask' -Reason $reason
}

Export-ModuleMember -Function Read-HookText, Read-HookInput, Get-HookValue, Write-HookOutput, Write-PreToolUseDecision, Write-AdditionalContext, Write-GuardError
