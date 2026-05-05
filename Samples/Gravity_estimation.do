**************** RESDM *****************

******************************* new version
clear all
set more off

*global input "C:/Users/akobayashi/OneDrive - International Monetary Fund (PRD)/PPML/input"
*global output "C:/Users/akobayashi/OneDrive - International Monetary Fund (PRD)/PPML/output"
global input "C:\Users\rzymek\OneDrive - International Monetary Fund (PRD)\Kobayashi, Alicja's files - PPML/input"
global output "C:\Users\rzymek\OneDrive - International Monetary Fund (PRD)\Kobayashi, Alicja's files - PPML/output"

*ssc install ppmlhdfe

*/******************************************************************************
TASK: cross sectional PPML estimation (trade flows 2018) 

Use the 2018-2019 ICIO trade data and the FTA dummies across countries to run a cross-sectional gravity regression (using PPML). We need to control for the exporter, importer fixed effects and some standard gravity controls such as distance (CEPII has the gravity variable). 

Merge all three datasets:

a) FTA data: https://www.ewf.uni-bayreuth.de/en/research/RTA-data/index.html

b) Gravity controls: https://www.cepii.fr/CEPII/en/bdd_modele/bdd_modele_item.asp?id=8

c) Trade flows data: George
*/
********************* 1) Merging FTA and gravity controls data *****************
use "$input/FTA.dta", clear
keep if year==2018
drop if exporter=="DDR"|importer=="DDR" //not a state anymore, DDR
drop if exporter=="FXX"|importer=="FXX" //uses France only, FTA
drop if exporter=="YUG"|importer=="YUG" //not a state anymore, FTA
drop if exporter=="ZAR"|importer=="ZAR" //not a state anymore, COD instead
drop if exporter=="ROM"|importer=="ROM" //ROU exists already.
drop if exporter=="TMP"|importer=="TMP" //TLS exists.
drop if exporter=="CSK"|importer=="CSK" //CZE exists.

save "$output/FTA.dta",replace
codebook exporter //273 unique exporters
* vars: exporter, importer, year

use "$input/gravitycontrols.dta", clear
keep if year==2018
* vars: iso3_o, iso3_d, year
* o is origin, d is destination

ren iso3_o exporter
ren iso3_d importer

/*
We need to deal with cases where imp*exp*year are not unique:

year	country_id_o	country_id_d	iso3_o	iso3_d	iso3num_o	iso3num_d	country_exists_o	country_exists_d
2018	ABW	ANT.1	ABW	ANT	533	532	1	0
2019	ABW	ANT.1	ABW	ANT	533	532	1	0
2018	ABW	ANT.2	ABW	ANT	533	530	1	0
2019	ABW	ANT.2	ABW	ANT	533	530	1	0

country_id_o	country_id_d	exporter	importer	iso3num_o	iso3num_d	country_exists_o
ETH.2	ABW	ETH	ABW	231	533	1
ETH.1	ABW	ETH	ABW	230	533	0
ETH.2	ABW	ETH	ABW	231	533	1
ETH.1	ABW	ETH	ABW	230	533	0
*/

drop if country_exists_d==0 //i.e. importer country must exist
drop if country_exists_o==0 //i.e. exporter country must exist
codebook exporter //235 unique exporters

* Merge FTA dataset with gravity controls dataset.
merge 1:1 exporter importer year using "$output/FTA.dta"

/*

    Result                      Number of obs
    -----------------------------------------
    Not matched                        19,304
        from master                         0  (_merge==1)
        from using                     19,304  (_merge==2)

    Matched                            55,225  (_merge==3)
    -----------------------------------------

All pairs in gravity controls data used.
Many pairs in FTA dataset do are not observed in control vars dataset. FTA contains many island states.

*/
keep if _merge==3
drop _merge
codebook exporter //235 unique exporters

save "$output/FTA_controls.dta",replace	

*/* ************************ 2) TRADE FLOWS DATA **********************************
To have the exporter-importer-sector trade flow, please aggregate the final consumption, investment, and intermediate data. 

The intermediate data is country m- sector i->country n, sector j. please aggregate in this way: \sum_j interflow(m,i,n,j) = interflow(m,i,n).*/

