

gs <- read.csv("ncis_bystate_bymonth_bytype.csv")


saveRDS(gs, file="/tmp/NYTimesGunSalesData.rds")

newgs <- readRDS("/tmp/NYTimesGunSalesData.rds")

identical(newgs, gs)

object.size(gs)

file.info("/tmp/NYTimesGunSalesData.rds")$size

webgs <- read.csv(paste0("https://raw.githubusercontent.com/NYTimes/"
                   "gun-sales/master/data/ncis_bystate_bymonth_bytype.csv"))
identical(gs, webgs)
