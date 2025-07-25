/*
The goal is to merge a firm-level dataset on Indian firms with an equivalent industry-level dataset to investigate the causal effect of externally imposed trade liberalization on firm-level productivity in India.

Heterogeneous responses to tariff reductions: Does firm size matter? The case of India.
JEL: F13, F14, F68, O19, O24
*/


clear all
set more off
cd "/Users/alicjakobayashi/Library/CloudStorage/OneDrive-UniversityofBristol/AED/size"
capture log close
log using "size.log",replace

use "industrydata.dta",clear

//////////////////////////STEP 1: IMPORT AND FIX EXCEL DATA////////////////////

destring groupnic-k_l,replace

save "industrydata_YEAR.dta",replace

*file>import>excel //tick both boxes

destring industrialcodeNIC1998-effectiverateofprotection,replace

*Before creating a lagged indep variable we need to sort the data.
sort industrialcodeNIC1998 year 
by industrialcodeNIC1998 : generate lagged_trade = tariff[_n-1] //158  missing values generated

sort industrialcodeNIC1998 year 
by industrialcodeNIC1998 : generate lagged_inputariff = inputariff[_n-1] //218 missing values generated

save "industry-year_tariff.dta",replace //everything is numerical
  

//////////////////////STEP 2: MERGE DTAS///////////////////////////////////////


use "firm_year_1989-1995(2).dta",clear

append using "firm_year_1996-2002(2).dta"


//////////////////////STEP 2.2 Generate characteristics variables//////////////


generate agesquared=age*age //18 missing values generated

tab type,generate(ownership)

tab size,generate(sizes)

rename yr year //we do this to match var.names with the other datasets.
rename industrycode industrialcodeNIC1998

save appended1989_2002.dta,replace //inducode and compname are strings


//////////////////////STEP 3: MERGE DTAS+EXCEL/////////////////////////////////


use "appended1989_2002.dta",clear //firm-level

destring industrialcodeNIC1998,replace

sort industrialcodeNIC1998 year //maybe before this we destring industtialcode
//only companyname string
tostring industrialcodeNIC1998,replace

save "appended1989_2002.dta",replace

use "industry-year_tariff.dta",clear //industry-level (excel) everything numerical

sort industrialcodeNIC1998 year //bc these variables are the ones the datasets have in common.

save "industry-year_tariff.dta",replace

tostring industrialcodeNIC1998,replace //indcod is a string now

merge 1:m industrialcodeNIC1998 year using "appended1989_2002.dta" //30 451

save appended_merged.dta,replace

su 
//up to this point there are 42 variables and 32 621 observations. Around 70 missing information for regressand tfp1000. some negative values


//////////////////////STEP 4: CLEANING DATA/////////////////////////////////

generate lnsales=ln(rsales+1)

rename ownership1 Private_stand_alone_company
rename ownership2 Private_group_firm
rename ownership3 Government_owned
rename ownership4 Foreign

rename sizes1 Large
rename sizes2 Medium
rename sizes3 Small


drop if year>1996 //Because we are only interested in 1986-96. 17 548 obs deleted.
drop if year<1989 //103 observations deleted

sort companyname year
by companyname : generate lagged_TFP = tfp1000[_n-1] //3149 missing values generated

***************************
duplicates report id year //check for duplicates in terms of id and year. yes there are duplicates indeed.
duplicates drop id year,force //15 observations deleted
duplicates report id year //check for duplicates, ok now
***************************

save "appended_merged.dta",replace 
su //45 variables, 14 896 observations


***********************MERGING WITH ADDITIONAL DATASET***********************
use "appended_merged.dta",clear 

//The current dataset in memory has an indcode using up to 4 digits. So, we need to create a new indcode variable which only uses the first three digits in order for us to merge this dataset with the additional dataset which uses 3 digits.

sort industrialcodeNIC1998 year
gen indcode3digits = substr(industrialcodeNIC1998,1,3)

br industrialcodeNIC1998 indcode3digits //indcodes 2424 och 2429 kodas båda som 242. Är inte detta problematiskt? Data är från 1989 men dyker upp i alla andra år?

