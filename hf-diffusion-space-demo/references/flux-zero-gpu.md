# FLUX LoRA on ZeroGPU

## Why ZeroGPU large (zero-a10g)
FLUX.1-dev in bf16 is ~24 GB. ZeroGPU `large` is a 48 GB MIG (RTX PRO 6000 Blackwell) — fits with headroom. `xlarge` (96 GB, 2× quota) only if you fuse/merge multiple LoRAs or raise resolution a lot. Free personal accounts can host up to 2 ZeroGPU Spaces; everything else (cpu-basic, dedicated GPU) needs a paid plan.

## Duration
single 1024×1024 image, 28 flowmatch steps ≈ 20–40 s on this GPU. Set `@spaces.GPU(duration=120)` to cover cold model-stream + first render; smaller = higher queue priority but risks a timeout on the first call.

## dtype / params
- `torch_dtype=torch.bfloat16` (matches the trainer config `dtype: bf16`).
- `guidance_scale=3.5`, `num_inference_steps=28` are the trainer's sample defaults (flowmatch sampler). Don't use SDXL-style 7.5 guidance.
- Generation size 1024×1024 (trainer resolution family 512/768/1024).

## Gated base model
`black-forest-labs/FLUX.1-dev` is gated. The Space runtime uses the creator's HF token and inherits accepted licenses. If that account hasn't accepted the FLUX.1-dev license, the `from_pretrained` download fails at build. Fix: accept the license on the pushing account, or pass an `HF_TOKEN` secret from an account that has.

## Loading the LoRA
Repo has raw `lora.safetensors` (Kohya-style `config.yaml`, not a diffusers adapter config). Load with:
```python
pipe = AutoPipelineForText2Image.from_pretrained("black-forest-labs/FLUX.1-dev", torch_dtype=torch.bfloat16).to("cuda")
pipe.load_lora_weights("<owner>/<repo>", weight_name="lora.safetensors")
```
`weight_name` is required because the repo isn't a diffusers-formatted adapter dir.

## Cold start
The 24 GB base download + compile happens once; `startup_duration_timeout: 1h` in the README frontmatter prevents the build from being killed. Subsequent boots reuse the packed weights.
