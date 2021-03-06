#' ANOVA summary for a two-way table, including Tukey Additivity Test
#'
#' Test for a 1-df interaction in two-way ANOVA table by the Tukey test.
#'
#' @details At present, this function simply gives the results of the ANOVAs for the additive model, the model including the 1 df
#'          term for non-additivity, and an \code{anova()} comparison of the two.
#'          The analysis is based on row and column means.
#'
#' @param object a \code{class("twoway")} object
#' @param ... other arguments passed down, but not used here
#' @author Michael Friendly
#' @importFrom stats anova aov
#' @export
#' @examples
#' data(sentRT)
#' sent.2way <- twoway(sentRT)
#' anova(sent.2way)


anova.twoway <- function(object, ...) {

  # r <- length(object$row)
  # c <- length(object$col)
  #
  # fit <- outer(object$row, object$col, "+") + object$overall
  # dat <- fit + object$residuals
  #
  # sse <- sum(object$residuals^2)
  # dfe <- ( r - 1 ) * ( c - 1 )
  #
  # ssrow <- c * sum(object$row^2)
  # sscol <- r * sum(object$col^2)

  if (object$method == "median") warning("The anova method is not appropriate for analysis by medians.\nThis analysis uses means.")
  z <- as.data.frame(object)
  aov1 <- anova(mod1 <- aov(data ~ row + col, data=z))
  aov2 <- anova(mod2 <- aov(data ~ row + col + nonadd, data=z))
  aov3 <- anova(mod1, mod2)

  info <- paste0('Dataset: ',  object$name, '; ', 'method: "', object$method, '"\n\n')
  cat(info)
  attr(aov1, "heading") <- "Analysis of Variance Table, assuming additivity\n"
  print(aov1)

#  cat("\nNon-Additive model", info, "\n")
  cat("\n\n")
  attr(aov2, "heading") <- "Analysis of Variance Table, allowing non-additivity\n"
  rownames(aov2)[4] <- "pure error"
  print(aov2)

  # cat("\nTukey test for non-additivity\n")
  # anova(mod1, mod2)
}
