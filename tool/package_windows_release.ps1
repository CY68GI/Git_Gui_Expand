param(
  [Parameter(Mandatory = $true)][string]$Tag,
  [string]$BuildOutput = "build/windows/x64/runner/Release",
  [string]$OutputDirectory = "dist",
  [string]$RepositoryRoot = ".",
  [string]$PortableGitRuntimeDirectory = ""
)

$ErrorActionPreference = "Stop"
$version = $Tag.TrimStart("v")
if ([string]::IsNullOrWhiteSpace($version)) {
  throw "Tag must contain a version"
}

$root = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$release = (Resolve-Path -LiteralPath (Join-Path $root $BuildOutput)).Path
$dist = [IO.Path]::GetFullPath((Join-Path $root $OutputDirectory))
$standardStage = Join-Path $dist "package-$Tag-standard"
$portableStage = Join-Path $dist "package-$Tag-PortableGit"
$standardAsset = Join-Path $dist "Git_Gui_Expand-$Tag-windows-x64.zip"
$portableAsset = Join-Path $dist "Git_Gui_Expand-$Tag-windows-x64-PortableGit.zip"
$runtimeLockPath = Join-Path $root "tool/portablegit-runtime.lock.json"
$runtimeLock = Get-Content -LiteralPath $runtimeLockPath -Raw | ConvertFrom-Json
$runtimePackageName = [string]$runtimeLock.packageName
$runtimeSource = if ([string]::IsNullOrWhiteSpace($PortableGitRuntimeDirectory)) {
  Join-Path $root "build/portablegit-runtime/$runtimePackageName"
} elseif ([IO.Path]::IsPathRooted($PortableGitRuntimeDirectory)) {
  $PortableGitRuntimeDirectory
} else {
  Join-Path $root $PortableGitRuntimeDirectory
}
$runtimeAsset = Join-Path $dist "$runtimePackageName-runtime.zip"
$utf8NoBom = [Text.UTF8Encoding]::new($false)

$distPrefix = [IO.Path]::GetFullPath($dist) + [IO.Path]::DirectorySeparatorChar
foreach ($path in @($standardStage, $portableStage)) {
  if (-not [IO.Path]::GetFullPath($path).StartsWith(
      $distPrefix,
      [StringComparison]::OrdinalIgnoreCase
    )) {
    throw "Unsafe release stage path: $path"
  }
}

function Remove-IfExists([string]$Path) {
  if (Test-Path -LiteralPath $Path) {
    Remove-Item -LiteralPath $Path -Recurse -Force
  }
}

function New-AppStage(
  [string]$Stage,
  [string]$PortableGitVersion = ""
) {
  Remove-IfExists $Stage
  $versionStage = Join-Path $Stage "versions/$version"
  New-Item -ItemType Directory -Path $versionStage -Force | Out-Null
  Get-ChildItem -LiteralPath $release -Force |
    Where-Object { $_.Name -notin @("userdata", "GitGuiExpandLauncher.exe") } |
    Copy-Item -Destination $versionStage -Recurse -Force
  Copy-Item -LiteralPath (Join-Path $release "GitGuiExpandLauncher.exe") `
    -Destination $Stage -Force
  $maintenanceStage = Join-Path $versionStage "maintenance"
  New-Item -ItemType Directory -Path $maintenanceStage -Force | Out-Null
  Copy-Item -LiteralPath (Join-Path $release "GitGuiExpandLauncher.exe") `
    -Destination $maintenanceStage -Force
  Get-ChildItem -LiteralPath $root -Filter "README*.md" |
    Copy-Item -Destination $Stage -Force
  Get-ChildItem -LiteralPath $root -Filter "CHANGELOG*.md" |
    Copy-Item -Destination $Stage -Force
  Copy-Item -LiteralPath (Join-Path $root "LICENSE") -Destination $Stage -Force
  $imagesSource = Join-Path $root "docs/images"
  if (Test-Path -LiteralPath $imagesSource -PathType Container) {
    $imagesStage = Join-Path $Stage "docs/images"
    New-Item -ItemType Directory -Path $imagesStage -Force | Out-Null
    Get-ChildItem -LiteralPath $imagesSource -Filter "*.png" -File |
      Copy-Item -Destination $imagesStage -Force
  }

  $versionPayload = @{
    version = $version
    tag = $Tag
    builtAt = (Get-Date).ToUniversalTime().ToString("o")
  }
  if (-not [string]::IsNullOrWhiteSpace($PortableGitVersion)) {
    $versionPayload.portableGitVersion = $PortableGitVersion
  }
  [IO.File]::WriteAllText(
    (Join-Path $versionStage "version.json"),
    ($versionPayload | ConvertTo-Json),
    $utf8NoBom
  )
  [IO.File]::WriteAllText(
    (Join-Path $Stage "current-version.txt"),
    "$version`n",
    $utf8NoBom
  )
}

