#!/usr/bin/env Rscript
# 
# Script to produce a map of a particular metric

suppressWarnings(suppressMessages(library(tidyverse))) # for tidy goodness
suppressWarnings(suppressMessages(library(ggplot2))) # for ggplot()
suppressWarnings(suppressMessages(library(broom))) # for tidy()
suppressWarnings(suppressMessages(library(rgdal))) # for readOGR(), writeOGR()


################
# Preamble
# --------------
cat("\tReading command-line arguments\n")
args <- commandArgs(trailingOnly = TRUE)
input_covid19_data_file <- args[1]
date_to_plot <- args[2]
input_shp_dir <- args[3]
input_shp_filenames <- args[4]
output_fig_filename <- args[5]


#################
# Read datasets
# ---------------

# Read shapefile (has one less code that COVID19 data from govt dashboard)
shp_full <- readOGR(file.path(input_shp_dir))
df_shp <- tidy(shp_full)

# Preserve the metadata
df_metadata <- subset(shp_full@data, select = c("lad19cd", "lad19nm"))
df_metadata$id <- as.character(0:(NROW(df_metadata) - 1))

df_rt_ltla <- read.csv(file.path(input_covid19_data_file), stringsAsFactors = FALSE)
df_rt_ltla$date <- as.Date(df_rt_ltla$date)

df_rt_ltla_sub <- subset(df_rt_ltla, date == as.Date(date_to_plot))
df_rt_ltla_sub$lad19cd <- df_rt_ltla_sub$ltla_code

#################
# Merge metric via LTLA code
# ---------------

df_shp <- left_join(df_shp, subset(df_metadata, select = c("id", "lad19cd")), by = "id")
df_shp <- left_join(df_shp, subset(df_rt_ltla_sub, select = c("R", "lad19cd")), by = "lad19cd")

#############
# Plotting parameters
# ----------

R_LIMITS <- c(0, 3.5)
TITLE <- "Instantaneous reproduction number, R"
SUBTITLE <- paste("England and Wales; estimate on", date_to_plot)
CAPTION <- paste0(
    "Data from: https://bdi-pathogens.shinyapps.io/LocalCovidTracker/\n", 
    "Date accessed: 27 October 2020")

#################
# Create map
# ---------------

map <- ggplot(df_shp, 
    aes(x = long, y = lat, group = group)) + 
    geom_polygon(aes(fill = R)) + 
    coord_fixed() + 
    xlab("") + ylab("") + 
    scale_fill_viridis_c(limits = R_LIMITS) + 
    theme_void() + 
    labs(
        title = TITLE, subtitle = SUBTITLE, caption = CAPTION)

ggsave(file.path(output_fig_filename), map, 
    height = 6, width = 6, units = "in")
