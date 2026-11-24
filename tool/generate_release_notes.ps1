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
$scopeEnglish = if ($previousTag) {
  "changes from $previousTag to $Tag"
} else {
  "the first public release"
}
$scopeSimplified = if ($previousTag) {
  "$previousTag 到 $Tag 之间的更新"
} else {
  "首个发布版本"
}
$scopeTraditional = if ($previousTag) {
  "$previousTag 到 $Tag 之間的更新"
} else {
  "首個發布版本"
}
$notes = @(
  "## Git GUI Expand $version"
  ""
  "> English: This page contains only $scopeEnglish."
  "> 简体中文：本页仅展示$scopeSimplified。"
  "> 繁體中文：本頁僅展示$scopeTraditional。"
  ""
  "### Download packages / 下载包 / 下載套件"
  ""
  "1. **Recommended / 推荐 / 建議**：" +
    "``Git_Gui_Expand-$Tag-windows-x64.zip``"
  "   Install Git for Windows separately from https://git-scm.com/download/win"
  "   请自行从 https://git-scm.com/download/win 安装 Git。"
  "   請自行從 https://git-scm.com/download/win 安裝 Git。"
  "2. ``Git_Gui_Expand-$Tag-windows-x64-PortableGit.zip``"
  "   Includes the pinned PortableGit runtime / 包含固定 PortableGit / 包含固定 PortableGit。"
  "3. ``PortableGit-2.56.1-64-bit-runtime.zip``"
  "   Independent runtime update package / 独立运行时更新包 / 獨立執行環境更新套件。"
  ""
  "> SHA-256 is read from the GitHub release asset metadata. No separate" +
    " `.sha256` assets are published. Gitee downloads are matched to the same" +
    " GitHub tag and asset name."
  "> SHA-256 从 GitHub Release 资产元数据读取，不再发布独立 `.sha256` 附件。" +
    "Gitee 下载会按相同标签和资产名匹配。"
  "> SHA-256 從 GitHub Release 資產中繼資料讀取，不再發布個別 `.sha256` 附件。" +
    "Gitee 下載會按相同標籤和資產名稱比對。"
  ""
  ($versionChanges -join "`n")
  ""
  "### Commits / 提交记录 / 提交記錄"
  ""
  ($commits -join "`n")
) -join "`n"

Set-Content -LiteralPath $OutputPath -Value $notes -Encoding utf8
Write-Output "Release notes written to $OutputPath"
