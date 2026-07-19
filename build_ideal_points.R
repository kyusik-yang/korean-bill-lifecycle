# build_ideal_points.R
# ============================================================
# Build the three ideal point series distributed by this repository.
#
#   1. ideal_points_wnominate.csv   per-assembly W-NOMINATE
#   2. ideal_points_bridged.csv     chained bridging alignment of (1)
#   3. ideal_points_dwnominate.csv  pooled DW-NOMINATE
#
# The three answer different questions and are not interchangeable.
# See CODEBOOK.md, section "Ideal points", before using any of them.
#
# Prerequisites:
#   install.packages(c("arrow", "dplyr", "tidyr", "pscl", "wnominate"))
#   remotes::install_github("wmay/dwnominate")   # not on CRAN, compiles Fortran
#
# Usage:
#   Rscript build_ideal_points.R              # all three
#   Rscript build_ideal_points.R --skip-dw    # skip the slow pooled estimation
# ============================================================

suppressMessages({
  library(arrow)
  library(dplyr)
  library(tidyr)
  library(pscl)
  library(wnominate)
})

args <- commandArgs(trailingOnly = TRUE)
SKIP_DW <- "--skip-dw" %in% args

PROCESSED <- "data/processed"
MIN_MINORITY <- 0.025   # a vote counts as contested if >=2.5% are in the minority
MIN_VOTES    <- 20      # a legislator is active with >=20 contested votes
REF_TERM     <- 20      # bridging alignment expresses every term in these units

CONSERVATIVE <- c("국민의힘", "미래통합당", "자유한국당", "미래한국당")
LIBERAL      <- "더불어민주당"

# ── Load ───────────────────────────────────────────────────
cat("Loading roll call data...\n")
rc <- read_parquet(file.path(PROCESSED, "roll_calls_all.parquet"))

api <- rc %>%
  filter(source == "api", term %in% c(20, 21, 22)) %>%
  mutate(
    term = as.integer(term),
    vote_num = case_when(
      vote == "찬성" ~ 1L,
      vote == "반대" ~ 6L,
      vote == "기권" ~ 9L,
      TRUE ~ NA_integer_
    )
  ) %>%
  filter(!is.na(vote_num), !is.na(member_id), !is.na(bill_id)) %>%
  mutate(vote_id = paste(term, bill_id, sep = "_"))

member_meta <- api %>% distinct(member_id, term, party, member_name)

# Party bloc labels, carried on every output file for convenience and for
# backward compatibility with the deprecated dw_ideal_points_20_22.csv schema.
party_bloc <- function(party) {
  dplyr::case_when(
    party %in% CONSERVATIVE ~ "conservative",
    party == LIBERAL ~ "liberal",
    party %in% c("정의당", "진보당", "기본소득당", "사회민주당") ~ "progressive",
    party == "조국혁신당" ~ "rebuilding",
    party %in% c("개혁신당", "새로운미래") ~ "centrist",
    party %in% c("민생당", "열린민주당") ~ "liberal_minor",
    TRUE ~ "independent"
  )
}


build_rollcall <- function(term_num, label_ids = TRUE) {
  sub <- api %>% filter(term == term_num)
  vw <- sub %>%
    distinct(member_id, vote_id, .keep_all = TRUE) %>%
    dplyr::select(member_id, vote_id, vote_num) %>%
    pivot_wider(names_from = vote_id, values_from = vote_num)
  mat <- as.matrix(vw[, -1]); rownames(mat) <- vw$member_id

  minority <- apply(mat, 2, function(col) {
    v <- col[!is.na(col) & col != 9]
    if (!length(v)) return(0)
    min(mean(v == 1), mean(v == 6))
  })
  mat <- mat[, minority >= MIN_MINORITY, drop = FALSE]
  active <- apply(mat, 1, function(r) sum(!is.na(r) & r != 9)) >= MIN_VOTES
  mat <- mat[active, , drop = FALSE]

  cat(sprintf("  %dth: %d legislators x %d contested votes\n",
              term_num, nrow(mat), ncol(mat)))
  rollcall(mat, yea = 1, nay = 6, missing = 9, notInLegis = NA,
           legis.names = rownames(mat),
           legis.data = data.frame(
             ID = rownames(mat),
             party = match(member_meta$party[match(rownames(mat),
                            member_meta$member_id[member_meta$term == term_num])],
                           sort(unique(member_meta$party))),
             stringsAsFactors = FALSE),
           desc = sprintf("%dth Korean National Assembly", term_num))
}

