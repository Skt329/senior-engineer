# ShellPolicy.psm1
# Decides, for one parsed command, whether the guard stays silent (none),
# asks the user (ask), or blocks with a reason for Claude (deny).
# The rules mirror section 5.4 of docs/plans/2026-10-01-senior-engineer-plugin.md.
# To change a rule: edit the lists below, add a case to
# tests/cases/shell-guard.cases.json, and run tests/run-tests.ps1.
# Keep this file ASCII-only (Windows PowerShell 5.1 reads it as ANSI).

Set-StrictMode -Version 2.0

Import-Module (Join-Path $PSScriptRoot 'ShellParser.psm1') -DisableNameChecking

$script:Prefix = 'senior-engineer: '

# ---------------------------------------------------------------- git lists
$script:GitDeny = @(
    'add', 'commit', 'push', 'merge', 'rebase', 'reset', 'revert', 'cherry-pick', 'am', 'apply',
    'clean', 'restore', 'rm', 'mv', 'gc', 'prune', 'repack', 'filter-branch', 'filter-repo',
    'update-ref', 'update-index', 'replace', 'notes', 'commit-tree', 'fast-import', 'read-tree'
)
$script:GitAllow = @(
    'status', 'diff', 'log', 'show', 'fetch', 'ls-files', 'ls-remote', 'ls-tree', 'blame', 'annotate',
    'describe', 'shortlog', 'grep', 'merge-base', 'cat-file', 'for-each-ref', 'rev-parse', 'rev-list',
    'symbolic-ref', 'show-ref', 'show-branch', 'name-rev', 'range-diff', 'whatchanged', 'count-objects',
    'check-ignore', 'check-attr', 'var', 'help', 'version', 'clone', 'init', 'cherry', 'difftool',
    'format-patch', 'archive'
)
$script:GitValueOptions = @('-C', '-c', '--git-dir', '--work-tree', '--namespace', '--config-env')
$script:GitSwitchDeny = @('-f', '--force', '--discard-changes', '-C', '--force-create', '--orphan', '-m', '--merge')
$script:GitBranchDeny = @('-d', '-D', '--delete', '-m', '-M', '--move', '-c', '-C', '--copy', '-f', '--force', '-u', '--unset-upstream', '--edit-description')
$script:GitTagListOptions = @('--contains', '--no-contains', '--points-at', '--sort', '-n', '--merged', '--no-merged', '--column', '--format')
$script:GitConfigReadOptions = @('--get', '--get-all', '--get-regexp', '--get-urlmatch', '--list', '-l')

# ----------------------------------------------------------------- gh lists
$script:GhDeny = @('pr merge', 'repo delete', 'release delete')
$script:GhAsk = @{
    'pr'       = @('create', 'edit', 'close', 'reopen', 'comment', 'review', 'ready', 'lock', 'unlock', 'update-branch')
    'issue'    = @('create', 'edit', 'close', 'reopen', 'comment', 'delete', 'transfer', 'lock', 'unlock', 'pin', 'unpin')
    'release'  = @('create', 'edit', 'upload')
    'repo'     = @('create', 'edit', 'fork', 'rename', 'sync', 'archive', 'unarchive', 'set-default')
    'workflow' = @('run', 'enable', 'disable')
    'run'      = @('rerun', 'cancel', 'delete')
    'gist'     = @('create', 'edit', 'delete')
    'label'    = @('create', 'edit', 'delete', 'clone')
}

