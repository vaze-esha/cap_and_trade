/*==============================================================================
							7_merge_with_outcomes.do
================================================================================

	PURPOSE:
	
		1. merge outputs from 6 with outcomes voting data 
		
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
	local input_yearly "`workingdir'/2_processing/final_datasets"
	local input_ballot "`workingdir'/2_processing/yearly_ballots"
	
	// output
	local output_data "`workingdir'/2_processing/final_datasets"
	
/*==============================================================================
										2015
==============================================================================*/
