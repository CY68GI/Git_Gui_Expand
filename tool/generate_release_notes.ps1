param(
  [Parameter(Mandatory = $true)][string]$Tag,
  [string]$OutputPath = "RELEASE_NOTES.md",
  [string]$ChangelogPath = "CHANGELOG.md"
)

$ErrorActionPreference = "Stop"
$version = $Tag.TrimStart("v")
$previousTag = git describe --tags --abbrev=0 "$Tag^" 2>$null
if ($LASTEXITCODE -ne 0) {
  $previousTag = $null
  $range = $Tag
} else {
  $range = "$previousTag..$Tag"
}

$lines = Get-Content -LiteralPath $ChangelogPath
$startIndex = -1
for ($index = 0; $index -lt $lines.Count; $index++) {
  if ($lines[$index] -match "^##\s+$([regex]::Escape($version))\s") {
    $startIndex = $index
    break
  }
}
if ($startIndex -lt 0) {
  throw "$ChangelogPath does not contain a section for $version"
}

$endIndex = $lines.Count
if ($previousTag) {
  $previousVersion = $previousTag.TrimStart("v")
  for ($index = $startIndex + 1; $index -lt $lines.Count; $index++) {
    if ($lines[$index] -match "^##\s+$([regex]::Escape($previousVersion))\s") {
      $endIndex = $index
      break
    }
  }
}

$versionChanges = @($lines[$startIndex..($endIndex - 1)] | Select-Object -Skip 1)
$commits = @(git log $range --pretty=format:"- %s")
$base = if ($previousTag) {
  "自 $previousTag 以来"
} else {
  "首个发布版本"
}
$notes = @(
  "## Git GUI Expand $version"
  ""
  "> 本页仅展示${base}的更新内容。"
  ""
  ($versionChanges -join "`n")
  ""
  "### 提交记录"
  ""
  ($commits -join "`n")
) -join "`n"

Set-Content -LiteralPath $OutputPath -Value $notes -Encoding utf8
Write-Output "Release notes written to $OutputPath"
