
# Default date for plotting
r_date="2020-07-21"

# Filename of raw shapefiles (see readme for where to access these)
raw_shp_dir="Local_Authority_Districts__December_2019__Boundaries_UK_BUC-shp"

# Filename of raw estimates of R from LocalCovidTracker
localcovidtracker_filename="estimated.R.ltlas.2020-10-27.csv"

# Filename of cleaned shapefiles
output_shp_filenames="uk_2019_local_authority_districts"


# Clean the Covid19 data from the LocalCovidTracker
data_covid19:
	Rscript src/data/clean_covid19_data.R \
		"data/raw/${localcovidtracker_filename}" \
		"data/processed/${localcovidtracker_filename}"

# Clean the shapefile (for this simple example, this script only moves the shapefile)
# (more in-depth scripts may use this script to clean/simplify the shapefile)
data_shapefile:
	rm -rf "data/processed/shp"; mkdir -p "data/processed/shp"
	
	Rscript src/data/clean_shapefile_data.R \
		"data/raw/${raw_shp_dir}" \
		"data/processed/shp" \
		"${output_shp_filenames}"

# Create a map of R in England and Wales
map: data_covid19 data_shapefile
	Rscript src/visualisation/create_map_r_ew.R \
		"data/processed/${localcovidtracker_filename}" \
		"$(r_date)" \
		"data/processed/shp" \
		"${output_shp_filenames}" \
		"output/figures/"


# Create a map of R in England and Wales (no prerequisite cleaning steps)
map_only:
	Rscript src/visualisation/create_map_r_ew.R \
		"data/processed/${localcovidtracker_filename}" \
		"$(r_date)" \
		"data/processed/shp" \
		"output/figures/"


adjacency_matrix:
	Rscript src/data/make_adjacency_from_shapefile.R \
		"data/processed/shp/" \
		"data/processed/lad19cd_adjacency_matrix.csv" \
		"data/processed/neighbours_201215.rda"