# ============================================================
# 1. Per-assembly W-NOMINATE
# ============================================================
# Each assembly is scaled on its own. The recovered configuration is
# identified only up to a reflection, so the sign of the axis is arbitrary
# and is fixed here by anchoring on a conservative legislator. Scores are
# comparable WITHIN an assembly and NOT across assemblies.

cat("\n[1/3] Per-assembly W-NOMINATE\n")
rc_list <- list()
wnom_scores <- list()

for (t in c(20, 21, 22)) {
  rcobj <- build_rollcall(t)
  rc_list[[as.character(t)]] <- rcobj

  cons_ids <- member_meta %>%
    filter(term == t, party %in% CONSERVATIVE) %>% pull(member_id)
  anchor <- which(rownames(rcobj$votes) %in% cons_ids)[1]
  if (is.na(anchor)) stop(sprintf("no conservative anchor in the %dth Assembly", t))

  fit <- wnominate(rcobj, dims = 2, polarity = c(anchor, anchor), verbose = FALSE)

  sc <- data.frame(
    member_id = rownames(fit$legislators),
    term = t,
    wnom_1d = fit$legislators$coord1D,
    wnom_2d = fit$legislators$coord2D,
    stringsAsFactors = FALSE
  )

  # Orient to the Voteview convention: positive = conservative, negative =
  # liberal. Without this the sign is whatever the anchor happened to produce.
  sc <- sc %>% left_join(member_meta %>% filter(term == t) %>%
                           dplyr::select(member_id, party), by = "member_id")
  if (mean(sc$wnom_1d[sc$party %in% CONSERVATIVE], na.rm = TRUE) <
      mean(sc$wnom_1d[sc$party == LIBERAL], na.rm = TRUE)) {
    sc$wnom_1d <- -sc$wnom_1d
    sc$wnom_2d <- -sc$wnom_2d
    cat(sprintf("    (%dth: flipped to positive = conservative)\n", t))
  }
  wnom_scores[[as.character(t)]] <- sc %>% dplyr::select(-party)

  cat(sprintf("    APRE 1D = %.3f, 2D = %.3f | eigenvalues > 1: %d\n",
              fit$fits["apre1D"], fit$fits["apre2D"],
              sum(fit$eigenvalues > 1, na.rm = TRUE)))
}

wnom <- bind_rows(wnom_scores) %>%
  left_join(member_meta, by = c("member_id", "term")) %>%
  mutate(party_bloc = party_bloc(party)) %>%
  dplyr::select(member_id, member_name, party, party_bloc, term, wnom_1d, wnom_2d)

write.csv(wnom, file.path(PROCESSED, "ideal_points_wnominate.csv"), row.names = FALSE)
cat(sprintf("  wrote ideal_points_wnominate.csv (%d rows)\n", nrow(wnom)))

# ============================================================
# 2. Chained bridging alignment
# ============================================================
# Put every assembly into the units of the reference assembly by regressing,
# for the legislators who serve in both, the earlier term's already-aligned
# score on the later term's raw score. The fitted line is then applied to the
# whole later term. Alignment chains forward: 21st onto 20th, 22nd onto the
# aligned 21st.
#
# This is an affine map, so it corrects both the arbitrary sign and the
# arbitrary scale, but it assumes that bridging legislators do not move on
# average. Where they do move, that movement is absorbed into the mapping.

cat("\n[2/3] Chained bridging alignment\n")

