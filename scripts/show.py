"""打印某个题型的全部真题题干（Typst 源码）。用法：uv run scripts/show.py simplex lp-basic"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def items(text):
    """按 (no: ... body: [ ... ]) 切出每一项，方括号配对。"""
    for m in re.finditer(r'\(\s*no:\s*"([^"]+)"(.*?)topic:\s*"([^"]+)"', text, re.S):
        start = text.find("body:", m.end())
        i = text.find("[", start)
        depth, j = 0, i
        while j < len(text):
            c = text[j]
            if c == "\\":
                j += 2
                continue
            if c == "[":
                depth += 1
            elif c == "]":
                depth -= 1
                if depth == 0:
                    break
            j += 1
        yield m.group(1), m.group(3), m.group(2), text[i + 1 : j].strip()


def main():
    want = set(sys.argv[1:])
    for f in sorted((ROOT / "data/exams").glob("2*.typ")):
        t = f.read_text(encoding="utf-8")
        for no, topic, mid, body in items(t):
            if topic in want:
                sc = re.search(r"score:\s*(\d+)", mid)
                print(f"===== {f.stem} {no} [{topic}] {sc.group(1) + '分' if sc else ''}")
                print(body)


if __name__ == "__main__":
    main()
