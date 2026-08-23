# CLAUDE.md

This repo owns the forge-ci pipeline schema. Change it and you change every
forge-ci engine.

Read ~/.claude/CLAUDE.md first. Those rules apply here.

## The vectors are the contract

`testdata/cases.json` is what an implementation is tested against. Adding a rule
to the schema without adding a vector means nothing checks it.

Every invalid vector carries the substring its error must contain. Match on the
substring, never on the whole message.

## Semantic vectors must pass the schema

A vector marked `semantic: true` is a cross reference check. JSON Schema cannot
express it, so forge-ci does it in a second pass.

`hack/validate.sh` asserts that a semantic vector passes the schema. If the
schema rejects it, the schema grew a rule it should not have.

## Naming follows forge

forge parses yaml through `sigs.k8s.io/yaml`, so `json:` tags decide the key
names. The conventions are not ours to pick.

| Thing | Style | Example |
|---|---|---|
| Keys | lowerCamelCase | `artifactStorePath` |
| Enum values | kebab-case | `type: compute` |
| Aliases | kebab-case | `all-pass` |
| Engine URIs | `forge://` or `alias://` only | anything else is a hard error |

## forge-ci rejects unknown keys and forge does not

forge silently drops a top level key it does not know. We do not. A typo in a
pipeline file is a bug you want reported, not swallowed.

That is a deliberate divergence. There is a vector for it.
