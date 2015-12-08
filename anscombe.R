
## load data (from R)
data("anscombe")

## inspect top of daya
head(anscombe)

## helper function: run regressionof x_i, y_i 
runReg <- function(id, dat) {
    x <- dat[,id]
    y <- dat[,id+4]
    fit <- lm(y ~ x)
    sumfit <- summary(fit)
    M <- cbind(coef(sumfit), c(sumfit$r.squared, sumfit$adj.r.squared))
    colnames(M)[5] <- "Rsq+AdjRsq"
    cat("Index: ", id, "\n")
    print(M, digits=3)
    cat("\n")
    invisible(list(sumfit, M))
}

plotAnscombe <- function(x, dat) {

    op <- par(mfrow=c(2,2), mar=c(3,3,0,1), oma=c(0,0,3,0))
    for (id in 1:4) {
        x <- dat[,id]
        y <- dat[,id+4]
        plot(x, y, pch=18, cex=1.5, col='orange', xlim=c(0,20), ylim=c(0,20))
        fit <- lm(y ~ x)
        abline(lm(y ~ x), col='blue')
        legend("topleft", legend=c(paste0("Intercept:  ", format(coef(fit)[1], digits=3)),
                                   paste0("Slope    :  ", format(coef(fit)[2], digits=3)),
                                   paste0("AdjRsquare: ", format(summary(fit)$adj.r.squared, digits=3))),
               bty="n")
    }
    par(op)
    title(main="Anscombe's Quartet", outer=TRUE, line=-2)
}

