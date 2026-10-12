Add-Type -AssemblyName System.Drawing
$root=Get-Location
$src=Join-Path $root '2026-10-11_05-25-39_5515-full-color3.png'
$b=[System.Drawing.Bitmap]::FromFile($src)
$regions=Get-Content 'regions.json' -Raw | ConvertFrom-Json
function Paint-Region($r,$rgb){$c=[System.Drawing.Color]::FromArgb(255,$rgb[0],$rgb[1],$rgb[2]);foreach($i in $r.pixels){$b.SetPixel(($i%342),[int][Math]::Floor($i/342),$c)}}
function Paint-Shape($coords,$rgb){$path=New-Object System.Drawing.Drawing2D.GraphicsPath;$points=@();for($i=0;$i -lt $coords.Count;$i+=2){$points+=New-Object System.Drawing.PointF ($coords[$i],$coords[$i+1])};$path.AddPolygon([System.Drawing.PointF[]]$points);$c=[System.Drawing.Color]::FromArgb(255,$rgb[0],$rgb[1],$rgb[2]);for($y=0;$y -lt 300;$y++){for($x=0;$x -lt 342;$x++){if($path.IsVisible($x,$y)){$v=$b.GetPixel($x,$y);if($v.R -eq 194 -and $v.G -eq 194 -and $v.B -eq 194){$b.SetPixel($x,$y,$c)}}}};$path.Dispose()}
# Fourth frame: beard, eyes, mushroom accents, and remaining clothing.
Paint-Shape @(137,106,151,120,177,117,189,102,197,147,179,169,157,168,145,151,135,136) @(199,186,142)
foreach($r in $regions){if($r.id -in @(44,45,47,49)){Paint-Region $r @(241,233,205)}elseif($r.id -in @(254,279,283,293,355,379)){Paint-Region $r @(108,140,80)}elseif($r.id -in @(265,294,244)){Paint-Region $r @(199,139,80)}elseif($r.id -in @(23,25,29,58,61,147)){Paint-Region $r @(240,212,114)}}
$b.Save((Join-Path $root '2026-10-11_05-25-39_5515-full-color4.png'),[System.Drawing.Imaging.ImageFormat]::Png)
# Fifth frame: reeds, birds, small plants and fungi.
foreach($r in $regions){if($r.id -in @(189,206,219,237)){Paint-Region $r @(108,140,80)}elseif($r.id -in @(52,60,69,79,90,111,150,165)){Paint-Region $r @(199,139,80)}elseif($r.id -in @(291,292,319,323)){Paint-Region $r @(62,153,107)}}
$b.Save((Join-Path $root '2026-10-11_05-25-39_5515-full-color5.png'),[System.Drawing.Imaging.ImageFormat]::Png)
# Sixth frame: cool woodland backdrop, forest floor, and remaining small areas.
for($y=0;$y -lt 300;$y++){for($x=0;$x -lt 342;$x++){$v=$b.GetPixel($x,$y);if($v.R -eq 194 -and $v.G -eq 194 -and $v.B -eq 194){if($y -ge 244){$rgb=@(27,58,47)}else{$rgb=@(79,109,111)};$b.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,$rgb[0],$rgb[1],$rgb[2]))}elseif($v.R -eq 111 -and $v.G -eq 114 -and $v.B -eq 110){$b.SetPixel($x,$y,[System.Drawing.Color]::FromArgb(255,27,58,47))}}}
$b.Save((Join-Path $root '2026-10-11_05-25-39_5515-full-color6.png'),[System.Drawing.Imaging.ImageFormat]::Png)
$b.Dispose()
# Verify dimensions, palette membership and preservation of all previously colored pixels.
$p=[System.Drawing.Bitmap]::FromFile((Join-Path $root 'revalia.png'));$allowed=@{};for($y=0;$y -lt $p.Height;$y++){for($x=0;$x -lt $p.Width;$x++){$allowed[$p.GetPixel($x,$y).ToArgb()]=1}};$p.Dispose()
$original=[System.Drawing.Bitmap]::FromFile($src)
foreach($stage in 4..6){$f=[System.Drawing.Bitmap]::FromFile((Join-Path $root "2026-10-11_05-25-39_5515-full-color$stage.png"));$bad=0;$changed=0;for($y=0;$y -lt 300;$y++){for($x=0;$x -lt 342;$x++){$c=$f.GetPixel($x,$y);if(-not $allowed.ContainsKey($c.ToArgb())){$bad++};$o=$original.GetPixel($x,$y);if($o.R -ne 194 -and $o.R -ne 111 -and $o.ToArgb() -ne $c.ToArgb()){$changed++}}};"color${stage}: $($f.Width)x$($f.Height), off-palette=$bad, existing-color-changes=$changed";$f.Dispose()};$original.Dispose()
