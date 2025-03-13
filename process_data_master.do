/*==============================================================================
							MASTER_PROCESS_DATA
================================================================================

	PURPOSE:
	
		1. Import covariates and clean them (median hh income by county and transit modes)
		
	INPUTS:
		1. ACSDP1Y`year'.DP03-Data.csv
	
	OUTPUTS:
		1. hh_income_transit_`year'.dta

		
		
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

	local dodir "/Users/eshavaze/cap_and_trade/process_data"
	
	// clean cci dataset
	//do "`dodir'/1_clean_cci.do" // takes really long to run 
	
	// create instrument with ces dataset
	do "`dodir'/2_create_instrument.do"
	// merge cci and ces datasets 
	do "`dodir'/3_merge_year_instrument_datasets.do"

	// create ballot imports for output data
	do "`dodir'/4_ballot_imports_master.do"
	
	// process all covariates 
	do "`dodir'/5_process_covariates.do"
	
	// merge covariates
	do "`dodir'/6_merge_covariates.do"

	display "All scripts have been executed successfully!"
