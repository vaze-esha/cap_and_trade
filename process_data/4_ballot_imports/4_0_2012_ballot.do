/*==============================================================================
							4_0_2012_ballot.do
================================================================================

	PURPOSE:
	
		1. create yearly ballot outcome by county datasets 
		
	INPUTS:
		1. input_data/ballot_june_2012.xls
		2. input_data/ballot_nov_2012.xls
	
	OUTPUTS:

		
		
==============================================================================*/

/*==============================================================================
									2012
==============================================================================*/	

		/*
		
								JUNE 
								PROP 28 AND 29

		
		
		*/
	
	
	import excel "`input_data'/ballot_june_2012.xls", sheet("Sheet1") firstrow clear
	
	// trim names 
	replace A = trim(A)
	rename A County
	
	// dropping unusable rows 
	drop if County == "Percent"
	drop if County == "State Totals"
	
	// empty col 
	drop D
	
	// rnaming columns 
	rename Proposition28 Yes_Prop28
	rename C No_Prop28
	rename Proposition29 Yes_Prop29
	rename F No_Prop29
	
	/*
	
	Proposition28	Limits on Legislators' Terms in Office
	Proposition29 	Tax on Cigarettes for Cancer Research 
	
	*/
	
	// save as separate datasets 
	foreach prop of numlist 28/29 {
    preserve
        keep County Yes_Prop`prop' No_Prop`prop'
        save "`output_data'/yearly_ballots/2012_prop_`prop'.dta", replace
    restore
}

	clear
	
	// processing each proposition 
	
	foreach prop of numlist 28/29 {
		// Load the dataset for each proposition
		use "`output_data'/yearly_ballots/2012_prop_`prop'.dta", clear

		// Drop first three rows 
		drop in 1/2

		// Rename variables
		rename (Yes_Prop`prop' No_Prop`prop') (Yes No)

		// Drop rows where County is empty
		drop if County == ""

		// Trim any trailing whitespace in the County variable
		replace County = trim(County)
		destring Yes, replace 
		destring No, replace

		// Generate pass binary based on majority vote
		gen prop_yes = Yes / (Yes + No)
		gen pass_binary = 1 if prop_yes > 0.50 // Majority vote (yes > no)
		replace pass_binary = 0 if pass_binary == .

		// Save the processed dataset
		save "`output_data'/yearly_ballots/2012_prop_`prop'.dta", replace
	}
	
	
		/*
		
								NOVEMBER 

		
		
		*/
	import excel "`input_data'/ballot_nov_2012.xls", sheet("Sheet1") firstrow clear
	
	// trim names 
	replace A = trim(A)
	rename A County
	
	// dropping unusable rows 
	drop if County == "Percent"
	drop if County == "State Totals"
	
	// renaming columns
	rename Proposition30 Yes_Prop30  
	rename C No_Prop30  
	rename Proposition31 Yes_Prop31  
	rename E No_Prop31  
	rename Proposition32 Yes_Prop32  
	rename G No_Prop32  
	rename Proposition33 Yes_Prop33  
	rename I No_Prop33  
	rename Proposition34 Yes_Prop34  
	rename K No_Prop34  
	rename Proposition35 Yes_Prop35  
	rename M No_Prop35  
	rename Proposition36 Yes_Prop36  
	rename O No_Prop36  
	rename Proposition37 Yes_Prop37  
	rename Q No_Prop37  
	rename Proposition38 Yes_Prop38  
	rename S No_Prop38  
	rename Proposition39 Yes_Prop39  
	rename U No_Prop39  
	rename Proposition40 Yes_Prop40  
	rename W No_Prop40  

	
	/*
	
	Proposition 30 – Temporary Taxes to Fund Education
	Proposition 31 – State Budget, State and Local Government
	Proposition 32 – Political Contributions by Payroll Deduction
	Proposition 33 – Auto Insurance Prices Based on Driver History
	Proposition 34 – Death Penalty
	Proposition 35 – Human Trafficking
	Proposition 36 – Three Strikes Law
	Proposition 37 – Genetically Engineered Foods Labeling
	Proposition 38 – Tax for Education, Early Childhood Programs
	Proposition 39 – Business Tax for Energy Funding
	Proposition 40 – Redistricting State Senate
	
	*/
	
	// save as separate datasets 
	foreach prop of numlist 30/40{
    preserve
        keep County Yes_Prop`prop' No_Prop`prop'
        save "`output_data'/yearly_ballots/2012_prop_`prop'.dta", replace
    restore
}

	clear
	
	// processing each proposition 
	
	foreach prop of numlist 30/40{
		// Load the dataset for each proposition
		use "`output_data'/yearly_ballots/2012_prop_`prop'.dta", clear

		// Drop first three rows 
		drop in 1/3

		// Rename variables
		rename (Yes_Prop`prop' No_Prop`prop') (Yes No)

		// Drop rows where County is empty
		drop if County == ""

		// Trim any trailing whitespace in the County variable
		replace County = trim(County)
		destring Yes, replace 
		destring No, replace

		// Generate pass binary based on majority vote
		gen prop_yes = Yes / (Yes + No)
		gen pass_binary = 1 if prop_yes > 0.50 // Majority vote (yes > no)
		replace pass_binary = 0 if pass_binary == .

		// Save the processed dataset
		save "`output_data'/yearly_ballots/2012_prop_`prop'.dta", replace
	}

	
	
	