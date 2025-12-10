# DB connection helpers
connect_faers <- function(db_path = file.path("..", "data", "faers.sqlite")) {
  if (!requireNamespace("DBI", quietly = TRUE) || !requireNamespace("RSQLite", quietly = TRUE)) {
    stop("Please install DBI and RSQLite before running the app.")
  }
  if (!file.exists(db_path)) {
    warning(sprintf("Database not found at %s", db_path))
    return(NULL)
  }
  DBI::dbConnect(RSQLite::SQLite(), db_path)
}

disconnect_faers <- function(con) {
  if (!is.null(con)) {
    try(DBI::dbDisconnect(con), silent = TRUE)
  }
}

db_safe_query <- function(con, sql) {
  if (is.null(con)) {
    return(data.frame())
  }
  DBI::dbGetQuery(con, sql)
}

# -------- Drug-level helpers for Page 4 --------
# -------- Drug-level helpers for Page 4 --------

# 1) Available target drugs (distinct target_generic)
get_available_drugs <- function(con) {
  if (is.null(con)) return(character(0))
  DBI::dbGetQuery(con, "
    SELECT DISTINCT target_generic
    FROM cohort_analytic
    WHERE target_generic IS NOT NULL
    ORDER BY target_generic
  ")$target_generic
}

# 2) Time series by quarter/year for a given drug
get_drug_time_series <- function(con, drug, level = c("quarter", "year")) {
  if (is.null(con) || is.null(drug) || is.na(drug) || drug == "") return(data.frame())
  level <- match.arg(level)
  if (level == "quarter") {
    sql <- "
      SELECT source_quarter AS period,
             COUNT(DISTINCT caseid) AS n_cases
      FROM cohort_analytic
      WHERE target_generic = ?
      GROUP BY source_quarter
      ORDER BY source_quarter
    "
  } else {
    sql <- "
      SELECT substr(source_quarter, 1, 4) AS period,
             COUNT(DISTINCT caseid) AS n_cases
      FROM cohort_analytic
      WHERE target_generic = ?
      GROUP BY substr(source_quarter, 1, 4)
      ORDER BY period
    "
  }
  DBI::dbGetQuery(con, sql, params = list(drug))
}

# 3) Pseudo SOC distribution for a given drug
get_drug_soc_dist <- function(con, drug, top_n = NULL) {
  if (is.null(con) || is.null(drug) || is.na(drug) || drug == "") return(data.frame())
  sql <- "
    SELECT pseudo_soc,
           COUNT(*) AS n_events
    FROM cohort_analytic
    WHERE target_generic = ?
    GROUP BY pseudo_soc
    ORDER BY n_events DESC
  "
  df <- DBI::dbGetQuery(con, sql, params = list(drug))
  if (!is.null(top_n)) df <- head(df, top_n)
  df
}

# 4) Top PTs for a given drug
get_drug_top_pt <- function(con, drug, n = 20) {
  if (is.null(con) || is.null(drug) || is.na(drug) || drug == "") return(data.frame())
  sql <- sprintf("
    SELECT pt,
           COUNT(*) AS n_events
    FROM cohort_analytic
    WHERE target_generic = ?
    GROUP BY pt
    ORDER BY n_events DESC
    LIMIT %d
  ", n)
  DBI::dbGetQuery(con, sql, params = list(drug))
}

# 5) Outcome summary for a given drug
get_drug_outcomes <- function(con, drug) {
  if (is.null(con) || is.null(drug) || is.na(drug) || drug == "") return(data.frame())
  DBI::dbGetQuery(con, "
    SELECT
      COUNT(DISTINCT CASE WHEN
        COALESCE(death, 0) +
        COALESCE(hosp, 0) +
        COALESCE(lifethreat, 0) +
        COALESCE(disability, 0) +
        COALESCE(congenital, 0) +
        COALESCE(required_intervention, 0) > 0
        THEN caseid END) AS serious_cases,
      SUM(CASE WHEN death = 1 THEN 1 ELSE 0 END) AS death,
      SUM(CASE WHEN hosp = 1 THEN 1 ELSE 0 END) AS hosp,
      SUM(CASE WHEN lifethreat = 1 THEN 1 ELSE 0 END) AS lifethreat,
      SUM(CASE WHEN disability = 1 THEN 1 ELSE 0 END) AS disability,
      SUM(CASE WHEN congenital = 1 THEN 1 ELSE 0 END) AS congenital,
      SUM(CASE WHEN required_intervention = 1 THEN 1 ELSE 0 END) AS required_intervention,
      COUNT(DISTINCT caseid) AS total_cases
    FROM cohort_analytic
    WHERE target_generic = ?
  ", params = list(drug))
}

# -------- Mechanism-level helpers for Page 3 --------

# Distinct mechanism classes
get_mechanism_classes <- function(con) {
  if (is.null(con)) return(character(0))
  DBI::dbGetQuery(con, "
    SELECT DISTINCT mech_class_final
    FROM cohort_analytic
    WHERE mech_class_final IS NOT NULL
    ORDER BY mech_class_final
  ")$mech_class_final
}

# Top PT overall (limit)
.get_top_pt_overall <- function(con, top_n = 80) {
  sql <- sprintf("
    SELECT pt, COUNT(*) AS n_events
    FROM cohort_analytic
    GROUP BY pt
    ORDER BY n_events DESC
    LIMIT %d
  ", as.integer(top_n))
  DBI::dbGetQuery(con, sql)
}

# Heatmap data: mech x pt counts (restricted to top PT overall)
get_pt_heatmap_data <- function(con, top_n = 80) {
  if (is.null(con)) return(data.frame())
  top_pt <- .get_top_pt_overall(con, top_n)
  if (!nrow(top_pt)) return(data.frame())
  placeholders <- paste(rep("?", nrow(top_pt)), collapse = ",")
  sql <- sprintf("
    SELECT mech_class_final AS mech_class,
           pt,
           COUNT(*) AS n_events
    FROM cohort_analytic
    WHERE pt IN (%s)
    GROUP BY mech_class_final, pt
  ", placeholders)
  df <- DBI::dbGetQuery(con, sql, params = as.list(top_pt$pt))
  list(top_pt = top_pt, counts = df)
}

# Top PT for a specific mechanism
get_top_pt_by_mech <- function(con, mech_class, top_n = 20) {
  if (is.null(con) || is.null(mech_class) || is.na(mech_class) || mech_class == "") return(data.frame())
  sql <- sprintf("
    SELECT pt,
           COUNT(*) AS n_events
    FROM cohort_analytic
    WHERE mech_class_final = ?
    GROUP BY pt
    ORDER BY n_events DESC
    LIMIT %d
  ", as.integer(top_n))
  DBI::dbGetQuery(con, sql, params = list(mech_class))
}

# Aggregate counts for PRR/ROR (mech vs rest, per PT)
get_prr_counts <- function(con, mech_class, top_n = 30) {
  if (is.null(con) || is.null(mech_class) || is.na(mech_class) || mech_class == "") return(data.frame())

  # Top PT within the mechanism to limit computation
  top_pt <- get_top_pt_by_mech(con, mech_class, top_n = top_n)
  if (!nrow(top_pt)) return(data.frame())

  placeholders <- paste(rep("?", nrow(top_pt)), collapse = ",")

  # Counts per pt within mech (a)
  sql_a <- sprintf("
    SELECT pt, COUNT(*) AS a
    FROM cohort_analytic
    WHERE mech_class_final = ?
      AND pt IN (%s)
    GROUP BY pt
  ", placeholders)
  a_df <- DBI::dbGetQuery(con, sql_a, params = c(list(mech_class), as.list(top_pt$pt)))

  # Total events within mech (for b)
  total_mech <- DBI::dbGetQuery(con, "
    SELECT COUNT(*) AS n FROM cohort_analytic WHERE mech_class_final = ?
  ", params = list(mech_class))$n

  # Total events overall (for d)
  total_all <- DBI::dbGetQuery(con, "SELECT COUNT(*) AS n FROM cohort_analytic")$n

  # PT totals overall (for c)
  sql_pt_total <- sprintf("
    SELECT pt, COUNT(*) AS pt_total
    FROM cohort_analytic
    WHERE pt IN (%s)
    GROUP BY pt
  ", placeholders)
  pt_total_df <- DBI::dbGetQuery(con, sql_pt_total, params = as.list(top_pt$pt))

  # Merge and compute b, c, d
  df <- dplyr::full_join(top_pt, a_df, by = "pt") |>
    dplyr::full_join(pt_total_df, by = "pt") |>
    dplyr::mutate(
      a = ifelse(is.na(a), 0, a),
      pt_total = ifelse(is.na(pt_total), 0, pt_total),
      b = pmax(total_mech - a, 0),
      c = pmax(pt_total - a, 0),
      d = pmax(total_all - a - b - c, 0)
    )
  df
}

# -------- Global trends helpers (Page 2) --------

# Aggregated counts by quarter; year aggregation can be done in R
get_global_trend_quarter <- function(con) {
  if (is.null(con)) return(data.frame())
  DBI::dbGetQuery(con, "
    WITH base AS (
      SELECT
        source_quarter AS period,
        caseid,
        MAX(COALESCE(death, 0) +
            COALESCE(hosp, 0) +
            COALESCE(lifethreat, 0) +
            COALESCE(disability, 0) +
            COALESCE(congenital, 0) +
            COALESCE(required_intervention, 0)) AS serious_any
      FROM cohort_analytic
      GROUP BY source_quarter, caseid
    )
    SELECT
      period,
      COUNT(DISTINCT caseid) AS n_cases,
      SUM(CASE WHEN serious_any > 0 THEN 1 ELSE 0 END) AS n_serious
    FROM base
    GROUP BY period
    ORDER BY period
  ")
}

# Severity trend by year (serious proportion)
get_severity_by_year <- function(con) {
  if (is.null(con)) return(data.frame())
  DBI::dbGetQuery(con, "
    WITH base AS (
      SELECT
        substr(source_quarter, 1, 4) AS year,
        caseid,
        MAX(COALESCE(death, 0) +
            COALESCE(hosp, 0) +
            COALESCE(lifethreat, 0) +
            COALESCE(disability, 0) +
            COALESCE(congenital, 0) +
            COALESCE(required_intervention, 0)) AS serious_any
      FROM cohort_analytic
      GROUP BY year, caseid
    )
    SELECT
      year,
      COUNT(DISTINCT caseid) AS n_cases,
      SUM(CASE WHEN serious_any > 0 THEN 1 ELSE 0 END) AS n_serious
    FROM base
    GROUP BY year
    ORDER BY year
  ")
}

# Event counts by mechanism (all events)
get_mech_event_counts <- function(con) {
  if (is.null(con)) return(data.frame())
  DBI::dbGetQuery(con, "
    SELECT mech_class_final AS mech_class,
           COUNT(*) AS n_events
    FROM cohort_analytic
    WHERE mech_class_final IS NOT NULL
      AND mech_class_final <> 'GIP_GLP1'
    GROUP BY mech_class_final
    ORDER BY n_events DESC
  ")
}

# Top pseudo SOC counts (overall)
get_top_pseudo_soc <- function(con, top_n = 15) {
  if (is.null(con)) return(data.frame())
  sql <- sprintf("
    SELECT pseudo_soc,
           COUNT(*) AS n_events
    FROM cohort_analytic
    WHERE pseudo_soc IS NOT NULL
    GROUP BY pseudo_soc
    ORDER BY n_events DESC
    LIMIT %d
  ", as.integer(top_n))
  DBI::dbGetQuery(con, sql)
}
