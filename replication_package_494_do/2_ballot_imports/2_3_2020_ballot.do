/*==============================================================================
							4_3_2020_ballot.do
================================================================================

	PURPOSE:
	
		1. create yearly ballot outcome by county datasets 
		
	INPUTS:
		1. input_data/ballot_2020.xlsx
	
	OUTPUTS:
	
	
		
==============================================================================*/
	
/*==============================================================================
									2020 
==============================================================================*/	
	
	/*
	Proposition 14: Bonds to Continue Stem Cell Research
	Proposition 15: Property Tax to Fund Schools, Government Services
	Proposition 16: Affirmative Action in Government Decisions
	Proposition 17: Restores Right to Vote After Prison Term
	Proposition 18: 17-year-old Primary Voting Rights
	Proposition 19: Changes Certain Property Tax Rules
	Proposition 20: Parole Restrictions for Certain Offenses
	Proposition 21: Expands Governments' Authority to Rent Control
	Proposition 22: App-Based Drivers and Employee Benefits
	Proposition 23: State Requirements for Kidney Dialysis Clinics
	Proposition 24: Amends Consumer Privacy Laws
	Proposition 25: Eliminates Money Bail System
	
	*/



	import excel "$raw_input_data/ballots/ballot_2020.xlsx", sheet("Sheet 1") firstrow clear
	// we will now split these by ballot 
	
	// trim names 
	replace A = trim(A)
	rename A County
	
	// dropping unusable rows 
	drop if County == "Percent"
	drop if County == "State Totals"
	
	// rename columns 
	rename Proposition14 Yes_Prop14
	rename C No_Prop14
	rename Proposition15 Yes_Prop15
	rename E No_Prop15
	rename Proposition16 Yes_Prop16
	rename G No_Prop16
	rename Proposition17 Yes_Prop17
	rename I No_Prop17
	rename Proposition18 Yes_Prop18
	rename K No_Prop18
	rename Proposition19 Yes_Prop19
	rename M No_Prop19
	rename Proposition20 Yes_Prop20
	rename O No_Prop20
	rename Proposition21 Yes_Prop21
	rename Q No_Prop21
	rename Proposition22 Yes_Prop22
	rename S No_Prop22
	rename Proposition23 Yes_Prop23
	rename U No_Prop23
	rename Proposition24 Yes_Prop24
	rename W No_Prop24
	rename Proposition25 Yes_Prop25
	rename Y No_Prop25
	
	
	// save as separate datasets 
	foreach prop of numlist 14/25 {
    preserve
        keep County Yes_Prop`prop' No_Prop`prop'
        save "$intermediate_data/yearly_ballots/2020_prop_`prop'.dta", replace
    restore
}

	clear

	// processing each proposition 
	
	foreach prop of numlist 14/25 {
		// Load the dataset for each proposition
		use "$intermediate_data/yearly_ballots/2020_prop_`prop'.dta", clear

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
		save "$intermediate_data/yearly_ballots/2020_prop_`prop'.dta", replace
	}
