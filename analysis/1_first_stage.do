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

	use "`input_data'/appended_all_years.dta"
	
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
	drop DRIVE_ALONE CARPOOLED TRANSIT_TO_WORK WALK_TO_WORK OTHER_TRANSPORT WFH total_white total_black total_american_india_alaskan total_asians total_hawaaian_pacific_islander total_other_race total_mixed LESS_THAN_HS SOME_COLLEGE_OR_ASSOCIATES BACHELORS_OR_HIGHER LESS_THAN_9TH_GRADE NINTH_TO_12TH_NO_DIPLOMA HS_GRADUATE SOME_COLLEGE_NO_DEGREE ASSOCIATES_DEGREE BACHELORS_DEGREE GRADUATE_OR_PROFESSIONAL_DEGREE POP_25_TO_34 POP_35_TO_44 POP_45_TO_64 POP_65_PLUS total_homeowners_renters total_homeowners total_renters total_nonwhite less_than_college prop_high_educated MEDIAN_HH_INCOME TotalProgramGGRFFunding TOT_funding 	TOTAL_POPULATION
	
	
	// run FS REG 
	reghdfe log_funding instrument,absorb(county_id Year) vce(cluster county_id)
	outreg2 using "`outputs'/fs_panel.tex", append label tex(frag) noaster ///
			title("First Stage (Full Sample) Results") ///
			
	// run RF regs 
	
	
	

/*

	// CES 2.0 TABLE 
	* Initialize the table by clearing previous results
	cap erase "`outputs'/fs_ces2"

	* Loop over years from 2015 to 2022
	local years_2 2015 2016 2017 2018 

	foreach yr of local years_2 {
		* Load data for the given year
		use "`input_data'/`yr'_ces2.dta", clear
		
		* Run the regression
		reg log_funding instrument, cluster(County)

		* Append results to LaTeX table
		outreg2 using "`outputs'/fs_ces2.tex", append label tex(frag) noaster ///
			title("First Stage (Full Sample) Results") ///
			addnote("Standard errors clustered at County level. CES version 2.0")
	}


	di "Regression results saved in `outputs'"



	// CES 3.0 TABLE 
	* loop ver 3 years 
	cap erase "`outputs'/fs_ces3"
	
	local years_3 2018 2019 2020 2021 2022

	foreach yr of local years_3 {
		* Load data for the given year
		use "`input_data'/`yr'_ces3.dta", clear
		
		* Run the regression
		reg log_funding instrument, cluster(County)

		* Append results to LaTeX table
		outreg2 using "`outputs'/fs_ces3.tex", append label tex(frag) noaster ///
			title("First Stage (Full Sample) Results") ///
			addnote("Standard errors clustered at County level. CES version 2")
	}

	* Notify that the process is complete
	di "Regression results saved in `outputs'"
	

/*==============================================================================
							FS CONTROLS ADDED
==============================================================================*/
	
	// CES 2.0 TABLE 
	* Initialize the table by clearing previous results
	cap erase "`outputs'/fs_ces2_controls"

	* Loop over years from 2015 to 2022
	local years_2 2015 2016 2017 2018 

	foreach yr of local years_2 {
		* Load data for the given year
		use "`input_data'/`yr'_ces2.dta", clear
		
		* Run the regression
		reg log_funding instrument prop_nonwhite prop_less_educated prop_transit_carpool, cluster(County)

		* Append results to LaTeX table
		outreg2 using "`outputs'/fs_ces2_controls.tex", append label tex(frag) noaster ///
			title("First Stage (Full Sample) Results") ///
			addnote("Standard errors clustered at County level. CES version 2")
	}


	di "Regression results saved in `outputs'"
	
	

	* Initialize the table by clearing previous results
	cap erase "`outputs'/fs_ces3_controls"

	* Loop over years from 2015 to 2022
	local years_3 2018 2019 2020 2021 2022

	foreach yr of local years_3 {
		* Load data for the given year
		use "`input_data'/`yr'_ces3.dta", clear
		
		* Run the regression
		reg log_funding instrument prop_nonwhite prop_less_educated prop_transit_carpool, cluster(County)

		* Append results to LaTeX table
		outreg2 using "`outputs'/fs_ces3_controls.tex", append label tex(frag) noaster ///
			title("First Stage (Full Sample) Results") ///
			addnote("Standard errors clustered at County level. CES version 2")
	}

	* Notify that the process is complete
	di "Regression results saved in `outputs'"
	

	
	

	

	
	
