/*==============================================================================
							2_merge_2018.do
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

	use "`output_data'/cci_yearly/cci_2018.dta"
	
	duplicates tag CensusTract, gen(dup)
	tab dup
