# AGENTS.md

Guidelines for AI agents (and humans) working in this repository.

## Commit messages

Commit messages must follow this style:

```
[component] Short imperative name

mistral session: <mistral vibe session>
```

Examples:

```
[kanata] Add feature

mistral session: <mistral vibe session>
```

```
[emacs] Set theme

- theme was nn now it's bb
- use the plugin whatever because the plugin whatnot is not available

mistral session: <mistral vibe session 2>
```

Rules:

- Subject: `[component]` in square brackets followed by a short, imperative name.
- Keep the name short.
- Only add bullet points in the body if really needed; omit them otherwise.
- End with a `mistral session:` trailer line identifying the Mistral Vibe
  session that produced the commit. The desktop app identifies sessions by
  name in the sidebar (IDs are not shown in the UI), so prefer the session
  name; use the session ID if the name is unknown.
- Squash work into a single commit per logical change before pushing.