function Assert-ReleaseLayout([string]$Stage) {
  $versionStage = Join-Path $Stage "versions/$version"
  $required = @(
    (Join-Path $Stage "GitGuiExpandLauncher.exe"),
    (Join-Path $Stage "current-version.txt"),
    (Join-Path $Stage "LICENSE"),
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
}

function Compress-Directory([string]$Source, [string]$Destination) {
  if (Test-Path -LiteralPath $Destination) {
    Remove-Item -LiteralPath $Destination -Force
  }
  & tar.exe -a -c -f $Destination -C $Source "."
  if ($LASTEXITCODE -ne 0) {
    throw "Could not create archive: $Destination"
  }
}

if (-not $runtimePackageName.Contains("PortableGit")) {
  throw "PortableGit runtime package name must contain PortableGit"
}
if (-not (Test-Path -LiteralPath $runtimeSource -PathType Container)) {
  throw "PortableGit runtime is missing: $runtimeSource"
}
$requiredRuntimeFiles = @(
  "cmd/git.exe",
  "git-runtime.json",
  "licenses/GIT-COPYING.txt",
  "licenses/PORTABLEGIT-NOTICE.txt"
)
foreach ($relative in $requiredRuntimeFiles) {
  $path = Join-Path $runtimeSource $relative
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    throw "PortableGit runtime is incomplete: $path"
  }
}
if (-not (Test-Path -LiteralPath (Join-Path $runtimeSource "usr") -PathType Container) -or
    (-not (Test-Path -LiteralPath (Join-Path $runtimeSource "mingw64") -PathType Container) -and
     -not (Test-Path -LiteralPath (Join-Path $runtimeSource "ucrt64") -PathType Container))) {
  throw "PortableGit runtime is missing usr and mingw64/ucrt64"
}

Remove-IfExists $standardStage
Remove-IfExists $portableStage
foreach ($asset in @($standardAsset, $portableAsset, $runtimeAsset)) {
  if (Test-Path -LiteralPath $asset) {
    Remove-Item -LiteralPath $asset -Force
  }
}
Get-ChildItem -LiteralPath $dist -File -Filter "*.sha256" -ErrorAction SilentlyContinue |
  Where-Object {
    $_.Name.StartsWith("Git_Gui_Expand-$Tag-", [StringComparison]::OrdinalIgnoreCase) -or
    $_.Name.StartsWith($runtimePackageName, [StringComparison]::OrdinalIgnoreCase)
  } |
  Remove-Item -Force

New-AppStage -Stage $standardStage
Assert-ReleaseLayout -Stage $standardStage

New-AppStage -Stage $portableStage -PortableGitVersion ([string]$runtimeLock.gitVersion)
$runtimeStageRoot = Join-Path $portableStage "runtime/git"
$runtimeVersionStage = Join-Path $runtimeStageRoot "versions/$runtimePackageName"
New-Item -ItemType Directory -Path $runtimeVersionStage -Force | Out-Null
Get-ChildItem -LiteralPath $runtimeSource -Force |
  Copy-Item -Destination $runtimeVersionStage -Recurse -Force
$runtimePointer = @{
  runtimeFormat = 1
  activeVersion = $runtimePackageName
  activePath = "versions/$runtimePackageName"
  previousVersion = ""
  previousPath = ""
  activatedAt = (Get-Date).ToUniversalTime().ToString("o")
} | ConvertTo-Json
[IO.File]::WriteAllText(
  (Join-Path $runtimeStageRoot "current.json"),
  $runtimePointer,
  $utf8NoBom
)
Assert-ReleaseLayout -Stage $portableStage
$portableRuntimeManifest = Join-Path $runtimeVersionStage "git-runtime.json"
if (-not (Test-Path -LiteralPath $portableRuntimeManifest -PathType Leaf)) {
  throw "PortableGit application package is missing its runtime manifest"
}

Compress-Directory -Source $runtimeSource -Destination $runtimeAsset
Compress-Directory -Source $standardStage -Destination $standardAsset
Compress-Directory -Source $portableStage -Destination $portableAsset

Remove-IfExists $standardStage
Remove-IfExists $portableStage
Write-Output (Get-Item -LiteralPath $standardAsset).FullName
Write-Output (Get-Item -LiteralPath $portableAsset).FullName
Write-Output (Get-Item -LiteralPath $runtimeAsset).FullName
