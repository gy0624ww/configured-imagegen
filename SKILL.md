---
name: configured-imagegen
description: Generate or edit raster images through the user's configured OpenAI-compatible provider. Use when a user requests image generation or editing and native image_gen is unavailable, or when the user explicitly asks to use the provider configured in ~/.codex/config.toml.
---

# Configured Image Generation

Use the native `image_gen` tool first when it is available. It has the best desktop integration and does not require credentials from configuration.

When native `image_gen` is unavailable, use the bundled wrapper. It reads only `model_providers.OpenAI.base_url` and `experimental_bearer_token` from `~/.codex/config.toml`, exposes them only to its child process as `OPENAI_BASE_URL` and `OPENAI_API_KEY`, and then invokes the bundled GPT Image CLI with the skill's isolated, current OpenAI SDK environment.

If the wrapper reports that its Python environment is missing, bootstrap it once with `scripts/setup_imagegen_env.sh`. Do not install dependencies into the system Python environment.

```bash
"$HOME/.codex/skills/configured-imagegen/scripts/run_imagegen.sh" generate \
  --prompt "<structured image prompt>" \
  --out "<workspace delivery path>.png"
```

The wrapper explicitly selects `gpt-image-2` unless a caller supplies `--model` or deliberately sets `CODEX_IMAGEGEN_MODEL` to a verified newer compatible GPT Image model. Pass `edit` and its normal GPT Image CLI arguments for image edits. Keep image prompts and output paths appropriate to the user request. Do not print, copy, persist, or ask the user for the configured token.

Before final delivery, inspect the resulting image and report the saved path. The wrapper returns a clear error if the compatible-provider configuration is missing.
