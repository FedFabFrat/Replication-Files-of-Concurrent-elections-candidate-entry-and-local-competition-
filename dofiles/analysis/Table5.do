********************************************************************************
* Table 5
* Concurrent national-local elections and local spending by type
* Output: $output/tables/Table5.tex
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

cap drop esam_*
eststo clear
qui eststo c2: reghdfe speed_Spese nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_spend = 1 if e(sample) == 1
summ speed_Spese if e(sample) == 1
local mean_speed_Spese: display %10.3f r(mean)
qui eststo c1: reghdfe asinhSpese_cc nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_spend == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
summ asinhSpese_cc  if e(sample) == 1
local mean_asinhSpese_cc : display %10.3f r(mean)

qui eststo c4: reghdfe speed_Sviluppo nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_svil = 1 if e(sample) == 1
summ speed_Sviluppo if e(sample) == 1
local mean_speed_Sviluppo : display %10.3f r(mean)
qui eststo c3: reghdfe asinhSviluppo_cc nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_svil == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
summ asinhSviluppo_cc if e(sample) == 1
local mean_asinhSviluppo_cc : display %10.3f r(mean)

qui eststo c6: reghdfe speed_Territorio nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_terr = 1 if e(sample) == 1
summ speed_Territorio if e(sample) == 1
local mean_speed_Territorio : display %10.3f r(mean)
qui eststo c5: reghdfe asinhTerritorio_cc nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_terr == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
summ asinhTerritorio_cc if e(sample) == 1
local mean_asinhTerritorio_cc : display %10.3f r(mean)

qui eststo c8: reghdfe speed_Amminist nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_amm = 1 if e(sample) == 1
summ speed_Amminist if e(sample) == 1
local mean_speed_Amminist: display %10.3f r(mean)
qui eststo c7: reghdfe asinhAmminist_cc nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_amm == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
summ asinhAmminist_cc  if e(sample) == 1
local mean_asinhAmminist_cc : display %10.3f r(mean)

qui eststo c9: reghdfe speed_Istruzione nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_ist = 1 if e(sample) == 1
summ speed_Istruzione if e(sample) == 1
local mean_speed_Istruzione : display %10.3f r(mean)
qui eststo c10: reghdfe asinhIstruzione_cc nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_ist == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
summ asinhIstruzione_cc if e(sample) == 1
local mean_asinhIstruzione_cc : display %10.3f r(mean)