# ------------------------------------------------------- infrastructure lists
$script:GcloudMutating = '^(deploy|delete|create|update|patch|set|add-|remove-|import|enable|disable|reset|restart|start|stop|resize|rollback|promote|migrate|undelete|cancel)'
$script:FirebaseMutating = ':(delete|disable|remove|set|update|push|import|rollback|create|clone|apply|enable|distribute)$'
$script:TerraformAsk = @('apply', 'destroy', 'import', 'taint', 'untaint', 'force-unlock')
$script:KubectlAsk = @('apply', 'create', 'delete', 'edit', 'patch', 'replace', 'scale', 'autoscale', 'drain', 'cordon', 'uncordon', 'taint', 'label', 'annotate', 'set', 'expose', 'run', 'exec', 'cp', 'debug')
$script:KubectlValueOptions = @('-n', '--namespace', '--context', '--kubeconfig', '--cluster', '--user', '-s', '--server')
$script:KubectlConfigAsk = @('use-context', 'set', 'set-context', 'set-cluster', 'set-credentials', 'delete-context', 'delete-cluster', 'unset', 'rename-context')
$script:DockerValueOptions = @('--context', '-H', '--host', '--config', '-c', '--log-level', '-l')

# ---------------------------------------------------------- package lists
$script:NpmInstall = @('install', 'i', 'in', 'ins', 'inst', 'insta', 'instal', 'isnt', 'isnta', 'isntal', 'isntall', 'add')
$script:NpmRemove = @('uninstall', 'un', 'unlink', 'remove', 'rm', 'r')
$script:NpmUpdate = @('update', 'up', 'upgrade', 'udpate')
$script:NpmPublish = @('publish', 'unpublish', 'deprecate', 'dist-tag', 'owner', 'access', 'token', 'adduser', 'login')
$script:PipValueOptions = @('-r', '--requirement', '-c', '--constraint', '-e', '--editable', '-i', '--index-url', '--extra-index-url', '-f', '--find-links', '-t', '--target', '--prefix', '--root')
$script:AlembicValueOptions = @('-c', '--config', '-x', '-n', '--name')

# --------------------------------------------------------------- helpers
function New-Decision {
    <#
    .SYNOPSIS
    Creates a decision object: none, ask, or deny, with a reason.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Creates an in-memory object only.')]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [ValidateSet('none', 'ask', 'deny')] [string] $Decision,
        [string] $Reason = ''
    )
    $text = ''
    if ($Reason.Length -gt 0) { $text = $script:Prefix + $Reason }
    return [pscustomobject]@{ Decision = $Decision; Reason = $text }
}

function Get-ArgSlice {
    [CmdletBinding()]
    param([string[]] $Items, [int] $Start)
    if ($null -eq $Items -or $Start -ge $Items.Count) { return }
    return $Items[$Start..($Items.Count - 1)]
}

function Test-HasArg {
    # Case-sensitive exact match, because git -b and -B mean different things.
    [CmdletBinding()]
    [OutputType([bool])]
    param([string[]] $Items, [string[]] $Values)
    foreach ($item in $Items) {
        if ($Values -ccontains $item) { return $true }
    }
    return $false
}

function Test-HasArgPrefix {
    [CmdletBinding()]
    [OutputType([bool])]
    param([string[]] $Items, [string[]] $Prefixes)
    foreach ($item in $Items) {
        foreach ($prefix in $Prefixes) {
            if ($item.StartsWith($prefix, [System.StringComparison]::Ordinal)) { return $true }
        }
    }
    return $false
}

function Get-NonFlagArgument {
    [CmdletBinding()]
    param([string[]] $Items, [string[]] $ValueOptions = @())
    $found = New-Object -TypeName 'System.Collections.Generic.List[string]'
    $k = 0
    while ($null -ne $Items -and $k -lt $Items.Count) {
        $item = $Items[$k]
        if ($item.StartsWith('-')) {
            if ($ValueOptions -ccontains $item) { $k += 2 } else { $k += 1 }
            continue
        }
        $found.Add($item)
        $k++
    }
    return $found.ToArray()
}

function Format-CommandText {
    [CmdletBinding()]
    param($Command)
    $text = [string]$Command.Text
    if ($text.Length -gt 160) { $text = $text.Substring(0, 157) + '...' }
    return $text
}

