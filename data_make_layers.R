rm(list=ls())

year.range <- 2009:2023

for(i in year.range){

data <- read.csv(paste0("data/processed_VMS_data", i, ".csv"), header=T)


# Now calculate swept area and aggregate with unit conversions
data <- data %>%
  # Calculate swept area ratio with proper unit conversions
  mutate(
    csquare_area = csquare_area(Csquare),
    swept_area_ratio = SweptArea / csquare_area,
    subsurface_sar =  SubsurfaceSweptArea/csquare_area) %>%
  # Group and summarize
  group_by(Year, MetierL5, Csquare) %>%
  summarise(
    NoVessels = sum(NoDistinctVessels, na.rm=T),
    total_fishing_hours = sum(FishingHour, na.rm = TRUE),
    total_weight_kg = sum(TotWeight, na.rm = TRUE),
    total_value_euro = sum(TotValue, na.rm = TRUE),
    swept_area_ratio = sum(swept_area_ratio, na.rm = TRUE),
    subsurface_sar = sum(subsurface_sar, na.rm=TRUE),
    .groups = 'drop'
  )

data$wkt <- wkt_csquare(lat = csquare_lat(data$Csquare), lon = csquare_lon(data$Csquare))

write.table(data, paste0("data/vms_export_", i, ".csv"), sep = ";", row.name = FALSE)

}
