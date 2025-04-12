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
	
********************************************************************************

	do "$dodir/1_import_pre_process.do"
