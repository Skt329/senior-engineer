# ShellParser.psm1
# Turns a shell command line (Bash or PowerShell syntax) into the list of
# programs it runs, so the policy can judge each one. It is deliberately
# simple: it understands quotes, the common separators, $( ) substitutions,
# env-var prefixes, wrapper words such as sudo, and nested shells such as
# bash -c, cmd /c and powershell -Command. It is not a full shell parser.
# Keep this file ASCII-only (Windows PowerShell 5.1 reads it as ANSI).

Set-StrictMode -Version 2.0

$script:SQ = [char]39   # single quote
$script:DQ = [char]34   # double quote
$script:BS = [char]92   # backslash
$script:BT = [char]96   # backtick
$script:LF = [char]10
$script:CR = [char]13

$script:Wrappers = @('sudo', 'command', 'exec', 'time', 'nice', 'nohup', 'env', '&', 'call')
$script:DashCShells = @('bash', 'sh', 'zsh', 'dash', 'ksh')
$script:MaxDepth = 3

function Get-Slice {
    [CmdletBinding()]
    param([string[]] $Items, [int] $Start)
    if ($null -eq $Items -or $Start -ge $Items.Count) {
        return
    }
    return $Items[$Start..($Items.Count - 1)]
}

function Find-ClosingParen {
    # Returns the index of the ')' that closes the '(' at OpenIndex, or -1.
    [CmdletBinding()]
    [OutputType([int])]
    param([string] $Text, [int] $OpenIndex)
    $depth = 0
    for ($k = $OpenIndex; $k -lt $Text.Length; $k++) {
        $ch = $Text[$k]
        if ($ch -eq [char]40) { $depth++ }
        elseif ($ch -eq [char]41) {
            $depth--
            if ($depth -eq 0) { return $k }
        }
    }
    return -1
}

