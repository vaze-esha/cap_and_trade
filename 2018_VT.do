/*==============================================================================
								2018 ONLY 
================================================================================

	PURPOSE:
	
		1. run first stage for all years 
		2. VOTER TURNOUT REGRESSIONS
			
		
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
	// input sub dirs
	local input_yearly "`workingdir'/2_processing/final_datasets"
	local input_ballot "`workingdir'/2_processing/yearly_ballots"
	
	
	// output
	local outputs "/Users/eshavaze/Downloads"

	
/*============================================================================*/
	
						// APPENDING DATA YEARLY 
		
/*============================================================================*/

	use "`input_yearly'/2015_ces2.dta", clear
	append using "`input_yearly'/2016_ces2.dta"
	append using "`input_yearly'/2017_ces2.dta"
	append using "`input_yearly'/2018_ces2.dta"

	merge m:1 County using "`input_ballot'/2018_voter_participation.dta"
	drop if _merge == 2
	
	
/*============================================================================*/
	
						// OLS + 2sls
		
/*============================================================================*/	

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
	
	// destring and clean outcome var 
	replace Total_Voters = subinstr(Total_Voters, ",", "", .)

	destring Total_Voters, replace 
	destring Turnout_Eligible, replace 
		
	* OLS regression
	reg  Turnout_Eligible log_cumulative_funding, vce(cluster county_id)
	est store ols
	
	* ols controls 
	reg  Turnout_Eligible log_cumulative_funding prop_nonwhite prop_less_educated, vce(cluster county_id)
	est store olsc

	* 2SLS (IV) regression
	ivreg2  Turnout_Eligible (log_cumulative_funding = avg_instrument), cluster(county_id)
	est store tsls
	
	* 2SLS (IV) regression controls 
	ivreg2  Turnout_Eligible (log_cumulative_funding = avg_instrument) prop_nonwhite prop_less_educated, cluster(county_id)
	est store tslsc
	

	//output
	outreg2 [ols olsc tsls tslsc] using "`outputs'/2018_vt.tex", replace label ///
		title("Voter Turnout") 
		