# ------------------------------------------------------------------- git
function Get-GitDecision {
    [CmdletBinding()]
    param($Command)
    $items = @($Command.Args)
    $text = Format-CommandText -Command $Command
    $i = 0
    while ($i -lt $items.Count -and $items[$i].StartsWith('-')) {
        if ($script:GitValueOptions -ccontains $items[$i]) { $i += 2 } else { $i += 1 }
    }
    if ($i -ge $items.Count) { return (New-Decision -Decision 'none') }

    $sub = $items[$i].ToLowerInvariant()
    $rest = @(Get-ArgSlice -Items $items -Start ($i + 1))

    if ($script:GitDeny -contains $sub) {
        return (New-Decision -Decision 'deny' -Reason ("Claude does not run 'git " + $sub + "'. Prepare the change and give the user a ready-to-paste command block instead (git-workflow skill). Do not try another way to run it."))
    }
    if ($sub -eq 'pull') {
        $risky = Test-HasArgPrefix -Items $rest -Prefixes @('--rebase', '--no-ff', '--squash')
        if ((Test-HasArg -Items $rest -Values @('--ff-only')) -and -not $risky -and -not (Test-HasArg -Items $rest -Values @('-r'))) {
            return (New-Decision -Decision 'none')
        }
        return (New-Decision -Decision 'deny' -Reason "use 'git pull --ff-only'. If it fails because the branch has diverged, stop and ask the user how to proceed.")
    }
    if ($sub -eq 'switch') {
        if (Test-HasArg -Items $rest -Values $script:GitSwitchDeny) {
            return (New-Decision -Decision 'deny' -Reason "this git switch option can discard work or reset a branch. Use 'git switch <branch>' or 'git switch -c <new-branch>' on a clean working tree.")
        }
        return (New-Decision -Decision 'none')
    }
    if ($sub -eq 'checkout') {
        $creates = ($rest.Count -ge 2 -and $rest[0] -ceq '-b')
        if ($creates -and -not (Test-HasArg -Items $rest -Values @('-f', '--force', '-B'))) {
            return (New-Decision -Decision 'none')
        }
        return (New-Decision -Decision 'deny' -Reason "use 'git switch <branch>' to change branches and 'git switch -c <name>' to create one. Other forms of git checkout can discard uncommitted changes.")
    }
    if ($sub -eq 'branch') {
        if ((Test-HasArg -Items $rest -Values $script:GitBranchDeny) -or (Test-HasArgPrefix -Items $rest -Prefixes @('--set-upstream-to'))) {
            return (New-Decision -Decision 'deny' -Reason "deleting, renaming, copying, or force-moving branches and changing upstreams are the user's call. Give the user the command instead.")
        }
        return (New-Decision -Decision 'none')
    }
    if ($sub -eq 'stash') {
        if ($rest.Count -gt 0 -and @('list', 'show') -contains $rest[0]) { return (New-Decision -Decision 'none') }
        return (New-Decision -Decision 'ask' -Reason ("git stash hides or restores uncommitted work (" + $text + "). The rules say Claude stops and asks instead. Approve only if you asked for this."))
    }
    if ($sub -eq 'tag') {
        if (Test-HasArg -Items $rest -Values @('-d', '--delete')) {
            return (New-Decision -Decision 'deny' -Reason "deleting tags is the user's call. Give the user the command instead.")
        }
        if ($rest.Count -eq 0 -or (Test-HasArg -Items $rest -Values @('-l', '--list')) -or (Test-HasArgPrefix -Items @($rest[0]) -Prefixes $script:GitTagListOptions)) {
            return (New-Decision -Decision 'none')
        }
        return (New-Decision -Decision 'ask' -Reason ("this creates a git tag (" + $text + "). Approve only if you asked for it."))
    }
    if ($sub -eq 'remote') {
        if ($rest.Count -eq 0 -or @('-v', '--verbose', 'show', 'get-url') -ccontains $rest[0]) { return (New-Decision -Decision 'none') }
        return (New-Decision -Decision 'ask' -Reason ("this changes git remotes (" + $text + ")."))
    }
    if ($sub -eq 'config') {
        if ((Test-HasArg -Items $rest -Values $script:GitConfigReadOptions) -or ($rest.Count -gt 0 -and @('get', 'list') -ccontains $rest[0])) {
            return (New-Decision -Decision 'none')
        }
        return (New-Decision -Decision 'ask' -Reason ("this changes git configuration (" + $text + ")."))
    }
    if ($sub -eq 'reflog') {
        if ($rest.Count -gt 0 -and @('expire', 'delete') -ccontains $rest[0]) {
            return (New-Decision -Decision 'deny' -Reason "expiring or deleting reflog entries destroys recovery points. Give the user the command instead.")
        }
        return (New-Decision -Decision 'none')
    }
    if ($sub -eq 'worktree') {
        if ($rest.Count -gt 0 -and $rest[0] -ceq 'list') { return (New-Decision -Decision 'none') }
        return (New-Decision -Decision 'ask' -Reason ("this changes git worktrees (" + $text + ")."))
    }
    if ($sub -eq 'submodule') {
        if ($rest.Count -eq 0 -or @('status', 'summary') -ccontains $rest[0]) { return (New-Decision -Decision 'none') }
        return (New-Decision -Decision 'ask' -Reason ("this changes git submodules (" + $text + ")."))
    }
    if ($sub -eq 'bisect') {
        return (New-Decision -Decision 'ask' -Reason ("git bisect checks out other commits (" + $text + "). Approve only if you are debugging with it."))
    }
    if ($script:GitAllow -contains $sub) {
        return (New-Decision -Decision 'none')
    }
    return (New-Decision -Decision 'ask' -Reason ("unrecognized git subcommand '" + $sub + "' (" + $text + "). Approve only if you expected it."))
}