* i)
import delimited using "$input/NC1S/final_consumption_NC1S_aggregated", clear 
ren source_c exporter
ren dest_c importer
collapse(sum) value_, by(exporter importer year)
codebook exporter //81 unique exporters
save "$output\consumption.dta",replace


* ii)
import delimited using "$input/NC1S/investment_use_NC1S_aggregated", clear 
ren source_c exporter
ren dest_c importer
collapse(sum) value_, by(exporter importer year)
codebook exporter //81 unique exporters
save "$output\investment.dta",replace


* iii)
import delimited using "$input/NC1S/intermediate_use_NC1S_aggregated", clear 
ren source_c exporter
ren dest_c importer
*collapse (sum) value_, by(exporter exp_sector importer year)
collapse (sum) value_, by(exporter importer year)
codebook exporter //81 unique exporters
save "$output\intermediate.dta",replace

* Combine all consumption + investment + intermediate trade values
use "$output/consumption.dta", clear
append using "$output/investment.dta"
append using "$output/intermediate.dta"

* Final collapse to get the grand total trade flow (X_ijt)
collapse (sum) value_, by(exporter importer year)

replace exporter = substr(exporter, 3, .)
replace importer = substr(importer, 3, .)

save "$output/exp_imp.dta",replace
codebook exporter //81 unique exporters

merge m:1 exporter importer using "$output/FTA_controls.dta"
/*

 Result                      Number of obs
    -----------------------------------------
    Not matched                        48,986
        from master                       161  (_merge==1)
        from using                     48,825  (_merge==2)

    Matched                             6,400  (_merge==3)
    -----------------------------------------

(80)^2 = 6400 obs. RoW does not exist in all datasets, therefore 80 instead of 81.

*/
codebook exporter if _merge==3 //80 unique exporters matched
levelsof exporter if _merge == 3
levelsof exporter if _merge == 1
keep if _merge==3
drop _merge

tempfile data
save "`data'"
************************* MERGE WITH TARIFF DATA *******************************
use "$input/tariffsPairs_88_21_vbeta1-2024-12.dta",clear
keep if year==2018
ren iso1 importer
ren iso2 exporter
codebook exporter //200 unique exporters
//tariff95 

merge 1:1 importer exporter using "`data'"

codebook exporter if _merge==3 //80
codebook importer if _merge==3 //80
//6320 observations = 80 x 80 - internal trade

//add back internal trade?
replace tariff95 = 0 if tariff95 == . & importer == exporter


*******************************************************************************
*************************** Create trade blocs dummies ************************

* 1) EU 
gen is_eu_exp = 0
replace is_eu_exp = 1 if inlist(exporter, "AUT", "BEL", "BGR", "CYP", "CZE", "DEU", "DNK", "ESP")
replace is_eu_exp = 1 if inlist(exporter, "EST", "FIN", "FRA", "GRC", "HRV", "HUN", "IRL", "ITA")
replace is_eu_exp = 1 if inlist(exporter, "LTU", "LUX", "LVA", "MLT", "NLD", "POL", "PRT", "ROU")
replace is_eu_exp = 1 if inlist(exporter,"SVK", "SVN", "SWE")

gen is_eu_imp = 0
replace is_eu_imp = 1 if inlist(importer, "AUT", "BEL", "BGR", "CYP", "CZE", "DEU", "DNK", "ESP")
replace is_eu_imp = 1 if inlist(importer, "EST", "FIN", "FRA", "GRC", "HRV", "HUN", "IRL", "ITA")
replace is_eu_imp = 1 if inlist(importer, "LTU", "LUX", "LVA", "MLT", "NLD", "POL", "PRT", "ROU")
replace is_eu_imp = 1 if inlist(importer, "SVK", "SVN", "SWE")

gen EU = (is_eu_exp == 1 & is_eu_imp == 1)
drop is_eu_exp is_eu_imp

* 2) USMCA
gen usmca_exp=0
replace usmca_exp =1 if inlist(exporter, "USA", "CAN", "MEX")

