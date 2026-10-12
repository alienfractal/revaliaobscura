# Forest Stamp Library

106 editable silhouette stamps, sized for Revalia Obscura's pixel art. Every visible stamp pixel uses the existing game palette. Transparent backgrounds; no black outlines or baked shading.

## Use the gallery

1. Open your scene in Aseprite.
2. Choose **File > Scripts > Forest Stamp Gallery**.
3. Click a thumbnail. Its name and native dimensions appear above the gallery.
   Use **Next** and **Previous** to change pages. Page 2 contains individual leaves and sprays. Page 3 contains modular branches and foliage clusters. Page 4 contains font-derived whole-tree silhouettes. Page 5 contains organic whole trees in small and large sizes.
4. Choose **Use foreground color** for a stencil, or uncheck it to keep the stamp's color. Optional horizontal flip.
5. Click **Load brush**, then click in your scene to place it. The gallery closes so you can paint.
6. Shade the placed copy on its layer. Reopen the gallery to choose another stamp.

The script uses Aseprite's New Brush command. Save a frequently used stamp in the brush menu with **Save Brush Here** if desired. Existing saved brushes are not replaced.

If the script is not listed immediately, use **File > Scripts > Rescan Scripts Folder** (if available), or restart Aseprite. Aseprite may ask to let the script read the library files when first run.

## Edit or add artwork

Open `forest-stamps.aseprite`. Paint over existing shapes inside their named slices. The gallery reads this master file each time it opens, so save your changes before reopening it. The empty **Your shading** layer can hold reusable shading, or keep the silhouettes flat and shade each scene instance instead.

For additional stamps, add a named slice and a matching rectangle entry in `forest-stamps.json`. The gallery displays 24 entries per page. Keep native pixel scale; use mirror variants instead of resizing when possible.

The separate PNG is an initial export; the gallery uses the editable Aseprite master, not that export.

## Without the gallery script

Open the master sheet, select one shape, press Ctrl+B, switch to the scene and stamp. The named slices make each shape's bounds easy to identify.

## Contents

- Trunks: straight, bent, forked, pine silhouette
- Branches: rising, wide fork, hanging, bare twig
- Foliage: small leaf, leaf fan, canopy cluster, drooping leaves
- Herbs: grass tuft, small fern, broad herb, flower stems
- Details: mushroom, stone, root fan, nest
- Understory: sapling, reeds, climbing vine, bush cluster
- Leaves: oak, maple, birch, willow, beech, alder, poplar, linden, ivy, hazel, elm, chestnut leaflet; sideways and smaller variants
- Leaf sprays: ash, rowan, chestnut fan, birch twig, willow spray, oak spray, fern frond, paired beech leaves

The new shapes are stylized botanical silhouettes, not scientific identification plates. The previous master is preserved as `forest-stamps-before-leaf-expansion.aseprite`.

These are simple starter shapes intended for you to refine and shade; they are not finished background illustrations.


## Assemble trees from page 3

Oak, birch, and pine each have upper, middle, lower, and fork branches. The thick left end meets the trunk; turn on horizontal flip to attach branches on the other side. Upper branches rise, middle branches spread, and lower branches descend. Vary their spacing and avoid perfect left/right symmetry.

There are dense and airy clusters for oak, birch, maple, willow, beech, and pine. Place several clusters over branch tips, overlap dense clusters to form canopy masses, and use airy clusters at the edges. Each cluster is a flat silhouette containing connected twigs and multiple leaves.

`oak-tree-assembly-example.aseprite` demonstrates the workflow on separate trunk, branch, foliage, and shading layers. Shade after assembly. These are stylized starter components for pixel art, not botanical diagrams.

The earlier 48-stamp master is saved as `forest-stamps-before-cluster-expansion.aseprite`.


## Font-derived whole trees: page 4

24 silhouettes from Woodcutter's Tree Icons font are added as a separate layer. They are fitted within 76x112 pixels and use the game's olive-green palette color. Use the gallery's foreground-color option for other forest depths.

Author and source information is in `font-source/SOURCES.md`. The glyphs are design assets from that font, not original drawings by Codex. The font itself has not been installed system-wide. Some glyphs are decorative icons; others have more natural broadleaf and spreading silhouettes. Fine branches can need hand cleanup after rasterization.

The previous 72-stamp master is preserved as `forest-stamps-before-font-trees.aseprite`.


## Organic silhouettes: page 5

Five source designs in two sizes (10 stamps): irregular woodland tree, spreading leafy tree, gnarled bare oak, umbrella pine, old broad oak. Original artwork and CC0 source information are in `organic-tree-source/SOURCES.md`.

Small stamps fit within 76x112 pixels. Large stamps fit within 152x224 pixels and retain more natural branching. Use larger versions for nearby or cropped trees and smaller ones for distant silhouettes; recolor with the gallery's foreground-color option.

The previous 96-stamp master is preserved as `forest-stamps-before-organic-trees.aseprite`.

## Three-color guide

The current master has a **Three-color shading - toggle for silhouettes** layer. Hide it to return to the uncolored source layers. The **Your shading** layer stays above it for manual refinements.

Composite trees use dark bark for the trunk, warmer brown for branches, and olive green for foliage. Branch-only stamps use three bark tones; standalone leaves use three green tones; clustered foliage uses two greens and brown stems. Each stamp contains at most three colors, all from revalia.png. Some very small shapes naturally use fewer tones.

These are editable color guides. Internal branches in imported flat silhouettes are suggested structure and may need hand adjustments. Stamp contours and transparency are unchanged.

The gallery now retains the master colors by default. Enable **Use foreground color** when you want a one-color stencil. A backup of the previous master is `forest-stamps-before-three-color.aseprite`.
