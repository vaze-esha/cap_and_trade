/*==============================================================================
								2018 PLACEBO CHECKS
================================================================================

	PURPOSE:
	
		1. run first stage for all years 
			
		
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
	local input_data "`workingdir'/2_processing"
	
	// output
	local outputs "/Users/eshavaze/Downloads"

	
/*============================================================================*/
	
						// FIRST STAGE REGRESSIONS 
		
/*============================================================================*/
/*
	shp2dta using "/Users/eshavaze/Downloads/ca_counties/CA_Counties.shp", database(counties.dta) coordinates(coords.dta) genid(county_id)

*/

	* Load data
	use "`input_data'/rf_dataset_placebo.dta", clear

	* Prepare panel structure and variables
	encode County, gen(county_id)
	egen max_instrument = max(instrument) if Year == 2018, by(county_id)
	keep if Year != 2018 | instrument == max_instrument
	drop max_instrument

	xtset county_id Year

	bysort County (Year): gen cumulative_funding = sum(TOT_funding)
	gen log_cumulative_funding = log(cumulative_funding)
	egen avg_instrument = mean(instrument), by(County Year)

	* Label variable for nicer output
	label variable log_cumulative_funding "Log(Cumulative Funding)"

	*==============================================================================
	* RUN ALL REGRESSIONS FOR PROP 1 IN 2014 AND OUTPUT TO ONE TABLE
	*==============================================================================

	* OLS
	reg prop_yes_1 log_cumulative_funding, vce(cluster county_id)
	est store ols

	* 2SLS
	ivreg2 prop_yes_1 (log_cumulative_funding = avg_instrument), cluster(county_id)
	est store iv

	* Output all results into one table
	outreg2 [ols iv] using "`outputs'/placebo_table.tex", replace label ///
		title("Placebo Check Regressions for Prop 1 (2014)") ///
		ctitle("OLS" "2SLS")

	display "Table saved to Downloads"
	
	clear 
	
/*============================================================================*/
	
						// TAX MECHANISMS TESTING 
		
/*============================================================================*/


	use "`input_data'/rf_dataset_mechanisms_tax.dta", clear

	encode County, gen(county_id)

	egen max_instrument = max(instrument) if Year == 2018, by(county_id)
	keep if Year != 2018 | instrument == max_instrument
	drop max_instrument

	xtset county_id Year

	bysort County (Year): gen cumulative_funding = sum(TOT_funding)
	gen log_cumulative_funding = log(cumulative_funding)
	egen avg_instrument = mean(instrument), by(County Year)

	* Tax aversion variables already merged in:
	* - tax_averse_score (0 to 5)
	* - high_tax_averse (0/1)

*==============================================================================
			* Run regressions and output each prop as a table
*==============================================================================
local props_2018 69 72

foreach num of local props_2018 {

    * OLS with tax aversion score (continuous 1–4)
    reg prop_yes_`num' log_cumulative_funding i.tax_averse_score, vce(cluster county_id)
    est store ols_prop_`num'

    * 2SLS with tax aversion score
    ivreg2 prop_yes_`num' (log_cumulative_funding = avg_instrument) i.tax_averse_score, partial(i.tax_averse_score) ///
        cluster(county_id)
    est store iv_prop_`num'

    * Export all to one table
    outreg2 [ols_prop_`num' iv_prop_`num'] using ///
        "`outputs'/mechanism_controls_2018_prop`num'.tex", replace label ///
        title("Placebo Regressions for Prop `num' (2018) with Tax Aversion Controls") 

    display "Saved: Prop `num'"


}
	label variable log_cumulative_funding "Log(Cumulative Funding)"
	coefplot ///
    (ols_prop_69, label("OLS: Prop 69 ")) ///
    (iv_prop_69, label("2SLS: Prop 69 ")) ///
    (ols_prop_72, label("OLS: Prop 72 ")) ///
    (iv_prop_72, label("2SLS: Prop 72")), ///
    vert ///
    title("Testing for Tax Aversion") ///
    xlabel(, angle(360) grid) ///
    ylabel(, grid) ///
    drop(_cons) ///
    keep(log_cumulative_funding) ///
    xline(0) ///
	yline(0)

	graph export "`outputs'/mech_plot.png", replace
	