gen usmca_imp=0
replace usmca_imp =1 if inlist(importer, "USA", "CAN", "MEX")

gen USMCA = (usmca_exp==1 & usmca_imp==1)
drop usmca_exp usmca_imp


* 3) CPTPP
* Japan, Malaysia, Vietnam, Australia, Singapore, Brunei Darussalam, New Zealand, Canada, Mexico, Peru and Chile
gen cptpp_exp = 0
replace cptpp_exp =1 if inlist(exporter,"AUS", "BRN", "CAN", "CHL", "JPN", "MYS")
replace cptpp_exp =1 if inlist(exporter,"MEX", "NZL", "PER", "SGP", "VNM")

gen cptpp_imp = 0
replace cptpp_imp =1 if inlist(importer,"AUS", "BRN", "CAN", "CHL", "JPN", "MYS")
replace cptpp_imp =1 if inlist(importer,"MEX", "NZL", "PER", "SGP", "VNM")

gen CPTPP = (cptpp_imp ==1 & cptpp_exp ==1)
drop cptpp_imp cptpp_exp

* 4) ASEAN  
gen asean_exp = 0
replace asean_exp=1 if inlist(exporter,"IDN", "MYS", "PHL", "SGP", "THA", "BRN")
replace asean_exp=1 if inlist(exporter,"VNM", "LAO", "MMR", "KHM")

gen asean_imp = 0
replace asean_imp=1 if inlist(importer,"IDN", "MYS", "PHL", "SGP", "THA", "BRN")
replace asean_imp=1 if inlist(importer,"VNM", "LAO", "MMR", "KHM")

gen ASEAN = (asean_exp==1 & asean_imp==1)
drop asean_exp asean_imp

* 5) RCEP
gen rcep_e = inlist(exporter, "AUS", "BRN", "KHM", "CHN", "IDN", "JPN") | ///
             inlist(exporter, "KOR", "LAO", "MYS", "MMR", "NZL", "PHL") | ///
             inlist(exporter, "SGP", "THA", "VNM")
gen rcep_i = inlist(importer, "AUS", "BRN", "KHM", "CHN", "IDN", "JPN") | ///
             inlist(importer, "KOR", "LAO", "MYS", "MMR", "NZL", "PHL") | ///
             inlist(importer, "SGP", "THA", "VNM")
gen RCEP = (rcep_e == 1 & rcep_i == 1)
drop rcep_*

* MERCOSUR
gen mer_exp =0
replace mer_exp = 1 if inlist(exporter,"ARG", "BRA", "PRY", "SGP", "URY")

gen mer_imp =0
replace mer_imp = 1 if inlist(importer,"ARG", "BRA", "PRY", "SGP", "URY")
gen MERCOSUR = (mer_exp ==1 & mer_imp==1)
drop mer_exp mer_imp

********************************* EXTRAS: **************************************

*Internal trade
gen internal=0
replace internal=1 if exporter==importer

*Formating gravity variables
gen log_dist = log(dist)
replace contig=1 if internal==1
replace comlang_off=1 if internal==1

