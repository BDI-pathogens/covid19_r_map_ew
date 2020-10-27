`covid19_r_map_ew`
-----------------

R code for creating a map of R(t) for England and Wales using data from [LocalCovidTracker](https://bdi-pathogens.shinyapps.io/LocalCovidTracker/).  


Overview
--------

Two datasets are required to run this script: shapefiles of the UK and estimates of R(t).  


**Data**

* Estimates of R(t) by Lower Tier Local Authority (LTLA) are available from [LocalCovidTracker](https://bdi-pathogens.shinyapps.io/LocalCovidTracker/).  Within the "Daily tracker" tab, adjust the date range to include the date of interest and select "Lower Tier Local Authority" from the "Area type of interest" drop down menu, and click "Download CSV" on the "Instantaneous reproduction number" panel.  The downloaded filename should be of the form `estimated.R.ltlas.*.csv` when downloaded from the Shiny App.  This file should be placed within the folder `data/raw` and it's full name should be updated within the `Makefile` (the `localcovidtracker_filename` variable).  
* Shapefiles of the UK with 2019 Local Authority District codes are available from the [ONS](https://geoportal.statistics.gov.uk/datasets/3a4fa2ce68f642e399b4de07643eeed3_0).  Download the "Shapefiles" from this website and put the uncompressed folder within `data/raw` of this repository.  The uncompressed folder name should be called `Local_Authority_Districts__December_2019__Boundaries_UK_BUC-shp` and should include five different files.  


**Usage**


Once downloaded, the following command wil clean both the R(t) and Shapefile data and produce a map for the date specified.  
```
make r_date="2020-04-23" map
```

Simply calling `make map` will produce a map for for 21st July 2020 (`2020-07-21`) by default.  


Requirements
-------------

The R scripts within this repository require the following packages: `rgdal, rmapshaper, broom, tidyverse, ggplot2`.  