# -------------------------------------------------------------------- gh
function Get-GhDecision {
    [CmdletBinding()]
    param($Command)
    $words = @(Get-NonFlagArgument -Items @($Command.Args))
    if ($words.Count -eq 0) { return (New-Decision -Decision 'none') }
    $noun = $words[0].ToLowerInvariant()
    $verb = ''
    if ($words.Count -gt 1) { $verb = $words[1].ToLowerInvariant() }
    $text = Format-CommandText -Command $Command

    if ($script:GhDeny -contains ($noun + ' ' + $verb)) {
        return (New-Decision -Decision 'deny' -Reason "merging pull requests and deleting repositories or releases are the user's call. Give the user the command instead.")
    }
    $changes = $false
    if ($noun -eq 'api') { $changes = $true }
    elseif (($noun -eq 'secret' -or $noun -eq 'variable') -and $verb -ne 'list') { $changes = $true }
    elseif ($script:GhAsk.ContainsKey($noun) -and ($script:GhAsk[$noun] -contains $verb)) { $changes = $true }

    if ($changes) {
        return (New-Decision -Decision 'ask' -Reason ("this GitHub CLI command changes something on GitHub (" + $text + "). Approve only if you asked for it."))
    }
    return (New-Decision -Decision 'none')
}

# --------------------------------------------------------------- deletes
function Get-DeleteDecision {
    [CmdletBinding()]
    param($Command)
    $text = Format-CommandText -Command $Command
    $reason = "recursive or directory delete (" + $text + "). Approve only if these files belong to the current task."
    if ($Command.Program -eq 'rmdir' -or $Command.Program -eq 'rd') {
        return (New-Decision -Decision 'ask' -Reason $reason)
    }
    foreach ($item in @($Command.Args)) {
        if ($item.Length -le 5 -and $item -cmatch '^-[A-Za-z]{0,3}[rR][A-Za-z]{0,3}$') { return (New-Decision -Decision 'ask' -Reason $reason) }
        if ($item -imatch '^-rec') { return (New-Decision -Decision 'ask' -Reason $reason) }
        if ($item -ceq '--recursive' -or $item -ieq '/s') { return (New-Decision -Decision 'ask' -Reason $reason) }
    }
    return (New-Decision -Decision 'none')
}

