import spaces  # MUST come before torch / diffusers (ZeroGPU monkey-patches CUDA)
import torch
import gradio as gr
from diffusers import AutoPipelineForText2Image

BASE_MODEL = "black-forest-labs/FLUX.1-dev"
LORA_REPO = "<owner>/<lora>"   # e.g. ngmediastudio89/perversa
LORA_FILE = "lora.safetensors"

# Load at module scope and .to("cuda") eagerly so ZeroGPU streams weights on first call.
pipe = AutoPipelineForText2Image.from_pretrained(
    BASE_MODEL, torch_dtype=torch.bfloat16
).to("cuda")
pipe.load_lora_weights(LORA_REPO, weight_name=LORA_FILE)
pipe.set_progress_bar_config(disable=True)


@spaces.GPU(duration=120)
def generate(prompt: str, steps: int = 28, seed: int = 42, guidance: float = 3.5):
    """Generate an image from a prompt using the LoRA on FLUX.1-dev.
    Include the LoRA trigger word in the prompt to activate the style."""
    generator = torch.Generator("cuda").manual_seed(int(seed))
    return pipe(
        prompt,
        num_inference_steps=int(steps),
        guidance_scale=float(guidance),
        generator=generator,
        width=1024,
        height=1024,
    ).images[0]


with gr.Blocks(title="LoRA Demo") as demo:
    gr.Markdown("# LoRA demo\nText-to-image on FLUX.1-dev. Include the trigger word in your prompt.")
    with gr.Row():
        with gr.Column():
            prompt = gr.Textbox(label="Prompt", lines=3)
            steps = gr.Slider(1, 50, value=28, step=1, label="Steps")
            seed = gr.Number(value=42, label="Seed", precision=0)
            guidance = gr.Slider(0.0, 10.0, value=3.5, step=0.1, label="Guidance scale")
            btn = gr.Button("Generate", variant="primary")
        with gr.Column():
            out = gr.Image(label="Result", type="pil")
    btn.click(fn=generate, inputs=[prompt, steps, seed, guidance], outputs=out)
    gr.Examples(examples=["PERVERSA, portrait, soft light"], inputs=[prompt], cache_examples=False)

demo.launch(mcp_server=True)
