********************************************************************************
* Table 4
* Local revenues, taxes, and national transfers
* Output: $output/tables/Table4.tex
********************************************************************************

clear all
set more off

use "$maindir/data/final_data.dta", clear
global controls "tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc"
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
keep codcom anno tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc tasso_occ_industr_91 tasso_occ_agric_91 inc_abitazioni_proprieta_91 indice_dip_anziani_91 incidenza_adul_dip_lau_91 tasso_occ_terz_91 inc_fam_disagio_econ_91 tasso_disocc_91 codreg codpro ever_natp_1 ever_civp_1 Entr_* Totale_gen_* sub_cat_* risc_comp* Amminist_* Cultura_* Giustizia_* Polizia_* Servizi_* Sociale_* Sviluppo_* Territorio_* Turismo_* Viabilita_* Sport_* Spese_* ele_date _merge accertamenti* educ may_born_city female age exp_in_office local_legi
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
foreach x of varlist State_trasf Amminist Cultura Giustizia Polizia Servizi Sociale Sviluppo Territorio Turismo Viabilita Sport Spese Totale_gen_entr Tasse Imposte {
	gen ln`x' = ln(`x'+0.0001)
	gen asinh`x' = asinh(`x')
}
foreach x of varlist State_trasf_cc Amminist_cc Cultura_cc Giustizia_cc Polizia_cc Servizi_cc Sociale_cc Sviluppo_cc Territorio_cc Turismo_cc Viabilita_cc Sport_cc Spese_cc Totale_gen_entr_cc Tasse_cc Imposte_cc {
	gen ln`x' = ln(`x'+0.0001)
	gen asinh`x' = asinh(`x')
}
foreach x of varlist State_trasf Amminist Cultura Giustizia Polizia Servizi Sociale Sviluppo Territorio Turismo Viabilita Sport Spese Totale_gen_entr Tasse Imposte {
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

cap drop esam_entr esam_tax esam_state_trasf
eststo clear
qui eststo c2: reghdfe speed_Totale_gen_entr nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_entr = 1 if e(sample) == 1
summ speed_Totale_gen_entr if e(sample) == 1
local mean_speed_Totale_gen_entr: display %10.3f r(mean)
qui eststo c1: reghdfe asinhTotale_gen_entr_cc nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_entr == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
summ asinhTotale_gen_entr_cc  if e(sample) == 1
local mean_asinhTotale_gen_entr_cc : display %10.3f r(mean)

qui eststo c4: reghdfe speed_Tasse nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_tax = 1 if e(sample) == 1
summ speed_Tasse if e(sample) == 1
local mean_speed_Tasse: display %10.3f r(mean)
qui eststo c3: reghdfe asinhTasse_cc nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_tax == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
summ asinhTasse_cc  if e(sample) == 1
local mean_asinhTasse_cc : display %10.3f r(mean)

qui eststo c6: reghdfe speed_State_trasf nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_state_trasf = 1 if e(sample) == 1
summ speed_State_trasf if e(sample) == 1
local mean_speed_State_trasf : display %10.3f r(mean)
qui eststo c5: reghdfe asinhState_trasf_cc nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_state_trasf == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
summ asinhState_trasf if e(sample) == 1
local mean_asinhState_trasf : display %10.3f r(mean)

esttab c1 c2 c3 c4 c5 c6, b (3) se starlevels(* 0.10 ** 0.05 *** 0.01) keep(nlse_did)

local panel_A_prehead "\begin{table}[!h]\centering\begin{threeparttable}\scriptsize" ///
 "\caption{Concurrent national-local elections, local revenues, taxes and national transfers.}\label{tab:nlse-revenues}" ///
 "\begin{tabular}{lcccccc} \hline\hline"
local panel_A_posthead "& \multicolumn{1}{c}{\textit{\shortstack{Total revenues \\ (IHS)}}} & \multicolumn{1}{c}{\textit{\shortstack{Eff. coll.\\ Tot. revenues}}} & \multicolumn{1}{c}{\textit{\shortstack{Total taxes \\ (IHS)}}} & \multicolumn{1}{c}{\textit{\shortstack{Eff. coll. \\ Tot. taxes}}} & \multicolumn{1}{c}{\textit{\shortstack{Nat. transfers \\ (IHS)}}} & \multicolumn{1}{c}{\textit{\shortstack{Eff. coll. \\ Nat. trasnfers}}} \\ \cmidrule(lr){2-2} \cmidrule(lr){3-3} \cmidrule(lr){4-4} \cmidrule(lr){5-5} \cmidrule(lr){6-6} \cmidrule(lr){7-7} "
local panel_A_prefoot "\\ \hline"
local panel_A_prefoot "\\ \hline"
local notes ="\item \textit{\underline{Notes}:} The dependent variables are: collected total revenues (IHS) and the ratio between collected and accrued total revenues; collected total taxes (IHS) and the ratio between collected and accrued total taxes; received national transfers (IHS) and the ratio between received and accrued national transfers. " + ///
"The treatment variable, \textit{NLCE\textsubscript{i,t}}, refers to the DiD variable capturing exposure to national-local elections. " + ///
"Controls include: population; share of adults with a tertiary degree; employment rate in agriculture; employment rate in services; employment rate in commerce; mayor education; mayor age; if mayor is from the city; if mayor has past office experience; mayor gender. " + ///
"Estimates include municipality and year fixed effects, region by year fixed effects, as well as relative to the election year fixed effects. " + ///
"Municipality clustered standard errors in parentheses. * p$<$0.10, ** p$<$0.05, *** p$<$0.01. "
local panel_A_postfoot "Mean Y & `mean_asinhTotale_gen_entr_cc' & `mean_speed_Totale_gen_entr' & `mean_asinhTasse_cc' & `mean_speed_Tasse' & `mean_asinhState_trasf' & `mean_speed_State_trasf' \\ " ///
"\hline Municipality FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Year FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Controls &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Rel. to ele. year FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Region $\times$ Year FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ \hline\hline " ///
"\end{tabular} \begin{tablenotes} \scriptsize{`notes'} \end{tablenotes} \end{threeparttable} \end{table}"
esttab c1 c2 c3 c4 c5 c6 using "$output/tables/Table4.tex", ///
tex compress nomtitles replace b (3) se starlevels(* 0.10 ** 0.05 *** 0.01) keep(nlse_did) coeflabels(nlse_did "\textit{NLCE\textsubscript{i,t}}") ///
prehead("`panel_A_prehead'") posthead("`panel_A_posthead'") prefoot(`panel_A_prefoot') postfoot(`panel_A_postfoot') gaps
