

gs <- read.csv("ncis_bystate_bymonth_bytype.csv")


saveRDS(gs, file="/tmp/NYTimesGunSalesData.rds")

newgs <- readRDS("/tmp/NYTimesGunSalesData.rds")

identical(newgs, gs)

object.size(gs)

file.info("/tmp/NYTimesGunSalesData.rds")$size

### old URL has changed
##webgs <- read.csv(paste0("https://raw.githubusercontent.com/NYTimes/"
##                         "gun-sales/master/data/ncis_bystate_bymonth_bytype.csv"))
### new URL
##webgs <- read.csv(paste0("https://raw.githubusercontent.com/NYTimes/",
##                         "gun-sales/master/inst/rawdata/ncis_bystate_bymonth_bytype.csv"))
### or our repo
webgs <- read.csv(paste0("https://raw.githubusercontent.com/eddelbuettel/",
                         "samples-intermediate-r/master/lesson02/",
                         "ncis_bystate_bymonth_bytype.csv"))
identical(gs, webgs)