*Formating trade agreement dummy
replace fta=0 if EU==1
replace fta=0 if USMCA==1
replace fta=0 if CPTPP==1
replace fta=0 if ASEAN==1
replace fta=0 if RCEP==1
foreach a in EU USMCA CPTPP ASEAN RCEP {
	replace `a'=0 if internal==1
}
gen fta_beyond_EU = fta
replace fta_beyond_EU = 0 if EU ==1

gen tariff_reg = ln(1+tariff95/100)

* Robert: keep self-trade
* George: keep values in levels

********************************************************************************
***************************** Run PPML estimation ******************************
* FTA = 1 if free trade agreement in place
* contig = share common land border dummy
* comlang_off = common official language dummy
* trade bloc dummy =1 if both exporter & importer member of same bloc, 0 ow.

* IDs for FEs
egen exp_id = group(exporter)
egen imp_id = group(importer)
egen pair_id = group(exporter importer)
gen  int_id = imp_id*internal


eststo clear
* ════════════════════════ FTA + ALL TRADE BLOCS ═══════════════════════════════
eststo m1: ppmlhdfe value_ fta EU USMCA CPTPP ASEAN RCEP log_dist contig comlang_off, ///
     absorb(exp_id imp_id int_id) ///
     cluster(pair_id)
	 
/*
------------------------------------------------------------------------------
             |               Robust
      value_ | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         fta |   .4831692   .0994797     4.86   0.000     .2881927    .6781458
          EU |   .7267824   .0703377    10.33   0.000      .588923    .8646418
       USMCA |   .5449589   .1637198     3.33   0.001     .2240739    .8658439
       CPTPP |   .1110049   .1146416     0.97   0.333    -.1136885    .3356983
       ASEAN |   -.036886   .1245675    -0.30   0.767    -.2810339    .2072618
        RCEP |  -.0159159   .1108527    -0.14   0.886    -.2331831    .2013513
    log_dist |  -.5274156   .0269926   -19.54   0.000    -.5803203    -.474511
      contig |   .2926185   .0607289     4.82   0.000      .173592    .4116449
 comlang_off |   .1095802    .066474     1.65   0.099    -.0207064    .2398668
       _cons |   14.56838    .239859    60.74   0.000     14.09827     15.0385
------------------------------------------------------------------------------
════════════════════════════════════════════════════════════════════════ */


* ═════════════════════ FTA + ALL TRADE BLOCS + tariff ═════════════════════════
eststo m2: ppmlhdfe value_ fta tariff_reg EU USMCA ASEAN MERCOSUR log_dist contig comlang_off, ///
     absorb(exp_id imp_id int_id) ///
     cluster(pair_id)
	 
/*
------------------------------------------------------------------------------
             |               Robust
      value_ | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         fta |   .4208705   .0972476     4.33   0.000     .2302686    .6114724
  tariff_reg |  -3.263941   .9936682    -3.28   0.001    -5.211495   -1.316387
          EU |   .6530038   .0711133     9.18   0.000     .5136244    .7923833
       USMCA |   .5024679   .1607825     3.13   0.002     .1873401    .8175957
       ASEAN |  -.0160133   .1198073    -0.13   0.894    -.2508313    .2188047
    MERCOSUR |   .1167684   .3026514     0.39   0.700    -.4764175    .7099543
    log_dist |  -.5042473   .0249333   -20.22   0.000    -.5531158   -.4553789
      contig |   .2681952   .0607264     4.42   0.000     .1491737    .3872167
 comlang_off |   .1209905   .0662604     1.83   0.068    -.0088776    .2508585
       _cons |   14.50187   .2076082    69.85   0.000     14.09496    14.90877
------------------------------------------------------------------------------
════════════════════════════════════════════════════════════════════════ */

*NEW: Lumping ASEAN, MERCOSUR in with other trade agreements

replace fta=1 if ASEAN==1
replace fta=1 if MERCOSUR==1
drop ASEAN MERCOSUR


* ═════════════════════ FTA + SELECT TRADE BLOCS + tariff ═════════════════════════
eststo m2: ppmlhdfe value_ fta tariff_reg EU USMCA log_dist contig comlang_off, ///
     absorb(exp_id imp_id int_id) ///
     cluster(pair_id)
	 
/*
------------------------------------------------------------------------------
             |               Robust
      value_ | Coefficient  std. err.      z    P>|z|     [95% conf. interval]
-------------+----------------------------------------------------------------
         fta |   .2884327   .0773673     3.73   0.000     .1367956    .4400698
  tariff_reg |  -3.487933    .997401    -3.50   0.000    -5.442803   -1.533063
          EU |   .6350175   .0700371     9.07   0.000     .4977474    .7722877
       USMCA |    .516774   .1607825     3.21   0.001     .2016461    .8319019
    log_dist |  -.4932577   .0244763   -20.15   0.000    -.5412305    -.445285
      contig |   .2734725   .0604654     4.52   0.000     .1549625    .3919825
 comlang_off |   .1443864   .0653313     2.21   0.027     .0163394    .2724334
       _cons |   14.41913   .2041691    70.62   0.000     14.01897     14.8193
------------------------------------------------------------------------------
════════════════════════════════════════════════════════════════════════ */

