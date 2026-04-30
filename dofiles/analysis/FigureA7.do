********************************************************************************
* Figure A7
* Event studies: local spending by category (12 panels)
* Output: $output/figures/FigureA7a.pdf, FigureA7b.pdf,
*         FigureA7c.pdf, FigureA7d.pdf,
*         FigureA7e.pdf, FigureA7f.pdf,
*         FigureA7g.pdf, FigureA7h.pdf,
*         FigureA7i.pdf, FigureA7j.pdf,
*         FigureA7k.pdf, FigureA7l.pdf
********************************************************************************

clear all
set more off

use "$maindir/data/final_data.dta", clear
// global controls "popolazione_residente incidenza_adul_dip_lau tasso_occ_agric tasso_occ_industr tasso_occ_terz"
global controls "tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc"
// global controls_base "popolazione_residente_91 incidenza_adul_dip_lau_91 tasso_occ_agric_91 tasso_occ_industr_91 tasso_occ_terz_91"
global controls_base "tasso_occ_industr_91 tasso_occ_agric_91 inc_abitazioni_proprieta_91 indice_dip_anziani_91 incidenza_adul_dip_lau_91 tasso_occ_terz_91 inc_fam_disagio_econ_91 tasso_disocc_91"

*
rename comune_mayors comune_ele
rename name_winner name_winner_ele
merge 1:1 codcom anno using "$maindir/data/admin/mayors_chars_0525.dta"
keep if _merge == 3
drop _merge

*
merge 1:1 codcom anno using "$maindir/data/bilanci/bilanci_mngd_2.dta"
sort codcom anno
keep codcom anno tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc tasso_occ_industr_91 tasso_occ_agric_91 inc_abitazioni_proprieta_91 indice_dip_anziani_91 incidenza_adul_dip_lau_91 tasso_occ_terz_91 inc_fam_disagio_econ_91 tasso_disocc_91 codreg codpro ever_natp_1 ever_civp_1 Entr_* Totale_gen_* sub_cat_* risc_comp* Amminist_* Cultura_* Giustizia_* Polizia_* Servizi_* Sociale_* Sviluppo_* Territorio_* Turismo_* Viabilita_* Sport_* Spese_* Istruzione_* ele_date _merge accertamenti* educ may_born_city female age exp_in_office local_legi
foreach x of varlist tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc tasso_occ_industr_91 tasso_occ_agric_91 inc_abitazioni_proprieta_91 indice_dip_anziani_91 incidenza_adul_dip_lau_91 tasso_occ_terz_91 inc_fam_disagio_econ_91 tasso_disocc_91 codreg codpro ever_natp_1 ever_civp_1 ele_date educ may_born_city female age exp_in_office local_legi {
		bys codcom (anno): carryforward `x', replace
}

*
global mayorc "educ may_born_city female age exp_in_office"
keep if inrange(anno,1998,2015)
drop if _merge == 1
gen temp = ele_date
gen nlse = 1 if ele_date == 15108 | ele_date == 17635
gen nlse_did = nlse
bys codcom (anno): carryforward nlse_did, replace
foreach x of varlist nlse nlse_did {
	recode `x' .=0
}

*
rename accertamenti3 State_trasf
rename risc_comp3 State_trasf_cc
rename risc_comp23 Tasse_cc
rename accertamenti23 Tasse
rename risc_comp22 Imposte_cc
rename accertamenti22 Imposte
rename *_correnti *
rename Totale_gen_entr_risc Totale_gen_entr_cc
foreach x of varlist State_trasf Amminist Cultura Giustizia Polizia Servizi Sociale Sviluppo Territorio Turismo Viabilita Sport Spese Totale_gen_entr Tasse Imposte Istruzione {
	gen ln`x' = ln(`x'+0.0001)
	gen asinh`x' = asinh(`x')
}
foreach x of varlist State_trasf_cc Amminist_cc Cultura_cc Giustizia_cc Polizia_cc Servizi_cc Sociale_cc Sviluppo_cc Territorio_cc Turismo_cc Viabilita_cc Sport_cc Spese_cc Totale_gen_entr_cc Tasse_cc Imposte_cc Istruzione_cc {
	gen ln`x' = ln(`x'+0.0001)
	gen asinh`x' = asinh(`x')
}
foreach x of varlist State_trasf Amminist Cultura Giustizia Polizia Servizi Sociale Sviluppo Territorio Turismo Viabilita Sport Spese Totale_gen_entr Tasse Imposte Istruzione {
	gen speed_`x' = `x'_cc/`x'
}
foreach x of varlist speed* {
	summarize `x' if ever_natp_1 == 1 & ever_civp_1 == 1, d
	replace `x' = . if `x' > r(p99) | `x' < r(p1)
}

*
xtset codcom anno
xtdescribe
bys codcom (anno): gen asd = _N
keep if inlist(asd,17,18)
drop asd
foreach x of varlist ln* asinh* speed* {
	bys codcom (anno): carryforward `x', replace
}
gen year_ele = year(ele_date)
gen temp1 = anno
gen temp2 = year_ele
gen rel_year_ele = temp1-temp2
drop temp1 temp2

