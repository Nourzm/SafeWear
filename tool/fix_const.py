"""Removes `const` keywords that became invalid after SW tokens turned into
getters. Iterates `dart analyze` until no invalid_constant errors remain."""
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(r"D:\Desktop\SafeWear\safewear")


def get_errors():
    out = subprocess.run(
        ["dart", "analyze", "--format=machine"],
        cwd=ROOT, capture_output=True, text=True, shell=True,
    ).stdout
    errors = []
    for line in out.splitlines():
        parts = line.split("|")
        if len(parts) > 7 and parts[2] in ("INVALID_CONSTANT", "CONST_WITH_NON_CONST",
                                           "CONST_INITIALIZED_WITH_NON_CONSTANT_VALUE",
                                           "NON_CONSTANT_LIST_ELEMENT",
                                           "NON_CONSTANT_MAP_ELEMENT",
                                           "CONST_EVAL_METHOD_INVOCATION",
                                           "NON_CONSTANT_DEFAULT_VALUE"):
            errors.append((parts[3], int(parts[4]), int(parts[5])))
    return errors


def fix_file(path, positions):
    text = Path(path).read_text(encoding="utf-8")
    lines = text.split("\n")
    # Convert (line, col) to absolute offset
    line_starts = [0]
    for ln in lines[:-1]:
        line_starts.append(line_starts[-1] + len(ln) + 1)
    offsets = sorted(
        (line_starts[l - 1] + c - 1 for l, c in positions), reverse=True
    )
    changed = False
    for off in offsets:
        # Find nearest preceding standalone `const` keyword
        region = text[:off]
        m = None
        for m_iter in re.finditer(r"\bconst\s", region):
            m = m_iter
        if m is None:
            continue
        text = text[:m.start()] + text[m.end():]
        changed = True
    if changed:
        Path(path).write_text(text, encoding="utf-8")
    return changed


for iteration in range(8):
    errors = get_errors()
    if not errors:
        print(f"clean after {iteration} iterations")
        sys.exit(0)
    print(f"iteration {iteration}: {len(errors)} errors")
    by_file = defaultdict(list)
    for f, l, c in errors:
        by_file[f].append((l, c))
    for f, positions in by_file.items():
        fix_file(f, positions)

print("WARNING: errors remain after 8 iterations")
errors = get_errors()
for e in errors[:10]:
    print(e)
sys.exit(1)
