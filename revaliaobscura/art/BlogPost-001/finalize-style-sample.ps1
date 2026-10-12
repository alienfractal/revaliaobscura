param([Parameter(Mandatory=$true)][string]$GeneratedPath)
Add-Type -AssemblyName System.Drawing
$palette=[System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'revalia.png'))
$colors=New-Object 'System.Collections.Generic.List[System.Drawing.Color]';$known=@{}
for($y=0;$y -lt $palette.Height;$y++){for($x=0;$x -lt $palette.Width;$x++){$c=$palette.GetPixel($x,$y);if($c.A -eq 255 -and -not $known.ContainsKey($c.ToArgb())){$known[$c.ToArgb()]=1;$colors.Add($c)}}}
$src=[System.Drawing.Bitmap]::FromFile($GeneratedPath)
$dst=New-Object System.Drawing.Bitmap 342,300
$cache=@{}
for($y=0;$y -lt 300;$y++){for($x=0;$x -lt 342;$x++){$sx=[Math]::Min($src.Width-1,[int][Math]::Floor(($x+.5)*$src.Width/342));$sy=[Math]::Min($src.Height-1,[int][Math]::Floor(($y+.5)*$src.Height/300));$c=$src.GetPixel($sx,$sy);$key=$c.ToArgb();if(-not $cache.ContainsKey($key)){$best=$colors[0];$dist=[double]::MaxValue;foreach($p in $colors){$d=2*[Math]::Pow($c.R-$p.R,2)+4*[Math]::Pow($c.G-$p.G,2)+3*[Math]::Pow($c.B-$p.B,2);if($d -lt $dist){$dist=$d;$best=$p}};$cache[$key]=$best};$dst.SetPixel($x,$y,$cache[$key])}}
$out=Join-Path (Get-Location) '2026-10-11_05-25-39_5515-full-color25-style-sample.png'
$dst.Save($out,[System.Drawing.Imaging.ImageFormat]::Png)
$bad=0;for($y=0;$y -lt 300;$y++){for($x=0;$x -lt 342;$x++){if(-not $known.ContainsKey($dst.GetPixel($x,$y).ToArgb())){$bad++}}}
"Saved color25 style sample: 342x300; off-palette pixels=$bad"
$palette.Dispose();$src.Dispose();$dst.Dispose()

