/*==============================================================================
							1_clean_datasets.do
================================================================================

	PURPOSE:
	
		1.Import cci_ces datasets and merge with ces scores 
		
	INPUTS:
		1. cci_CESVersion2.dta
		2. cci_CESVersion3.dta
		3. cci_CESVersion4.dta
	
	OUTPUTS:
	
		
		
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

	* detect user 
	local system_string `c(username)' // Get Stata dir.
	display "Current user, `c(username)' `c(machine_type)' `c(os)'."

	if inlist( "`c(username)'" , "eshavaze") {

		local workingdir "/Users/eshavaze/Dropbox/cal_cap_and_trade"

	}

	* add your path here *
	
	else {
	  noisily display as error _newline "{phang}Your username [`c(username)'] could not be matched with a profile. Check do-file header and try again.{p_end}"
	  error 2222
	}

	di "This project is working from `workingdir'"

/*============================================================================*/		
	
	* input dir
	local input_data "`workingdir'/0_raw_input"
	di "`input_data'"

	* output dir
	local output_data "`workingdir'/1_input"
	di "`output_data'"
/*============================================================================*/	

/*==============================================================================
							     import data
==============================================================================*/	
	
	// import ces2
	import excel "`input_data'/ces2results.xlsx", sheet("CES2.0FinalResults") firstrow clear
	keep CensusTract TotalPopulation CaliforniaCounty CES20Score CES20PercentileRange
	save "`output_data'/ces2results.dta", replace

	// import ces3
	import excel "`input_data'/ces3results.xlsx", sheet("CES3.0FinalResults") firstrow clear
	keep CensusTract TotalPopulation CaliforniaCounty CES30Score CES30Percentile CES30PercentileRange
	save "`output_data'/ces3results.dta", replace

	// import ces4
	import excel "`input_data'/ces4results.xlsx", sheet("CES4.0FinalResults") firstrow clear
	keep CensusTract TotalPopulation CaliforniaCounty CES40Score CES40Percentile CES40PercentileRange
	save "`output_data'/ces4results.dta", replace
	
	
********************************************************************************

/*==============================================================================
							     merges
==============================================================================*/	

	use "`output_data'/cci_ces_versions/cci_CESVersion2.dta"
	destring CensusTract, replace
	
	merge 1:1 CensusTract  Year using "`output_data'/ces2results.dta"

	
	
	
	