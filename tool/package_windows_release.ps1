param(
  [Parameter(Mandatory = $true)][string]$Tag,
  [string]$BuildOutput = "build/windows/x64/runner/Release",
  [string]$OutputDirectory = "dist",
  [string]$RepositoryRoot = "."
)

$ErrorActionPreference = "Stop"
$version = $Tag.TrimStart("v")
if ([string]::IsNullOrWhiteSpace($version)) {
  throw "Tag must contain a version"
}

$root = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$release = (Resolve-Path -LiteralPath (Join-Path $root $BuildOutput)).Path
$dist = [IO.Path]::GetFullPath((Join-Path $root $OutputDirectory))
$stage = Join-Path $dist "package-$Tag"
$versionStage = Join-Path $stage "versions/$version"
$asset = Join-Path $dist "Git_Gui_Expand-$Tag-windows-x64.zip"

$distPrefix = [IO.Path]::GetFullPath($dist) + [IO.Path]::DirectorySeparatorChar
if (-not [IO.Path]::GetFullPath($stage).StartsWith(
      $distPrefix,
      [StringComparison]::OrdinalIgnoreCase
    )) {
  throw "Unsafe release stage path: $stage"
}

if (Test-Path -LiteralPath $stage) {
  Remove-Item -LiteralPath $stage -Recurse -Force
}
if (Test-Path -LiteralPath $asset) {
  Remove-Item -LiteralPath $asset -Force
}
New-Item -ItemType Directory -Path $versionStage -Force | Out-Null

Get-ChildItem -LiteralPath $release -Force |
  Where-Object { $_.Name -notin @("userdata", "GitGuiExpandLauncher.exe") } |
  Copy-Item -Destination $versionStage -Recurse -Force
Copy-Item -LiteralPath (Join-Path $release "GitGuiExpandLauncher.exe") `
  -Destination $stage -Force
$maintenanceStage = Join-Path $versionStage "maintenance"
New-Item -ItemType Directory -Path $maintenanceStage -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $release "GitGuiExpandLauncher.exe") `
  -Destination $maintenanceStage -Force
Get-ChildItem -LiteralPath $root -Filter "README*.md" |
  Copy-Item -Destination $stage -Force
Get-ChildItem -LiteralPath $root -Filter "CHANGELOG*.md" |
  Copy-Item -Destination $stage -Force
Copy-Item -LiteralPath (Join-Path $root "LICENSE") -Destination $stage -Force

$versionJson = @{
  version = $version
  tag = $Tag
  builtAt = (Get-Date).ToUniversalTime().ToString("o")
} | ConvertTo-Json
$utf8NoBom = [Text.UTF8Encoding]::new($false)
[IO.File]::WriteAllText(
  (Join-Path $versionStage "version.json"),
  $versionJson,
  $utf8NoBom
)
[IO.File]::WriteAllText(
  (Join-Path $stage "current-version.txt"),
  "$version`n",
  $utf8NoBom
)

$required = @(
  (Join-Path $stage "GitGuiExpandLauncher.exe"),
  (Join-Path $stage "current-version.txt"),
  (Join-Path $stage "LICENSE"),
  (Join-Path $versionStage "git_gui_expand.exe"),
  (Join-Path $versionStage "flutter_windows.dll"),
  (Join-Path $versionStage "data/app.so"),
  (Join-Path $versionStage "maintenance/GitGuiExpandLauncher.exe"),
  (Join-Path $versionStage "version.json")
)
foreach ($path in $required) {
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    throw "Release package is incomplete: $path"
  }
}

Compress-Archive -Path "$stage/*" -DestinationPath $asset -CompressionLevel Optimal
$assetFile = Get-Item -LiteralPath $asset
$hash = (Get-FileHash -LiteralPath $asset -Algorithm SHA256).Hash.ToLowerInvariant()
$checksumAsset = "$asset.sha256"
[IO.File]::WriteAllText(
  $checksumAsset,
  "$hash  $($assetFile.Name)`n",
  $utf8NoBom
)
Remove-Item -LiteralPath $stage -Recurse -Force
Write-Output $assetFile.FullName
Write-Output $checksumAsset
