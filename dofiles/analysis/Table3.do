********************************************************************************
* Table 3
* Concurrent national-local elections and elected mayor characteristics
* Output: $output/tables/Table3.tex
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
foreach y of varlist educ may_born_city female age exp_in_office {
	qui eststo `y': reghdfe `y' nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1, a(codcom ele_date i.codreg#i.anno) vce(cl codcom)
	summ `y' if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1
	local mean_`y': display %10.3f r(mean)
}
local panel_A_prehead "\begin{table}[!h]\centering\begin{threeparttable}" ///
 "\caption{Concurrent national-local elections, elected mayors characteristics.}\label{tab:nlse-mayors}" ///
 "\begin{tabular}{lccccc} \hline\hline"
local panel_A_posthead "& \multicolumn{1}{c}{\textit{\shortstack{Education}}} & \multicolumn{1}{c}{\textit{\shortstack{Born in city}}} & \multicolumn{1}{c}{\textit{\shortstack{Female}}} & \multicolumn{1}{c}{\textit{\shortstack{Age}}} & \multicolumn{1}{c}{\textit{\shortstack{Exp. in office}}} \\ \cmidrule(lr){2-2} \cmidrule(lr){3-3} \cmidrule(lr){4-4} \cmidrule(lr){5-5} \cmidrule(lr){6-6} "
local panel_A_prefoot "\\ \hline"
local panel_A_prefoot "\\ \hline"
local notes ="\item \textit{\underline{Notes}:} Dependent variables: the education level of the mayor; a dummy equal to one if the mayor is born in the city she is elected in; a dummy equal to one if the gender of the mayor is female; the age of the mayor; a dummy equal to one if the mayor had previous experience in office. " + ///
"The treatment variable, \textit{NLCE\textsubscript{i,t}}, refers to the DiD variable capturing exposure to national-local elections. " + ///
"Controls include: population; share of adults with a tertiary degree; employment rate in agriculture; employment rate in services; employment rate in commerce. " + ///
"Estimates include municipality and election date fixed effects, as well as region by year fixed effects. " + ///
"Municipality clustered standard errors in parentheses. * p$<$0.10, ** p$<$0.05, *** p$<$0.01. "
local panel_A_postfoot "Mean Y & `mean_educ' & `mean_may_born_city' & `mean_female' &`mean_age' & `mean_exp_in_office' \\ " ///
"\hline Municipality FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Ele. date FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Controls &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Region $\times$ Year FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ \hline\hline " ///
"\end{tabular} \begin{tablenotes} \scriptsize{`notes'} \end{tablenotes} \end{threeparttable} \end{table}"
// first panel
esttab educ may_born_city female age exp_in_office using "$output/tables/Table3.tex", ///
tex compress nomtitles replace b (3) se starlevels(* 0.10 ** 0.05 *** 0.01) keep(nlse_did) coeflabels(nlse_did "\textit{NLCE\textsubscript{i,t}}") ///
prehead("`panel_A_prehead'") posthead("`panel_A_posthead'") prefoot(`panel_A_prefoot') postfoot(`panel_A_postfoot') gaps
