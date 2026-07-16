# Instructor Notes — BTIP Workflow Orchestration Managers

## How to Frame This Session

The interns are in their final 2 weeks — they've been running fastp, spades, and quast for several weeks and are starting to write up results. Use this framing:

1. **Start with what they already know:** "You've all run fastp. You've run spades. You've run quast. You know these tools individually."

2. **Name the pain point:** "Now you're writing up your results for a manuscript. How do you document all the parameter sweeps you ran? If a reviewer asks you to vary k-mer size from 21 to 33 to 55 — can they reproduce your analysis?"

3. **Pitch the solution:** "This session is about turning your ad-hoc tool runs into a publication-ready, reproducible workflow. A single repo that anyone can clone and re-run — bash, Snakemake, or Nextflow."

4. **Bridge to prior talks:** "Glee covered Git basics. Today we pick up where that left off — making your pipeline code version-controlled and reproducible at scale."

5. **Stay objective:** Don't oversell. "Pick the right tool for your project. Bash for quick checks. Snakemake or Nextflow for anything you'd put in a paper. The concepts transfer."

## Before the Session

### 1. Test the Demo End-to-End (Day Before)

```bash
# Clone fresh and verify
cd /tmp
rm -rf test-demo
cp -r ~/btip-2026-workflow-test test-demo && cd test-demo
pixi install

# Generate/verify data
ls -lh data/reads/sample_R1.fastq.gz

# Test bash — one combo (~60 sec)
pixi run bash bash/pipeline.sh 20 33
ls results/bash/q20_k33/spades/contigs.fasta
ls results/bash/q20_k33/quast/report.tsv

# Test Snakemake dry-run
pixi run snakemake -s snakemake/Snakefile --cores 2 --dry-run
# Should show: Job stats: 28 jobs (1 count + 9 trim + 9 assemble + 9 evaluate)
# Or: 27 (rule all's 9 inputs + 9 trim + 9 assemble + 9 evaluate)

# Test Snakemake full run (~3-5 min)
pixi run snakemake -s snakemake/Snakefile --cores 2

# Test Snakemake resume
# Kill one SPAdes run mid-way, then:
pixi run snakemake -s snakemake/Snakefile --cores 2 --rerun-incomplete

# Test Nextflow full run (~3-5 min)
pixi run nextflow run nextflow/main.nf -profile local

# Test Nextflow resume
# Ctrl-c during ASSEMBLE, then:
pixi run nextflow run nextflow/main.nf -profile local -resume
```

### 2. Common Failures and Fixes

| Problem | Cause | Fix |
|---|---|---|
| SPAdes "no reads" / empty contigs | fastp filtered all reads (q=30 too strict) | Reduce max QC to 25 in config.yaml, or use higher-coverage reads |
| Snakemake "MissingInputException" | SPAdes output path mismatch | Verify `contigs.fasta` exists at the expected output path |
| Nextflow "No such file" | File path mismatch in process output | Check `path(contigs)` output matches what SPAdes writes |
| QuAST fails with "cannot parse" | Empty contigs from failed assembly | Check upstream — fastp may have filtered all reads |
| pixi install hangs | Network issue with conda channels | Use `pixi install -v` to debug, or pre-install on presentation machine |
| Snakemake DAG shows no edges | Dependencies not resolved | Check `rule all` input patterns match `expand()` output |
| `dot` not found for DAG visualization | Graphviz not installed | graphviz is in pixi.toml — run `pixi install` |
| SPAdes kills laptop (OOM) | Too many parallel assemblies | Snakemake `--cores 2`, Nextflow `maxForks 2` — safe on 4+ GB RAM |
| Nextflow "DSL1 not supported" | Running with Nextflow 25+ | Use `pixi run nextflow` (pixi provides Nextflow 24, DSL2 compatible) |
| `command not found: fastp` | Missing pixi environment | Prefix with `pixi run` — tools are in `.pixi/envs/default/bin/` |
| pixi install takes forever | First solve from scratch | Expected 5-10 min. Run `pixi install -v` to see progress |

### 3. Session Prep Checklist

- [ ] Test demo end-to-end on the presentation machine
- [ ] Pre-build the slide PDF: `pixi run render-deck`
- [ ] Print 1-page command reference: `pixi run print-cheatsheet` (output: `deck/cheatsheet.pdf`)
- [ ] Pre-generate DAG for slides: `pixi run dag-slide` (output: `deck/media/dag.png`)

### 3.5. Exit Ticket Google Form

Create a Google Form with these 3 questions. Settings: collect email (optional), limit to 1 response.

**Question 1** (Multiple choice):
```
Which tool would you choose for...
  a) A one-off quick analysis?
     ○ bash   ○ Snakemake   ○ Nextflow
  b) A long-term research project?
     ○ bash   ○ Snakemake   ○ Nextflow
```

**Question 2** (Short answer):
```
If you could sweep another parameter in this pipeline
(not qc or kmer), what would you investigate and why?
___________________________________________
```

**Question 3** (Paragraph):
```
What's still confusing? (Be honest — this helps
us improve future sessions.)
___________________________________________
_____
```

### 4. Command Reference Cheat Sheet

