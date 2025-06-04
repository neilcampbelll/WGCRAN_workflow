# WGCRAN_workflow
Code for processing ICES VMS and logbook data to deliver the data products requested by WGCRAN, June 2025.

## Overview

This repository contains R scripts for downloading, processing, and aggregating Vessel Monitoring System (VMS) and logbook data from the ICES database. The workflow produces standardised outputs including swept area calculations, fishing effort metrics, and spatial data products for ecosystem impact assessments.

## Repository Structure

```
WGCRAN_workflow/
├── data.R                           # Main processing pipeline
├── scripts/
│   ├── data_libraries.R             # Required R packages
│   ├── data_download_raw_data.R     # Download VMS data from ICES
│   ├── data_process.R               # Core data processing and swept area calculations
│   ├── data_aggregate_across_layers.R  # Data aggregation and standardisation
│   ├── data_make_layers.R           # Layer creation and export formatting
│   ├── data_check.R                 # Data quality checks
│   └── data_rpt_process.R           # Process database extract files
├── WGCRAN_Script.R                  # WGCRAN-specific output generation
├── data/                            # Data storage directory
└── output/                          # Generated outputs
```

## Dependencies

### Required R Packages
- `dplyr` - Data manipulation
- `tidyr` - Data tidying
- `icesVMS` - ICES VMS data access
- `vmstools` - VMS data processing tools
- `sf` - Spatial data handling
- `sfdSAR` - Swept area ratio calculations
- `ggplot2` - Data visualisation
- `readr` - Data import/export

Install dependencies with:
```r
install.packages(c("dplyr", "tidyr", "icesVMS", "vmstools", "sf", "sfdSAR", "ggplot2", "readr"))
```

## Usage

### Complete Processing Pipeline
Run the entire workflow for years 2009-2023:
```r
source("data.R")
```

### Individual Processing Steps

1. **Download raw VMS data**:
```r
source("scripts/data_download_raw_data.R")
```

2. **Process and calculate swept areas**:
```r
source("scripts/data_process.R")
```

3. **Aggregate and standardise data**:
```r
source("scripts/data_aggregate_across_layers.R")
```

4. **Generate export layers**:
```r
source("scripts/data_make_layers.R")
```

### WGCRAN-Specific Outputs
Generate WGCRAN deliverables (beam trawl data for BE, DE, NL, DK):
```r
source("WGCRAN_Script.R")
```

## Key Features

### Data Processing
- **Automatic gear width calculation** using ICES Benthis parameters
- **Swept area computation** for surface and subsurface impacts
- **Metier standardisation** using RDB ISSG classifications
- **Vessel anonymisation** for data confidentiality
- **Quality control** including unit standardisation

### Output Formats
- **Shapefiles** with UTM 29N projection for GIS analysis
- **WKT text files** for database import
- **CSV files** with standardised headers
- **C-square aggregation** at 0.05° resolution

### Filtering Options
- **Country-specific** processing
- **Metier-level** filtering (L4-L6)
- **Temporal** subsetting by year/month
- **Gear type** selection

## Data Products

### Standard Outputs
Each processed year generates:
- `VMS{year}_with_swept_area.rds` - Processed VMS data with calculated swept areas
- `processed_VMS_data{year}.csv` - Standardised aggregated data
- `vms_export_{year}.csv` - Export-ready layer data

### WGCRAN Deliverables
- `CRAN_DATA_{year}.shp` - Spatial data in ESRI Shapefile format
- `CRAN_DATA_{year}.wkt` - WKT format for database applications

## Configuration

### Year Range
Modify `year.range` in relevant scripts to process specific years:
```r
year.range <- c(2020:2023)  # Process 2020-2023 only
```

### Geographic Scope
Update country filters in `WGCRAN_Script.R`:
```r
filter(country %in% c("BE", "DE", "NL", "DK"))
```

### Metier Selection
Modify metier filters for different gear types:
```r
filter(leMetLevel6 %in% c("TBB_CRU_16-31_0_0", "TBB_DEF_16_31_0_0"))
```

## Data Quality

### Known Issues
- Finnish vessel length data requires unit conversion (2021+)
- Some countries may have incomplete gear width parameters
- Vessel anonymisation applied when <3 vessels per C-square

### Quality Checks
Run data validation:
```r
source("scripts/data_check.R")
```

## References

- ICES VMS data: https://www.ices.dk/data/data-portals/Pages/VMS.aspx
- Benthis methodology: https://benthis.eu/
- RDB ISSG Metier classifications: ICES data standards

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

For questions or issues, please open a GitHub issue or contact the repository maintainer.
