/*==============================================================================
						2_construct_instruments.do
================================================================================

	PURPOSE:
	
		1. merge each cci_year dataset with instrument values 
		
	INPUTS:
		1. 
	
	OUTPUTS:
		1. 
		
		
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

	* detect user 
	local system_string `c(username)' // Get Stata dir.
	display "Current user, `c(username)' `c(machine_type)' `c(os)'."

	if inlist( "`c(username)'" , "eshavaze") {

		local workingdir "/Users/eshavaze/Dropbox/cal_cap_and_trade"

	}

	* add your path here *
	
	else {
	  noisily display as error _newline "{phang}Your username [`c(username)'] could not be matched with a profile. Check do-file header and try again.{p_end}"
	  error 2222
	}

	di "This project is working from `workingdir'"

/*============================================================================*/
		
/*============================================================================*/		
	
	* input dir
	local input_data "`workingdir'/1_input"
	di "`input_data'"

	* output dir
	local output_data "`workingdir'/2_processing"
	di "`output_data'"

/*============================================================================*/	
	

/*==============================================================================
									2015
==============================================================================*/	

	// load yearly data
	use "`input_data'/cci_yearly/cci_2015.dta"
	/*
	 CESVersion |      Freq.     Percent        Cum.
	------------+-----------------------------------
			  2 |     16,068      100.00      100.00
	------------+-----------------------------------
		  Total |     16,068      100.00
	*/
	
	merge m:1 County using "`input_data'/instrument_yearly/ces2_2015.dta" 
	drop if _merge==1 // counties with no census tracts in the bandwidht 
	
	
	// creating the funding variable 
	
	// keep unfunded tracts in dataset, these are true zeroes 
	count if TotalProgramGGRFFunding==.
	// 1,294
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	
	// version 2 only in this dataset
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)

	drop _merge
	
	// FS 
	// reg TOT_funding instrument, cluster(County)
	
	save "`output_data'/2015.dta", replace 
	
/*==============================================================================
									2016
==============================================================================*/
		
	// load yearly data
	use "`input_data'/cci_yearly/cci_2016.dta"
	
	/*
	 CESVersion |      Freq.     Percent        Cum.
------------+-----------------------------------
          2 |     11,525       99.60       99.60
          3 |         46        0.40      100.00
------------+-----------------------------------
      Total |     11,571      100.00
*/

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "`input_data'/instrument_yearly/ces`v'_2016.dta"
			drop if _merge==1
			drop _merge 
			save "`input_data'/cci_temp_`v'_2016.dta", replace
		restore
	}
	
	use "`input_data'/cci_temp_2_2016.dta", clear
	append using "`input_data'/cci_temp_3_2016.dta"
	save "`output_data'/2016.dta", replace 
	
	count if TotalProgramGGRFFunding==.
	// 1,294
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	
	// version 2and3 only in this dataset
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	
	// FS 
	//reg TOT_funding instrument, cluster(County)
	save "`output_data'/2016.dta", replace 

/*==============================================================================
									2017
==============================================================================*/
		
	// load yearly data
	use "`input_data'/cci_yearly/cci_2017.dta"
	
	/*
	 CESVersion |      Freq.     Percent        Cum.
------------+-----------------------------------
          2 |     12,618       85.05       85.05
          3 |      2,218       14.95      100.00
------------+-----------------------------------
      Total |     14,836      100.00

*/

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "`input_data'/instrument_yearly/ces`v'_2017.dta"
			drop if _merge==1
			drop _merge 
			save "`input_data'/cci_temp_`v'_2017.dta", replace
		restore
	}
	
	use "`input_data'/cci_temp_2_2017.dta", clear
	append using "`input_data'/cci_temp_3_2017.dta"
	save "`output_data'/2017.dta", replace 
	
	count if TotalProgramGGRFFunding==.
	// 1,294
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	
	// version 2and3 only in this dataset
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	
	// FS 
	//reg TOT_funding instrument, cluster(County)
	save "`output_data'/2017.dta", replace 
		
/*==============================================================================
									2018
==============================================================================*/

	// load yearly data
	use "`input_data'/cci_yearly/cci_2018.dta"
	
	/*
	 CESVersion |      Freq.     Percent        Cum.
------------+-----------------------------------
          2 |     12,618       85.05       85.05
          3 |      2,218       14.95      100.00
------------+-----------------------------------
      Total |     14,836      100.00

*/

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "`input_data'/instrument_yearly/ces`v'_2018.dta"
			drop if _merge==1
			drop _merge 
			save "`input_data'/cci_temp_`v'_2018.dta", replace
		restore
	}
	
	use "`input_data'/cci_temp_2_2018.dta", clear
	append using "`input_data'/cci_temp_3_2018.dta"
	save "`output_data'/2018.dta", replace 
	
	count if TotalProgramGGRFFunding==.
	// 1,294
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	
	// version 2and3 only in this dataset
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	
	// FS 
	//reg TOT_funding instrument, cluster(County)
	save "`output_data'/2018.dta", replace 

