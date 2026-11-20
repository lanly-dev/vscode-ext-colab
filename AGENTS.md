# AGENTS.md

Test bench for pairs of VS Code extensions that invoke each other's commands.
This repo holds **no extension code** — only workspace wiring
(`ext-colab.code-workspace`), scenario checklists (`scenarios/`), and small
generated fixtures (`fixtures/`).

Rules:

- Member extensions live in **sibling clones**; reference them with relative
  paths only. No absolute local paths anywhere in this repo (it is public).
- Cross-extension calls need both extensions in **one** extension host — every
  launch configuration must pass one `--extensionDevelopmentPath` per member.
- When a cross-extension contract changes (command id, arguments, version
  gate), update the pair's scenario checklist in the same change.
- Fixtures are generated, tiny, and synthetic (tones/silence). No real media.
