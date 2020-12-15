#!/usr/bin/env Rscript 
# 
# W. Probert, 24 October 2020

suppressWarnings(suppressMessages(library(rgdal))) # for readOGR(), writeOGR()
suppressWarnings(suppressMessages(library(sp))) # for poly2nb(), nb2mat()
suppressWarnings(suppressMessages(library(spdep)))
suppressWarnings(suppressMessages(library(raster))) # so that aggregate() is in the right namespace
suppressWarnings(suppressMessages(library(broom))) # for tidy()
suppressWarnings(suppressMessages(library(tidyverse))) # for left_join()

suppressWarnings(suppressMessages(library(ggplot2))) # incase plotting is done

################
# Preamble
# --------------
cat("\tReading command-line arguments\n")
args <- commandArgs(trailingOnly = TRUE)
input_data_dir <- args[1]
output_matrix <- args[2]
output_rds <- args[3]

#################
# Read datasets
# ---------------

# Read shapefile (has one less code that COVID19 data from govt dashboard)
shp_full <- readOGR(file.path(input_data_dir), stringsAsFactors = FALSE)


#################
# Process shapefile
# ---------------

# Subset to England and Wales
shp_ew <- subset(shp_full, grepl("E|W", lad19cd))

# Create new LAD name and code
shp_ew@data$new_lad19cd <- shp_ew@data$lad19cd
shp_ew@data$new_lad19nm <- shp_ew@data$lad19nm

# Merge Cornwall and Scilly Isles into the Cornwall code/name
shp_ew@data$new_lad19cd[shp_ew@data$new_lad19cd == "E06000053"] <- "E06000052"
shp_ew@data$new_lad19nm[shp_ew@data$new_lad19cd == "E06000052"] <- "Cornwall"


# Merge "City of London" into "Hackney and City of London"
shp_ew@data$new_lad19cd[shp_ew@data$new_lad19cd == "E09000001"] <- "E09000012"
shp_ew@data$new_lad19nm[shp_ew@data$new_lad19cd == "E09000012"] <- "Hackney and City of London"

# Create a merged polygon for the two groups of LTLA's above
shp_ew_api <- aggregate(shp_ew, by = "new_lad19cd")

# Subset to non-duplicate codes and merge metadata
df_sub <- subset(shp_ew@data, !(lad19cd %in% c("E06000053", "E09000001")))
shp_ew_api@data <- merge(shp_ew_api@data, 
        df_sub, by = "new_lad19cd", all.x = TRUE)

# Create a spatial dataframe
df_shp <- tidy(shp_ew_api)

# Merge the metadata
df_metadata <- subset(shp_ew_api@data, select = c("new_lad19cd", "new_lad19nm"))
df_metadata$id <- as.character(1:(NROW(df_metadata)))
df_shp <- left_join(df_shp, 
    subset(df_metadata, select = c("id", "new_lad19cd", "new_lad19nm")), by = "id")

# Check the plot has merged these LTLAs correctly.  
# map <- ggplot(df_shp,
#     aes(x = long, y = lat, group = group)) +
#     geom_polygon(aes(fill = 'red')) +
#     coord_fixed() +
#     xlab("") + ylab("") +
#     geom_polygon(data = subset(df_shp, new_lad19cd == "E09000012"), aes(fill = "blue")) +
#     geom_polygon(data = subset(df_shp, new_lad19cd == "E06000052"), aes(fill = "green"))

#############################
# Create an adjacency matrix
# ---------------------------

neighbours <- poly2nb(shp_ew_api)
neighbours_matrix <- nb2mat(neighbours, style = "B",  zero.policy = TRUE)

# Save neighbours object to disk
save("neighbours", "df_metadata", file = file.path(output_rds))

neighbours_df <- as.data.frame(neighbours_matrix)
row.names(neighbours_df) <- shp_ew_api$new_lad19cd
names(neighbours_df) <- shp_ew_api$new_lad19cd

# Save to matrix to disk
write.csv(neighbours_df, file.path(output_matrix))



#############################
# Print several checks
# ---------------------------

# Loop through the following LTLAs as a basic check check of the bordering LTLAs: 
ltlas_to_check <- c("E06000052", "E09000012", "E07000178", "E07000047")

for(ltla in ltlas_to_check){
    cat("LTLA ", 
        as.vector(unlist(subset(df_metadata, new_lad19cd == ltla, select = "new_lad19nm"))),
        "(", ltla, ")\n")
    
    cat("borders on ")
    borders <- names(neighbours_df)[neighbours_df[ltla] == 1]
    for(b in borders){
        
        cat(as.vector(unlist(subset(df_metadata, new_lad19cd == b, select = "new_lad19nm"))))
        cat("(", b, "), ")
    }
    cat("\n\n")
}
