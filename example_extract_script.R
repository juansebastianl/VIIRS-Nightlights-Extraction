######################################################################################################
# example_extract_script.R
# Written by Juan Sebastian Lozano
# Description: 
#   This is an example of how to extract the nightlights data from rasters in R
# INPUT:  ../gadm36_levels_gpkg/gadm36_levels.gpkg (download from https://gadm.org/download_world.html)
#         ./*_*_*.TIF (luminosity rasters downloaded from the previous step)
# OUTPUT: ./example_luminosity.csv
######################################################################################################

library(sf)
library(raster)
library(tidyverse)
library(exactextractr) # much faster than the raster package commands 
library(future.apply)

# As an example we will extract the mean luminosity for every ADMIN 3 region in South Sudan

# Load the South Sudan geopackage file
world <- st_read("../gadm36_levels_gpkg/gadm36_levels.gpkg", "level3")
south_sudan <- world %>%
                 filter(NAME_0 == "South Sudan")

rm(world)
                
# Output from last script
viirs_filenames <- list.files("./", "\\.TIF", full.names = T)

years <- str_split(viirs_filenames, "_") %>% 
            sapply(`[`, 1) %>% 
            {gsub("\\./", "", .)} %>% 
            as.numeric()

months <- str_split(viirs_filenames, "_") %>% 
  sapply(`[`, 2) %>% 
  as.numeric()


##############
# Generic extraction function
##############
extract_nightlights <- function(filename, year,month, 
                                shapefile = world, 
                                gid = "GID_3", 
                                fun = "mean"){
  tibble(
    year = year, 
    month = month, 
    gid = shapefile %>% st_drop_geometry() %>% select(gid = {{gid}}) %>% `$`(gid),
    luminosity = exact_extract(raster(filename), shapefile, fun)
  ) %>% 
  return()
}

# The extraction process is often a memory-limited process, so paralleling might slow things down 
# If on a machine where the process becomes cpu-limted rather than memory limited, then parallelizing 
# can make sense.
plan("multisession")

luminosity_panel <- 
  future_mapply(extract_nightlights, viirs_filenames, years, months,
         MoreArgs = list(shapefile = south_sudan),  
         SIMPLIFY = F) %>% 
  bind_rows()

luminosity_panel %>% write_csv("./example_luminosity.csv")