function Split-ShellCommand {
    <#
    .SYNOPSIS
    Splits a command line into segments on newlines, ;, &&, ||, |, a lone &,
    and grouping characters ( ) { }, never inside quotes. The inside of each
    $( ) substitution is split as well and returned as extra segments.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowEmptyString()] [string] $CommandLine)

    $segments = New-Object -TypeName 'System.Collections.Generic.List[string]'
    $extra = New-Object -TypeName 'System.Collections.Generic.List[string]'
    if ([string]::IsNullOrEmpty($CommandLine)) {
        return
    }

    $current = New-Object -TypeName System.Text.StringBuilder
    $last = [char]0
    $inSingle = $false
    $inDouble = $false
    $length = $CommandLine.Length
    $i = 0

    while ($i -lt $length) {
        $c = $CommandLine[$i]
        $next = [char]0
        if ($i + 1 -lt $length) { $next = $CommandLine[$i + 1] }

        if ($inSingle) {
            [void]$current.Append($c); $last = $c
            if ($c -eq $script:SQ) { $inSingle = $false }
            $i++
            continue
        }

        if ($inDouble) {
            if (($c -eq $script:BS -or $c -eq $script:BT) -and $next -eq $script:DQ) {
                [void]$current.Append($c); [void]$current.Append($next); $last = $next
                $i += 2
                continue
            }
            if ($c -eq [char]36 -and $next -eq [char]40) {
                $close = Find-ClosingParen -Text $CommandLine -OpenIndex ($i + 1)
                if ($close -lt 0) { $close = $length - 1 }
                $inner = $CommandLine.Substring($i + 2, [Math]::Max(0, $close - $i - 2))
                $extra.Add($inner)
                [void]$current.Append($CommandLine.Substring($i, $close - $i + 1)); $last = [char]41
                $i = $close + 1
                continue
            }
            [void]$current.Append($c); $last = $c
            if ($c -eq $script:DQ) { $inDouble = $false }
            $i++
            continue
        }

        # Outside quotes from here on.
        if ($c -eq $script:SQ) {
            $inSingle = $true
            [void]$current.Append($c); $last = $c
            $i++
            continue
        }
        if ($c -eq $script:DQ) {
            $inDouble = $true
            [void]$current.Append($c); $last = $c
            $i++
            continue
        }
        if (($c -eq $script:BT -or $c -eq $script:BS) -and ($next -eq $script:LF -or $next -eq $script:CR)) {
            # Line continuation in PowerShell (backtick) or Bash (backslash).
            $i += 2
            if ($i -lt $length -and $CommandLine[$i] -eq $script:LF) { $i++ }
            continue
        }
        if ($c -eq [char]36 -and $next -eq [char]40) {
            $close = Find-ClosingParen -Text $CommandLine -OpenIndex ($i + 1)
            if ($close -lt 0) { $close = $length - 1 }
            $inner = $CommandLine.Substring($i + 2, [Math]::Max(0, $close - $i - 2))
            $extra.Add($inner)
            [void]$current.Append($CommandLine.Substring($i, $close - $i + 1)); $last = [char]41
            $i = $close + 1
            continue
        }
        if ($c -eq [char]36 -and $next -eq [char]123) {
            # ${VAR}: copy through the closing brace.
            $closeBrace = $CommandLine.IndexOf([char]125, $i)
            if ($closeBrace -lt 0) { $closeBrace = $length - 1 }
            [void]$current.Append($CommandLine.Substring($i, $closeBrace - $i + 1)); $last = [char]125
            $i = $closeBrace + 1
            continue
        }
        if ($c -eq [char]35 -and ($current.Length -eq 0 -or [char]::IsWhiteSpace($last))) {
            # Comment: skip to the end of the line.
            while ($i -lt $length -and $CommandLine[$i] -ne $script:LF -and $CommandLine[$i] -ne $script:CR) { $i++ }
            continue
        }

        $isBreak = $false
        $skip = 1
        if ($c -eq [char]59 -or $c -eq $script:LF -or $c -eq $script:CR) {
            $isBreak = $true
        }
        elseif ($c -eq [char]38) {
            if ($next -eq [char]38) {
                $isBreak = $true; $skip = 2
            }
            elseif ($last -eq [char]62 -or $last -eq [char]60 -or $next -eq [char]62) {
                # Redirections such as 2>&1 and &> are not separators.
                [void]$current.Append($c); $last = $c
                $i++
                continue
            }
            elseif ($current.ToString().Trim().Length -eq 0) {
                # PowerShell call operator at the start of a segment: drop it.
                $i++
                continue
            }
            else {
                $isBreak = $true
            }
        }
        elseif ($c -eq [char]124) {
            $isBreak = $true
            if ($next -eq [char]124) { $skip = 2 }
        }
        elseif ($c -eq [char]40 -or $c -eq [char]41 -or $c -eq [char]123 -or $c -eq [char]125) {
            $isBreak = $true
        }

        if ($isBreak) {
            $piece = $current.ToString().Trim()
            if ($piece.Length -gt 0) { $segments.Add($piece) }
            [void]$current.Clear(); $last = [char]0
            $i += $skip
            continue
        }

        [void]$current.Append($c); $last = $c
        $i++
    }

    $tail = $current.ToString().Trim()
    if ($tail.Length -gt 0) { $segments.Add($tail) }

    foreach ($sub in $extra) {
        foreach ($piece in @(Split-ShellCommand -CommandLine $sub)) {
            $segments.Add($piece)
        }
    }
    return $segments.ToArray()
}

function ConvertTo-ShellToken {
    <#
    .SYNOPSIS
    Splits one segment on whitespace outside quotes and removes the quotes.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([AllowEmptyString()] [string] $Segment)

    $tokens = New-Object -TypeName 'System.Collections.Generic.List[string]'
    if ([string]::IsNullOrEmpty($Segment)) {
        return
    }
    $word = New-Object -TypeName System.Text.StringBuilder
    $hasWord = $false
    $inSingle = $false
    $inDouble = $false
    $length = $Segment.Length
    $i = 0
    while ($i -lt $length) {
        $c = $Segment[$i]
        $next = [char]0
        if ($i + 1 -lt $length) { $next = $Segment[$i + 1] }

        if ($inSingle) {
            if ($c -eq $script:SQ) { $inSingle = $false } else { [void]$word.Append($c) }
            $i++
            continue
        }
        if ($inDouble) {
            if (($c -eq $script:BS -or $c -eq $script:BT) -and $next -eq $script:DQ) {
                [void]$word.Append($script:DQ)
                $i += 2
                continue
            }
            if ($c -eq $script:DQ) { $inDouble = $false } else { [void]$word.Append($c) }
            $i++
            continue
        }
        if ($c -eq $script:SQ) { $inSingle = $true; $hasWord = $true; $i++; continue }
        if ($c -eq $script:DQ) { $inDouble = $true; $hasWord = $true; $i++; continue }
        if ([char]::IsWhiteSpace($c)) {
            if ($hasWord) {
                $tokens.Add($word.ToString())
                [void]$word.Clear()
                $hasWord = $false
            }
            $i++
            continue
        }
        [void]$word.Append($c)
        $hasWord = $true
        $i++
    }
    if ($hasWord) { $tokens.Add($word.ToString()) }
    return $tokens.ToArray()
}

