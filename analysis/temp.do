	
	// working directory dropbox 
	local workingdir "/Users/eshavaze/Dropbox/cal_cap_and_trade"
	
	// input 
	local input_data "`workingdir'/2_processing/final_datasets"
	
	// output
	local outputs "`workingdir'/3_output/tables"

*
* Initialize the table by clearing previous results
cap erase `outputs'

* Loop over years from 2015 to 2022
local years 2015 2016 2017 2018 2019 2020 2021 2022

foreach yr of local years {
    * Load data for the given year
    use "`input_data'/`yr'.dta", clear
    
    * Run the regression
    reg log_funding instrument, cluster(County)

    * Append results to LaTeX table
    outreg2 using `outputs', append label tex(frag) ///
        title("First Stage (Full Sample) Results") ///
        addnote("Standard errors clustered at County level. CES version 2")
}

* Notify that the process is complete
di "Regression results saved in `outputs'"



