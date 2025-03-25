/*==============================================================================
							1_regress_iv_master.do
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
							FS NO CONTROLS 
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
	
	// a lot of covariates absorbed in year-fe are collinear: remove them 
	drop DRIVE_ALONE CARPOOLED TRANSIT_TO_WORK WALK_TO_WORK OTHER_TRANSPORT WFH total_white total_black total_american_india_alaskan total_asians total_hawaaian_pacific_islander total_other_race total_mixed LESS_THAN_HS SOME_COLLEGE_OR_ASSOCIATES BACHELORS_OR_HIGHER LESS_THAN_9TH_GRADE NINTH_TO_12TH_NO_DIPLOMA HS_GRADUATE SOME_COLLEGE_NO_DEGREE ASSOCIATES_DEGREE BACHELORS_DEGREE GRADUATE_OR_PROFESSIONAL_DEGREE POP_25_TO_34 POP_35_TO_44 POP_45_TO_64 POP_65_PLUS total_homeowners_renters total_homeowners total_renters total_nonwhite less_than_college prop_high_educated MEDIAN_HH_INCOME TotalProgramGGRFFunding TOT_funding
	
	// init out table
	estimates clear

	// ols1
	reg log_funding instrument, vce(cluster county_id)
	est store reg1

	//ols2
	reg log_funding instrument prop_nonwhite prop_less_educated prop_transit_carpool, vce(cluster county_id)
	est store reg2

	//output
	outreg2 [reg1 reg2] using "`outputs'/combined_table.tex", replace label ///
		title("Regression Results for Log Funding") 
	
	/*
	
	// run FS REG 
	reghdfe log_funding instrument,absorb(county_id Year) vce(cluster county_id)
	outreg2 using "`outputs'/fs_panel.tex", append label tex(frag) noaster ///
			title("First Stage (Pooled Sample) Results") ///
			
	*/	

			
	clear
	
	*/
	
/*==============================================================================
							RF NO CONTROLS 
==============================================================================*/


	use "`input_data'/rf_dataset.dta"

	encode County, gen(county_id)  // Convert county to numeric ID
	
	// choose max instrument val for 2018 (2 vals based on ces version)
	egen max_instrument = max(instrument) if Year == 2018, by(county_id)

	// Keep only observations where instrument equals the max for each county in 2018
	keep if Year != 2018 | instrument == max_instrument

	//Drop the temporary variable
	drop max_instrument

	
	// SET PANEL 
	xtset county_id Year  // Panel setup (if county-year is panel data)
	
	// a lot of covariates absorbed in year-fe are collinear: remove them 
	drop DRIVE_ALONE CARPOOLED TRANSIT_TO_WORK WALK_TO_WORK OTHER_TRANSPORT WFH total_white total_black total_american_india_alaskan total_asians total_hawaaian_pacific_islander total_other_race total_mixed LESS_THAN_HS SOME_COLLEGE_OR_ASSOCIATES BACHELORS_OR_HIGHER LESS_THAN_9TH_GRADE NINTH_TO_12TH_NO_DIPLOMA HS_GRADUATE SOME_COLLEGE_NO_DEGREE ASSOCIATES_DEGREE BACHELORS_DEGREE GRADUATE_OR_PROFESSIONAL_DEGREE POP_25_TO_34 POP_35_TO_44 POP_45_TO_64 POP_65_PLUS total_homeowners_renters total_homeowners total_renters total_nonwhite less_than_college prop_high_educated MEDIAN_HH_INCOME TotalProgramGGRFFunding TOT_funding


	* Define propositions by year
	local props_2012 28 29 30 31 32 33 34 35 36 37 38 39 40
	local props_2014 1 2 41 42 45 46 47 48
	local props_2016 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67
	local props_2018 1 10 11 12 2 3 4 5 6 68 69 7 70 71 72 8
	local props_2020 14 15 16 17 18 19 20 21 22 23 24 25
	local props_2022 1 26 27 28 29 30 31

	
	
	* Loop through years
	foreach year in 2012 2014 2016 2018 2020 2022 {
		* Get the propositions for this year
		local props `props_`year''

		* Reset stored estimates
		estimates clear

		* Run regressions for each proposition
		local first = 1
		foreach num in `props' {
			preserve   // Prevent permanent changes

			* Keep only relevant variables
			keep County county_id Year instrument prop_yes_`num' prop_nonwhite prop_less_educated prop_transit_carpool

			* Run regression
			reg prop_yes_`num' instrument, vce(cluster county_id)
			est store prop_`num'

			* Append to the table instead of replacing
			if `first' == 1 {
				outreg2 using "`outputs'/table_`year'.tex", replace label ///
					title("Reduced Form for `year' Propositions")
				local first = 0
			}
			else {
				outreg2 using "`outputs'/table_`year'.tex", append label 
			}

			restore   // Reload full dataset for next iteration
		}

		display "Table for `year' saved successfully."
	}

	
	/*
	* Loop through years
	foreach year in 2012 2014 2016 2018 2020 2022 {
		* Get the propositions for this year
		local props `props_`year''

		* Reset stored estimates
		estimates clear

		* Run regressions for each proposition
		local first = 1
		foreach num in `props' {
			preserve   // Prevent permanent changes

			* Keep only relevant variables
			keep County county_id Year instrument prop_yes_`num' prop_nonwhite prop_less_educated prop_transit_carpool TOTAL_POPULATION 

			* Run regression
			reg prop_yes_`num' instrument prop_nonwhite prop_less_educated prop_transit_carpool, vce(cluster county_id)
			est store prop_`num'

			* Append to the table instead of replacing
			if `first' == 1 {
				outreg2 using "`outputs'/table_`year'_wcontrols.tex", replace label noaster ///
					title("Reduced Form for `year' Propositions")
				local first = 0
			}
			else {
				outreg2 using "`outputs'/table_`year'_wcontrols.tex", append label noaster
			}

			restore   // Reload full dataset for next iteration
		}

		display "Table for `year' saved successfully."
	}



