# run-tests.ps1
# Checks the plugin's structure and the behavior of every hook script.
#   Windows:     powershell -ExecutionPolicy Bypass -File tests\run-tests.ps1
#   PowerShell 7: pwsh -File tests/run-tests.ps1
# Add -Full to run every shell case as its own PowerShell process (slower,
# closer to how Claude Code runs the hook). Exit code 0 means all passed.
# Keep this file ASCII-only.

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingWriteHost', '', Justification = 'A console test runner reports to the console.')]
[CmdletBinding()]
param(
    [switch] $Full
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$started = Get-Date
$script:Passed = 0
$script:Failed = 0

Import-Module (Join-Path (Join-Path (Join-Path $root 'hooks') 'scripts') 'lib/HookIO.psm1') -Force -DisableNameChecking
Import-Module (Join-Path (Join-Path (Join-Path $root 'hooks') 'scripts') 'lib/ShellPolicy.psm1') -Force -DisableNameChecking

function Write-Check {
    param([bool] $Ok, [string] $Name, [string] $Detail = '')
    if ($Ok) {
        $script:Passed++
        return
    }
    $script:Failed++
    $line = 'FAIL  ' + $Name
    if ($Detail.Length -gt 0) { $line = $line + ' -- ' + $Detail }
    Write-Host $line
}

function Get-RepoPath {
    param([string] $Relative)
    return (Join-Path $root ($Relative.Replace('/', [System.IO.Path]::DirectorySeparatorChar)))
}

function Read-JsonFile {
    param([string] $Path)
    return (ConvertFrom-Json -InputObject ([System.IO.File]::ReadAllText($Path)))
}

function Read-Frontmatter {
    param([string] $Path)
    $result = @{ Ok = $false; Keys = @{}; BodyLines = 0 }
    $lines = [System.IO.File]::ReadAllLines($Path)
    if ($lines.Count -lt 3 -or $lines[0] -ne '---') { return $result }
    $end = -1
    for ($k = 1; $k -lt $lines.Count; $k++) {
        if ($lines[$k] -eq '---') { $end = $k; break }
    }
    if ($end -lt 0) { return $result }
    for ($k = 1; $k -lt $end; $k++) {
        if ($lines[$k] -match '^([A-Za-z][A-Za-z0-9_-]*):\s*(.*)$') {
            $result.Keys[$Matches[1]] = $Matches[2]
        }
    }
    $result.Ok = $true
    $result.BodyLines = $lines.Count - $end - 1
    return $result
}

function Test-YamlPlainSafe {
    # A one-line YAML plain scalar must not contain ': ' or ' #', end with ':',
    # or start with an indicator character. If it does, strict YAML parsers
    # fail and Claude Code loads the skill with empty metadata.
    param([string] $Value)
    if ($Value.Contains(': ') -or $Value.Contains(' #') -or $Value.EndsWith(':')) { return $false }
    if ($Value -match '^[\[\]{}>|*&!%@`"'']') { return $false }
    return $true
}

function ConvertTo-ArgumentString {
    param([string[]] $Arguments)
    $parts = New-Object -TypeName 'System.Collections.Generic.List[string]'
    foreach ($argument in $Arguments) {
        if ($argument -match '[\s"]') { $parts.Add('"' + ($argument -replace '"', '\"') + '"') }
        else { $parts.Add($argument) }
    }
    return ($parts.ToArray() -join ' ')
}

$script:PowerShellExe = (Get-Process -Id $PID).Path
$script:OnWindows = ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT)

