library(tidyverse)
# install Rcompadre if not already installed
if (!requireNamespace("Rcompadre", quietly = TRUE)){
  devtools::install_github("jonesor/Rcompadre")
}
library(Rcompadre)

comadre <- cdb_fetch("comadre") #get newest version of COMADRE
comadre <- cdb_flag(comadre) %>% #flag dataset
  filter(!check_NA_A, #remove matrices with NAs
         check_ergodic, #get only ergodic matrices (needed for asymptotic lambda)
         !is.na(Lon), !is.na(Lat)) #remove rows without GPS coordinates

# 116 populations
comadre %>% 
  filter(Class == "Mammalia") %>% 
  mutate(Lon = round(Lon, 1), #approximate GPS location
         Lat = round(Lat), 1) %>% #think carefully about the threshold
  group_by(SpeciesAccepted, Lon, Lat) %>% #group by populations
  tally()

# 37 populations with more >= 3 data points at different year
comadre %>% 
  filter(Class == "Mammalia") %>% 
  mutate(Lon = round(Lon, 1), #approximate GPS location
         Lat = round(Lat), 1) %>% #think carefully about the threshold
  group_by(SpeciesAccepted, Lon, Lat) %>% #group by populations
  tally() %>% 
  filter(n >= 3)

# 84 species 
comadre %>% 
  filter(Class == "Mammalia") %>%
  as_tibble() %>% 
  pull(SpeciesAccepted) %>% 
  unique()

# 36 species with more >= 3 data points at different year
comadre %>% 
  filter(Class == "Mammalia") %>% 
  mutate(Lon = round(Lon, 1), #approximate GPS location
         Lat = round(Lat), 1) %>% #think carefully about the threshold
  group_by(SpeciesAccepted, Lon, Lat) %>% #group by populations
  tally() %>% 
  filter(n >= 3) %>% 
  pull(SpeciesAccepted) %>% 
  unique()

# get species to work with, in this case all mammals with valid entries: ergodic
# matrices without NAs and geolocalized populations
species <- comadre %>% 
  filter(Class == "Mammalia") %>%
  as_tibble() %>% 
  pull(SpeciesAccepted) %>% 
  unique() %>% 
  gsub("_", " ", .) #species names were not consistent

# remove sub-species
species <- sapply(species, function(x)
  paste(str_split(x, " ", simplify = TRUE)[1],
        str_split(x, " ", simplify = TRUE)[2])) %>% 
  unique()
