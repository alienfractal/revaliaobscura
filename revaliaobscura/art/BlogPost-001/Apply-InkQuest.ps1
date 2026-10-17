param([string]$ManifestName = 'ink-quest-changes.json')
$ErrorActionPreference = 'Stop'
$questStage = Join-Path $PSScriptRoot '.ink-quest-work'
$questRepo = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$questManifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot $ManifestName) -Raw | ConvertFrom-Json
# Check every path and both versions before writing anything. Refuse to overwrite
# concurrent work in the shared repository.
foreach ($change in $questManifest) {
    $destination = [System.IO.Path]::GetFullPath((Join-Path $questRepo $change.path))
    if (-not $destination.StartsWith($questRepo + '\', [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Path outside project: $destination"
    }
    $source = Join-Path $questStage $change.path
    if ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant() -ne $change.after) {
        throw "Prepared file has changed: $source"
    }
    if (Test-Path -LiteralPath $destination) {
        $actual = (Get-FileHash -LiteralPath $destination -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($actual -eq $change.after) { continue }
        if ($null -eq $change.before -or $actual -ne $change.before) {
            throw "Concurrent changes found; refusing to overwrite: $destination"
        }
    } elseif ($null -ne $change.before) {
        throw "Original file was removed: $destination"
    }
}
foreach ($change in $questManifest) {
    $destination = Join-Path $questRepo $change.path
    $directory = Split-Path -Parent $destination
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $questStage $change.path) -Destination $destination
}
Write-Output "Applied $($questManifest.Count) ink quest files to $questRepo"
