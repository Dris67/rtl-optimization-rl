#!/usr/bin/env python3
"""Print attempt-level verification and the best eligible ADP gain per seed."""
import argparse
import csv
from pathlib import Path

DEFAULT = Path(__file__).resolve().parents[1] / "results" / "shared-drive" / "attempts.csv"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("attempts", type=Path, nargs="?", default=DEFAULT)
    args = parser.parse_args()
    with args.attempts.open(newline="", encoding="utf-8") as file:
        rows = list(csv.DictReader(file))
    if not rows:
        parser.error("attempts CSV contains no rows")

    print("Seed  Attempts  No change  Simulation pass  Formal pass  Unique verified")
    for seed in sorted({int(row["seed"]) for row in rows}):
        print_counts(str(seed), [row for row in rows if int(row["seed"]) == seed])
    print_counts("All", rows)
    print("\nBest eligible ADP reduction (%)")
    runs = sorted({(int(row["seed"]), row["benchmark"]) for row in rows})
    for seed, benchmark in runs:
        gains = [
            float(row["adp_improvement_pct"]) for row in rows
            if int(row["seed"]) == seed and row["benchmark"] == benchmark
            and row["competition_eligible"].lower() == "true"
        ]
        print(f"{seed:4}  {benchmark:12}  {f'{max(gains):.3f}%' if gains else '—'}")


def print_counts(label, rows):
    no_changes = sum(row["status"] == "NO_CHANGE" for row in rows)
    simulated = sum(row["simulation"] == "PASS" for row in rows)
    proved = [row for row in rows if row["formal"] == "PASS"]
    distinct = {(row["benchmark"], row["source_sha256"]) for row in proved}
    print(f"{label:>4}  {len(rows):8}  {no_changes:9}  {simulated:15}  {len(proved):11}  {len(distinct):15}")


if __name__ == "__main__":
    main()
