# forge-ci-spec

This repo owns the forge-ci pipeline schema and its conformance vectors.

## What is here

| Path | Holds |
|---|---|
| `spec/forge-ci.v1.yaml` | The pipeline schema. JSON Schema draft 2020-12. |
| `testdata/cases.json` | Conformance vectors. Valid documents and invalid ones. |
| `hack/validate.sh` | Checks the schema and the vectors agree. |

## The split between schema and validator

The schema catches shape. A missing key, a bad enum value, an alias that is not
kebab-case.

The schema cannot catch a cross reference. `state: st` is well formed even when
no engine is called `st`. So forge-ci runs a second pass.

A vector marked `semantic: true` must **pass** the schema and **fail** in
forge-ci. `hack/validate.sh` asserts both halves. A semantic vector that the
schema rejects is a bug in the schema, not a passing test.

## Running the gate

```sh
forge test-all
```
