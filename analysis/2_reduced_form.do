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
	local input_data "`workingdir'/2_processing/final_datasets"
	
	// output
	local outputs "/Users/eshavaze/Dropbox/Apps/Overleaf/a3_emv_econ_494/rf_no_controls"

	
/*============================================================================*/
	
						// REDUCED FORM REGRESSIONS 
		
/*============================================================================*/


/*==============================================================================
							RF NO CONTROLS 
==============================================================================*/
