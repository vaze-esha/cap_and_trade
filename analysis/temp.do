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
	local input_data "`workingdir'/2_processing/cci_instrument_funding"
	
	// output
	local output_data "`workingdir'/2_processing/cci_instrument_funding"



/*==============================================================================
						LOOPING OVER YEARS
==============================================================================*/		

foreach year in 2015/2016 {
	
	// Load data
	use "`input_data'/`year'.dta", clear

	// Drop duplicates
	duplicates drop County TOT_funding Total_GGRF_Treatment_tracts ///
		Total_GGRF_Control_tracts instrument, force

	// Merge with covariates
	merge 1:1 County using "`workingdir'/2_processing/covariates/covariates_`year'.dta"
	drop if _merge == 2
	drop _merge

	// Create key variables
	destring TOTAL_POPULATION, replace
	gen total_nonwhite = total_black + total_american_india_alaskan + total_asians ///
                      + total_hawaaian_pacific_islander + total_other_race + total_mixed
	gen prop_nonwhite = total_nonwhite / (total_white + total_nonwhite)
	
	gen less_than_college = LESS_THAN_9TH_GRADE + NINTH_TO_12TH_NO_DIPLOMA + ///
                         HS_GRADUATE + SOME_COLLEGE_NO_DEGREE
	gen prop_less_educated = less_than_college / TOTAL_POPULATION
	gen prop_high_educated = 1 - prop_less_educated

	gen prop_transit_carpool = (TRANSIT_TO_WORK + CARPOOLED) / ///
	                         (DRIVE_ALONE + CARPOOLED + TRANSIT_TO_WORK + ///
	                         WALK_TO_WORK + OTHER_TRANSPORT + WFH)

	gen log_funding = log(TOT_funding)
	gen log_control_funding = log(Total_GGRF_Control_tracts)
	gen log_treated_funding = log(Total_GGRF_Treatment_tracts)

	// Full sample regressions
	reg log_funding instrument MEDIAN_HH_INCOME prop_nonwhite ///
		prop_less_educated prop_transit_carpool, cluster(County)
	outreg2 using "/Users/eshavaze/Downloads/fullsample_results.tex", append label tex(frag) ///
		title("Full Sample Results `year'")

	// Subsample regressions
	reg log_treated_funding instrument MEDIAN_HH_INCOME prop_nonwhite ///
		prop_less_educated prop_transit_carpool if TOTAL_POPULATION < 50000, cluster(County)
	outreg2 using "subsample_results.tex", append label tex(frag) ///
		title("Subsample Results `year'")
}
