 year.range <- c(2009:2023)

for(i in year.range){
  data <- readRDS(paste0("data/VMS", i, "_with_swept_area.rds")
                  
  # Transform and aggregate the data
  processed_data_complete <- data %>%
    tidyr::as_tibble() %>%
    select(country, year, month, cSquare, vesselLengthCategory, gearCode, leMetLevel6, avgFishingSpeed, fishingHours, avgOal,avgKw,
           kwFishinghours, totweight, totvalue, uniqueVessels, anonVessels, averageInterval, swept_area, subsurface)
    
        transmute(
      RecordType = recordtype,
      CountryCode = country,
      Year = as.numeric(year),
      Month = as.numeric(month),
      NoDistinctVessels = UniqueVessels,
      AnonymizedVesselID = AnonVessels,
      Csquare = c_square,
      MetierL4 = gear_code,
      MetierL5 = paste(gear_code, LE_MET_level5, sep="_"),
      MetierL6 = LE_MET_level6,
      VesselLengthRange = vessel_length_category,
      NumberOfRecords = as.numeric(NumberOfRecords),
      AverageFishingSpeed = as.numeric(avg_fishing_speed),
      FishingHour = as.numeric(fishing_hours),
      AverageInterval = as.numeric(AverageInterval),
      AverageVesselLength = as.numeric(avg_oal),
      AveragekW = as.numeric(avg_kw),
      kWFishingHour = as.numeric(kw_fishinghours),
      # Use swept_area as the column is now named in your data
      SweptArea = as.numeric(swept_area),
      # Use subsurface as the column is now named
      SubsurfaceSweptArea = as.numeric(subsurface),
      TotWeight = as.numeric(totweight),
      TotValue = as.numeric(totvalue),
      # Use gearWidth as it's now called in your data
      AverageGearWidth = as.numeric(gearWidth)
    ) %>%
    group_by(CountryCode, Year, Month, Csquare, MetierL4, MetierL5, MetierL6, VesselLengthRange) %>%
    summarise(
      No_Records = sum(NumberOfRecords),
      AverageFishingSpeed = weighted.mean(AverageFishingSpeed, NumberOfRecords, na.rm = TRUE),
      FishingHour = sum(FishingHour),
      AverageInterval = weighted.mean(AverageInterval, NumberOfRecords, na.rm = TRUE),
      AverageVesselLength = weighted.mean(AverageVesselLength, NumberOfRecords, na.rm = TRUE),
      AveragekW = weighted.mean(AveragekW, NumberOfRecords, na.rm = TRUE),
      kWFishingHour = sum(kWFishingHour, na.rm = TRUE),
      SweptArea = sum(SweptArea, na.rm = TRUE),
      SubsurfaceSweptArea = sum(SubsurfaceSweptArea, na.rm = TRUE),
      TotWeight = sum(TotWeight, na.rm = TRUE),
      TotValue = sum(TotValue, na.rm = TRUE),
      AverageGearWidth = weighted.mean(AverageGearWidth, NumberOfRecords, na.rm = TRUE),
      AnonymizedVesselID = {
        distinct_vessels <- unique(unlist(strsplit(AnonymizedVesselID, ";")))
        if (length(distinct_vessels) >= 3 || "not_required" %in% distinct_vessels) {
          "not_required"
        } else {
          paste(sort(distinct_vessels), collapse = ";")
        }
      },
      NoDistinctVessels = {
        distinct_vessels <- unique(unlist(strsplit(AnonymizedVesselID, ";")))
        if (length(distinct_vessels) >= 3 || "not_required" %in% distinct_vessels) {
          "3"
        } else {
          as.character(length(distinct_vessels))
        }
      },
      RecordType = "VE"
    ) %>%
    select(
      RecordType,
      CountryCode,
      Year,
      Month,
      NoDistinctVessels,
      AnonymizedVesselID,
      Csquare,
      MetierL4,
      MetierL5,
      MetierL6,
      VesselLengthRange,
      AverageFishingSpeed,
      FishingHour,
      AverageInterval,
      AverageVesselLength,
      AveragekW,
      kWFishingHour,
      TotWeight,
      TotValue,
      SweptArea,
      SubsurfaceSweptArea,
      AverageGearWidth
    ) %>%
    as.data.frame()
  
  
  processed_data_incomplete <- data %>%
    tidyr::as_tibble() %>%
    filter(year == i,
           (is.na(HabitatType) | is.na(DepthRange) | is.na(NumberOfRecords)),
           country %in% c("ES", "PT", "NO")) %>%
    transmute(
      RecordType = recordtype,
      CountryCode = country,
      Year = as.numeric(year),
      Month = as.numeric(month),
      NoDistinctVessels = as.character(UniqueVessels),
      AnonymizedVesselID = case_when(
        as.numeric(UniqueVessels) >= 3 ~ "not_required",
        TRUE ~ AnonVessels
      ),
      Csquare = c_square,
      MetierL4 = gear_code,
      MetierL5 = paste(gear_code, LE_MET_level5, sep="_"),
      MetierL6 = LE_MET_level6,
      VesselLengthRange = vessel_length_category,
      NumberOfRecords = NA,
      AverageFishingSpeed = as.numeric(avg_fishing_speed),
      FishingHour = as.numeric(fishing_hours),
      AverageInterval = as.numeric(AverageInterval),
      AverageVesselLength = as.numeric(avg_oal),
      AveragekW = as.numeric(avg_kw),
      kWFishingHour = as.numeric(kw_fishinghours),
      TotWeight = as.numeric(totweight),
      TotValue = as.numeric(totvalue),
      AverageGearWidth = as.numeric(gearWidth),
      # Use the calculated fields from your data directly
      SweptArea = as.numeric(swept_area),
      SubsurfaceSweptArea = as.numeric(subsurface)
    ) %>%
    group_by(CountryCode, Year, Month, Csquare, MetierL4, MetierL5, MetierL6, VesselLengthRange) %>%
    summarise(
      No_Records = sum(NumberOfRecords, na.rm = TRUE),
      AverageFishingSpeed = mean(AverageFishingSpeed, na.rm = TRUE),
      FishingHour = sum(FishingHour, na.rm = TRUE),
      AverageInterval = mean(AverageInterval, na.rm = TRUE),
      AverageVesselLength = mean(AverageVesselLength, na.rm = TRUE),
      AveragekW = mean(AveragekW, na.rm = TRUE),
      kWFishingHour = sum(kWFishingHour, na.rm = TRUE),
      SweptArea = sum(SweptArea, na.rm = TRUE),
      SubsurfaceSweptArea = sum(SubsurfaceSweptArea, na.rm = TRUE),
      TotWeight = sum(TotWeight, na.rm = TRUE),
      TotValue = sum(TotValue, na.rm = TRUE),
      AverageGearWidth = mean(AverageGearWidth, na.rm = TRUE),
      NoDistinctVessels = as.character(max(as.numeric(NoDistinctVessels), na.rm = TRUE)),
      AnonymizedVesselID = if(max(as.numeric(NoDistinctVessels), na.rm = TRUE) >= 3) "not_required" else paste(sort(unique(AnonymizedVesselID)), collapse = ";"),
      RecordType = "VE"
    ) %>%
    select(
      RecordType,
      CountryCode,
      Year,
      Month,
      NoDistinctVessels,
      AnonymizedVesselID,
      Csquare,
      MetierL4,
      MetierL5,
      MetierL6,
      VesselLengthRange,
      AverageFishingSpeed,
      FishingHour,
      AverageInterval,
      AverageVesselLength,
      AveragekW,
      kWFishingHour,
      TotWeight,
      TotValue,
      SweptArea,
      SubsurfaceSweptArea,
      AverageGearWidth
    ) %>%
    as.data.frame()
  
  processed_data <- bind_rows(processed_data_complete, processed_data_incomplete)
  
  # Write the output
  write.table(processed_data, 
              file = paste0("data/processed_VMS_data", i, ".csv"), 
              row.names = FALSE, 
              col.names = TRUE, 
              sep = ",")
  
print(paste0("Processing complete for ", i, "."))

}

