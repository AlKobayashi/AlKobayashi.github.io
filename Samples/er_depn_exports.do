/*
Requested output:
Construct foreign demand for Sweden
imports of sweden's trade partners weighted by partner's share in swed exports.

source: chrome-extension://efaidnbmnnnibpcajpcglclefindmkaj/https://www.ecb.europa.eu/pub/pdf/other/mb201111_focus06.en.pdf

MAC: https://darwin.escb.eu/livelink/livelink/fetchcsui/2000/8774247/97984055/97983176/98310443/9459270/9459394/9459832/1763304616/1763304633/1763304636/1763304649/2023%2D12%2D14_Macroeconomic_Assessment_Chapter_%28MAC%29_EB.pdf?nodeid=1767517795&vernum=-2 p.11

*/
********************** IMPORT DATA *************************
clear all 

set more off

global raw_data_trade "P:\ECB business areas\DGE\DED\Monitoring and Analysis\07. Trade (EES)\Trade assessment\TDM\Clean TDM values"

global path "\\GIMECB01\HOMEDIR-IL$\kobayas\LP_ER"

global conversion "\\gimecb01\Data\ECB business areas\DGE\DED\Monitoring and Analysis\07. Trade (EES)\Conversion"

cd "$path"


**************** CLEAN DATA: SELECT YEARS ***********************

use "${raw_data_trade}\TDM_I_value_25-06.dta", clear
drop if year <2000

**************** CLEAN DATA: KEEP CHN AS EXPORTER ******************
/* Reporter = importer, partner = exporter

We want EA = reporter
China = partner
*/

keep if ptn_iso3 == "SWE"

label variable rpt_iso3 "Importer"
label variable ptn_iso3 "Exporter"


* Generate total exports by year and month but keep all data
bysort year month: egen total_exports = total(value)

gen destinationsshare = value / total_exports //in decimals. multiply by 100 for %


********** WIEGHTED AVG

* Step 1: create weighted value
gen weighted_export = value * destinationsshare

* Step 2: sum weighted values per year-month
bysort year month: egen weighted_avg = total(weighted_export)

rename weighted_avg Fod

keep year month Fod
duplicates drop
*********************************** SAVE IN EXCEL ******************************

export excel using "$path\LP_ER.xlsx", sheet("Foreign demand") sheetmodify firstrow(variables)

******************************************************************************

import excel "LP_ER.xlsx", sheet("data") firstrow clear

// impact of NEER on exp_i where i is a member of {TTT,CAP,COM,CON, INT}. NEER on exp
// impact of USDSEK on -\\-


foreach var of varlist expTTT expCAP expCOM expCON expINT NEER REER Releffprice USDSEK Fod {
    gen log_`var' = log(`var')
}

tsset Date

lpirf log_expTTT log_NEER log_Releffprice log_USDSEK log_Fod, step(12) lags(1/4)
lpirf log_expTTT log_NEER log_Releffprice log_USDSEK log_Fod, step(12) lags(1/12)

// heterog effects of ER depn on exports for different export industries
lpirf log_expCAP log_NEER log_Releffprice log_USDSEK log_Fod, step(12) lags(1/12)
lpirf log_expCOM log_NEER log_Releffprice log_USDSEK log_Fod, step(12) lags(1/12)
lpirf log_expCON log_NEER log_Releffprice log_USDSEK log_Fod, step(12) lags(1/12)
lpirf log_expINT log_NEER log_Releffprice log_USDSEK log_Fod, step(12) lags(1/12)