function Invoke-HookScript {
    # Runs a hook script the way Claude Code does: a new PowerShell process,
    # JSON on stdin, JSON (or nothing) on stdout.
    param([string] $ScriptPath, [string[]] $ScriptArgs = @(), [string] $InputText = '', $Environment = $null)
    $arguments = New-Object -TypeName 'System.Collections.Generic.List[string]'
    foreach ($a in @('-NoLogo', '-NoProfile', '-NonInteractive')) { $arguments.Add($a) }
    if ($script:OnWindows) { $arguments.Add('-ExecutionPolicy'); $arguments.Add('Bypass') }
    $arguments.Add('-File'); $arguments.Add($ScriptPath)
    foreach ($a in $ScriptArgs) { $arguments.Add($a) }

    $info = New-Object -TypeName System.Diagnostics.ProcessStartInfo
    $info.FileName = $script:PowerShellExe
    $info.Arguments = ConvertTo-ArgumentString -Arguments $arguments.ToArray()
    $info.UseShellExecute = $false
    $info.RedirectStandardInput = $true
    $info.RedirectStandardOutput = $true
    $info.RedirectStandardError = $true
    $info.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $info.StandardErrorEncoding = [System.Text.Encoding]::UTF8
    foreach ($name in @('SENIOR_ENGINEER_ALLOW_BUILTIN_AGENTS', 'SENIOR_ENGINEER_ALLOW_OPUS_SUBAGENTS')) {
        if ($info.EnvironmentVariables.ContainsKey($name)) { $info.EnvironmentVariables.Remove($name) }
    }
    if ($null -ne $Environment) {
        foreach ($property in $Environment.PSObject.Properties) {
            $info.EnvironmentVariables[$property.Name] = [string]$property.Value
        }
    }

    $process = [System.Diagnostics.Process]::Start($info)
    $encoding = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false
    $bytes = $encoding.GetBytes($InputText)
    $process.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length)
    $process.StandardInput.Close()
    $errorTask = $process.StandardError.ReadToEndAsync()
    $stdout = $process.StandardOutput.ReadToEnd()
    if (-not $process.WaitForExit(60000)) {
        $process.Kill()
        return [pscustomobject]@{ ExitCode = -1; StdOut = ''; StdErr = 'timed out' }
    }
    return [pscustomobject]@{ ExitCode = $process.ExitCode; StdOut = $stdout; StdErr = $errorTask.Result }
}

function Get-DecisionFromOutput {
    param([string] $StdOut)
    $text = $StdOut.Trim()
    if ($text.Length -eq 0) { return [pscustomobject]@{ Decision = 'none'; Reason = ''; Parsed = $true } }
    try {
        $parsed = ConvertFrom-Json -InputObject $text
    }
    catch {
        return [pscustomobject]@{ Decision = 'invalid-json'; Reason = $text; Parsed = $false }
    }
    $decision = [string](Get-HookValue $parsed 'hookSpecificOutput.permissionDecision')
    $reason = [string](Get-HookValue $parsed 'hookSpecificOutput.permissionDecisionReason')
    return [pscustomobject]@{ Decision = $decision; Reason = $reason; Parsed = $true }
}

function Test-CaseResult {
    param([string] $Name, $Case, [string] $Got, [string] $Reason)
    $expect = [string]$Case.expect
    $detail = 'expected ' + $expect + ', got ' + $Got
    if ($Reason.Length -gt 0) { $detail = $detail + ' (' + $Reason + ')' }
    $ok = ($Got -eq $expect)
    $needle = [string](Get-HookValue $Case 'reasonContains')
    if ($ok -and $needle.Length -gt 0 -and -not $Reason.Contains($needle)) {
        $ok = $false
        $detail = 'reason does not contain "' + $needle + '": ' + $Reason
    }
    Write-Check -Ok $ok -Name $Name -Detail $detail
}

# 1. JSON files parse ---------------------------------------------------
$jsonFiles = @('.claude-plugin/plugin.json', '.claude-plugin/marketplace.json', 'hooks/hooks.json')
foreach ($caseFile in Get-ChildItem -LiteralPath (Get-RepoPath 'tests/cases') -Filter '*.json') {
    $jsonFiles += ('tests/cases/' + $caseFile.Name)
}
foreach ($relative in $jsonFiles) {
    $ok = $true
    $detail = ''
    try { $null = Read-JsonFile -Path (Get-RepoPath $relative) } catch { $ok = $false; $detail = $_.Exception.Message }
    Write-Check -Ok $ok -Name ('json parses: ' + $relative) -Detail $detail
}

