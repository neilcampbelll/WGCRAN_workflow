
## Process raw VMS database extract into usable format
rm(list=ls())
year.range <- c(2009:2023)

source("scripts/data_libraries.R")
# source("scripts/data_rpt_process.R") run this once to import the database table format from Carlos' extract
source("scripts/data_process.R")
source("scripts/data_aggregate_across_layers.R")
source("scripts/data_make_layers.R")
