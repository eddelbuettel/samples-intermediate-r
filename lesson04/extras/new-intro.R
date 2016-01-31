

## part 1 -- getting data
library(dplyr)
library(ggplot2)

curdir <- getwd()
setwd("~/git/samples-intermediate-r/lesson04/extras/dplyr-tutorial")

flights <- tbl_df(read.csv("flights.csv", stringsAsFactors = FALSE))
flights$date <- as.Date(flights$date)

weather <- tbl_df(read.csv("weather.csv", stringsAsFactors = FALSE))
weather$date <- as.Date(weather$date)

planes <- tbl_df(read.csv("planes.csv", stringsAsFactors = FALSE))

airports <- tbl_df(read.csv("airports.csv", stringsAsFactors = FALSE))
setwd(curdir)

flights
weather
planes
airports


## part 2 -- 

sfo <- filter(flights, dest == "SFO")
qplot(date, dep_delay, data = sfo)
qplot(date, arr_delay, data = sfo)
qplot(arr_delay, dep_delay, data = sfo)

qplot(dep_delay, data = flights, binwidth = 10)
qplot(dep_delay, data = flights, binwidth = 1) + xlim(0, 250)

by_day <- group_by(flights, date)
daily_delay <- summarise(by_day, 
  dep = mean(dep_delay, na.rm = TRUE),
  arr = mean(arr_delay, na.rm = TRUE)
)
qplot(date, dep, data = daily_delay, geom = "line")
qplot(date, arr, data = daily_delay, geom = "line")

# What's the best way to measure delay? ---------------------------------------
daily_delay <- by_day %>% 
  filter(!is.na(dep_delay)) %>%
  summarise(
    mean = mean(dep_delay),
    median = median(dep_delay),
    q75 = quantile(dep_delay, 0.75),
    over_15 = mean(dep_delay > 15),
    over_30 = mean(dep_delay > 30),
    over_60 = mean(dep_delay > 60)
  )

qplot(date, mean, data = daily_delay)
qplot(date, median, data = daily_delay)
qplot(date, q75, data = daily_delay)
qplot(date, over_15, data = daily_delay)
qplot(date, over_30, data = daily_delay)
qplot(date, over_60, data = daily_delay)


## 03 pipelines

hourly_delay <- filter(
  summarise(
    group_by(
      filter(flights, !is.na(dep_delay)), 
      date, hour), 
    delay = mean(dep_delay), 
    n = n()), 
  n > 10
)

hourly_delay <- flights %>% 
  filter(!is.na(dep_delay)) %>%
  group_by(date, hour) %>%
  summarise(
    delay = mean(dep_delay),
    n = n()
  ) %>% 
  filter(n > 10)


# Challenges -------------------------------------------------------------------

flights %>%
  group_by(dest) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE), n = n()) %>%
  arrange(desc(arr_delay))

flights %>% 
  group_by(carrier, flight, dest) %>% 
  tally(sort = TRUE) %>%
  filter(n == 365)

flights %>% 
  group_by(carrier, flight, dest) %>% 
  filter(n() == 365)

per_hour <- flights %>%
  filter(cancelled == 0) %>%
  mutate(time = hour + minute / 60) %>%
  group_by(time) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE), n = n())

qplot(time, arr_delay, data = per_hour)
qplot(time, arr_delay, data = per_hour, size = n) + scale_size_area()
qplot(time, arr_delay, data = filter(per_hour, n > 30), size = n) + scale_size_area()

ggplot(filter(per_hour, n > 30), aes(time, arr_delay)) + 
  geom_vline(xintercept = 5:24, colour = "white", size = 2) +
  geom_point()


## 4 -- grouped mutate

# Motivating examples ----------------------------------------------------------

planes <- flights %>%
  filter(!is.na(arr_delay)) %>%
  group_by(plane) %>%
  filter(n() > 30)

planes %>%
  mutate(z_delay = (arr_delay - mean(arr_delay)) / sd(arr_delay)) %>%
  filter(z_delay > 5)

planes %>% filter(min_rank(arr_delay) < 5)

# Ranking functions ------------------------------------------------------------

min_rank(c(1, 1, 2, 3))
dense_rank(c(1, 1, 2, 3))
row_number(c(1, 1, 2, 3))

flights %>% group_by(plane) %>% filter(row_number(desc(arr_delay)) <= 2)
flights %>% group_by(plane) %>% filter(min_rank(desc(arr_delay)) <= 2)
flights %>% group_by(plane) %>% filter(dense_rank(desc(arr_delay)) <= 2)

# Lead and lag -----------------------------------------------------------------

daily <- flights %>% 
  group_by(date) %>% 
  summarise(delay = mean(dep_delay, na.rm = TRUE))

daily %>% mutate(delay - lag(delay))
daily %>% mutate(delay - lag(delay))


## 5 joins