# 2. Manifests ---------------------------------------------------------
$plugin = Read-JsonFile -Path (Get-RepoPath '.claude-plugin/plugin.json')
$market = Read-JsonFile -Path (Get-RepoPath '.claude-plugin/marketplace.json')
Write-Check -Ok ($plugin.name -eq 'senior-engineer') -Name 'plugin name is senior-engineer'
Write-Check -Ok ([string]$plugin.version -match '^\d+\.\d+\.\d+$') -Name 'plugin version is semver' -Detail ([string]$plugin.version)
$entry = @($market.plugins)[0]
Write-Check -Ok ($entry.name -eq $plugin.name) -Name 'marketplace entry name matches plugin.json'
Write-Check -Ok ($entry.source -eq './') -Name 'marketplace entry source is ./'
Write-Check -Ok ($entry.version -eq $plugin.version) -Name 'marketplace and plugin versions match'

# 3. hooks.json --------------------------------------------------------
$hooksJson = Read-JsonFile -Path (Get-RepoPath 'hooks/hooks.json')
foreach ($required in @('SessionStart', 'SubagentStart', 'PreToolUse')) {
    Write-Check -Ok ($null -ne $hooksJson.hooks.PSObject.Properties[$required]) -Name ('hooks.json has ' + $required)
}
$entryCount = 0
foreach ($hookEvent in $hooksJson.hooks.PSObject.Properties) {
    foreach ($group in @($hookEvent.Value)) {
        foreach ($hook in @($group.hooks)) {
            $entryCount++
            $label = 'hooks.json ' + $hookEvent.Name + ' entry ' + $entryCount
            $hookArgs = @($hook.args)
            $fileAt = [Array]::IndexOf($hookArgs, '-File')
            $okShape = ($hook.type -eq 'command' -and $hook.command -eq 'powershell.exe' -and $fileAt -ge 0 -and ($fileAt + 1) -lt $hookArgs.Count -and $hook.timeout -gt 0)
            Write-Check -Ok $okShape -Name ($label + ' uses exec form with -File')
            if ($fileAt -ge 0 -and ($fileAt + 1) -lt $hookArgs.Count) {
                $target = [string]$hookArgs[$fileAt + 1]
                $prefix = '${CLAUDE_PLUGIN_ROOT}/'
                $okPrefix = $target.StartsWith($prefix)
                Write-Check -Ok $okPrefix -Name ($label + ' script path starts with ${CLAUDE_PLUGIN_ROOT}/') -Detail $target
                if ($okPrefix) {
                    $resolved = Get-RepoPath ($target.Substring($prefix.Length))
                    Write-Check -Ok (Test-Path -LiteralPath $resolved) -Name ($label + ' script exists') -Detail $target
                }
            }
            $condition = Get-HookValue $hook 'if'
            if ($null -ne $condition) {
                Write-Check -Ok ([string]$condition -match '^[A-Za-z]+\(.+\)$') -Name ($label + ' if pattern is well formed') -Detail ([string]$condition)
            }
        }
    }
}

# The shell guard only starts when an if filter matches, so every program the
# policy acts on, and every wrapper or nested shell the parser looks inside
# ($script:Wrappers and $script:DashCShells in ShellParser.psm1), needs one.
# The hook cases below call the policy directly and cannot catch a missing filter.
$guardedPrograms = @(
    'git', 'gh', 'rm', 'rmdir', 'gcloud', 'firebase', 'terraform', 'kubectl', 'docker',
    'npm', 'pnpm', 'yarn', 'pip', 'pip3', 'uv', 'poetry', 'alembic',
    'bash', 'bash.exe', 'sh', 'zsh', 'dash', 'ksh', 'cmd', 'cmd.exe',
    'powershell', 'powershell.exe', 'pwsh', 'pwsh.exe',
    'sudo', 'env', 'command', 'exec', 'time', 'nice', 'nohup'
)
$filterLists = @{
    'Bash'       = $guardedPrograms
    'PowerShell' = $guardedPrograms + @('Remove-Item', 'del', 'rd', 'erase', 'ri')
}
foreach ($matcher in @('Bash', 'PowerShell')) {
    $filters = @()
    foreach ($group in @($hooksJson.hooks.PreToolUse)) {
        if ([string]$group.matcher -ne $matcher) { continue }
        foreach ($hook in @($group.hooks)) {
            if (@($hook.args) -contains '${CLAUDE_PLUGIN_ROOT}/hooks/scripts/shell-guard.ps1') {
                $filters += [string](Get-HookValue $hook 'if')
            }
        }
    }
    foreach ($program in $filterLists[$matcher]) {
        $pattern = $matcher + '(' + $program + ' *)'
        Write-Check -Ok ($filters -ccontains $pattern) -Name ('hooks.json starts the shell guard for ' + $pattern)
    }
}