function ConvertTo-ProgramName {
    <#
    .SYNOPSIS
    Normalizes a program token: /usr/bin/git, git.exe and
    "C:\Program Files\Git\cmd\git.exe" all become git.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param([string] $Token)
    $name = $Token
    $cut = [Math]::Max($name.LastIndexOf('/'), $name.LastIndexOf($script:BS))
    if ($cut -ge 0) { $name = $name.Substring($cut + 1) }
    $name = $name.ToLowerInvariant()
    foreach ($ext in @('.exe', '.cmd', '.bat', '.com')) {
        if ($name.EndsWith($ext)) {
            $name = $name.Substring(0, $name.Length - $ext.Length)
            break
        }
    }
    return $name
}

function Get-ShellCommand {
    <#
    .SYNOPSIS
    Returns one object per program the command line runs, with Program,
    Args (string[]) and Text, following bash -c, cmd /c and powershell -Command.
    #>
    [CmdletBinding()]
    param(
        [AllowEmptyString()] [string] $CommandLine,
        [int] $Depth = 0
    )
    $results = New-Object -TypeName 'System.Collections.Generic.List[object]'
    if ($Depth -gt $script:MaxDepth) {
        return
    }

    foreach ($segment in @(Split-ShellCommand -CommandLine $CommandLine)) {
        $tokens = @(ConvertTo-ShellToken -Segment $segment)
        $idx = 0
        while ($idx -lt $tokens.Count) {
            $token = $tokens[$idx]
            if ($token -cmatch '^[A-Za-z_][A-Za-z0-9_]*=') { $idx++; continue }
            $lower = $token.ToLowerInvariant()
            if ($script:Wrappers -contains $lower) {
                $idx++
                while ($idx -lt $tokens.Count -and $tokens[$idx].StartsWith('-')) {
                    $option = $tokens[$idx]
                    if (@('-u', '-g', '-n', '-C', '--unset', '--chdir', '--user', '--group') -ccontains $option) { $idx += 2 } else { $idx += 1 }
                }
                continue
            }
            break
        }
        if ($idx -ge $tokens.Count) { continue }

        $program = ConvertTo-ProgramName -Token $tokens[$idx]
        $rest = @(Get-Slice -Items $tokens -Start ($idx + 1))

        if ($script:DashCShells -contains $program) {
            for ($j = 0; $j -lt $rest.Count; $j++) {
                $flag = $rest[$j]
                if (-not $flag.StartsWith('--') -and $flag -cmatch '^-[A-Za-z]*c[A-Za-z]*$' -and ($j + 1) -lt $rest.Count) {
                    foreach ($inner in @(Get-ShellCommand -CommandLine $rest[$j + 1] -Depth ($Depth + 1))) { $results.Add($inner) }
                    break
                }
            }
        }
        elseif ($program -eq 'cmd') {
            for ($j = 0; $j -lt $rest.Count; $j++) {
                # Git Bash users write //c so that MSYS does not turn /c into a path.
                if ($rest[$j] -imatch '^//?[ck]$') {
                    $innerLine = (@(Get-Slice -Items $rest -Start ($j + 1))) -join ' '
                    foreach ($inner in @(Get-ShellCommand -CommandLine $innerLine -Depth ($Depth + 1))) { $results.Add($inner) }
                    break
                }
            }
        }
        elseif ($program -eq 'powershell' -or $program -eq 'pwsh') {
            for ($j = 0; $j -lt $rest.Count; $j++) {
                if ($rest[$j] -imatch '^-c(om|omm|omma|omman|ommand)?$') {
                    $innerLine = (@(Get-Slice -Items $rest -Start ($j + 1))) -join ' '
                    foreach ($inner in @(Get-ShellCommand -CommandLine $innerLine -Depth ($Depth + 1))) { $results.Add($inner) }
                    break
                }
            }
        }

        $results.Add([pscustomobject]@{
            Program = $program
            Args    = [string[]]$rest
            Text    = $segment
        })
    }
    return $results.ToArray()
}

Export-ModuleMember -Function Split-ShellCommand, ConvertTo-ShellToken, ConvertTo-ProgramName, Get-ShellCommand
