"""Windows Aseprite -> Hugging Face Gradio bridge. Tokens never enter job files."""
from __future__ import annotations

import argparse
import base64
import ctypes
import io
import json
import os
from pathlib import Path
import random
import re
import time
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parent
ACCOUNTS = ROOT / "accounts.local.json"
DEFAULT_SPACE = "lienthealien/Qwen-Image-Edit-2511-LoRAs-Fast"


def read_json(path):
    return json.loads(Path(path).read_text(encoding="utf-8-sig"))


def atomic_json(path, value):
    path = Path(path)
    temp = path.with_suffix(path.suffix + ".tmp")
    temp.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding="utf-8")
    os.replace(temp, path)


def protect_token(text, decrypt=False):
    """DPAPI binds secrets to this Windows user. Never writes plaintext tokens."""
    if os.name != "nt":
        raise RuntimeError("Account storage requires Windows DPAPI.")
    from ctypes import wintypes

    class Blob(ctypes.Structure):
        _fields_ = [("size", wintypes.DWORD), ("data", ctypes.POINTER(ctypes.c_ubyte))]

    raw = base64.b64decode(text, validate=True) if decrypt else text.encode("utf-8")
    buffer = ctypes.create_string_buffer(raw)
    source = Blob(len(raw), ctypes.cast(buffer, ctypes.POINTER(ctypes.c_ubyte)))
    dest = Blob()
    crypt = ctypes.windll.crypt32
    if decrypt:
        ok = crypt.CryptUnprotectData(ctypes.byref(source), None, None, None, None, 1, ctypes.byref(dest))
    else:
        ok = crypt.CryptProtectData(ctypes.byref(source), ctypes.c_wchar_p("Aseprite Hugging Face"), None, None, None, 1, ctypes.byref(dest))
    if not ok:
        raise ctypes.WinError()
    try:
        value = ctypes.string_at(dest.data, dest.size)
    finally:
        ctypes.windll.kernel32.LocalFree(dest.data)
    return value.decode("utf-8") if decrypt else base64.b64encode(value).decode("ascii")


def load_token(profile):
    accounts = read_json(ACCOUNTS) if ACCOUNTS.exists() else {}
    entry = accounts.get(profile)
    if entry:
        return protect_token(entry["protected_token"], decrypt=True)
    if profile == "default":
        from huggingface_hub import get_token
        return get_token()  # Reuse HF_TOKEN or a previous `hf auth login`.
    raise ValueError(f"Account profile '{profile}' not found. Open Accounts first.")


def normalize_space(space):
    space = space.strip().rstrip("/")
    prefix = "https://huggingface.co/spaces/"
    if space.startswith(prefix):
        space = space[len(prefix):]
    if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", space):
        raise ValueError("Enter a Hugging Face Space as owner/name or its huggingface.co/spaces URL.")
    return space


def endpoint_details(client, requested=""):
    api = client.view_api(return_format="dict", print_info=False)
    endpoints = api.get("named_endpoints", {})
    if requested.strip():
        name = "/" + requested.strip().lstrip("/")
        if name not in endpoints:
            raise ValueError(f"Endpoint {name} not available. Available: {', '.join(endpoints)}")
        return name, endpoints[name], api
    for name in ("/edit_image", "/infer", "/predict", "/generate"):
        if name in endpoints:
            names = {p["parameter_name"] for p in endpoints[name].get("parameters", [])}
            if names & {"images_b64_json", "images", "image", "input_image"}:
                return name, endpoints[name], api
    raise ValueError("No supported image-edit endpoint found. Use Inspect API; enter an endpoint explicitly.")


def enum_values(param):
    schema = param.get("type", {})
    if not isinstance(schema, dict):
        return []
    return schema.get("enum", []) or schema.get("items", {}).get("enum", [])


def is_sdxl(details):
    names = {p["parameter_name"] for p in details.get("parameters", [])}
    return {"model_name", "mode", "input_image", "strength"} <= names


def sdxl_dimensions(image_path):
    from PIL import Image
    with Image.open(image_path) as im:
        scale = 1024 / max(im.size)
        return tuple(max(256, min(1024, int(round(size * scale / 64)) * 64)) for size in im.size)


