
# Get headers and widths from database extract file
con <- file("LE_Data_all_21_01_2025/VMS_Data_all_21_01_2025.rpt", "r")
first_lines <- readLines(con, n = 10)
close(con)

# Get column widths from the dashes line
widths <- nchar(strsplit(first_lines[7], "(?<=\\s)(?=\\S)|(?<=\\S)(?=\\s)", perl=TRUE)[[1]])

# Get column names from line 6
col_names <- strsplit(first_lines[6], "(?<=\\s)(?=\\S)|(?<=\\S)(?=\\s)", perl=TRUE)[[1]]
col_names <- trimws(col_names)  # Remove any whitespace

## read the .rpt file
data <- read_fwf("LE_Data_all_21_01_2025/VMS_Data_all_21_01_2025.rpt",
                 fwf_widths(widths),
                 skip = 7)

## extract column names
names(data) <- col_names

## drop the non-informative columns
data <- data[, seq(1, ncol(data), by = 2)]

## assign names back to the data
names(data) <- col_names[seq(1, length(col_names), by = 2)]


# First, remove the trailing rows with mostly NAs
data <- data %>%
  # Keep only rows where at least some key columns have values
  filter(!is.na(country) & !is.na(year) & !is.na(month))

# Then process the data types
data <- data %>%
  mutate(
    # Already handled these three
    totvalue = as.numeric(ifelse(totvalue == "NULL", NA, totvalue)),
    ICES_avg_fishing_speed = as.numeric(ifelse(ICES_avg_fishing_speed == "NULL", NA, ICES_avg_fishing_speed)),
    avg_gearWidth = as.numeric(ifelse(avg_gearWidth == "NULL", NA, avg_gearWidth)),
    
    # Convert remaining numeric fields
    avg_fishing_speed = as.numeric(ifelse(avg_fishing_speed == "NULL", NA, avg_fishing_speed)),
    fishing_hours = as.numeric(ifelse(fishing_hours == "NULL", NA, fishing_hours)),
    avg_oal = as.numeric(ifelse(avg_oal == "NULL", NA, avg_oal)),
    avg_kw = as.numeric(ifelse(avg_kw == "NULL", NA, avg_kw)),
    kw_fishinghours = as.numeric(ifelse(kw_fishinghours == "NULL", NA, kw_fishinghours)),
    totweight = as.numeric(ifelse(totweight == "NULL", NA, totweight)),
    
    # Convert integer-like fields
    UniqueVessels = as.numeric(ifelse(UniqueVessels == "NULL", NA, UniqueVessels)),
    SessionID = as.numeric(ifelse(SessionID == "NULL", NA, SessionID)),
    NumberOfRecords = as.numeric(ifelse(NumberOfRecords == "NULL", NA, NumberOfRecords)),
    
    # Convert interval to numeric
    AverageInterval = as.numeric(ifelse(AverageInterval == "NULL", NA, AverageInterval)),
    
    # Convert SweptArea to numeric
    SweptArea = as.numeric(ifelse(SweptArea == "NULL", NA, SweptArea)),
    
    # Character fields - standardize NULL to NA for consistency
    HabitatType = ifelse(HabitatType == "NULL", NA, HabitatType),
    DepthRange = ifelse(DepthRange == "NULL", NA, DepthRange)
  )


saveRDS(data, "data/VMS2025.rds")

