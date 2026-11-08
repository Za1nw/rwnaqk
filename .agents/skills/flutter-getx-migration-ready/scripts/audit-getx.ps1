# Read-only, lightweight GetX architecture audit. Findings are heuristic, NOT compile errors.
# Usage: & '.\scripts\audit-getx.ps1' -ProjectPath 'D:\project\my-app'
[CmdletBinding()]
param(
    [string]$ProjectPath = '.',
    [ValidateSet('Table', 'Json')]
    [string]$Format = 'Table'
)

$ErrorActionPreference = 'Stop'
try { $root = (Resolve-Path -LiteralPath $ProjectPath -ErrorAction Stop).Path }
catch { throw "Project path not found: $ProjectPath" }

$lib = Join-Path $root 'lib'
if (-not (Test-Path -LiteralPath $lib -PathType Container)) { throw "No lib/ directory: $lib" }

$files = @(Get-ChildItem -LiteralPath $lib -Filter '*.dart' -Recurse -File | Where-Object {
    $_.FullName -notmatch '[\\/](build|\.dart_tool|generated)[\\/]' -and
    $_.Name -notmatch '(\.g|\.freezed|\.gr)\.dart$'
} | Sort-Object FullName)

$issues = New-Object 'System.Collections.Generic.List[object]'
foreach ($file in $files) {
    $relative = $file.FullName.Substring($root.Length).TrimStart([char]'\', [char]'/').Replace('\', '/')
    $isDataDomain = $relative -match '(^|/)(domain|data|repositories?)(/|$)'
    $isController = $relative -match '(^|/)(controllers?)(/|$)' -or $relative -match 'controller\.dart$'
    $isComposition = $relative -match '(^|/)(bindings?|routes?)(/|$)' -or $relative -match '(^|/)(main|app)\.dart$'
    $lines = [System.IO.File]::ReadAllLines($file.FullName)
    for ($i = 0; $i -lt $lines.Length; $i++) {
        $line = $lines[$i]
        $trimmed = $line.TrimStart()
        # Skip full-line comments; inline/string matches can still be false positives.
        if ($trimmed.StartsWith('//') -or $trimmed.StartsWith('*')) { continue }
        $severity = $null
        $reason = $null

        if ($isDataDomain -and $line -match 'package:get/get\.dart|package:get/(get_|route|state)') {
            $severity = 'HIGH'; $reason = 'GetX import in data/domain boundary'
        } elseif ($isDataDomain -and $line -match '\bGet\.(find|put|lazyPut|create|to|off|snackbar|dialog)\b') {
            $severity = 'HIGH'; $reason = 'GetX global call in data/domain boundary'
        } elseif ($isController -and $line -match '\bDio\s*\(|\b(?:dio|_dio|client|_client)\s*\.\s*(?:get|post|put|patch|delete)\s*\(') {
            $severity = 'MEDIUM'; $reason = 'Possible direct HTTP in GetX controller; inspect repository boundary'
        } elseif (-not $isComposition -and $line -match '\bGet\.(put|lazyPut|putAsync|create)\s*(?:<|\()') {
            $severity = 'LOW'; $reason = 'DI registration outside a binding; inspect ownership (may be intentional)'
        } elseif ($isController -and $line -match '\bpermanent\s*:\s*true') {
            $severity = 'LOW'; $reason = 'Permanent dependency; document intended app lifetime'
        }

        if ($severity) {
            $issues.Add([pscustomobject]@{
                Severity = $severity
                File = $relative
                Line = ($i + 1)
                Hint = $reason
            })
        }
    }
}

if ($Format -eq 'Json') {
    @{
        fileCount = $files.Count
        findingCount = $issues.Count
        findings = @($issues.ToArray())
        disclaimer = 'Read-only heuristic; verify manually. Not a Dart parser.'
    } | ConvertTo-Json -Depth 5
} else {
    Write-Host "GetX audit: $($files.Count) Dart files scanned" -ForegroundColor Cyan
    if ($issues.Count -eq 0) {
        Write-Host 'No heuristic findings; this does not prove correctness.' -ForegroundColor Green
    } else {
        $issues | Format-Table Severity, File, Line, Hint -Wrap -AutoSize
        Write-Host "$($issues.Count) possible finding(s). Verify by inspecting code and tests." -ForegroundColor Yellow
    }
}
