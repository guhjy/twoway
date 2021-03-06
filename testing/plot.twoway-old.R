#' Plot method for two-way tables
#'
#' Plots either the fitted values and residuals under additivity or
#' a diagnostic plot for removable non-additivity by a power transformation
#'
#' @details For the \code{which="fit"} plot, the basic result comes from a plot of the row effects against the column fitted
#'     values, which appears as a rectangular grid in these coordinates.  Rotating this 45 degrees counterclockwise give a plot
#'     in which the vertical coordinate is the fitted value for the two-way table, and the horizontal coordinate is the column fit
#'     minus the row effect.  The spacing of the grid lines for the rows and columns of the table show the relative magnitudes of the
#'     row/column means or medians.
#'
#'     For the \code{which="diagnose"} plot, the interaction residuals from an additive model, \eqn{y_{ij} = \mu + \alpha_i + \beta_j},
#'     are plotted against the estimated components \eqn{\alpha_i \beta_j / \mu}. If this plot shows a substantially non-zero
#'     slope, \eqn{b}, this analysis suggests that a power transformation, \eqn{ y \rightarrow y^(1-b)} might reduce the
#'     apparent interaction effects.
#' @param x a \code{class("twoway")} object
#' @param which one of \code{"fit"} or \code{"diagnose"}
#' @param main plot title
#' @param ylab Y axis label for \code{"fit"} plot
#' @param annotate  A logical value; if \code{TRUE}, the slope and power are displayed in the diagnostic plot
#' @param rfactor for the \code{"fit"} method, draw lines for \code{abs(residuals) > rfactor*sqrt(MSPE)}
#' @param rcolor  for the \code{"fit"} method, a vector of length 2 giving the color of lines for positive and negative residuals
#' @param ... other arguments passed down
#' @importFrom graphics plot text abline arrows segments
#' @importFrom stats lm coef
#' @return For the \code{"diagnose"} plot, a list with elements \code{c("slope", "power")} is returned invisibly
#' @author Michael Friendly
#' @export
#' @examples
#' data(sentRT)
#' twoway(sentRT)
#' plot(twoway(sentRT), ylab="Reaction Time")
#' plot(twoway(sentRT), which="diagnose")

