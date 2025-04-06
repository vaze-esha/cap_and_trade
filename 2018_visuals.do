/*==============================================================================
								2018 ONLY 
================================================================================

	PURPOSE:
	
		1. run first stage for all years 
			
		
==============================================================================*/

	* Clear all and set large data arguments.
	macro drop _all 
	clear all
	// version 18.0, user
	set more off 
	set seed 13011
	pause on
/*==============================================================================
						setting user paths and dirs
==============================================================================*/		
	
	// working directory dropbox 
	local workingdir "/Users/eshavaze/Dropbox/cal_cap_and_trade"
	
	// input 
	local input_data "`workingdir'/2_processing"
	
	// output
	local outputs "/Users/eshavaze/Downloads"

	
/*============================================================================*/
	
						// FIRST STAGE REGRESSIONS 
		
/*============================================================================*/

/*==============================================================================
										CLEAN
==============================================================================*/

	use "`input_data'/appended_all_years_2018.dta"
	
	
	encode County, gen(county_id)  // Convert county to numeric ID
	
	// choose max instrument val for 2018 (2 vals based on ces version)
	egen max_instrument = max(instrument) if Year == 2018, by(county_id)

	// Keep only observations where instrument equals the max for each county in 2018
	keep if Year != 2018 | instrument == max_instrument

	//Drop the temporary variable
	drop max_instrument

	
	// SET PANEL 
	xtset county_id Year  // Panel setup (if county-year is panel data)
	
	
	// sum all funding receieved until 2018 by each county
	bysort County (Year): gen cumulative_funding = sum(TOT_funding)
	gen log_cumulative_funding = log(cumulative_funding)
	
	// calculate an average of instrument over the years 
	egen avg_instrument = mean(instrument), by(County Year)

	
/*==============================================================================
								LABEL, SET SCHEME
==============================================================================*/

	label variable log_cumulative_funding "Log(Cumulative Funding)"
	label variable Year ""
	label variable County ""
	label variable avg_instrument Instrument
	
	
	// SET SCHEME
	set scheme s1color
	graph set window fontface "Helvetica"  // Set font to helvetica
	
/*==============================================================================
								SUM STATS
==============================================================================*/
	
	// LOG CUML FUNDING
	histogram log_cumulative_funding, bins(15) ///
		fcolor(emerald) lcolor(white) /// Fill = emerald, outline = black
		graphregion(color(white)) 
		
	graph export "`outputs'/log_cuml_funding.png", replace

		
	// INSTRUMENT
	twoway (line avg_instrument county_id, by(Year) lcolor(emerald)) ///
       (scatter avg_instrument county_id, mcolor(green%50)), ///
       by(Year, legend(off)) ///
	   xlabel(none)
	   
	graph export "`outputs'/instrument_dist.png", replace

/*==============================================================================
									MAPS!!!	
==============================================================================*/
	
	//shp2dta using "/Users/eshavaze/Downloads/ca_counties/CA_Counties.shp", database(counties.dta) coordinates(coords.dta) genid(county_id)
	
	//use "`workingdir'/1_input/shape_data/counties.dta"
	
	//replace NAME = strtrim(NAME)
	//rename NAME County
	
	//save "`workingdir'/1_input/shape_data/counties.dta", replace 

	// MAKING A MAP OF FUNDING 
	merge m:1 County using "`workingdir'/1_input/shape_data/counties.dta"
	preserve 
	keep if Year == 2015
	spmap log_cumulative_funding using "`workingdir'/1_input/shape_data/coords.dta", id(county_id) fcolor(Greens2) 
	graph export "`outputs'/funding_map_2015.png", replace
	restore
	
	// MAKING A MAP OF FUNDING 
	preserve 
	keep if Year == 2016
	spmap log_cumulative_funding using "`workingdir'/1_input/shape_data/coords.dta", id(county_id) fcolor(Greens3) 
	graph export "`outputs'/funding_map_2016.png", replace
	restore
	
	// MAKING A MAP OF FUNDING 
	preserve 
	keep if Year == 2017
	spmap log_cumulative_funding using "`workingdir'/1_input/shape_data/coords.dta", id(county_id) fcolor(Greens2) 
	graph export "`outputs'/funding_map_2017.png", replace
	restore
	
	
	// MAKING A MAP OF FUNDING 
	preserve 
	keep if Year == 2018
	spmap log_cumulative_funding using "`workingdir'/1_input/shape_data/coords.dta", id(county_id) fcolor(Greens2)
	graph export "`outputs'/funding_map_2018.png", replace
	restore
	

	