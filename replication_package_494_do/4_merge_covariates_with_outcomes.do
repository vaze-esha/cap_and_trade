/*==============================================================================
							4_merge_covariates.do
================================================================================

	PURPOSE:
	
	1. merge covariates into yearly datasets 
		
==============================================================================*/

	* Clear all and set large data arguments.
	macro drop _all 
	clear all
	// version 18.0, user
	set more off 
	set seed 13011
	pause on


	
	* SET TO PATH ON YOUR MACHINE WHERE REPLICATION PACKAGE DATA IS SAVED 

	global workingdir "/Users/eshavaze/Dropbox/replication_package_494"
	di "$workingdir"
	
	* SET TO PATH ON YOUR MACHINE WHERE REPLICATION PACKAGE DOFILES ARE SAVED
	
	global dodir "/Users/eshavaze/cap_and_trade/replication_package_494_do"
	di "$dodir"
	
	
********************************************************************************
		* SET TO PATH ON YOUR MACHINE WHERE REPLICATION PACKAGE DATA IS SAVED 

	global workingdir "/Users/eshavaze/Dropbox/replication_package_494"
	di "$workingdir"
	
	* SET TO PATH ON YOUR MACHINE WHERE REPLICATION PACKAGE DOFILES ARE SAVED
	
	global dodir "/Users/eshavaze/cap_and_trade/replication_package_494_do"
	di "$dodir"
	
	
********************************************************************************
	
	* raw input dir
	global raw_input_data "$workingdir/0_raw_input"
	di "$raw_input_data"

	* intermediate processed data 
	global intermediate_data "$workingdir/1_intermediate"
	di "$intermediate_data"
	
	
	* final datasets
	global final_data "$workingdir/2_final"
	di "$final_data"

	* tables 
	global tables "$workingdir/3_tables"
	di "$tables"
	
/*==============================================================================
										2015
==============================================================================*/
	use "$intermediate_data/2015.dta", clear
		
		// Drop duplicates
		duplicates drop County TOT_funding instrument, force

		// Merge with covariates
		merge 1:1 County using "$intermediate_data/covariates/covariates_2015.dta"
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
		
		// exclude ASIANS
		gen total_nonwhite = total_black + total_american_india_alaskan  ///
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
		
		
		save "$final_data/2015.dta", replace

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
		use "$intermediate_data/`year'.dta", clear
		
		// Drop duplicates
		duplicates drop County TOT_funding instrument, force
		keep if CESVersion==2 

		// Merge with covariates
		merge 1:1 County using "$intermediate_data/covariates/covariates_`year'.dta"
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
		
		gen total_nonwhite = total_black + total_american_india_alaskan ///
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
		
		save "$final_data/`year'.dta", replace

	}
	
	
	foreach year of numlist 2018 2019 2021 2022 2023{
		
		// Load data
		use "$intermediate_data/`year'.dta", clear
		
		// Drop duplicates
		duplicates drop County TOT_funding instrument, force
		keep if CESVersion==3

		// Merge with covariates
		merge 1:1 County using "$intermediate_data/covariates/covariates_`year'.dta"
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
		
		gen total_nonwhite = total_black + total_american_india_alaskan ///
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
		
		save "$final_data/`year'.dta", replace

	}
	
/*==============================================================================
									2020 only 
==============================================================================*/	

	// Load data
		use "$intermediate_data/2020.dta", clear
		
		// Drop duplicates
		duplicates drop County TOT_funding instrument, force
		keep if CESVersion==3

		// Merge with covariates
		// LAGGED DATA for covariates 
		merge 1:1 County using "$intermediate_data/covariates/covariates_2019.dta"
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
		
		gen total_nonwhite = total_black + total_american_india_alaskan ///
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
		
		save "$final_data/2020.dta", replace
		
/*==============================================================================
						Append All Years into Final Panel
==============================================================================*/

	clear all

	local years 2015 2016 2017 2018 2019 2020 2021 2022 2023
	local first = 1

	foreach year of local years {
		if `first' == 1 {
			use "$final_data/`year'.dta", clear
			local first = 0
		}
		else {
			append using "$final_data/`year'.dta"
		}
	}

	save "$final_data/panel_2015_2023.dta", replace
	
	
	clear
/*==============================================================================
						MERGE WITH BALLOT OUTCOMES 
==============================================================================*/		
	
	use "$final_data/panel_2015_2023.dta"
	
	* Define all proposition files to merge
	local propfiles ///
		2016_prop_50 2016_prop_51 2016_prop_52 2016_prop_53 2016_prop_54 ///
		2016_prop_55 2016_prop_56 2016_prop_57 2016_prop_58 2016_prop_59 ///
		2016_prop_60 2016_prop_61 2016_prop_62 2016_prop_63 2016_prop_64 ///
		2016_prop_65 2016_prop_66 2016_prop_67 ///
		2018_prop_1 2018_prop_2 2018_prop_3 2018_prop_4 2018_prop_5 ///
		2018_prop_6 2018_prop_7 2018_prop_8 2018_prop_10 2018_prop_11 ///
		2018_prop_12 2018_prop_68 2018_prop_69 2018_prop_70 2018_prop_71 2018_prop_72 ///
		2022_prop_1 2022_prop_26 2022_prop_27 2022_prop_28 2022_prop_29 2022_prop_30 2022_prop_31 ///
		2012_prop_39 2014_prop_1

	* Loop through and merge each proposition file into the panel
	foreach f of local propfiles {
		display "Merging proposition file: `f'.dta"
		merge m:1 County using "$intermediate_data/yearly_ballots/`f'.dta"
		
		// Drop observations that were only in the prop file
		drop if _merge == 2
		drop _merge
	}


	save "$final_data/panel_2015_2023.dta", replace 


		