# 4. ASCII-only files ---------------------------------------------------
$asciiFiles = @()
$asciiFiles += @(Get-ChildItem -LiteralPath (Get-RepoPath 'hooks/scripts') -Recurse -File | Where-Object { $_.Extension -eq '.ps1' -or $_.Extension -eq '.psm1' })
$asciiFiles += @(Get-ChildItem -LiteralPath (Get-RepoPath 'context') -File)
$asciiFiles += @(Get-Item -LiteralPath (Get-RepoPath 'tests/run-tests.ps1'))
$asciiFiles += @(Get-Item -LiteralPath (Get-RepoPath 'hooks/hooks.json'))
foreach ($file in $asciiFiles) {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $bad = -1
    for ($k = 0; $k -lt $bytes.Length; $k++) {
        if ($bytes[$k] -gt 127) { $bad = $k; break }
    }
    Write-Check -Ok ($bad -lt 0) -Name ('ascii only: ' + $file.Name) -Detail ('first non-ASCII byte at offset ' + $bad)
}

# 5. Context sizes -----------------------------------------------------
$coreText = [System.IO.File]::ReadAllText((Get-RepoPath 'context/core-rules.md'))
$subText = [System.IO.File]::ReadAllText((Get-RepoPath 'context/subagent-rules.md'))
Write-Check -Ok ($coreText.Length -le 7500) -Name 'core-rules.md is at most 7,500 characters' -Detail ([string]$coreText.Length)
Write-Check -Ok ($subText.Length -le 1500) -Name 'subagent-rules.md is at most 1,500 characters' -Detail ([string]$subText.Length)

# 6. Skills ------------------------------------------------------------
$vendored = @('humanize-writing')
$skillDirs = @(Get-ChildItem -LiteralPath (Get-RepoPath 'skills') -Directory)
Write-Check -Ok ($skillDirs.Count -eq 13) -Name 'there are 13 skills' -Detail ([string]$skillDirs.Count)
foreach ($dir in $skillDirs) {
    $skillFile = Join-Path $dir.FullName 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillFile)) {
        Write-Check -Ok $false -Name ('skill has SKILL.md: ' + $dir.Name)
        continue
    }
    $front = Read-Frontmatter -Path $skillFile
    Write-Check -Ok $front.Ok -Name ('skill frontmatter parses: ' + $dir.Name)
    if (-not $front.Ok) { continue }
    $name = [string]$front.Keys['name']
    $description = [string]$front.Keys['description']
    Write-Check -Ok ($name -eq $dir.Name) -Name ('skill name matches folder: ' + $dir.Name) -Detail $name
    Write-Check -Ok ($name -cmatch '^[a-z0-9]+(-[a-z0-9]+)*$' -and $name.Length -le 64) -Name ('skill name is kebab-case: ' + $dir.Name)
    Write-Check -Ok ($description.Length -gt 0 -and $description.Length -le 1024) -Name ('skill description is 1-1024 characters: ' + $dir.Name) -Detail ([string]$description.Length)
    if ($vendored -notcontains $dir.Name) {
        Write-Check -Ok (Test-YamlPlainSafe -Value $description) -Name ('skill description is YAML-safe: ' + $dir.Name)
        Write-Check -Ok ($description.StartsWith('This skill should be used')) -Name ('skill description is third person: ' + $dir.Name)
    }
    Write-Check -Ok ($front.BodyLines -le 500) -Name ('skill body is at most 500 lines: ' + $dir.Name) -Detail ([string]$front.BodyLines)
    $body = [System.IO.File]::ReadAllText($skillFile)
    foreach ($match in [regex]::Matches($body, '(references|scripts)/[A-Za-z0-9_.-]+\.(md|py)')) {
        $target = Join-Path $dir.FullName ($match.Value.Replace('/', [System.IO.Path]::DirectorySeparatorChar))
        Write-Check -Ok (Test-Path -LiteralPath $target) -Name ('skill reference exists: ' + $dir.Name + '/' + $match.Value)
    }
    $refDir = Join-Path $dir.FullName 'references'
    if (Test-Path -LiteralPath $refDir) {
        foreach ($ref in Get-ChildItem -LiteralPath $refDir -File) {
            Write-Check -Ok ($body.Contains('references/' + $ref.Name)) -Name ('reference is linked from SKILL.md: ' + $dir.Name + '/references/' + $ref.Name)
        }
    }
}

