param(
  [Parameter(Mandatory = $true)][string]$Tag,
  [Parameter(Mandatory = $true)][string[]]$AssetPath,
  [Parameter(Mandatory = $true)][string]$NotesPath,
  [string]$Owner = "CY68EWZRY",
  [string]$Repo = "Git_Gui_Expand",
  [string]$TargetCommitish = "",
  [string]$Token = $env:GITEE_TOKEN
)

$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($Token)) {
  throw "GITEE_TOKEN is required to create a Gitee Release"
}
$notes = Get-Content -LiteralPath $NotesPath -Raw
$baseUrl = "https://gitee.com/api/v5/repos/$Owner/$Repo"
$tagPath = [Uri]::EscapeDataString($Tag)
$headers = @{
  Authorization = "Bearer $Token"
  Accept = "application/json"
}

$release = $null
try {
  $release = Invoke-RestMethod -Method Get `
    -Uri "$baseUrl/releases/tags/$tagPath" `
    -Headers $headers
} catch {
  $status = $_.Exception.Response.StatusCode.value__
  if ($status -ne 404) {
    throw
  }
}

if ($null -eq $release) {
  $releases = Invoke-RestMethod -Method Get `
    -Uri "$baseUrl/releases?per_page=50" `
    -Headers $headers
  $release = @($releases) | Where-Object { $_.tag_name -eq $Tag } | Select-Object -First 1
}

if ($null -eq $release) {
  if ([string]::IsNullOrWhiteSpace($TargetCommitish)) {
    $TargetCommitish = (git rev-parse HEAD).Trim()
  }
  $release = Invoke-RestMethod -Method Post `
    -Uri "$baseUrl/releases" `
    -Headers $headers `
    -ContentType "application/x-www-form-urlencoded; charset=utf-8" `
    -Body @{
      tag_name = $Tag
      name = "Git GUI Expand $Tag"
      body = $notes
      prerelease = "false"
      target_commitish = $TargetCommitish
    }
}

foreach ($path in $AssetPath) {
  $asset = Get-Item -LiteralPath $path
  $attachments = Invoke-RestMethod -Method Get `
    -Uri "$baseUrl/releases/$($release.id)/attach_files" `
    -Headers $headers
  $existing = @($attachments) | Where-Object { $_.name -eq $asset.Name }
  if (-not $existing) {
    Invoke-RestMethod -Method Post `
      -Uri "$baseUrl/releases/$($release.id)/attach_files" `
      -Headers $headers `
      -Form @{
        file = $asset
      } | Out-Null
    Write-Output "Uploaded $($asset.Name) to Gitee Release $Tag"
  } else {
    Write-Output "Gitee Release $Tag already contains $($asset.Name)"
  }
}
