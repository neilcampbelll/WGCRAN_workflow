clean_data <- processed_data %>%
  mutate(AverageGearWidth = as.numeric(AverageGearWidth)) %>%
  group_by(CountryCode) %>%
  summarise(
    min_width = min(AverageGearWidth, na.rm = TRUE),
    max_width = max(AverageGearWidth, na.rm = TRUE),
    unique_values = n_distinct(AverageGearWidth),
    sample_values = paste(head(sort(unique(AverageGearWidth)), 5), collapse = ", ")
  )

print(clean_data)

missing_countries <- c("FR", "ES", "IE", "PT", "LV", "IS", "FI", "NO")

raw_check <- processed_data %>%
  filter(CountryCode %in% missing_countries) %>%
  group_by(CountryCode) %>%
  summarise(
    n_records = n(),
    n_na = sum(is.na(AverageGearWidth)),
    sample_values = paste(head(unique(AverageGearWidth), 5), collapse = ", ")
  )

print(raw_check)

# Let's also look at the structure of a few specific values
processed_data %>%
  filter(CountryCode %in% missing_countries) %>%
  select(CountryCode, AverageGearWidth) %>%
  head(10)

# And check for any non-numeric characters
processed_data %>%
  filter(CountryCode %in% missing_countries) %>%
  filter(!is.na(AverageGearWidth)) %>%
  mutate(has_non_numeric = grepl("[^0-9\\.-]", AverageGearWidth)) %>%
  filter(has_non_numeric) %>%
  select(CountryCode, AverageGearWidth) %>%
  head(10)