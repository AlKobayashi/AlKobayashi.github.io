/*
Requested output:
Produce a contribution chart of the euro area imports from China (in value), distinguishing between intermediate, consumption, capital goods, and others, monthly frequency, Jan 2024-latest data available, index dec 2024=0 (but no smoothing 3mma). 
To do this, you will need TDM data, and use the correspondence table HS2022-BEC.


Compute value weights for each category c.
Compute value growth rates relative to Dec 24 values for each category c.
Compute weighted growth rates = value growth rates * Dec 24 share, for each category c.

*/


********************** IMPORT DATA *************************
clear all 

set more off

global raw_data_trade "P:\Path\TDM\Clean TDM values"

global path "P:\Path\07-2025\EA import from CN by categ\Cleaned dta"

global conversion "P:\Path\Conversion"

cd "$path"


**************** CLEAN DATA: SELECT YEARS ***********************

use "${raw_data_trade}\TDM_I_value_25-06.dta", clear
drop if year <2023

**************** CLEAN DATA: KEEP CHN AS EXPORTER ******************
/* Reporter = importer, partner = exporter

We want EA = reporter
China = partner
*/

keep if ptn_iso3 == "CHN"

label variable rpt_iso3 "Importer"
label variable ptn_iso3 "Exporter"
rename commodity HS6

************** CLEAN DATA: KEEP EA20 AS IMPORTER **************
keep if rpt_EA_fix==1

*********************************** COLLAPSE DATA ******************************

collapse (sum) value, by(year month HS6) 

save EA_I_CHN, replace

// Now we have EA20 imports from CHN for all HS66.

************************ CONVERT HS2022 TO BEC5 *********************///////////

//Now we need to match HS6 codes at HS2022 level with BEC5. Noemie's lines:

use EA_I_CHN,clear

/*check aggregare
collapse (sum) value, by(year month) 
gen Dec2024bis=value if month==12 & year==2024
egen Dec2024=max(Dec2024bis)
gen value_index=(value-Dec2024)/Dec2024
*/



rename HS6 FromHS22
merge m:1 FromHS22 using "$conversion/FromHS22_ToBEC5.dta"
drop if _merge==2
drop FromHS22
rename ToBEC5 BEC5
keep if _merge ==3 //keep only matched products

******************** CREATE OTHER CATEGORY *******************************
sort year month EndUse
replace EndUse = "Other" if EndUse == ""
tab EndUse

/*
     EndUse |      Freq.     Percent        Cum.
------------+-----------------------------------
        CAP |     10,938       15.09       15.09
       CONS |     17,493       24.14       39.23
        INT |     43,971       60.68       99.91
      Other |         62        0.09      100.00
------------+-----------------------------------
      Total |     72,464      100.00

*/

drop _merge

save "EA_I_CHN_BEC5.dta",replace

************************** PERFORM COMPUTATIONS ********************************
*********************************************************************///////////

use "EA_I_CHN_BEC5.dta",clear

collapse(sum) value, by(year month EndUse) 

/*

*************************** 3mma  ******************************
sort year month
egen time=group(year month)
egen id=group(EndUse)
xtset id time 

gen value_3mma=(value+l.value+l2.value)/3
drop if year<2024
drop value
rename value_3mma value
drop id time

*/


/*check aggregare
collapse (sum) value, by(year month) 
gen Dec2024bis=value if month==12 & year==2024
egen Dec2024=max(Dec2024bis)
gen value_index=(value-Dec2024)/Dec2024
*/

egen value_tot = total(value), by(year month)

reshape wide value, i(year month) j(EndUse) string


*************************** CREATE VALUE WEIGHTS  ******************************

ds value* // Collect variables starting with "value"
local value_vars r(varlist)' 

//compute growths
foreach var of local value_vars { // Loop over each "value" variable
    // Extract the suffix of the variable name (e.g., "CAP" from "valueCAP")
    local suffix = substr("var'", 6, .) // Get everything after "value"

    // Create the share variable for each "valuei"
    gen share_suffix' = (var' / value_tot)
}


******************* COMPUTE M-O-M GROWTH RATES REL. TO DEC 24 ******************

* Step 1: Create a temporary dataset with Dec 2024 values
preserve
keep if year == 2024 & month == 12

* Save Dec 2024 values in locals
foreach var of varlist value* {
    scalar val_var' = var'[1]
}
restore

* Step 2: Loop through value* variables and compute growth rates
foreach var of varlist value* {
    gen var'_growth = (var' / scalar(val_var') - 1)*100
}
**************** COMPUTE WEIGHTED GROWTH RATES: WEIGHT = DEC 24 SHARE **********
* ---------- CAP---------
preserve
keep if year == 2024 & month == 12

quietly {
    gen byte _flag = 1  // just to have something to summarize if needed
    summarize share_CAP if _flag == 1, meanonly
    scalar shareCAP_dec2024 = r(mean)
}
restore

* Step 2: Now compute the weighted rate
gen CAP_weighted_rate = valueCAP_growth * shareCAP_dec2024


* ---------- INT ----------
preserve
keep if year == 2024 & month == 12
quietly {
    summarize share_INT, meanonly
    scalar shareINT_dec2024 = r(mean)
}
restore
gen INT_weighted_rate = valueINT_growth * shareINT_dec2024

* ---------- CONS ----------
preserve
keep if year == 2024 & month == 12
quietly {
    summarize share_CONS, meanonly
    scalar shareCONS_dec2024 = r(mean)
}
restore
gen CONS_weighted_rate = valueCONS_growth * shareCONS_dec2024

* ---------- Other ----------
preserve
keep if year == 2024 & month == 12
quietly {
    summarize share_Other, meanonly
    scalar shareOther_dec2024 = r(mean)
}
restore
gen Other_weighted_rate = valueOther_growth * shareOther_dec2024


// Create a single date variable.
gen str7 Date = string(year) + "-" + string(month, "%02.0f")
order Date, first


************************************ DONE *******************************
**********************************************************************
* OPTIONAL CLEANING

keep Date Other_weighted_rate CONS_weighted_rate INT_weighted_rate CAP_weighted_rate value_tot_growth

rename Other_weighted_rate Other 
rename CONS_weighted_rate Consumption
rename INT_weighted_rate Intermediate
rename CAP_weighted_rate Capital
rename value_tot_growth Total



* SAVE IN EXCEL
export excel using "P:\path\EA_I_CHN_BEC5.xlsx", sheet("Data from stata 3mma") sheetmodify firstrow(variables)
