param([string]$GeneratedPath)
Add-Type -AssemblyName System.Drawing
$original=[System.Drawing.Bitmap]::FromFile('C:/Users/lien/AppData/Local/Temp/codex-clipboard-5c7d622e-8881-4da0-8915-3871d3073395.png')
$gen=[System.Drawing.Bitmap]::FromFile($GeneratedPath)
$p=[System.Drawing.Bitmap]::FromFile((Join-Path (Get-Location) 'revalia.png'))
$colors=New-Object 'System.Collections.Generic.List[System.Drawing.Color]';$known=@{}
for($y=0;$y -lt $p.Height;$y++){for($x=0;$x -lt $p.Width;$x++){$c=$p.GetPixel($x,$y);if($c.A -eq 255 -and -not $known.ContainsKey($c.ToArgb())){$known[$c.ToArgb()]=1;$colors.Add($c)}}}
$dst=$original.Clone();$mask=New-Object System.Drawing.Drawing2D.GraphicsPath
$coords=@(293,87,332,77,389,80,423,102,444,132,440,206,423,240,408,283,375,320,331,320,305,291,286,267,288,219,271,179,273,135)
$pts=@();for($i=0;$i -lt $coords.Count;$i+=2){$pts+=New-Object System.Drawing.PointF ($coords[$i],$coords[$i+1])};$mask.AddPolygon([System.Drawing.PointF[]]$pts)
$cache=@{}
for($y=75;$y -lt 325;$y++){for($x=265;$x -lt 447;$x++){if(-not $mask.IsVisible($x,$y)){continue};$gridX=[Math]::Floor($x/3)*3+1.5;$gridY=[Math]::Floor($y/3)*3+1.5;$sx=[Math]::Min($gen.Width-1,[int][Math]::Floor($gridX*$gen.Width/$dst.Width));$sy=[Math]::Min($gen.Height-1,[int][Math]::Floor($gridY*$gen.Height/$dst.Height));$c=$gen.GetPixel($sx,$sy);$k=$c.ToArgb();if(-not $cache.ContainsKey($k)){$best=$colors[0];$dist=[double]::MaxValue;foreach($q in $colors){$d=2*[Math]::Pow($c.R-$q.R,2)+4*[Math]::Pow($c.G-$q.G,2)+3*[Math]::Pow($c.B-$q.B,2);if($d -lt $dist){$dist=$d;$best=$q}};$cache[$k]=$best};$dst.SetPixel($x,$y,$cache[$k])}}
$dst.Save((Join-Path (Get-Location) '2026-10-11_05-25-39_5515-full-color26-face-study-scene.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$outside=0;$bad=0
for($y=0;$y -lt $dst.Height;$y++){for($x=0;$x -lt $dst.Width;$x++){if($mask.IsVisible($x,$y)){if(-not $known.ContainsKey($dst.GetPixel($x,$y).ToArgb())){$bad++}}elseif($dst.GetPixel($x,$y).ToArgb() -ne $original.GetPixel($x,$y).ToArgb()){$outside++}}}
"Saved scene face study: $($dst.Width)x$($dst.Height); changes outside face=$outside; edited off-palette pixels=$bad"
$original.Dispose();$gen.Dispose();$p.Dispose();$dst.Dispose();$mask.Dispose()
