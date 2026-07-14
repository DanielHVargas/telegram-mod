# PowerShell Script to resize 'Simb Fabicon K azul.png' into all Android launcher icon densities.

Add-Type -AssemblyName System.Drawing

function Resize-Image {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [int]$Width,
        [int]$Height,
        [float]$ScaleFactor
    )
    
    Write-Host "Resizing to $Width x $Height -> $DestPath"
    
    $srcImg = [System.Drawing.Image]::FromFile($SourcePath)
    $bmp = New-Object System.Drawing.Bitmap($Width, $Height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    
    # High-quality scaling settings
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    
    # Calculate dimensions using ScaleFactor (padding)
    $targetW = $Width * $ScaleFactor
    $targetH = $Height * $ScaleFactor
    
    $aspectSrc = $srcImg.Width / $srcImg.Height
    $aspectDest = $targetW / $targetH
    
    if ($aspectSrc -gt $aspectDest) {
        $finalW = $targetW
        $finalH = $targetW / $aspectSrc
    } else {
        $finalH = $targetH
        $finalW = $targetH * $aspectSrc
    }
    
    $x = ($Width - $finalW) / 2
    $y = ($Height - $finalH) / 2
    
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($srcImg, $x, $y, $finalW, $finalH)
    
    # Ensure parent dir exists
    $parentDir = [System.IO.Path]::GetDirectoryName($DestPath)
    if (!(Test-Path $parentDir)) {
        New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
    }
    
    # Save image
    $bmp.Save($DestPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $g.Dispose()
    $bmp.Dispose()
    $srcImg.Dispose()
}

$source = "Simb Fabicon K azul.png"

# Check if source exists
if (!(Test-Path $source)) {
    Write-Error "Source file '$source' not found in workspace!"
    exit 1
}

# Define Densities and their sizes
# Densities: Name -> @(LegacySize, AdaptiveSize)
$densities = @{
    "mdpi"    = @(48, 108)
    "hdpi"    = @(72, 162)
    "xhdpi"   = @(96, 216)
    "xxhdpi"  = @(144, 324)
    "xxxhdpi" = @(192, 432)
}

foreach ($density in $densities.Keys) {
    $sizes = $densities[$density]
    $legacySize = $sizes[0]
    $adaptiveSize = $sizes[1]
    
    # 1. Main app legacy and round icons
    $pathLegacy = "TMessagesProj/src/main/res/mipmap-$density/ic_launcher.png"
    $pathRound = "TMessagesProj/src/main/res/mipmap-$density/ic_launcher_round.png"
    Resize-Image -SourcePath $source -DestPath $pathLegacy -Width $legacySize -Height $legacySize -ScaleFactor 0.90
    Resize-Image -SourcePath $source -DestPath $pathRound -Width $legacySize -Height $legacySize -ScaleFactor 0.90
    
    # 2. Standalone legacy launcher icons
    $pathLegacySa = "TMessagesProj_AppStandalone/src/main/res/mipmap-$density/ic_launcher_sa.png"
    Resize-Image -SourcePath $source -DestPath $pathLegacySa -Width $legacySize -Height $legacySize -ScaleFactor 0.90
    
    # 3. Adaptive foregrounds (scaled smaller to fit inside Android's 66% safe mask)
    $pathFore = "TMessagesProj/src/main/res/mipmap-$density/icon_foreground.png"
    $pathForeRound = "TMessagesProj/src/main/res/mipmap-$density/icon_foreground_round.png"
    $pathForeSa = "TMessagesProj/src/main/res/mipmap-$density/icon_foreground_sa.png"
    Resize-Image -SourcePath $source -DestPath $pathFore -Width $adaptiveSize -Height $adaptiveSize -ScaleFactor 0.65
    Resize-Image -SourcePath $source -DestPath $pathForeRound -Width $adaptiveSize -Height $adaptiveSize -ScaleFactor 0.65
    Resize-Image -SourcePath $source -DestPath $pathForeSa -Width $adaptiveSize -Height $adaptiveSize -ScaleFactor 0.65
}

Write-Host "All launcher icons resized successfully!"
