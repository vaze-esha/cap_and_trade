/*==============================================================================
							2_merge_2016.do
================================================================================

	PURPOSE:
	
		1.Import cci_ces datasets and merge with ces scores 
		
	INPUTS:
		1. cci_CESVersion2.dta
		2. cci_CESVersion3.dta
		3. cci_2016.dta
	
	OUTPUTS:
		1. 2016.dta 
		
		
==============================================================================*/
/*============================================================================*/	
* code 
	local code "/Users/eshavaze/cap_and_trade"
	
	* workingdir
	local workingdir "/Users/eshavaze/Dropbox/cal_cap_and_trade"
	
	* input dir
	local input_data "`workingdir'/0_raw_input"
	di "`input_data'"

	* output dir
	local output_data "`workingdir'/1_input"
	di "`output_data'"
	
/*==============================================================================
							 1. Load and Inspect
==============================================================================*/	

	/*
	
		Take each yearly dataset and merge it with CES Score data 
		Resulting dataset is at the Census Tract level 
	
	*/
	
	use "`output_data'/cci_yearly/cci_2017.dta"
	
	duplicates tag CensusTract, gen(dup)
	tab dup
	/*
	    dup |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      2,803       18.89       18.89
          1 |      4,782       32.23       51.13
          2 |      4,020       27.10       78.22
          3 |      1,840       12.40       90.62
          4 |        525        3.54       94.16
          5 |        168        1.13       95.30
          6 |         77        0.52       95.81
          7 |         56        0.38       96.19
          8 |          9        0.06       96.25
          9 |         20        0.13       96.39
         10 |         11        0.07       96.46
         12 |         13        0.09       96.55
         14 |         15        0.10       96.65
         15 |         16        0.11       96.76
         49 |         50        0.34       97.09
        430 |        431        2.91      100.00
------------+-----------------------------------
      Total |     14,836      100.00
 
	most census tracts get funded 2/3 times per year
	
	*/
	
	duplicates tag ProjectIDNumber CensusTract, gen(d)
	tab d 

	/*
	
	 d |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     14,614       98.50       98.50
          1 |         68        0.46       98.96 // bulk in Low-Income Weatherization Program 
          2 |         12        0.08       99.04
          3 |         12        0.08       99.12
          4 |          5        0.03       99.16
          5 |          6        0.04       99.20
          6 |          7        0.05       99.25
          7 |         16        0.11       99.35
          8 |          9        0.06       99.41
         10 |         11        0.07       99.49
         12 |         13        0.09       99.58
         13 |         14        0.09       99.67
         48 |         49        0.33      100.00 // Low Carbon Transportation
------------+-----------------------------------
      Total |     14,836      100.00
	  
	  these funding grants are usually for unique projects 

*/
	drop dup 
	drop d
	/*
	  count if BufferAmount==.
	  12,618

	. count if BufferCount==.
	  12,618

	. count if ApplicantsAssisted!=0
	  0

	. count if IntermediaryAdminExpensesCalc!=0
	  37
	
	. tab CESVersion

	 CESVersion |      Freq.     Percent        Cum.
	------------+-----------------------------------
			  2 |     12,618       85.05       85.05
			  3 |      2,218       14.95      100.00
	------------+-----------------------------------
		  Total |     14,836      100.00
	

	*/
	
	// what programs get funded?
	tab ProjectDescription
	tab ProgramName
	tab SubProgramName
	
	/*
	CVRP promotes clean vehicle adoption .. |     10,573       71.27       71.76
	EFMP Plus-up provides additional ince.. |        702        4.73       76.84
	Enhanced Fleet Modernization Program .. |        200        1.35       78.19
	Provides single-family and small mult.. |        844        5.69       86.03
	Provides single-family low-income hom.. |          2        0.01       86.04
	Provides single-family low-income hom.. |         16        0.11       86.15
	Provides single-family low-income hom.. |         30        0.20       86.35
	Provides single-family low-income hom.. |         14        0.09       86.45
	Provides single-family low-income hom.. |         38        0.26       86.70
	Provides single-family low-income hom.. |        601        4.05       90.75

	
	                       Program Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
          Active Transportation Program |          3        0.02        0.02
Affordable Housing and Sustainable Co.. |         11        0.07        0.09
              Climate Smart Agriculture |        235        1.58        1.68
                  Forest Health Program |          4        0.03        1.71
  Low Carbon Transit Operations Program |        102        0.69        2.39
              Low Carbon Transportation |     11,752       79.21       81.61
      Low-Income Weatherization Program |      1,586       10.69       92.30
Sustainable Agricultural Lands Conser.. |          3        0.02       92.32
     Transformative Climate Communities |          1        0.01       92.32
Transit and Intercity Rail Capital Pr.. |         13        0.09       92.41
   Urban and Community Forestry Program |         43        0.29       92.70
                        Waste Diversion |          7        0.05       92.75
                Water-Energy Efficiency |      1,076        7.25      100.00
----------------------------------------+-----------------------------------
                                  Total |     14,836      100.00

					   Sub Program Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
          Active Transportation Program |          3        0.02        0.02
Affordable Housing and Sustainable Co.. |         11        0.07        0.09
  Alternative Manure Management Program |          1        0.01        0.10
                       Clean Cars 4 All |        902        6.08        6.18
                 Clean Mobility Options |          1        0.01        6.19
    Clean Truck and Bus Vouchers (HVIP) |        191        1.29        7.48
           Clean Vehicle Rebate Project |     10,608       71.50       78.98
Dairy Digester Research and Developme.. |         16        0.11       79.08
Financing Assistance for Lower-Income.. |         22        0.15       79.23
                  Forest Health Program |          4        0.03       79.26
                  Healthy Soils Program |          1        0.01       79.27
  Low Carbon Transit Operations Program |        102        0.69       79.95
Multi-Family Energy Efficiency and Re.. |         41        0.28       80.23
                        Organics Grants |          7        0.05       80.28
        Rural School Bus Pilot Projects |         20        0.13       80.41
Single-Family Energy Efficiency and S.. |        944        6.36       86.78
 Single-Family Solar Photovoltaics (PV) |        601        4.05       90.83
State Water Efficiency and Enhancemen.. |        217        1.46       92.29
Sustainable Agricultural Lands Conser.. |          3        0.02       92.31
Transformative Climate Communities (C.. |          1        0.01       92.32
Transit and Intercity Rail Capital Pr.. |         13        0.09       92.40
           Urban and Community Forestry |         43        0.29       92.69
             Water-Energy Grant Program |      1,076        7.25       99.95
      Zero-Emission Truck and Bus Pilot |          8        0.05      100.00
----------------------------------------+-----------------------------------
                                  Total |     14,836      100.00
--> 2017 round of funding should influence voting on clean cars specifically and 
		energy policy 
	
	*/
	
	
	// how long do projects usually last?
	tab ProjectLifeYears
	/*
	
        Project Life Years |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |         52        0.35        0.35
                    1 |         81        0.55        0.90
                  1.2 |          1        0.01        0.90
                  1.6 |          1        0.01        0.91
                   10 |        997        6.72        7.63
                  100 |         24        0.16        7.79
                   11 |         61        0.41        8.20
                   12 |          2        0.01        8.22
                   14 |          3        0.02        8.24
                   15 |        234        1.58        9.81
                   16 |        140        0.94       10.76
                    2 |          9        0.06       10.82
   2.2000000000000002 |          1        0.01       10.83
                   20 |        160        1.08       11.90
               23.375 |          1        0.01       11.91
                   25 |        732        4.93       16.84
                    3 |     11,534       77.74       94.59
                   30 |        220        1.48       96.07
                    4 |          2        0.01       96.08
                   40 |         42        0.28       96.37
                    5 |        407        2.74       99.11
                    6 |          3        0.02       99.13
                   60 |          4        0.03       99.16
                    7 |          2        0.01       99.17
                    8 |         33        0.22       99.39
                    9 |         90        0.61      100.00
----------------------+-----------------------------------
                Total |     14,836      100.00

				
		--> Projects usually last three years -- so 2017-2020
			measure impacts of this funding round for three years 

	*/
	// how many projects have external funding (in addition to ggrf?)
	count if TotalProjectCost!= TotalProgramGGRFFunding
	//  1875
	tab ProgramName if TotalProjectCost!= TotalProgramGGRFFunding
	
	/*
	
	Program Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
          Active Transportation Program |          2        0.11        0.11
Affordable Housing and Sustainable Co.. |          9        0.48        0.59
              Climate Smart Agriculture |        217       11.57       12.16
                  Forest Health Program |          4        0.21       12.37
  Low Carbon Transit Operations Program |         52        2.77       15.15
              Low Carbon Transportation |        197       10.51       25.65
      Low-Income Weatherization Program |      1,267       67.57       93.23
Sustainable Agricultural Lands Conser.. |          3        0.16       93.39
Transit and Intercity Rail Capital Pr.. |         13        0.69       94.08
   Urban and Community Forestry Program |         13        0.69       94.77
                        Waste Diversion |          7        0.37       95.15
                Water-Energy Efficiency |         91        4.85      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,875      100.00

*/

	tab County
	count if strpos(County, ",") > 0
	// 42
	// none of these have census tract details 
	
