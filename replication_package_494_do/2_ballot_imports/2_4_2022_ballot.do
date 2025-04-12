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
									2020 
==============================================================================*/	
	
	/*
	
	Proposition 1: Constitutional Right to Reproductive Freedom
	Proposition 26: Sports Wagering on Tribal Lands
	Proposition 27: Online Sports Wagering Outside of Tribal Lands
	Proposition 28: Public School Arts and Music Education Funding
	Proposition 29: Regulates Kidney Dialysis Clinics
	Proposition 30: Tax to Fund ZEV/Wildfire Programs
	Proposition 31: Prohibition on Sale of Certain Tobacco Products
		
	*/
	
	import excel "$raw_input_data/ballots/ballot_2022.xlsx", sheet("sheet1") firstrow clear
	// we will now split these by ballot 
	
	// trim names 
	replace A = trim(A)
	rename A County
	
	// dropping unusable rows 
	drop if County == "Percent"
	drop if County == "State Totals"
	
	// rename columns 
	rename Proposition1 Yes_Prop1
	rename C No_Prop1
	rename Proposition26 Yes_Prop26
	rename E No_Prop26
	rename Proposition27 Yes_Prop27
	rename G No_Prop27
	rename Proposition28 Yes_Prop28
	rename I No_Prop28
	rename Proposition29 Yes_Prop29
	rename K No_Prop29
	rename Proposition30 Yes_Prop30
	rename M No_Prop30
	rename Proposition31 Yes_Prop31
	rename O No_Prop31
		
	
	// save as separate datasets 
	foreach prop in 1 26 27 28 29 30 31 {
    preserve
        keep County Yes_Prop`prop' No_Prop`prop'
        save "$1_intermediate/yearly_ballots/2022_prop_`prop'.dta", replace
    restore
}

	clear

	// processing each proposition 
	
	foreach prop in 1 26 27 28 29 30 31 {
		// Load the dataset for each proposition
		use "$1_intermediate/yearly_ballots/2022_prop_`prop'.dta", clear

		// Drop first three rows 
		drop in 1/3

		// Drop rows where County is empty
		drop if County == ""

		// Trim any trailing whitespace in the County variable
		replace County = trim(County)
		destring Yes_Prop`prop', replace 
		destring No_Prop`prop', replace

	// Generate pass binary based on majority vote
		gen prop_yes_`prop' =  Yes_Prop`prop' / (Yes_Prop`prop' + No_Prop`prop')
		gen pass_binary_`prop' = 1 if prop_yes_`prop' > 0.50 // Majority vote (yes > no)
		replace pass_binary_`prop' = 0 if pass_binary_`prop' == .

		// Save the processed dataset
		save "$1_intermediate/yearly_ballots/2022_prop_`prop'.dta", replace
	}
