********************************************************************************
* Table A1
* Descriptive statistics of main variables
* Output: $output/tables/TableA1.tex
********************************************************************************

clear all
set more off

use "$maindir/data/final_data.dta", clear
global controls "tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc"
global controls_base "tasso_occ_industr_91 tasso_occ_agric_91 inc_abitazioni_proprieta_91 indice_dip_anziani_91 incidenza_adul_dip_lau_91 tasso_occ_terz_91 inc_fam_disagio_econ_91 tasso_disocc_91"

*
label variable densita_demografica "Demographic density"
label variable indice_dip_anziani "Elderly dependency index"
label variable incidenza_stranieri "Foreigners' incidence index"
label variable ampiezza_media_famiglie "Average household size"
label variable inc_abitazioni_proprieta "Homeownership rate"
label variable incidenza_adul_dip_lau "High education rate"
label variable tasso_disocc "Unemployment rate"
label variable tasso_occ_agric "Employment rate in agriculture"
label variable tasso_occ_industr "Employment rate in industry"
label variable tasso_occ_terz "Employment rate in services"
label variable tasso_occ_comm "Employment rate in commerce"
label variable inc_occ_bass_comp "Incidence of low-skilled jobs"
label variable inc_fam_disagio_econ "Families below poverty line"
label variable sh_votes_natp_1st "Local share of votes of local nat-.established party"
label variable sh_votes_civp_1st "Local share of votes of independent party"
label variable natwin "Pr. victory of nat.-established party"
label variable civwin "Pr. victory of independet party"
label variable n_cand "N. of candidates"
label variable inv_hhi "HHPC index"
label variable n_natp "N. of candidates of nat.-established parties"
label variable n_civp "N. of candidates of independent parties"
label variable nlse_did "NLCE DiD"

local prehead1 	"\begin{table}[!h]\centering\small\begin{threeparttable}" ///
				"\caption{Descriptive statistics of main variables}\label{tab:ds}" ///
				"\begin{tabular}{lccccc} \hline \hline" ///
				"  & Mean & SD  & Min  & p50 & Max  \\  \hline " ///
				"\addlinespace"
local prehead2 	"%"
local prehead3  "%"
local posthead1	"\textit{\underline{Outcome}}& & & & & \\" ///
                "\addlinespace"
local posthead2	"\textit{\underline{Treatment}}& & & & & \\" ///
                "\addlinespace"
local posthead3	"\textit{\underline{Controls}}& & & & & \\" ///
                "\addlinespace"
local prefoot1 	"& & & & & \\"
local prefoot2 	"& & & & & \\"
local prefoot3 	"\hline"
local postfoot1 "%"
local postfoot2 "%"
local notes = "\item \textit{\underline{Notes.}} This table shows the descriptive statistics of the main variables used in the analysis."
local postfoot3 "\hline\hline \end{tabular} \begin{tablenotes} \scriptsize{`notes'} \end{tablenotes} \end{threeparttable} \end{table}"
qui reghdfe n_cand nlse_did $controls if ever_natp_1 == 1 & ever_civp_1 == 1, a(codcom ele_date i.codreg#i.anno) vce(cl codcom)
gen temp_samp = 1 if e(sample) == 1
*outcomes
estpost sum n_cand inv_hhi n_civp n_natp sh_votes_natp_1st sh_votes_civp_1st natwin civwin if ever_natp_1 == 1 & ever_civp_1 == 1 & temp_samp == 1, detail
esttab using "$output/tables/TableA1.tex", tex fragment label nomtitles nonumbers mlabels(,none) collabels(,none) cells("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) p50(fmt(3)) max(fmt(3))") title("Descriptive Statistics") prehead("`prehead1'") posthead("`posthead1'") prefoot("`prefoot1'") postfoot("`postfoot1'") noobs replace
eststo clear
*variables of interest
estpost sum nlse_did if ever_natp_1 == 1 & ever_civp_1 == 1 & temp_samp == 1, detail
esttab using "$output/tables/TableA1.tex", label compress nomtitles nonumbers mlabels(,none) collabels(,none) cells("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) p50(fmt(3)) max(fmt(3))") prehead("`prehead2'") posthead("`posthead2'") prefoot("`prefoot2'") postfoot("`postfoot2'") noobs append
eststo clear
*controls
estpost sum indice_dip_anziani incidenza_stranieri ampiezza_media_famiglie inc_abitazioni_proprieta incidenza_adul_dip_lau tasso_disocc tasso_occ_agric tasso_occ_industr tasso_occ_terz inc_occ_bass_comp inc_fam_disagio_econ densita_demografica if ever_natp_1 == 1 & ever_civp_1 == 1 & temp_samp == 1, detail
esttab using "$output/tables/TableA1.tex", tex fragment label compress nomtitles nonumbers mlabels(,none) collabels(,none) cells("mean(fmt(3)) sd(fmt(3)) min(fmt(3)) p50(fmt(3)) max(fmt(3))") prehead("`prehead3'") posthead("`posthead3'") prefoot("`prefoot1'") postfoot("`postfoot3'") noobs append
eststo clear
