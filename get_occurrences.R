library(tidyverse)
library(spocc)
library(doParallel)
library(foreach)

source("get_species.R") #two variables: comadre (the DB) and species (char vector)

T0 <- Sys.time()
ncores <- detectCores() - 2
registerDoParallel(ncores)

foreach (taxon = species, 
         .combine = "rbind") %dopar% {
           
           df <- occ(query = taxon, 
                     from = c("gbif", 
                              "bison", 
                              "ecoengine", 
                              "idigbio", 
                              "ala", 
                              "vertnet"), 
                     # limit = 10
                     ecoengineopts = list(limit = 20000),
                     vertnetopts = list(limit = 50000),
                     alaopts = list(limit = 20000),
                     idigbioopts = list(limit = 50000),
                     bisonopts = list(limit = 50000),
                     gbifopts = list(limit = 100000)
           )
           
           res <- bind_rows(
             tryCatch(df$vertnet$data[[1]] %>% 
                        transmute(species = name, 
                                  lon = as.numeric(longitude), 
                                  lat = as.numeric(latitude),
                                  year = as.numeric(year),
                                  record = basisofrecord,
                                  coordinate_uncertainty = as.numeric(coordinateuncertaintyinmeters),
                                  institution = occurrenceid) %>% 
                        add_column(database = 'Vertnet'),
                      error = function(e) return(tibble(
                        species = NA, 
                        lon = NA, 
                        lat = NA,
                        year = NA,
                        record = NA,
                        coordinate_uncertainty = NA,
                        institution = NA
                      ))),
             tryCatch(df$bison$data[[1]] %>% 
                        transmute(species = providedScientificName, 
                                  lon = as.numeric(longitude), 
                                  lat = as.numeric(latitude),
                                  year = as.numeric(year),
                                  record = basisOfRecord,
                                  coordinate_uncertainty = NA,
                                  institution = institutionID) %>% 
                        add_column(database = 'Bison'),
                      error = function(e) return(tibble(
                        species = NA, 
                        lon = NA, 
                        lat = NA,
                        year = NA,
                        record = NA,
                        coordinate_uncertainty = NA,
                        institution = NA
                      ))),
             tryCatch(df$ecoengine$data[[1]] %>% 
                        transmute(species = name, 
                                  lon = longitude, 
                                  lat = latitude, 
                                  year = year(as.Date(end_date)), # might be a character
                                  record = observation_type,
                                  coordinate_uncertainty = as.numeric(coordinate_uncertainty_in_meters),
                                  institution = key) %>% 
                        add_column(database = 'Ecoengine'),
                      error = function(e) return(tibble(
                        species = NA, 
                        lon = NA, 
                        lat = NA,
                        year = NA,
                        record = NA,
                        coordinate_uncertainty = NA,
                        institution = NA
                      ))),
             tryCatch(df$gbif$data[[1]] %>% 
                        transmute(species = name, 
                                  lon = longitude, 
                                  lat = latitude, 
                                  year = as.numeric(year), 
                                  record = basisOfRecord,
                                  coordinate_uncertainty = as.numeric(coordinateUncertaintyInMeters),
                                  institution = institutionCode) %>% 
                        add_column(database = 'GBIF'),
                      error = function(e) return(tibble(
                        species = NA, 
                        lon = NA, 
                        lat = NA,
                        year = NA,
                        record = NA,
                        coordinate_uncertainty = NA,
                        institution = NA
                      ))),
             tryCatch(df$idigbio$data[[1]] %>% 
                        transmute(species = canonicalname, 
                                  lon = longitude, 
                                  lat = latitude, 
                                  year = year(as.Date(datecollected)), 
                                  record = basisofrecord,
                                  coordinate_uncertainty = as.numeric(coordinateuncertainty),
                                  institution = institutioncode) %>%
                        add_column(database = 'Idigbio'),
                      error = function(e) return(tibble(
                        species = NA, 
                        lon = NA, 
                        lat = NA,
                        year = NA,
                        record = NA,
                        coordinate_uncertainty = NA,
                        institution = NA
                      ))),
             tryCatch(df$ala$data[[1]] %>% 
                        transmute(species = name, 
                                  lon = longitude, 
                                  lat = latitude, 
                                  year = as.numeric(year), 
                                  record = basisOfRecord,
                                  coordinate_uncertainty = as.numeric(coordinateUncertaintyInMeters),
                                  institution = institutionUid) %>%
                        add_column(database = 'ALA'),
                      error = function(e) return(tibble(
                        species = NA, 
                        lon = NA, 
                        lat = NA,
                        year = NA,
                        record = NA,
                        coordinate_uncertainty = NA,
                        institution = NA
                      )))
           ) %>% 
             filter(!is.na(lon), !is.na(lat)) 
           
           write_csv(res, paste0('Data/', taxon, '.csv'))
           
           if (nrow(res) > 0) {
             res <- res %>% 
               mutate(species = Hmisc::capitalize(species)) %>% 
               # mutate(species = map(species, function(x)
               #  paste(str_split(x, ' ', simplify = TRUE)[1],
               #     str_split(x, ' ', simplify = TRUE)[2])
               # )) %>% 
               unnest(cols = c(species))
             
             return(res)
           } else {
             res <- tibble(
               species = NA, 
               lon = NA, 
               lat = NA,
               year = NA,
               record = NA,
               coordinate_uncertainty = NA,
               institution = NA,
               database = NA
             )
             return(res)
           }
           
         } -> records

stopImplicitCluster()
Sys.time() - T0

completed <- list.files('Data', pattern = 'csv') %>% 
  gsub('[.]csv', '', .)

if (!all(species %in% completed)){
  warning('Not all species were processed')
}

completed <- list.files('Data', pattern = 'csv', full.names = TRUE)
res <- list()
for (file in completed){
  res[[which(completed == file)]] <- read_csv(file, col_types = cols()) %>% 
    mutate(species = gsub('[.]csv', '', str_split(file, '/', simplify = TRUE)[[2]]))
}

bind_rows(res) %>% 
  write_csv("records.csv")

rm(completed, res)
