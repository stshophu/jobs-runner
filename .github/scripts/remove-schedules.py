"""Remove `schedule:` triggers from all workflow files in .github/workflows
(except the one-off migration file). Keeps workflow_dispatch so the jobs can
still be started by hand. Usage: python3 remove-schedules.py <repo-dir>"""
import glob, os, re, sys

root = sys.argv[1] if len(sys.argv) > 1 else "."
changed = 0
for path in glob.glob(os.path.join(root, ".github/workflows/*.y*ml")):
    if os.path.basename(path).startswith("migrate-out"):
        continue
    lines = open(path).read().split("\n")
    out, in_on, skip = [], False, False
    for line in lines:
        if re.match(r"^on:\s*$", line):
            in_on = True; out.append(line); continue
        if in_on and re.match(r"^\S", line):
            in_on = False
        if in_on:
            m = re.match(r"^  (\w+):", line)
            if m:
                skip = m.group(1) == "schedule"
                if skip:
                    out.append("  # schedule moved to the public runner stshophu/viterbo-runner")
                    continue
            elif skip and (line.startswith("    ") or line.strip().startswith("#")):
                continue
            else:
                skip = False
        out.append(line)
    new = "\n".join(out)
    if re.search(r"(?m)^on:\s*\n(\s*#.*\n)*(?=\S|\Z)", new):          # nothing left under on:
        new = re.sub(r"(?m)^on:\s*\n", "on:\n  workflow_dispatch:\n", new, count=1)
    if new != "\n".join(lines):
        open(path, "w").write(new); changed += 1
        print("removed schedule:", os.path.basename(path))
print(f"{changed} workflow file(s) changed")
