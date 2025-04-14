/*==============================================================================
									MASTER
==============================================================================*/	


	* SET TO PATH ON YOUR MACHINE WHERE REPLICATION PACKAGE DATA IS SAVED 

	global workingdir "/Users/eshavaze/Dropbox/replication_package_494"
	di "$workingdir"
	
	* SET TO PATH ON YOUR MACHINE WHERE REPLICATION PACKAGE DOFILES ARE SAVED
	
	global dodir "/Users/eshavaze/cap_and_trade/replication_package_494_do"
	di "$dodir"
	
	
********************************************************************************
	
	* raw input dir
	global raw_input_data "$workingdir/0_raw_input"
	di "$raw_input_data"

	* intermediate processed data 
	global intermediate_data "$workingdir/1_intermediate"
	di "$intermediate_data"
	
	
	* final datasets
	global final_data "$workingdir/2_final"
	di "$final_data"

	* tables 
	global tables "$workingdir/3_tables"
	di "$tables"
	
********************************************************************************

	// DATA PROCESSING FILES 
	//include "$dodir/1_import_pre_process.do" // troubleshoot later
	
	//ballot data 
	include "$dodir/2_ballot_imports/2_0_2012_ballot.do"
	include "$dodir/2_ballot_imports/2_0_2014_ballot.do"
	include "$dodir/2_ballot_imports/2_1_2016_ballot.do"
	include "$dodir/2_ballot_imports/2_2_2018_ballot.do"
	include "$dodir/2_ballot_imports/2_3_2020_ballot.do"
	include "$dodir/2_ballot_imports/2_4_2022_ballot.do"
	include "$dodir/2_ballot_imports/2_5_voter_particpation.do"
	
	// include "$dodir/3_process_covariates.do" // troubleshoot loop path
	// include "$dodir/4_merge_covariates_with_outcomes.do"

	
	// DATA ANALYSIS FILES 
	include "$dodir/5_FS_2SLS.do"
