********************************************************************************
* Figure A2
* Number of local elections per year with national election dates
* Output: $output/figures/FigureA2.pdf
********************************************************************************

clear all
set more off

use "$maindir/data/final_data.dta", clear
global controls "tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc"
global controls_base "tasso_occ_industr_91 tasso_occ_agric_91 inc_abitazioni_proprieta_91 indice_dip_anziani_91 incidenza_adul_dip_lau_91 tasso_occ_terz_91 inc_fam_disagio_econ_91 tasso_disocc_91"

*
preserve
keep if ever_natp_1 == 1 & ever_civp_1 == 1
collapse (count) codcom (max) nlse, by(anno)
tw connect codcom anno, lc(black) mc(black) ///
xline(1994, lc(gs8) lp(dash_dot)) ///
xline(1996, lc(gs8) lp(dash_dot)) ///
xline(2001, lc(gs6) lp(solid) lw(thick)) ///
xline(2006, lc(gs8) lp(dash_dot)) ///
xline(2008, lc(gs6) lp(solid) lw(thick)) ///
xline(2013, lc(gs8) lp(dash_dot)) ///
ytitle("N. of local elections") ///
xtitle("Years")
graph export "$output/figures/FigureA2.pdf", as(pdf) replace
restore