qui eststo c12: reghdfe speed_Sociale nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
gen esam_soc = 1 if e(sample) == 1
summ speed_Sociale if e(sample) == 1
local mean_speed_Sociale : display %10.3f r(mean)
qui eststo c11: reghdfe asinhSociale_cc nlse_did $controls $mayorc if ever_natp_1 == 1 & ever_civp_1 == 1 & esam_soc == 1, a(codcom anno i.rel_year_ele i.rel_year_ele i.codreg#i.anno) vce(cl codcom)
summ asinhSociale_cc if e(sample) == 1
local mean_asinhSociale_cc : display %10.3f r(mean)

esttab c* , b (3) se starlevels(* 0.10 ** 0.05 *** 0.01) keep(nlse_did)

local panel_A_prehead "\begin{table}[!h]\centering\begin{threeparttable}\scriptsize" ///
 "\caption{Concurrent national-local elections, local spending by type.}\label{tab:nlse-spending}" ///
 "\begin{tabular}{lcccccc} \hline\hline"
local panel_A_posthead "& \multicolumn{1}{c}{\textit{\shortstack{Total expenses \\ (IHS)}}} & \multicolumn{1}{c}{\textit{\shortstack{Efficiency\\ Tot. expenses}}} & \multicolumn{1}{c}{\textit{\shortstack{Tot. econ. \\ development (IHS)}}} & \multicolumn{1}{c}{\textit{\shortstack{Efficiency \\ econ. dev.}}} & \multicolumn{1}{c}{\textit{\shortstack{Tot. env \\ and urban (IHS)}}} & \multicolumn{1}{c}{\textit{\shortstack{Efficiency \\ env. and urban}}} \\ \cmidrule(lr){2-2} \cmidrule(lr){3-3} \cmidrule(lr){4-4} \cmidrule(lr){5-5} \cmidrule(lr){6-6} \cmidrule(lr){7-7} "
local panel_A_prefoot "\hline "
local panel_A_postfoot "Mean Y & `mean_asinhSpese_cc' & `mean_speed_Spese' & `mean_asinhSviluppo_cc' & `mean_speed_Sviluppo' & `mean_asinhTerritorio_cc' & `mean_speed_Territorio' \\"
local panel_B_prehead "\\ "
local panel_B_posthead "& \multicolumn{1}{c}{\textit{\shortstack{Total admin. \\ (IHS)}}} & \multicolumn{1}{c}{\textit{\shortstack{Efficiency\\ admin.}}} & \multicolumn{1}{c}{\textit{\shortstack{Tot. educ. \\ (IHS)}}} & \multicolumn{1}{c}{\textit{\shortstack{Efficiency \\ educ.}}} & \multicolumn{1}{c}{\textit{\shortstack{Tot. social \\ (IHS)}}} & \multicolumn{1}{c}{\textit{\shortstack{Efficiency \\ social}}} \\ \cmidrule(lr){2-2} \cmidrule(lr){3-3} \cmidrule(lr){4-4} \cmidrule(lr){5-5} \cmidrule(lr){6-6} \cmidrule(lr){7-7} "
local panel_B_prefoot "\\ \hline"
local notes ="\item \textit{\underline{Notes}:} The dependent variables are: total commited expenses (IHS) and the ratio between actual and committed total expenses; commited expenses on economic development (IHS) and the ratio between actual and committed expenses on economic development; commited expenses on environmental and urban development (IHS) and the ratio between actual and committed expenses on environmental and urban development; commited expenses on administrative activities (IHS) and the ratio between actual and committed expenses on administrative activities; commited expenses on education (IHS) and the ratio between actual and committed expenses on education; commited expenses on social welfare (IHS) and the ratio between actual and committed expenses on social welfare. " + ///
"The treatment variable, \textit{NLCE\textsubscript{i,t}}, refers to the DiD variable capturing exposure to national-local elections. " + ///
"Controls include: population; share of adults with a tertiary degree; employment rate in agriculture; employment rate in services; employment rate in commerce; mayor education; mayor age; if mayor is from the city; if mayor has past office experience; mayor gender. " + ///
"Estimates include municipality and year fixed effects, region by year fixed effects, as well as relative to the election year fixed effects. " + ///
"Municipality clustered standard errors in parentheses. * p$<$0.10, ** p$<$0.05, *** p$<$0.01. "
local panel_B_postfoot "Mean Y & `mean_asinhAmminist_cc' & `mean_speed_Amminist' & `mean_asinhIstruzione_cc' & `mean_speed_Istruzione' & `mean_asinhSociale_cc' & `mean_speed_Sociale' \\ " ///
"Municipality FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Ele. date FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Controls &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Rel. to ele. year FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Region $\times$ Year FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ \hline\hline " ///
"\end{tabular} \begin{tablenotes} \scriptsize{`notes'} \end{tablenotes} \end{threeparttable} \end{table}"
esttab c1 c2 c3 c4 c5 c6 using "$output/tables/Table5.tex", ///
tex compress nomtitles replace b (3) se starlevels(* 0.10 ** 0.05 *** 0.01) keep(nlse_did) coeflabels(nlse_did "\textit{NLCE\textsubscript{i,t}}") ///
prehead("`panel_A_prehead'") posthead("`panel_A_posthead'") prefoot(`panel_A_prefoot') postfoot(`panel_A_postfoot') gaps
esttab c7 c8 c9 c10 c11 c12 using "$output/tables/Table5.tex", ///
tex compress nomtitles append nonumbers b (3) se starlevels(* 0.10 ** 0.05 *** 0.01) keep(nlse_did) coeflabels(nlse_did "\textit{NLCE\textsubscript{i,t}}") ///
prehead("`panel_B_prehead'") posthead("`panel_B_posthead'") prefoot(`panel_B_prefoot') postfoot(`panel_B_postfoot') gaps
