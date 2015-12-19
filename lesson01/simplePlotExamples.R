
## standard graphics device
library(stats)
plot(nhtemp, main = "nhtemp data", ylab = "Mean annual temp. in F)")

## using dygraphs
library(dygraphs)
fig <- dygraph(nhtemp, main = "New Haven Temperatures")
fig <- dyAxis(fig, "y", label = "Temp (F)", valueRange = c(40, 60))
fig <- dyOptions(fig, axisLineWidth = 1.5, fillGraph = TRUE, drawGrid = FALSE)
fig
