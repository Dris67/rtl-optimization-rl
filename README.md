# Verified RTL Optimization with Reinforcement Learning

This project searches for equivalent RTL implementations with lower area-delay product (ADP). The agent starts from a reference design each episode and uses tabular Q-learning to select module-specific or Yosys rewrite actions. Icarus Verilog checks simulated behavior, the interface check enforces compatibility, and EQY checks equivalence. Yosys/ABC maps candidates to Nangate45 and OpenSTA measures timing. The flow ranks verified candidates by ADP, with a maximum 5% increase in either area or delay relative to the reference.

The six benchmarks are an ALU, arbiter, counter, FIFO, multiplier and shifter. CPU-only Q-learning is the default and requires no training dataset. The notebook also supports a matched random-policy control and an optional GPU model that ranks actions during search.

## Run in Google Colab

1. Upload [the repository notebook](notebooks/Verified_RTL_Optimization_Reinforcement_Learning.ipynb) to Colab. The [RL Colab](https://colab.research.google.com/drive/1UxbkrykEh-UbKTqe44F_Wj1L2Bw9aIWK#scrollTo=rtl-13) is also available to accounts with access.
2. Select **Runtime → Run all** to run the default Seed 2 experiment. Set the runtime hardware accelerator to **None** for CPU-only runs. When prompted, mount Google Drive. Setup installs missing tools and runs reference preflight before the search.
3. To reproduce Seed 1, change the experiment cell to `EPISODES = 5`, `HORIZON = 1` and `SEEDS = (1,)` before running it. Seed 2 uses `EPISODES = 5`, `HORIZON = 5` and `SEEDS = (2,)`. For a smaller run, set `MODULES = ("shifter",)` and use one episode and one step.
4. Open `MyDrive/rtl_opt_rl_project/results/verified_rtl_v4/rl/` to inspect the new logs. Use the same `RUN_TAG` and settings to resume. Change the tag to start an independent run with the same settings.

The repository notebook retains the experiment's reference bytes, parameters and search logic. It includes a checksum-verified OpenSTA setup cell for Colab and omits saved cell outputs. The Linux runner uses the OpenSTA installation on your PATH. The archived results remain separately browsable with no Colab or CAD tools.

## Run locally on Linux

Install Python 3.10 or newer, Git, curl, the [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build) and standalone [OpenSTA](https://github.com/The-OpenROAD-Project/OpenSTA). Add `yosys`, `yosys-abc`, `iverilog`, `vvp`, `eqy`, `sby` and `sta` to `PATH`. On distributions that package it, `sudo apt-get install opensta` installs `sta`. The experiment uses the [2026-11-17 OSS CAD Suite release](https://github.com/YosysHQ/oss-cad-suite-build/releases/tag/2026-11-17) and OpenSTA reporting version 2.0.17. Exact flags, tool versions, and the Liberty SHA-256 are in [measurement.json](results/shared-drive/baselines/26b6a5e39af193da/measurement.json).

Run these commands from the repository root. Adjust the CAD Suite path to your installation location.

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
source /path/to/oss-cad-suite/environment
python scripts/run.py --profile smoke
```

The smoke profile runs preflight for all six references and one optimization attempt per selected benchmark. Run `python scripts/run.py --help` for options. The runner uses the notebook's implementation and writes new results under `work/project/results/verified_rtl_v4/rl/`. It downloads the Nangate45 typical Liberty file from [OpenROAD-flow-scripts](https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts/tree/master/flow/platforms/nangate45) if it is missing. If you already have the exact file, pass `--liberty /path/to/NangateOpenCellLibrary_typical.lib`.

| Profile | Seed | Episodes per module | Max rewrite steps per episode |
|---|---:|---:|---:|
| `smoke` | 1 | 1 | 1 |
| `seed1` | 1 | 5 | 1 |
| `seed2` | 2 | 5 | 5 |
| `both` | 1, then 2 | 5 each | 1, then 5 |

```bash
# Run both archived experiment configurations on all benchmarks
python scripts/run.py --profile both --work-dir work/reproduction

# Run Seed 2 for one benchmark with a separate matched random control
python scripts/run.py --profile seed2 --benchmarks shifter --random-control --work-dir work/shifter-control

# Summarize the archived results or a new run
python scripts/summarize.py
python scripts/summarize.py work/reproduction/project/results/verified_rtl_v4/rl/attempts.csv
```

A run can finish with fewer attempts if it exhausts its valid actions. Formal proof or timing differences between environments can change the search trajectory. Reuse the work directory, measurement setup and flags to resume an interrupted experiment. Use `--workers` to run different benchmarks concurrently and use a single process per work directory. GPU model runs require CUDA PyTorch and the model dependencies listed in the notebook. They use one worker. The packaged experimental results use CPU-only Q-learning with the random control disabled.

## Recorded results

| Run | Attempts | No-ops | Simulation passes | Formal proof passes |
|---|---:|---:|---:|---:|
| Seed 1 | 30 | 0 | 30 | 30 |
| Seed 2 | 148 | 11 | 137 | 136 |
| Combined | 178 | 11 | 167 | 166 |

The 166 formal passes cover 71 distinct RTL sources across the two seeds. One FIFO attempt timed out in formal checking. A later attempt proved the same source. The best eligible ADP reductions were 70.67% for the multiplier, 31.65% for the ALU and 15.10% for the FIFO. The archived runs measure pre-layout area and timing. A matched random comparison is needed to measure any advantage of Q-learning over random search.

### Find the results

- [All attempts](results/shared-drive/attempts.csv), [per-benchmark counts](results/shared-drive/pass_rates.csv), [failures](results/shared-drive/failures.csv), [no-ops](results/shared-drive/no_change.csv) and [comparison by run](results/shared-drive/comparison_by_run.csv).
- [Best eligible candidates](results/shared-drive/best_verified.csv), [all measured improvements](results/shared-drive/adp_improvements.csv), [verified eligible improvements](results/shared-drive/verified_improvements.csv) and [the original ADP comparison plot](results/shared-drive/verified_adp_comparison.png).
- [Reference RTL and provenance](results/shared-drive/references/), [baseline checks](results/shared-drive/baseline_checks.csv), [configuration and negative control](results/shared-drive/baselines/26b6a5e39af193da/) and [run artifacts](results/shared-drive/runs/).

The results snapshot preserves the shared-drive exports and original Colab paths in those exports. To find local RTL or a run record, use the `experiment_id` folder and the final path component of `attempt_id` beneath `results/shared-drive/runs/`. The [source folder](https://drive.google.com/drive/folders/1aex9Kz00KK_i65ytqgVoRObSsZyAq6G1) contains the nested tool work directories, including detailed simulator, equivalence and mapping logs. Access to that folder requires an authorized Drive account.

RTLLM-derived RTL comes from the [pinned upstream revision](https://github.com/hkust-zhiyao/RTLLM/tree/51ed553d0ffd32797a1a0a13e051656bf302c81f). The upstream MIT notice is provided in [LICENSE-RTLLM](LICENSE-RTLLM).

## Local verification

The CPU smoke test passed simulation and formal checks on all six benchmarks, and a second invocation resumed without duplicating attempts. A Seed 1 replay reproduced all 20 recorded actions, candidate hashes and ADP values across the ALU, arbiter, counter and shifter.