destring indcode3digits,replace

rename _merge _merge_section1

save "appended_merged.dta",replace

use "industrydata_YEAR.dta",clear //industry-level data 

rename nic1 indcode3digits

sort indcode3digits

destring indcode3digits,replace

save "industrydata_YEAR_edited.dta",replace

use "industrydata_YEAR_edited.dta",clear

//MERGE
merge 1:m indcode3digits using "appended_merged.dta" //8291 matched

duplicates report id year
duplicates drop id year,force //103 observations deleted
duplicates report id year //14 897 obs left

rename tfp1000 TFP
rename lagged_inputariff lagged_inputtariff
rename lagged_trade lagged_outputtariff

save "THEdataset.dta",replace

******************************** FOCUS ON : SIZES ***************************

use "THEdataset.dta",clear //GOOD TO USE

su Large,detail 	//if sales exceed 99th percentile		2 690
su Medium,detail 	//if avg sales is above median but less than 99th percentile
su Small,detail 	//if avg sales is less than median

su logemployment //8 292 obs
kdensity logemployment 	// Suggestion [0,9],(9,11], (11,inf) 
kdensity rsales 		// Suggestion Largest 95th percentile and above

su rsales if year==1989 //936 observations
su rsales if year==1990 // 1 120 obs <--
su rsales if year==1991 // 1 413 obs

/*
keep if year==1990
su rsales,detail //we see that 90th percentile rsale is 321.7419

*/

su logemployment if year==1989 // 565 observations <-- industry-level
su logemployment if year==1990 // 670 observations 
su logemployment if year==1991 // 836 observations


/* Alternatives
logemployment 			log number of employees**
rsales					real sales** 

laborprod				more than 14 000 obs (as an alternative to TFP)

br logemployment indcode3digits companyname if year==1989
*/

use "THEdataset.dta",clear //good to use, then generate rsales


generate Small_rsales =1 if (year==1990 & rsales<191.61607)
replace Small_rsales =0 if (year==1990 & rsales>=191.61607)
replace Small_rsales =. if year!=1990
replace Small_rsales =. if (year==1990 & rsales==.)

generate Medium_rsales =1 if (year==1990 & rsales<321.7419 & rsales>=191.61607)
replace Medium_rsales =0 if (year==1990 & rsales>=321.7419 | rsales<191.61607)
replace Medium_rsales =. if year!=1990
replace Medium_rsales =. if (year==1990 & rsales==.)

generate Large_rsales =1 if (year==1990 & rsales>=321.7419)
replace Large_rsales =0 if (year==1990 & rsales<321.7419)
replace Large_rsales =. if year!=1990
replace Large_rsales =. if (year==1990 & rsales==.)



sort id year rsales

br id year rsales Small_rsales Medium_rsales Large_rsales

count if Small_rsales ==1 //5749
count if Medium_rsales ==1 // 551
count if Large_rsales ==1 //743

tab year, summarize(rsales)


xtile employmentquantile = logemployment, nq(3)

tab employmentquantile //
/*
1 Small: 2 921
2 Medium: 3 280
3 Large: 2 091
*/

generate employmentQuant = 1 if logemployment <10.78624 
replace employmentQuant = 2 if (logemployment >=10.78624 & logemployment<10.9063)
replace employmentQuant = 3 if logemployment >=10.9063 


save "THEdataset.dta",replace
***************************** WINSORIZE SAMPLE 10 % ****************************
//WINSOR 10 PERCENT:TEST
use "THEdataset.dta",clear //good to use


ssc install winsor

winsor TFP, p(.1) gen(TFP_winsored_p10)
winsor TFP, p(.05) gen(TFP_winsored_p5)
 
save "THEdataset.dta",replace


***************************** TEST FOR SERIAL CORRELATION *********************

//DURBIN WATSON TEST FOR SERIAL CORRELATION
reg TFP lagged_outputtariff lagged_inputtariff lagged_TFP lnsales age agesquared, robust
dwstat //NOT WORKING

