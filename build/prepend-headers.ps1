param(
    [Parameter(Mandatory = $true)][string]$Source,
    [Parameter(Mandatory = $true)][string]$Obfuscated,
    [Parameter(Mandatory = $true)][string]$Out
)

$lines = Get-Content -LiteralPath $Source -Encoding UTF8
$header = New-Object System.Collections.Generic.List[string]
foreach ($line in $lines) {
    if ($line -match '^\s*script_(name|description|author|version)\s*\(') {
        [void]$header.Add($line)
    }
    elseif ($header.Count -gt 0 -and $line -match '^\s*$') {
        break
    }
    elseif ($header.Count -gt 0) {
        break
    }
}

if ($header.Count -eq 0) {
    Write-Error "script_name/script_version not found in $Source"
    exit 1
}

$body = [System.IO.File]::ReadAllText($Obfuscated)
$text = ($header -join "`r`n") + "`r`n`r`n" + $body
[System.IO.File]::WriteAllText($Out, $text, [System.Text.UTF8Encoding]::new($false))
Write-Host "[prepend] MoonLoader header + obf body -> $Out"
