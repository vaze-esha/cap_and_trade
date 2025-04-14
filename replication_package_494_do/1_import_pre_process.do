/*==============================================================================
						CLEAN AND IMPORT DATA 
							+ PRE-PROCESSING 
==============================================================================*/	


	    /*
			This do-file:
			
			1. Imports CCI data from California climate Investments 
			   and cleans it 
			2. Imports CES data from CalEPA and cleans it 
			3. Exports cleaned data as .dtas 
			
			4. Calls ces and cci datasets to create the instrument 
			
		*/

//============================================================================*/

	* Clear all and set large data arguments.
	macro drop _all 
	clear all
	// version 18.0, user
	set more off 
	set seed 13011
	pause on
		* SET TO PATH ON YOUR MACHINE WHERE REPLICATION PACKAGE DATA IS SAVED 

	global workingdir "/Users/eshavaze/Dropbox/replication_package_494"
	di "$workingdir"
	
	* SET TO PATH ON YOUR MACHINE WHERE REPLICATION PACKAGE DOFILES ARE SAVED
	
	global dodir "/Users/eshavaze/cap_and_trade/replication_package_494_do"
	di "$dodir"
	
	
********************************************************************************
	
	* raw input dir
	global raw_input_data "$workingdir/0_raw_input"
	di "$raw_input_data"

	* intermediate processed data 
	global intermediate_data "$workingdir/1_intermediate"
	di "$intermediate_data"
	
	
	* final datasets
	global final_data "$workingdir/2_final"
	di "$final_data"

	* tables 
	global tables "$workingdir/3_tables"
	di "$tables"

//============================================================================*/
	

/*==============================================================================
						IMPORT AND CLEAN CCI DATA
==============================================================================*/	

	
	import excel "$raw_input_data/cci_2024ar_detaileddata.xlsx", sheet("Project List") firstrow
	
	// only keep relevant variables
	keep ProjectIDNumber ReportingCycleName AgencyName ProgramName ProgramDescription SubProgramName ProjectDescription CensusTract SenateDistrict AssemblyDistrict County TotalProjectCost TotalProgramGGRFFunding ProjectLifeYears DateOperational ProjectCompletionDate FundingRecipient BufferAmount BufferCount CESVersion CESVersionCalc ApplicantsAssisted IntermediaryAdminExpensesCalc 
	
	// clean the year variable 
	rename ReportingCycleName Year
	drop if Year==""
	
	// strip semi/mid year update strings
	foreach keyword in "Semi-Annual" "Mid-Year Update" {
			
		replace Year = subinstr(Year, "`keyword'", "", .)
		replace Year = strtrim(Year)
	
	}
	
	// destring year
	destring Year, replace
	
	 count if CensusTract==""
	// 22,059
	
	/*
	
		These projects are at the county level, not the census tract level 
	
	*/
	
	// cleaning CES Version data 
	// each project is associated with a CES version under which it was funded 
	
	tab CESVersion
	replace CESVersion="2" if CESVersion=="2.0"
	replace CESVersion="3" if CESVersion=="3.0" // recording errors
	
	destring CESVersion, replace 
	
********************************************************************************

	// aplit the dataset by CES versions and save it 
	
	foreach v in 2 3 4 {
    preserve
    keep if CESVersion == `v'
    save "$intermediate_data/cci_CESVersion`v'", replace
    restore
}

	// split into yearly datasets and save it 
	
	foreach year in 2015 2016 2017 2018 2019 2020 2021 2022 2023 {
    preserve
    keep if Year == `year'
    save "$intermediate_data/cci_`year'", replace
    restore
}

********************************************************************************

