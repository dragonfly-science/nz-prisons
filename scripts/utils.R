
fix_factor_levels <- function(x) {
    levels <- droplevels(x)
    res = unique(as.character(levels))
    end = c()
    if ("Other" %in% levels) {
        res <- res[res != "Other"]
        end <- c("Other")
    }
    if ("Unknown" %in% levels) {
        res <- res[res != "Unknown"]
        end <- c(end, "Unknown")
    }
    c(res, end)
}
