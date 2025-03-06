/*==============================================================================
							4_ballot_imports.do
================================================================================

	PURPOSE:
	
		1. produce processed ballot data files 
		
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
	local input_data "`workingdir'/0_raw_input/ballots"
	
	// output
	local output_data "`workingdir'/2_processing"
	
	// code 
	local do_dir "/Users/eshavaze/cap_and_trade/process_data/4_ballot_imports"
	
/*============================================================================*/
		
								// RUNNING FILES 
		
/*============================================================================*/		
	
	// 2012
	include "`do_dir'/4_0_2012_ballot.do"
	
	// 2014
	include "`do_dir'/4_0_2014_ballot.do"
	
	// 2016 
	include "`do_dir'/4_1_2016_ballot.do"
	
	// 2018
	include "`do_dir'/4_2_2018_ballot.do"

	// 2020 
	include "`do_dir'/4_3_2020_ballot.do"
	
	// 2022 
	include "`do_dir'/4_4_2022_ballot.do"