/*==============================================================================
									2019
==============================================================================*/


	// load yearly data
	use "`input_data'/cci_yearly/cci_2019.dta"
	
	/*
	 CESVersion |      Freq.     Percent        Cum.
------------+-----------------------------------
          2 |     12,618       85.05       85.05
          3 |      2,218       14.95      100.00
------------+-----------------------------------
      Total |     14,836      100.00

*/

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "`input_data'/instrument_yearly/ces`v'_2019.dta"
			drop if _merge==1
			drop _merge 
			save "`input_data'/cci_temp_`v'_2019.dta", replace
		restore
	}
	
	use "`input_data'/cci_temp_2_2019.dta", clear
	append using "`input_data'/cci_temp_3_2019.dta"
	save "`output_data'/2019.dta", replace 
	
	count if TotalProgramGGRFFunding==.
	// 1,294
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	
	// version 2and3 only in this dataset
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	
	// FS 
	//reg TOT_funding instrument, cluster(County)
	save "`output_data'/2019.dta", replace 

/*==============================================================================
									2020
==============================================================================*/
	
	// load yearly data
	use "`input_data'/cci_yearly/cci_2020.dta"
	
	/*
	 CESVersion |      Freq.     Percent        Cum.
------------+-----------------------------------
          2 |     12,618       85.05       85.05
          3 |      2,218       14.95      100.00
------------+-----------------------------------
      Total |     14,836      100.00

*/

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "`input_data'/instrument_yearly/ces`v'_2020.dta"
			drop if _merge==1
			drop _merge 
			save "`input_data'/cci_temp_`v'_2020.dta", replace
		restore
	}
	
	use "`input_data'/cci_temp_2_2020.dta", clear
	append using "`input_data'/cci_temp_3_2020.dta"
	save "`output_data'/2020.dta", replace 
	
	count if TotalProgramGGRFFunding==.
	// 1,294
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	
	// version 2and3 only in this dataset
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	
	// FS 
	//reg TOT_funding instrument, cluster(County)
	save "`output_data'/2020.dta", replace 
	
/*==============================================================================
									2021
==============================================================================*/
	
	// load yearly data
	use "`input_data'/cci_yearly/cci_2021.dta"
	
	/*
	 CESVersion |      Freq.     Percent        Cum.
------------+-----------------------------------
          2 |     12,618       85.05       85.05
          3 |      2,218       14.95      100.00
------------+-----------------------------------
      Total |     14,836      100.00

*/

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "`input_data'/instrument_yearly/ces`v'_2021.dta"
			drop if _merge==1
			drop _merge 
			save "`input_data'/cci_temp_`v'_2021.dta", replace
		restore
	}
	
	use "`input_data'/cci_temp_2_2021.dta", clear
	append using "`input_data'/cci_temp_3_2021.dta"
	save "`output_data'/2021.dta", replace 
	
	count if TotalProgramGGRFFunding==.
	// 1,294
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	
	// version 2and3 only in this dataset
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	
	// FS 
	//reg TOT_funding instrument, cluster(County)
	save "`output_data'/2021.dta", replace 

/*==============================================================================
									2022
==============================================================================*/
	
	// load yearly data
	use "`input_data'/cci_yearly/cci_2022.dta"
	
	/*
	 CESVersion |      Freq.     Percent        Cum.
------------+-----------------------------------
          2 |     12,618       85.05       85.05
          3 |      2,218       14.95      100.00
------------+-----------------------------------
      Total |     14,836      100.00

*/

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "`input_data'/instrument_yearly/ces`v'_2022.dta"
			drop if _merge==1
			drop _merge 
			save "`input_data'/cci_temp_`v'_2022.dta", replace
		restore
	}
	
	use "`input_data'/cci_temp_2_2022.dta", clear
	append using "`input_data'/cci_temp_3_2022.dta"
	save "`output_data'/2022.dta", replace 
	
	count if TotalProgramGGRFFunding==.
	// 1,294
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	
	// version 2and3 only in this dataset
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	
	// FS 
	//reg TOT_funding instrument, cluster(County)
	save "`output_data'/2022.dta", replace 

/*==============================================================================
									2023
==============================================================================*/
	
	// load yearly data
	use "`input_data'/cci_yearly/cci_2023.dta"
	
	/*
	 CESVersion |      Freq.     Percent        Cum.
------------+-----------------------------------
          2 |     12,618       85.05       85.05
          3 |      2,218       14.95      100.00
------------+-----------------------------------
      Total |     14,836      100.00

*/

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "`input_data'/instrument_yearly/ces`v'_2023.dta"
			drop if _merge==1
			drop _merge 
			save "`input_data'/cci_temp_`v'_2023.dta", replace
		restore
	}
	
	use "`input_data'/cci_temp_2_2023.dta", clear
	append using "`input_data'/cci_temp_3_2023.dta"
	save "`output_data'/2023.dta", replace 
	
	count if TotalProgramGGRFFunding==.
	// 1,294
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	
	// version 2and3 only in this dataset
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	
	// FS 
	//reg TOT_funding instrument, cluster(County)
	save "`output_data'/2023.dta", replace 

