Add-Type -AssemblyName System.Drawing
$root=Get-Location
$start=[System.Drawing.Bitmap]::FromFile((Join-Path $root '2026-10-11_05-25-39_5515-full-color12.png'))
$target=[System.Drawing.Bitmap]::FromFile((Join-Path $root '2026-10-11_05-25-39_5515-full-color8-detailed.png'))
$w=$target.Width;$h=$target.Height
function Make-Path($coords){$p=New-Object System.Drawing.Drawing2D.GraphicsPath;$pts=@();for($i=0;$i -lt $coords.Count;$i+=2){$pts+=New-Object System.Drawing.PointF ($coords[$i],$coords[$i+1])};$p.AddPolygon([System.Drawing.PointF[]]$pts);return ,$p}
$figure=Make-Path @(120,34,145,38,165,36,196,39,215,48,236,35,246,47,244,79,266,93,267,126,258,160,268,188,271,236,262,267,235,279,207,269,183,281,152,276,131,277,97,274,76,257,77,229,83,213,77,190,78,160,83,134,81,105,103,86,108,69,112,49)
$head=Make-Path @(137,39,191,37,211,51,212,91,198,111,186,156,175,186,156,185,145,150,133,120,129,89,128,59)
$bird=Make-Path @(280,96,310,95,328,109,341,135,341,167,292,169,276,147,280,120)
$labels=New-Object 'int[]' ($w*$h)
for($y=0;$y -lt $h;$y++){for($x=0;$x -lt $w;$x++){$c=$target.GetPixel($x,$y);$lum=.2126*$c.R+.7152*$c.G+.0722*$c.B;$isGreen=$c.G -gt $c.R*1.08 -and $c.G -gt $c.B*.9;$stage=23
if($bird.IsVisible($x,$y)){$stage=22}
elseif($head.IsVisible($x,$y)){if($y -lt 62 -or ($x -lt 139 -and $y -lt 139) -or ($y -gt 103 -and $c.R -gt $c.B*1.25 -and $c.G -gt $c.B*1.2 -and $c.G -gt $c.R*.72)){$stage=19}else{$stage=20}}
elseif($figure.IsVisible($x,$y)){if($isGreen -and $y -lt 220){if($lum -lt 85){$stage=17}else{$stage=18}}elseif($y -lt 130 -and ($x -lt 130 -or $x -gt 209)){$stage=18}elseif($y -gt 231 -and ($x -lt 104 -or $x -gt 243)){$stage=22}else{$stage=21}}
elseif($y -ge 232){if(($x -gt 62 -and $x -lt 104 -and $y -lt 268) -or ($x -gt 247 -and $x -lt 281 -and $y -lt 266)){$stage=22}elseif($lum -lt 65){$stage=15}else{$stage=16}}
else{if($lum -lt 50){$stage=13}elseif($lum -lt 115){$stage=14}else{$stage=16}}
if($stage -ge 17 -and ($c.R+$c.G+$c.B) -lt 110){$stage=23};if($lum -gt 210){$stage=24};$labels[$y*$w+$x]=$stage}}
$b=$start.Clone();$counts=@{}
foreach($n in 13..22){$changed=0;for($y=0;$y -lt $h;$y++){for($x=0;$x -lt $w;$x++){if($labels[$y*$w+$x] -eq $n){$c=$target.GetPixel($x,$y);if($b.GetPixel($x,$y).ToArgb() -ne $c.ToArgb()){$changed++};$b.SetPixel($x,$y,$c)}}};$b.Save((Join-Path $root "2026-10-11_05-25-39_5515-full-color$n.png"),[System.Drawing.Imaging.ImageFormat]::Png);$counts[$n]=$changed}
# Separate the final dark contour cleanup from the final remaining colors.
$count23=0
for($y=0;$y -lt $h;$y++){for($x=0;$x -lt $w;$x++){$c=$target.GetPixel($x,$y);if(($c.R+$c.G+$c.B) -lt 110 -and $b.GetPixel($x,$y).ToArgb() -ne $c.ToArgb()){$b.SetPixel($x,$y,$c);$count23++}}}
$b.Save((Join-Path $root '2026-10-11_05-25-39_5515-full-color23.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$counts[23]=$count23
Copy-Item -LiteralPath (Join-Path $root '2026-10-11_05-25-39_5515-full-color8-detailed.png') -Destination (Join-Path $root '2026-10-11_05-25-39_5515-full-color24.png')
$b.Dispose();$start.Dispose();$target.Dispose();$figure.Dispose();$head.Dispose();$bird.Dispose()
$p=[System.Drawing.Bitmap]::FromFile((Join-Path $root 'revalia.png'));$allowed=@{};for($y=0;$y -lt $p.Height;$y++){for($x=0;$x -lt $p.Width;$x++){$allowed[$p.GetPixel($x,$y).ToArgb()]=1}};$p.Dispose()
foreach($n in 13..24){$f=[System.Drawing.Bitmap]::FromFile((Join-Path $root "2026-10-11_05-25-39_5515-full-color$n.png"));$bad=0;for($y=0;$y -lt $h;$y++){for($x=0;$x -lt $w;$x++){if(-not $allowed.ContainsKey($f.GetPixel($x,$y).ToArgb())){$bad++}}};"color${n}: ${w}x${h}; off-palette=$bad; new pixels=$($counts[$n])";$f.Dispose()}
$hashA=(Get-FileHash -LiteralPath (Join-Path $root '2026-10-11_05-25-39_5515-full-color8-detailed.png')).Hash
$hashB=(Get-FileHash -LiteralPath (Join-Path $root '2026-10-11_05-25-39_5515-full-color24.png')).Hash
"Final file exactly matches target: $($hashA -eq $hashB)"

