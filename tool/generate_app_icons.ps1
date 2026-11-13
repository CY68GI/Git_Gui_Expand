$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent $PSScriptRoot
$assetDirectory = Join-Path $projectRoot 'assets\icons'
$windowsIcon = Join-Path $projectRoot 'windows\runner\resources\app_icon.ico'
$macIconDirectory = Join-Path $projectRoot 'macos\Runner\Assets.xcassets\AppIcon.appiconset'
$linuxIconDirectory = Join-Path $projectRoot 'linux\icons\hicolor\256x256\apps'

New-Item -ItemType Directory -Force -Path $assetDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $macIconDirectory | Out-Null
New-Item -ItemType Directory -Force -Path $linuxIconDirectory | Out-Null

function New-RoundedPath {
  param(
    [float]$X,
    [float]$Y,
    [float]$Width,
    [float]$Height,
    [float]$Radius
  )
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $diameter = $Radius * 2
  $path.AddArc($X, $Y, $diameter, $diameter, 180, 90)
  $path.AddArc($X + $Width - $diameter, $Y, $diameter, $diameter, 270, 90)
  $path.AddArc(
    $X + $Width - $diameter,
    $Y + $Height - $diameter,
    $diameter,
    $diameter,
    0,
    90
  )
  $path.AddArc($X, $Y + $Height - $diameter, $diameter, $diameter, 90, 90)
  $path.CloseFigure()
  return $path
}

function New-IconPng {
  param([int]$Size)

  $bitmap = New-Object System.Drawing.Bitmap(
    $Size,
    $Size,
    [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
  )
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $graphics.CompositingQuality =
    [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $graphics.InterpolationMode =
    [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.Clear([System.Drawing.Color]::Transparent)

  $inset = [Math]::Max(0.5, $Size * 0.025)
  $rectSize = $Size - ($inset * 2)
  $radius = [Math]::Max(2.0, $Size * 0.225)
  $shape = New-RoundedPath -X $inset -Y $inset -Width $rectSize `
    -Height $rectSize -Radius $radius
  $gradient = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    (New-Object System.Drawing.PointF(0, 0)),
    (New-Object System.Drawing.PointF($Size, $Size)),
    [System.Drawing.ColorTranslator]::FromHtml('#12A58D'),
    [System.Drawing.ColorTranslator]::FromHtml('#084A56')
  )
  $graphics.FillPath($gradient, $shape)

  $white = [System.Drawing.Color]::White
  $lineWidth = [Math]::Max(1.15, $Size * 0.052)
  $pen = New-Object System.Drawing.Pen($white, $lineWidth)
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

  $centerX = $Size * 0.5
  $rootY = $Size * 0.29
  $branchY = $Size * 0.50
  $childY = $Size * 0.68
  $leftX = $Size * 0.33
  $rightX = $Size * 0.67
  $nodeRadius = [Math]::Max(1.7, $Size * 0.062)
  $rootRadius = [Math]::Max(1.8, $Size * 0.058)

  $graphics.DrawLine($pen, $centerX, $rootY + $rootRadius, `
    $centerX, $branchY)
  $graphics.DrawLine($pen, $leftX, $branchY, $rightX, $branchY)
  $graphics.DrawLine($pen, $leftX, $branchY, $leftX, $childY - $nodeRadius)
  $graphics.DrawLine($pen, $rightX, $branchY, $rightX, $childY - $nodeRadius)

  $nodeBrush = New-Object System.Drawing.SolidBrush($white)
  $graphics.FillEllipse(
    $nodeBrush,
    [float]($centerX - $rootRadius),
    [float]($rootY - $rootRadius),
    [float]($rootRadius * 2),
    [float]($rootRadius * 2)
  )
  $graphics.FillEllipse(
    $nodeBrush,
    [float]($leftX - $nodeRadius),
    [float]($childY - $nodeRadius),
    [float]($nodeRadius * 2),
    [float]($nodeRadius * 2)
  )
  $graphics.FillEllipse(
    $nodeBrush,
    [float]($rightX - $nodeRadius),
    [float]($childY - $nodeRadius),
    [float]($nodeRadius * 2),
    [float]($nodeRadius * 2)
  )

  $stream = New-Object System.IO.MemoryStream
  $bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
  $bytes = $stream.ToArray()

  $stream.Dispose()
  $nodeBrush.Dispose()
  $pen.Dispose()
  $gradient.Dispose()
  $shape.Dispose()
  $graphics.Dispose()
  $bitmap.Dispose()
  return ,$bytes
}

$pngSizes = @(16, 20, 24, 32, 40, 48, 64, 128, 256, 512, 1024)
$pngData = @{}
foreach ($size in $pngSizes) {
  $pngData[$size] = New-IconPng -Size $size
  if (@(16, 32, 64, 128, 256, 512, 1024) -contains $size) {
    [System.IO.File]::WriteAllBytes(
      (Join-Path $macIconDirectory "app_icon_$size.png"),
      $pngData[$size]
    )
  }
}

[System.IO.File]::WriteAllBytes(
  (Join-Path $assetDirectory 'app_icon.png'),
  $pngData[256]
)
[System.IO.File]::WriteAllBytes(
  (Join-Path $linuxIconDirectory 'git_gui_expand.png'),
  $pngData[256]
)

$icoSizes = @(16, 20, 24, 32, 40, 48, 64, 128, 256)
$headerSize = 6 + ($icoSizes.Count * 16)
$offset = $headerSize
$icoStream = New-Object System.IO.MemoryStream
$writer = New-Object System.IO.BinaryWriter($icoStream)
$writer.Write([UInt16]0)
$writer.Write([UInt16]1)
$writer.Write([UInt16]$icoSizes.Count)
foreach ($size in $icoSizes) {
  $writer.Write([byte]($(if ($size -ge 256) { 0 } else { $size })))
  $writer.Write([byte]($(if ($size -ge 256) { 0 } else { $size })))
  $writer.Write([byte]0)
  $writer.Write([byte]0)
  $writer.Write([UInt16]1)
  $writer.Write([UInt16]32)
  $bytes = $pngData[$size]
  $writer.Write([UInt32]$bytes.Length)
  $writer.Write([UInt32]$offset)
  $offset += $bytes.Length
}
foreach ($size in $icoSizes) {
  $writer.Write($pngData[$size])
}
$writer.Flush()
[System.IO.File]::WriteAllBytes($windowsIcon, $icoStream.ToArray())
$writer.Dispose()
$icoStream.Dispose()

Write-Output "Generated Windows ICO, macOS iconset, Linux icon and app asset."