```
=== BASH ===
pixi run bash bash/pipeline.sh 20 33              # single run
pixi run bash -c 'for q in 15 20 25; do for k in 21 33 55; do bash bash/pipeline.sh $q $k; done; done'  # all 9

=== SNAKEMAKE ===
pixi run snakemake -s snakemake/Snakefile --cores 2 --dry-run   # preview
pixi run snakemake -s snakemake/Snakefile --cores 2              # full run
pixi run snakemake -s snakemake/Snakefile --dag | pixi run dot -Tpng > dag.png  # DAG
pixi run snakemake -s snakemake/Snakefile --cores 2 --rerun-incomplete  # resume

=== NEXTFLOW ===
pixi run nextflow run nextflow/main.nf -profile local             # full run
pixi run nextflow run nextflow/main.nf -profile local -resume     # resume
pixi run nextflow run nextflow/main.nf -profile slurm             # HPC/SLURM (CFB cluster)
```

---

## During the Session

### Timing

| Block | Duration | Clock | Notes |
|---|---|---|---|
| Intro + Hook (slides #1-6) | 10 min | 0:00-0:10 | Don't rush. The 3×3 grid must land. Slide #6 covers pixi/reproducibility concepts briefly — interns know conda, bridge to pixi. |
| Bash hands-on (slide #7) | 15 min | 0:10-0:25 | Walk the room. Help stuck interns. Don't fix everything — the "pain" is intentional. |
| Bash discussion (slide #8) | 5 min | 0:25-0:30 | "What was hard?" Let THEM articulate pain points before you show the next slide. |
| Snakemake reveal (slides #9-11) | 20 min | 0:30-0:50 | Show dry-run first. Then DAG. Then full run. The `--dag` visualization = the "wow." |
| Nextflow reveal (slides #12-14) | 18 min | 0:50-1:08 | Start with `-resume` demo (ctrl-c, re-run). Channels are abstract; resume is concrete. |
| Bonus: HPC/SLURM (slide #15) | 2 min | 1:08-1:10 | Quick bonus. "I know Nextflow best. Snakemake does this too." Show the config, move on. |
| Compare + close (slides #16-20) | 10 min | 1:10-1:20 | Side-by-side table (includes HPC row). Triad callback. Exit ticket link. |
| Buffer | 10 min | 1:20-1:30 | Overflow Q&A. Help lingering interns. |

### Live Demo Demonstrations

| Demo | Commands | What to say |
|---|---|---|
| **Bash pain** | `ls results/bash/` | "9 flat directories. Now imagine 90. Or 900. How do you compare N50?" |
| **Snakemake DAG** | `pixi run snakemake --dag \| pixi run dot -Tpng > dag.png && xdg-open dag.png` | "This is your pipeline, visualized. Bash can't do this." |
| **Snakemake resume** | Start run → `ps aux \| grep spades` → kill PID → `pixi run snakemake --rerun-incomplete` | "It only redoes what failed. No wasted computation." |
| **Nextflow resume** | `pixi run nextflow run -profile local` → Ctrl-C → `pixi run nextflow run -profile local -resume` | "Green checkmarks = cached. It picks up exactly where it stopped." |
| **Nextflow reports** | Open `results/nextflow/dag.svg` | "Nextflow generates reports automatically — DAG, timeline, execution report." |
| **Nextflow SLURM** (bonus) | Show `nextflow.config` slurm profile | "I'm more comfortable with Nextflow. Snakemake does this too with `--cluster`. Both work." |

### Common Student Confusion Points

| Confusion | Response |
|---|---|
| "What's a wildcard?" | Show: `{qc}` in the filename → resolved to `15`, `20`, or `25` at runtime. |
| "Why 3 tools? Just pick one." | "Different labs use different tools. The concepts transfer. Whichever you pick, it's better than bash for anything > 2 runs." |
| "This seems complicated for 9 runs." | "It is. The point isn't 9 — it's 90. Or 900. The bash approach breaks at 9. The workflow manager doesn't break at 900." |
| "Snakemake or Nextflow?" | "Snakemake if your team knows Python. Nextflow if you need cloud-native scale. Both are fine. Both are better than bash loops." |
| "Do I need to learn both?" | "Pick one. The concepts transfer. If you learn Snakemake first, Nextflow takes a day to pick up." |
| "Can I run this on the HPC?" | "Yes — `-profile slurm`. Nextflow submits jobs to SLURM automatically. No code changes needed. That's slide #15." |

### Tactical Notes

- **Don't let them install during the session.** Verify `pixi install` completed at the very start (slide #6).
- **The bash loop is deliberately painful.** Don't help them write the nested loop — let them feel it. "How would you do all 9?" is the key teaching moment.
- **Show DAG before running.** The `--dag` visualization is more powerful when they see it BEFORE the run. It becomes a map they recognize during execution.
- **The resume demos need to be live.** Pre-position a partial Snakemake/Nextflow run so you can demonstrate resume without waiting for a full run.
- **Have a backup.** If SPAdes is too slow on student laptops, have a pre-run results directory they can compare against.

---

## After the Session

- [ ] Review exit ticket responses (especially Q3: "what's still confusing")
- [ ] Send follow-up email: link to repo, nf-core website, Snakemake documentation
- [ ] Note timing: which block ran over? Adjust for next year.
- [ ] Update this file with any new pitfalls or improvements discovered
- [ ] Archive the session note to knowledge graph
