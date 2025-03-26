/*==============================================================================
							4_4_2022_ballot.do
================================================================================

	PURPOSE:
	
		1. create yearly ballot outcome by county datasets 
		
	INPUTS:
		1. input_data/ballot_2020.xlsx
	
	OUTPUTS:
	
	
		
==============================================================================*/

// working directory dropbox 
	local workingdir "/Users/eshavaze/Dropbox/cal_cap_and_trade"
	
	// input 
	local input_data "`workingdir'/0_raw_input/ballots"
	
	// output
	local output_data "`workingdir'/2_processing"
	
	// code 
	local do_dir "/Users/eshavaze/cap_and_trade/process_data/4_ballot_imports"
	
/*==============================================================================
									2018 
==============================================================================*/	
	
	
	import excel "`input_data'/2018_voter_participation.xlsx", sheet("Worksheet") firstrow clear
	// we will now split these by ballot 
	
	drop in 1/2
	// rename columns 
	rename VOTERPARTICIPATIONSTATISTICSB County
	rename B Number_of_Precincts
	rename C Eligible_to_Register
	rename D Registered_Voters
	rename E Precinct_Voters
	rename F Vote_By_Mail_Voters
	rename G Total_Voters
	rename H Percent_Vote_By_Mail
	rename I Turnout_Registered
	rename J Turnout_Eligible
	drop K
	
	drop in 1/3
	
	// drop empty rows
	replace County="." if County==""
	drop if County=="."
	
	gen rownum = _n  // Create a row number variable
	drop if mod(rownum, 2) == 0  // Drop even-numbered rows
	drop if rownum == 117 
	drop if rownum == 119 
	
	drop rownum  // Remove the temporary row number variable

	// remove stars 
	foreach var of varlist County Number_of_Precincts Eligible_to_Register Registered_Voters Precinct_Voters {
    replace `var' = subinstr(`var', "*", "", .)  // Remove all asterisks
}
	
	// remove percent sign 
	foreach var of varlist Percent_Vote_By_Mail Turnout_Registered Turnout_Eligible {
    replace `var' = subinstr(`var', "%", "", .)  // Remove the percent sign
    destring `var', replace force  // Convert to numeric format
    replace `var' = `var' / 100  // Divide by 100 to convert to decimal
}

	save "`output_data'/2018_voter_participation.dta", replace 
	
/*==============================================================================
									2016 
==============================================================================*/	
	
	
	import excel "`input_data'/2016_voter_participation.xlsx", sheet("Worksheet") firstrow clear
	// we will now split these by ballot 

	drop in 1/2
	// rename columns 
	rename VOTERPARTICIPATIONSTATISTICSB County
	rename B Number_of_Precincts
	rename C Eligible_to_Register
	rename D Registered_Voters
	rename E Precinct_Voters
	rename F Vote_By_Mail_Voters
	rename G Total_Voters
	rename H Percent_Vote_By_Mail
	rename I Turnout_Registered
	rename J Turnout_Eligible
	drop K
	
	// remove stars 
	foreach var of varlist County Number_of_Precincts Eligible_to_Register Registered_Voters Precinct_Voters {
    replace `var' = subinstr(`var', "*", "", .)  // Remove all asterisks
}
	
	// remove percent sign 
	foreach var of varlist Percent_Vote_By_Mail Turnout_Registered Turnout_Eligible {
    replace `var' = subinstr(`var', "%", "", .)  // Remove the percent sign
    destring `var', replace force  // Convert to numeric format
    replace `var' = `var' / 100  // Divide by 100 to convert to decimal
}

	drop in 59/60
	
	save "`output_data'/2016_voter_participation.dta", replace 
	