bridged <- wnom %>% mutate(bridged_1d = NA_real_)
bridged$bridged_1d[bridged$term == REF_TERM] <- bridged$wnom_1d[bridged$term == REF_TERM]

alignment_log <- data.frame()
for (t in c(21, 22)) {
  prev <- t - 1
  ids <- intersect(bridged$member_id[bridged$term == prev],
                   bridged$member_id[bridged$term == t])
  a <- bridged %>% filter(term == prev, member_id %in% ids) %>% arrange(member_id)
  b <- bridged %>% filter(term == t,    member_id %in% ids) %>% arrange(member_id)
  stopifnot(identical(a$member_id, b$member_id))

  fit <- lm(a$bridged_1d ~ b$wnom_1d)
  slope <- unname(coef(fit)[2]); intercept <- unname(coef(fit)[1])

  idx <- bridged$term == t
  bridged$bridged_1d[idx] <- intercept + slope * bridged$wnom_1d[idx]

  cat(sprintf("  %dth onto %dth: %d bridging legislators, slope %+.4f, intercept %+.4f, R2 %.4f\n",
              t, prev, length(ids), slope, intercept, summary(fit)$r.squared))
  alignment_log <- rbind(alignment_log, data.frame(
    term = t, reference_term = prev, n_bridging = length(ids),
    slope = slope, intercept = intercept, r_squared = summary(fit)$r.squared))
}

write.csv(bridged %>% dplyr::select(member_id, member_name, party, party_bloc, term,
                                    wnom_1d, bridged_1d),
          file.path(PROCESSED, "ideal_points_bridged.csv"), row.names = FALSE)
write.csv(alignment_log, file.path(PROCESSED, "ideal_points_bridging_params.csv"),
          row.names = FALSE)
cat(sprintf("  wrote ideal_points_bridged.csv (%d rows) and the alignment parameters\n",
            nrow(bridged)))

# ============================================================
# 3. Pooled DW-NOMINATE
# ============================================================
# Estimate all three assemblies jointly, with bridging legislators anchoring
# a single scale. IMPORTANT: dwnominate represents each legislator's
# trajectory as a polynomial in the term index and requires at least five
# sessions to fit even a linear one. With three assemblies it admits only a
# constant, so every legislator receives ONE position covering all terms.
# Cross-term change in a party mean is therefore entirely compositional here.

