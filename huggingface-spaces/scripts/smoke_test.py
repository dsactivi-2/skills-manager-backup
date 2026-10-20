#!/usr/bin/env python3
"""Smoke test for a Hugging Face Gradio + ZeroGPU text-to-image Space.

Run from a venv that has `gradio_client` installed (kept OUTSIDE the Space dir):
    python smoke_test.py <ns>/<name>

Connects to the Space, prints view_api(), runs one generation, and asserts the
returned file's first 8 bytes are the PNG magic number. Override inputs via env:
    SMOKE_PROMPT, SMOKE_API, SMOKE_STEPS, SMOKE_SEED, SMOKE_GUIDANCE.
"""
import os
import sys

from gradio_client import Client

PNG_MAGIC = b"\x89PNG\r\n\x1a\n"


def main(repo_id: str) -> None:
    tok = open(os.path.expanduser("~/.cache/huggingface/token")).read().strip()
    client = Client(
        repo_id,
        token=tok,
        download_files=True,
        httpx_kwargs={"timeout": 600},
    )

    print("=== view_api ===")
    try:
        print(client.view_api())
    except Exception as e:  # noqa: BLE001
        print("view_api err:", e)

    # Neutral prompt by default; a LoRA only triggers if its trigger word is present.
    prompt = os.environ.get("SMOKE_PROMPT", "a photo of a cat, high quality")
    api_name = os.environ.get("SMOKE_API", "/generate")
    steps = int(os.environ.get("SMOKE_STEPS", "28"))
    seed = int(os.environ.get("SMOKE_SEED", "42"))
    guidance = float(os.environ.get("SMOKE_GUIDANCE", "3.5"))

    try:
        result = client.predict(prompt, steps, seed, guidance, api_name=api_name)
        with open(result, "rb") as fh:
            head = fh.read(8)
        print("result:", result)
        print("magic bytes:", head)
        if head == PNG_MAGIC:
            print("OK: valid PNG generated")
        else:
            print("WARN: output is not a PNG:", head)
            sys.exit(1)
    except Exception as e:  # noqa: BLE001
        print("predict ERROR:", type(e).__name__, e)
        sys.exit(1)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("usage: python smoke_test.py <ns>/<name>")
        sys.exit(2)
    main(sys.argv[1])
