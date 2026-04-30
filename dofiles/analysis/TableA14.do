********************************************************************************
* Table A14
* Robustness: mayor born in city - by population size
* Output: $output/tables/TableA14.tex
********************************************************************************

clear all
set more off

use "$maindir/data/final_data.dta", clear
global controls "tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc"
global controls_base "tasso_occ_industr_91 tasso_occ_agric_91 inc_abitazioni_proprieta_91 indice_dip_anziani_91 incidenza_adul_dip_lau_91 tasso_occ_terz_91 inc_fam_disagio_econ_91 tasso_disocc_91"

* merge mayors data *
rename comune_mayors comune_ele
rename name_winner name_winner_ele
merge 1:1 codcom anno using "$maindir/data/admin/mayors_chars_0525.dta"
keep if _merge == 3
drop _merge

* robustness mayor born *
qui reghdfe educ nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom ele_date i.codreg#i.anno) vce(cl codcom)
cap gen esam = 1 if e(sample) == 1
summ popolazione_residente_91 if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1, d
gen ab50 = 1 if popolazione_residente_91 >= r(p50)
recode ab50 .=0 if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1
eststo clear
qui eststo c1: reghdfe may_born_city nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1, a(codcom ele_date i.codreg#i.anno) vce(cl codcom)
summ may_born_city if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1
local mean_may_born_city1: display %10.3f r(mean)
qui eststo c2: reghdfe may_born_city nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1 & ab50 == 1, a(codcom ele_date i.codreg#i.anno) vce(cl codcom)
summ may_born_city if ever_natp_1 == 1 & ever_civp_1 == 1 & e(sample) == 1
local mean_may_born_city2: display %10.3f r(mean)
qui eststo c3: reghdfe may_born_city nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1 & ab50 == 0, a(codcom ele_date i.codreg#i.anno) vce(cl codcom)
summ may_born_city if ever_natp_1 == 1 & ever_civp_1 == 1 & e(sample) == 1
local mean_may_born_city3: display %10.3f r(mean)
qui eststo c4: reghdfe may_born_city nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1 & popolazione_residente_91 >= 10000, a(codcom ele_date i.codreg#i.anno) vce(cl codcom)
summ may_born_city if ever_natp_1 == 1 & ever_civp_1 == 1 & e(sample) == 1
local mean_may_born_city4: display %10.3f r(mean)
qui eststo c5: reghdfe may_born_city nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1 & popolazione_residente_91 >= 15000, a(codcom ele_date i.codreg#i.anno) vce(cl codcom)
summ may_born_city if ever_natp_1 == 1 & ever_civp_1 == 1 & e(sample) == 1
local mean_may_born_city5: display %10.3f r(mean)
esttab c*, b (3) se starlevels(* 0.10 ** 0.05 *** 0.01) keep(nlse_did)
local panel_A_prehead "\begin{table}[!h]\centering\begin{threeparttable}" ///
 "\caption{Concurrent national-local elections, mayor born in city and population size.}\label{tab:rob-mayor-born-rob}" ///
 "\begin{tabular}{lccccc} \hline\hline"
local panel_A_posthead "%%"
local panel_A_prefoot ""
local panel_A_prefoot "\hline"
local notes ="\item \textit{\underline{Notes}:} Dependent variables: a dummy equal to one if the mayor is born in the city she is elected in. " + ///
"The treatment variable, \textit{NLCE\textsubscript{i,t}}, refers to the DiD variable capturing exposure to national-local elections. " + ///
"Controls include: population; share of adults with a tertiary degree; employment rate in agriculture; employment rate in services; employment rate in commerce. " + ///
"The sample is restricted base on population at baseline (1991). Column (1) reports the unrestricted estimates. Column (2) restricts the sample to have population (1991) above the median (roughly 5'000). Column (3) restricts the sample to have population (1991) below the median (roughly 5'000). Column (4) restricts the sample to have population (1991) above 10'000. Column (5) restricts the sample to have population (1991) above 15'000. " + ///
"Estimates include municipality and election date fixed effects, as well as region by year fixed effects. " + ///
"Municipality clustered standard errors in parentheses. * p$<$0.10, ** p$<$0.05, *** p$<$0.01. "
local panel_A_postfoot "Mean Y & `mean_may_born_city1' & `mean_may_born_city2' & `mean_may_born_city3' & `mean_may_born_city4' & `mean_may_born_city5' \\ " ///
"\hline Population (1991) &&Above median&Below median&Above 10k&Above 15k\\ " ///
"Municipality FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Ele. date FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Controls &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Region $\times$ Year FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\  \hline\hline " ///
"\end{tabular} \begin{tablenotes} \scriptsize{`notes'} \end{tablenotes} \end{threeparttable} \end{table}"
// first panel
esttab c* using "$output/tables/TableA14.tex", ///
tex compress nomtitles replace b (3) se starlevels(* 0.10 ** 0.05 *** 0.01) keep(nlse_did) coeflabels(nlse_did "\textit{NLCE\textsubscript{i,t}}") ///
prehead("`panel_A_prehead'") posthead("`panel_A_posthead'") prefoot(`panel_A_prefoot') postfoot(`panel_A_postfoot') gaps