* Create sample indicators (replicate from Table5.do to get same esam_* variables)
cap drop esam_*
eststo clear
qui eststo c2: reghdfe speed_Spese nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_spend = 1 if e(sample) == 1
qui eststo c4: reghdfe speed_Sviluppo nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_svil = 1 if e(sample) == 1
qui eststo c6: reghdfe speed_Territorio nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_terr = 1 if e(sample) == 1
qui eststo c8: reghdfe speed_Amminist nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_amm = 1 if e(sample) == 1
qui eststo c9: reghdfe speed_Istruzione nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_ist = 1 if e(sample) == 1
qui eststo c12: reghdfe speed_Sociale nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_soc = 1 if e(sample) == 1

cap drop lag* lead* group fytb nt
cap drop temp
xtset codcom anno
gen lag0 = s.nlse_did
recode lag0 .=0
local c = 0
label var lag0 "0"
qui forvalues x=1/18 {
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
forvalues z=6/18 {
	replace group = 1 if lead`z' == 1
}
forvalues z=6/18 {
	replace group = 1 if lag`z' == 1
}
recode group .=0
bys codcom (anno): egen temp = min(anno) if nlse == 1
bys codcom (anno): egen fytb = max(temp)
recode fytb .=0
gen nt = 1 if fytb == 0
recode nt .=0


eststo clear
eventstudyinteract asinhSpese_cc lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_spend == 1, vce(cluster codcom) absorb(i.codcom i.anno i.rel_year_ele i.codreg#i.anno) cohort(fytb) control_cohort(nt) covariates($controls)
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)
event_plot sa_b#sa_v, stub_lag(lag# lag#) stub_lead(lead# lead#) trimlead(5) trimlag(5) plottype(connected) ciplottype(rcap) together noautolegend ///
	graph_opt(xtitle("Years since treatment") ///
	ytitle("Coefficients estimates (95% CI)") ///
	title("(IHS) Total Expenses") ///
	xlabel(-5(1)5) ///
	ylabel(-0.15(0.1)0.45) ///
	yline(0, lp(dash) lc(gs8)) ///
	xline(-1, lp(dash) lc(gs8)) ///
	legend(off)) ///
	lag_opt1(color(black) msym(O) msize(medlarge)) lag_ci_opt1(color(black) lw(medthick))
graph export "$output/figures/FigureA7a.pdf", as(pdf) replace

eststo clear
eventstudyinteract speed_Spese lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_spend == 1, vce(cluster codcom) absorb(i.codcom i.anno i.rel_year_ele i.codreg#i.anno) cohort(fytb) control_cohort(nt) covariates($controls)
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)
event_plot sa_b#sa_v, stub_lag(lag# lag#) stub_lead(lead# lead#) trimlead(5) trimlag(5) plottype(connected) ciplottype(rcap) together noautolegend ///
	graph_opt(xtitle("Years since treatment") ///
	ytitle("Coefficients estimates (95% CI)") ///
	title("Efficiency in Total Expenses") ///
	xlabel(-5(1)5) ///
	ylabel(-0.25(0.05)0.25) ///
	yline(0, lp(dash) lc(gs8)) ///
	xline(-1, lp(dash) lc(gs8)) ///
	legend(off)) ///
	lag_opt1(color(black) msym(O) msize(medlarge)) lag_ci_opt1(color(black) lw(medthick))
graph export "$output/figures/FigureA7b.pdf", as(pdf) replace

eststo clear
eventstudyinteract asinhSviluppo_cc lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_svil == 1, vce(cluster codcom) absorb(i.codcom i.anno i.rel_year_ele i.codreg#i.anno) cohort(fytb) control_cohort(nt) covariates($controls)
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)
event_plot sa_b#sa_v, stub_lag(lag# lag#) stub_lead(lead# lead#) trimlead(5) trimlag(5) plottype(connected) ciplottype(rcap) together noautolegend ///
	graph_opt(xtitle("Years since treatment") ///
	ytitle("Coefficients estimates (95% CI)") ///
	title("(IHS) Economic Development Expenses") ///
	xlabel(-5(1)5) ///
	ylabel(-2(1)2) ///
	yline(0, lp(dash) lc(gs8)) ///
	xline(-1, lp(dash) lc(gs8)) ///
	legend(off)) ///
	lag_opt1(color(black) msym(O) msize(medlarge)) lag_ci_opt1(color(black) lw(medthick))
graph export "$output/figures/FigureA7c.pdf", as(pdf) replace

eststo clear
eventstudyinteract speed_Sviluppo lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_svil == 1, vce(cluster codcom) absorb(i.codcom i.anno i.rel_year_ele i.codreg#i.anno) cohort(fytb) control_cohort(nt) covariates($controls)
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)
event_plot sa_b#sa_v, stub_lag(lag# lag#) stub_lead(lead# lead#) trimlead(5) trimlag(5) plottype(connected) ciplottype(rcap) together noautolegend ///
	graph_opt(xtitle("Years since treatment") ///
	ytitle("Coefficients estimates (95% CI)") ///
	title("Efficiency in Economic Development Expenses") ///
	xlabel(-5(1)5) ///
	ylabel(-6(2)6) ///
	yline(0, lp(dash) lc(gs8)) ///
	xline(-1, lp(dash) lc(gs8)) ///
	legend(off)) ///
	lag_opt1(color(black) msym(O) msize(medlarge)) lag_ci_opt1(color(black) lw(medthick))
graph export "$output/figures/FigureA7d.pdf", as(pdf) replace

eststo clear
eventstudyinteract asinhTerritorio_cc lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_terr == 1, vce(cluster codcom) absorb(i.codcom i.anno i.rel_year_ele i.codreg#i.anno) cohort(fytb) control_cohort(nt) covariates($controls)
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)
event_plot sa_b#sa_v, stub_lag(lag# lag#) stub_lead(lead# lead#) trimlead(5) trimlag(5) plottype(connected) ciplottype(rcap) together noautolegend ///
	graph_opt(xtitle("Years since treatment") ///
	ytitle("Coefficients estimates (95% CI)") ///
	title("(IHS) Environmental and Urban Expenses") ///
	xlabel(-5(1)5) ///
	ylabel(-1.5(0.5)1.5) ///
	yline(0, lp(dash) lc(gs8)) ///
	xline(-1, lp(dash) lc(gs8)) ///
	legend(off)) ///
	lag_opt1(color(black) msym(O) msize(medlarge)) lag_ci_opt1(color(black) lw(medthick))
graph export "$output/figures/FigureA7e.pdf", as(pdf) replace

eststo clear
eventstudyinteract speed_Territorio lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_terr == 1, vce(cluster codcom) absorb(i.codcom i.anno i.rel_year_ele i.codreg#i.anno) cohort(fytb) control_cohort(nt) covariates($controls)
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)
event_plot sa_b#sa_v, stub_lag(lag# lag#) stub_lead(lead# lead#) trimlead(5) trimlag(5) plottype(connected) ciplottype(rcap) together noautolegend ///
	graph_opt(xtitle("Years since treatment") ///
	ytitle("Coefficients estimates (95% CI)") ///
	title("Efficiency in Environmental and Urban Expenses") ///
	xlabel(-5(1)5) ///
	ylabel(-1(0.5)1) ///
	yline(0, lp(dash) lc(gs8)) ///
	xline(-1, lp(dash) lc(gs8)) ///
	legend(off)) ///
	lag_opt1(color(black) msym(O) msize(medlarge)) lag_ci_opt1(color(black) lw(medthick))
graph export "$output/figures/FigureA7f.pdf", as(pdf) replace

eststo clear
eventstudyinteract asinhAmminist_cc lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_amm == 1, vce(cluster codcom) absorb(i.codcom i.anno i.rel_year_ele i.codreg#i.anno) cohort(fytb) control_cohort(nt) covariates($controls)
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)
event_plot sa_b#sa_v, stub_lag(lag# lag#) stub_lead(lead# lead#) trimlead(5) trimlag(5) plottype(connected) ciplottype(rcap) together noautolegend ///
	graph_opt(xtitle("Years since treatment") ///
	ytitle("Coefficients estimates (95% CI)") ///
	title("(IHS) Administrative Expenses") ///
	xlabel(-5(1)5) ///
	ylabel(-1.5(0.5)1.5) ///
	yline(0, lp(dash) lc(gs8)) ///
	xline(-1, lp(dash) lc(gs8)) ///
	legend(off)) ///
	lag_opt1(color(black) msym(O) msize(medlarge)) lag_ci_opt1(color(black) lw(medthick))
graph export "$output/figures/FigureA7g.pdf", as(pdf) replace

eststo clear
eventstudyinteract speed_Amminist lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_amm == 1, vce(cluster codcom) absorb(i.codcom i.anno i.rel_year_ele i.codreg#i.anno) cohort(fytb) control_cohort(nt) covariates($controls)
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)
event_plot sa_b#sa_v, stub_lag(lag# lag#) stub_lead(lead# lead#) trimlead(5) trimlag(5) plottype(connected) ciplottype(rcap) together noautolegend ///
	graph_opt(xtitle("Years since treatment") ///
	ytitle("Coefficients estimates (95% CI)") ///
	title("Efficiency in Administrative Expenses") ///
	xlabel(-5(1)5) ///
	ylabel(-0.15(0.05)0.15) ///
	yline(0, lp(dash) lc(gs8)) ///
	xline(-1, lp(dash) lc(gs8)) ///
	legend(off)) ///
	lag_opt1(color(black) msym(O) msize(medlarge)) lag_ci_opt1(color(black) lw(medthick))
graph export "$output/figures/FigureA7h.pdf", as(pdf) replace

eststo clear
eventstudyinteract asinhIstruzione_cc lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_ist == 1, vce(cluster codcom) absorb(i.codcom i.anno i.rel_year_ele i.codreg#i.anno) cohort(fytb) control_cohort(nt) covariates($controls)
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)
event_plot sa_b#sa_v, stub_lag(lag# lag#) stub_lead(lead# lead#) trimlead(5) trimlag(5) plottype(connected) ciplottype(rcap) together noautolegend ///
	graph_opt(xtitle("Years since treatment") ///
	ytitle("Coefficients estimates (95% CI)") ///
	title("(IHS) Education Expenses") ///
	xlabel(-5(1)5) ///
	ylabel(-1.5(0.5)3) ///
	yline(0, lp(dash) lc(gs8)) ///
	xline(-1, lp(dash) lc(gs8)) ///
	legend(off)) ///
	lag_opt1(color(black) msym(O) msize(medlarge)) lag_ci_opt1(color(black) lw(medthick))
graph export "$output/figures/FigureA7i.pdf", as(pdf) replace

eststo clear
eventstudyinteract speed_Istruzione lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_ist == 1, vce(cluster codcom) absorb(i.codcom i.anno i.rel_year_ele i.codreg#i.anno) cohort(fytb) control_cohort(nt) covariates($controls)
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)
event_plot sa_b#sa_v, stub_lag(lag# lag#) stub_lead(lead# lead#) trimlead(5) trimlag(5) plottype(connected) ciplottype(rcap) together noautolegend ///
	graph_opt(xtitle("Years since treatment") ///
	ytitle("Coefficients estimates (95% CI)") ///
	title("Efficiency in Education Expenses") ///
	xlabel(-5(1)5) ///
	ylabel(-0.2(0.1)0.5) ///
	yline(0, lp(dash) lc(gs8)) ///
	xline(-1, lp(dash) lc(gs8)) ///
	legend(off)) ///
	lag_opt1(color(black) msym(O) msize(medlarge)) lag_ci_opt1(color(black) lw(medthick))
graph export "$output/figures/FigureA7j.pdf", as(pdf) replace

eststo clear
eventstudyinteract asinhSociale_cc lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_soc == 1, vce(cluster codcom) absorb(i.codcom i.anno i.rel_year_ele i.codreg#i.anno) cohort(fytb) control_cohort(nt) covariates($controls)
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)
event_plot sa_b#sa_v, stub_lag(lag# lag#) stub_lead(lead# lead#) trimlead(5) trimlag(5) plottype(connected) ciplottype(rcap) together noautolegend ///
	graph_opt(xtitle("Years since treatment") ///
	ytitle("Coefficients estimates (95% CI)") ///
	title("(IHS) Social Expenses") ///
	xlabel(-5(1)5) ///
	ylabel(-2(1)3) ///
	yline(0, lp(dash) lc(gs8)) ///
	xline(-1, lp(dash) lc(gs8)) ///
	legend(off)) ///
	lag_opt1(color(black) msym(O) msize(medlarge)) lag_ci_opt1(color(black) lw(medthick))
graph export "$output/figures/FigureA7k.pdf", as(pdf) replace

eststo clear
eventstudyinteract speed_Sociale lag* lead* if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_soc == 1, vce(cluster codcom) absorb(i.codcom i.anno i.rel_year_ele i.codreg#i.anno) cohort(fytb) control_cohort(nt) covariates($controls)
matrix sa_b = e(b_iw)
matrix sa_v = e(V_iw)
event_plot sa_b#sa_v, stub_lag(lag# lag#) stub_lead(lead# lead#) trimlead(5) trimlag(5) plottype(connected) ciplottype(rcap) together noautolegend ///
	graph_opt(xtitle("Years since treatment") ///
	ytitle("Coefficients estimates (95% CI)") ///
	title("Efficiency in Social Expenses") ///
	xlabel(-5(1)5) ///
	ylabel(-0.4(0.2)0.4) ///
	yline(0, lp(dash) lc(gs8)) ///
	xline(-1, lp(dash) lc(gs8)) ///
	legend(off)) ///
	lag_opt1(color(black) msym(O) msize(medlarge)) lag_ci_opt1(color(black) lw(medthick))
graph export "$output/figures/FigureA7l.pdf", as(pdf) replace
