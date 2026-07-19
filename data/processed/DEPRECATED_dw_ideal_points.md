# dw_ideal_points_20_22.csv is deprecated

This file is retained for one release cycle so existing code does not break.
It will be removed. **Do not use it for new work.**

Despite its name it does not contain DW-NOMINATE estimates:

- `coord1D` is per-assembly W-NOMINATE, with the 21st Assembly's sign flipped.
  Its 21st Assembly values equal exactly -1 times the per-assembly solution.
- `aligned` is a chained bridging alignment of `coord1D`, which was never
  documented and had no script in the repository.

The two columns imply opposite conclusions about the headline polarization
trend, so any cross-assembly result taken from `coord1D` should be re-checked.

Use instead, all produced by `build_ideal_points.R`:

| File | Column | Use for |
|------|--------|---------|
| `ideal_points_wnominate.csv` | `wnom_1d` | within-assembly comparisons |
| `ideal_points_bridged.csv` | `bridged_1d` | cross-assembly comparisons (default) |
| `ideal_points_dwnominate.csv` | `dwnom_1d` | cross-assembly, pooled estimation |

See `../../CORRECTIONS.md` and the "Ideal Points" section of `../../CODEBOOK.md`.