# Motivation: plotting delays on map -------------------------------------------

location <- airports %>% 
  select(dest = iata, name = airport, lat, long)

delays <- flights %>%
  group_by(dest) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE), n = n()) %>%
  arrange(desc(arr_delay)) %>%
  inner_join(location)

ggplot(delays, aes(long, lat)) + 
  borders("state") + 
  geom_point(aes(colour = arr_delay), size = 5, alpha = 0.9) + 
  scale_colour_gradient2() +
  coord_quickmap()

delays %>% filter(arr_delay < 0)


# What weather condition is most related to delays? ----------------------------

hourly_delay <- flights %>% 
  group_by(date, hour) %>%
  filter(!is.na(dep_delay)) %>%
  summarise(
    delay = mean(dep_delay),
    n = n()
  ) %>% 
  filter(n > 10)
delay_weather <- hourly_delay %>% left_join(weather)

arrange(delay_weather, desc(delay))

qplot(temp, delay, data = delay_weather)
qplot(wind_speed, delay, data = delay_weather)
qplot(gust_speed, delay, data = delay_weather)
qplot(is.na(gust_speed), delay, data = delay_weather, geom = "boxplot")
qplot(conditions, delay, data = delay_weather, geom = "boxplot") + coord_flip()
qplot(events, delay, data = delay_weather, geom = "boxplot") + coord_flip()

# Another approach is to look at a specific day and think about
# unusual values
june22 <- filter(flights, date == as.Date("2011-06-22"))
qplot(hour + minute / 60, dep_delay, data = june22)

# What plane conditions are most related to delays? ----------------------------

planes <- tbl_df(read.csv("planes.csv", stringsAsFactors = FALSE))
planes %>% group_by(type) %>% tally()
planes %>% group_by(engine) %>% tally()
planes %>% group_by(type, engine) %>% tally()

qplot(year, data = planes, binwidth = 1)
planes %>% filter(year <= 1960) %>% View()

qplot(no.seats, data = planes, binwidth = 10)
planes %>% filter(no.seats < 10) %>% View()

plane_delay <- flights %>% 
  group_by(plane) %>%
  summarise(
    n = n(),
    dist = mean(dist),
    delay = mean(dep_delay, na.rm = TRUE)
  )
anti_join(plane_delay, planes) %>% arrange(desc(n)) %>% View()
# What's the common pattern?

plane_delay <- plane_delay %>% left_join(planes)

plane_delay %>% arrange(n)
qplot(n, data = plane_delay, binwidth = 1)
qplot(n, data = plane_delay, binwidth = 1) + xlim(0, 250)

plane_delay <- plane_delay %>% filter(n > 50)
qplot(dist, delay, data = plane_delay)

qplot(year, delay, data = plane_delay)
qplot(year, delay, data = plane_delay) + 
  xlim(1990, 2011) + 
  geom_smooth(span = 0.5, method = "loess")


## 6 -- do

options(digits = 3)
# Do with one unnamed argument -------------------------------------------------

# Derived from http://stackoverflow.com/a/23341485/16632
#library(dplyr)
library(zoo)

# Data frame
df <- data.frame(
  houseID = rep(1:10, each = 10), 
  year = 1995:2004, 
  price = ifelse(runif(10 * 10) > 0.50, NA, exp(rnorm(10 * 10)))
)

# . is a pronoun representing the current group

df %>% 
  group_by(houseID) %>% 
  do(na.locf(.))

df %>% 
  group_by(houseID) %>% 
  do(head(., 2))

df %>% 
  group_by(houseID) %>% 
  do(data.frame(year = .$year[1]))


# Do with multiple named arguments ---------------------------------------------
#source("0-data.R")
# How do delays vary over the course of the day?

models <- flights %>% 
  filter(hour >= 5, hour <= 20) %>%
  group_by(date) %>%
  do(
    mod = lm(dep_delay ~ hour, data = .)
  )

models
str(models) # don't do this!
str(models[1, ])

rsq <- function(x) summary(x)$r.squared
fit <- models %>% 
  summarise(date = as.Date(date[1]), rsq = rsq(mod))
fit %>% arrange(desc(rsq))
fit %>% arrange(rsq)

coef_df <- function(x) {
  sc <- coef(summary(x))
  colnames(sc) <- c("est", "se", "t", "P")
  data.frame(coef = rownames(sc), sc)
}
models %>% do(coef_df(.$mod))

hourly <- flights %>%
  filter(hour >= 5, hour <= 20) %>%
  group_by(date, hour) %>%
  summarise(dep_delay = mean(dep_delay))

qplot(hour, dep_delay, data = hourly %>% semi_join(fit %>% filter(rsq > 0.2)), geom = "line") + facet_wrap(~date)
qplot(hour, dep_delay, data = hourly %>% semi_join(fit %>% filter(rsq < 0.001)), geom = "line") + facet_wrap(~date)
