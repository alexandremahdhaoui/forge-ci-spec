#!/bin/sh
set -eu

exec uv run --quiet --with jsonschema --with pyyaml python3 - "$@" <<'PY'
import json
import sys

import yaml
from jsonschema import Draft202012Validator

schema = yaml.safe_load(open("spec/forge-ci.v1.yaml"))
cases = json.load(open("testdata/cases.json"))
validator = Draft202012Validator(schema)

failures = []
checked = 0
deferred = 0


def errors_for(doc):
    return [e.message + " at " + "/".join(str(p) for p in e.absolute_path)
            for e in validator.iter_errors(doc)]


for c in cases["valid"]:
    checked += 1
    errs = errors_for(c["doc"])
    if errs:
        failures.append("valid/%s must pass the schema but got: %s" % (c["case"], errs[0]))

for c in cases["invalid"]:
    checked += 1
    errs = errors_for(c["doc"])
    if c.get("semantic"):
        deferred += 1
        if errs:
            failures.append(
                "invalid/%s is marked semantic so it must PASS the schema and fail "
                "only in forge-ci, but the schema rejected it: %s" % (c["case"], errs[0]))
        continue
    if not errs:
        failures.append("invalid/%s must fail the schema and did not" % c["case"])

for f in failures:
    print("FAIL " + f, file=sys.stderr)

print("checked %d vectors, %d deferred to the forge-ci validator" % (checked, deferred))

if failures:
    sys.exit(1)

print("schema and vectors agree")
PY