# -------------------------------------------------------- infrastructure
function Get-InfraDecision {
    [CmdletBinding()]
    param($Command)
    $program = $Command.Program
    $all = @($Command.Args)
    $text = Format-CommandText -Command $Command
    $askCloud = (New-Decision -Decision 'ask' -Reason ($program + " command that changes cloud or cluster resources (" + $text + "). The user approves every deploy and infrastructure change."))

    if ($program -eq 'gcloud') {
        foreach ($word in @(Get-NonFlagArgument -Items $all)) {
            $lower = $word.ToLowerInvariant()
            if ($lower -match $script:GcloudMutating -or @('rm', 'mv', 'cp') -contains $lower) { return $askCloud }
        }
        return (New-Decision -Decision 'none')
    }
    if ($program -eq 'firebase') {
        foreach ($word in $all) {
            $lower = $word.ToLowerInvariant()
            if ($lower -eq 'deploy' -or $lower -match $script:FirebaseMutating) { return $askCloud }
        }
        return (New-Decision -Decision 'none')
    }
    if ($program -eq 'terraform') {
        $words = @(Get-NonFlagArgument -Items $all)
        if ($words.Count -eq 0) { return (New-Decision -Decision 'none') }
        $sub = $words[0].ToLowerInvariant()
        $next = ''
        if ($words.Count -gt 1) { $next = $words[1].ToLowerInvariant() }
        if ($script:TerraformAsk -contains $sub) { return $askCloud }
        if ($sub -eq 'state' -and @('rm', 'mv', 'push', 'replace-provider') -contains $next) { return $askCloud }
        if ($sub -eq 'workspace' -and @('new', 'delete') -contains $next) { return $askCloud }
        return (New-Decision -Decision 'none')
    }
    if ($program -eq 'kubectl') {
        $words = @(Get-NonFlagArgument -Items $all -ValueOptions $script:KubectlValueOptions)
        if ($words.Count -eq 0) { return (New-Decision -Decision 'none') }
        $verb = $words[0].ToLowerInvariant()
        $next = ''
        if ($words.Count -gt 1) { $next = $words[1].ToLowerInvariant() }
        if ($script:KubectlAsk -contains $verb) { return $askCloud }
        if ($verb -eq 'rollout' -and @('restart', 'undo', 'pause', 'resume') -contains $next) { return $askCloud }
        if ($verb -eq 'config' -and $script:KubectlConfigAsk -contains $next) { return $askCloud }
        return (New-Decision -Decision 'none')
    }
    if ($program -eq 'docker') {
        $words = @(Get-NonFlagArgument -Items $all -ValueOptions $script:DockerValueOptions)
        if ($words.Count -eq 0) { return (New-Decision -Decision 'none') }
        $sub = $words[0].ToLowerInvariant()
        $next = ''
        if ($words.Count -gt 1) { $next = $words[1].ToLowerInvariant() }
        $askDocker = (New-Decision -Decision 'ask' -Reason ("docker command that pushes images or deletes containers, images, or volumes (" + $text + ")."))
        if (@('push', 'rmi', 'rm') -contains $sub) { return $askDocker }
        if (@('system', 'volume', 'image', 'container', 'network', 'builder') -contains $sub -and @('prune', 'rm') -contains $next) { return $askDocker }
        if ($sub -eq 'compose') {
            if ($words -contains 'rm') { return $askDocker }
            if (($words -contains 'down') -and ((Test-HasArg -Items $all -Values @('-v', '--volumes')) -or (Test-HasArgPrefix -Items $all -Prefixes @('--rmi')))) { return $askDocker }
        }
        return (New-Decision -Decision 'none')
    }
    return (New-Decision -Decision 'none')
}

