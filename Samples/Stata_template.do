clear all 

set more off

global path "P:\ECB business areas\DGE\FSC2"

cd "${path}\Chart Country exports by BEC"

/////////////////////// Import data //////////////////////

use "TDM_data.dta",clear

import excel "excelfile.xlsx", sheet("Conversion HS17-BEC") firstrow clear

//////////////////////////////// working space ////////////////////////

 

//////////////////////////////// Save data ////////////////////////

save "Final_EA_RoW_2019-2014.dta",replace

export excel using "P:\ECB business areas\ww\give_a_name_to_this_dataset_currently_in_working_directory.xlsx", sheet("give_a_name_to_this_sheet") sheetmodify firstrow(variables)