def make_arguments(details, cfg, image_path, seed, handle_file):
    result = {}
    has_image = False
    sdxl = is_sdxl(details)
    dimensions = sdxl_dimensions(image_path) if sdxl else None
    for p in details.get("parameters", []):
        name = p["parameter_name"]
        if sdxl and name == "mode":
            result[name] = "Image to image"  # Never silently use the server's text-to-image default.
        elif sdxl and name == "model_name":
            selected = cfg.get("model", "Juggernaut XL - Ragnarok")
            if enum_values(p) and selected not in enum_values(p): raise ValueError("Unknown SDXL model: " + str(selected))
            result[name] = selected
        elif sdxl and name == "negative_prompt":
            result[name] = cfg.get("negative_prompt", "text, watermark, blurry, multiple objects")
        elif sdxl and name == "style":
            selected = cfg.get("sdxl_style", "")
            values = [] if selected in ("", "None", "(No style)") else [selected]
            if enum_values(p) and any(v not in enum_values(p) for v in values): raise ValueError("Unknown SDXL style: " + str(selected))
            result[name] = values  # RuinedHugg uses a multiselect, unlike Qwen.
        elif sdxl and name in ("width", "height"):
            result[name] = dimensions[0 if name == "width" else 1]
        elif sdxl and name == "strength":
            value = float(cfg.get("strength", 0.45))
            if not 0 < value <= 1: raise ValueError("SDXL denoising strength must be greater than 0 and at most 1.")
            result[name] = value
        elif sdxl and name == "guidance": result[name] = float(cfg.get("guidance", 7))
        elif sdxl and name == "resize_mode": result[name] = "Pad to fit"
        elif sdxl and name == "use_canny": result[name] = False
        elif sdxl and name == "canny_image": result[name] = None
        elif sdxl and name == "param_20":
            selected = str(cfg.get("sdxl_lora", "None")).strip() or "None"
            if enum_values(p) and selected not in enum_values(p): raise ValueError("Unknown SDXL LoRA: " + selected)
            result[name] = selected
        elif sdxl and name == "param_21": result[name] = float(cfg.get("lora_strength", 0.5))
        elif name == "images_b64_json":
            encoded = base64.b64encode(Path(image_path).read_bytes()).decode("ascii")
            result[name] = json.dumps(["data:image/png;base64," + encoded])
            has_image = True
        elif name in ("image", "input_image"):
            result[name] = handle_file(str(image_path)); has_image = True
        elif name == "images":
            component = str(p.get("component", "")).lower()
            schema = json.dumps(p.get("type", {})).lower()
            item = handle_file(str(image_path))
            result[name] = [{"image": item, "caption": None}] if "gallery" in component or '"caption"' in schema else [item]
            has_image = True
        elif name in ("prompt", "edit_prompt"):
            result[name] = cfg["prompt"]
        elif name in ("lora_adapter", "lora", "adapter"):
            selected = str(cfg.get("lora", "")).strip()
            if not selected:
                raise ValueError("This Space requires a LoRA. Use Inspect API and enter an exact LoRA name; no style is selected automatically.")
            choices = enum_values(p)
            if choices and selected not in choices:
                raise ValueError("LoRA not found. Choices: " + ", ".join(map(str, choices)))
            result[name] = selected
        elif name == "prompt_edit_style":
            style = cfg.get("style", "(No style)")
            choices = enum_values(p)
            if choices and style not in choices: raise ValueError("Unknown style: " + str(style))
            result[name] = style
        elif name == "lora_strength": result[name] = float(cfg.get("lora_strength", 1.0))
        elif name == "seed": result[name] = seed
        elif name == "randomize_seed": result[name] = False
        elif name in ("guidance_scale", "true_cfg_scale"): result[name] = float(cfg.get("guidance", 1.0))
        elif name in ("steps", "num_inference_steps"): result[name] = int(cfg.get("steps", 4))
        elif p.get("parameter_has_default", False):
            pass
        else:
            raise ValueError(f"Unsupported required API input: {name}. Share api-info.json to add support.")
    if not has_image:
        raise ValueError("Endpoint has no supported reference-image input.")
    return result


