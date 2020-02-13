library(CoordinateCleaner)
library(tidyverse)
library(raster)
library(sf)

# import csv files
d <- read_csv("records.csv") %>% 
  transmute(species, 
            database,
            decimallongitude = lon,
            decimallatitude = lat, 
            year, 
            record = str_to_upper(record),
            coordinate_uncertainty)

# clean data using CoordinateCleaner
d <- d %>%
  cc_val() %>% 
  cc_equ() %>% 
  cc_cap() %>% 
  cc_cen() %>% 
  cc_gbif() %>%
  cc_inst() %>%
  cc_sea() %>% 
  cc_zero() %>%
  cc_urb()

d <- d %>% 
  cc_dupl(species = "species",
          lon = "decimallongitude", 
          lat = "decimallatitude")

# need to check numbers that we get. Maybe we also exclude after 2000 to match
# WorldClim database. Or perhaps same as the Chelsa.
d <- d %>%
  filter(year >= 1950,
         coordinate_uncertainty <= 10000 | is.na(coordinate_uncertainty))

# need to check records. For the Cheetah, these were the only available
d <- d %>%
  filter(record == "SPECIMEN" |
           record == "OBSERVATION" |
           record == "HUMAN_OBSERVATION" |
           record == "PRESERVED_SPECIMEN" | 
           record == "IMAGE" | 
           record == "HUMANOBSERVATION" |
           record == "PRESERVEDSPECIMEN" |
           record == "LIVINGSPECIMEN" |
           record == "LIVING_SPECIMEN" |
           record == "MACHINEOBSERVATION" |
           record == "MACHINE_OBSERVATION" |
           record == "LITERATURE")

d %>% 
  group_by(species) %>% 
  tally() %>% 
  arrange(n) %>% 
  filter(n >= 30)

write_csv(d, "cleaned_records.csv")
