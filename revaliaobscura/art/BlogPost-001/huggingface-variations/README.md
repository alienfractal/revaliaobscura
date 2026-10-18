# Hugging Face Reference Variations for Aseprite

Draw one rock, select it, and generate related rocks through your own Hugging Face Space. Each result becomes a frame in a new sprite. The original sprite is never changed.

Windows, Python 3.10+, and Aseprite 1.3.x. Defaults to `lienthealien/Qwen-Image-Edit-2511-LoRAs-Fast`.

Also supports your SDXL Space: `lienthealien/RuinedHugg`.

## Choose Qwen or SDXL

Use the **Backend** dropdown in Aseprite:

- **Qwen image edit:** `/infer`, Pixel-Art-Refiner, 4 steps, guidance 1. Uses an editing instruction with the reference image.
- **RuinedHugg SDXL:** `/generate`, Juggernaut XL - Ragnarok, 25 steps, guidance 7. The bridge explicitly uses **Image to image**. It never relies on the Space's text-to-image default.

Switching the backend fills in its Space, endpoint, steps, guidance and starter prompt, and shows its relevant settings. Your saved `default` account works with both Spaces. Reopen the script after updating it to see the backend selector.

SDXL exposes **Denoising**, default `0.45`. Lower values generally preserve more of the reference; higher values permit larger changes. For SDXL, describe the desired image in the prompt (for example, "one isolated pixel-art rock, chipped edges, upper-left lighting"), rather than relying only on an editing instruction.

Click **Inspect API** to fill the **SDXL LoRA** dropdown with the choices currently offered by RuinedHugg, such as `pixel-art-xl-v1.1.safetensors` or `PixelArtRedmond-Lite64.safetensors`. `None` is always available and disables that slot. Refreshing keeps your selection if it is still offered; otherwise it selects None. The fetched list is cached locally for the next launch. The tool exposes the first LoRA slot; the other slots use the Space's empty defaults. **LoRA strength** controls that slot. The SDXL style selector sends the separate multiselect style input in the format RuinedHugg expects.

Before requesting a GPU generation, the bridge calls RuinedHugg's CPU preparation endpoint to validate the input and fetch the optional LoRA. If its model is still loading, the Space's error is shown. Canny is disabled. The generation size follows the reference's aspect ratio with the long side at 1024, dimensions rounded to multiples of 64 and limited to 256–1024. References are padded to fit rather than cropped. The existing output-resizing and palette-matching options still apply.

Every variation starts from the same original reference; SDXL does not progressively feed its output back into the next job. Results open as frames in a new sprite just like Qwen results.

## Quick start on this computer

The Python dependencies are installed in this workspace folder, and the token from your `Desktop\projects\account.txt` is saved in the encrypted `default` profile. Access to your actual Space and its `/infer` API has been verified. The defaults are configured for its `Pixel-Art-Refiner` adapter, with no additional style preset.

1. In Aseprite choose **File → Scripts → Open Scripts Folder**.
2. Copy **HF Variations Launcher.lua** from the parent project folder into the Scripts folder. This small launcher uses the already configured bridge here; there is no need to move the Python environment or reenter your token. If you move this project, update the launcher's path. For a portable installation, extract the ZIP into a subfolder of Scripts and run Setup.cmd in that folder instead.
3. Choose **File → Scripts → Rescan Scripts Folder**. Run **HF Variations Launcher**. With the portable installation, run **HF Variations** from its subfolder instead.
4. Click **Inspect API**. It checks access without submitting a generation, shows available LoRAs when the API exposes them, and fills in the endpoint.
5. Choose a LoRA from the dropdown. The verified Space includes `Pixel-Art-Refiner`, selected by default, and `Pixel-Art-Spritesheet`. For isolated rock variations, begin with Pixel-Art-Refiner and `(No style)` to reduce additional style changes. Inspect API refreshes the dropdown with the Space's current choices.
6. Open your rock drawing, select its rectangle, enter a prompt, and click **Generate**. Start with one variation to check the model/LoRA combination.

If moving a virtual environment causes trouble, run Setup.cmd in its final location. The portable archive intentionally contains no virtual environment, credentials, reference drawings or generated outputs.

To add another account later, open Accounts.cmd and save a named profile. There is no need to run a global Hugging Face login for the configured default account.

## Existing Hugging Face login

The `default` profile first uses a locally saved account from **Accounts.cmd**. If there is none, it reuses the token from Hugging Face's normal `HF_TOKEN` environment setting or `hf auth login` credential cache.

**Login.cmd** provides the normal Hugging Face terminal login if you prefer it. That login changes the active Hugging Face account for other tools using the same credential cache. Named profiles in Accounts.cmd let this script choose among accounts without changing that shared login.

Account tokens entered in Accounts.cmd are encrypted with Windows DPAPI for the current Windows user and saved in `accounts.local.json`. They are not written into Lua, job JSON, command lines or image metadata. The account window can delete a profile. Copying an encrypted account file to another Windows user/computer will not make its tokens usable there.

