/*==============================================================================
							1_clean_datasets.do
================================================================================

	PURPOSE:
	
		1. Report missings 
		2. Summarize key variables 
		3. Preliminary cleaning
		
	INPUTS:
		1. cci_2024ar_detaileddata.xlsx
	
	OUTPUTS:
	
	Datasets split by CESVersion (2, 3, 4):

		cci_CESVersion2.dta
		cci_CESVersion3.dta
		cci_CESVersion4.dta

	Datasets split by Year (2015 to 2023):

		cci_2015.dta
		cci_2016.dta
		cci_2017.dta
		cci_2018.dta
		cci_2019.dta
		cci_2020.dta
		cci_2021.dta
		cci_2022.dta
		cci_2023.dta
		
		
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
							     import data
==============================================================================*/	
	
	import excel "`input_data'/cci_2024ar_detaileddata.xlsx", sheet("Project List") firstrow
	
	/* 
	
	Use the CCI dataset to process a dataset that tells us the score 
	for each census tract (2.0, 3.0, 4.0) and the amount of GGRF funding 
	attributed to that tract 
	
	We also know 
	1. which geographic unit (county, AD, SD) each tract belongs to 
	2. Date of implementation 
	3. Type of program 
	4. Text details on project 
	5. Recepient details 
	6. Buffer amounts dispersed 

	*/
	
	keep ProjectIDNumber ReportingCycleName AgencyName ProgramName ProgramDescription SubProgramName RecordType ProjectName ProjectType ProjectDescription CensusTract Address LatLong SenateDistrict AssemblyDistrict County TotalProjectCost TotalProgramGGRFFunding ProjectLifeYears DateOperational ProjectCompletionDate FundingRecipient BufferAmount BufferCount CESVersion CESVersion CESVersionCalc ApplicantsAssisted IntermediaryAdminExpensesCalc PRIMARY_FUNDING_RECIPIENT_TYPE
	
	
	// 1. year 
	
	rename ReportingCycleName Year
	drop if Year==""
	tab Year 
	
	/*
	Reporting Cycle Name |      Freq.     Percent        Cum.
---------------------+-----------------------------------
                2015 |     16,068       11.36       11.36
                2016 |     11,571        8.18       19.54
                2017 |     14,836       10.49       30.03
                2018 |     19,846       14.03       44.07
    2018 Semi-Annual |      2,293        1.62       45.69
                2019 |     13,508        9.55       55.24
    2019 Semi-Annual |      3,646        2.58       57.82
                2020 |     15,191       10.74       68.56
    2020 Semi-Annual |      2,844        2.01       70.57
                2021 |      9,822        6.94       77.51
    2021 Semi-Annual |      5,034        3.56       81.07
                2022 |     10,042        7.10       88.17
2022 Mid-Year Update |      4,064        2.87       91.05
                2023 |      7,918        5.60       96.64
2023 Mid-Year Update |      4,746        3.36      100.00
---------------------+-----------------------------------
               Total |    141,429      100.00
			   
	For my analysis, mid-year updates will be coded as year updates 
	time of update within the year is not relevant 

*/

	// strip semi/mid year update strings
	foreach keyword in "Semi-Annual" "Mid-Year Update" {
    replace Year = subinstr(Year, "`keyword'", "", .)
	replace Year = strtrim(Year)
}

	destring Year, replace
	
	// 2. Census Tract
	quietly tab CensusTract
	display r(r)
	// 7979 unique census tracts in this dataset 
	
	 count if CensusTract==""
	// 22,059
	
	/*
	
	These projects are at the county level, not the census tract level 
	This is not necessarily a problem, since the outcome is at the county level
	
	*/

	 count if CensusTract=="" & County==""
	// 0
	
	//3. CESVersion
	
	tab CESVersion
	replace CESVersion="2" if CESVersion=="2.0"
	replace CESVersion="3" if CESVersion=="3.0" // recording errors
	
	destring CESVersion, replace 
	
	
	//4. County 
	tab County
	// none missing 
	
	/*
		populated by multiple values: a project can impact many counties
		because we only consider the funding recieved by disdvantaged tracts 
		as a proportion of control tracts in the same county 
		we deal with county splits after score calculation 
		
	*/
	
********************************************************************************

	// split and save by CES Scores
	
	foreach v in 2 3 4 {
    preserve
    keep if CESVersion == `v'
    save "`output_data'/cci_ces_versions/cci_CESVersion`v'", replace
    restore
}

	// split and save by Year 
	
	foreach year in 2015 2016 2017 2018 2019 2020 2021 2022 2023 {
    preserve
    keep if Year == `year'
    save "`output_data'/cci_yearly/cci_`year'", replace
    restore
}

	
********************************************************************************

	/*
	
	potentially:
		make a dataset with the cci reported outcomes and if they have any 
		impact
	

	
	
	