param(
  [Parameter(Mandatory = $true)][string]$Tag,
  [Parameter(Mandatory = $true)][string]$AssetPath,
  [Parameter(Mandatory = $true)][string]$NotesPath,
  [string]$Owner = "CY68EWZRY",
  [string]$Repo = "Git_Gui_Expand",
  [string]$Token = $env:GITEE_TOKEN
)

$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($Token)) {
  throw "GITEE_TOKEN is required to create a Gitee Release"
}
$asset = Get-Item -LiteralPath $AssetPath
$notes = Get-Content -LiteralPath $NotesPath -Raw
$baseUrl = "https://gitee.com/api/v5/repos/$Owner/$Repo"
$tagPath = [Uri]::EscapeDataString($Tag)
$tokenQuery = [Uri]::EscapeDataString($Token)

$release = $null
try {
  $release = Invoke-RestMethod -Method Get `
    -Uri "$baseUrl/releases/tags/$tagPath?access_token=$tokenQuery"
} catch {
  $status = $_.Exception.Response.StatusCode.value__
  if ($status -ne 404) {
    throw
  }
}

if ($null -eq $release) {
  $release = Invoke-RestMethod -Method Post `
    -Uri "$baseUrl/releases" `
    -Form @{
      access_token = $Token
      tag_name = $Tag
      name = "Git GUI Expand $Tag"
      body = $notes
      prerelease = $false
      target_commitish = $Tag
    }
}

$attachments = Invoke-RestMethod -Method Get `
  -Uri "$baseUrl/releases/$($release.id)/attach_files?access_token=$tokenQuery"
$existing = @($attachments) | Where-Object { $_.name -eq $asset.Name }
if (-not $existing) {
  Invoke-RestMethod -Method Post `
    -Uri "$baseUrl/releases/$($release.id)/attach_files" `
    -Form @{
      access_token = $Token
      file = $asset
    } | Out-Null
  Write-Output "Uploaded $($asset.Name) to Gitee Release $Tag"
} else {
  Write-Output "Gitee Release $Tag already contains $($asset.Name)"
}
