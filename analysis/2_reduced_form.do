/*==============================================================================
							1_regress_iv_master.do
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
	local input_data "`workingdir'/2_processing/merged_outcomes_for_reg"
	
	// output
	local outputs "/Users/eshavaze/Downloads"

	
/*============================================================================*/
	
						// REDUCED FORM REGRESSIONS 
		
/*============================================================================*/

/*==============================================================================
							RF NO CONTROLS 
==============================================================================*/

	use "`input_data'/2015_ces2_ballots.dta"
	
	reg Yes_Prop51 instrument 
	
	
	// pool all years of data 
	// year fe 
	// county fe 
	// cluster at the county level 
	
	// 2sls estimates without controls 
	
	// split ballots into environmental and non and report everything 
	
	// table structure:
	
	// 3 tables: OLS 2SLS In one table 
	// RF 
	// FS 
