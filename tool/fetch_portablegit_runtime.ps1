param(
  [string]$LockPath = (Join-Path $PSScriptRoot "portablegit-runtime.lock.json"),
  [string]$OutputDirectory = "build/portablegit-runtime",
  [string]$CacheDirectory = "build/download-cache",
  [string]$ArchivePath = "",
  [string]$ExpectedSha256 = ""
)

$ErrorActionPreference = "Stop"
$root = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$lock = Get-Content -LiteralPath $LockPath -Raw | ConvertFrom-Json
$packageName = [string]$lock.packageName
$sourceUrl = [string]$lock.sourceUrl
$sourceSha256 = if ([string]::IsNullOrWhiteSpace($ExpectedSha256)) {
  ([string]$lock.sourceSha256).ToLowerInvariant()
} else {
  $ExpectedSha256.ToLowerInvariant()
}
if ([string]::IsNullOrWhiteSpace($packageName) -or
    $packageName -notmatch "^[A-Za-z0-9._-]+$" -or
    -not $packageName.Contains("PortableGit")) {
  throw "PortableGit lock has an invalid packageName"
}
if ($sourceSha256 -notmatch "^[a-f0-9]{64}$") {
  throw "PortableGit lock has an invalid SHA-256"
}

function Resolve-WorkspacePath([string]$Path) {
  if ([IO.Path]::IsPathRooted($Path)) {
    return [IO.Path]::GetFullPath($Path)
  }
  return [IO.Path]::GetFullPath((Join-Path $root $Path))
}

function Get-Sha256Lower([string]$Path) {
  $stream = [IO.File]::OpenRead($Path)
  try {
    $algorithm = [Security.Cryptography.SHA256]::Create()
    try {
      $bytes = $algorithm.ComputeHash($stream)
    } finally {
      $algorithm.Dispose()
    }
  } finally {
    $stream.Dispose()
  }
  return (-join ($bytes | ForEach-Object { $_.ToString("x2") }))
}

$output = Resolve-WorkspacePath $OutputDirectory
$cache = Resolve-WorkspacePath $CacheDirectory
$archive = if ([string]::IsNullOrWhiteSpace($ArchivePath)) {
  Join-Path $cache "$packageName.7z.exe"
} else {
  Resolve-WorkspacePath $ArchivePath
}
$normalized = Join-Path $output $packageName
$extract = Join-Path $output "extract-$packageName"

if (-not (Test-Path -LiteralPath $archive -PathType Leaf)) {
  New-Item -ItemType Directory -Path $cache -Force | Out-Null
  $partial = "$archive.part"
  if (Test-Path -LiteralPath $partial) {
    Remove-Item -LiteralPath $partial -Force
  }
  Invoke-WebRequest -Uri $sourceUrl -OutFile $partial
  Move-Item -LiteralPath $partial -Destination $archive -Force
}

$actualSha256 = Get-Sha256Lower $archive
if ($actualSha256 -ne $sourceSha256) {
  throw "PortableGit archive SHA-256 mismatch: expected $sourceSha256, actual $actualSha256"
}

if (Test-Path -LiteralPath $extract) {
  Remove-Item -LiteralPath $extract -Recurse -Force
}
if (Test-Path -LiteralPath $normalized) {
  Remove-Item -LiteralPath $normalized -Recurse -Force
}
New-Item -ItemType Directory -Path $extract -Force | Out-Null

$extractProcess = Start-Process -FilePath $archive `
  -ArgumentList @("-y", "-o$extract") `
  -Wait -PassThru -WindowStyle Hidden
if ($extractProcess.ExitCode -ne 0) {
  throw "PortableGit extraction failed with exit code $($extractProcess.ExitCode)"
}

$gitExe = Join-Path $extract "cmd/git.exe"
if (-not (Test-Path -LiteralPath $gitExe -PathType Leaf)) {
  throw "Extracted PortableGit does not contain cmd/git.exe"
}
if (-not (Test-Path -LiteralPath (Join-Path $extract "usr") -PathType Container) -or
    (-not (Test-Path -LiteralPath (Join-Path $extract "mingw64") -PathType Container) -and
     -not (Test-Path -LiteralPath (Join-Path $extract "ucrt64") -PathType Container))) {
  throw "Extracted PortableGit does not contain usr and mingw64/ucrt64"
}

$versionOutput = & $gitExe --version
$versionMatch = [regex]::Match([string]$versionOutput, "git version\s+([^\s]+)")
if (-not $versionMatch.Success) {
  throw "Could not parse the extracted PortableGit version"
}
$gitVersion = $versionMatch.Groups[1].Value
if ($gitVersion -ne [string]$lock.gitVersion) {
  throw "PortableGit version mismatch: expected $($lock.gitVersion), actual $gitVersion"
}

New-Item -ItemType Directory -Path $normalized -Force | Out-Null
Get-ChildItem -LiteralPath $extract -Force |
  Copy-Item -Destination $normalized -Recurse -Force
$licenseDirectory = Join-Path $normalized "licenses"
New-Item -ItemType Directory -Path $licenseDirectory -Force | Out-Null
$copying = Get-ChildItem -LiteralPath $extract -Recurse -File -Filter "COPYING" |
  Select-Object -First 1
if ($null -eq $copying) {
  throw "PortableGit distribution does not contain its Git COPYING license"
}
Copy-Item -LiteralPath $copying.FullName `
  -Destination (Join-Path $licenseDirectory "GIT-COPYING.txt") -Force
$distributionLicense = Get-ChildItem -LiteralPath $extract -File -Filter "LICENSE*.txt" |
  Select-Object -First 1
if ($null -ne $distributionLicense) {
  Copy-Item -LiteralPath $distributionLicense.FullName `
    -Destination (Join-Path $licenseDirectory "PORTABLEGIT-LICENSE.txt") -Force
}

$notice = @"
PortableGit package: $packageName
Git version: $gitVersion
Upstream archive: $sourceUrl
Upstream SHA-256: $sourceSha256
Source availability: $($lock.sourceAvailability)
Git license: licenses/GIT-COPYING.txt
PortableGit distribution notice: licenses/PORTABLEGIT-LICENSE.txt
"@
[IO.File]::WriteAllText(
  (Join-Path $licenseDirectory "PORTABLEGIT-NOTICE.txt"),
  $notice,
  [Text.UTF8Encoding]::new($false)
)

$manifest = @{
  runtimeFormat = 1
  packageName = $packageName
  gitVersion = $gitVersion
  sourceUrl = $sourceUrl
  archiveSha256 = $sourceSha256
  licensePath = "licenses/GIT-COPYING.txt"
  noticePath = "licenses/PORTABLEGIT-NOTICE.txt"
  builtAt = (Get-Date).ToUniversalTime().ToString("o")
} | ConvertTo-Json
[IO.File]::WriteAllText(
  (Join-Path $normalized "git-runtime.json"),
  $manifest,
  [Text.UTF8Encoding]::new($false)
)

Remove-Item -LiteralPath $extract -Recurse -Force
Write-Output $normalized
