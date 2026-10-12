Add-Type -AssemblyName System.Drawing
$root=Get-Location
$b=[System.Drawing.Bitmap]::FromFile((Join-Path $root '2026-10-11_05-25-39_5515-full-color8.png'))
function Key($c){'{0},{1},{2}' -f $c.R,$c.G,$c.B}
$greens=@('43,103,78','62,153,107','108,140,80','103,193,118','27,58,47')
$back=@('79,109,111','61,67,86','43,103,78')
$skin=@('247,136,99','247,173,148','185,109,91')
function Poly($coords,$rgb,$allow){$path=New-Object System.Drawing.Drawing2D.GraphicsPath;$pts=@();$xs=@();$ys=@();for($i=0;$i -lt $coords.Count;$i+=2){$pts+=New-Object System.Drawing.PointF ($coords[$i],$coords[$i+1]);$xs+=$coords[$i];$ys+=$coords[$i+1]};$path.AddPolygon([System.Drawing.PointF[]]$pts);$c=[System.Drawing.Color]::FromArgb(255,$rgb[0],$rgb[1],$rgb[2]);$xmin=[Math]::Max(0,($xs|Measure-Object -Minimum).Minimum);$xmax=[Math]::Min(341,($xs|Measure-Object -Maximum).Maximum);$ymin=[Math]::Max(0,($ys|Measure-Object -Minimum).Minimum);$ymax=[Math]::Min(299,($ys|Measure-Object -Maximum).Maximum);for($y=[int]$ymin;$y -le $ymax;$y++){for($x=[int]$xmin;$x -le $xmax;$x++){$v=$b.GetPixel($x,$y);if($path.IsVisible($x,$y) -and $v.R -ne 4 -and ($allow -contains (Key $v))){$b.SetPixel($x,$y,$c)}}};$path.Dispose()}
function Stroke($coords,$rgb,$allow){$c=[System.Drawing.Color]::FromArgb(255,$rgb[0],$rgb[1],$rgb[2]);for($i=0;$i -lt $coords.Count-2;$i+=2){$ax=$coords[$i];$ay=$coords[$i+1];$dx=$coords[$i+2]-$ax;$dy=$coords[$i+3]-$ay;$n=[Math]::Max([Math]::Abs($dx),[Math]::Abs($dy));for($s=0;$s -le $n;$s++){$x=[int][Math]::Round($ax+$dx*$s/[Math]::Max(1,$n));$y=[int][Math]::Round($ay+$dy*$s/[Math]::Max(1,$n));if($x -ge 0 -and $x -lt 342 -and $y -ge 0 -and $y -lt 300){$v=$b.GetPixel($x,$y);if($v.R -ne 4 -and ($allow -contains (Key $v))){$b.SetPixel($x,$y,$c)}}}}}
function Save($n){$b.Save((Join-Path $root "2026-10-11_05-25-39_5515-full-color$n.png"),[System.Drawing.Imaging.ImageFormat]::Png)}
# 9: clustered cape leaves with dark veins, existing mushroom caps warmed.
foreach($leaf in @(@(92,103,105,95,111,97,106,111,97,119),@(104,110,119,101,121,107,116,121,107,124),@(204,101,215,95,224,105,215,118,207,117),@(211,120,224,112,230,119,222,133,214,138),@(94,202,106,196,110,203,101,216,94,214))){Poly $leaf @(108,140,80) $greens}
foreach($vein in @(@(95,115,105,103),@(109,121,117,108),@(209,113,217,102),@(218,131,224,118),@(98,212,105,201))){Stroke $vein @(27,58,47) $greens}
foreach($edge in @(@(93,104,102,98),@(105,112,115,105),@(207,101,215,98),@(214,123,222,116),@(95,204,102,199))){Stroke $edge @(103,193,118) $greens}
Poly @(96,82,100,78,105,80,107,84,102,86) @(161,61,59) @('139,0,0','106,0,0','199,139,80','240,212,114')
Poly @(233,68,238,65,242,68,241,72,235,72) @(161,61,59) @('139,0,0','106,0,0','199,139,80','240,212,114')
Save 9
# 10: complete the long pale beard and clarify living vines on the arms.
Poly @(150,129,157,137,163,141,176,131,182,139,177,157,169,177,160,178,153,157) @(199,186,142) $back
Poly @(155,141,161,148,163,172,158,164) @(241,233,205) @('199,186,142')
Stroke @(174,142,171,155,165,171) @(156,147,124) @('199,186,142','241,233,205')
$armAllow=$skin+$greens
Stroke @(108,126,113,133,109,141,114,146) @(43,103,78) $armAllow
Poly @(111,132,107,127,103,130,109,134) @(108,140,80) $armAllow
Poly @(110,140,115,133,119,135,114,141) @(62,153,107) $armAllow
Stroke @(225,120,221,132,227,142,221,154) @(27,58,47) $armAllow
Poly @(222,129,215,124,213,129,220,133) @(108,140,80) $armAllow
Poly @(225,140,231,133,234,138,228,144) @(62,153,107) $armAllow
Poly @(223,151,216,147,214,151,221,155) @(108,140,80) $armAllow
Save 10
# 11: palette fills clarify the existing hat-wearing bird, nest and tiny gnomes.
Poly @(297,114,301,110,304,113,300,120,297,135,302,141,313,138,325,138,321,145,309,149,296,143,292,136) @(199,186,142) $back
Stroke @(298,120,295,135,301,142) @(241,233,205) @('199,186,142')
Poly @(298,104,303,99,307,101,306,105,312,105,309,108,298,108) @(114,103,90) $back
Stroke @(300,105,309,105) @(233,160,73) @('114,103,90')
Stroke @(292,150,302,155,316,154,330,150) @(199,139,80) $back
Stroke @(295,154,306,158,321,155) @(114,103,90) $back
Poly @(80,228,84,222,88,229) @(161,61,59) ($back+$greens)
Poly @(82,230,87,229,88,233,82,233) @(241,233,205) ($back+$greens)
Poly @(254,239,258,233,261,240) @(233,160,73) ($back+$greens)
Poly @(255,241,260,240,261,244,256,244) @(199,186,142) ($back+$greens)
Save 11
# 12: add restrained distant foliage and small herb clusters to the floor.
foreach($clump in @(@(5,53,15,39,26,46,36,59,21,61),@(44,74,54,63,67,71,74,82,55,86),@(271,51,284,40,295,47,306,62,284,65),@(315,84,325,70,341,76,341,92,326,96))){Poly $clump @(43,103,78) @('79,109,111')}
foreach($plant in @(@(28,274),@(52,261),@(116,277),@(207,283),@(285,266),@(309,280))){$x=$plant[0];$y=$plant[1];Stroke @($x,$y,$x,($y-11)) @(108,140,80) @('27,58,47','43,103,78');Poly @(($x-1),($y-4),($x-8),($y-9),($x-9),($y-13),($x-4),($y-11),$x,($y-6)) @(43,103,78) @('27,58,47');Poly @(($x+1),($y-7),($x+7),($y-13),($x+10),($y-13),($x+6),($y-8)) @(108,140,80) @('27,58,47','43,103,78');Stroke @(($x-6),($y-11),($x-2),($y-7)) @(108,140,80) @('43,103,78')}
Save 12
$b.Dispose()
# Validate the four deliverables against the supplied palette and original outline.
$p=[System.Drawing.Bitmap]::FromFile((Join-Path $root 'revalia.png'));$allowed=@{};for($y=0;$y -lt $p.Height;$y++){for($x=0;$x -lt $p.Width;$x++){$allowed[$p.GetPixel($x,$y).ToArgb()]=1}};$p.Dispose()
$o=[System.Drawing.Bitmap]::FromFile((Join-Path $root '2026-10-11_05-25-39_5515-full-color8.png'))
foreach($n in 9..12){$f=[System.Drawing.Bitmap]::FromFile((Join-Path $root "2026-10-11_05-25-39_5515-full-color$n.png"));$bad=0;$ink=0;$diff=0;for($y=0;$y -lt 300;$y++){for($x=0;$x -lt 342;$x++){$c=$f.GetPixel($x,$y);$v=$o.GetPixel($x,$y);if(-not $allowed.ContainsKey($c.ToArgb())){$bad++};if($v.ToArgb() -ne $c.ToArgb()){$diff++;if($v.R -eq 4){$ink++}}}};"color${n}: 342x300; off-palette=$bad; changed-outline=$ink; pixels changed from color8=$diff";$f.Dispose()};$o.Dispose()
