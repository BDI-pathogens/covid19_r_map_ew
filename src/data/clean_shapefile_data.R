#!/usr/bin/env Rscript 
# 
# Script to read shapefile of UK and save in known location (can also be used to simplify
# the shapefile if needed; removed for this simple version).  
# 
# W. Probert, 24 October 2020

suppressWarnings(suppressMessages(library(rgdal))) # for readOGR(), writeOGR()

################
# Preamble
# --------------
cat("\tReading command-line arguments\n")
args <- commandArgs(trailingOnly = TRUE)
input_data_dir <- args[1]
output_data_dir <- args[2]
output_shp_filenames <- args[3]

#################
# Read datasets
# ---------------

# Read shapefile (has one less code that COVID19 data from govt dashboard)
shp_full <- readOGR(file.path(input_data_dir))


#################
# Process shapefile
# ---------------

# No processing needed for simple map
shp <- shp_full


#################
# Save shapefile
# ---------------

writeOGR(shp, 
    file.path(output_data_dir),
    file.path(output_shp_filenames),
    driver = "ESRI Shapefile")
