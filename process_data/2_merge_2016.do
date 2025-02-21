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
	
	use "`output_data'/cci_yearly/cci_2016.dta"
	destring CensusTract, replace
	// 322 missing 
	// these are projects that were implemented at the county/ad/sd levels
	
	duplicates tag CensusTract, gen(dup)
	tab dup
	br SubProgramName CensusTract County TotalProgramGGRFFunding if dup >0
	/*
	
	    dup |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      3,630       31.37       31.37
          1 |      5,062       43.75       75.12
          2 |      1,587       13.72       88.83
          3 |        616        5.32       94.16
          4 |        170        1.47       95.63
          5 |         24        0.21       95.83
          6 |         49        0.42       96.26
          8 |         18        0.16       96.41
          9 |         20        0.17       96.59 // 
         11 |         12        0.10       96.69 // santa clara
         12 |         13        0.11       96.80 // san diego
         13 |         14        0.12       96.92 // LA
         14 |         15        0.13       97.05 // LA
         18 |         19        0.16       97.22 //san francisco
        321 |        322        2.78      100.00 // missing 
------------+-----------------------------------
      Total |     11,571      100.00

	  
	  Majority of tracts get funded atleast TWO times in a year 

	  Q: Are these the same project? or different projects 
*/

	duplicates tag ProjectIDNumber CensusTract, gen(d)
	tab d
	
	/*
	
	      d |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     11,330       97.92       97.92
          1 |        104        0.90       98.82
          2 |         27        0.23       99.05
          3 |          8        0.07       99.12
          4 |          5        0.04       99.16
          5 |         24        0.21       99.37
          6 |          7        0.06       99.43
          7 |          8        0.07       99.50
          8 |         18        0.16       99.65
          9 |         10        0.09       99.74
         12 |         13        0.11       99.85
         16 |         17        0.15      100.00
------------+-----------------------------------
      Total |     11,571      100.00

	  
	  A: rarely. let's inspect the duplicates here
	  
*/
	br SubProgramName CensusTract County TotalProgramGGRFFunding if d>0
	tab SubProgramName if d>0
	tab County if d>0
	// many, no specific pattern 
	tab TotalProgramGGRFFunding if d>0
	
	/*
	
	                   Sub Program Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
    Clean Truck and Bus Vouchers (HVIP) |        180       74.69       74.69
Single-Family Energy Efficiency and S.. |         58       24.07       98.76
Transit and Intercity Rail Capital Pr.. |          3        1.24      100.00
----------------------------------------+-----------------------------------
                                  Total |        241      100.00


								  
    Lots of variation in funding. 
	mass is at:
	
	19260 |         33       13.69       24.48 // Clean Truck and Bus Vouchers (HVIP)
	23540 |         21        8.71       35.27 // Clean Truck and Bus Vouchers (HVIP)
    24610 |         56       23.24       58.51 // Clean Truck and Bus Vouchers (HVIP)
   108070 |         20        8.30       91.70
   101650 |         10        4.15       82.57
    96300 |         10        4.15       78.01

	  
	many funding recepients for d>0
*/


	// drop empty variables: 
	
	/*
	  count if BufferAmount==.
	  11,525

	. count if BufferCount==.
	  11,525

	. count if ApplicantsAssisted!=0
	  0

	. count if IntermediaryAdminExpensesCalc!=0
	  33
	
	. tab CESVersion

	 CESVersion |      Freq.     Percent        Cum.
	------------+-----------------------------------
			  2 |     11,525       99.60       99.60
			  3 |         46        0.40      100.00
	------------+-----------------------------------
		  Total |     11,571      100.00

	

	*/
	
	
	// what programs get funded?
	tab ProjectDescription
	tab ProgramName
	tab SubProgramName
	/*
	Mass lies here: 
	
	CVRP promotes clean vehicle adoption .. |      8,087       69.89       70.10
	EFMP Plus-up provides additional ince.. |        585        5.06       75.33
	PFP (Public Fleets Pilot) is a projec.. |         44        0.38       76.79
	Project will expand the current water.. |         52        0.45       77.37
	Provides single-family and small mult.. |      1,376       11.89       89.43
	Provides single-family low-income hom.. |        625        5.40       94.83
	Voucher Incentive program to  introdu.. |        172        1.49       98.41
	Voucher incentive program to  introdu.. |        129        1.11       99.52


	
						   Program Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
Affordable Housing and Sustainable Co.. |         22        0.19        0.19
              Climate Smart Agriculture |        127        1.10        1.29
                  Forest Health Program |          5        0.04        1.33
  Low Carbon Transit Operations Program |        114        0.99        2.32
              Low Carbon Transportation |      9,029       78.03       80.35 // clean transport
      Low-Income Weatherization Program |      2,001       17.29       97.64 // weatherization
Sustainable Agricultural Lands Conser.. |          1        0.01       97.65
Transit and Intercity Rail Capital Pr.. |         16        0.14       97.79
   Urban and Community Forestry Program |         29        0.25       98.04
                        Waste Diversion |          1        0.01       98.05
                Water-Energy Efficiency |        226        1.95      100.00
----------------------------------------+-----------------------------------
                                  Total |     11,571      100.00


	
					   Sub Program Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
Advanced Technology Demonstration and.. |          3        0.03        0.03
Affordable Housing and Sustainable Co.. |         22        0.19        0.22
                       Clean Cars 4 All |        585        5.06        5.27
                 Clean Mobility Options |          1        0.01        5.28
    Clean Truck and Bus Vouchers (HVIP) |        301        2.60        7.88
           Clean Vehicle Rebate Project |      8,131       70.27       78.15
Dairy Digester Research and Developme.. |          3        0.03       78.18
Financing Assistance for Lower-Income.. |          7        0.06       78.24
                  Forest Health Program |          5        0.04       78.28
  Low Carbon Transit Operations Program |        114        0.99       79.27
           Organics and Recycling Loans |          1        0.01       79.28
Single-Family Energy Efficiency and S.. |      1,376       11.89       91.17
 Single-Family Solar Photovoltaics (PV) |        625        5.40       96.57
State Water Efficiency and Enhancemen.. |        124        1.07       97.64
           State Water Project Turbines |          2        0.02       97.66
Sustainable Agricultural Lands Conser.. |          1        0.01       97.67
Transit and Intercity Rail Capital Pr.. |         16        0.14       97.80
           Urban and Community Forestry |         29        0.25       98.06
             Water-Energy Grant Program |        224        1.94       99.99
      Zero-Emission Truck and Bus Pilot |          1        0.01      100.00
----------------------------------------+-----------------------------------
                                  Total |     11,571      100.00


	
	1. CVRP promotes clean vehicle adoption in California by offering rebates from $1,000 to $7,502 
	for the purchase or lease of new, eligible zero-emission vehicles, including electric, 
	plug-in hybrid electric and fuel cell vehicles.
	
	2. Provides single-family and small multi-family low-income homes in disadvantaged communities 
	with weatherization and energy efficiency measures to provide energy savings and other co-benefits.
	
	--> 2016 round of funding should influence voting on clean cars specifically and 
		energy policy 
	
	*/
	
	// how long do projects usually last?
	tab ProjectLifeYears
	/*
	
     Project Life Years |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |         61        0.53        0.53
                  0.5 |          1        0.01        0.54
                    1 |         73        0.63        1.17
                  1.7 |          2        0.02        1.18
                   10 |        446        3.85        5.04
                10-20 |          4        0.03        5.07
                  100 |         24        0.21        5.28
                   11 |          1        0.01        5.29
                   12 |         12        0.10        5.39
                   14 |          6        0.05        5.44
                   15 |        333        2.88        8.32
                   16 |          5        0.04        8.37
                   18 |          2        0.02        8.38
                    2 |          9        0.08        8.46
                   20 |         63        0.54        9.01
                   25 |        644        5.57       14.57
                    3 |      8,737       75.51       90.08
                   30 |         17        0.15       90.23
                    4 |          1        0.01       90.23
               4.3-10 |         16        0.14       90.37
                   40 |         28        0.24       90.61
                    5 |        766        6.62       97.23
                    6 |          2        0.02       97.25
                    7 |          1        0.01       97.26
                    8 |        145        1.25       98.51
                    9 |        120        1.04       99.55
                  9.5 |         52        0.45      100.00
----------------------+-----------------------------------
                Total |     11,571      100.00

				
		--> Projects usually last three years -- so 2016-2019
			measure impacts of this funding round for three years 

	*/
	
	// how many projects have external funding (in addition to ggrf?)
	count if TotalProjectCost!= TotalProgramGGRFFunding
	//  2,489
	tab ProgramName if TotalProjectCost!= TotalProgramGGRFFunding
	
	/*
						   Program Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
Affordable Housing and Sustainable Co.. |         17        0.68        0.68
              Climate Smart Agriculture |        113        4.54        5.22
                  Forest Health Program |          4        0.16        5.38
  Low Carbon Transit Operations Program |         61        2.45        7.83
              Low Carbon Transportation |        303       12.17       20.01
      Low-Income Weatherization Program |      1,822       73.20       93.21
Sustainable Agricultural Lands Conser.. |          1        0.04       93.25
Transit and Intercity Rail Capital Pr.. |         16        0.64       93.89
   Urban and Community Forestry Program |         28        1.12       95.02
                        Waste Diversion |          1        0.04       95.06
                Water-Energy Efficiency |        123        4.94      100.00
----------------------------------------+-----------------------------------
                                  Total |      2,489      100.00



*/

	tab County 
	/*
	 County |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                Alameda |        897        5.58        5.58
Alpine, Fresno, Inyo, Madera, Mono, T.. |          1        0.01        5.59
                                 Amador |          8        0.05        5.64
                      Amador, El Dorado |          1        0.01        5.64
                                  Butte |         81        0.50        6.15
                              Calaveras |         14        0.09        6.24
                                 Colusa |          8        0.05        6.29
                     Colusa, Inyo, Mono |          1        0.01        6.29
                           Contra Costa |        509        3.17        9.46
             Contra Costa, Napa, Solano |          1        0.01        9.47
                              Del Norte |          2        0.01        9.48
                              El Dorado |         76        0.47        9.95
                      El Dorado, Placer |          1        0.01        9.96
                El Dorado, Placer, Yolo |          1        0.01        9.96
                                 Fresno |        373        2.32       12.29
                          Fresno, Kings |          1        0.01       12.29
                         Fresno, Tulare |          1        0.01       12.30
                                  Glenn |          8        0.05       12.35
                               Humboldt |         61        0.38       12.73
                               Imperial |         17        0.11       12.83
                                   Inyo |          3        0.02       12.85
                                   Kern |        197        1.23       14.08
                                  Kings |         38        0.24       14.31
                                   Lake |         15        0.09       14.41
                                 Lassen |          1        0.01       14.41
                            Los Angeles |      4,533       28.21       42.63
         Los Angeles, Orange, Riverside |          1        0.01       42.63
            Los Angeles, San Bernardino |          1        0.01       42.64
                                 Madera |         43        0.27       42.91
                                  Marin |        165        1.03       43.93
                               Mariposa |          5        0.03       43.96
                              Mendocino |         42        0.26       44.22
                                 Merced |         60        0.37       44.60
        Merced, San Joaquin, Stanislaus |          1        0.01       44.60
                                  Modoc |          2        0.01       44.62
                                   Mono |          2        0.01       44.63
                               Monterey |        148        0.92       45.55
                                   Napa |         82        0.51       46.06
                                 Nevada |         45        0.28       46.34
                         Nevada, Placer |          1        0.01       46.35
                         Nevada, Sierra |          1        0.01       46.35
                                 Orange |      1,495        9.30       55.66
                                 Placer |        182        1.13       56.79
                                 Plumas |          2        0.01       56.80
                              Riverside |        701        4.36       61.17
                             Sacramento |        522        3.25       64.41
                       Sacramento, Yolo |          1        0.01       64.42
                             San Benito |         27        0.17       64.59
                San Benito, Santa Clara |          1        0.01       64.59
                         San Bernardino |        529        3.29       67.89
                              San Diego |      1,325        8.25       76.13
                          San Francisco |        448        2.79       78.92
  San Francisco, San Mateo, Santa Clara |          1        0.01       78.93
                            San Joaquin |        199        1.24       80.17
                        San Luis Obispo |        137        0.85       81.02
                              San Mateo |        445        2.77       83.79
                          Santa Barbara |        159        0.99       84.78
                            Santa Clara |      1,068        6.65       91.42
                             Santa Cruz |        138        0.86       92.28
                                 Shasta |         58        0.36       92.64
                               Siskiyou |          6        0.04       92.68
                                 Solano |        177        1.10       93.78
                                 Sonoma |        270        1.68       95.46
                             Stanislaus |        122        0.76       96.22
                                 Sutter |         20        0.12       96.35
                                 Tehama |         15        0.09       96.44
                                Trinity |          3        0.02       96.46
                                 Tulare |         91        0.57       97.03
                               Tuolumne |         16        0.10       97.12
                                Ventura |        356        2.22       99.34
                                   Yolo |         98        0.61       99.95
                                   Yuba |          8        0.05      100.00
----------------------------------------+-----------------------------------
                                  Total |     16,068      100.00
								  
		Q: A census tract cannot belong to multiple counties 
		   So what are these weird obs with comma county names?

	*/
	
	count if strpos(County, ",") > 0
	// 36
	// none of these have census tract details 
	
	
