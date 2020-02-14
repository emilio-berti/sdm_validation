library(tidyverse)
library(raster)
library(dismo)
library(spThin)
library(doParallel)
library(foreach)


'%ni%' <- Negate('%in%')
r_tmp <- getData(name = "worldclim", 
                 var = "tmean",
                 res = 2.5,
                 download = TRUE, 
                 path = tempdir())

r_tmp <- r_tmp[[1]]

grin <- function(x){
  grinned <- gridSample(x, r_tmp, n = 1) %>% 
    as.data.frame()
  gc()
  thinned <- thin.algorithm(grinned, thin.par = 10, reps = 1)[[1]] %>% 
    as_tibble() %>% 
    mutate(species = taxon)
  gc()
  return(thinned)
}


marine_families <- c("Balaenidae", "Balaenopteridae", 
                     "Delphinidae", "Dugongidae", "Eschrichtiidae", 
                     "Iniidae", "Monodontidae", "Neobalaenidae", 
                     "Odobenidae", "Otariidae", "Phocidae",
                     "Phocoenidae", "Physeteridae", "Platanistidae",
                     "Trichechidae", "Ziphiidae")

marine_species <- read_csv("https://raw.githubusercontent.com/MegaPast2Future/PHYLACINE_1.2/master/Data/Traits/Trait_data.csv") %>% 
  transmute(Family.1.2,
            Binomial.1.2 = gsub("_", " ", Binomial.1.2)) %>% 
  filter(Family.1.2 %in% marine_families) %>% 
  pull(Binomial.1.2)

d <- read_csv('cleaned_records.csv') %>% 
  filter(species %ni% marine_species) %>% 
  group_by(species) %>% 
  add_tally() %>% 
  ungroup() %>% 
  arrange(n)

done <- list.files("Data_grinned/") %>% 
  gsub("[.]csv", "", .)

sp <- unique(d$species) %>% 
  setdiff(done)

# To much memory required for my machine with 8 Gb
# ncores <- detectCores() - 5
# registerDoParallel(ncores)
foreach(taxon = sp, 
        .combine = "rbind") %do% {
          # prepare for thinning
          occ <- d %>% 
            filter(species == taxon) %>% 
            dplyr::select(decimallongitude,
                          decimallatitude) %>% 
            coordinates()
          print(paste0("Working on ", 
                       taxon,
                       ": n = ",
                       nrow(occ),
                       "."))
          # grinning
          grinned <- tryCatch(grin(occ),
                              error = function(e){
                                empt <- tibble(Longitude = NA, 
                                               Latitude = NA, 
                                               species = taxon)
                                return(empt)
                              })
          # write to file
          write_csv(grinned, paste0("Data_grinned/", taxon, ".csv"))
        }
#stopImplicitCluster()

completed <- list.files("Data_grinned", pattern = "csv", full.names = TRUE)
res <- list()
for (file in completed){
  res[[which(completed == file)]] <- read_csv(file, col_types = cols())
}
res <- bind_rows(res)

write_csv(res, "grinned_cleaned_records.csv")

res %>% 
  group_by(species) %>% 
  tally() %>% 
  arrange(n) %>% 
  filter(n >= 30) %>% 
  knitr::kable()

species <- res %>% 
  group_by(species) %>% 
  tally() %>% 
  arrange(n) %>% 
  filter(n >= 30) %>% 
  pull(species)

mass <- read_csv("https://raw.githubusercontent.com/MegaPast2Future/PHYLACINE_1.2/master/Data/Traits/Trait_data.csv") %>% 
  mutate(Species = gsub("_", " ", Binomial.1.2)) %>% 
  filter(Species %in% species) %>% 
  dplyr::select(Species, Mass.g)

# thin again all species together
# res <- res %>% 
#   dplyr::select(-species) %>% 
#   as.data.frame()
# 
# thinned <- thin.algorithm(res, thin.par = 5, reps = 1)[[1]]

r_tmp[!is.na(r_tmp)] <- 1
pdf("Figures/occ_map.pdf", width = 8, height = 3.5)
par(mar = c(0, 0, 0, 0))
plot(r_tmp, col = "gray80",
     frame = FALSE, legend = FALSE,
     box = FALSE, axes = FALSE)
points(res$Longitude, res$Latitude, 
       pch = 21, cex = 0.01,
       col = rgb(0.2, 0.2, 0.6, 0.1))
dev.off()
