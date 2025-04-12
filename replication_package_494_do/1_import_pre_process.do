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
	
	
	local workingdir "/Users/eshavaze/Dropbox/replication_package_494"
	
	* raw input dir
	local raw_input_data "`workingdir'/0_raw_input"
	di "`raw_input_data'"

	* intermediate processed data 
	local output_data "`workingdir'/1_intermediate"
	di "`intermediate_data'"
	
/*==============================================================================
						IMPORT AND CLEAN CCI DATA
==============================================================================*/	

	
	import excel "`raw_input_data'/cci_2024ar_detaileddata.xlsx", sheet("Project List") firstrow
	
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
    save "`intermediate_data'/cci_ces_versions/cci_CESVersion`v'", replace
    restore
}

	// split into yearly datasets and save it 
	
	foreach year in 2015 2016 2017 2018 2019 2020 2021 2022 2023 {
    preserve
    keep if Year == `year'
    save "`intermediate_data'/cci_yearly/cci_`year'", replace
    restore
}

********************************************************************************

/*==============================================================================
							IMPORT AND CLEAN CES DATA 
==============================================================================*/	
	// import ces2
	import excel "`raw_input_data'/ces2results.xlsx", sheet("CES2.0FinalResults") firstrow clear
	keep CensusTract TotalPopulation CaliforniaCounty CES20Score CES20PercentileRange
	save "`intermediate_data'/ces2results.dta", replace

	// import ces3
	import excel "`raw_input_data'/ces3results.xlsx", sheet("CES3.0FinalResults") firstrow clear
	keep CensusTract TotalPopulation CaliforniaCounty CES30Score CES30Percentile CES30PercentileRange
	save "`intermediate_data'/ces3results.dta", replace

	// import ces4
	import excel "`raw_input_data'/ces4results.xlsx", sheet("CES4.0FinalResults") firstrow clear
	keep CensusTract TotalPopulation CaliforniaCounty CES40Score CES40Percentile CES40PercentileRange
	save "`intermediate_data'/ces4results.dta", replace

	
	clear
/*==============================================================================
						CREATE INSTRUMENT BY CES VERSION
==============================================================================*/

/*==============================================================================
							     VERSION 2
==============================================================================*/		

	use "`intermediate_data'/cci_ces_versions/cci_CESVersion2.dta"
	
	// drop fields with no census tract data 
	drop if CensusTract==""
	drop if CensusTract=="NA"
	destring CensusTract, replace 
	
	
	// merge with scores 
	merge m:1 CensusTract using "`intermediate_data'/ces_results/ces2results.dta"
	
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
	
	save "`intermediate_data'/instrument/ces2_instrument.dta", replace 
	
	
/*==============================================================================
							     VERSION 3
==============================================================================*/	

	use "`intermediate_data'/cci_ces_versions/cci_CESVersion3.dta"
	
	
	// drop fields with no census tract data 
	drop if CensusTract==""
	drop if CensusTract=="NA"
	destring CensusTract, replace 
	
	
	// merge with scores 
	merge m:1 CensusTract using "`intermediate_data'/ces_results/ces3results.dta"
	
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
	
	save "`intermediate_data'/instrument/ces3_instrument.dta", replace 
	
/*==============================================================================
					EXPORT AS YEARLY DATASETS WITH INSTRUMENT 
==============================================================================*/	

	local versions "2 3"
	
	foreach v of local versions {
    use "`intermediate_data'/instrument/ces`v'_instrument.dta", clear

    // Assuming there is a year variable, adjust if needed
    levelsof Year, local(Years)
    
	replace County = trim(County) if !missing(County)
	
    foreach y of local Years {
        preserve
        keep if Year == `y'
        save "`intermediate_data'/instrument_yearly/ces`v'_`y'.dta", replace
        restore
    }
}