# -------------------------------------------------------------- packages
function Test-PipInstallAddsPackage {
    # True when "pip install" names a package from an index rather than only
    # requirement files, editable installs, or local paths.
    [CmdletBinding()]
    [OutputType([bool])]
    param([string[]] $Items)
    $k = 0
    while ($null -ne $Items -and $k -lt $Items.Count) {
        $item = $Items[$k]
        if ($script:PipValueOptions -ccontains $item) { $k += 2; continue }
        if ($item.StartsWith('-')) { $k += 1; continue }
        $isLocal = ($item -eq '.' -or $item -eq '..' -or $item.StartsWith('./') -or $item.StartsWith('../') -or $item.StartsWith('.\') -or $item.StartsWith('..\'))
        if (-not $isLocal) { return $true }
        $k++
    }
    return $false
}

function Get-PackageDecision {
    [CmdletBinding()]
    param($Command)
    $program = $Command.Program
    $all = @($Command.Args)
    $text = Format-CommandText -Command $Command
    $askDependency = (New-Decision -Decision 'ask' -Reason ("this adds, removes, upgrades, or publishes a dependency (" + $text + "). The rules say prefer what the repo already uses and pin versions. Approve only if you agreed to this change."))
    $askGlobal = (New-Decision -Decision 'ask' -Reason ("global package install (" + $text + "). The rules say ask before global installs."))

    if ($program -eq 'npm' -or $program -eq 'pnpm') {
        if ((Test-HasArg -Items $all -Values @('-g', '--global')) -or (Test-HasArgPrefix -Items $all -Prefixes @('--location=global'))) { return $askGlobal }
    }

    $words = @(Get-NonFlagArgument -Items $all)
    $sub = ''
    if ($words.Count -gt 0) { $sub = $words[0].ToLowerInvariant() }
    $next = ''
    if ($words.Count -gt 1) { $next = $words[1].ToLowerInvariant() }

    if ($program -eq 'npm') {
        if ($script:NpmInstall -contains $sub) {
            if ($words.Count -gt 1) { return $askDependency }
            return (New-Decision -Decision 'none')
        }
        if (($script:NpmRemove + $script:NpmUpdate + $script:NpmPublish) -contains $sub) { return $askDependency }
        if ($sub -eq 'audit' -and ($words -contains 'fix')) { return $askDependency }
        return (New-Decision -Decision 'none')
    }
    if ($program -eq 'pnpm') {
        if ($sub -eq 'add') { return $askDependency }
        if (@('install', 'i') -contains $sub -and $words.Count -gt 1) { return $askDependency }
        if (@('remove', 'rm', 'uninstall', 'un', 'update', 'up', 'upgrade', 'publish') -contains $sub) { return $askDependency }
        return (New-Decision -Decision 'none')
    }
    if ($program -eq 'yarn') {
        if (@('add', 'remove', 'upgrade', 'up', 'upgrade-interactive', 'global', 'publish') -contains $sub) { return $askDependency }
        if ($sub -eq 'npm' -and $next -eq 'publish') { return $askDependency }
        return (New-Decision -Decision 'none')
    }
    if ($program -eq 'pip' -or $program -eq 'pip3') {
        $index = -1
        for ($k = 0; $k -lt $all.Count; $k++) {
            if (-not $all[$k].StartsWith('-')) { $index = $k; break }
        }
        if ($index -lt 0) { return (New-Decision -Decision 'none') }
        $pipSub = $all[$index].ToLowerInvariant()
        if ($pipSub -eq 'uninstall') { return $askDependency }
        if ($pipSub -eq 'install' -and (Test-PipInstallAddsPackage -Items @(Get-ArgSlice -Items $all -Start ($index + 1)))) { return $askDependency }
        return (New-Decision -Decision 'none')
    }
    if ($program -eq 'uv') {
        if ((Test-HasArg -Items $all -Values @('--upgrade', '-U')) -or (Test-HasArgPrefix -Items $all -Prefixes @('--upgrade-package'))) { return $askDependency }
        if (@('add', 'remove') -contains $sub) { return $askDependency }
        if ($sub -eq 'tool' -and $next -eq 'install') { return $askDependency }
        if ($sub -eq 'pip' -and $next -eq 'uninstall') { return $askDependency }
        if ($sub -eq 'pip' -and $next -eq 'install') {
            $installAt = [Array]::IndexOf($all, 'install')
            if ($installAt -ge 0 -and (Test-PipInstallAddsPackage -Items @(Get-ArgSlice -Items $all -Start ($installAt + 1)))) { return $askDependency }
        }
        return (New-Decision -Decision 'none')
    }
    if ($program -eq 'poetry') {
        if (@('add', 'remove', 'update', 'self') -contains $sub) { return $askDependency }
        return (New-Decision -Decision 'none')
    }
    return (New-Decision -Decision 'none')
}

# ------------------------------------------------------------ migrations
function Get-MigrationDecision {
    [CmdletBinding()]
    param($Command)
    $words = @(Get-NonFlagArgument -Items @($Command.Args) -ValueOptions $script:AlembicValueOptions)
    if ($words.Count -gt 0 -and @('upgrade', 'downgrade', 'stamp') -contains $words[0].ToLowerInvariant()) {
        $text = Format-CommandText -Command $Command
        return (New-Decision -Decision 'ask' -Reason ("this runs a database migration (" + $text + "). Approve only if you asked for it and know which database it targets."))
    }
    return (New-Decision -Decision 'none')
}

# -------------------------------------------------------------- dispatch
function Get-CommandDecision {
    <#
    .SYNOPSIS
    Decides none, ask, or deny for one parsed command from Get-ShellCommand.
    #>
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)] $Command)
    $program = [string]$Command.Program
    if ($program -eq 'git') { return (Get-GitDecision -Command $Command) }
    if ($program -eq 'gh') { return (Get-GhDecision -Command $Command) }
    if (@('rm', 'rmdir', 'rd', 'del', 'erase', 'remove-item', 'ri') -contains $program) { return (Get-DeleteDecision -Command $Command) }
    if (@('gcloud', 'firebase', 'terraform', 'kubectl', 'docker') -contains $program) { return (Get-InfraDecision -Command $Command) }
    if (@('npm', 'pnpm', 'yarn', 'pip', 'pip3', 'uv', 'poetry') -contains $program) { return (Get-PackageDecision -Command $Command) }
    if ($program -eq 'alembic') { return (Get-MigrationDecision -Command $Command) }
    return (New-Decision -Decision 'none')
}