if (SKIP_DW) {
  cat("\n[3/3] Pooled DW-NOMINATE: skipped (--skip-dw)\n")
} else {
  cat("\n[3/3] Pooled DW-NOMINATE\n")
  if (!requireNamespace("dwnominate", quietly = TRUE)) {
    stop("dwnominate is not installed. See the header of this script.")
  }
  library(dwnominate)

  # Starting values: with fewer than five sessions dwnominate cannot build
  # common-space starts on its own, so scale one pooled matrix in which each
  # legislator appears once and all three assemblies' votes are stacked.
  pooled <- api %>%
    distinct(member_id, vote_id, .keep_all = TRUE) %>%
    dplyr::select(member_id, vote_id, vote_num) %>%
    pivot_wider(names_from = vote_id, values_from = vote_num)
  pmat <- as.matrix(pooled[, -1]); rownames(pmat) <- pooled$member_id
  keep <- apply(pmat, 2, function(col) {
    v <- col[!is.na(col) & col != 9]
    length(v) > 0 && min(mean(v == 1), mean(v == 6)) >= MIN_MINORITY
  })
  pmat <- pmat[, keep, drop = FALSE]
  pmat <- pmat[apply(pmat, 1, function(r) sum(!is.na(r) & r != 9)) >= MIN_VOTES, , drop = FALSE]
  cat(sprintf("  pooled starting matrix: %d legislators x %d votes\n",
              nrow(pmat), ncol(pmat)))

  cons_all <- member_meta %>% filter(party %in% CONSERVATIVE) %>% pull(member_id)
  pooled_rc <- rollcall(pmat, yea = 1, nay = 6, missing = 9, notInLegis = NA,
                        legis.names = rownames(pmat),
                        legis.data = data.frame(
                          ID = rownames(pmat),
                          party = as.integer(rownames(pmat) %in% cons_all),
                          stringsAsFactors = FALSE))
  p_anchor <- which(rownames(pmat) %in% cons_all)[1]
  start_fit <- wnominate(pooled_rc, dims = 2,
                         polarity = c(p_anchor, p_anchor), verbose = FALSE)

  polarity <- sapply(c(20, 21, 22), function(t) {
    ids <- rownames(rc_list[[as.character(t)]]$votes)
    cons_ids <- member_meta %>% filter(term == t, party %in% CONSERVATIVE) %>% pull(member_id)
    which(ids %in% cons_ids)[1]
  })

  set.seed(20260718)
  fit <- dwnominate(unname(rc_list), id = "ID", start = start_fit,
                    dims = 1, model = 0, polarity = polarity)

  dw <- fit$legislators %>%
    mutate(term = as.integer(session) + 19L) %>%
    dplyr::select(member_id = ID, term, dwnom_1d = coord1D) %>%
    left_join(member_meta, by = c("member_id", "term"))

  ref <- dw %>% filter(term == 20)
  if (mean(ref$dwnom_1d[ref$party %in% CONSERVATIVE], na.rm = TRUE) <
      mean(ref$dwnom_1d[ref$party == LIBERAL], na.rm = TRUE)) {
    dw$dwnom_1d <- -dw$dwnom_1d
    cat("  (flipped to positive = conservative)\n")
  }

  write.csv(dw %>% mutate(party_bloc = party_bloc(party)) %>%
              dplyr::select(member_id, member_name, party, party_bloc, term, dwnom_1d),
            file.path(PROCESSED, "ideal_points_dwnominate.csv"), row.names = FALSE)
  cat(sprintf("  wrote ideal_points_dwnominate.csv (%d rows)\n", nrow(dw)))
  saveRDS(fit, file.path(PROCESSED, "dwnominate_fit.rds"))
}

# ============================================================
# Comparison
# ============================================================
cat("\n", strrep("=", 72), "\n", sep = "")
cat("INTER-PARTY DISTANCE UNDER EACH SERIES\n")
cat(strrep("=", 72), "\n\n")

gap <- function(df, col) {
  sapply(c(20, 21, 22), function(t) {
    a <- mean(df[[col]][df$term == t & df$party %in% CONSERVATIVE], na.rm = TRUE)
    b <- mean(df[[col]][df$term == t & df$party == LIBERAL], na.rm = TRUE)
    abs(a - b)
  })
}
g1 <- gap(wnom, "wnom_1d"); g2 <- gap(bridged, "bridged_1d")
cat("  term   per-assembly   bridged")
if (!SKIP_DW) cat("   pooled DW") ; cat("\n")
for (i in 1:3) {
  cat(sprintf("   %2d      %.3f        %.3f", c(20, 21, 22)[i], g1[i], g2[i]))
  if (!SKIP_DW) cat(sprintf("      %.3f", gap(dw, "dwnom_1d")[i]))
  cat("\n")
}
cat(sprintf("\n  growth 20th to 22nd:  %+.1f%%       %+.1f%%",
            100 * (g1[3] - g1[1]) / g1[1], 100 * (g2[3] - g2[1]) / g2[1]))
if (!SKIP_DW) {
  g3 <- gap(dw, "dwnom_1d")
  cat(sprintf("     %+.1f%%", 100 * (g3[3] - g3[1]) / g3[1]))
}
cat("\n\n  The per-assembly series is renormalized within each term, so it reports\n")
cat("  much larger growth than either series that holds a scale fixed across\n")
cat("  terms. Do not compare per-assembly scores across assemblies.\n")

writeLines(capture.output(sessionInfo()),
           file.path(PROCESSED, "ideal_points_sessioninfo.txt"))
cat("\nDone.\n")
