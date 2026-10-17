# Reduce Sprite Colors

Standalone Lua script for Aseprite 1.3.x; tested in Aseprite 1.3.18.6.

## Install and run

1. In Aseprite choose **File > Scripts > Open Scripts Folder**.
2. Copy **Reduce Sprite Colors.lua** into that folder.
3. Choose **File > Scripts > Rescan Scripts Folder**, then run **Reduce Sprite Colors**.
4. Pick a total color limit (try 32 or 16), leave **Create a reduced copy** enabled, and click **Reduce colors**.
5. Compare the new tab with your original. Use **Save As** to save a result you like.

The script never saves or overwrites a file. With the copy option disabled, the operation is a single Undo step.

## Settings

- **Total colors:** maximum palette entries, from 2 to 256. Indexed sprites reserve one entry for transparency, so a limit of 16 allows up to 15 nontransparent swatches. An RGB sprite only reserves that entry if it has transparent pixels. Results can use fewer entries when colors collapse or the source already fits.
- **K-means passes:** maximum refinement passes, default 24. More passes may refine the result but take longer.
- **Use original swatches:** enabled by default. Selects an actual source color near each cluster center. Disable to use rounded average colors.
- **Create a reduced copy:** enabled by default. Opens an unsaved duplicate with a `-reduced` name. The original sprite stays untouched.

## Indexed palettes

Clustering uses the actual RGBA colors referenced by pixels, weighted by their frequency across all cels. Palette indices are never treated as color coordinates. Unused palette entries do not influence the result; duplicate swatches are combined. Reordering palette indices without changing the artwork produces the same reduced colors.

Indexed sprites remain indexed. The script builds a smaller palette, remaps every cel's pixel indices to it, and sets the transparent index to zero. A nonzero original transparent index is handled correctly, including its different meaning on background layers. Linked cels remain linked. RGB sprites remain RGB.

All frames and layers, including hidden and locked layers, participate. Animation timing, tags, cel positions, and layer properties are retained. There is no dithering, resizing, flattening, or selection-only mode. One shared palette avoids independently changing the colors from frame to frame.

## Alpha and limitations

Fully transparent pixels stay transparent. Partially transparent pixels retain their exact alpha values: each alpha level receives its own color clusters. If the requested palette cannot hold at least one color per nontransparent alpha level plus the transparency slot, the script reports an error before changing anything. Increase the color limit in that case.

The distance measure is weighted RGB (2R, 4G, 3B), with deterministic frequency-weighted seeding and k-means refinement. It optimizes stored cel colors; layer blending or opacity can produce additional displayed colors. It does not guarantee preservation of tiny highlights or particular artistic ramps at very low limits.

Grayscale sprites, tilemap layers, and sprites containing multiple palettes over time are rejected before changes are made. Normal indexed animations with one palette shared across frames are supported.

Large RGB images with many unique colors can take time; Aseprite may be unresponsive while Lua runs.

## Batch use

Run with an already opened input file, followed by script parameters and the script:

```text
aseprite --batch input.aseprite --script-param colors=32 --script-param copy=0 --script "Reduce Sprite Colors.lua" --save-as output.aseprite
```

Optional parameters: `iterations=24`, `original=0` for average colors, `copy=0` for in-place processing of the loaded document. Only an explicit CLI `--save-as` saves anything.

## Verification

The companion `test-reduce-sprite-colors.lua` runs synthetic RGB and indexed cases in Aseprite itself. Pass `--script-param testload=1` and `--script-param dir="absolute-path-to-this-folder"` before `--script test-reduce-sprite-colors.lua`. It writes `color-reducer-test-results.txt` in that folder.

API references: [Palette](https://www.aseprite.org/api/palette/), [Sprite](https://www.aseprite.org/api/sprite/), [Image](https://www.aseprite.org/api/image/).
