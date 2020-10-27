#!/usr/bin/env Rscript 
# 
# Script to clean a range of epi datasets from LocalTracker Shiny dashboard.  
# 
# W. Probert, 24 October 2020

################
# Preamble
# --------------
cat("\tReading command-line arguments\n")
args <- commandArgs(trailingOnly = TRUE)
input_data_file <- args[1]
output_data_file <- args[2]

#################
# Read datasets
# ---------------

# ----------------
# SHINY APP R DATA
# ----------------
cat("\tReading Rt estimates from LocalCovidTracker\n")
df_rt_ltla <- read.csv(file.path(input_data_file), stringsAsFactors = FALSE)

df_rt_ltla <- subset(df_rt_ltla, select = c("Area", "AreaCode", "Dates", "R"))
names(df_rt_ltla) <- c("ltla_name", "ltla_code", "date", "R")
df_rt_ltla$date <- as.Date(df_rt_ltla$date)

# Sort data on LTLA code, then date
df_rt_ltla <- df_rt_ltla[order(df_rt_ltla$ltla_name, df_rt_ltla$date), ]

# Subset columns of interest
df_rt_ltla <- df_rt_ltla[, c("ltla_code", "ltla_name", "date", "R")]

####################
cat(paste0("\tSave dataset to file at:\n\t\t", file.path(output_data_file), "\n"))

write.csv(df_rt_ltla, 
    file.path(output_data_file), 
    row.names = FALSE)
