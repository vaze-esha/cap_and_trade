/*==============================================================================
							6_merge_covariates.do
================================================================================

	PURPOSE:
	
		1. run first stage and reduced from regressions for all years 
		
		check the tracts for zero instrument values -- is it just once tract? 
		that is driving this?
		varible number of zeros -- what counties are zero always?
			this means there are control tracts 
			but no treated tracts 
			what should i do about these logically?
			
		
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
	local input_data "`workingdir'/2_processing/cci_instrument_funding"
	
	// output
	local output_data "/Users/eshavaze/Dropbox/cal_cap_and_trade/2_processing/final_datasets"

/*==============================================================================
										2015
==============================================================================*/
	use "`input_data'/2015.dta", clear
		
		// Drop duplicates
		duplicates drop County TOT_funding instrument, force

		// Merge with covariates
		merge 1:1 County using "`workingdir'/2_processing/covariates/covariates_2015.dta"
		drop if _merge == 2
		drop _merge

		// Create key variables
		rename totals_races TOTAL_POPULATION
		destring TOTAL_POPULATION, replace
		
		// destring vars 
		foreach var in DRIVE_ALONE CARPOOLED TRANSIT_TO_WORK WALK_TO_WORK ///
					OTHER_TRANSPORT WFH MEDIAN_HH_INCOME TOTAL_POPULATION ///
					total_white total_black total_american_india_alaskan ///
					total_asians total_hawaaian_pacific_islander ///
					total_other_race total_mixed LESS_THAN_HS ///
					SOME_COLLEGE_OR_ASSOCIATES BACHELORS_OR_HIGHER ///
					LESS_THAN_9TH_GRADE NINTH_TO_12TH_NO_DIPLOMA ///
					HS_GRADUATE SOME_COLLEGE_NO_DEGREE ASSOCIATES_DEGREE ///
					BACHELORS_DEGREE GRADUATE_OR_PROFESSIONAL_DEGREE ///
					POP_25_TO_34 POP_35_TO_44 POP_45_TO_64 POP_65_PLUS ///
					total_homeowners_renters total_homeowners total_renters {
		destring `var', replace
		}
		
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
		
		// Set variable labels for clearer table output
		label variable log_funding "Log(Total GGRF Funding)"
		label variable instrument "Z"
		label variable MEDIAN_HH_INCOME "Median Household Income"
		label variable prop_nonwhite "Proportion Nonwhite"
		label variable prop_less_educated "Proportion Less Educated"
		label variable prop_transit_carpool "Proportion Using Transit/Carpool"
		
		
		save "`output_data'/2015_ces2.dta", replace

/*==============================================================================
										2017 onwards 
==============================================================================*/	
	
	// 2016 is 2 
	// 2017 is 2 
	// 2018 is an even split, mass in three 
	// 2019, 2020, 2021 mass in three 
	// 2022 mass in three 
	// 2023 mass in three 
	
	foreach year of numlist 2016 2017 2018{
		
		// Load data
		use "`input_data'/`year'.dta", clear
		
		// Drop duplicates
		duplicates drop County TOT_funding instrument, force
		keep if CESVersion==2 

		// Merge with covariates
		merge 1:1 County using "`workingdir'/2_processing/covariates/covariates_`year'.dta"
		drop if _merge == 2
		drop _merge

		// Create key variables
		rename totals_races TOTAL_POPULATION
		replace TOTAL_POPULATION = "." if regexm(TOTAL_POPULATION, "[^0-9.]")
		destring TOTAL_POPULATION, replace
		
		// destring vars 
		foreach var in DRIVE_ALONE CARPOOLED TRANSIT_TO_WORK WALK_TO_WORK ///
					OTHER_TRANSPORT WFH MEDIAN_HH_INCOME TOTAL_POPULATION ///
					total_white total_black total_american_india_alaskan ///
					total_asians total_hawaaian_pacific_islander ///
					total_other_race total_mixed LESS_THAN_HS ///
					SOME_COLLEGE_OR_ASSOCIATES BACHELORS_OR_HIGHER ///
					LESS_THAN_9TH_GRADE NINTH_TO_12TH_NO_DIPLOMA ///
					HS_GRADUATE SOME_COLLEGE_NO_DEGREE ASSOCIATES_DEGREE ///
					BACHELORS_DEGREE GRADUATE_OR_PROFESSIONAL_DEGREE ///
					POP_25_TO_34 POP_35_TO_44 POP_45_TO_64 POP_65_PLUS ///
					total_homeowners_renters total_homeowners total_renters {
		tostring `var', replace
		replace `var' = "." if regexm(`var', "[^0-9.]")
		destring `var', replace
		}
		
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
		
		// Set variable labels for clearer table output
		label variable log_funding "Log(Total GGRF Funding)"
		label variable instrument "Z"
		label variable MEDIAN_HH_INCOME "Median Household Income"
		label variable prop_nonwhite "Proportion Nonwhite"
		label variable prop_less_educated "Proportion Less Educated"
		label variable prop_transit_carpool "Proportion Using Transit/Carpool"
		
		save "`output_data'/`year'_ces2.dta", replace

	}
	
	
	foreach year of numlist 2018 2019 2021 2022 2023{
		
		// Load data
		use "`input_data'/`year'.dta", clear
		
		// Drop duplicates
		duplicates drop County TOT_funding instrument, force
		keep if CESVersion==3

		// Merge with covariates
		merge 1:1 County using "`workingdir'/2_processing/covariates/covariates_`year'.dta"
		drop if _merge == 2
		drop _merge

		// Create key variables
		rename totals_races TOTAL_POPULATION
		replace TOTAL_POPULATION = "." if regexm(TOTAL_POPULATION, "[^0-9.]")
		destring TOTAL_POPULATION, replace
		
		// destring vars 
		foreach var in DRIVE_ALONE CARPOOLED TRANSIT_TO_WORK WALK_TO_WORK ///
					OTHER_TRANSPORT WFH MEDIAN_HH_INCOME TOTAL_POPULATION ///
					total_white total_black total_american_india_alaskan ///
					total_asians total_hawaaian_pacific_islander ///
					total_other_race total_mixed LESS_THAN_HS ///
					SOME_COLLEGE_OR_ASSOCIATES BACHELORS_OR_HIGHER ///
					LESS_THAN_9TH_GRADE NINTH_TO_12TH_NO_DIPLOMA ///
					HS_GRADUATE SOME_COLLEGE_NO_DEGREE ASSOCIATES_DEGREE ///
					BACHELORS_DEGREE GRADUATE_OR_PROFESSIONAL_DEGREE ///
					POP_25_TO_34 POP_35_TO_44 POP_45_TO_64 POP_65_PLUS ///
					total_homeowners_renters total_homeowners total_renters {
		tostring `var', replace
		replace `var' = "." if regexm(`var', "[^0-9.]")
		destring `var', replace
		}
		
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
		
		// Set variable labels for clearer table output
		label variable log_funding "Log(Total GGRF Funding)"
		label variable instrument "Z"
		label variable MEDIAN_HH_INCOME "Median Household Income"
		label variable prop_nonwhite "Proportion Nonwhite"
		label variable prop_less_educated "Proportion Less Educated"
		label variable prop_transit_carpool "Proportion Using Transit/Carpool"
		
		save "`output_data'/`year'_ces3.dta", replace

	}
	
/*==============================================================================
									2020 only 
==============================================================================*/	

	// Load data
		use "`input_data'/2020.dta", clear
		
		// Drop duplicates
		duplicates drop County TOT_funding instrument, force
		keep if CESVersion==3

		// Merge with covariates
		// LAGGED DATA for covariates 
		merge 1:1 County using "`workingdir'/2_processing/covariates/covariates_2019.dta"
		drop if _merge == 2
		drop _merge
		
		

		// Create key variables
		rename totals_races TOTAL_POPULATION
		replace TOTAL_POPULATION = "." if regexm(TOTAL_POPULATION, "[^0-9.]")
		destring TOTAL_POPULATION, replace
		
		// destring vars 
		foreach var in DRIVE_ALONE CARPOOLED TRANSIT_TO_WORK WALK_TO_WORK ///
					OTHER_TRANSPORT WFH MEDIAN_HH_INCOME TOTAL_POPULATION ///
					total_white total_black total_american_india_alaskan ///
					total_asians total_hawaaian_pacific_islander ///
					total_other_race total_mixed LESS_THAN_HS ///
					SOME_COLLEGE_OR_ASSOCIATES BACHELORS_OR_HIGHER ///
					LESS_THAN_9TH_GRADE NINTH_TO_12TH_NO_DIPLOMA ///
					HS_GRADUATE SOME_COLLEGE_NO_DEGREE ASSOCIATES_DEGREE ///
					BACHELORS_DEGREE GRADUATE_OR_PROFESSIONAL_DEGREE ///
					POP_25_TO_34 POP_35_TO_44 POP_45_TO_64 POP_65_PLUS ///
					total_homeowners_renters total_homeowners total_renters {
		tostring `var', replace
		replace `var' = "." if regexm(`var', "[^0-9.]")
		destring `var', replace
		}
		
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
		
		// Set variable labels for clearer table output
		label variable log_funding "Log(Total GGRF Funding)"
		label variable instrument "Z"
		label variable MEDIAN_HH_INCOME "Median Household Income"
		label variable prop_nonwhite "Proportion Nonwhite"
		label variable prop_less_educated "Proportion Less Educated"
		label variable prop_transit_carpool "Proportion Using Transit/Carpool"
		
		save "`output_data'/2020_ces3.dta", replace
		