def make_preflight_arguments(details, generation_args):
    """RuinedHugg's CPU preparation endpoint numbers its LoRA slots differently."""
    result = {}
    for p in details.get("parameters", []):
        name = p["parameter_name"]
        slot = re.fullmatch(r"param_(\d+)", name)
        if slot and 14 <= int(slot[1]) <= 23:
            source = "param_" + str(int(slot[1]) + 6)
            if source in generation_args: result[name] = generation_args[source]
            elif p.get("parameter_has_default"): result[name] = p.get("parameter_default")
            else: raise ValueError("Missing SDXL preparation input: " + name)
        elif name in generation_args: result[name] = generation_args[name]
        elif not p.get("parameter_has_default"): raise ValueError("Unsupported SDXL preparation input: " + name)
    return result


class JobCancelled(Exception):
    pass


def wait_for_job(job, folder, update, label):
    deadline = time.monotonic() + 1200
    while not job.done():
        if (folder / "cancel.request").exists():
            job.cancel()
            raise JobCancelled("Cancellation requested. A job already running remotely may finish.")
        if time.monotonic() > deadline:
            job.cancel()
            raise TimeoutError("Timed out after 20 minutes. The remote job may still run; no retry was submitted.")
        status = job.status()
        code = str(getattr(status, "code", "waiting"))
        rank = getattr(status, "rank", None)
        update("running", f"{label}: {code}" + (f" (queue {rank})" if rank is not None else ""))
        time.sleep(1)
    return job.result()


def extract_image(result):
    """Accept Qwen's base64 dict, Gradio image files, galleries, and image+seed tuples."""
    if isinstance(result, dict):
        if result.get("status") in ("blocked", "error", "failed"):
            raise ValueError(str(result.get("message", "Space rejected this request.")))
        for key in ("image", "output_image", "result", "path", "url"):
            if result.get(key):
                return extract_image(result[key])
    elif isinstance(result, (tuple, list)):
        for item in result:
            if isinstance(item, (dict, list, tuple, str)):
                try:
                    return extract_image(item)
                except ValueError:
                    if isinstance(item, dict) and item.get("status") in ("blocked", "error", "failed"):
                        raise
    elif isinstance(result, str):
        if result.startswith("data:image/"):
            return ("bytes", base64.b64decode(result.split(",", 1)[1], validate=True))
        if len(result) < 4096 and Path(result).is_file():
            return ("file", result)
        if result.startswith("https://"):
            return ("url", result)
    raise ValueError("API returned no supported image. No automatic retry was made.")


def read_result_image(result, client, token):
    from PIL import Image
    kind, value = extract_image(result)
    if kind == "file":
        with Image.open(value) as im: return im.convert("RGBA")
    if kind == "url":
        # Never send an HF token to arbitrary URLs supplied by a remote model.
        source = urlparse(client.src)
        destination = urlparse(value)
        if destination.scheme != "https" or destination.netloc != source.netloc:
            raise ValueError("Remote output URL is outside this Space; expected a downloaded file or same-Space URL.")
        import httpx
        response = httpx.get(value, headers={"Authorization": f"Bearer {token}"} if token else {},
                             follow_redirects=False, timeout=120)
        response.raise_for_status()
        value = response.content
    with Image.open(io.BytesIO(value)) as im: return im.convert("RGBA")