/*==============================================================================
							IMPORT AND CLEAN CES DATA 
==============================================================================*/	
	// import ces2
	import excel "$raw_input_data/ces2results.xlsx", sheet("CES2.0FinalResults") firstrow clear
	keep CensusTract TotalPopulation CaliforniaCounty CES20Score CES20PercentileRange
	save "$intermediate_data/ces2results.dta", replace

	// import ces3
	import excel "$raw_input_data/ces3results.xlsx", sheet("CES3.0FinalResults") firstrow clear
	keep CensusTract TotalPopulation CaliforniaCounty CES30Score CES30Percentile CES30PercentileRange
	save "$intermediate_data/ces3results.dta", replace

	// import ces4
	import excel "$raw_input_data/ces4results.xlsx", sheet("CES4.0FinalResults") firstrow clear
	keep CensusTract TotalPopulation CaliforniaCounty CES40Score CES40Percentile CES40PercentileRange
	save "$intermediate_data/ces4results.dta", replace

	
	clear
/*==============================================================================
						CREATE INSTRUMENT BY CES VERSION
==============================================================================*/

/*==============================================================================
							     VERSION 2
==============================================================================*/		

	use "$intermediate_data/cci_CESVersion2.dta"
	
	// drop fields with no census tract data 
	drop if CensusTract==""
	drop if CensusTract=="NA"
	destring CensusTract, replace 
	
	
	// merge with scores 
	merge m:1 CensusTract using "$intermediate_data/ces2results.dta"
	
	/*
	    Result                      Number of obs
    -----------------------------------------
    Not matched                           216
        from master                         5  (_merge==1) // unscored tract? possibly an error 
        from using                        211  (_merge==2) // unfunded tracts -- they dont get funded in any of the years in this dataset

    Matched                            53,411  (_merge==3)
    -----------------------------------------
	
	*/
	
	
	tab CensusTract if _merge==1
	
	/*
	

		 Census |
		  Tract |      Freq.     Percent        Cum.
	------------+-----------------------------------
	 6037137000 |          5      100.00      100.00
	------------+-----------------------------------
		  Total |          5      100.00

	  */
	  
	 // looks like an error 
	 drop if _merge==1
	  
	  
	 // use the county measure from ces scores now 
	 drop County 
	 rename CaliforniaCounty County
	 
	// keep unfunded tracts in dataset, these are true zeroes 
	count if TotalProgramGGRFFunding==.
	// 1,138
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	  
	****************************************************************************
	// CALCULATING THE INSTRUMENT 
	// RD c=3.86 (KI chosen by previous paper) 
	
	
	/*
	CES2.0: 75th percentile score is: 32.66230828250767
	
	we want this dataset to have one observation for each:
		YEAR-COUNTY
	so Alameda will have 4 observations in the output dataset, one 
	instrument score for each year 
	
	*/
	 
	duplicates tag CensusTract County Year, gen(dup) 
	/*
		Note that the dataset will have the same census tract many times 
		because a tract gets funded many times every year (and also over the years)
		
		Now, we only care about a tract's score every year:
			so we deduplicate such that the observations are unique at 
			COUNTY-CENSUS TRACT-YEAR level 
			Example: 
				Alameda-60789000-2016 gets once score 
				Alameda-60789000-2017 gets once score etc. 
	
	*/
	
	drop if dup>0
	drop dup
	sort CensusTract Year
	tostring CensusTract, replace 

	drop if CES20Score==""
	drop if CES20Score=="NA"
	// (78 observations deleted)
	destring CES20Score, replace 
	
	
	
								//BANDWIDHT = 3.86
	
	gen Treat_Tract = (CES20Score > 32.66230828250767 & CES20Score <= 36.522308282507666) // for ver 2 

	gen Control_Tract = inrange(CES20Score, 28.802308282507667, 32.66230828250767)

	
	/*
	
	tab Year if Treat_Tract==1

	  Reporting |
	 Cycle Name |      Freq.     Percent        Cum.
	------------+-----------------------------------
		   2015 |        142       14.00       14.00
		   2016 |        264       26.04       40.04
		   2017 |        263       25.94       65.98
		   2018 |        187       18.44       84.42
		   2019 |         86        8.48       92.90
		   2020 |         41        4.04       96.94
		   2021 |         17        1.68       98.62
		   2022 |          9        0.89       99.51
		   2023 |          5        0.49      100.00
	------------+-----------------------------------
		  Total |      1,014      100.00

*/

	egen TOT_Treatment = total(Treat_Tract), by(County Year)
	egen TOT_Control = total(Control_Tract), by(County Year)
	gen instrument = TOT_Treatment / (TOT_Treatment + TOT_Control)
	
	// handling zeroes
	gen denom = TOT_Treatment + TOT_Control
	replace instrument = . if denom == 0  // Avoid division by zero
	drop denom

	collapse (mean) instrument, by(Year County) 
	drop if instrument==. // tracts never in bandwidth

	sort Year County
	drop if Year==.
	
	save "$intermediate_data/ces2_instrument.dta", replace 
	
	
