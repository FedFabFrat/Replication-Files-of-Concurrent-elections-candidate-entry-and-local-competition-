********************************************************************************
* Master do-file
* Paper:   Concurrent Elections, Candidate Entry, and Local Competition
* Author:  Federico Fabio Frattini
* Journal: Public Choice 
*
* INSTRUCTIONS FOR REPLICATORS:
*   1. Set $maindir (line ~25) to the absolute path of the replication package
*      root directory.
*   2. Create an output/ folder at that root; all tables and figures are saved
*      there.
*   3. Run this file from top to bottom. Data generation must complete before
*      analysis scripts are executed.
*   4. After running master.do, open R and run data/maps/maps.R to produce
*      Figure A1. Update the maps path variable in that script accordingly.
*
********************************************************************************

clear all
set more off

********************************************************************************
* 1. GLOBALS
*    Set $maindir to the root of the replication package. All other paths are
*    derived from $maindir and do not need to be changed.
********************************************************************************

global maindir "/path/to/replication_package"   // <-- CHANGE THIS to the absolute path of the replication package root

global output          "$maindir/output"
global data_controls   "$maindir/data/controls"
global data_elezioni   "$maindir/data/elections"
global maps            "$maindir/data/maps"


********************************************************************************
* 2. DATA GENERATION
********************************************************************************

* 2.1  Socio-demographic controls from ISTAT population censuses (1991/2001/2011)
*      Input:  data/controls/raw/confini-epoca_*.xlsx
*      Output: data/controls/controls_9111.dta
do "$maindir/dofiles/controls/mgmt_controls.do"

* 2.2  Local election data from Ministry of Interior (1991-2019)
*      Input:  data/elections/raw/comunali-*.dta
*      Output: data/elections/elections_data_0525.dta
do "$maindir/dofiles/elections/ele_data_1.do"

* 2.3  Mayor characteristics from Ministry of Interior administrators archive
*      Input:  data/admin/raw/YYYY.csv
*      Output: data/admin/mayors_chars_0525.dta
do "$maindir/dofiles/admin/mgmt_mayors_chars_1.do"

* 2.4  Final analysis dataset
*      Input:  controls_9111.dta + elections_data_0525.dta + panel_years_1.dta
*      Output: data/final_data.dta
do "$maindir/dofiles/data_mgmt_0525.do"


********************************************************************************
* 2.5  CLEANUP: Remove intermediate files generated during data generation.
*      Processed outputs (elections_data_0525.dta, controls_9111.dta,
*      mayors_chars_0525.dta, final_data.dta) are already saved above.
*      cap erase suppresses errors if a file does not exist on a given run.
********************************************************************************

* admin intermediates (mayors_YYYY.dta, created by mgmt_mayors_chars_1.do)
forvalues x = 1990/2019 {
    cap erase "$maindir/data/admin/raw/mayors_`x'.dta"
}

* admin extracted CSVs (extracted from admin_raw_*.zip by mgmt_mayors_chars_1.do)
local filelist : dir "$maindir/data/admin/raw" files "storico_amministratori_comuni*.csv"
foreach f of local filelist {
    cap erase "$maindir/data/admin/raw/`f'"
}

* controls intermediates (confini-epoca_NN.dta, created by mgmt_controls.do)
forvalues x = 1/20 {
    local n = string(`x', "%02.0f")
    cap erase "$maindir/data/controls/raw/confini-epoca_`n'.dta"
}

* elections intermediates (comunali-*.dta and *.txt, created by ele_data_1.do)
local filelist : dir "$maindir/data/elections/raw" files "comunali-*.dta"
foreach f of local filelist {
    cap erase "$maindir/data/elections/raw/`f'"
}
local filelist : dir "$maindir/data/elections/raw" files "*.txt"
foreach f of local filelist {
    cap erase "$maindir/data/elections/raw/`f'"
}


********************************************************************************
* 3. ANALYSIS
*    One do-file per exhibit. Run in order.
*    NOTE: Figure A1 (geographic map) is produced separately in R.
*          After master.do completes, open R and run data/maps/maps.R.
********************************************************************************

* --- Figures ---
* Figure 1
do "$maindir/dofiles/analysis/Figure1.do"

* Figure 2
do "$maindir/dofiles/analysis/Figure2.do"

* Figure 3
do "$maindir/dofiles/analysis/Figure3.do"


* --- Tables ---
* Table 1
do "$maindir/dofiles/analysis/Table1.do"

* Table 2
do "$maindir/dofiles/analysis/Table2.do"

* Table 3
do "$maindir/dofiles/analysis/Table3.do"

* Table 4
do "$maindir/dofiles/analysis/Table4.do"

* Table 5
do "$maindir/dofiles/analysis/Table5.do"


* --- Appendix Figures ---
* Figure A1 input (then run maps.R in R)
do "$maindir/dofiles/analysis/FigureA1.do"

* Figure A2
do "$maindir/dofiles/analysis/FigureA2.do"

* Figure A3
do "$maindir/dofiles/analysis/FigureA3.do"

* Figure A4
do "$maindir/dofiles/analysis/FigureA4.do"

* Figure A5
do "$maindir/dofiles/analysis/FigureA5.do"

* Figure A6
do "$maindir/dofiles/analysis/FigureA6.do"

* Figure A7
do "$maindir/dofiles/analysis/FigureA7.do"


* --- Appendix Tables ---
* Table A1
do "$maindir/dofiles/analysis/TableA1.do"

* Table A2
do "$maindir/dofiles/analysis/TableA2.do"

* Table A3
do "$maindir/dofiles/analysis/TableA3.do"

* Table A4
do "$maindir/dofiles/analysis/TableA4.do"

* Table A5
do "$maindir/dofiles/analysis/TableA5.do"

* Table A6
do "$maindir/dofiles/analysis/TableA6.do"

* Table A7
do "$maindir/dofiles/analysis/TableA7.do"

* Table A8
do "$maindir/dofiles/analysis/TableA8.do"

* Table A9
do "$maindir/dofiles/analysis/TableA9.do"

* Table A10
do "$maindir/dofiles/analysis/TableA10.do"

* Table A11
do "$maindir/dofiles/analysis/TableA11.do"

* Table A12
do "$maindir/dofiles/analysis/TableA12.do"

* Table A13
do "$maindir/dofiles/analysis/TableA13.do"

* Table A14
do "$maindir/dofiles/analysis/TableA14.do"

