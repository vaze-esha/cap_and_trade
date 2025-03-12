	
	// working directory dropbox 
	local workingdir "/Users/eshavaze/Dropbox/cal_cap_and_trade"
	
	// input 
	local input_data "`workingdir'/2_processing/cci_instrument_funding"
	
	// output
	local outputs "`workingdir'/3_output/tables"

	
	
	// Load data
		use "`input_data'/`year'.dta", clear
		
		keep if CESVersion==2
		// Drop duplicates
		duplicates drop County TOT_funding instrument, force

		// Merge with covariates
		merge 1:1 County using "`workingdir'/2_processing/covariates/covariates_`year'.dta"
		drop if _merge == 2
		drop _merge

		// Create key variables
		rename totals_races TOTAL_POPULATION
		replace TOTAL_POPULATION = "." if regexm(TOTAL_POPULATION, "[^0-9.]")
		destring TOTAL_POPULATION, replace
		
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
		tostring `var', replace
		replace `var' = "." if regexm(`var', "[^0-9.]")
		destring `var', replace
		}
		
		gen total_nonwhite = total_black + total_american_india_alaskan + total_asians ///
						  + total_hawaaian_pacific_islander + total_other_race + total_mixed
		gen prop_nonwhite = total_nonwhite / (total_white + total_nonwhite)
		
		gen less_than_college = LESS_THAN_9TH_GRADE + NINTH_TO_12TH_NO_DIPLOMA + ///
							 HS_GRADUATE + SOME_COLLEGE_NO_DEGREE
		gen prop_less_educated = less_than_college / TOTAL_POPULATION
		gen prop_high_educated = 1 - prop_less_educated

		gen prop_transit_carpool = (TRANSIT_TO_WORK + CARPOOLED) / ///
								 (DRIVE_ALONE + CARPOOLED + TRANSIT_TO_WORK + ///
								 WALK_TO_WORK + OTHER_TRANSPORT + WFH)

		gen log_funding = log(TOT_funding)
		
		// Set variable labels for clearer table output
		label variable log_funding "Log(Total GGRF Funding)"
		label variable instrument "Z"
		label variable MEDIAN_HH_INCOME "Median Household Income"
		label variable prop_nonwhite "Proportion Nonwhite"
		label variable prop_less_educated "Proportion Less Educated"
		label variable prop_transit_carpool "Proportion Using Transit/Carpool"


		// Full sample regressions (Stepwise Inclusion of Controls)
		
		reg log_funding instrument, cluster(County)
		outreg2 using "`outputs'/fullsample_fs_reg_`year'.tex", replace label tex(frag) ///
			title("First Stage (Full Sample) `year'") addnote("Standard errors clustered at County level. CES version 2") ///

		reg log_funding instrument MEDIAN_HH_INCOME, cluster(County)
		outreg2 using "`outputs'/fullsample_fs_reg_`year'.tex", append label tex(frag) ///
		keep(instrument) addtext(Median Household Income, YES)

		reg log_funding instrument MEDIAN_HH_INCOME prop_nonwhite, cluster(County)
		outreg2 using "`outputs'/fullsample_fs_reg_`year'.tex", append label tex(frag) ///
		keep(instrument) addtext(Median Household Income, YES, Proportion Non-White, YES)

		reg log_funding instrument MEDIAN_HH_INCOME prop_nonwhite prop_less_educated, cluster(County)
		outreg2 using "`outputs'/fullsample_fs_reg_`year'.tex", append label tex(frag) ///
		keep(instrument) addtext(Median Household Income, YES, Proportion Non-White, YES, Proportion Less Educated, YES)
		
		reg log_funding instrument MEDIAN_HH_INCOME prop_nonwhite prop_less_educated prop_transit_carpool, cluster(County)
		outreg2 using "`outputs'/fullsample_fs_reg_`year'.tex", append label tex(frag) ///
		keep(instrument) addtext(Median Household Income, YES, Proportion Non-White, YES, Proportion Less Educated, YES, Proportion Transit/Carpool, YES)
	