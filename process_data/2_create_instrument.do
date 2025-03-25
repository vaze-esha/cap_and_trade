/*==============================================================================
						2_construct_instruments.do
================================================================================

	PURPOSE:
	
		1.Import cci_ces datasets and merge with ces scores by version (2,3,4)
		
	INPUTS:
		1. cci_CESVersion2.dta
		2. cci_CESVersion3.dta
		3. cci_CESVersion4.dta
	
	OUTPUTS:
	
		
		
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
	
	* input dir
	local input_data "`workingdir'/0_raw_input"
	di "`input_data'"

	* output dir
	local output_data "`workingdir'/1_input"
	di "`output_data'"

/*============================================================================*/	

/*==============================================================================
							     VERSION 2
==============================================================================*/	
	
	use "`output_data'/cci_ces_versions/cci_CESVersion2.dta"
	
	// drop fields with no census tract data 
	drop if CensusTract==""
	drop if CensusTract=="NA"
	destring CensusTract, replace 
	
	
	// merge with scores 
	merge m:1 CensusTract using "`output_data'/ces_results/ces2results.dta"
	
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
	
	//+2
	gen Treat_Tract = (CES20Score > 32.66230828250767 & CES20Score <= 38.52230828) // updated bandwidth

	gen Control_Tract = inrange(CES20Score, 26.80230828, 32.66230828250767) // updated bandwidth

	*/
	
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

	// not that there are some zeros here (true zeroes: tracts in bandwidht, none funded)
	
	// resulting dataset:
	
	/*
	
	Every project that was funded under version 2 scores 
	restrict to tracts within the RD bandwidht of version 2 75th percentile 
	calculate the intrsument for each county-year level 
	
	resulting dataset has year-county-instrument level observations for the years
	
	  Reporting |
	 Cycle Name |      Freq.     Percent        Cum.
	------------+-----------------------------------
		   2015 |         31       17.22       17.22
		   2016 |         32       17.78       35.00
		   2017 |         32       17.78       52.78
		   2018 |         29       16.11       68.89
		   2019 |         22       12.22       81.11
		   2020 |         13        7.22       88.33
		   2021 |          9        5.00       93.33
		   2022 |          8        4.44       97.78
		   2023 |          4        2.22      100.00
	------------+-----------------------------------
		  Total |        180      100.00

	
	counties: 
	
		California |
			 County |      Freq.     Percent        Cum.
	----------------+-----------------------------------
		   Alameda  |          7        3.55        3.55
			 Butte  |          2        1.02        4.57
			Colusa  |          5        2.54        7.11
	   Contra Costa |          7        3.55       10.66
			Fresno  |          7        3.55       14.21
			 Glenn  |          1        0.51       14.72
		  Imperial  |          3        1.52       16.24
			  Kern  |          7        3.55       19.80
			 Kings  |          6        3.05       22.84
		Los Angeles |         10        5.08       27.92
			Madera  |          3        1.52       29.44
			Merced  |          5        2.54       31.98
		  Monterey  |          7        3.55       35.53
			Nevada  |          3        1.52       37.06
			Orange  |          6        3.05       40.10
			Placer  |          2        1.02       41.12
		 Riverside  |          6        3.05       44.16
		Sacramento  |          7        3.55       47.72
		 San Benito |          2        1.02       48.73
	 San Bernardino |          7        3.55       52.28
		  San Diego |          6        3.05       55.33
	  San Francisco |          6        3.05       58.38
		San Joaquin |          9        4.57       62.94
		  San Mateo |          7        3.55       66.50
	  Santa Barbara |          4        2.03       68.53
		Santa Clara |          7        3.55       72.08
		 Santa Cruz |          5        2.54       74.62
			Shasta  |          2        1.02       75.63
			Solano  |          7        3.55       79.19
			Sonoma  |          5        2.54       81.73
		Stanislaus  |          6        3.05       84.77
			Sutter  |          6        3.05       87.82
			Tehama  |          5        2.54       90.36
			Tulare  |          8        4.06       94.42
		   Ventura  |          6        3.05       97.46
			  Yolo  |          3        1.52       98.98
			  Yuba  |          2        1.02      100.00
	----------------+-----------------------------------
			  Total |        197      100.00

		// 37/58 counties -- the missing counties 
		// never have tracts that fall in out RD bandwidht 
		// and are not in the sample 
		
		*/
	
	
	sort Year County
	drop if Year==.
	
	save "`output_data'/instrument/ces2_instrument.dta", replace 
	

