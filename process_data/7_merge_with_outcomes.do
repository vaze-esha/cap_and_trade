/*==============================================================================
							7_merge_with_outcomes.do
================================================================================

	PURPOSE:
	
		1. merge outputs from 6 with outcomes voting data 
		
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
	local input_yearly "`workingdir'/2_processing/final_datasets"
	local input_ballot "`workingdir'/2_processing/yearly_ballots"
	
	// output
	local output_data "`workingdir'/2_processing/merged_outcomes_for_reg"
	
/*==============================================================================
										2015
==============================================================================*/


	// merge 2015 data with 2016 voting outcomes 
	use "`input_yearly'/2015_ces2.dta"
	
	local files 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67
	
	foreach num of local files {
    merge 1:1 County using "`input_ballot'/2016_prop_`num'.dta"
	drop if _merge==2
	
    // Check for merge issues (optional)
    tab _merge
    
    // Drop _merge to avoid conflicts in the next iteration
    drop _merge
	
}
	save "`output_data'/2015_ces2_ballots.dta", replace 

	clear 

/*==============================================================================
										2016
==============================================================================*/

	// merge 2016 data with 2016 voting outcomes 
	use "`input_yearly'/2016_ces2.dta"
	
	local files 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67
	
	foreach num of local files {
    merge 1:1 County using "`input_ballot'/2016_prop_`num'.dta"
	drop if _merge==2
    
    // Check for merge issues (optional)
    tab _merge
    
    // Drop _merge to avoid conflicts in the next iteration
    drop _merge

}
	save "`output_data'/2016_ces2_ballots.dta", replace 

	clear
	
/*==============================================================================
										2017
==============================================================================*/

	
	// merge 2017 data with 2018 voting outcomes 
	use "`input_yearly'/2017_ces2.dta"
	
	local files 1 2 3 4 5 6 7 8 10 11 12 68 69 70 71 72
	
	foreach num of local files {
    merge 1:1 County using "`input_ballot'/2018_prop_`num'.dta"
	drop if _merge==2
	
    // Check for merge issues (optional)
    tab _merge
    
    // Drop _merge to avoid conflicts in the next iteration
    drop _merge
	
}
	save "`output_data'/2017_ces2_ballots.dta", replace 

	clear 

/*==============================================================================
										2018
==============================================================================*/

	
	// merge 2017 data with 2018 voting outcomes 
	use "`input_yearly'/2018_ces2.dta"
	
	local files 1 2 3 4 5 6 7 8 10 11 12 68 69 70 71 72
	
	foreach num of local files {
    merge 1:1 County using "`input_ballot'/2018_prop_`num'.dta"
	drop if _merge==2
	
    // Check for merge issues (optional)
    tab _merge
    
    // Drop _merge to avoid conflicts in the next iteration
    drop _merge
	
}
	save "`output_data'/2018_ces2_ballots.dta", replace 

	clear 
	
	// merge 2017 data with 2018 voting outcomes 
	use "`input_yearly'/2018_ces3.dta"
	
	local files 1 2 3 4 5 6 7 8 10 11 12 68 69 70 71 72
	
	foreach num of local files {
    merge 1:1 County using "`input_ballot'/2018_prop_`num'.dta"
	drop if _merge==2
	
    // Check for merge issues (optional)
    tab _merge
    
    // Drop _merge to avoid conflicts in the next iteration
    drop _merge
	
}
	save "`output_data'/2018_ces3_ballots.dta", replace

	clear 

	
	
	
	/*
/*==============================================================================
										2019
==============================================================================*/

	// merge 2019 data with 2022 (and all ahead of those)
	use "`input_yearly'/2019_ces3.dta"
	
	local files 1 26 27 28 29 30 31
	
	foreach num of local files {
    merge 1:1 County using "`input_ballot'/2022_prop_`num'.dta"
	drop if _merge==2
	
    // Check for merge issues (optional)
    tab _merge
    
    // Drop _merge to avoid conflicts in the next iteration
    drop _merge
	
}
	save "`output_data'/2019_ces3_ballots.dta", replace 

	clear 

/*==============================================================================
										2020
==============================================================================*/

	// merge 2019 data with 2022 (and all ahead of those)
	use "`input_yearly'/2020_ces3.dta"
	
	local files 1 26 27 28 29 30 31
	
	foreach num of local files {
    merge 1:1 County using "`input_ballot'/2022_prop_`num'.dta"
	drop if _merge==2
	
    // Check for merge issues (optional)
    tab _merge
    
    // Drop _merge to avoid conflicts in the next iteration
    drop _merge
	
}
	save "`output_data'/2020_ces3_ballots.dta"

	clear 
	
/*==============================================================================
										2021
==============================================================================*/

	// merge 2019 data with 2022 (and all ahead of those)
	use "`input_yearly'/2021_ces3.dta"
	
	local files 1 26 27 28 29 30 31
	
	foreach num of local files {
    merge 1:1 County using "`input_ballot'/2022_prop_`num'.dta"
	drop if _merge==2
	
    // Check for merge issues (optional)
    tab _merge
    
    // Drop _merge to avoid conflicts in the next iteration
    drop _merge
	
}
	save "`output_data'/2021_ces3_ballots.dta", replace 

	clear 

/*==============================================================================
										2022
==============================================================================*/

	// merge 2019 data with 2022 (and all ahead of those)
	use "`input_yearly'/2022_ces3.dta"
	
	local files 1 26 27 28 29 30 31
	
	foreach num of local files {
    merge 1:1 County using "`input_ballot'/2022_prop_`num'.dta"
	drop if _merge==2
	
    // Check for merge issues (optional)
    tab _merge
    
    // Drop _merge to avoid conflicts in the next iteration
    drop _merge
	
}
	save "`output_data'/2022_ces3_ballots.dta", replace

	clear 

	


/*
def homeless_solar_farm(money, county): 
	if money >= 0 
	return county in len(money) 
	

	
	