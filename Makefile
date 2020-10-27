

raw_shp_dir="Local_Authority_Districts__December_2019__Boundaries_UK_BUC-shp"
output_shp_filenames="uk_2019_local_authority_districts"
date_of_interest="2020-07-21"

data_covid19:
	Rscript src/data/clean_covid19_data.R \
		"data/raw/estimated.R.ltlas.2020-10-27.csv" \
		"data/processed/estimated.R.ltlas.2020-10-27.csv"

data_shapefile:
	rm -rf "data/processed/shp"; mkdir -p "data/processed/shp"
	
	Rscript src/data/clean_shapefile_data.R \
		"data/raw/${raw_shp_dir}" \
		"data/processed/shp" \
		"${output_shp_filenames}"

map: data_covid19 data_shapefile
	Rscript src/visualisation/create_map_r_ew.R \
		"data/processed/estimated.R.ltlas.2020-10-27.csv" \
		"${date_of_interest}" \
		"data/processed/shp" \
		"${output_shp_filenames}" \
		"output/figures/map_r_ew_${date_of_interest}.png"
