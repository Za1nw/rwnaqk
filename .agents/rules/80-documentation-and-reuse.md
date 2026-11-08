---
trigger: model_decision
description: "Use when creating reusable Flutter components, shared GetX helpers, networking libraries, repository contracts, modules, or project architecture documentation."
---
# Practical documentation without noise

- Document reusable modules in the nearest existing documentation location; create `docs/` only if the project has no documented convention and the abstraction genuinely warrants it.
- For reusable business/data components, document purpose, inputs/outputs, dependency boundaries, example usage, error states, and lifecycle/cleanup where relevant.
- Keep API contracts distinct from UI contracts. Note whether a Laravel endpoint is verified or proposed, and provide example sanitized payloads only when based on the actual backend.
- Document which feature owns cart/session/shared state, which events invalidate caches, and which parts still depend on GetX.
- For any future migration plan, classify code as `reusable unchanged`, `presentation replacement required`, or `requires coordinated backend change`. Do not claim universal automated conversion.
- Avoid generated wall-of-text comments, redundant READMEs, and documentation-only changes during urgent release tasks unless requested.
