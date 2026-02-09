* ==============================================================================
* STATA SCRIPT: Mass Copy and Rename Excel Files (+88 Offset)
* Original older contains excel files named 1 to 196. Ask Stata to copy these and rename these into a new folder. Rename to i+88, such that 1 is renamed to 89,etc..
* ==============================================================================

* 1. Define the folder paths
* Using forward slashes (/) is best practice for network drives like U:
local source "U:/FTA/data/Bilateral/Input-2016"
local target "U:/FTA/data/Bilateral/Input"

* 2. Create the target folder if it doesn't already exist
capture mkdir "`target'"

* 3. Loop through files 1 to 196
forvalues i = 1/196 {
    
    * Define the source file path (where it is now)
    local old_file "`source'/`i'.xlsx"
    
    * Calculate the new number (e.g., 1 + 88 = 89)
    local new_num = `i' + 88
    
    * Define the target file path (where it is going)
    local new_file "`target'/`new_num'.xlsx"
    
    * 4. Perform the copy and rename
    * 'capture' ensures the loop doesn't stop if a file number is missing
    * 'replace' allows you to rerun this script safely
    capture copy "`old_file'" "`new_file'", replace
    
    * 5. Display progress in the Results window
    if _rc == 0 {
        display "Copied: `i'.xlsx  -->  `new_num'.xlsx"
    }
    else {
        display as error "Note: File `i'.xlsx not found in source. Skipping..."
    }
}

display "----------------------------------------------------------------"
display "PROCESS COMPLETE: Check the 'Input' folder for files 89-284."
display "----------------------------------------------------------------"
