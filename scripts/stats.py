"""统计真题：每个题型有哪些题、多少分。用法：uv run scripts/stats.py [--list]"""
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ITEM = re.compile(r'\(\s*no:\s*"([^"]+)"(.*?)topic:\s*"([^"]+)"', re.S)
SCORE = re.compile(r'score:\s*(\d+)')


def load():
    out = []
    for f in sorted((ROOT / "data/exams").glob("*.typ")):
        if f.stem.startswith("_"):
            continue
        for m in ITEM.finditer(f.read_text(encoding="utf-8")):
            s = SCORE.search(m.group(2))
            out.append((f.stem, m.group(1), int(s.group(1)) if s else None, m.group(3)))
    return out


def main():
    items = load()
    by = defaultdict(list)
    for e, no, sc, t in items:
        by[t].append((e, no, sc))
    exams = sorted({e for e, *_ in items})
    print(f"{len(exams)} 套卷子，{len(items)} 题")
    for t in sorted(by, key=lambda k: (k.startswith("x-"), k)):
        qs = by[t]
        pts = sum(s or 0 for _, _, s in qs)
        print(f"{t:16s} {len(qs):3d} 题 {pts:4d} 分  " + ("  ".join(f"{e}:{n}" for e, n, _ in qs) if "--list" in sys.argv else ""))
    for e in exams:
        tot = sum(s or 0 for x, _, s, _ in items if x == e)
        print(f"  {e}: {sum(1 for x, *_ in items if x == e)} 题, 合计 {tot} 分")


if __name__ == "__main__":
    main()
