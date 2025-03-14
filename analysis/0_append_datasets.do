/*==============================================================================
							0_append_datasets.do
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
	
						// APPEND ALL YEARS 
		
/*============================================================================*/

	// FS DATA 

	use "`input_data'/final_datasets/2015_ces2.dta"

	foreach file in 2016_ces2.dta 2017_ces2.dta 2018_ces2.dta 2018_ces3.dta ///
					2019_ces3.dta 2020_ces3.dta 2021_ces3.dta 2022_ces3.dta 2023_ces3.dta {
		append using "`input_data'/final_datasets/`file'"
		drop ProjectIDNumber AgencyName ProgramName ProgramDescription SubProgramName ProjectDescription CensusTract SenateDistrict AssemblyDistrict ApplicantsAssisted geo_id ProjectLifeYears DateOperational ProjectCompletionDate FundingRecipient TotalProjectCost BufferAmount BufferCount CESVersion CESVersionCalc IntermediaryAdminExpensesCalc
	}

	save "`input_data'/appended_all_years.dta", replace

	
	// merged with outcomes data 
	
	clear
	use "`input_data'/merged_outcomes_for_reg/2015_ces2_ballots.dta"

	foreach file in 2016_ces2_ballots.dta 2017_ces2_ballots.dta 2018_ces2_ballots.dta 2018_ces3_ballots.dta ///
					2019_ces3_ballots.dta 2020_ces3_ballots.dta 2021_ces3_ballots.dta 2022_ces3_ballots.dta {
		append using "`input_data'/merged_outcomes_for_reg/`file'"
		drop ProjectIDNumber AgencyName ProgramName ProgramDescription SubProgramName ProjectDescription CensusTract SenateDistrict AssemblyDistrict ApplicantsAssisted geo_id ProjectLifeYears DateOperational ProjectCompletionDate FundingRecipient TotalProjectCost BufferAmount BufferCount CESVersion CESVersionCalc IntermediaryAdminExpensesCalc
	}

	save "`input_data'/ces_all_ballots_appended.dta", replace
