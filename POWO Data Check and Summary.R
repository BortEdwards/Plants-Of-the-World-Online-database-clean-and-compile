# Takes two datasets from Plants of the World Online (species and distribution), corrects errors, and combines into a master dataset

require(plyr)
require(dplyr)

# Load data
setwd("/Users/vicki/Dropbox (Smithsonian)/Yale/Vascular Plants/TDWG Keys")
TDWG.L3 <- read.csv("tdwg_wgsrpd_lvl3.txt", sep="*", header = TRUE) # list of TDWG codes and corresponding verbatim strings available from https://github.com/tdwg/wgsrpd/tree/master/109-488-1-ED/2nd%20Edition 
setwd("/Users/vicki/Dropbox (Smithsonian)/Yale/Vascular Plants/WCSP:POWO/POWO/WCSP_species_and_distribution_download_29_aug_2019")
POWO.distr <- read.csv("species_distribution.txt", sep = "|")
POWO.species <- read.csv("species.txt", sep = "|")

# Fix problematic area codes
POWO.distr$area_code_l3 <- toupper(POWO.distr$area_code_l3) # convert lowercase codes to full uppercase
for(x in 1:nrow(TDWG.L3))
  POWO.distr$area_code_l3 <- gsub(TDWG.L3[x,"L3.code"],TDWG.L3[x,"L3.area"], POWO.distr$area_code_l3)

# Tally number of areas each taxon is identified in
area.sums <- as.data.frame(table(POWO.distr$db_id))
colnames(area.sums)<-c('db_id','areas.found.in')
region.sums <- POWO.distr %>% group_by(db_id, region) %>% tally %>% group_by(db_id) %>% tally
region.sums <- rename(region.sums, c("n"="regions.found.in"))
continent.sums <- POWO.distr %>% group_by(db_id, continent) %>% tally %>% group_by(db_id) %>% tally
continent.sums <- rename(continent.sums, c("n"="continents.found.in"))

# join genus and species fields for scientificname field
POWO.species <- transform(POWO.species, scientificname=paste(genus, species, sep=" "))

# select fields from distance and species datasheets to carry forward to master sheet
species.fields <- POWO.species[c("db_id",
                                 "ipni_id",
                                 "family",
                                 "genus",
                                 "species",
                                 "full_name",
                                 "scientificname",
                                 "b_authors"
)]
species.fields <- rename(species.fields, c("b_authors"="authors", "full_name"="verbatim_scientificname"))

distr.fields <- POWO.distr[c("db_id",
                             "continent",
                             "region",
                             "area",
                             "introduced")]

# pull together in single dataframe, make sure empty cells have "NA" value, remove errant tabs
l <- list(species.fields, distr.fields, area.sums, region.sums, continent.sums)
POWO.master <- Reduce(merge, lapply(l, data.table, keep.rownames = FALSE))
POWO.master[POWO.master == ""] <- NA
gsub("\t", "", "POWO.master")

setwd("/Users/vicki/Dropbox (Smithsonian)/Yale/Vascular Plants/WCSP:POWO")
write.table(POWO.master,'POWO.MOLmaster.txt', sep="|", quote=FALSE, row.names = FALSE) # output as text file
