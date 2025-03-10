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
	
	preserve 
	
	// keep first instance of dups
	duplicates drop County TOT_funding instrument, force
	
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
	
	reg TOT_funding instrument, cluster(County) 
	
	/*
		
	Linear regression                               Number of obs     =         31
													F(1, 30)          =       3.61
													Prob > F          =     0.0672
													R-squared         =     0.0587
													Root MSE          =     1.1e+07

									(Std. err. adjusted for 31 clusters in County)
	------------------------------------------------------------------------------
				 |               Robust
	 TOT_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
	-------------+----------------------------------------------------------------
	  instrument |    8526736    4489725     1.90   0.067    -642506.7    1.77e+07
		   _cons |    4401223    1424196     3.09   0.004      1492626     7309819
	------------------------------------------------------------------------------
	*/
	
	// now let's exclude the zeroes and see what happens 
	drop if instrument==0
	reg TOT_funding instrument, cluster(County) 
	
	/*
	
	Linear regression                               Number of obs     =         21
                                                F(1, 20)          =       1.33
                                                Prob > F          =     0.2631
                                                R-squared         =     0.0155
                                                Root MSE          =     1.3e+07

                                (Std. err. adjusted for 21 clusters in County)
------------------------------------------------------------------------------
             |               Robust
 TOT_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |   -7815091    6786219    -1.15   0.263    -2.20e+07     6340714
       _cons |   1.45e+07    5576318     2.60   0.017      2884570    2.61e+07
------------------------------------------------------------------------------
*/

	// reuslts worsen -- this means that these counties get a lot of funding, even 
		// though they have no treated tracts 
	
	restore 
	
	
	// 2016 
	use "`input_data'/2016.dta"
	
	preserve 
	
	// keep first instance of dups
	duplicates drop County TOT_funding instrument, force
	
	reg TOT_funding instrument, cluster(County) 
		
	count if instrument==0
	//10 
	tab County if instrument==0
	
	/*
	
								 County |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                 Colusa |          1       10.00       10.00
                                 Madera |          1       10.00       20.00
                                 Merced |          1       10.00       30.00
                                 Nevada |          1       10.00       40.00
                                 Placer |          1       10.00       50.00
                          Santa Barbara |          1       10.00       60.00
                             Santa Cruz |          1       10.00       70.00
                                 Shasta |          1       10.00       80.00
                                 Tehama |          1       10.00       90.00
                                   Yolo |          1       10.00      100.00
----------------------------------------+-----------------------------------
                                  Total |         10      100.00

*/
	
	
	/*
	
	Linear regression                           Number of obs     =         33
                                                F(1, 31)          =       2.30
                                                Prob > F          =     0.1397
                                                R-squared         =     0.0444
                                                Root MSE          =     3.7e+07

                                (Std. err. adjusted for 32 clusters in County)
------------------------------------------------------------------------------
             |               Robust
 TOT_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |   2.79e+07   1.84e+07     1.52   0.140     -9658392    6.55e+07
       _cons |    8848045    4618418     1.92   0.065      -571282    1.83e+07
------------------------------------------------------------------------------
	*/
	
	restore 
	
	
	// 2017
	use "`input_data'/2017.dta"
	preserve 
	
	// keep first instance of dups
	duplicates drop County TOT_funding instrument, force
	
	reg TOT_funding instrument, cluster(County) 
	
	count if instrument==0
	//10 
	tab County if instrument==0
	
	/*
								 County |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                 Colusa |          1       10.00       10.00
                                 Madera |          1       10.00       20.00
                                  Marin |          1       10.00       30.00
                               Monterey |          1       10.00       40.00
                                 Nevada |          1       10.00       50.00
                             San Benito |          1       10.00       60.00
                              San Mateo |          1       10.00       70.00
                                 Solano |          1       10.00       80.00
                                Ventura |          1       10.00       90.00
                                   Yuba |          1       10.00      100.00
----------------------------------------+-----------------------------------
                                  Total |         10      100.00

	
	
	*/
	
	/*
	
	Linear regression                           Number of obs     =         51
                                                F(1, 32)          =      14.31
                                                Prob > F          =     0.0006
                                                R-squared         =     0.1543
                                                Root MSE          =     2.0e+07

                                (Std. err. adjusted for 33 clusters in County)
------------------------------------------------------------------------------
             |               Robust
 TOT_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |   3.19e+07    8444429     3.78   0.001     1.47e+07    4.91e+07
       _cons |    5069723    2511101     2.02   0.052    -45223.22    1.02e+07
------------------------------------------------------------------------------


	*/
	
	restore 
	
	
	// 2018
	use "`input_data'/2018.dta"
	preserve 
	
	// keep first instance of dups
	duplicates drop County TOT_funding instrument, force
	
	count if instrument==0
	//11
	tab County if instrument==0
	/*
								 County |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                  Butte |          1        9.09        9.09
                                 Colusa |          1        9.09       18.18
                                  Glenn |          1        9.09       27.27
                               Imperial |          1        9.09       36.36
                                   Napa |          1        9.09       45.45
                                 Placer |          1        9.09       54.55
                             San Benito |          1        9.09       63.64
                          Santa Barbara |          1        9.09       72.73
                                 Sonoma |          1        9.09       81.82
                                 Tehama |          1        9.09       90.91
                                   Yolo |          1        9.09      100.00
----------------------------------------+-----------------------------------
                                  Total |         11      100.00
	
	*/
	
	reg TOT_funding instrument, cluster(County) 
	
	
	/*
	
	
Linear regression                               Number of obs     =         56
                                                F(1, 34)          =       0.92
                                                Prob > F          =     0.3445
                                                R-squared         =     0.0059
                                                Root MSE          =     5.3e+07

                                (Std. err. adjusted for 35 clusters in County)
------------------------------------------------------------------------------
             |               Robust
 TOT_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |   1.33e+07   1.39e+07     0.96   0.345    -1.49e+07    4.14e+07
       _cons |   2.88e+07    9968835     2.89   0.007      8576998    4.91e+07
------------------------------------------------------------------------------

	*/
	
	restore 
	
	// 2019
	use "`input_data'/2019.dta"
	preserve 
	
	// keep first instance of dups
	duplicates drop County TOT_funding instrument, force
	
	count if instrument==0
	//12
	tab County if instrument==0
	
	/*
								 County |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                  Butte |          1        8.33        8.33
                                  Marin |          1        8.33       16.67
                                   Napa |          1        8.33       25.00
                                 Nevada |          1        8.33       33.33
                              Riverside |          1        8.33       41.67
                             San Benito |          1        8.33       50.00
                          San Francisco |          1        8.33       58.33
                          Santa Barbara |          1        8.33       66.67
                             Santa Cruz |          1        8.33       75.00
                                 Sutter |          1        8.33       83.33
                                 Tehama |          1        8.33       91.67
                                   Yolo |          1        8.33      100.00
----------------------------------------+-----------------------------------
                                  Total |         12      100.00
	
	*/
	
	reg TOT_funding instrument, cluster(County) 
	
	/*
	
	
Linear regression                               Number of obs     =         52
                                                F(1, 33)          =       2.12
                                                Prob > F          =     0.1546
                                                R-squared         =     0.0187
                                                Root MSE          =     5.9e+07

                                (Std. err. adjusted for 34 clusters in County)
------------------------------------------------------------------------------
             |               Robust
 TOT_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |   2.61e+07   1.79e+07     1.46   0.155    -1.04e+07    6.26e+07
       _cons |   3.07e+07    9088229     3.38   0.002     1.23e+07    4.92e+07
------------------------------------------------------------------------------



	*/
	
	restore 
	
	
	// 2020
	use "`input_data'/2020.dta"
	preserve 
	
	// keep first instance of dups
	duplicates drop County TOT_funding instrument, force
	
	count if instrument==0
	//11
	tab County if instrument==0
	
	/*
	
	County |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                Alameda |          1        9.09        9.09
                                  Butte |          1        9.09       18.18
                           Contra Costa |          1        9.09       27.27
                                   Napa |          1        9.09       36.36
                             San Benito |          1        9.09       45.45
                          San Francisco |          1        9.09       54.55
                              San Mateo |          1        9.09       63.64
                          Santa Barbara |          1        9.09       72.73
                            Santa Clara |          1        9.09       81.82
                                 Tehama |          1        9.09       90.91
                                   Yolo |          1        9.09      100.00
----------------------------------------+-----------------------------------
                                  Total |         11      100.00
*/
	
	reg TOT_funding instrument, cluster(County) 
	
	/*
	
	
Linear regression                               Number of obs     =         42
                                                F(1, 29)          =       0.01
                                                Prob > F          =     0.9242
                                                R-squared         =     0.0001
                                                Root MSE          =     1.2e+08

                                (Std. err. adjusted for 30 clusters in County)
------------------------------------------------------------------------------
             |               Robust
 TOT_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |    3634249   3.79e+07     0.10   0.924    -7.38e+07    8.11e+07
       _cons |   7.05e+07   2.65e+07     2.66   0.013     1.63e+07    1.25e+08
------------------------------------------------------------------------------



	*/
	
	restore 
	
	
	// 2021
	use "`input_data'/2021.dta"
	preserve 
	
	// keep first instance of dups
	duplicates drop County TOT_funding instrument, force
	
	count if instrument==0
	//9
	tab County if instrument==0
	
	/*
								 County |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                Alameda |          1       11.11       11.11
                                  Butte |          1       11.11       22.22
                           Contra Costa |          1       11.11       33.33
                                  Marin |          1       11.11       44.44
                                   Napa |          1       11.11       55.56
                             San Benito |          1       11.11       66.67
                                 Solano |          1       11.11       77.78
                                Ventura |          1       11.11       88.89
                                   Yolo |          1       11.11      100.00
----------------------------------------+-----------------------------------
                                  Total |          9      100.00

	*/
	
	
	reg TOT_funding instrument, cluster(County) 
	
	/*
	
	
Linear regression                               Number of obs     =         37
                                                F(1, 27)          =       1.07
                                                Prob > F          =     0.3095
                                                R-squared         =     0.0413
                                                Root MSE          =     7.9e+07

                                (Std. err. adjusted for 28 clusters in County)
------------------------------------------------------------------------------
             |               Robust
 TOT_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |   5.87e+07   5.67e+07     1.04   0.310    -5.76e+07    1.75e+08
       _cons |   2.85e+07   1.37e+07     2.09   0.046     496822.1    5.66e+07
------------------------------------------------------------------------------



	*/
	
	restore 
	
	
	
	// 2022
	use "`input_data'/2022.dta"
	preserve 
	
	// keep first instance of dups
	duplicates drop County TOT_funding instrument, force
	
		
	count if instrument==0
	//9
	tab County if instrument==0
	
	/*
	County |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                  Butte |          1       11.11       11.11
                                  Marin |          1       11.11       22.22
                                   Napa |          1       11.11       33.33
                             San Benito |          1       11.11       44.44
                          San Francisco |          1       11.11       55.56
                            San Joaquin |          1       11.11       66.67
                                 Sonoma |          1       11.11       77.78
                                 Sutter |          1       11.11       88.89
                                   Yolo |          1       11.11      100.00
----------------------------------------+-----------------------------------
                                  Total |          9      100.00

	*/
	
	reg TOT_funding instrument, cluster(County) 
	
	/*
	
	
Linear regression                               Number of obs     =         39
                                                F(1, 30)          =       0.01
                                                Prob > F          =     0.9260
                                                R-squared         =     0.0001
                                                Root MSE          =     3.7e+07

                                (Std. err. adjusted for 31 clusters in County)
------------------------------------------------------------------------------
             |               Robust
 TOT_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |    -909722    9706397    -0.09   0.926    -2.07e+07    1.89e+07
       _cons |   3.00e+07   1.06e+07     2.82   0.008      8267418    5.17e+07
------------------------------------------------------------------------------



	*/
	
	restore 
	
	
	// 2023
	use "`input_data'/2023.dta"
	preserve 
	
	// keep first instance of dups
	duplicates drop County TOT_funding instrument, force
	
	count if instrument==0
	//9
	tab County if instrument==0
	
	/*
	                                 County |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                 Fresno |          1       11.11       11.11
                                  Glenn |          1       11.11       22.22
                               Monterey |          1       11.11       33.33
                                   Napa |          1       11.11       44.44
                             San Benito |          1       11.11       55.56
                          San Francisco |          1       11.11       66.67
                          Santa Barbara |          1       11.11       77.78
                                 Tehama |          1       11.11       88.89
                                   Yolo |          1       11.11      100.00
----------------------------------------+-----------------------------------
                                  Total |          9      100.00
*/
	
	
	reg TOT_funding instrument, cluster(County) 
	
	/*
	
	

Linear regression                               Number of obs     =         32
                                                F(1, 27)          =       0.07
                                                Prob > F          =     0.7909
                                                R-squared         =     0.0005
                                                Root MSE          =     7.0e+07

                                (Std. err. adjusted for 28 clusters in County)
------------------------------------------------------------------------------
             |               Robust
 TOT_funding | Coefficient  std. err.      t    P>|t|     [95% conf. interval]
-------------+----------------------------------------------------------------
  instrument |    4698593   1.75e+07     0.27   0.791    -3.13e+07    4.07e+07
       _cons |   3.97e+07   1.81e+07     2.19   0.037      2553943    7.69e+07
------------------------------------------------------------------------------



	*/
	
	restore 
	
	
	