xtserial TFP lagged_outputtariff lagged_inputtariff lagged_TFP lnsales age agesquared
//says no first order AC but this must be wrong.

//is lnsales a valid proxy
corr lnsales size, with a correlation of -0.8354
reg lnsales size


//TYPE OF INDUSTRIES: Foreign Government_owned Private_group_firm Private_stand_alone_company use_I trade_IC trade_E use_CND use_CD use_C use_B


//TEST from grp regression OK
xi: areg TFP lagged_outputtariff lagged_inputtariff age agesquared lagged_TFP i.year, absorb(companyname) robust


******************** FD REGRESSIONS employment median, 75*************************


use "THEdataset.dta",clear //GOOD TO USE

xtset id year
drop if employmentQuant!=1

							*FD Column 1 - Q1

xi: reg TFP lagged_outputtariff lagged_inputtariff lagged_TFP lnsales age agesquared i.year, cluster(id) 

reg d.TFP d.lagged_outputtariff d.lagged_inputtariff d.lagged_TFP d.lnsales d.age d.agesquared i.year, cluster(id) 

/* Noobs: ≈ 3 878

lagged_outputtariff: 	-0.011
lagged_inputtariff: 	0.185**	
lagged_TFP: 			-0.131***
lnsales: 				0.256***

*/

							*FD Column 2 - Q2
								
use "THEdataset.dta",clear //good to use

xtset id year
drop if employmentQuant !=2

reg d.TFP d.lagged_outputtariff d.lagged_inputtariff d.lagged_TFP d.lnsales d.age d.agesquared i.year, cluster(id) 

/* Noobs: 800, R-squared: 0.3007

lagged_outputtariff: 	0.100		
lagged_inputtariff: 	-1.264		
lagged_TFP: 			-0.212***
lnsales: 				0.281***	

*/

							*FD Column 3 - Q3
								
use "THEdataset.dta",clear //good to use

xtset id year
drop if employmentQuant !=3 //regressing for Q3

reg d.TFP d.lagged_outputtariff d.lagged_inputtariff d.lagged_TFP d.lnsales d.age d.agesquared i.year, cluster(id) 

/* Noobs: 3 990, R-squared: 0.3315

lagged_outputtariff: 	-0.030**					
lagged_inputtariff: 	-0.397*
lagged_TFP: 			-0.158***				
lnsales: 				0.256***				

*/

//////////////////////////WINSORIZED FOR 3 QUANTILES////////////////////////////

use "THEdataset.dta",clear


xtset id year
drop if employmentQuant!=1

						*FD Column 1 - Q1

xi: reg TFP_winsored_p10 lagged_outputtariff lagged_inputtariff lagged_TFP lnsales age agesquared i.year, cluster(id) 

reg d.TFP_winsored_p10 d.lagged_outputtariff d.lagged_inputtariff d.lagged_TFP d.lnsales d.age d.agesquared i.year, cluster(id) 

/* Noobs: ≈3 878, R-squared: 0.2092 

lagged_outputtariff: 	-0.002	
lagged_inputtariff: 	0.052		
lagged_TFP: 			-0.049***	
lnsales: 				0.149***	

*/

						*FD Column 2 - Q2
								
use "THEdataset.dta",clear

xtset id year
drop if employmentQuant !=2

reg d.TFP_winsored_p10 d.lagged_outputtariff d.lagged_inputtariff d.lagged_TFP d.lnsales d.age d.agesquared i.year, cluster(id) 

/* Noobs: 800, R-squared: 0.3007

lagged_outputtariff: 	0.033		
lagged_inputtariff: 	-0.319		
lagged_TFP: 			-0.034	
lnsales: 				0.145***	

*/

						*FD Column 3 - Q3
								
use "THEdataset.dta",clear


xtset id year
drop if employmentQuant !=3 //regressing for Q3

reg d.TFP_winsored_p10 d.lagged_outputtariff d.lagged_inputtariff d.lnsales d.age d.agesquared i.year, cluster(id) 

