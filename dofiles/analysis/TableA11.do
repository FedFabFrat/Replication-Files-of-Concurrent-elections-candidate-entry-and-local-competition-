********************************************************************************
* Table A11
* Robustness: electoral outcomes - restricted post-treatment period (t+2)
* Output: $output/tables/TableA11.tex
********************************************************************************

clear all
set more off

use "$maindir/data/final_data.dta", clear
global controls "tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc"
global controls_base "tasso_occ_industr_91 tasso_occ_agric_91 inc_abitazioni_proprieta_91 indice_dip_anziani_91 incidenza_adul_dip_lau_91 tasso_occ_terz_91 inc_fam_disagio_econ_91 tasso_disocc_91"

* limit post-concurrency at t+2 *
bys codcom nlse_did (local_legi): gen count_post = _n if nlse_did == 1 & !inlist(year(ele_date),2001,2008)
sort codcom local_legi
replace count_post = count_post-1
recode count_post .=0

* ele out *
eststo clear
qui reghdfe sh_votes_civp_1st nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1 & count_post <= 2, a(codcom ele_date i.codreg#i.anno) vce(cl codcom)
cap gen esam = 1 if e(sample) == 1
eststo clear
foreach y of varlist sh_votes_natp_1st sh_votes_civp_1st natwin civwin inv_hhi {
	qui eststo `y'_1: reghdfe `y' nlse_did if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1 & count_post <= 2, a(codcom ele_date) vce(cl codcom)
	qui eststo `y'_2: reghdfe `y' nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1 & count_post <= 2, a(codcom ele_date) vce(cl codcom)
	qui eststo `y'_3: reghdfe `y' nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1 & count_post <= 2, a(codcom ele_date i.codreg#i.anno) vce(cl codcom)
	summ `y' if ever_natp_1 == 1 & ever_civp_1 == 1 & esam == 1
	local mean_`y': display %10.3f r(mean)
}
esttab, b (3) se starlevels(* 0.10 ** 0.05 *** 0.01) keep(nlse_did)
local panel_A_prehead "\begin{table}[!h]\centering\begin{threeparttable}" ///
 "\caption{Concurrent national-local elections, electoral outcomes. Restricting the post-treatment period.}\label{tab:ele-out-res-tpost}" ///
 "\begin{tabular}{lcccccc} \hline\hline"
local panel_A_posthead "\multicolumn{1}{l}{\textit{Panel A:}} & \multicolumn{3}{c}{\textit{\shortstack{Sh. votes of nationally-\\established party}}} & \multicolumn{3}{c}{\textit{\shortstack{Sh. votes of \\independent party}}} \\ \cmidrule(lr){1-1} \cmidrule(lr){2-4} \cmidrule(lr){5-7} "
local panel_A_prefoot ""
local panel_A_postfoot "\hline Mean Y & `mean_sh_votes_natp_1st' & `mean_sh_votes_natp_1st' & `mean_sh_votes_natp_1st' &`mean_sh_votes_civp_1st' & `mean_sh_votes_civp_1st' & `mean_sh_votes_civp_1st' \\"
local panel_B_prehead "\\"
local panel_B_posthead "\multicolumn{1}{l}{\textit{Panel B:}} & \multicolumn{3}{c}{\textit{\shortstack{Pr. victory of nationally-\\established party}}} & \multicolumn{3}{c}{\textit{\shortstack{Pr. victory of \\independent party}}} \\ \cmidrule(lr){1-1} \cmidrule(lr){2-4} \cmidrule(lr){5-7} "
local panel_B_prefoot "\hline"
local panel_B_postfoot "Mean Y & `mean_natwin' & `mean_natwin' & `mean_natwin' &`mean_civwin' & `mean_civwin' & `mean_civwin' \\"
local panel_C_prehead "\\"
local panel_C_posthead "\multicolumn{1}{l}{\textit{Panel C:}} & \multicolumn{3}{c}{\textit{HHPC index}} \\ \cmidrule(lr){1-1} \cmidrule(lr){2-4} "
local panel_C_prefoot "\hline"
local notes ="\item \textit{\underline{Notes}:} Dependent variables: the local votes share of an independent/nationally-established party; the probability of victory at the local election for a independent/nationally-established party; the Herfindahl-Hirschman political competition index. " + ///
"The treatment variable, \textit{NLCE\textsubscript{i,t}}, refers to the DiD variable capturing exposure to national-local elections. " + ///
"Controls include: population; share of adults with a tertiary degree; employment rate in agriculture; employment rate in services; employment rate in commerce. " + ///
"Estimates include municipality and election date fixed effects, as well as region by year fixed effects. The post-concurrency period is restricted up to \textit{t+2}." + ///
"Municipality clustered standard errors in parentheses. * p$<$0.10, ** p$<$0.05, *** p$<$0.01. "
local panel_C_postfoot "Mean Y & `mean_inv_hhi' & `mean_inv_hhi' & `mean_inv_hhi' &&& \\ " ///
"\hline Municipality FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Ele. date FE &\checkmark&\checkmark&\checkmark&\checkmark&\checkmark&\checkmark\\ " ///
"Controls &&\checkmark&\checkmark&&\checkmark&\checkmark\\ " ///
"Region by Year FE &&&\checkmark&&&\checkmark\\ \hline\hline " ///
"\end{tabular} \begin{tablenotes} \scriptsize{`notes'} \end{tablenotes} \end{threeparttable} \end{table}"
// first panel
esttab sh_votes_natp_1st_1 sh_votes_natp_1st_2 sh_votes_natp_1st_3 sh_votes_civp_1st_1 sh_votes_civp_1st_2 sh_votes_civp_1st_3 using "$output/tables/TableA11.tex", ///
tex compress nomtitles replace b (3) se starlevels(* 0.10 ** 0.05 *** 0.01) keep(nlse_did) coeflabels(nlse_did "\textit{NLCE\textsubscript{i,t}}") ///
prehead("`panel_A_prehead'") posthead("`panel_A_posthead'") prefoot(`panel_A_prefoot') postfoot(`panel_A_postfoot') gaps noobs
// second panel
esttab natwin_1 natwin_2 natwin_3 civwin_1 civwin_2 civwin_3 using "$output/tables/TableA11.tex", ///
tex compress nomtitles append nonumbers b (3) se starlevels(* 0.10 ** 0.05 *** 0.01) keep(nlse_did) coeflabels(nlse_did "\textit{NLCE\textsubscript{i,t}}") ///
prehead("`panel_B_prehead'") posthead("`panel_B_posthead'") prefoot(`panel_B_prefoot') postfoot(`panel_B_postfoot') gaps noobs
// last panel
esttab inv_hhi_1 inv_hhi_2 inv_hhi_3 using "$output/tables/TableA11.tex", ///
tex compress nomtitles append nonumbers b (3) se starlevels(* 0.10 ** 0.05 *** 0.01) keep(nlse_did) coeflabels(nlse_did "\textit{NLCE\textsubscript{i,t}}") ///
prehead("`panel_C_prehead'") posthead("`panel_C_posthead'") prefoot(`panel_C_prefoot') postfoot(`panel_C_postfoot') gaps
