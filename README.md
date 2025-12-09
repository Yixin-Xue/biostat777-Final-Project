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

## Run the Shiny app
```bash
cd app
Rscript -e "shiny::runApp('app.R', host='0.0.0.0', port=3838)"
```
By default the app looks for `../data/faers.sqlite`. Override via `FAERS_DB_PATH=/path/to/faers.sqlite` if needed.

## Notes
- Current database covers 2019–2021; extend by rerunning the pipeline with additional years.
- Data files are large and should stay out of git; keep `data/` in `.gitignore`.
