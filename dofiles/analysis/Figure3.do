********************************************************************************
* Figure 3
* Event studies: electoral outcomes (vote shares, win probabilities, HHPC)
* Output: $output/figures/sa_sh_votes_natp_1st.pdf, sa_sh_votes_civp_1st.pdf,
*         sa_natwin.pdf, sa_civwin.pdf, sa_inv_hhi.pdf
********************************************************************************

clear all
set more off

use "$maindir/data/final_data.dta", clear
global controls "tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc"
global controls_base "tasso_occ_industr_91 tasso_occ_agric_91 inc_abitazioni_proprieta_91 indice_dip_anziani_91 incidenza_adul_dip_lau_91 tasso_occ_terz_91 inc_fam_disagio_econ_91 tasso_disocc_91"

* event studies *
qui reghdfe n_cand nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom ele_date i.codreg#i.anno) vce(cl codcom)
cap gen esam = 1 if e(sample) == 1
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
foreach y of varlist sh_votes_natp_1st sh_votes_civp_1st natwin civwin inv_hhi {
	if "`y'" == "sh_votes_natp_1st" {
		local subfig "a"
		local yt "Local votes share of nat.-established party"
	}
	if "`y'" == "sh_votes_civp_1st" {
		local subfig "b"
		local yt "Local votes share of independent party"
	}
	if "`y'" == "natwin" {
		local subfig "c"
		local yt "Pr. of victory of nat.-established party"
	}
	if "`y'" == "civwin" {
		local subfig "d"
		local yt "Pr. of victory of independent party"
	}
	if "`y'" == "inv_hhi" {
		local subfig "e"
		local yt "HHPC index"
	}
	eventstudyinteract `y' lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1, vce(cluster codcom) absorb(codcom ele_date codreg#anno) cohort(fytb) control_cohort(nt) covariates($controls)
	matrix sa_b = e(b_iw)
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
	graph export "$output/figures/Figure3`subfig'.pdf", as(pdf) replace
}
