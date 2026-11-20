#!/usr/bin/env python3
"""Run the Colab notebook's verification and search code from a Linux shell."""
import argparse
import json
import os
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
NOTEBOOK = ROOT / "notebooks" / "Verified_RTL_Optimization_Reinforcement_Learning.ipynb"
BENCHMARKS = ("alu", "multiplier", "shifter", "counter", "arbiter", "fifo")
PROFILES = {
    "smoke": (1, 1, (1,)),
    "seed1": (5, 1, (1,)),
    "seed2": (5, 5, (2,)),
}


def positive_int(value):
    parsed = int(value)
    if parsed < 1:
        raise argparse.ArgumentTypeError("expected a positive integer")
    return parsed


def initialize(args):
    work = args.work_dir.resolve()
    if work == ROOT / "results" or ROOT / "results" in work.parents:
        raise SystemExit("Choose a work directory outside the checked-in results.")
    project = work / "project"
    os.environ.update(
        RTL_PROJECT=str(project),
        RTL_OTHER_PROJECT=str(work / "other"),
        RTL_RUNTIME=str(work / "runtime"),
    )
    if args.liberty:
        source = args.liberty.resolve()
        if not source.is_file():
            raise SystemExit(f"Liberty file not found: {source}")
        target = project / "scripts" / "NangateOpenCellLibrary_typical.lib"
        target.parent.mkdir(parents=True, exist_ok=True)
        if source != target:
            shutil.copyfile(source, target)
    namespace = {"__name__": "__main__"}
    for i, cell in enumerate(json.loads(NOTEBOOK.read_bytes())["cells"], 1):
        tags = cell["metadata"].get("tags", [])
        if cell["cell_type"] != "code" or "interactive" in tags:
            continue
        exec(compile("".join(cell["source"]), f"{NOTEBOOK.name}:cell-{i}", "exec"), namespace)
        if "configuration" in tags:
            namespace.update(MODEL_KEY=args.model, RUN_TAG=args.run_tag)
    return namespace


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profile", choices=("smoke", "seed1", "seed2", "both"), default="smoke")
    parser.add_argument("--benchmarks", nargs="+", choices=BENCHMARKS, default=list(BENCHMARKS))
    parser.add_argument("--work-dir", type=Path, default=ROOT / "work")
    parser.add_argument("--liberty", type=Path, help="Path to a local Nangate45 typical Liberty file")
    parser.add_argument("--run-tag", default="default", help="Change to start an independent run")
    parser.add_argument("--workers", type=positive_int, default=1)
    parser.add_argument("--model", choices=("coder_7b", "qwen3_8b", "coder_14b", "codev_r1"))
    parser.add_argument("--random-control", action="store_true")
    parser.add_argument("--preflight-only", action="store_true")
    args = parser.parse_args()
    if args.model and args.workers != 1:
        parser.error("model-guided runs require --workers 1")
    if len(set(args.benchmarks)) != len(args.benchmarks):
        parser.error("--benchmarks must not contain duplicates")

    flow = initialize(args)
    blocked = set(args.benchmarks) - set(flow["READY_BENCHMARKS"])
    if blocked:
        raise SystemExit(f"Reference preflight failed for: {', '.join(sorted(blocked))}")
    if args.preflight_only:
        return

    profiles = ("seed1", "seed2") if args.profile == "both" else (args.profile,)
    for profile in profiles:
        episodes, horizon, seeds = PROFILES[profile]
        flow["run_rl_batch"](
            args.benchmarks, episodes, horizon, seeds,
            random_control=args.random_control, model_key=args.model, workers=args.workers,
        )
    flow["comparison_report"](make_plot=False)
    print(f"Results: {flow['OUTPUT']}")


if __name__ == "__main__":
    main()