function Merge-Decision {
    <#
    .SYNOPSIS
    Combines decisions. The strictest wins: deny over ask over none.
    #>
    [CmdletBinding()]
    param([object[]] $Decisions)
    $rank = @{ 'none' = 0; 'ask' = 1; 'deny' = 2 }
    $best = 0
    foreach ($decision in $Decisions) {
        $value = $rank[[string]$decision.Decision]
        if ($value -gt $best) { $best = $value }
    }
    if ($best -eq 0) { return (New-Decision -Decision 'none') }
    $name = 'ask'
    if ($best -eq 2) { $name = 'deny' }
    $reasons = New-Object -TypeName 'System.Collections.Generic.List[string]'
    foreach ($decision in $Decisions) {
        if ($decision.Decision -eq $name -and -not $reasons.Contains([string]$decision.Reason)) {
            $reasons.Add([string]$decision.Reason)
        }
    }
    return [pscustomobject]@{ Decision = $name; Reason = ($reasons.ToArray() -join ' | ') }
}

function Get-ShellGuardDecision {
    <#
    .SYNOPSIS
    Entry point used by shell-guard.ps1 and the tests. Parses the whole
    command line, judges every program in it, and returns the strictest result.
    #>
    [CmdletBinding()]
    param([AllowEmptyString()] [string] $CommandLine)
    $decisions = New-Object -TypeName 'System.Collections.Generic.List[object]'
    foreach ($parsed in @(Get-ShellCommand -CommandLine $CommandLine)) {
        $decisions.Add((Get-CommandDecision -Command $parsed))
    }
    return (Merge-Decision -Decisions $decisions.ToArray())
}

Export-ModuleMember -Function Get-ShellGuardDecision, Get-CommandDecision, Merge-Decision, New-Decision
