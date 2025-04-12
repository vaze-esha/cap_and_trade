/*==============================================================================
									MASTER
==============================================================================*/	


	* SET TO PATH ON YOUR MACHINE WHERE REPLICATION PACKAGE DATA IS SAVED 

	local workingdir "/Users/eshavaze/Dropbox/replication_package_494"
	
	
	* SET TO PATH ON YOUR MACHINE WHERE REPLICATION PACKAGE DOFILES ARE SAVED
	
	local dodir "/Users/eshavaze/cap_and_trade/replication_package_494_do"
	
	
********************************************************************************
	
	
	
	* raw input dir
	local raw_input_data "`workingdir'/0_raw_input"
	di "`raw_input_data'"

	* intermediate processed data 
	local output_data "`workingdir'/1_intermediate"
	di "`intermediate_data'"
	
********************************************************************************

	do "`dodir'/1_import_pre_process.do"