/*==============================================================================
							     VERSION 3
==============================================================================*/	

	use "$intermediate_data/cci_CESVersion3.dta"
	
	
	// drop fields with no census tract data 
	drop if CensusTract==""
	drop if CensusTract=="NA"
	destring CensusTract, replace 
	
	
	// merge with scores 
	merge m:1 CensusTract using "$intermediate_data/ces3results.dta"
	
	/*
	
	 Result                      Number of obs
    -----------------------------------------
    Not matched                           137
        from master                         9  (_merge==1)
        from using                        128  (_merge==2)

    Matched                            65,933  (_merge==3)
    -----------------------------------------
*/
	
	tab CensusTract if _merge==1
	/*
	

		 Census |
		  Tract |      Freq.     Percent        Cum.
	------------+-----------------------------------
	 6037137000 |          5      100.00      100.00
	------------+-----------------------------------
		  Total |          5      100.00

	  */
	  
	 // looks like an error 
	 drop if _merge==1
	 
	 // use the county measure from ces scores now 
	 drop County 
	 rename CaliforniaCounty County
	 
	// keep unfunded tracts in dataset, these are true zeroes 
	count if TotalProgramGGRFFunding==.
	// 128
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	
	****************************************************************************
	// CALCULATING THE INSTRUMENT 
	// RD c=3.86 (KI chosen by previous paper) 
	
	drop if CES30Score==""
	// 9 
	drop if CES30Score=="NA"
	//398
	destring CES30Score, replace 
	centile CES30Score, centile(75)
	
	/*
	CES3.0: 75th percentil score is: 38.68746 
	
	we want this dataset to have one observation for each:
		YEAR-COUNTY
	so Alameda will have 4 observations in the output dataset, one 
	instrument score for each year 
	
	*/
	 
	duplicates tag CensusTract County Year, gen(dup) 
	/*
		Note that the dataset will have the same census tract many times 
		because a tract gets funded many times every year (and also over the years)
		
		Now, we only care about a tract's score every year:
			so we deduplicate such that the observations are unique at 
			COUNTY-CENSUS TRACT-YEAR level 
			Example: 
				Alameda-60789000-2016 gets once score 
				Alameda-60789000-2017 gets once score etc. 
	
	*/
	
	drop if dup>0
	drop dup
	sort CensusTract Year
	tostring CensusTract, replace 
	
	
	
									//BANDWIDTH = 3.86
						
	gen Treat_Tract = (CES30Score >= 38.68746  & CES30Score <= 42.54746) // for ver 3

	gen Control_Tract = (CES30Score >=34.82746 & CES30Score < 38.68746)
	
	/*
	
	//+2
	gen Treat_Tract = (CES30Score >= 38.68746  & CES30Score <= 44.54746) // for ver 3

	gen Control_Tract = (CES30Score >=32.82746 & CES30Score < 38.68746)
	*/
	
	/*
	
	tab Year if Treat_Tract==1

	  Reporting |
	 Cycle Name |      Freq.     Percent        Cum.
	------------+-----------------------------------
		   2016 |          1        0.09        0.09
		   2017 |         73        6.62        6.72
		   2018 |        206       18.69       25.41
		   2019 |        203       18.42       43.83
		   2020 |        136       12.34       56.17
		   2021 |        164       14.88       71.05
		   2022 |        181       16.42       87.48
		   2023 |        138       12.52      100.00
	------------+-----------------------------------
		  Total |      1,102      100.00

*/

	egen TOT_Treatment = total(Treat_Tract), by(County Year)
	egen TOT_Control = total(Control_Tract), by(County Year)
	gen instrument = TOT_Treatment / (TOT_Treatment + TOT_Control)
	
	// handling zeroes
	gen denom = TOT_Treatment + TOT_Control
	replace instrument = . if denom == 0  // Avoid division by zero
	drop denom
	
	collapse (mean) instrument, by(Year County)
	drop if instrument==. // tracts never in bandwidth

	// 248 deleted 
	// not that there are some zeros here (true zeroes: tracts in bandwidht, none funded)
	
	
	sort Year County
	drop if Year==.
	
	save "$intermediate_data/ces3_instrument.dta", replace 
	