def prepare_reference(input_path, output_path, background, upscale):
    from PIL import Image
    with Image.open(input_path) as src:
        image = src.convert("RGBA")
    rgb = Image.new("RGBA", image.size, background)
    rgb.alpha_composite(image)
    rgb = rgb.convert("RGB")
    if upscale and max(rgb.size) < 768:
        factor = max(1, 768 // max(rgb.size))
        rgb = rgb.resize((rgb.width * factor, rgb.height * factor), Image.Resampling.NEAREST)
    rgb.save(output_path)


def postprocess(image, cfg, reference_size):
    from PIL import Image
    if cfg.get("resize", True):
        image = image.resize(tuple(reference_size), Image.Resampling.NEAREST)
    palette = cfg.get("palette", [])
    if cfg.get("match_palette"):
        if not 1 <= len(palette) <= 256:
            raise ValueError("Palette matching needs 1–256 nontransparent source swatches.")
        alpha = image.getchannel("A")
        swatches = [tuple(c[:3]) for c in palette]
        pal = Image.new("P", (1, 1))
        # Fill unused entries with the first real swatch, never invented black.
        padded = swatches + [swatches[0]] * (256 - len(swatches))
        pal.putpalette([v for c in padded for v in c])
        image = image.convert("RGB").quantize(palette=pal, dither=Image.Dither.NONE).convert("RGBA")
        image.putalpha(alpha)
    return image


def clean_error(exc, token):
    message = str(exc)
    if token: message = message.replace(token, "[redacted]")
    return re.sub(r"hf_[A-Za-z0-9_]+", "[redacted]", message)[:1800]


def run_job(job_path, client_factory=None):
    job_path = Path(job_path).resolve()
    folder = job_path.parent
    status_path = folder / "status.json"
    files = []
    token = None
    def update(state, message, **extra):
        atomic_json(status_path, {"state": state, "message": message, "files": files, **extra})
    try:
        cfg = read_json(job_path)
        update("running", "Loading account and connecting to Space…")
        token = load_token(cfg.get("account", "default"))
        space = normalize_space(cfg.get("space", DEFAULT_SPACE))
        if client_factory is None:
            import inspect
            from gradio_client import Client, handle_file
            token_key = "token" if "token" in inspect.signature(Client).parameters else "hf_token"
            client = Client(space, **{token_key: token}, verbose=False,
                            analytics_enabled=False, download_files=str(folder / "downloads"))
        else:
            client, handle_file = client_factory(space, token)
        name, details, api = endpoint_details(client, cfg.get("endpoint", ""))
        atomic_json(folder / "api-info.json", api)
        loras = []
        for p in details.get("parameters", []):
            if p["parameter_name"] in ("lora_adapter", "lora", "adapter", "param_20"):
                loras = enum_values(p)
        if cfg.get("operation") == "inspect":
            update("complete", f"Connected: {name}. LoRAs: {', '.join(map(str, loras)) or 'see api-info.json'}",
                   endpoint=name, loras=loras, api_info=str(folder / "api-info.json"))
            return
        count = int(cfg.get("count", 1))
        if not 1 <= count <= 8: raise ValueError("Choose 1 to 8 variations.")
        if not str(cfg.get("prompt", "")).strip(): raise ValueError("Enter a variation prompt.")
        steps = int(cfg.get("steps", 4))
        if not 1 <= steps <= 50: raise ValueError("Steps must be 1 to 50.")
        if not 1 <= float(cfg.get("guidance", 1)) <= 10: raise ValueError("Guidance must be 1 to 10.")
        if not 0 <= float(cfg.get("lora_strength", 1)) <= 2: raise ValueError("LoRA strength must be 0 to 2.")
        seed = int(cfg.get("seed", -1))
        if not -1 <= seed <= 2147483647: raise ValueError("Seed must be -1 or 0 to 2147483647.")
        prepared = folder / "reference-upload.png"
        prepare_reference(folder / "input.png", prepared, cfg.get("background", "#ffffff"), cfg.get("upscale", True))
        from PIL import Image
        with Image.open(folder / "input.png") as src: reference_size = src.size
        if "/check_safety" in api.get("named_endpoints", {}):
            safety = client.predict(prompt=cfg["prompt"], api_name="/check_safety")
            if isinstance(safety, dict) and safety.get("status") == "blocked":
                raise ValueError(safety.get("message", "Space rejected the prompt."))
        if is_sdxl(details) and "/fetch_selected_model" in api.get("named_endpoints", {}):
            if (folder / "cancel.request").exists(): raise JobCancelled("Stopped before model preparation.")
            update("running", "Preparing SDXL model and optional LoRA before GPU allocation…")
            generation_args = make_arguments(details, cfg, prepared, max(seed, 0), handle_file)
            preflight_args = make_preflight_arguments(api["named_endpoints"]["/fetch_selected_model"], generation_args)
            wait_for_job(client.submit(api_name="/fetch_selected_model", **preflight_args), folder, update, "Preparing SDXL")
        elif "/prepare_request" in api.get("named_endpoints", {}):
            if (folder / "cancel.request").exists(): raise JobCancelled("Stopped before cloud adapter preparation.")
            update("running", "Cloud Space: preparing the selected adapter before generation…")
            preparation = make_arguments(api["named_endpoints"]["/prepare_request"], cfg, prepared, max(seed, 0), handle_file)
            wait_for_job(client.submit(api_name="/prepare_request", **preparation), folder, update, "Cloud adapter preparation")
        if cfg.get("operation") == "prepare":
            update("complete", "Cloud preparation succeeded. No GPU generation submitted.", endpoint=name)
            return
        for index in range(count):
            cancel = folder / "cancel.request"
            if cancel.exists():
                update("cancelled", "Stopped. No further variations will be submitted."); return
            current_seed = random.SystemRandom().randrange(2147483648) if seed < 0 else (seed + index) % 2147483648
            arguments = make_arguments(details, cfg, prepared, current_seed, handle_file)
            update("running", f"Submitting variation {index+1}/{count} (seed {current_seed})…")
            job = client.submit(api_name=name, **arguments)
            result = wait_for_job(job, folder, update, f"Variation {index+1}/{count}")
            image = read_result_image(result, client, token)
            image = postprocess(image, cfg, reference_size)
            output = folder / f"variation-{index+1:02d}.png"
            image.save(output)
            actual_seed = result.get("seed", current_seed) if isinstance(result, dict) else current_seed
            if isinstance(result, (tuple, list)) and len(result)>1 and isinstance(result[1], (int, float)):
                actual_seed = int(result[1])
            if isinstance(result, (tuple, list)) and len(result)>1 and isinstance(result[1], dict):
                actual_seed = result[1].get("seed", current_seed)
            files.append({"path": str(output), "seed": actual_seed})
            update("running", f"Saved variation {index+1}/{count}.")
        update("complete", f"Finished {len(files)} variations.", endpoint=name)
    except JobCancelled as exc:
        update("cancelled", str(exc))
    except Exception as exc:
        update("error", clean_error(exc, token))


def accounts_window():
    import tkinter as tk
    from tkinter import ttk, messagebox
    root = tk.Tk(); root.title("Aseprite — Hugging Face accounts")
    root.geometry("540x240")
    entries = read_json(ACCOUNTS) if ACCOUNTS.exists() else {}
    ttk.Label(root, text="Save a token locally for each account. Choose its profile name in Aseprite.", wraplength=500).pack(padx=15, pady=12)
    row=ttk.Frame(root);row.pack(fill="x",padx=15)
    ttk.Label(row,text="Profile name:").pack(side="left")
    name=ttk.Combobox(row,values=sorted(entries),width=35);name.set("default");name.pack(side="right")
    row=ttk.Frame(root);row.pack(fill="x",padx=15,pady=10)
    ttk.Label(row,text="Hugging Face token:").pack(side="left")
    token=ttk.Entry(row,show="•",width=38);token.pack(side="right")
    ttk.Label(root,text="Tokens are encrypted for this Windows user with DPAPI.\nUse a token authorized to access your Space. Never share it in chat.").pack(padx=15,pady=8)
    def save():
        try:
            profile=name.get().strip();secret=token.get().strip()
            if not re.fullmatch(r"[A-Za-z0-9_-]{1,40}",profile): raise ValueError("Use 1–40 letters, digits, underscores or hyphens for the profile.")
            if not secret.startswith("hf_"): raise ValueError("Enter a Hugging Face access token beginning hf_.")
            entries[profile]={"protected_token":protect_token(secret)}
            atomic_json(ACCOUNTS,entries);token.delete(0,tk.END)
            name.configure(values=sorted(entries))
            messagebox.showinfo("Saved",f"Account '{profile}' saved. Enter that profile name in Aseprite.")
        except Exception as exc: messagebox.showerror("Account setup",str(exc))
    def delete():
        profile=name.get().strip()
        if profile in entries:
            del entries[profile];atomic_json(ACCOUNTS,entries);name.configure(values=sorted(entries));token.delete(0,tk.END)
    row=ttk.Frame(root);row.pack(pady=8)
    ttk.Button(row,text="Save account",command=save).pack(side="left",padx=5)
    ttk.Button(row,text="Delete selected profile",command=delete).pack(side="left",padx=5)
    ttk.Button(row,text="Close",command=root.destroy).pack(side="left",padx=5)
    root.mainloop()


if __name__ == "__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("--job",type=Path)
    parser.add_argument("--accounts",action="store_true")
    args=parser.parse_args()
    if args.accounts: accounts_window()
    elif args.job: run_job(args.job)
    else: parser.error("Choose --accounts or --job path")
