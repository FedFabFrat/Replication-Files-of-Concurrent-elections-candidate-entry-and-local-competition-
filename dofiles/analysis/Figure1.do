********************************************************************************
* Figure 1
* Time trends in local electoral outcomes (1991-2019)
* Output: $output/figures/Figure1a.pdf, inv_hhi.pdf, sh_votes.pdf, pwin.pdf,
*         n_cand.pdf
********************************************************************************

clear all
set more off

use "$maindir/data/final_data.dta", clear
global controls "tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc"
global controls_base "tasso_occ_industr_91 tasso_occ_agric_91 inc_abitazioni_proprieta_91 indice_dip_anziani_91 incidenza_adul_dip_lau_91 tasso_occ_terz_91 inc_fam_disagio_econ_91 tasso_disocc_91"

* descriptive evidence and stats *

*
preserve
keep if ever_natp_1 == 1 & ever_civp_1 == 1
collapse (mean) sh_votes_natp_1st sh_votes_civp_1st natwin civwin n_cand n_civp n_natp inv_hhi, by(anno)
foreach x of varlist sh_votes_natp_1st sh_votes_civp_1st natwin civwin n_cand n_civp n_natp inv_hhi {
	gen temp = `x' if anno == 1991
	egen matemp = max(temp)
	gen `x'_rel = `x'/matemp*100
	drop temp matemp
}
tw (line n_cand anno, lc(black) lw(medthick)), ///
legend(off) ///
ytitle("N. of candidates (1991 = 100)") ///
xtitle("Years") ///
title("Number of candidates")
graph export "$output/figures/Figure1a.pdf", as(pdf) replace

tw (line inv_hhi anno, lc(black) lw(medthick)), ///
legend(off) ///
ytitle("N. of local candidates (1991 = 100)") ///
xtitle("Years") ///
title("HHPC")
graph export "$output/figures/Figure1b.pdf", as(pdf) replace

tw (line sh_votes_natp_1st anno, lc(black) lw(medthick)) ///
(line sh_votes_civp_1st anno, lc(gs8) lw(medthick) lp(longdash)), ///
legend(pos(6) rows(1) order(1 "Nationally-established party" 2 "Indepentent party")) ///
ytitle("Local share of votes (1991 = 100)") ///
xtitle("Years") ///
title("Votes share by party type")
graph export "$output/figures/Figure1c.pdf", as(pdf) replace

tw (line natwin anno, lc(black) lw(medthick)) ///
(line civwin anno, lc(gs8) lw(medthick) lp(longdash)), ///
legend(pos(6) rows(1) order(1 "Nationally-established party" 2 "Indepentent party")) ///
ytitle("Pr. of victory (1991 = 100)") ///
xtitle("Years") ///
title("Pr. of victory by party type")
graph export "$output/figures/Figure1d.pdf", as(pdf) replace

tw (line n_natp anno, lc(black) lw(medthick)) ///
(line n_civp anno, lc(gs8) lw(medthick) lp(longdash)), ///
legend(pos(6) rows(1) order(1 "Nationally-established party" 2 "Indepentent party")) ///
ytitle("N. of local candidates (1991 = 100)") ///
xtitle("Years") ///
title("Number of candidates by party type")
graph export "$output/figures/Figure1e.pdf", as(pdf) replace
restore
