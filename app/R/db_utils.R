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
