/*==============================================================================
							4_1_2016_ballot.do
================================================================================

	PURPOSE:
	
		1. create yearly ballot outcome by county datasets 
		
	INPUTS:
		1. input_data/ballot_june_2016.xls
		2. input_data/ballot_nov_2016.xls
	
	OUTPUTS:
		output_data/yearly_ballots/2016_prop_50.dta
		output_data/yearly_ballots/2016_prop_51.dta
		output_data/yearly_ballots/2016_prop_52.dta
		output_data/yearly_ballots/2016_prop_53.dta
		output_data/yearly_ballots/2016_prop_54.dta
		output_data/yearly_ballots/2016_prop_55.dta
		output_data/yearly_ballots/2016_prop_56.dta
		output_data/yearly_ballots/2016_prop_57.dta
		output_data/yearly_ballots/2016_prop_58.dta
		output_data/yearly_ballots/2016_prop_59.dta
		output_data/yearly_ballots/2016_prop_60.dta
		output_data/yearly_ballots/2016_prop_61.dta
		output_data/yearly_ballots/2016_prop_62.dta
		output_data/yearly_ballots/2016_prop_63.dta
		output_data/yearly_ballots/2016_prop_64.dta
		output_data/yearly_ballots/2016_prop_65.dta
		output_data/yearly_ballots/2016_prop_66.dta
		output_data/yearly_ballots/2016_prop_67.dta
				
		
==============================================================================*/


/*==============================================================================
									2016
==============================================================================*/	

	/*
	
								JUNE BALLOT 
								PROPOSITION 50
	
	*/

	import excel "$raw_input_data/ballots/ballot_june_2016.xls", sheet("Sheet1") cellrange(A4) firstrow clear
	// empties
	drop if Yes==. & No==.
	destring Yes No, replace 
	
	// trim names 
	replace A = trim(A)
	rename A County
	rename Yes Yes_Prop50
	rename No No_Prop50

	// dropping unusable rows 
	drop if County == "Percent"
	drop if County == "State Totals"
	
	// generate pass binary 
	gen prop_yes_50 =  Yes_Prop50 / (Yes_Prop50 + No_Prop50)
	gen pass_binary_50 = 1 if prop_yes_50>0.50 // majority vote
	replace pass_binary_50 = 0 if pass_binary_50==.

	notes: PROP50 SUSPENSION OF LEGISLATORS (passed) file made on TS
     
	save "$intermediate_data/yearly_ballots/2016_prop_50.dta", replace 
	
	/*
	
								NOVEMBER BALLOT
							    PROPOSITIONS 51-67
	
	*/
	
	import excel "$raw_input_data/ballots/ballot_nov_2016.xls", sheet("Sheet1") firstrow clear
	// we will now split these by ballot 
	
	// trim names 
	replace A = trim(A)
	rename A County
	
	// dropping unusable rows 
	drop if County == "Percent"
	drop if County == "State Totals"
	
	// renaming columns 
	rename Proposition51 Yes_Prop51
	rename C No_Prop51
	rename Proposition52 Yes_Prop52
	rename E No_Prop52
	rename Proposition53 Yes_Prop53
	rename G No_Prop53
	rename Proposition54 Yes_Prop54
	rename I No_Prop54
	rename Proposition55 Yes_Prop55
	rename K No_Prop55
	rename Proposition56 Yes_Prop56
	rename M No_Prop56
	rename Proposition57 Yes_Prop57
	rename O No_Prop57
	rename Proposition58 Yes_Prop58
	rename Q No_Prop58
	rename Proposition59 Yes_Prop59
	rename S No_Prop59
	rename Proposition60 Yes_Prop60
	rename U No_Prop60
	rename Proposition61 Yes_Prop61
	rename W No_Prop61
	rename Proposition62 Yes_Prop62
	rename Y No_Prop62
	rename Proposition63 Yes_Prop63
	rename AA No_Prop63
	rename Proposition64 Yes_Prop64
	rename AC No_Prop64
	rename Proposition65 Yes_Prop65
	rename AE No_Prop65
	rename Proposition66 Yes_Prop66
	rename AG No_Prop66
	rename Proposition67 Yes_Prop67
	rename AI No_Prop67
	
	// save as separate datasets 
	foreach prop in 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 {
    preserve
        keep County Yes_Prop`prop' No_Prop`prop'
        save "$intermediate_data/yearly_ballots/2016_prop_`prop'.dta", replace
    restore
}

	clear

	// processing each proposition 
	
	foreach prop of numlist 51/67 {
		// Load the dataset for each proposition
		use "$intermediate_data/yearly_ballots/2016_prop_`prop'.dta", clear

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
		save "$intermediate_data/yearly_ballots/2016_prop_`prop'.dta", replace
	}

	/*

			1. Proposition 50 – Suspension of Legislators
			2. Proposition 51 – K-12 and Community College Facilities
			3. Proposition 52 – Medi-Cal Hospital Fee Program
			4. Proposition 53 – Voter Approval of Revenue Bonds
			5. Proposition 54 – Legislative Procedure Requirements
			6. Proposition 55 – Tax Extension for Education and Healthcare
			7. Proposition 56 – Cigarette Tax
			8. Proposition 57 – Criminal Sentences & Juvenile Crime Proceedings
			9. Proposition 58 – English Proficiency. Multilingual Education.
			10. Proposition 59 – Corporate Political Spending Advisory Question
			11. Proposition 60 – Adult Film Condom Requirements
			12. Proposition 61 – State Prescription Drug Purchase Standards
			13. Proposition 62 – Repeal of Death Penalty
			14. Proposition 63 – Firearms and Ammunition Sales
			15. Proposition 64 – Marijuana Legalization
			16. Proposition 65 – Carryout Bag Charges
			17. Proposition 66 – Death Penalty Procedure Time Limits
			18. Proposition 67 – Ban on Single-use Plastic Bags

	*/