/*==============================================================================
							     VERSION 3
==============================================================================*/	

	use "`output_data'/cci_ces_versions/cci_CESVersion3.dta"
	
	
	// drop fields with no census tract data 
	drop if CensusTract==""
	drop if CensusTract=="NA"
	destring CensusTract, replace 
	
	
	// merge with scores 
	merge m:1 CensusTract using "`output_data'/ces_results/ces3results.dta"
	
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
	
	// resulting dataset:
	
	/*
	
	Every project that was funded under version 3 scores 
	restrict to tracts within the RD bandwidht of version 3 75th percentile 
	calculate the intrsument for each county-year level 
	
	resulting dataset has year-county-instrument level observations for the years
	
  Reporting |
 Cycle Name |      Freq.     Percent        Cum.
------------+-----------------------------------
       2016 |          1        0.67        0.67
       2017 |         14        9.33       10.00
       2018 |         24       16.00       26.00
       2019 |         24       16.00       42.00
       2020 |         22       14.67       56.67
       2021 |         22       14.67       71.33
       2022 |         23       15.33       86.67
       2023 |         20       13.33      100.00
------------+-----------------------------------
      Total |        150      100.00

	
	counties: 
	
	 California |
         County |      Freq.     Percent        Cum.
----------------+-----------------------------------
       Alameda  |          7        4.55        4.55
   Contra Costa |          7        4.55        9.09
        Fresno  |          8        5.19       14.29
      Imperial  |          5        3.25       17.53
          Kern  |          6        3.90       21.43
         Kings  |          6        3.90       25.32
    Los Angeles |          9        5.84       31.17
        Madera  |          5        3.25       34.42
        Merced  |          7        4.55       38.96
      Monterey  |          5        3.25       42.21
        Orange  |          7        4.55       46.75
     Riverside  |          8        5.19       51.95
    Sacramento  |          7        4.55       56.49
 San Bernardino |          7        4.55       61.04
      San Diego |          6        3.90       64.94
  San Francisco |          3        1.95       66.88
    San Joaquin |          7        4.55       71.43
      San Mateo |          6        3.90       75.32
    Santa Clara |          6        3.90       79.22
     Santa Cruz |          2        1.30       80.52
        Solano  |          5        3.25       83.77
        Sonoma  |          2        1.30       85.06
    Stanislaus  |          7        4.55       89.61
        Sutter  |          3        1.95       91.56
        Tulare  |          7        4.55       96.10
       Ventura  |          5        3.25       99.35
          Yuba  |          1        0.65      100.00
----------------+-----------------------------------
          Total |        154      100.00


		// 27/58 counties -- the missing counties 
		// never have tracts that fall in out RD bandwidht 
		// and are not in the sample 
		
		*/
	
	
	sort Year County
	drop if Year==.
	
	save "`output_data'/instrument/ces3_instrument.dta", replace 

/*==============================================================================
							   Exporting yearly datasets 
==============================================================================*/	

	local versions "2 3"
	
	foreach v of local versions {
    use "`output_data'/instrument/ces`v'_instrument.dta", clear

    // Assuming there is a year variable, adjust if needed
    levelsof Year, local(Years)
    
	replace County = trim(County) if !missing(County)
	
    foreach y of local Years {
        preserve
        keep if Year == `y'
        save "`output_data'/instrument_yearly/ces`v'_`y'.dta", replace
        restore
    }
}
