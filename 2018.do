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
	
	// sum all funding receieved until 2018 by each county
	bysort County (Year): gen cumulative_funding = sum(TOT_funding)
	gen log_cumulative_funding = log(cumulative_funding)
	
	// calculate an average of instrument over the years 
	egen avg_instrument = mean(instrument), by(County)
	drop if Year != 2018

	// init out table
	estimates clear
	
	// ols1
	reg log_cumulative_funding avg_instrument, robust
	est store reg1

	//ols2
	reg log_cumulative_funding avg_instrument prop_nonwhite prop_less_educated prop_transit_carpool, robust
	est store reg2

	//output
	outreg2 [reg1 reg2] using "`outputs'/combined_table.tex", replace label ///
		title("Regression Results for Log Funding") 
		
		
	clear
	
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
	
	// sum all funding receieved until 2018 by each county
	bysort County (Year): gen cumulative_funding = sum(TOT_funding)
	gen log_cumulative_funding = log(cumulative_funding)
	
	// calculate an average of instrument over the years 
	egen avg_instrument = mean(instrument), by(County)
	drop if Year != 2018
	
	// define local environmental propositions only 
	local props_2018 1 10 12 3 6 68 69 72
	
	* Loop through years
	foreach year in 2018 {
		* Get the propositions for this year
		local props `props_`year''

		* Reset stored estimates
		estimates clear

		* Run regressions for each proposition
		local first = 1
		foreach num in `props' {
			preserve   // Prevent permanent changes

			* Run regression
			reg prop_yes_`num' avg_instrument, robust
			est store prop_`num'

			* Append to the table instead of replacing
			if `first' == 1 {
				outreg2 using "`outputs'/rf_`year'.tex", replace label ///
					title("Reduced Form for `year' Propositions")
				local first = 0
			}
			else {
				outreg2 using "`outputs'/rf_`year'.tex", append label 
			}

			restore   // Reload full dataset for next iteration
		}

		display "Table for `year' saved successfully."
	}
	
	clear
	
/*==============================================================================
									2SLS
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
	
	// sum all funding receieved until 2018 by each county
	bysort County (Year): gen cumulative_funding = sum(TOT_funding)
	gen log_cumulative_funding = log(cumulative_funding)
	
	// calculate an average of instrument over the years 
	egen avg_instrument = mean(instrument), by(County)
	drop if Year != 2018
	
	// define local environmental propositions only 
	local props_2018 1 10 12 3 6 68 69 72
	
	* Loop through years
	foreach year in 2018 {
		* Get the propositions for this year
		local props `props_`year''

		* Reset stored estimates
		estimates clear

		* Run regressions for each proposition
		local first_ols = 1
		local first_sls = 1
		foreach num in `props' {
			preserve   // Prevent permanent changes
			
			* Run OLS regression
			reg prop_yes_`num' log_cumulative_funding, robust
			est store ols_prop_`num'

			* Run 2SLS (IV) regression
			ivreg2 prop_yes_`num' (log_cumulative_funding = avg_instrument), robust
			est store sls_prop_`num'

			* Output OLS estimates to a separate table
			if `first_ols' == 1 {
				outreg2 [ols_prop_`num'] using "`outputs'/`year'_ols.tex", replace label ///
					title("OLS Estimates for `year'")
				local first_ols = 0
			}
			else {
				outreg2 [ols_prop_`num'] using "`outputs'/`year'_ols.tex", append label 
			}

			* Output 2SLS (IV) estimates to a separate table
			if `first_sls' == 1 {
				outreg2 [sls_prop_`num'] using "`outputs'/`year'_2sls.tex", replace label  ///
					title("2SLS Estimates for `year'")
				local first_sls = 0
			}
			else {
				outreg2 [sls_prop_`num'] using "`outputs'/`year'_2sls.tex", append label 
			}

			restore   // Reload full dataset for next iteration
		}

		display "Tables for `year' saved successfully."
	}
	