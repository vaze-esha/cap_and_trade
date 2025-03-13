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
	local input_data "`workingdir'/2_processing/final_datasets"
	
	// output
	local outputs "/Users/eshavaze/Dropbox/Apps/Overleaf/a3_emv_econ_494/fs_with_controls"

	
/*============================================================================*/
	
						// FIRST STAGE REGRESSIONS 
		
/*============================================================================*/

/*==============================================================================
							FS NO CONTROLS 
==============================================================================*/
/*
	* Initialize the table by clearing previous results
	cap erase `outputs'

	* Loop over years from 2015 to 2022
	local years 2015 2016 2017 2018 2019 2020 2021 2022

	foreach yr of local years {
		* Load data for the given year
		use "`input_data'/`yr'.dta", clear
		
		* Run the regression
		reg log_funding instrument, cluster(County)

		* Append results to LaTeX table
		outreg2 using `outputs', append label tex(frag) noaster ///
			title("First Stage (Full Sample) Results") ///
			addnote("Standard errors clustered at County level. CES version 2")
	}

	* Notify that the process is complete
	di "Regression results saved in `outputs'"

	*/
	
/*==============================================================================
							FS CONTROLS ADDED
==============================================================================*/

	* Initialize the table by clearing previous results
	cap erase `outputs'

	* Loop over years from 2015 to 2022
	local years 2015 2016 2017 2018 2019 2020 2021 2022

	foreach yr of local years {
		* Load data for the given year
		use "`input_data'/`yr'.dta", clear
		
		* Run the regression
		reg log_funding instrument prop_nonwhite prop_less_educated prop_transit_carpool, cluster(County)

		* Append results to LaTeX table
		outreg2 using `outputs', append label tex(frag) noaster ///
			title("First Stage (Full Sample) Results") ///
			addnote("Standard errors clustered at County level. CES version 2")
	}

	* Notify that the process is complete
	di "Regression results saved in `outputs'"
	

	
	

	

	
	