/*==============================================================================
							     2. Cleaning 
==============================================================================*/	

	drop if CensusTract==""

	// merge ces2 first
	preserve

	//Keep only observations where CES20Score == 2
	keep if CESVersion == 2

	//Merge with ces2results.dta (for CES score 2)
	merge m:1 CensusTract using "`output_data'/ces2results.dta"
	
	/*
	
	Result                      Number of obs
    -----------------------------------------
    Not matched                         1,352
        from master                       409  (_merge==1) // projects without census tract associated 
        from using                        943  (_merge==2) // tracts that get no funding 

    Matched                            12,209  (_merge==3)
    -----------------------------------------


*/

	// save temp 
	
	/* 
		
		to account for these, we use the CaliforniaCounty Measure instead of the 
		cci dataset county, which will be an empty field after the merge 
	
	*/
	drop County 
	rename CaliforniaCounty County
	
	tempfile merged_ces2
	save `merged_ces2'

	restore
	

	// merge ces3 
	preserve

	//Keep only observations where CES20Score == 2
	keep if CESVersion == 3

	//Merge with ces2results.dta (for CES score 2)
	merge m:1 CensusTract using "`output_data'/ces3results.dta"
	
	/*
	        Result                      Number of obs
    -----------------------------------------
    Not matched                         5,904
        from master                         1  (_merge==1) // error 
        from using                      5,903  (_merge==2) // unfunded under ver3

    Matched                             2,193  (_merge==3)
    -----------------------------------------


*/

	// save temp 
	drop if _merge==2 // we don't need these, unfunded under ver 3 data 
	drop if _merge==1
	/* 
		
		to account for these, we use the CaliforniaCounty Measure instead of the 
		cci dataset county, which will be an empty field after the merge 
	
	*/
	drop County 
	rename CaliforniaCounty County
	
	tempfile merged_ces3
	save `merged_ces3'

	restore


	// append .dtas 
	use `merged_ces2', clear
	append using `merged_ces3'

	* Save the final appended dataset
	save "`output_data'/2016.dta", replace
	
	
	drop if _merge==1
	drop _merge 
	
	// keep unfunded tracts in dataset, these are true zeroes 
	count if TotalProgramGGRFFunding==.
	// 1,138
	replace TotalProgramGGRFFunding=0 if TotalProgramGGRFFunding==.
	
	drop if CES20Score==""
	drop if CES20Score=="NA"
	destring CES20Score, replace 
	
	
	// CALCULATING THE INSTRUMENT 
	// RD c=3.86 (KI chosen by previous paper)
	
	preserve 
	// census tracts are duplicated 
	duplicates tag CensusTract County, gen(dup)
	drop if dup>0
	drop dup
	// 4726 obs remain 
	
	// construct the instrument 
	// each county: count funded and unfunded tracts 
	gen Treat_Tract = (CES20Score > 32.66230828250767 & CES20Score <= 36.522308282507666)

	gen Control_Tract = inrange(CES20Score, 28.802308282507667, 32.66230828250767)

	egen TOT_Treatment = total(Treat_Tract), by(County)
	egen TOT_Control = total(Control_Tract), by(County)
	gen instrument = TOT_Treatment / (TOT_Treatment + TOT_Control)
	// 206 missing values generated
	
	br CensusTract County Treat_Tract Control_Tract TOT_Treatment TOT_Control
	
	// each county has once instrument level, only retain those 
	duplicates tag County, gen(dup)
	bysort County (dup): keep if _n == 1
	
	keep County instrument
	// not that there are some zeros here (true zeroes: tracts in bandwidht, none funded)
	
	// Save it as a temporary file  
    tempfile instr_data  
    save `instr_data'
	
	restore 
	

	/*
	
	206 obs where instrument is missing -- these are whole counties where 
	   the tracts never fall in the RD score range we need 
	   
	   These counties are excluded from the sample because they are off the 
	   threshold we need to argue exogneity
	   
	*/
	
	egen TOT_funding_treated = sum(TotalProgramGGRFFunding) if CES20Score > 32.66230828250767 & CES20Score <= 36.522308282507666, by(County)
	egen TOT_funding_control = sum(TotalProgramGGRFFunding) if inrange(CES20Score, 28.802308282507667, 32.66230828250767), by(County)
	egen TOT_funding = sum(TotalProgramGGRFFunding), by(County) // total funds rec'd by each county
	
	tostring(CensusTract), replace
	
	// merge the instrument back in 
	merge m:1 County using `instr_data'  
	drop _merge  // Drop merge indicator
	
	/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                            13,063  (_merge==3)
    -----------------------------------------

	*/
