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

	/*
	
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

/*============================================================================*/
	
						// APPEND ALL BALLOTS
		
/*============================================================================*/
	
	// merged with outcomes data 
	
	clear
	use "`input_data'/yearly_ballots/2012_prop_28.dta"

	local files 2012_prop_29 2012_prop_30 2012_prop_31 2012_prop_32 2012_prop_33 2012_prop_34 2012_prop_35 2012_prop_36 2012_prop_37 2012_prop_38 2012_prop_39 2012_prop_40 2014_prop_1 2014_prop_2 2014_prop_41 2014_prop_42 2014_prop_45 2014_prop_46 2014_prop_47 2014_prop_48 2016_prop_50 2016_prop_51 2016_prop_52 2016_prop_53 2016_prop_54 2016_prop_55 2016_prop_56 2016_prop_57 2016_prop_58 2016_prop_59 2016_prop_60 2016_prop_61 2016_prop_62 2016_prop_63 2016_prop_64 2016_prop_65 2016_prop_66 2016_prop_67 2018_prop_1 2018_prop_10 2018_prop_11 2018_prop_12 2018_prop_2 2018_prop_3 2018_prop_4 2018_prop_5 2018_prop_6 2018_prop_68 2018_prop_69 2018_prop_7 2018_prop_70 2018_prop_71 2018_prop_72 2018_prop_8 2020_prop_14 2020_prop_15 2020_prop_16 2020_prop_17 2020_prop_18 2020_prop_19 2020_prop_20 2020_prop_21 2020_prop_22 2020_prop_23 2020_prop_24 2020_prop_25 2022_prop_1 2022_prop_26 2022_prop_27 2022_prop_28 2022_prop_29 2022_prop_30 2022_prop_31

	foreach file in `files' {
		merge 1:1 County using "`input_data'/yearly_ballots/`file'"
		drop _merge
		
	}

	save "`input_data'/all_ballots_appended.dta", replace
	clear

/*============================================================================*/
	
								// merge 
		
/*============================================================================*/
	
	
	// now merge with appended pooled sample for all years 
	use  "`input_data'/all_ballots_appended.dta"
	
	merge 1:m County using "`input_data'/appended_all_years.dta", keepusing(Year *)
	drop if _merge == 1 
	
	save "`input_data'/rf_dataset.dta", replace 
	
*/


/*============================================================================*/
	
						// APPEND UNTIL 2018 ONLY 
		
/*============================================================================*/

	// FS DATA 

	use "`input_data'/final_datasets/2015_ces2.dta"

	foreach file in 2016_ces2.dta 2017_ces2.dta 2018_ces2.dta 2018_ces3.dta {
		append using "`input_data'/final_datasets/`file'"
		drop ProjectIDNumber AgencyName ProgramName ProgramDescription SubProgramName ProjectDescription CensusTract SenateDistrict AssemblyDistrict ApplicantsAssisted geo_id ProjectLifeYears DateOperational ProjectCompletionDate FundingRecipient TotalProjectCost BufferAmount BufferCount CESVersion CESVersionCalc IntermediaryAdminExpensesCalc
	}

	save "`input_data'/appended_all_years_2018.dta", replace
	
	
	clear

/*============================================================================*/
	
						// APPEND ALL BALLOTS 2018 only 
		
/*============================================================================*/
	
	// merged with outcomes data 

	use "`input_data'/yearly_ballots/2012_prop_28.dta"

	local files 2018_prop_1 2018_prop_10 2018_prop_11 2018_prop_12 2018_prop_2 2018_prop_3 2018_prop_4 2018_prop_5 2018_prop_6 2018_prop_68 2018_prop_69 2018_prop_7 2018_prop_70 2018_prop_71 2018_prop_72 2018_prop_8 

	foreach file in `files' {
		merge 1:1 County using "`input_data'/yearly_ballots/`file'"
		drop _merge
		
	}

	save "`input_data'/2018_ballots_appended.dta", replace
	clear

/*============================================================================*/
	
								// merge 
		
/*============================================================================*/
	
	
	// now merge with appended pooled sample for all years 
	use  "`input_data'/2018_ballots_appended.dta"
	
	merge 1:m County using "`input_data'/appended_all_years_2018.dta", keepusing(Year *)
	drop if _merge == 1 
	drop _merge
	
	save "`input_data'/rf_dataset.dta", replace 
	
	
	
	
/*============================================================================*/
	
						// APPEND ALL BALLOTS 2014 only 
		
/*============================================================================*/
	
	// merged with outcomes data 

	use "`input_data'/yearly_ballots/2012_prop_28.dta"

	local files 2014_prop_1 2014_prop_2 2014_prop_41 2014_prop_42 2014_prop_45 2014_prop_46 2014_prop_47 2014_prop_48

	foreach file in `files' {
		merge 1:1 County using "`input_data'/yearly_ballots/`file'"
		drop _merge
		
	}

	save "`input_data'/2014_ballots_appended.dta", replace
	clear

/*============================================================================*/
	
								// merge 
		
/*============================================================================*/
	
	
	// now merge with appended pooled sample for all years 
	use  "`input_data'/2014_ballots_appended.dta"
	
	merge 1:m County using "`input_data'/appended_all_years_2018.dta", keepusing(Year *)
	drop if _merge == 1 
	
	save "`input_data'/rf_dataset_placebo.dta", replace 
	

/*============================================================================*/
	
						// APPEND ALL BALLOTS 2014 only 
		
/*============================================================================*/
	
	* Start with first proposition
	use "`input_data'/yearly_ballots/2012_prop_28.dta", clear
	rename pass_binary_28 pass28  // make it easier to track
	tempfile merged
	save `merged'

	* Loop through the rest
	local props 29 30 38 39

	foreach p of local props {
		use "`input_data'/yearly_ballots/2012_prop_`p'.dta", clear
		rename pass_binary_`p' pass`p'
		merge 1:1 County using `merged'
		drop _merge
		save `merged', replace
	}

	use `merged', clear

	* Now construct tax aversion index (e.g., sum of "No" votes)
	gen tax_averse_score = (pass28 == 0) + (pass29 == 0) + (pass30 == 0) + (pass38 == 0) + (pass39 == 0)

	* Optional binary version: high tax aversion if 3+ of 5 "No"
	gen high_tax_averse = (tax_averse_score >= 3)

	label var tax_averse_score "Number of No votes on 2012 tax/spend props"
	label var high_tax_averse "High tax aversion (3+ No votes)"


	save "`input_data'/2012_ballots_appended.dta", replace

	clear

/*============================================================================*/
	
								// merge 
		
/*============================================================================*/
	
	
	// now merge with appended pooled sample for all years 
	use  "`input_data'/2012_ballots_appended.dta"
	
	merge 1:m County using"`input_data'/rf_dataset.dta", keepusing(Year *)
	drop if _merge == 1 
	
	save "`input_data'/rf_dataset_mechanisms_tax.dta", replace 
	
	
	
