
library(data.table)
## or quietly: suppressMessages(library(data.table))

## read directly from our repo
gs <- fread(paste0("https://raw.githubusercontent.com/eddelbuettel/",
                   "samples-intermediate-r/master/lesson02/",
                   "ncis_bystate_bymonth_bytype.csv"))

## see tables already read
tables()

## set a key; here on multiple columns
setkey(gs, state, year, month)

## helper function like sum on all data:
gs[,sum(guns_sold)]

## fast grouping
gs[,sum(guns_sold),by=state][1:10]
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
gs[,sum(guns_sold),by=year]

## two variables
gs[, sum(guns_sold), by="state,year"][1:10]



### Examples from vignette(s)
## 2014 (Jan - Oct) flights data
flights <- fread("https://github.com/arunsrinivasan/flights/wiki/NYCflights14/flights14.csv")

head(flights)

dim(flights)

### General idea:     DT[i, j, by]
###
### SQL equivalent:   where i    select    group by


## work on i -- Subset rows

## work on i -- select by two criteria
ans <- flights[origin == "JFK" & month == 6L]

## work on i -- or just two rows
flights[1:2]

## work on i -- sort by two criteria
ans <- flights[order(origin, -dest)]


## select in j -- select column 
ans <- flights[, arr_delay]        # as vector
ans <- flights[, list(arr_delay)]  # as data.table
ans <- flights[, .(arr_delay)]     # same, shorthand


## select in j -- select several and rename
ans <- flights[, .(delay_arr = arr_delay, delay_dep = dep_delay)]

## select in j -- compute
ans <- flights[, sum((arr_delay + dep_delay) < 0)]

## i and j -- subset and compute
ans <- flights[origin == "JFK" & month == 6L, 
               .(m_arr=mean(arr_delay), m_dep=mean(dep_delay))]


## i,j,by -- delays at JFK across year
ans <- flights[origin == "JFK",  .(m_arr=mean(arr_delay), m_dep=mean(dep_delay)), by=month]


## how many trips from JFK in June?
flights[origin == "JFK" & month == 6L, length(dest)]   # really length() of any column
flights[origin == "JFK" & month == 6L, .N]             # shorthand


## what if we want columns by name as in data.frame?  specify 'with=FALSE'
ans <- flights[, c("arr_delay", "dep_delay"), with=FALSE]


## aggregation using by
## how many trips departing at each airport?
ans <- flights[, .(.N), by=.(origin)]


## use 'keyby' for different sort order
ans <- flights[carrier == "AA", .(avgarr=mean(arr_delay), avgdep=mean(dep_delay)), 
               keyby=.(origin, dest, month)]

## 'chaining' to efficiently combine queries
ans <- flights[carrier == "AA", .N, by=.(origin, dest)][order(origin, -dest)]


## expressions in by
ans <- flights[, .N, .(dep_delay>0, arr_delay>0)]


## .SD -- subset of data created by grouping with by,
## .SDcols -- select columns
flights[carrier == "AA",                     ## Only on trips with carrier "AA"
        lapply(.SD, mean),                   ## compute the mean
        by=.(origin, dest, month),           ## for every 'origin,dest,month'
        .SDcols=c("arr_delay", "dep_delay")] ## for just those specified in .SDcols



## Examples of :=

## Assign new columns
flights[, `:=`(speed = distance/(air_time/60), # in km/hr
               delay = arr_delay+dep_delay)]   # in min

## Delete
flights[, c("delay") := NULL]  # deletes instantly

## Assign along with by
flights[, max_speed := max(speed), by=.(origin, dest)]

## Multiple columns
in_cols  <- c("dep_delay", "arr_delay")
out_cols <- c("max_dep_delay", "max_arr_delay")
flights[, c(out_cols) := lapply(.SD, max), by = month,
        .SDcols = in_cols]
