## Assisted-by: Claude Opus 5 and Claude Fable 5.1 (Anthropic). See the
## Provenance section of README.md.
##
## Every figure quoted in the README and in data-raw/*.md came out of a
## particular set of package versions. Without them a number that later fails
## to reproduce cannot be told apart from a number that was wrong.
##
## Each script in data-raw/ calls record_session() when it finishes, writing
## data-raw/sessioninfo/<name>.txt. The committed ones are from the runs that
## produced the figures quoted in README.md and data-raw/*.md; a script that
## has not been run since is simply absent, and writes its file when it is.

record_session <- function(name) {
    dir <- file.path("data-raw", "sessioninfo")
    dir.create(dir, showWarnings = FALSE, recursive = TRUE)
    path <- file.path(dir, paste0(name, ".txt"))

    con <- file(path, "wt")
    on.exit(close(con))
    ## What identifies the run, beyond the package versions: the inputs and
    ## knobs it was given, and the code it ran.
    knobs <- Sys.getenv(c("THCA_LOG2TPM", "THCA_COUNTS", "THCA_GDC",
                          "THCA_PREPARED", "THCA_MMC3", "GSE33630",
                          "GSE33630_CEL", "BUILD_OUT", "BRS_ITER",
                          "BRS_CORES", "BRS_UNIVERSE", "BRS_OUT",
                          "BRS_WRITE_EXPECTED"), unset = NA)
    knobs <- knobs[!is.na(knobs)]
    ## Paths are recorded by file name only: where a file sat on one machine
    ## says nothing useful to the next reader.
    is_path <- grepl("/", knobs, fixed = TRUE)
    knobs[is_path] <- basename(knobs[is_path])
    commit <- tryCatch(
        system2("git", c("rev-parse", "--short", "HEAD"), stdout = TRUE,
                stderr = FALSE),
        error = function(e) character(), warning = function(w) character()
    )
    writeLines(c(
        paste("script:", name),
        paste("run on:", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
        paste("commit:", if (length(commit)) commit else "unknown"),
        paste("thyroidBRS:", tryCatch(
            as.character(utils::packageVersion("thyroidBRS")),
            error = function(e) "not installed")),
        if (length(knobs)) paste0(names(knobs), "=", knobs) else
            "environment: (defaults)",
        ""
    ), con)
    writeLines(capture.output(utils::sessionInfo()), con)

    message("recorded environment in ", path)
    invisible(path)
}
