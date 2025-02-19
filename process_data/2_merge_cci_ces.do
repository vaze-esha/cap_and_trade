/*==============================================================================
							1_clean_datasets.do
================================================================================

	PURPOSE:
	
		1.Import cci_ces datasets and merge with ces scores 
		
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
							     import data
==============================================================================*/	
	/*
	// import ces2
	import excel "`input_data'/ces2results.xlsx", sheet("CES2.0FinalResults") firstrow clear
	keep CensusTract TotalPopulation CaliforniaCounty CES20Score CES20PercentileRange
	save "`output_data'/ces2results.dta", replace

	// import ces3
	import excel "`input_data'/ces3results.xlsx", sheet("CES3.0FinalResults") firstrow clear
	keep CensusTract TotalPopulation CaliforniaCounty CES30Score CES30Percentile CES30PercentileRange
	save "`output_data'/ces3results.dta", replace

	// import ces4
	import excel "`input_data'/ces4results.xlsx", sheet("CES4.0FinalResults") firstrow clear
	keep CensusTract TotalPopulation CaliforniaCounty CES40Score CES40Percentile CES40PercentileRange
	save "`output_data'/ces4results.dta", replace
	*/
	
********************************************************************************

/*==============================================================================
							     merges
==============================================================================*/	

	/*
	
		Take each yearly dataset and merge it with CES Score data 
		Resulting dataset is at the Census Tract level 
	
	*/
	
	use "`output_data'/cci_yearly/cci_2015.dta"
	destring CensusTract, replace
	// 381 missing 
	// these are projects that were implemented at the county/ad/sd levels
	
	duplicates tag CensusTract, gen(dup)
	
	
	merge m:1 CensusTract using "`output_data'/ces2results.dta"

	/*
	
	    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,676
        from master                       382  (_merge==1)
        from using                      1,294  (_merge==2)

    Matched                            15,686  (_merge==3)
    -----------------------------------------

	381 unmatched from master are missing 
	1. one obs from LA: no project details found
	2. drop this, likely an error 
	
	*/
	br if _merge == 1
	drop if _merge==1 &  ProjectType == ""
	br if _merge == 2 
	
	// unmatched from using: tracts that never get any funding in the cci in 2015
	
	br CensusTract County TotalProgramGGRFFunding FundingRecipient CES20Score CES20PercentileRange if _merge == 3
	sort CES20PercentileRange
	drop if CES20Score=="NA" // drop unscored tracts 
	
	/*
	
		There are funded tracts that do not have a CES ranking 
		
		Is there a pattern for higher ranked tracts that get funded?
		
	*/
	
	tab CES20PercentileRange
	replace CES20PercentileRange = subinstr(CES20PercentileRange, " (lowest scores)", "", .)
	replace CES20PercentileRange = subinstr(CES20PercentileRange, " (highest scores)", "", .)
	
	// are there are any patterns for the highest scores that get funded?
	tab FundingRecipient if inlist(CES20PercentileRange, "76-80%", "81-85%", "86-90%", "91-95%", "96-100%")
	/*
	
					  Funding Recipient |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                               CalSTART |        203        7.77        7.77
    Center for Sustainable Energy (CSE) |      2,245       85.95       93.72
                                 SCAQMD |        132        5.05       98.77
                                SJVAPCD |         32        1.23      100.00
----------------------------------------+-----------------------------------
                                  Total |      2,612      100.00
*/
	// are there are any patterns for the lowest scores that get funded?
	tab FundingRecipient if !inlist(CES20PercentileRange, "76-80%", "81-85%", "86-90%", "91-95%", "96-100%")
	
	/*
	
					  Funding Recipient |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                      - |        380        2.82        2.82
                               CalSTART |        168        1.25        4.07
    Center for Sustainable Energy (CSE) |     12,858       95.56       99.63
              Land Trust of Napa County |          1        0.01       99.64
                                 SCAQMD |         39        0.29       99.93
                                SJVAPCD |         10        0.07      100.00
----------------------------------------+-----------------------------------
                                  Total |     13,456      100.00
	
	*/
	
	
	// CES is majority recepient in both categories
	// "-" is the same set of obs where the census tract is missing 
	
	drop if CES20PercentileRange==""
	drop if CES20PercentileRange=="NA"
	
	// total funds by percentile range:
	egen total_funds_by_prange = total(TotalProgramGGRFFunding), by(CES20PercentileRange)
	list CES20PercentileRange total_funds_by_prange 


	/*
	bysort CES20PercentileRange (total_funds_by_prange): keep if _n == 1
	list CES20PercentileRange total_funds_by_prange, clean noobs
	
	CES20P~e   total_~e  
        1-5%   1.64e+07  
      11-15%   1.45e+07  
      16-20%   1.39e+07  
      21-25%   1.29e+07  
      26-30%   1.28e+07  
      31-35%   1.02e+07  
      36-40%    8941773  
      41-45%    8345976  
      46-50%    7141962  
      51-55%    6402082  
      56-60%    5724412  
       6-10%   1.71e+07  
      61-65%    5072592  
      66-70%    3911176  
      71-75%    3790069  
      76-80%    3101932  
      81-85%    3212076  
      86-90%    2431692  
      91-95%    2266912  
     96-100%    4345377  

*/
	egen total_sum_top = total(total_funds_by_prange) if inlist(CES20PercentileRange, "76-80%", "81-85%", "86-90%", "91-95%", "96-100%")
	egen total_sum_bottom = total(total_funds_by_prange) if !inlist(CES20PercentileRange, "76-80%", "81-85%", "86-90%", "91-95%", "96-100%")
	// verifying that bottom 25 gets more money than top 75 

	// Does score predict funding?
	// higher score --> more funding
	destring CES20Score, replace 
	reg TotalProgramGGRFFunding CES20Score
	// full sample is too noisy
	
	/*
	  Source |       SS           df       MS      Number of obs   =    15,660
-------------+----------------------------------   F(1, 15658)     =    774.61
       Model |  1.4580e+11         1  1.4580e+11   Prob > F        =    0.0000
    Residual |  2.9471e+12    15,658   188217621   R-squared       =    0.0471
-------------+----------------------------------   Adj R-squared   =    0.0471
       Total |  3.0929e+12    15,659   197516282   Root MSE        =     13719

------------------------------------------------------------------------------
TotalProgr~g | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  CES20Score |  -225.7957   8.112842   -27.83   0.000    -241.6978   -209.8936
       _cons |   15594.18   217.2635    71.78   0.000     15168.32    16020.04
------------------------------------------------------------------------------

	*/
	
	// what about those above the cut off score?
	centile CES20Score, centile(75)
	local p75 = r(c_1)
	display "`p75'"

	reg TotalProgramGGRFFunding CES20Score if CES20Score >= 32.66230828250767
	/*
	  Source |       SS           df       MS      Number of obs   =     3,479
-------------+----------------------------------   F(1, 3477)      =     76.29
       Model |  5.8715e+09         1  5.8715e+09   Prob > F        =    0.0000
    Residual |  2.6759e+11     3,477  76959209.8   R-squared       =    0.0215
-------------+----------------------------------   Adj R-squared   =    0.0212
       Total |  2.7346e+11     3,478    78625275   Root MSE        =    8772.6

------------------------------------------------------------------------------
TotalProgr~g | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  CES20Score |   140.1639   16.04688     8.73   0.000     108.7016    171.6261
       _cons |  -211.4591   716.9919    -0.29   0.768    -1617.227    1194.309
------------------------------------------------------------------------------

*/ 

	// those below?
	reg TotalProgramGGRFFunding CES20Score if CES20Score < 32.66230828250767
	
	/*
	
	      Source |       SS           df       MS  Number of obs   =    12,181
-------------+----------------------------------   F(1, 12179)     =    537.49
       Model |  1.1541e+11         1  1.1541e+11   Prob > F        =    0.0000
    Residual |  2.6151e+12    12,179   214723999   R-squared       =    0.0423
-------------+----------------------------------   Adj R-squared   =    0.0422
       Total |  2.7305e+12    12,180   224181925   Root MSE        =     14653

------------------------------------------------------------------------------
TotalProgr~g | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  CES20Score |  -416.6218   17.97034   -23.18   0.000    -451.8465   -381.3971
       _cons |   18829.82   337.0684    55.86   0.000     18169.11    19490.52
------------------------------------------------------------------------------

	*/
	
	// focus on sub-samples near the cut-off values
	
	twoway (scatter TotalProgramGGRFFunding CES20Score if CES20Score >= 32.66230828250767) ///
       (lfit TotalProgramGGRFFunding CES20Score if CES20Score >= 32.66230828250767)

	twoway (scatter TotalProgramGGRFFunding CES20Score if CES20Score < 32.66230828250767) ///
       (lfit TotalProgramGGRFFunding CES20Score if CES20Score < 32.66230828250767)

	
	// lower scores have a higher mass of big ticket projects 
	
	
	
	