/* Noobs: 3 990, R-squared: 0.3315

lagged_outputtariff: 	-0.028***					
lagged_inputtariff: 	-0.205***
lagged_TFP: 			-0.049***				
lnsales: 				0.138***				

*/
********************** LOG EMPLOYED UNBALANCED + UNWINSORED *********************
use "THEdataset.dta",clear

eststo clear
use "THEdataset.dta",clear

keep if employmentQuant ==3

xtset id year
eststo: reg d.TFP d.lagged_outputtariff d.lagged_inputtariff d.lnsales d.agesquared i.year, cluster(id) 


esttab using "Table_employed+UNBALANCED+UNWINSORED.csv", ///
replace se b(3) star(* 0.10 ** 0.05 *** 0.01)	
*********************** LOG EMPLOYED UNBALANCED + WINSORED ***********************
use "THEdataset.dta",clear

eststo clear
use "THEdataset.dta",clear
keep if employmentQuant ==3

xtset id year
eststo: reg d.TFP_winsored_p5 d.lagged_outputtariff d.lagged_inputtariff d.lnsales d.agesquared i.year, cluster(id) 


esttab using "Table_employed+UNBALANCED+WINSORED.FINAL.csv", ///
replace se b(3) star(* 0.10 ** 0.05 *** 0.01)	
*********************** LOG EMPLOYED BALANCED + WINSORED ***********************
use "THEdataset.dta",clear

eststo clear
use "THEdataset.dta",clear
bysort companyname : keep if _N==8 
keep if employmentQuant ==3

xtset id year
eststo: reg d.TFP_winsored_p5 d.lagged_outputtariff d.lagged_inputtariff d.lnsales d.agesquared i.year, cluster(id) 


esttab using "Table_employed+BALANCED+WINSORED.csv", ///
replace se b(3) star(* 0.10 ** 0.05 *** 0.01)	

	
********************************************************************************
**************** SAVE 3 REGRESSIONS + 3 WINSORED WITHOUT LAGGED Y***************

eststo clear

use "THEdataset.dta",clear
xtset id year
drop if employmentQuant!=1

eststo: reg d.TFP d.lagged_outputtariff d.lagged_inputtariff d.lnsales d.agesquared i.year, cluster(id) 

use "THEdataset.dta",clear
xtset id year
drop if employmentQuant!=2

eststo: reg d.TFP d.lagged_outputtariff d.lagged_inputtariff d.lnsales d.agesquared i.year, cluster(id) 

use "THEdataset.dta",clear
xtset id year
drop if employmentQuant!=3

eststo: reg d.TFP d.lagged_outputtariff d.lagged_inputtariff d.lnsales d.agesquared i.year, cluster(id) 

//winsorized below

use "THEdataset.dta",clear
xtset id year
drop if employmentQuant!=1

eststo: reg d.TFP_winsored_p10 d.lagged_outputtariff d.lagged_inputtariff d.lnsales d.agesquared i.year, cluster(id) 


use "THEdataset.dta",clear
xtset id year
drop if employmentQuant!=2

eststo: reg d.TFP_winsored_p10 d.lagged_outputtariff d.lagged_inputtariff d.lnsales d.agesquared i.year, cluster(id) 


use "THEdataset.dta",clear
xtset id year
drop if employmentQuant!=3

eststo: reg d.TFP_winsored_p10 d.lagged_outputtariff d.lagged_inputtariff d.lnsales d.agesquared i.year, cluster(id) 


esttab using "Robust_logemployed.csv", ///
replace se b(3) star(* 0.10 ** 0.05 *** 0.01)		

***************************SUMMARY STATISTICS**************************
use "THEdataset.dta",clear

eststo clear	
use "THEdataset.dta",clear
estpost summarize TFP lagged_outputtariff lagged_inputtariff lagged_TFP age agesquared lnsales logemployment employmentQuant

esttab  using "Sum_stats.csv", cells("mean(fmt(%5.2f))   sd(fmt(%5.2f)) count(fmt(%5.0f)) min(fmt(%5.2f)) max(fmt(%5.2f))") ///
replace noobs


***************************************************************************
log close