# 7. Agents ------------------------------------------------------------
$agentFiles = @(Get-ChildItem -LiteralPath (Get-RepoPath 'agents') -Filter '*.md' -File)
Write-Check -Ok ($agentFiles.Count -eq 3) -Name 'there are 3 agents' -Detail ([string]$agentFiles.Count)
foreach ($file in $agentFiles) {
    $front = Read-Frontmatter -Path $file.FullName
    $base = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    Write-Check -Ok $front.Ok -Name ('agent frontmatter parses: ' + $base)
    if (-not $front.Ok) { continue }
    $name = [string]$front.Keys['name']
    Write-Check -Ok ($name -eq $base) -Name ('agent name matches file: ' + $base) -Detail $name
    Write-Check -Ok ($name -cmatch '^[a-z0-9][a-z0-9-]{1,48}[a-z0-9]$') -Name ('agent name is 3-50 kebab-case characters: ' + $base)
    Write-Check -Ok (Test-YamlPlainSafe -Value ([string]$front.Keys['description'])) -Name ('agent description is YAML-safe: ' + $base)
    Write-Check -Ok (@('haiku', 'sonnet', 'opus', 'inherit') -contains [string]$front.Keys['model']) -Name ('agent model is valid: ' + $base)
    Write-Check -Ok ([string]$front.Keys['model'] -ne 'opus') -Name ('agent does not use opus: ' + $base)
    Write-Check -Ok (@('blue', 'cyan', 'green', 'yellow', 'magenta', 'red') -contains [string]$front.Keys['color']) -Name ('agent color is valid: ' + $base)
    $tools = @(([string]$front.Keys['tools']).Split(',') | ForEach-Object { $_.Trim() })
    Write-Check -Ok ($tools.Count -gt 0 -and $tools -notcontains 'Agent' -and $tools -notcontains 'Task') -Name ('agent cannot spawn agents: ' + $base)
    Write-Check -Ok ([string]$front.Keys['maxTurns'] -match '^\d+$') -Name ('agent has a numeric maxTurns: ' + $base)
}

# 8. Hook behavior -----------------------------------------------------
$shellCases = Read-JsonFile -Path (Get-RepoPath 'tests/cases/shell-guard.cases.json')
$shellScript = Get-RepoPath $shellCases.script
$index = 0
foreach ($case in @($shellCases.cases)) {
    $tool = [string](Get-HookValue $case 'tool')
    if ($tool.Length -eq 0) { $tool = 'Bash' }
    $name = 'shell-guard [' + $tool + '] ' + $case.cmd
    $decision = Get-ShellGuardDecision -CommandLine ([string]$case.cmd)
    Test-CaseResult -Name $name -Case $case -Got $decision.Decision -Reason $decision.Reason
    if ($Full -or ($index % 20) -eq 0) {
        $inputObject = [ordered]@{ hook_event_name = 'PreToolUse'; tool_name = $tool; tool_input = [ordered]@{ command = [string]$case.cmd } }
        $run = Invoke-HookScript -ScriptPath $shellScript -InputText (ConvertTo-Json -InputObject $inputObject -Compress -Depth 6)
        $parsed = Get-DecisionFromOutput -StdOut $run.StdOut
        Test-CaseResult -Name ($name + ' (process)') -Case $case -Got $parsed.Decision -Reason $parsed.Reason
    }
    $index++
}

