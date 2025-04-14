/*==============================================================================
							4_0_2014_ballot.do
================================================================================

	PURPOSE:
	
		1. create yearly ballot outcome by county datasets 
		
	INPUTS:
		1. input_data/ballot_june_2014.xls
		2. input_data/ballot_nov_2014.xls
	
	OUTPUTS:
	 - no environmental issues on june 
	 - 
		
		
==============================================================================*/

/*==============================================================================
									2014
==============================================================================*/	

		/*
		
								JUNE 
								PROP 41 AND 42
		
		
		*/


	import excel "$raw_input_data/ballots/ballot_june_2014.xls", sheet("Sheet1") firstrow clear
	
	// trim names 
	replace A = trim(A)
	rename A County
	
	// dropping unusable rows 
	drop if County == "Percent"
	drop if County == "State Totals"
	
	// renaming columns 
	rename Proposition41 Yes_Prop41 // Veterans Housing & Homeless Bond Act of 2014
	rename C No_Prop41
	rename Proposition42 Yes_Prop42 // Public Records. Open Meetings. Reimbursements.
	rename E No_Prop42
	
	// save as separate datasets 
	foreach prop of numlist 41/42 {
    preserve
        keep County Yes_Prop`prop' No_Prop`prop'
        save "$intermediate_data/yearly_ballots/2014_prop_`prop'.dta", replace
    restore
}

	clear
	
	// processing each proposition 
	
	foreach prop of numlist 41/42 {
		// Load the dataset for each proposition
		use "$intermediate_data/yearly_ballots/2014_prop_`prop'.dta", clear

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
		save "$intermediate_data/yearly_ballots/2014_prop_`prop'.dta", replace
	}

		/*
		
									NOVEMBER 
								PROP 1, 2 45-48
		
		
		*/
		
	import excel "$raw_input_data/ballots/ballot_nov_2014.xls", sheet("Sheet1") firstrow clear
	
	// trim names 
	replace A = trim(A)
	rename A County
		
	// dropping unusable rows 
	drop if County == "Percent"
	drop if County == "State Totals"
		
	// renaming columns 
	rename Proposition1 Yes_Prop1 
	rename C No_Prop1
	rename Proposition2 Yes_Prop2
	rename E No_Prop2
	rename Proposition45 Yes_Prop45
	rename G No_Prop45
	rename Proposition46 Yes_Prop46
	rename I No_Prop46
	rename Proposition47 Yes_Prop47
	rename K No_Prop47
	rename Proposition48 Yes_Prop48
	rename M No_Prop48
				
	/*
	
	Proposition 1 (C) – Funding Water Quality, Supply, Treatment, Storage
	Proposition 2 (E) – State Budget Stabilization Account
	Proposition 45 (G) – Healthcare Insurance Rate Changes
	Proposition 46 (I) – Doctor Drug Testing, Medical Negligence
	Proposition 47 (K) – Criminal Sentences, Misdemeanor Penalties
	Proposition 48 (M) – Indian Gaming Compacts Referendum
	
	*/
	
	// save as separate datasets 
	foreach prop of numlist 1 2 45 46 47 48 {
    preserve
        keep County Yes_Prop`prop' No_Prop`prop'
        save "$intermediate_data/yearly_ballots/2014_prop_`prop'.dta", replace
    restore
}

	clear
	
	// processing each proposition 
	
	foreach prop of numlist 1 2 45 46 47 48{
		// Load the dataset for each proposition
		use "$intermediate_data/yearly_ballots/2014_prop_`prop'.dta", clear

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
		save "$intermediate_data/yearly_ballots/2014_prop_`prop'.dta", replace
	}

	