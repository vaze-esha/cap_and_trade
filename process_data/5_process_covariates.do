/*==============================================================================
							5_process_covariates.do
================================================================================

	PURPOSE:
	
		1. Import covariates and clean them (median hh income by county and transit modes)
		
	INPUTS:
		1. ACSDP1Y`year'.DP03-Data.csv
	
	OUTPUTS:
		1. hh_income_transit_`year'.dta

		
		
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
	local output_data "`workingdir'/1_input/covariates"
	di "`output_data'"
/*============================================================================*/	


/*==============================================================================
						HH INCOME AND TRANSIT DETAILS 
==============================================================================*/	
	
	/*
	
	
	/*
	
	1. Transportation (Commute by Car & Transit)
	2. Household Income (Median Income)

	*/
	
	foreach year of numlist 2014 2015 2016 2017 2018 2019 2021 2022 2023{
		
		import delimited using "`input_data'/acs_misc_data/ACSDP1Y`year'.DP03-Data.csv", varnames(1) encoding(utf8) clear
		
		// remove unused vars 
		keep geo_id name dp03_0021e dp03_0022e dp03_0024e dp03_0062e dp03_0019e dp03_0020e dp03_0023e
		
		// rename vars 
		rename name County 
		rename dp03_0023e OTHER_TRANSPORT // Estimate!!COMMUTING TO WORK!!Workers 16 years and over!!Other means
		rename dp03_0020e CARPOOLED //Estimate!!COMMUTING TO WORK!!Workers 16 years and over!!Car, truck, or van -- carpooled
		rename dp03_0019e DRIVE_ALONE // Estimate!!COMMUTING TO WORK!!Workers 16 years and over!!Car, truck, or van -- drove alone
		rename dp03_0021 TRANSIT_TO_WORK //!!Workers 16 years and over!!Public transportation (excluding taxicab)
		rename dp03_0022e WALK_TO_WORK  //Estimate!!COMMUTING TO WORK!!Workers 16 years and over!!Walked
		rename dp03_0024e WFH //Estimate!!COMMUTING TO WORK!!Workers 16 years and over!!Worked at home
		rename dp03_0062e MEDIAN_HH_INCOME // inflation adjusted 
		
		// DROP FIRST TWO ROWS 
		drop in 1/2
		
		// CLEAN COUNTY NAME 
		// REMOVE " County, California" FROM EACH NAME
		replace County = subinstr(County, " County, California", "", .)
		
		destring DRIVE_ALONE CARPOOLED TRANSIT_TO_WORK WALK_TO_WORK OTHER_TRANSPORT WFH MEDIAN_HH_INCOME, replace
		save "`output_data'/hh_income_transit_`year'.dta", replace
	}
	
	clear
	
	*/
	
/*==============================================================================
								POPULATION DATA
==============================================================================*/	

	/*
	import delimited using "`input_data'/population_estimates.csv", varnames(1) encoding(utf8) clear
	
	// unsuable rows 
	drop in 1/13
	drop v6
	drop date_code
	
	// RENAME VARS 
	rename name County 
	rename date_desc date
	rename pop Population 
	
	// CLEAN COUNTY NAME 
	// REMOVE " County, California" FROM EACH NAME
	replace County = subinstr(County, " County, California", "", .)
	
	// DUP ESTIMATES WE DONT USE
	drop if regexm(date, "base")
	drop if regexm(date, "Census")
	
	// clean date var
	gen Year = substr(date, strpos(date, "/") + 1, 6)
	replace Year = substr(Year, strpos(Year, "/") + 1, 4)
	drop date 
	destring Year Population, replace
	
	/*
	
					SAVING YEAR WISE POPULATION DATASETS 
	
	*/
	
	
	// GET THE LIST OF UNIQUE YEARS
	levelsof Year, local(years)

	// SAVING YEARLY POPULATION DATASETS
	preserve // SAVE THE ORIGINAL DATASET

	foreach year of local years {
		// KEEP OBSERVATIONS FOR THE CURRENT YEAR
		keep if Year == `year'

		// SAVE THE SUBSET AS A SEPARATE DATASET
		save "`output_data'/population_data_`year'.dta", replace

		// RESTORE THE ORIGINAL DATASET FOR THE NEXT ITERATION
		restore, preserve
	}

	restore // RESTORE THE ORIGINAL DATASET 
	
	*/

/*==============================================================================
								EDUCATION DATA
==============================================================================*/

	foreach year of numlist 2014/2023{
		
		import delimited using "`input_data'/acs_education_data/ACSST5Y`year'.S1501-Data.csv", varnames(1) encoding(utf8) clear
		
		// KEEP RELEVANT VARIABLES
		keep geo_id name s1501_c01_002e s1501_c01_004e s1501_c01_005e s1501_c01_007e s1501_c01_008e s1501_c01_009e s1501_c01_010e s1501_c01_011e s1501_c01_012e s1501_c01_013e s1501_c01_016e s1501_c01_019e s1501_c01_022e s1501_c01_025e
		
		destring s1501_c01_002e s1501_c01_004e s1501_c01_005e s1501_c01_007e s1501_c01_008e s1501_c01_009e s1501_c01_010e s1501_c01_011e s1501_c01_012e s1501_c01_013e s1501_c01_016e s1501_c01_019e s1501_c01_022e s1501_c01_025e, replace 
		
		rename name County 
		rename s1501_c01_002e LESS_THAN_HS // Total!!Estimate!!Less than high school graduate
		rename s1501_c01_004e SOME_COLLEGE_OR_ASSOCIATES // Total!!Estimate!!Some college or associate's degree
		rename s1501_c01_005e BACHELORS_OR_HIGHER // Total!!Estimate!!Bachelor's degree or higher
		rename s1501_c01_007e LESS_THAN_9TH_GRADE // Total!!Estimate!!Less than 9th grade
		rename s1501_c01_008e NINTH_TO_12TH_NO_DIPLOMA // Total!!Estimate!!9th to 12th grade, no diploma
		rename s1501_c01_009e HS_GRADUATE // Total!!Estimate!!High school graduate (includes equivalency)
		rename s1501_c01_010e SOME_COLLEGE_NO_DEGREE // Total!!Estimate!!Some college, no degree
		rename s1501_c01_011e ASSOCIATES_DEGREE // Total!!Estimate!!Associate's degree
		rename s1501_c01_012e BACHELORS_DEGREE // Total!!Estimate!!Bachelor's degree
		rename s1501_c01_013e GRADUATE_OR_PROFESSIONAL_DEGREE // Total!!Estimate!!Graduate or professional degree
		rename s1501_c01_016e POP_25_TO_34 // Total!!Estimate!!Population 25 to 34 years
		rename s1501_c01_019e POP_35_TO_44 // Total!!Estimate!!Population 35 to 44 years
		rename s1501_c01_022e POP_45_TO_64 // Total!!Estimate!!Population 45 to 64 years
		rename s1501_c01_025e POP_65_PLUS // Total!!Estimate!!Population 65 years and over
			
		// drop unused rows 
		drop in 1/2
			
		// CLEAN COUNTY NAME 
		// REMOVE " County, California" FROM EACH NAME
		replace County = subinstr(County, " County, California", "", .)
	
		// save 
		save "`output_data'/pop_education_`year'.dta", replace
			
	}

	
	
	
	