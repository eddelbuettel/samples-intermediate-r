library(dplyr)

## from lesson 3
### Examples from vignette(s)
## 2014 (Jan - Oct) flights data
flights <- data.table::fread("https://github.com/arunsrinivasan/flights/wiki/NYCflights14/flights14.csv", showProgress=FALSE)

## a data.frame replacement / alternative from dplyr
tbl <- as.tbl(flights)


# select() to select columns (also: rename())
# filter() to filter rows (also:  slice()) 
# arrange() to re-order or arrange rows
# mutate() to create new columns
# summarise() to summarise values
# group_by() for group operations (ie split-apply-combine)
# distinct(), sample_n(), sample_frac()

## Examples

# select() for columns:
select(tbl, carrier, flight)  # to select one or more columns
select(tbl, -cancelled)       # to exclude by name
select(tbl, flight:distance)  # for range from first to last


# filter() for rows:
filter(tbl, air_time >= 60, arr_delay > 20)     # for 1, 2, ... conds  
filter(tbl, carrier %in% c("AA", "UA"))         # standard R funcs
filter(tbl, carrier == "AA" | carrier == "UA")  # for OR
slice(tbl, 1:10)                                # selects rows by position 

# arrange() for re-ordering by column(s):
tbl %>% arrange(year, month, day)
arrange(tbl, year, month, day)      # same thing without pipe
arrange(tbl, desc(arr_delay))

tbl %>% 
    group_by(carrier) %>%
    summarise(avg_arr_delay = mean(arr_delay),
              avg_dep_delay = mean(dep_delay),
              total = n()) %>% 
    arrange(desc(avg_arr_delay))

# mutate() to add columns
tbl %>% mutate(gain = arr_delay - dep_delay,
               speed = distance / air_time * 60)

tbl %>% mutate(gain = arr_delay - dep_delay,
               speed = distance / air_time * 60) %>% 
    select(carrier:speed) %>% 
    arrange(desc(speed))

tbl %>% mutate(gain = arr_delay - dep_delay,
               gain_per_hour = gain / (air_time / 60))
               
tbl %>% transmute(gain = arr_delay - dep_delay,
                  gain_per_hour = gain / (air_time / 60))

## grouping example
by_tailnum <- group_by(tbl, tailnum)
delay <- summarise(by_tailnum,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE))
delay <- filter(delay, count > 20, dist < 2000)

# Interestingly, the average delay is only slightly related to the
# average distance flown by a plane.
library(ggplot2)
ggplot(delay, aes(dist, delay)) +
    geom_point(aes(size = count), alpha = 1/2) +
    geom_smooth() +
    scale_size_area()
               
## grouping and summaries
destinations <- group_by(tbl, dest)
summarise(destinations,
          planes = n_distinct(tailnum),
          flights = n()
)
