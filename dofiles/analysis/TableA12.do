********************************************************************************
* Table A12
* Robustness: candidates entry - province-level clustering
* Output: $output/tables/TableA12.tex
********************************************************************************

clear all
set more off

use "$maindir/data/final_data.dta", clear
global controls "tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc"
global controls_base "tasso_occ_industr_91 tasso_occ_agric_91 inc_abitazioni_proprieta_91 indice_dip_anziani_91 incidenza_adul_dip_lau_91 tasso_occ_terz_91 inc_fam_disagio_econ_91 tasso_disocc_91"

* n_cand - change cluster *
qui reghdfe n_cand nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom ele_date i.codreg#i.anno) vce(cl codpro)
cap gen esam = 1 if e(sample) == 1
eststo clear
foreach y of varlist n_cand n_civp n_natp {
	qui eststo `y'_1: reghdfe `y' nlse_did if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1, a(codcom ele_date) vce(cl codpro)
	qui eststo `y'_2: reghdfe `y' nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1, a(codcom ele_date) vce(cl codpro)
	qui eststo `y'_3: reghdfe `y' nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1, a(codcom ele_date i.codreg#i.anno) vce(cl codpro)
	summ `y' if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1
	local mean_`y': display %10.3f r(mean)
}
local panel_A_prehead "\begin{table}[!h]\centering\begin{threeparttable}\scriptsize" ///
 "\caption{Concurrent national-local elections, candidates entry. Provincial cluster.}\label{tab:n-cand-codpro}" ///
 "\begin{tabular}{lccccccccc} \hline\hline"
local panel_A_posthead "\multicolumn{1}{l}{\textit{Panel A:}} & \multicolumn{3}{c}{\textit{Number of candidates}} & \multicolumn{3}{c}{\textit{\shortstack{N. cand. of nationally-\\established party}}} & \multicolumn{3}{c}{\textit{\shortstack{N. cand. of \\independent party}}} \\ \cmidrule(lr){1-1} \cmidrule(lr){2-4} \cmidrule(lr){5-7} \cmidrule(lr){8-10}"
local panel_A_prefoot ""
local panel_A_prefoot "\hline"
local notes ="\item \textit{\underline{Notes}:} Dependent variables: the number of candidates participating at the local election, overall and with a nationally-established/independent party. " + ///
"The treatment variable, \textit{NLCE\textsubscript{i,t}}, refers to the DiD variable capturing exposure to national-local elections. " + ///
"Controls include: population; share of adults with a tertiary degree; employment rate in agriculture; employment rate in services; employment rate in commerce. " + ///
"Estimates include municipality and election date fixed effects, as well as region by year fixed effects. " + ///
"Province clustered standard errors in parentheses. * p$<$0.10, ** p$<$0.05, *** p$<$0.01. "
local panel_A_postfoot "Mean Y & `mean_n_cand' & `mean_n_cand' & `mean_n_cand' & `mean_n_natp' & `mean_n_natp' & `mean_n_natp' &`mean_n_civp' & `mean_n_civp' & `mean_n_civp' \\ " ///
"\hline Municipality FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Ele. date FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Controls &&\checkmark&\checkmark&&\checkmark&\checkmark&&\checkmark&\checkmark\\ " ///
"Region $\times$ Year FE &&&\checkmark&&&\checkmark&&&\checkmark\\ \hline\hline " ///
"\end{tabular} \begin{tablenotes} \scriptsize{`notes'} \end{tablenotes} \end{threeparttable} \end{table}"
// first panel
esttab n_cand_1 n_cand_2 n_cand_3 n_natp_1 n_natp_2 n_natp_3 n_civp_1 n_civp_2 n_civp_3 using "$output/tables/TableA12.tex", ///
tex compress nomtitles replace b (3) se starlevels(* 0.10 ** 0.05 *** 0.01) keep(nlse_did) coeflabels(nlse_did "\textit{NLCE\textsubscript{i,t}}") ///
prehead("`panel_A_prehead'") posthead("`panel_A_posthead'") prefoot(`panel_A_prefoot') postfoot(`panel_A_postfoot') gaps
