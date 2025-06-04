
  
  
  library(dplyr)
  library(icesVMS)
  library(vmstools)
  library(sf)

  for(i in 2023){  
  
  vms <- readRDS(paste0("data/VMS", i, "_with_swept_area.RDS"))
  temp <- vms %>%
    dplyr::select(country, year, month, cSquare, leMetLevel6, fishingHours, 
                  kwFishinghours, totweight, totvalue, uniqueVessels, anonVessels) %>%
    filter(country %in% c("BE", "DE", "NL", "DK"), 
           leMetLevel6 %in% c("TBB_CRU_16-31_0_0", "TBB_DEF_16_31_0_0")) %>%
    group_by(cSquare) %>%
    summarise(
      fishingHours = sum(fishingHours),
      kwFishinghours = sum(kwFishinghours),
      totweight = sum(totweight),
      totvalue = sum(totvalue),
      # Calculate LPUE and price after summarising the raw values
      LPUE = sum(totweight) / sum(kwFishinghours),
      price = sum(totvalue) / sum(totweight),
      # Create a mask column - TRUE if 1-2 vessels (needs masking), FALSE if 3+ vessels
      Mask = n_distinct(anonVessels) < 3,
      # Store the vessel count for reference
      vessels = n_distinct(anonVessels)
    )
  
  # create a geometry field in well-known text format
temp$geometry <- wkt_csquare(vmstools::CSquare2LonLat(temp$cSquare, 0.05)$SI_LATI, vmstools::CSquare2LonLat(temp$cSquare, 0.05)$SI_LON)

  # convert the data frame to a spatial object, and reproject to UTM 29N
temp <- st_as_sf(temp, wkt = "geometry", crs = 4236) %>%
  st_transform(crs=32629)

  # save as a shapefile and a text file
write_sf(temp, paste0("output/CRAN_DATA_", i, ".shp"))
write.table(temp, paste0("output/CRAN_DATA_", i, ".wkt"), sep = ";")

}

# sort(unique(vms$leMetLevel6))

# "TBB_CRU_16-31_0_0", "TBB_DEF_16_31_0_0"
# 