/*==============================================================================
					EXPORT AS YEARLY DATASETS WITH INSTRUMENT 
==============================================================================*/	

	local versions "2 3"
	
	foreach v of local versions {
    use "$intermediate_data/ces`v'_instrument.dta", clear

    // Assuming there is a year variable, adjust if needed
    levelsof Year, local(Years)
    
	replace County = trim(County) if !missing(County)
	
    foreach y of local Years {
        preserve
        keep if Year == `y'
        save "$intermediate_data/ces`v'_`y'.dta", replace
        restore
    }
}


	clear 
	
	
/*==============================================================================
					MERGE YEARLY CCI + YEARLY INSTRUMENT DATA 
==============================================================================*/	

/*==============================================================================
									2015
==============================================================================*/	

	// load yearly data
	use "$intermediate_data/cci_2015.dta"
	/*
	 CESVersion |      Freq.     Percent        Cum.
	------------+-----------------------------------
			  2 |     16,068      100.00      100.00
	------------+-----------------------------------
		  Total |     16,068      100.00
	*/
	
	merge m:1 County using "$intermediate_data/ces2_2015.dta" 
	drop if _merge==1 // counties with no census tracts in the bandwidht 
	
	
	// creating the funding variable 
	
	// keep unfunded tracts in dataset, these are true zeroes 
	count if TotalProgramGGRFFunding==.
	// 1,294
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	
	// version 2 only in this dataset
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)

	drop _merge
	
	save "$intermediate_data/2015.dta", replace 
	
/*==============================================================================
									2016
==============================================================================*/
		
	// load yearly data
	use "$intermediate_data/cci_2016.dta"
	
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
			merge m:1 County using "$intermediate_data/ces`v'_2016.dta"
			drop if _merge==1
			drop _merge 
			save "$intermediate_data/cci_temp_`v'_2016.dta", replace
		restore
	}
	
	use "$intermediate_data/cci_temp_2_2016.dta", clear
	append using "$intermediate_data/cci_temp_3_2016.dta"
	save "$intermediate_data/2016.dta", replace 
	
	count if TotalProgramGGRFFunding==.
	// 1,294
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	
	// version 2and3 only in this dataset
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	
	save "$intermediate_data/2016.dta", replace 
	
/*==============================================================================
                                    2017
==============================================================================*/

	// load yearly data
	use "$intermediate_data/cci_2017.dta"

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "$intermediate_data/ces`v'_2017.dta"
			drop if _merge==1
			drop _merge 
			save "$intermediate_data/cci_temp_`v'_2017.dta", replace
		restore
	}

	use "$intermediate_data/cci_temp_2_2017.dta", clear
	append using "$intermediate_data/cci_temp_3_2017.dta"
	save "$intermediate_data/2017.dta", replace 

	count if TotalProgramGGRFFunding==.
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	save "$intermediate_data/2017.dta", replace 

