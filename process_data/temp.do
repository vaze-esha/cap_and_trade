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
								YEARLY MERGES 
==============================================================================*/	

			*******************************************************
			*******************************************************
								    *2015*
			*******************************************************
			*******************************************************

/*==============================================================================
							 1. Load and Inspect
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
	tab dup
	br SubProgramName CensusTract County TotalProgramGGRFFunding if dup >0
	/*
	
	    dup |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      1,524        9.48        9.48
          1 |      3,668       22.83       32.31
          2 |      9,474       58.96       91.27
          3 |        736        4.58       95.86
          4 |         85        0.53       96.38
          5 |         84        0.52       96.91 
          6 |         35        0.22       97.12 
          7 |          8        0.05       97.17 // Ventura
          8 |         18        0.11       97.29 // Fresno and LA
         12 |         13        0.08       97.37 // all in Santa Clara
         15 |         16        0.10       97.47 // all in LA
         25 |         26        0.16       97.63 // all in san bernadino 
        380 |        381        2.37      100.00 // missing census tract observations 
------------+-----------------------------------
      Total |     16,068      100.00
	  
	  Majority of tracts get funded atleast three times in a year 

	  Q: Are these the same project? or different projects 
*/

	duplicates tag ProjectIDNumber CensusTract, gen(d)
	
	/*
	
	      d |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     15,863       98.72       98.72
          1 |         56        0.35       99.07
          2 |         39        0.24       99.32
          3 |         12        0.07       99.39
          4 |         10        0.06       99.45
          5 |         30        0.19       99.64
          8 |          9        0.06       99.70
          9 |         10        0.06       99.76
         14 |         15        0.09       99.85
         23 |         24        0.15      100.00
------------+-----------------------------------
      Total |     16,068      100.00
	  
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
    Clean Truck and Bus Vouchers (HVIP) |        201       98.05       98.05
           Clean Vehicle Rebate Project |          4        1.95      100.00
----------------------------------------+-----------------------------------
                                  Total |        205      100.00
								  
    Total   |
    Program |
GGRFFunding |      Freq.     Percent        Cum.
------------+-----------------------------------
       4000 |          2        0.98        0.98
       7500 |          1        0.49        1.46
      15000 |          1        0.49        1.95
      16617 |          1        0.49        2.44
      18922 |         60       29.27       31.71 // CALSTART
      24057 |          4        1.95       33.66
      24178 |        113       55.12       88.78 // CALSTART
      38895 |          2        0.98       89.76
      42048 |          3        1.46       91.22
      52560 |          2        0.98       92.20
      57816 |          2        0.98       93.17
      62759 |          3        1.46       94.63
      63072 |          1        0.49       95.12
      99865 |          7        3.41       98.54
     110377 |          3        1.46      100.00
------------+-----------------------------------
      Total |        205      100.00
	  
	  
                      Funding Recipient |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                               CalSTART |        201       98.05       98.05
    Center for Sustainable Energy (CSE) |          4        1.95      100.00
----------------------------------------+-----------------------------------
                                  Total |        205      100.00

	So if a census tract gets funded multiple times under the same project 
	It's a calstart project (transportation)

*/


	// drop empty variables: 
	
	/*
	  count if BufferAmount==.
	  16,068

	. count if BufferCount==.
	  16,068

	. count if ApplicantsAssisted!=0
	  0

	. count if IntermediaryAdminExpensesCalc!=0
	  0
	
	  count if CESVersion!=2
	  0

	*/
	
	
	// what programs get funded?
	tab ProjectDescription
	tab ProgramName
	tab SubProgramName
	/*
	Mass lies here: 
	
	CVRP promotes clean vehicle adoption .. |     15,049       93.66       93.81
	Improved transit amenities to attract.. |         32        0.20       94.64
	PFP (Public Fleets Pilot) is a projec.. |         54        0.34       95.70
	Voluntary Vehicle Retirement 			|        213        1.33       97.65
	Voucher Incentive program to  introdu.. |        341        2.12       99.78
	Voucher incentive program to  introdu.. |         30        0.19       99.96
	
							   Program Name |      Freq.     Percent        Cum.
	----------------------------------------+-----------------------------------
				  Climate Smart Agriculture |        237        1.47        1.47
					  Forest Health Program |         29        0.18        1.66
	  Low Carbon Transit Operations Program |         93        0.58        2.23
				  Low Carbon Transportation |     15,688       97.64       99.87
	Sustainable Agricultural Lands Conser.. |          1        0.01       99.88
							Waste Diversion |          8        0.05       99.93
		 Wetlands and Watershed Restoration |         12        0.07      100.00
	----------------------------------------+-----------------------------------
									  Total |     16,068      100.00
	
						   Sub Program Name |      Freq.     Percent        Cum.
	----------------------------------------+-----------------------------------
						   Clean Cars 4 All |        213        1.33        1.33
					 Clean Mobility Options |          1        0.01        1.33
		Clean Truck and Bus Vouchers (HVIP) |        371        2.31        3.64
			   Clean Vehicle Rebate Project |     15,103       93.99       97.64
	Dairy Digester Research and Developme.. |          4        0.02       97.66
					  Forest Health Program |         29        0.18       97.84
	  Low Carbon Transit Operations Program |         93        0.58       98.42
							Organics Grants |          4        0.02       98.44
			   Organics and Recycling Loans |          1        0.01       98.45
	Recycled Fiber, Plastic, and Glass Gr.. |          3        0.02       98.47
			Renewable and Alternative Fuels |          1        0.01       98.48
	State Water Efficiency and Enhancemen.. |        232        1.44       99.92
	Sustainable Agricultural Lands Conser.. |          1        0.01       99.93
		 Wetlands and Watershed Restoration |         12        0.07      100.00
	----------------------------------------+-----------------------------------
									  Total |     16,068      100.00

	
	1. CVRP promotes clean vehicle adoption in California by offering rebates from $1,000 to $7,502 
	for the purchase or lease of new, eligible zero-emission vehicles, including electric, 
	plug-in hybrid electric and fuel cell vehicles.
	
	--> 2015 round of funding should influence voting on clean cars specifically 
	
	*/
	
	// how long do projects usually last?
	tab ProjectLifeYears
	/*
	
   Project Life Years |      Freq.     Percent        Cum.
----------------------+-----------------------------------
                    0 |          1        0.01        0.01
                    1 |         60        0.37        0.38
                   10 |        191        1.19        1.57
                   12 |          4        0.02        1.59
                   15 |        436        2.71        4.31
                    2 |          3        0.02        4.33
                   20 |          7        0.04        4.37
                   25 |          1        0.01        4.38
                25-50 |         12        0.07        4.45
                    3 |     15,317       95.33       99.78
                   30 |          4        0.02       99.80
                    5 |          1        0.01       99.81
                   50 |          3        0.02       99.83
                   60 |         21        0.13       99.96
                    7 |          3        0.02       99.98
                   80 |          3        0.02       99.99
                    9 |          1        0.01      100.00
----------------------+-----------------------------------
                Total |     16,068      100.00
				
		--> Projects usually last three years -- so 2015-2018 
			measure impacts of this funding round for three years 

	*/
	
	// how many projects have external funding (in addition to ggrf?)
	count if TotalProjectCost!= TotalProgramGGRFFunding
	// 867
	
	/*
	 Program Description |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
CalRecycle offers funding to assist p.. |          8        0.92        0.92
Funds forest health restoration, refo.. |         27        3.11        4.04
Invests in competitive projects that .. |        183       21.11       25.14
Provides mobile source incentives to .. |        585       67.47       92.62
Provides operating and capital assist.. |         51        5.88       98.50
The Wetlands Restoration for Greenhou.. |         12        1.38       99.88
Two complementary programs of SGC, th.. |          1        0.12      100.00
----------------------------------------+-----------------------------------
                                  Total |        867      100.00

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
	// 16
	// none of these have census tract details 
	
	
/*==============================================================================
							     2. Cleaning 
==============================================================================*/	
	// dropping empties
	drop BufferAmount BufferCount ApplicantsAssisted IntermediaryAdminExpensesCalc CESVersionCalc CESVersion
	drop dup 
	drop d
	
	// merge with ces scores (2.0 for 2015)
	merge m:1 CensusTract using "`output_data'/ces2results.dta"
	
	/*
	
	    Result                      Number of obs
    -----------------------------------------
    Not matched                         1,676
        from master                       382  (_merge==1) // projects with no census tract associated 
        from using                      1,294  (_merge==2) // census tracts that don't get funded 

    Matched                            15,686  (_merge==3)
    -----------------------------------------
	*/
	
	drop if _merge==1
	
	// keep unfunded tracts in dataset, these are true zeroes 
	count if TotalProgramGGRFFunding==.
	// 1,294

	// do not keep unscored tracts, analysis hedges on RD threshold cutoff 
	drop if CES20Score==""
	drop if CES20Score=="NA"
	destring CES20Score, replace 
	
	// calculate the top 25 pcentile score 
	centile CES20Score, centile(75)
	local p75 = r(c_1)
	display "`p75'"
	// 32.66230828250767
	
	
	// CALCULATING THE INSTRUMENT 
	// RD c=3.86 (KI chosen by previous paper)
	
	// each county: count funded and unfunded tracts 
	gen Treat_Tract = (CES20Score > 32.66230828250767 & CES20Score <= 36.522308282507666)
	//846 treatment tracts 
	
	gen Control_Tract = inrange(CES20Score, 28.802308282507667, 32.66230828250767)
	//1021 control tracts 

	egen TOT_Treatment = total(Treat_Tract), by(County)
	egen TOT_Control = total(Control_Tract), by(County)
	
	gen instrument = TOT_Treatment / (TOT_Treatment + TOT_Control)
	drop if instrument==.
	
	/*
	
	647 obs where instrument is missing -- these are whole counties where 
	   the tracts never fall in the RD score range we need 
	   
	   These counties are excluded from the sample because they are off the 
	   threshold we need to argue exogneity
	   
	*/
	
	egen TOT_funding_treated = sum(TotalProgramGGRFFunding) if CES20Score > 32.66230828250767 & CES20Score <= 36.522308282507666, by(County)
	egen TOT_funding_control = sum(TotalProgramGGRFFunding) if inrange(CES20Score, 28.802308282507667, 32.66230828250767), by(County)
	egen TOT_funding = sum(TotalProgramGGRFFunding), by(County) // total funds rec'd by each county
	
	// FIRST STAGE:
	reg TOT_funding instrument 
	
	/*
	
	
      Source |       SS           df       MS      Number of obs   =    16,259
-------------+----------------------------------   F(1, 16257)     =     36.86
       Model |  8.9343e+15         1  8.9343e+15   Prob > F        =    0.0000
    Residual |  3.9400e+18    16,257  2.4236e+14   R-squared       =    0.0023
-------------+----------------------------------   Adj R-squared   =    0.0022
       Total |  3.9490e+18    16,258  2.4289e+14   Root MSE        =    1.6e+07

------------------------------------------------------------------------------
 TOT_funding | Coefficient  Std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |    5044158   830784.6     6.07   0.000      3415729     6672587
       _cons |   1.51e+07   378016.1    39.91   0.000     1.43e+07    1.58e+07
------------------------------------------------------------------------------
	
	*/
	