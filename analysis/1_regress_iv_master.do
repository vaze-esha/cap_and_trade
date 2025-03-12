/*==============================================================================
							1_regress_iv_master.do
================================================================================

	PURPOSE:
	
		1. run first stage and reduced from regressions for all years 
		
		check the tracts for zero instrument values -- is it just once tract? 
		that is driving this?
		varible number of zeros -- what counties are zero always?
			this means there are control tracts 
			but no treated tracts 
			what should i do about these logically?
			
		
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
	
	// working directory dropbox 
	local workingdir "/Users/eshavaze/Dropbox/cal_cap_and_trade"
	
	// input 
	local input_data "`workingdir'/2_processing/cci_instrument_funding"
	
	// output
	local output_data "`workingdir'/2_processing/cci_instrument_funding"

	
/*============================================================================*/
		
								// RUNNING FILES 
		
/*============================================================================*/

			
	// 2015 
	use "`input_data'/2015.dta"
	
	// keep first instance of dups
	duplicates drop County TOT_funding Total_GGRF_Treatment_tracts Total_GGRF_Control_tracts instrument, force
	
	
	// merge with covariates 
	merge 1:1 County using "`workingdir'/2_processing/covariates/covariates_2015.dta"
	drop if _merge==2
	drop _merge
	
	count if instrument==0
	tab County if instrument==0
	// 10
	
	/*
	
								 County |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                 Colusa |          1       10.00       10.00
                               Monterey |          1       10.00       20.00
                                 Nevada |          1       10.00       30.00
                             San Benito |          1       10.00       40.00
                              San Mateo |          1       10.00       50.00
                             Santa Cruz |          1       10.00       60.00
                                 Shasta |          1       10.00       70.00
                                 Solano |          1       10.00       80.00
                                 Sutter |          1       10.00       90.00
                                   Yolo |          1       10.00      100.00
----------------------------------------+-----------------------------------
                                  Total |         10      100.00

	*/


	/*
	
	
							ADDING CONTROLS:
								RACE [non-white only]
								HH INCOME 
								EDUCATION

	*/
	
	rename totals_races TOTAL_POPULATION
	destring TOTAL_POPULATION, replace
	

	// proportion non white:
	
	// destring vars 
	foreach var in DRIVE_ALONE CARPOOLED TRANSIT_TO_WORK WALK_TO_WORK ///
                OTHER_TRANSPORT WFH MEDIAN_HH_INCOME TOTAL_POPULATION ///
                total_white total_black total_american_india_alaskan ///
                total_asians total_hawaaian_pacific_islander ///
                total_other_race total_mixed LESS_THAN_HS ///
                SOME_COLLEGE_OR_ASSOCIATES BACHELORS_OR_HIGHER ///
                LESS_THAN_9TH_GRADE NINTH_TO_12TH_NO_DIPLOMA ///
                HS_GRADUATE SOME_COLLEGE_NO_DEGREE ASSOCIATES_DEGREE ///
                BACHELORS_DEGREE GRADUATE_OR_PROFESSIONAL_DEGREE ///
                POP_25_TO_34 POP_35_TO_44 POP_45_TO_64 POP_65_PLUS ///
                total_homeowners_renters total_homeowners total_renters {
    destring `var', replace
}

	// race props
	gen total_nonwhite = total_black + total_american_india_alaskan + total_asians ///
                     + total_hawaaian_pacific_islander + total_other_race + total_mixed

	gen prop_nonwhite = total_nonwhite / (total_white + total_nonwhite)

	// edu props
	gen less_than_college = LESS_THAN_9TH_GRADE + NINTH_TO_12TH_NO_DIPLOMA + ///
                        HS_GRADUATE + SOME_COLLEGE_NO_DEGREE

	gen prop_less_educated = less_than_college / TOTAL_POPULATION
	gen prop_high_educated = 1 - prop_less_educated

	// transportation 
	gen prop_transit_carpool = (TRANSIT_TO_WORK + CARPOOLED) / (DRIVE_ALONE + CARPOOLED + TRANSIT_TO_WORK + WALK_TO_WORK + OTHER_TRANSPORT + WFH)

	// logged 
	gen log_funding = log(TOT_funding)
	gen log_control_funding = log(Total_GGRF_Control_tracts)
	gen log_treated_funding = log(Total_GGRF_Treatment_tracts)
	
	reg log_funding instrument, cluster(County)
	/*
Linear regression                               Number of obs     =         31
                                                F(1, 30)          =       4.12
                                                Prob > F          =     0.0513
                                                R-squared         =     0.1105
                                                Root MSE          =     1.4396

                                (Std. err. adjusted for 31 clusters in County)
------------------------------------------------------------------------------
             |               Robust
 log_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |   1.622276    .799127     2.03   0.051    -.0097595    3.254311
       _cons |   14.36721   .3460747    41.51   0.000     13.66043    15.07399
------------------------------------------------------------------------------


*/
	// add some controls 
	reg log_funding instrument MEDIAN_HH_INCOME, cluster(County)
	/*

Linear regression                               Number of obs     =         28
                                                F(2, 27)          =      12.44
                                                Prob > F          =     0.0001
                                                R-squared         =     0.3540
                                                Root MSE          =     1.1655

                                    (Std. err. adjusted for 28 clusters in County)
----------------------------------------------------------------------------------
                 |               Robust
     log_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-----------------+----------------------------------------------------------------
      instrument |   1.456957   .6155967     2.37   0.025     .1938571    2.720058
MEDIAN_HH_INCOME |   .0000453   .0000117     3.86   0.001     .0000212    .0000694
           _cons |   11.75235   .8342781    14.09   0.000     10.04056    13.46415
----------------------------------------------------------------------------------


	*/
	reg log_funding instrument MEDIAN_HH_INCOME prop_less_educated, cluster(County)
	/*
Linear regression                               Number of obs     =         28
                                                F(3, 27)          =       8.19
                                                Prob > F          =     0.0005
                                                R-squared         =     0.3798
                                                Root MSE          =     1.1655

                                      (Std. err. adjusted for 28 clusters in County)
------------------------------------------------------------------------------------
                   |               Robust
       log_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------------+----------------------------------------------------------------
        instrument |   1.610601    .647997     2.49   0.019     .2810213    2.940181
  MEDIAN_HH_INCOME |   .0000251   .0000193     1.30   0.203    -.0000144    .0000646
prop_less_educated |  -7.488329   6.078802    -1.23   0.229      -19.961    4.984343
             _cons |   15.97127   3.507139     4.55   0.000     8.775214    23.16732
------------------------------------------------------------------------------------

	*/
	
	// add all controls 
	reg log_funding instrument MEDIAN_HH_INCOME prop_nonwhite prop_less_educated, cluster(County)

	/*
	Linear regression                               Number of obs     =         28
                                                F(4, 27)          =       7.55
                                                Prob > F          =     0.0003
                                                R-squared         =     0.4060
                                                Root MSE          =     1.1652

                                      (Std. err. adjusted for 28 clusters in County)
------------------------------------------------------------------------------------
                   |               Robust
       log_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------------+----------------------------------------------------------------
        instrument |   1.392697   .6526655     2.13   0.042     .0535376    2.731855
  MEDIAN_HH_INCOME |   .0000176   .0000215     0.82   0.421    -.0000266    .0000618
     prop_nonwhite |   2.243806    1.86148     1.21   0.239    -1.575634    6.063247
prop_less_educated |  -6.828993   6.394698    -1.07   0.295    -19.94983    6.291843
             _cons |   15.49007   3.662843     4.23   0.000     7.974536     23.0056
------------------------------------------------------------------------------------

	*/
	
	// add transit controls 
	reg log_funding instrument MEDIAN_HH_INCOME prop_nonwhite prop_less_educated prop_transit_carpool, cluster(County)
	
	/*
	
	Linear regression                               Number of obs     =         28
                                                F(5, 27)          =       7.84
                                                Prob > F          =     0.0001
                                                R-squared         =     0.4200
                                                Root MSE          =     1.1772

                                        (Std. err. adjusted for 28 clusters in County)
--------------------------------------------------------------------------------------
                     |               Robust
         log_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
---------------------+----------------------------------------------------------------
          instrument |   1.410856   .6664015     2.12   0.044     .0435136    2.778199
    MEDIAN_HH_INCOME |   .0000205    .000022     0.93   0.359    -.0000246    .0000655
       prop_nonwhite |   3.038219    2.23827     1.36   0.186    -1.554332     7.63077
  prop_less_educated |  -7.341339   6.809727    -1.08   0.291    -21.31374    6.631067
prop_transit_carpool |  -3.553786    3.49553    -1.02   0.318    -10.72602     3.61845
               _cons |   15.76288    3.97132     3.97   0.000     7.614406    23.91136
--------------------------------------------------------------------------------------
*/
	

	
	/*
	
	
								SUB-SAMPLE REGRESSIONS 
	
	
	*/
	
	reg log_treated_funding instrument, cluster(County)
	/*
	
	
Linear regression                               Number of obs     =         21
                                                F(1, 20)          =       0.04
                                                Prob > F          =     0.8447
                                                R-squared         =     0.0035
                                                Root MSE          =     2.0925

                                (Std. err. adjusted for 21 clusters in County)
------------------------------------------------------------------------------
             |               Robust
log_treate~g | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |   .6188319   3.118125     0.20   0.845    -5.885464    7.123127
       _cons |   10.51356   1.803898     5.83   0.000     6.750696    14.27643
------------------------------------------------------------------------------
*/
	reg log_treated_funding instrument MEDIAN_HH_INCOME prop_nonwhite prop_less_educated prop_transit_carpool, cluster(County)
/*
Linear regression                               Number of obs     =         20
                                                F(5, 19)          =       2.94
                                                Prob > F          =     0.0394
                                                R-squared         =     0.4271
                                                Root MSE          =     1.7383

                                        (Std. err. adjusted for 20 clusters in County)
--------------------------------------------------------------------------------------
                     |               Robust
 log_treated_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
---------------------+----------------------------------------------------------------
          instrument |  -2.150759   2.991837    -0.72   0.481    -8.412747    4.111229
    MEDIAN_HH_INCOME |  -5.93e-06   .0000473    -0.13   0.901    -.0001049     .000093
       prop_nonwhite |   10.06833   4.668381     2.16   0.044     .2972987    19.83936
  prop_less_educated |    8.22926   16.53771     0.50   0.624    -26.38457    42.84309
prop_transit_carpool |  -19.09921   5.261332    -3.63   0.002    -30.11131    -8.08712
               _cons |    8.56053   8.695203     0.98   0.337     -9.63874     26.7598
--------------------------------------------------------------------------------------
*/


	reg log_control_funding instrument, cluster(County)
	/*
	Linear regression                               Number of obs     =         29
                                                F(1, 28)          =       8.36
                                                Prob > F          =     0.0073
                                                R-squared         =     0.2182
                                                Root MSE          =     1.8249

                                (Std. err. adjusted for 29 clusters in County)
------------------------------------------------------------------------------
             |               Robust
log_contro~g | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |   3.540182    1.22406     2.89   0.007     1.032809    6.047555
       _cons |   9.076751   .4382394    20.71   0.000     8.179058    9.974444
------------------------------------------------------------------------------
*/
	
	
	reg log_control_funding instrument MEDIAN_HH_INCOME prop_nonwhite prop_less_educated prop_transit_carpool, cluster(County)
	
/*

Linear regression                               Number of obs     =         26
                                                F(5, 25)          =       2.47
                                                Prob > F          =     0.0594
                                                R-squared         =     0.2943
                                                Root MSE          =     1.8903

                                        (Std. err. adjusted for 26 clusters in County)
--------------------------------------------------------------------------------------
                     |               Robust
 log_control_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
---------------------+----------------------------------------------------------------
          instrument |    2.81284   1.370805     2.05   0.051     -.010385    5.636065
    MEDIAN_HH_INCOME |   .0000421   .0000285     1.48   0.152    -.0000166    .0001007
       prop_nonwhite |   4.634809   4.334135     1.07   0.295    -4.291509    13.56113
  prop_less_educated |   5.570669   9.017684     0.62   0.542     -13.0016    24.14294
prop_transit_carpool |  -11.11587   6.869272    -1.62   0.118     -25.2634    3.031658
               _cons |   4.612144   5.002192     0.92   0.365    -5.690063    14.91435
--------------------------------------------------------------------------------------
*/
	

	