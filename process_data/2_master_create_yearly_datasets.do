/*==============================================================================
							2_master_year.do
================================================================================

	PURPOSE:
		1. master do-file to create dataset with instrument for year year
		2. county level for each year 
	
		
		
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
	* code 
	local code "/Users/eshavaze/cap_and_trade"
	
	* workingdir
	local workingdir "/Users/eshavaze/Dropbox/cal_cap_and_trade"
	
	* input dir
	local input_data "`workingdir'/0_raw_input"
	di "`input_data'"

	* output dir
	local output_data "`workingdir'/1_input"
	di "`output_data'"
	
/*==============================================================================
								call do-files
==============================================================================*/		
	//a. 2015
	include "`code'/2_merge_2015.do"
	//b. 2016
	include "`code'/2_merge_2016.do"
