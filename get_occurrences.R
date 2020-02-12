library(tidyverse)
library(spocc)

source("get_species.R") #two variables: comadre (the DB) and species (char vector)

occ_data <- list()

# loop to get data for all species and combine the databases into one tibble.
# Output will be stored in a names list with elements the occurrence for each
# species
for (x in species) {
  d <- occ(x, from = c("gbif", "bison", 
                       "inat", "ecoengine", 
                       "vertnet", "idigbio",
                       "obis", "ala")) #not ebird
  
  occ_data[[x]] <- lapply(names(d), function(y){
    if (nrow(d[[y]]$data[[1]]) > 0) {
      d[[y]]$data[[1]] %>% 
        transmute(Species = x,
                  Long = as.numeric(longitude),
                  Lat = as.numeric(latitude),
                  Source = prov) %>% 
        filter(!is.na(Long), !is.na(Lat)) %>% 
        unique()
    }
  }) %>% 
    bind_rows() %>% 
    unique()
}