$fileCases = Read-JsonFile -Path (Get-RepoPath 'tests/cases/file-guard.cases.json')
foreach ($case in @($fileCases.cases)) {
    $inputObject = [ordered]@{ hook_event_name = 'PreToolUse'; tool_name = [string]$case.tool; tool_input = [ordered]@{ file_path = [string]$case.path } }
    $run = Invoke-HookScript -ScriptPath (Get-RepoPath $fileCases.script) -InputText (ConvertTo-Json -InputObject $inputObject -Compress -Depth 6)
    $parsed = Get-DecisionFromOutput -StdOut $run.StdOut
    Test-CaseResult -Name ('file-guard [' + $case.tool + '] ' + $case.path) -Case $case -Got $parsed.Decision -Reason $parsed.Reason
}

$agentCases = Read-JsonFile -Path (Get-RepoPath 'tests/cases/agent-gate.cases.json')
foreach ($case in @($agentCases.cases)) {
    $raw = Get-HookValue $case 'raw'
    if ($null -ne $raw) {
        $inputText = [string]$raw
        $label = 'agent-gate raw input'
    }
    else {
        $inputObject = [ordered]@{ hook_event_name = 'PreToolUse'; tool_name = 'Agent'; tool_input = $case.toolInput }
        $inputText = ConvertTo-Json -InputObject $inputObject -Compress -Depth 6
        $label = 'agent-gate ' + (ConvertTo-Json -InputObject $case.toolInput -Compress)
    }
    $run = Invoke-HookScript -ScriptPath (Get-RepoPath $agentCases.script) -InputText $inputText -Environment (Get-HookValue $case 'env')
    $parsed = Get-DecisionFromOutput -StdOut $run.StdOut
    if ($label.Length -gt 140) { $label = $label.Substring(0, 137) + '...' }
    Test-CaseResult -Name $label -Case $case -Got $parsed.Decision -Reason $parsed.Reason
}

# 9. Session and subagent context injection -----------------------------
$modes = @(
    @{ Mode = 'Session'; EventName = 'SessionStart'; Heading = '# Senior engineer operating rules' },
    @{ Mode = 'Subagent'; EventName = 'SubagentStart'; Heading = '# Subagent rules' }
)
foreach ($mode in $modes) {
    $run = Invoke-HookScript -ScriptPath (Get-RepoPath 'hooks/scripts/session-start.ps1') -ScriptArgs @('-Mode', $mode.Mode) -InputText '{"hook_event_name":"SessionStart","source":"startup"}'
    $text = $run.StdOut.Trim()
    $ok = $false
    $detail = $run.StdErr
    try {
        $parsed = ConvertFrom-Json -InputObject $text
        $eventName = [string](Get-HookValue $parsed 'hookSpecificOutput.hookEventName')
        $context = [string](Get-HookValue $parsed 'hookSpecificOutput.additionalContext')
        $ok = ($eventName -eq $mode.EventName -and $context.StartsWith($mode.Heading))
        $detail = 'event ' + $eventName + ', ' + $text.Length + ' characters'
    }
    catch { $detail = 'output is not JSON: ' + $text }
    Write-Check -Ok $ok -Name ('session-start -Mode ' + $mode.Mode + ' injects the rules') -Detail $detail
    Write-Check -Ok ($text.Length -lt 9000) -Name ('session-start -Mode ' + $mode.Mode + ' output stays under 9,000 characters') -Detail ([string]$text.Length)
}

# Summary --------------------------------------------------------------
$seconds = [Math]::Round(((Get-Date) - $started).TotalSeconds, 1)
Write-Host ''
Write-Host ('{0} passed, {1} failed in {2} s' -f $script:Passed, $script:Failed, $seconds)
if ($script:Failed -gt 0) { exit 1 }
exit 0
