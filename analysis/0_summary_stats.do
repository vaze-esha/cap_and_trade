/*==============================================================================
							0_summary_stats.do
================================================================================

	PURPOSE:
	
		1. summary stats tables
			
		
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
	local input_data "`workingdir'/2_processing"
	

	// output
	local outputs "/Users/eshavaze/Downloads"

	
/*============================================================================*/
	
							// SUMMARY STATS 
		
/*============================================================================*/

	use "`input_data'/rf_dataset.dta"
	
	sort County

	levelsof County, local(counties)
	
	encode County, gen(county_id) 
	gen tot_funding_scaled=TOT_funding/1000000
	
	* Get unique county_id values from the dataset
	levelsof county_id, local(county_ids)

	* Loop through each county_id and collect summary statistics
	foreach county_id of local county_ids {
		* Subset data for the current county
		preserve
		keep if county_id == `county_id'

		* Run the summary statistics for the variables
		eststo summstats_`county_id': estpost summarize tot_funding_scaled log_funding instrument

		* Restore the full dataset
		restore
	}

	* Export the summary statistics to a LaTeX file with counties as rows
	esttab summstats_* using "`outputs'/table_summ.tex", replace main(mean %6.2f) aux(sd) 
	// switch rows and columns 
