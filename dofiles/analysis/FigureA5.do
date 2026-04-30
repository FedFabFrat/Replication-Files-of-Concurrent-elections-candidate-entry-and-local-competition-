********************************************************************************
* Figure A5
* Event studies: Concurrent national-local elections and elected mayor characteristics
* Outputs: $output/figures/FigureA5a.pdf
*          $output/figures/FigureA5b.pdf
*          $output/figures/FigureA5c.pdf
*          $output/figures/FigureA5d.pdf
*          $output/figures/FigureA5e.pdf
********************************************************************************

clear all
set more off

use "$maindir/data/final_data.dta", clear
global controls "tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc"
global controls_base "tasso_occ_industr_91 tasso_occ_agric_91 inc_abitazioni_proprieta_91 indice_dip_anziani_91 incidenza_adul_dip_lau_91 tasso_occ_terz_91 inc_fam_disagio_econ_91 tasso_disocc_91"


* mayor chars *
rename comune_mayors comune_ele
rename name_winner name_winner_ele
merge 1:1 codcom anno using "$maindir/data/admin/mayors_chars_0525.dta"
keep if _merge == 3
drop _merge
cap drop esam
qui reghdfe educ nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom ele_date i.codreg#i.anno) vce(cl codcom)
cap gen esam = 1 if e(sample) == 1
eststo clear

* event studies *
cap drop lag* lead* group fytb nt
cap drop temp
xtset codcom local_legi
gen lag0 = s.nlse_did
recode lag0 .=0
local c = 0
label var lag0 "0"
qui forvalues x=1/10 {
	local c = `c' + 1
	gen lag`x' = l`x'.lag0
	recode lag`x' .=0
	label var lag`x' "+ `c'"
	gen lead`x' = f`x'.lag0
	recode lead`x' .=0
	label var lead`x' "- `c'"
}
replace lead1 = 0
gen group = .
forvalues z=4/10 {
	replace group = 1 if lead`z' == 1
}
forvalues z=4/10 {
	replace group = 1 if lag`z' == 1
}
recode group .=0
bys codcom (local_legi): egen temp = min(anno) if nlse == 1
bys codcom (local_legi): egen fytb = max(temp)
recode fytb .=0
gen nt = 1 if fytb == 0
recode nt .=0
eststo clear
foreach y of varlist educ may_born_city female age exp_in_office {
	if "`y'" == "educ" {
		local subfig "a"
		local yt "Education"
	}
	if "`y'" == "may_born_city" {
		local subfig "b"
		local yt "Born in city"
	}
	if "`y'" == "female" {
		local subfig "c"
		local yt "Female"
	}
	if "`y'" == "age" {
		local subfig "d"
		local yt "Age"
	}
	if "`y'" == "exp_in_office" {
		local subfig "e"
		local yt "Exp. in office"
	}
	eventstudyinteract `y' lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1, vce(cluster codcom) absorb(codcom ele_date codreg#anno) cohort(fytb) control_cohort(nt) covariates($controls)
	matrix sa_b = e(b_iw) // storing the estimates for later
	matrix sa_v = e(V_iw)
	event_plot sa_b#sa_v, stub_lag(lag# lag#) stub_lead(lead# lead#) trimlead(3) trimlag(3) plottype(connected) ciplottype(rcap) together noautolegend ///
		graph_opt(xtitle("Elections since treatment") ///
		ytitle("Coefficients estimates (95% CI)") ///
		title("`yt'") ///
		xlabel(-3(1)3) ///
		yline(0, lp(dash) lc(gs8)) ///
		xline(-1, lp(dash) lc(gs8)) ///
		legend(off)) ///
		lag_opt1(color(black) msym(O) msize(medlarge)) lag_ci_opt1(color(black) lw(medthick)) 
	graph export "$output\figures\FigureA5`subfig'.pdf", as(pdf) replace
}

