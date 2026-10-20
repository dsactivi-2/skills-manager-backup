import spaces  # MUST be first import (before torch/diffusers) for ZeroGPU
import torch
import gradio as gr
from diffusers import AutoPipelineForText2Image

# Edit these for the target model/LoRA.
BASE_MODEL = "black-forest-labs/FLUX.1-dev"
LORA_REPO = "<owner>/<lora-repo>"
LORA_FILE = "lora.safetensors"
TRIGGER = "<TRIGGER_WORD>"  # include in prompt to activate the LoRA

# Load at module scope and .to("cuda") eagerly so ZeroGPU streams weights on first call.
pipe = AutoPipelineForText2Image.from_pretrained(
    BASE_MODEL, torch_dtype=torch.bfloat16
).to("cuda")
pipe.load_lora_weights(LORA_REPO, weight_name=LORA_FILE)
pipe.set_progress_bar_config(disable=True)


@spaces.GPU(duration=120)
def generate(
    prompt: str,
    steps: int = 28,
    seed: int = 42,
    guidance: float = 3.5,
) -> "PIL.Image.Image":
    """Generate an image from a text prompt using the LoRA on the base model.

    Include the trigger word in the prompt to activate the LoRA style.
    """
    generator = torch.Generator("cuda").manual_seed(int(seed))
    image = pipe(
        prompt,
        num_inference_steps=int(steps),
        guidance_scale=float(guidance),
        generator=generator,
        width=1024,
        height=1024,
    ).images[0]
    return image


EXAMPLES = [
    [f"{TRIGGER}, portrait, soft studio light, detailed, 4k"],
    [f"{TRIGGER}, full body shot, cinematic lighting, highly detailed"],
]


with gr.Blocks(title=f"{TRIGGER} LoRA Demo") as demo:
    gr.Markdown(
        f"# {TRIGGER} — FLUX.1-dev LoRA demo\n"
        f"Text-to-image using `{LORA_REPO}` on `{BASE_MODEL}`.\n\n"
        f"**Include the trigger word `{TRIGGER}` in your prompt.**"
    )
    with gr.Row():
        with gr.Column():
            prompt = gr.Textbox(
                label="Prompt",
                lines=3,
                placeholder=f"{TRIGGER}, a portrait, soft light …",
            )
            steps = gr.Slider(1, 50, value=28, step=1, label="Steps")
            seed = gr.Number(value=42, label="Seed", precision=0)
            guidance = gr.Slider(0.0, 10.0, value=3.5, step=0.1, label="Guidance scale")
            btn = gr.Button("Generate", variant="primary")
        with gr.Column():
            out = gr.Image(label="Result", type="pil")
    btn.click(fn=generate, inputs=[prompt, steps, seed, guidance], outputs=out)
    gr.Examples(examples=EXAMPLES, inputs=[prompt], cache_examples=False)

demo.launch(mcp_server=True)