plot.twoway <- function(x, which=c("fit", "diagnose"), main, ylab,
                        annotate=TRUE,
                        rfactor=1,
                        rcolor=c("blue", "red"),
                        ...) {
  which <- match.arg(which)
  resp <- x$responseName
  vnames <- x$varNames

  # TODO: do both plots in a single call??

  if(which=="fit") {
    if (missing(main)) main <- paste0("Tukey two-way fit plot for ", x$name, " (method: ", x$method, ")")
    if (missing(ylab)) ylab <- "Fitted value"
    roweff <- x$roweff
    coleff <- x$coleff
    r <- length(roweff)
    c <- length(coleff)
    all <- x$overal
    clo <- min(coleff) + all
    chi <- max(coleff) + all
    from <- cbind(clo - roweff, clo + roweff)
    to   <- cbind(chi - roweff, chi + roweff)

    rlo <- min(roweff)
    rhi <- max(roweff)
    from <- rbind(from,  cbind(coleff + all - rhi, coleff + all + rhi))
    to   <- rbind(to,    cbind(coleff + all - rlo, coleff + all + rlo))
    colnames(from) <- c("x", "y")
    colnames(to)   <- c("x", "y")

    labs <- c(names(roweff), names(coleff))

    # find the plot range to include residuals and labels
    fit <- outer(x$roweff, x$coleff, "+") + x$overall
    dat <- fit + x$residuals
    dif <- t(outer(coleff+all, roweff,  "-"))  # colfit - roweff
    ylim <- range(rbind(dat, fit))
    ylim <- ylim + c(-.25, .1)* range(rbind(dat,fit))

    # coordinates of vertices in the plot are (fit, dif)
    plot( rbind(from, to), main=main, type="n",
          #          col=rep(c("red", "blue"), times= c(r, c)),
          asp=1,
          ylim = ylim,
          ylab = ylab,
          xlab=" Column Fit - Row Effect",
          ...)


    indr <- 1:r
    indc <- (r+1):(r+c)
    # labels for rows and columns
    # TODO: tweak label positions with an offset
    off <- c(0, .5)
    text(to[indr,], labs[indr], srt=45, pos=4, offset=c(0.1,0.5), xpd=TRUE)
    text(to[(r+1):(r+c),], labs[(r+1):(r+c)], srt=-45, pos=4, offset=c(0,-.5), xpd=TRUE)
    # draw lines
    segments(from[indr,1], from[indr,2], to[indr,1], to[indr,2])
    segments(from[indc,1], from[indc,2], to[indc,1], to[indc,2])

    # draw lines/arrows for  large residuals
    # TODO should use sqrt(SSPE)
    e <- x$residuals
    MSE <- sum(e^2) / prod(c(r,c)-1)
    sigma <- sqrt(MSE)
    showres <- abs(e) > rfactor * sigma
    clr <- ifelse(e > 0, rcolor[1], rcolor[2])
    #    browser()


    # DONE: vectorize this code !!!

    x.df <- as.data.frame(x)
    bot <- cbind(x.df$dif, x.df$fit)
    top <- cbind(x.df$dif, x.df$data)
    clr <- ifelse(x$residual > 0, rcolor[1], rcolor[2])
    segments(bot[,1], bot[,2], top[,1], top[,2], col = clr)

    #     re <- outer(roweff, rep(1,r))
    #     cf <- outer(rep(1,c), coleff) + all
    #     for (i in 1:r) {
    #       for (j in 1:c) {
    #         bot <- c(dif[i,j], fit[i,j])
    # #        bot <- c( (cf[i,j]-re[i,j]), (cf[i,j]+re[i,j]) )
    #         top <- bot + c(0, e[i,j])
    #         segments(bot[1], bot[2], top[1], top[2], col = clr[i,j])
    #       }
    #     }

  }
  # diagnostic plot
  else {
    if (missing(main)) main <- paste0("Tukey additivity plot for ", x$name, " (method: ", x$method, ")")
    # comp <- c(outer(x$roweff, x$coleff)/x$overall)
    # res <- c(x$residuals)
    # plot(comp, x$residuals, main = main,
    #      xlab = "Diagnostic Comparison Values",
    #      ylab = "Interaction Residuals",
    #      ...)
    # fit <- lm(res ~ comp)
    # abline(fit)
    # abline(h = 0, v = 0, lty = "dotted")

    x.df <- as.data.frame(x)
    plot(residual ~ nonadd, data=x.df,
         main = main,
         cex = 1.2,
         pch = 16,
         xlab = expression("Comparison Values = roweff * coleff /" * hat(mu)),
         ylab = sprintf("Residuals from %s ~ %s + %s", resp, vnames[1], vnames[2]),
#         ylab = expression("Residual from y ~ row + col"),
         ...)
    fit <- lm(residual ~ nonadd, data=x.df)
    abline(fit, lwd=2)
    abline(h = 0, v = 0, lty = "dotted")
#    slope <- coef(fit)[2]
    slope <- x$slope
    power <- 1 - slope
    cat("Slope of Residual on comparison value: ", round(slope,1),
        "\nSuggested power transformation:        ", round(power,1),
        "\n")

    if (is.logical(annotate) && annotate) {
      if( slope > 0 ) {
        loc <- c(min(x.df$nonadd), .95*max(x.df$residual))
        pos=4
      }
      else {
        loc <- c(max(x.df$nonadd), .95*max(x.df$residual))
        pos=2
      }

      text(loc[1], loc[2],
           paste("Slope:", round(slope,1), "\nPower:", round(power,1)),
           pos=pos)
    }

    # TODO: Identify unusual points
    # TODO: Optionally, add confidence limits for lm line, or add loess smooth??
    invisible(list(slope=slope, power=power))

  }
}