/*==============================================================================
                                    2018
==============================================================================*/

	use "$intermediate_data/cci_2018.dta"

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "$intermediate_data/ces`v'_2018.dta"
			drop if _merge==1
			drop _merge 
			save "$intermediate_data/cci_temp_`v'_2018.dta", replace
		restore
	}

	use "$intermediate_data/cci_temp_2_2018.dta", clear
	append using "$intermediate_data/cci_temp_3_2018.dta"
	save "$intermediate_data/2018.dta", replace 

	count if TotalProgramGGRFFunding==.
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	save "$intermediate_data/2018.dta", replace 

/*==============================================================================
                                    2019
==============================================================================*/

	use "$intermediate_data/cci_2019.dta"

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "$intermediate_data/ces`v'_2019.dta"
			drop if _merge==1
			drop _merge 
			save "$intermediate_data/cci_temp_`v'_2019.dta", replace
		restore
	}

	use "$intermediate_data/cci_temp_2_2019.dta", clear
	append using "$intermediate_data/cci_temp_3_2019.dta"
	save "$intermediate_data/2019.dta", replace 

	count if TotalProgramGGRFFunding==.
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	save "$intermediate_data/2019.dta", replace 

/*==============================================================================
                                    2020
==============================================================================*/

	use "$intermediate_data/cci_2020.dta"

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "$intermediate_data/ces`v'_2020.dta"
			drop if _merge==1
			drop _merge 
			save "$intermediate_data/cci_temp_`v'_2020.dta", replace
		restore
	}

	use "$intermediate_data/cci_temp_2_2020.dta", clear
	append using "$intermediate_data/cci_temp_3_2020.dta"
	save "$intermediate_data/2020.dta", replace 

	count if TotalProgramGGRFFunding==.
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	save "$intermediate_data/2020.dta", replace 

/*==============================================================================
                                    2021
==============================================================================*/

	use "$intermediate_data/cci_2021.dta"

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "$intermediate_data/ces`v'_2021.dta"
			drop if _merge==1
			drop _merge 
			save "$intermediate_data/cci_temp_`v'_2021.dta", replace
		restore
	}

	use "$intermediate_data/cci_temp_2_2021.dta", clear
	append using "$intermediate_data/cci_temp_3_2021.dta"
	save "$intermediate_data/2021.dta", replace 

	count if TotalProgramGGRFFunding==.
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	save "$intermediate_data/2021.dta", replace 

/*==============================================================================
                                    2022
==============================================================================*/

	use "$intermediate_data/cci_2022.dta"

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "$intermediate_data/ces`v'_2022.dta"
			drop if _merge==1
			drop _merge 
			save "$intermediate_data/cci_temp_`v'_2022.dta", replace
		restore
	}

	use "$intermediate_data/cci_temp_2_2022.dta", clear
	append using "$intermediate_data/cci_temp_3_2022.dta"
	save "$intermediate_data/2022.dta", replace 

	count if TotalProgramGGRFFunding==.
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	save "$intermediate_data/2022.dta", replace 

/*==============================================================================
                                    2023
==============================================================================*/

	use "$intermediate_data/cci_2023.dta"

	foreach v in 2 3 {
		preserve
			keep if CESVersion == `v'
			merge m:1 County using "$intermediate_data/ces`v'_2023.dta"
			drop if _merge==1
			drop _merge 
			save "$intermediate_data/cci_temp_`v'_2023.dta", replace
		restore
	}

	use "$intermediate_data/cci_temp_2_2023.dta", clear
	append using "$intermediate_data/cci_temp_3_2023.dta"
	save "$intermediate_data/2023.dta", replace 

	count if TotalProgramGGRFFunding==.
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	egen TOT_funding= sum(TotalProgramGGRFFunding), by(County)
	save "$intermediate_data/2023.dta", replace 
