
# This is a live feed for the code for the Princeton OPR broom seminar

fit <- lm(mpg ~ wt + qsec, data = mtcars)
summary(fit)

# install.packages("broom")
library(broom)


tidy(fit)
augment(fit)
glance(fit)

### UN Data

load(url("http://varianceexplained.org/courses/WS1015/files/undata-213.RData"))

# install.packages("dplyr")
library(dplyr)

x <- tbl_df(x)
x

100 %>% log(10)

sin(log(cos(exp(3)), 2))
3 %>% exp() %>% cos() %>% log(2) %>% sin()

View(x)

# install.packages("stringr")
# install.packages("lubridate")

library(stringr)
library(lubridate)

votes <- x %>%
  select(rcid, date, unres, vote, country = uniquename) %>%
  filter(vote < 4) %>%
  mutate(country = str_sub(country, 2, -2),
         unres = str_sub(unres, 2, -2),
         date = ymd(date),
         year = year(date))

by_year <- votes %>%
  group_by(year) %>%
  summarize(number_yes = sum(vote == 1),
            percent_yes = mean(vote == 1),
            total = n())

by_country <- votes %>%
  group_by(country) %>%
  summarize(number_yes = sum(vote == 1),
            percent_yes = mean(vote == 1),
            total = n()) %>%
  filter(total > 100)

by_country %>%
  arrange(desc(percent_yes))

by_country %>%
  arrange(percent_yes)

by_country %>% filter(country == "South Africa")

library(ggplot2)

ggplot(by_year, aes(x = year, y = percent_yes)) +
  geom_line() +
  geom_smooth()

by_year_country <- votes %>%
  group_by(country, year) %>%
  summarize(number_yes = sum(vote == 1),
            percent_yes = mean(vote == 1),
            total = n())

interesting_countries <- c("United States of America",
                           "United Kingdom",
                           "India",
                           "Sweden",
                           "China",
                           "France")
by_year_country %>%
  filter(country %in% interesting_countries) %>%
  ggplot(aes(x = year, y = percent_yes)) +
  geom_line() +
  facet_wrap(~country)

US <- by_year_country %>%
  filter(country == "United States of America")

US_fit <- lm(percent_yes ~ year, data = US)
summary(US_fit)

linear_mods <- by_year_country %>%
  group_by(country) %>%
  do(mod = lm(percent_yes ~ year, data = .))

tidied <- linear_mods %>%
  tidy(mod) %>%
  ungroup() %>%
  filter(term == "year")

ggplot(tidied, aes(estimate, p.value)) +
  geom_point() +
  scale_y_log10() +
  geom_text(aes(label = country), check_overlap = TRUE) +
  xlim(-.025, .025)

by_year_country %>%
  filter(country == "Marshall Islands") %>%
  ggplot(aes(year, percent_yes)) +
  geom_line()

tidied %>%
  mutate_each(funs(round(., 2)), estimate:p.value)
