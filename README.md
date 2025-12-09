# biostat777-Final-Project

Project workspace for FAERS T2DM safety pipeline and Shiny dashboard.

## Contents
- `data/`: cleaned SQLite database `faers.sqlite` (large) and `pseudo_soc_map_top.csv` mapping file.
- `scripts/`: data pipeline scripts (`download_faers.R`, `step1`–`step11`, `check-cohort.R`).
- `app/`: Shiny dashboard scaffold (6 pages).
  - `app.R`: entrypoint, connects to `../data/faers.sqlite` by default (override with `FAERS_DB_PATH`).
  - `R/`: modules and helpers (`mod_home.R`, `mod_global_trends.R`, `mod_mech_compare.R`, `mod_drug_profiles.R`, `mod_temporal_signals.R`, `mod_methods.R`, `db_utils.R`, `plot_utils.R`).
  - `www/`: static assets placeholder.
- `faers_clean.zip`: archive containing the cleaned DB, mapping CSV, and scripts (backup).

## File/Module roles
- `scripts/download_faers.R`: download and unzip FAERS raw TXT by quarter/year.
- `scripts/step1-clean-names.R`: standardize column names.
- `scripts/step2-clean-content.R`: clean field contents (IDs, dates, numeric).
- `scripts/step3-dedup-sqlite.R`: import to SQLite and deduplicate.
- `scripts/step4-clean-sql.R`: filter outliers/ranges; produce `*_clean`.
- `scripts/step5-widescreen-sql.R`: wide screen target drugs; produce `drug_wide`, `target_cases`.
- `scripts/step6-normalize-rxnorm.R`: RxNorm normalization; produce `drug_normalized`, `target_cases_norm`.
- `scripts/step7-fine-filter.R`: fine filter target drug exposure records.
- `scripts/step8-pseudo-soc.R`: map PT to pseudo SOC; produce `reac_pseudo_soc`.
- `scripts/step9-cohort.R`: assemble cohort_index/demo/drug/reac/outc.
- `scripts/step10-mechanism.R`: add ATC/mechanism; produce `cohort_drug_final`, `drug_atc_mech`.
- `scripts/step11-analytic.R`: build `cohort_analytic` and outcome flags.
- `scripts/check-cohort.R`: simple QA checks.
- `app/app.R`: Shiny entry; loads modules; connects to SQLite.
- `app/R/db_utils.R`: DB connect/disconnect and safe query helper.
- `app/R/plot_utils.R`: shared plotting utilities (placeholder).
- `app/R/mod_home.R`: Page 1 Home/Overview.
- `app/R/mod_global_trends.R`: Page 2 Global Trends.
- `app/R/mod_mech_compare.R`: Page 3 Mechanism Comparison.
- `app/R/mod_drug_profiles.R`: Page 4 Individual Drug Profiles.
- `app/R/mod_temporal_signals.R`: Page 5 Temporal & Emerging Signals.
- `app/R/mod_methods.R`: Page 6 Methods & Downloads.
- `app/www/.gitkeep`: placeholder to keep static asset folder in git.

## Directory tree (current)
```
biostat777-Final-Project/
├─ README.md                 # Project overview and run instructions
├─ faers_clean.zip           # Backup: cleaned DB, mapping CSV, scripts
├─ data/                     # Cleaned DB, mapping CSV (gitignored; large)
│  ├─ faers.sqlite           # Main SQLite database
│  └─ pseudo_soc_map_top.csv # PT → pseudo SOC mapping
├─ scripts/                  # Data pipeline scripts
│  ├─ download_faers.R
│  ├─ step1-clean-names.R
│  ├─ step2-clean-content.R
│  ├─ step3-dedup-sqlite.R
│  ├─ step4-clean-sql.R
│  ├─ step5-widescreen-sql.R
│  ├─ step6-normalize-rxnorm.R
│  ├─ step7-fine-filter.R
│  ├─ step8-pseudo-soc.R
│  ├─ step9-cohort.R
│  ├─ step10-mechanism.R
│  ├─ step11-analytic.R
│  └─ check-cohort.R
├─ app/                      # Shiny dashboard scaffold
│  ├─ app.R                  # Entrypoint: navbar tabs for 6 pages
│  ├─ R/                     # Modules and helpers
│  │  ├─ db_utils.R
│  │  ├─ plot_utils.R
│  │  ├─ mod_home.R
│  │  ├─ mod_global_trends.R
│  │  ├─ mod_mech_compare.R
│  │  ├─ mod_drug_profiles.R
│  │  ├─ mod_temporal_signals.R
│  │  └─ mod_methods.R
│  └─ www/                   # Static assets placeholder
│     └─ .gitkeep
└─ .gitignore                # Ignores data/, faers_clean.zip, .DS_Store
```

## Run the Shiny app
```bash
cd app
Rscript -e "shiny::runApp('app.R', host='0.0.0.0', port=3838)"
```
By default the app looks for `../data/faers.sqlite`. Override via `FAERS_DB_PATH=/path/to/faers.sqlite` if needed.

## Notes
- Current database covers 2019–2021; extend by rerunning the pipeline with additional years.
- Data files are large and should stay out of git; keep `data/` in `.gitignore`.