/*==============================================================================
							     2. Cleaning 
==============================================================================*/	
	// dropping empties
	drop ApplicantsAssisted BufferAmount BufferCount
	drop dup 
	drop d
	
	// merge ces2 first
	preserve

	//Keep only observations where CES20Score == 2
	keep if CESVersion == 2

	//Merge with ces2results.dta (for CES score 2)
	merge m:1 CensusTract using "`output_data'/ces2results.dta"
	
	/*
	
	Result                      Number of obs
    -----------------------------------------
    Not matched                         1,461
        from master                       323  (_merge==1) // projects with no census tract associated 
        from using                      1,138  (_merge==2) // census tracts that don't get funded 

    Matched                            11,202  (_merge==3)
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
    Not matched                         7,989
        from master                         0  (_merge==1)
        from using                      7,989  (_merge==2) // unfunded under ver3

    Matched                                46  (_merge==3)
    -----------------------------------------
*/

	// save temp 
	drop if _merge==2 // we don't need these, unfunder under ver 3 data 
	
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

	drop if _merge==1 // census tracts that did not have any funding data associated with them (not true zeroes)
	drop _merge 
	
	// keep unfunded tracts in dataset, these are true zeroes 
	count if TotalProgramGGRFFunding==.
	// 1,138

	// do not keep unscored tracts, analysis hedges on RD threshold cutoff 
	drop if CES20Score==""
	drop if CES20Score=="NA"
	destring CES20Score, replace 
	
	// calculate the top 25 pcentile score 
	centile CES20Score, centile(75)
	local p75 = r(c_1)
	display "`p75'"
	// 40.6670816696226
	
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
    Matched                            12,275  (_merge==3)
    -----------------------------------------

	
	*/
	
	// now de-duplicate the dataset on County again 
	duplicates tag County, gen(dup)
	bysort County (dup): keep if _n == 1
	
	keep County instrument TOT_funding TOT_funding_treated TOT_funding_control TotalPopulation
	drop if instrument==.
	
	/*
	
	670 obs where instrument is missing -- these are whole counties where 
	   the tracts never fall in the RD score range we need 
	   
	   These counties are excluded from the sample because they are off the 
	   threshold we need to argue exogneity
	   
	*/

	// FIRST STAGE:
	reg TOT_funding instrument 
	
	/*

     
      Source |       SS           df       MS      Number of obs   =        37
-------------+----------------------------------   F(1, 35)        =      1.26
       Model |  6.2927e+13         1  6.2927e+13   Prob > F        =    0.2687
    Residual |  1.7437e+15        35  4.9821e+13   R-squared       =    0.0348
-------------+----------------------------------   Adj R-squared   =    0.0073
       Total |  1.8066e+15        36  5.0185e+13   Root MSE        =    7.1e+06

------------------------------------------------------------------------------
 TOT_funding | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |    5543646    4932680     1.12   0.269     -4470227    1.56e+07
       _cons |    1855707    2213876     0.84   0.408     -2638700     6350114
------------------------------------------------------------------------------


	
	*/
	
	save "`output_data'/cci_ces_merged/2016.dta"
