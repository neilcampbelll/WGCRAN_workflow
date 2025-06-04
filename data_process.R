

# get metiers table (updated April 2024)
rdb_metiers <- read.csv("data/RDB_ISSG_Metier_list.csv")

# get gear widths and metier lookup from ICES DB
gear_widths <- icesVMS::get_benthis_parameters()


# First create the expanded reference table including old codes
rdb_metiers_expanded <- rdb_metiers %>%
  select(Metier_level6, Benthis_metiers) %>%
  bind_rows(
    rdb_metiers %>%
      filter(Old_code != "") %>%
      mutate(old_codes = strsplit(Old_code, ", ")) %>%
      unnest(old_codes) %>%
      select(old_codes, Benthis_metiers) %>%
      rename(Metier_level6 = old_codes)
  ) %>%
  distinct()

##SOME OF THE AVERAGE KW VALUES IN THE DATABASE ARE ZEROS - DEPRECATE THIS FOR NOW AND USE FIXED VALUES
##
# Combined operations with subsurfaceProp and impact calculations
#data <- data %>%
#  left_join(
#    rdb_metiers_expanded %>%
#      distinct(Metier_level6, .keep_all = TRUE),
#    by = c("LE_MET_level6" = "Metier_level6")
#  ) %>%
#  rename(benthisMetier = Benthis_metiers) %>%
#  mutate(benthisMetier = na_if(benthisMetier, "")) %>%
#  left_join(
#    gear_widths %>%
#      select(benthisMet, firstFactor, secondFactor, gearModel, gearCoefficient, subsurfaceProp) %>%
#      mutate(subsurfaceProp = as.numeric(subsurfaceProp)),  # Convert to numeric here
#    by = c("benthisMetier" = "benthisMet")
#  ) %>%
#  mutate(
#    gearWidth_model = predict_gear_width(gearModel, 
#                                         gearCoefficient, 
#                                         .)
#  ) %>%
#  mutate(
#    # Calculate distance traveled in km
#    distance_traveled = fishing_hours * (avg_fishing_speed * 1.852),
#    
#    # Calculate swept area in km²
#    swept_area = distance_traveled * (gearWidth_model / 1000),
#    
#    # Calculate subsurface impact area in km²
#    subsurface = distance_traveled * (gearWidth_model / 1000) * (as.numeric(subsurfaceProp) / 100)
#  )

## NEW CODE HERE


for(i in 2009:2023){
  
# read in VMS data
data <- readRDS(paste0("data/VMS", i, ".RDS"))

if(i >= 2021){
  data$avgOal[data$country == "FI"] <- data$avgOal[data$country == "FI"] / 100
}

#data <- data %>%
#  # First join with rdb_metiers as you were doing before
#  left_join(
#    rdb_metiers_expanded %>%
#      distinct(Metier_level6, .keep_all = TRUE),
#    by = c("leMetLevel6" = "Metier_level6")
#  ) %>%
#  rename(benthisMetier = Benthis_metiers) %>%
#  mutate(benthisMetier = na_if(benthisMetier, "")) %>%
  
  # Now join with the gear_widths table, but use gearWidth directly
#  left_join(
#    gear_widths %>%
#      select(benthisMet, gearWidth, subsurfaceProp) %>%  # Use gearWidth instead of other parameters
#      mutate(subsurfaceProp = as.numeric(subsurfaceProp)),
#    by = c("benthisMetier" = "benthisMet")
#  ) %>%
# Calculate swept area directly using the gearWidth from the table
#  mutate(
    # Calculate distance traveled in km
#    distance_traveled = fishingHours * (avgFishingSpeed * 1.852),
    
#    swept_area = distance_traveled * gearWidth,
    
    # Calculate subsurface impact area in km²
#    subsurface = swept_area * (as.numeric(subsurfaceProp) / 100)
    
#  )


data <- data %>%
  # First join with rdb_metiers as you were doing before
  left_join(
    rdb_metiers_expanded %>%
      distinct(Metier_level6, .keep_all = TRUE),
    by = c("leMetLevel6" = "Metier_level6")
  ) %>%
  rename(benthisMetier = Benthis_metiers) %>%
  mutate(benthisMetier = na_if(benthisMetier, "")) %>%
  
  # Now join with the gear_widths table, including all relevant parameters
  left_join(
    gear_widths %>%
      select(benthisMet, gearModel, gearCoefficient, firstFactor, secondFactor, subsurfaceProp),
    by = c("benthisMetier" = "benthisMet")
  ) %>%
  
  # Calculate the gear width dynamically based on the model and parameters
  mutate(
    # Choose the coefficient value based on gearCoefficient
    coef_value = case_when(
      gearCoefficient == "avg_kw" ~ avgKw,
      gearCoefficient == "avg_oal" ~ avgOal,
      TRUE ~ NA_real_
    ),
    
    # Calculate gear width based on the model
    calculated_gearWidth = case_when(
      gearModel == "linear" ~ (firstFactor * coef_value) + secondFactor,  # aLOA + b
      gearModel == "power" ~ firstFactor * (coef_value ^ secondFactor), # a(kW^b)
      TRUE ~ NA_real_
    ),
    
    # Calculate distance traveled in km
    distance_traveled = fishingHours * (avgFishingSpeed * 1.852),
    
    # Use the calculated gear width for swept area
    swept_area = distance_traveled * (calculated_gearWidth/1000),
    
    # Calculate subsurface impact area in km²
    subsurface = swept_area * (as.numeric(subsurfaceProp) / 100)
  )

saveRDS(data, paste0("data/VMS", i, "_with_swept_area.rds"))

}
