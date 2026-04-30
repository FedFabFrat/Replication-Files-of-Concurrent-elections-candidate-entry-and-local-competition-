********************************************************************************
* Figure A1 (data preparation)
* Generates nlse.dta - input for maps.R which produces Figure A1
* Output: $maps/nlse.dta
********************************************************************************

clear all
set more off

use "$maindir/data/final_data.dta", clear

*
preserve
collapse (max) nlse codreg codpro, by(codcom)
save "$maps/nlse.dta", replace
restore
