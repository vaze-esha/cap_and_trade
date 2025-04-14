/*==============================================================================
							4_2_2018_ballot.do
================================================================================

	PURPOSE:
	
		1. create yearly ballot outcome by county datasets 
		
	INPUTS:
		1. input_data/ballot_june_2018.xls
		2. input_data/ballot_nov_2018.xls
	
	OUTPUTS:
		2018_prop_68.dta
		2018_prop_69.dta
		2018_prop_70.dta
		2018_prop_71.dta
		2018_prop_72.dta
		2018_prop_1.dta
		2018_prop_2.dta
		2018_prop_3.dta
		2018_prop_4.dta
		2018_prop_5.dta
		2018_prop_6.dta
		2018_prop_7.dta
		2018_prop_8.dta
		2018_prop_10.dta
		2018_prop_11.dta
		2018_prop_12.dta
	
		
==============================================================================*/

/*==============================================================================
									2018
==============================================================================*/	

	/*
	
								JUNE BALLOT 
								PROPOSITION 68-72

		- Proposition 68 – Natural Resources Bond
		- Proposition 69 – Transportation Revenue: Restrictions and Limits
		- Proposition 70 – Greenhouse Gas Reduction Reserve Fund
		- Proposition 71 – Ballot Measures: Effective Date
		- Proposition 72 – Property Tax: New Construction: Rain-Capture
	
	*/
	
	import excel "$raw_input_data/ballots/ballot_june_2018.xls", sheet("Sheet1") firstrow clear
	
	// we will now split these by ballot 
	
	// trim names 
	replace A = trim(A)
	rename A County
	
	// dropping unusable rows 
	drop if County == "Percent"
	drop if County == "State Totals"
	
	// renaming columns
	rename Proposition68 Yes_Prop68
	rename C No_Prop68
	rename Proposition69 Yes_Prop69
	rename E No_Prop69
	rename Proposition70 Yes_Prop70
	rename G No_Prop70
	rename Proposition71 Yes_Prop71
	rename I No_Prop71
	rename Proposition72 Yes_Prop72
	rename K No_Prop72

	// save as separate datasets 
	foreach prop in 68 69 70 71 72 {
    preserve
        keep County Yes_Prop`prop' No_Prop`prop'
        save "$intermediate_data/yearly_ballots/2018_prop_`prop'.dta", replace
    restore
}

	clear

	// processing each proposition 
	
	foreach prop of numlist 68/72 {
		// Load the dataset for each proposition
		use "$intermediate_data/yearly_ballots/2018_prop_`prop'.dta", clear

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
		save "$intermediate_data/yearly_ballots/2018_prop_`prop'.dta", replace
	}
	
	clear

	/*
	
								NOVEMBER BALLOT
								PROPOSITION 1-12

			1. Proposition 1: Bonds to Fund Veteran & Affordable Housing  
			2. Proposition 2: Amend Existing Housing Program for Mental Illness  
			3. Proposition 3: Bond for Water and Environmental Projects  
			4. Proposition 4: Bond for Children's Hospital Construction  
			5. Proposition 5: Senior Property Reduction  
			6. Proposition 6: Repeal of Fuel Tax  
			7. Proposition 7: Change Daylight Saving Time Period  
			8. Proposition 8: Regulates Kidney Dialysis Treatment Charges  
			9. Proposition 10: Rental Control on Residential Property  
			10. Proposition 11: Emergency Ambulance Employees On-Call  
			11. Proposition 12: Farm Animals Confinement Standards  

	*/
	
	
	import excel "$raw_input_data/ballots/ballot_nov_2018.xls", sheet("Sheet1") firstrow clear
	
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
	rename Proposition2 Yes_Prop2
	rename E No_Prop2
	rename Proposition3 Yes_Prop3
	rename G No_Prop3
	rename Proposition4 Yes_Prop4
	rename I No_Prop4
	rename Proposition5 Yes_Prop5
	rename K No_Prop5
	rename Proposition6 Yes_Prop6
	rename M No_Prop6
	rename Proposition7 Yes_Prop7
	rename O No_Prop7
	rename Proposition8 Yes_Prop8
	rename Q No_Prop8
	rename Proposition10 Yes_Prop10
	rename S No_Prop10
	rename Proposition11 Yes_Prop11
	rename U No_Prop11
	rename Proposition12 Yes_Prop12
	rename W No_Prop12
	
	
	// save as separate datasets 
	foreach prop of numlist 1 2 3 4 5 6 7 8 10 11 12 {
    preserve
        keep County Yes_Prop`prop' No_Prop`prop'
        save "$intermediate_data/yearly_ballots/2018_prop_`prop'.dta", replace
    restore
}

	clear

	// processing each proposition 
	
	foreach prop of numlist 1 2 3 4 5 6 7 8 10 11 12 {
		// skip prop 9
		// Load the dataset for each proposition
		use "$intermediate_data/yearly_ballots/2018_prop_`prop'.dta", clear

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
		save "$intermediate_data/yearly_ballots/2018_prop_`prop'.dta", replace
	}
	
	clear