## Rock prompt

The dialog starts with a rock-variation prompt. A shorter alternative:

> Make one new rock from this reference. Change its silhouette, cracks and chipped edges. Keep the same pixel-art style, palette, material, perspective and upper-left lighting. Show one centered, fully visible rock on the same plain background. No text or extra objects.

Each variation uses the original reference, rather than the previous generated result. A seed of `-1` chooses a fresh seed for each image. A fixed seed uses that seed, seed+1, seed+2, etc. Requested seeds and returned seeds when available are recorded in the job results.

## Drawing and output behavior

- Sends the **visible composite of the current frame**. With the selection option enabled, it crops to the selection's bounding rectangle; pixels inside that rectangle are included even if a freehand selection excludes them. Hide unrelated layers before generating.
- Indexed and RGB sources export correctly as an RGB/RGBA reference PNG. The indexed original remains untouched.
- Qwen receives an opaque reference: transparent areas are composited onto **Upload background**, default white (`#ffffff`). Small references can be enlarged with nearest-neighbor before upload.
- **Resize results** uses nearest-neighbor to restore the reference's dimensions. This resizes generated details; it does not guarantee hand-drawn pixel-art quality or identical framing.
- **Match source palette** maps the returned image's RGB colors to the source palette without dithering. Returned alpha is retained. This can help match your game art but may lose subtle model shading.
- Results open in a **new RGB sprite**, one frame per variation. Palette matching restricts the colors while retaining RGB storage. You can export it as a sprite sheet or use the color-reduction script afterward.
- Generated output usually has an opaque background. Background removal is not included, and original transparency is not used as an output mask because a new rock can have a different silhouette.
- Reference images, prompts, downloaded originals and resized PNGs are kept in timestamped subfolders under `jobs/`. Deleting a job folder later removes that local history. Source `.aseprite` documents are not saved or overwritten.

## Compatibility and errors

For Qwen, the bridge calls the cloud Space's `/prepare_request` endpoint before `/infer`, matching the webpage's request sequence. This lets the cloud server cache Civitai-hosted adapters such as Pixel-Art-Refiner before entering the GPU worker. Model and LoRA weights are not downloaded to your PC. If preparation fails, no inference job is submitted. Closing and reopening the launcher restores a valid LoRA if an older saved setting was blank.

The bridge inspects the Space API rather than assuming an argument order. It supports the common `/edit_image`, `/infer`, and `/predict` Qwen endpoints, plus RuinedHugg's `/generate` SDXL endpoint, with either base64-JSON images, a Gallery input, a list of image files, or a single image. It accepts base64 image results, downloaded image files, and image+seed/details results. An endpoint can also be entered explicitly.

Other required API parameters stop the request with an error instead of guessing. The **api-info.json** in the job folder describes the endpoint and can be shared to adapt the script; it does not contain your token. API support is not a guarantee that every Space bearing the Qwen name has the same contract.

Your specific Space's live API was successfully inspected using your locally supplied token. Its `/infer` endpoint accepts the base64 reference, prompt, LoRA, style, seed, randomization flag, guidance, LoRA strength, steps and optional output-resolution setting. The bridge supports those inputs and its image+seed output format. After fixing the preparation sequence, one actual Qwen generation using the reference from a failed user job completed successfully and returned its PNG. Cloud preparation, inference and image download have now been verified end to end.

RuinedHugg's authenticated live API and application source were also inspected. Its generation and model-preparation contracts were validated locally. No SDXL GPU generation was submitted during implementation.

The Space runs on your Hugging Face account's available hardware/quota. This tool does not buy credits, duplicate Spaces or change hardware. Clicking Generate submits the requested number of jobs sequentially. It does not automatically retry failed generations. Cancellation prevents further submissions and requests cancellation of the current queued job; a generation already running on the server may finish. Earlier successful variations are retained and imported if a later request fails.

Aseprite may ask permission to write reference/job files or execute the local helper on first use. Those prompts come from Aseprite's Lua permissions. The helper uses a background Python process so Aseprite remains usable while waiting.

## Verification

Tested the export/import functions in Aseprite 1.3.18.6: indexed colors, selection crop, original-sprite safety, palette extraction, and importing multiple results as frames. Twenty-two offline Python tests cover both backends, Qwen cloud-adapter preparation and failure handling, SDXL image-to-image mode, preparation/LoRA slot mapping, style/strength inputs, exact reference reuse, seed progression, resizing, palette matching, cancellation, partial results, token redaction and DPAPI encryption. The background launcher is checked separately. These tests make no paid generation calls.

The Python test command is `.venv\Scripts\python.exe -m unittest test_bridge.py -v` from this folder. Tests require the companion files from the source folder, which are excluded from the portable release.

References: [Gradio client](https://www.gradio.app/main/docs/python-client/introduction), [public Qwen upstream source](https://huggingface.co/spaces/prithivMLmods/Qwen-Image-Edit-2511-LoRAs-Fast/blob/main/app.py), [Aseprite scripting API](https://www.aseprite.org/api/).
