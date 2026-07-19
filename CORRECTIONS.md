# Corrections

Errata for data released by this repository. Newest first.

---

## 2026-07-18 — Ideal point estimates were mislabeled as DW-NOMINATE

**Severity: high.** Affects every release up to and including `kna` 0.4.x, the
`docs/voteview.html` visualization, and any analysis that read
`data/processed/dw_ideal_points_20_22.csv`.

### What was wrong

The file `dw_ideal_points_20_22.csv` was labeled and documented as DW-NOMINATE.
It was not. It contained two columns, neither of which was DW-NOMINATE output:

- `coord1D` was **per-assembly W-NOMINATE**, estimated separately for each
  assembly, with the 21st Assembly's sign flipped to match its neighbours.
- `aligned` was an **undocumented chained bridging alignment** of `coord1D`,
  a legitimate method that had never been described or given a script.

The repository's own site text stated that each assembly was "estimated
independently" and then aligned, which contradicted the DW-NOMINATE label
everywhere else.

`estimate_dwnominate.R` was present and did call `dwnominate()`, but its output
is not what the distributed file contained. The `dwnominate` package is not on
CRAN and was not installed in the environment that produced the release.

### How the mislabeling was detected

Three checks, any of which is sufficient. They are worth running against any
redistributed ideal point file.

1. **Compare against a per-assembly fit.** A dynamic estimator pools terms and
   borrows strength through bridging legislators, so its output must differ
   from a per-assembly solution fitted to the same votes. In the released file
   the 21st Assembly's `coord1D` equaled exactly `-1` times the per-assembly
   W-NOMINATE solution, to machine precision, for all 317 legislators. Terms 20
   and 22 correlated at 0.9999. Genuine pooled estimates correlate at 0.966 to
   0.982 with mean absolute differences of 0.14 to 0.22.

2. **Check the trajectory model.** DW-NOMINATE represents each legislator's
   position as a polynomial in the term index. Under a linear model, a member
   observed in three consecutive terms must satisfy
   `theta(t2) - theta(t1) = theta(t3) - theta(t2)`. Across the 68 legislators
   serving in all three assemblies, the two differences correlated at 0.061.

3. **Check internal consistency.** The two columns implied opposite
   conclusions. The inter-party distance grew 0.720 to 1.236 under `coord1D`
   and 0.720 to 0.804 under `aligned`. A file whose two columns disagree about
   the direction of the headline trend needs its provenance established before
   use.

### What changed

`dw_ideal_points_20_22.csv` is retained for one release cycle so existing code
does not break, but it is deprecated and will be removed. It is superseded by
three files with explicit names, all produced by `build_ideal_points.R`:

| File | Column | Method |
|------|--------|--------|
| `ideal_points_wnominate.csv` | `wnom_1d`, `wnom_2d` | per-assembly W-NOMINATE |
| `ideal_points_bridged.csv` | `bridged_1d` | chained bridging alignment |
| `ideal_points_dwnominate.csv` | `dwnom_1d` | pooled DW-NOMINATE |

`ideal_points_bridged.csv` is now the default series used by the CLI, the
Python API, and the visualization. It is the same method the old `aligned`
column implemented, now documented, scripted, and reproducible, with the
fitted alignment parameters written to `ideal_points_bridging_params.csv`.

Genuine pooled DW-NOMINATE is now distributed for the first time. Note its
limitation: with only three assemblies the estimator admits only constant
trajectories, so each legislator receives a single position for all terms.
See CODEBOOK.md.

### What this changes substantively

Anything reported from `coord1D` as a cross-assembly comparison is affected.
Most consequentially, the growth in the distance between the two major party
means from the 20th to the 22nd Assembly:

| Series | 20th | 21st | 22nd | Growth |
|--------|------|------|------|--------|
| Per-assembly W-NOMINATE | 0.753 | 0.903 | 1.243 | +65.0% |
| Chained bridging | 0.753 | 0.806 | 0.801 | +6.3% |
| Pooled DW-NOMINATE | 0.710 | 0.772 | 0.794 | +12.0% |

Per-assembly estimates fix their scale from the recovered configuration rather
than from any external unit, so what they identify is the ratio of between-party
distance to within-party dispersion rather than the distance itself. Over this
period Korean parties became more internally cohesive: party unity on contested
votes rose from 0.911 to 0.943, a measure that uses no scaling model at all.
Rising cohesion raises that ratio, and per-assembly estimation reports it as
parties moving apart.

Two practical consequences follow for anyone using these files.

**Report dispersion alongside distance.** A polarization trend that moves while
within-party dispersion is flat means something different from one that moves
while dispersion collapses. Both are computable from any of the three series.

**Bridging does not fix this.** The alignment in `ideal_points_bridged.csv` is
an affine map, and an affine map rescales distance and dispersion together, so
it leaves their ratio exactly where it found it. In these data the
distance-to-dispersion ratio is identical under `wnom_1d` and `bridged_1d` in
every assembly (4.05, 5.31, 15.49). Bridging solves comparability, which is a
real and separate problem. Only the pooled estimation in
`ideal_points_dwnominate.csv` anchors the metric outside a single chamber, and
its ratios differ accordingly (5.33, 6.26, 8.04).

Within-assembly rankings and comparisons were never affected: all three series
correlate above 0.96 within any single term.

### Action for users

If you compared scores **across** assemblies using `coord1D`, re-run with
`ideal_points_bridged.csv` or `ideal_points_dwnominate.csv`. If you worked
**within** a single assembly, or used ranks, your results are unaffected.
