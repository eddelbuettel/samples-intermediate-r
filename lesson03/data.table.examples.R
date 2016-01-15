
library(data.table)
## or quietly: suppressMessages(library(data.table))

## read directly from our repo
gs <- fread(paste0("https://raw.githubusercontent.com/eddelbuettel/",
                   "samples-intermediate-r/master/lesson02/",
                   "ncis_bystate_bymonth_bytype.csv"))
## or:  gs <- fread("ncis_bystate_bymonth_bytype.csv")
## see tables already read
tables()

## set a key; here on multiple columns
setkey(gs, state, year, month)

## helper function like sum on all data:
gs[,sum(guns_sold,na.rm=TRUE)]

## fast grouping
gs[,sum(guns_sold,na.rm=TRUE),by=state][1:10]
##                    state       V1
##  1:              Alabama  4996174
##  2:               Alaska  1012582
##  3:              Arizona  3183790
##  4:             Arkansas  2683605
##  5:           California 11009000
##  6:             Colorado  5512891
##  7:          Connecticut  1395864
##  8:             Delaware   416998
##  9: District of Columbia     4203
## 10:              Florida  9175229

## or
gs[,sum(guns_sold,na.rm=TRUE),by=year]

## two variables
gs[,sum(guns_sold,na.rm=TRUE),by="state,year"][1:10]



### Examples from vignette(s)
## 2014 (Jan - Oct) flights data
flights <- fread("https://github.com/arunsrinivasan/flights/wiki/NYCflights14/flights14.csv")

head(flights)

dim(flights)

### General idea:     DT[i, j, by]
###
### SQL equivalent:   where i   select    group by

