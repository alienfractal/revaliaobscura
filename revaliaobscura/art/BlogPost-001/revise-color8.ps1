Add-Type -AssemblyName System.Drawing
$root=Get-Location
$old=Join-Path $root '2026-10-11_05-25-39_5515-full-color8.png'
$backup=Join-Path $root '2026-10-11_05-25-39_5515-full-color8-detailed.png'
if(-not (Test-Path -LiteralPath $backup)){Copy-Item -LiteralPath $old -Destination $backup}
$src=[System.Drawing.Bitmap]::FromFile((Join-Path $root '2026-10-11_05-25-39_5515-full-color7.png'))
$b=$src.Clone()
# Change only the backdrop color, preserving all existing drawn lines and objects.
$trunks=@(@(20,8,-.04),@(62,10,.07),@(105,7,-.05),@(231,9,.06),@(276,12,-.05),@(322,9,.035))
$changed=0;$protected=0
for($y=0;$y -lt 300;$y++){for($x=0;$x -lt 342;$x++){$v=$src.GetPixel($x,$y);if($v.R -ne 125 -or $v.G -ne 156 -or $v.B -ne 156){continue};$rgb=@(79,109,111)
foreach($t in $trunks){$center=$t[0]+$t[2]*($y-120);$half=$t[1]/2.0;if([Math]::Abs($x-$center) -lt $half){$rgb=@(61,67,86);break}}
# Broad restrained foliage masses, leaving open space around the central head.
if($y -lt 55){$edge=18+9*[Math]::Sin($x/21.0)+7*[Math]::Sin($x/9.0);if($y -lt $edge -and ($x -lt 114 -or $x -gt 223)){$rgb=@(43,103,78)}}
$b.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,$rgb[0],$rgb[1],$rgb[2]));$changed++}}
$b.Save($old,[System.Drawing.Imaging.ImageFormat]::Png)
$p=[System.Drawing.Bitmap]::FromFile((Join-Path $root 'revalia.png'));$allowed=@{};for($y=0;$y -lt $p.Height;$y++){for($x=0;$x -lt $p.Width;$x++){$allowed[$p.GetPixel($x,$y).ToArgb()]=1}};$bad=0
for($y=0;$y -lt 300;$y++){for($x=0;$x -lt 342;$x++){$v=$src.GetPixel($x,$y);$c=$b.GetPixel($x,$y);if(-not $allowed.ContainsKey($c.ToArgb())){$bad++};if(($v.R -ne 125 -or $v.G -ne 156 -or $v.B -ne 156) -and $v.ToArgb() -ne $c.ToArgb()){$protected++}}}
"color8 revised: 342x300; off-palette=$bad; changes outside background=$protected; detailed version preserved"
$p.Dispose();$src.Dispose();$b.Dispose()
