/*==============================================================================
							1_regress_iv_master.do
================================================================================

	PURPOSE:
	
		1. run first stage and reduced from regressions for all years 
		
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
	
	// code 
	local do_dir "/Users/eshavaze/cap_and_trade/analysis"
	
/*============================================================================*/
		
								// RUNNING FILES 
		
/*============================================================================*/

			
	// 2015 
	use "`input_data'/2015.dta"
	
	preserve 
	
	// keep first instance of dups
	duplicates drop County TOT_funding instrument, force
	
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
	
	restore 
	
	// 2016 
	use "`input_data'/2016.dta"
	preserve 
	
	// keep first instance of dups
	duplicates drop County TOT_funding instrument, force
	
	reg TOT_funding instrument, cluster(County) 
	
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
	
	
	
	