********************************************************************************
* Figure A3
* Balance: coefplot of 1991 controls regressed on NLCE exposure
* Output: $output/figures/FigureA3.pdf
********************************************************************************

clear all
set more off

use "$maindir/data/final_data.dta", clear
global controls "tasso_occ_industr tasso_occ_agric inc_abitazioni_proprieta indice_dip_anziani incidenza_adul_dip_lau tasso_occ_terz inc_fam_disagio_econ tasso_disocc"
global controls_base "tasso_occ_industr_91 tasso_occ_agric_91 inc_abitazioni_proprieta_91 indice_dip_anziani_91 incidenza_adul_dip_lau_91 tasso_occ_terz_91 inc_fam_disagio_econ_91 tasso_disocc_91"

*
preserve
collapse (max) nlse indice_dip_anziani_91 incidenza_stranieri_91 ampiezza_media_famiglie_91 inc_abitazioni_proprieta_91 incidenza_adul_dip_lau_91 tasso_disocc_91 tasso_occ_agric_91 tasso_occ_industr_91 tasso_occ_terz_91 inc_occ_bass_comp_91 inc_fam_disagio_econ_91 densita_demografica_91 codreg codpro, by(codcom)
foreach x of varlist indice_dip_anziani_91 incidenza_stranieri_91 ampiezza_media_famiglie_91 inc_abitazioni_proprieta_91 incidenza_adul_dip_lau_91 tasso_disocc_91 tasso_occ_agric_91 tasso_occ_industr_91 tasso_occ_terz_91 inc_occ_bass_comp_91 inc_fam_disagio_econ_91 densita_demografica_91 {
	egen sd = sd(`x')
	egen mean = mean(`x')
	cap gen `x'_sd = (`x' - mean) / sd
	drop sd mean
}
eststo clear
local c = 0
foreach x of varlist indice_dip_anziani_91_sd incidenza_stranieri_91_sd ampiezza_media_famiglie_91_sd inc_abitazioni_proprieta_91_sd incidenza_adul_dip_lau_91_sd tasso_disocc_91_sd tasso_occ_agric_91_sd tasso_occ_industr_91_sd tasso_occ_terz_91_sd inc_occ_bass_comp_91_sd inc_fam_disagio_econ_91_sd densita_demografica_91_sd {
	local c = `c' + 1
	di `c'
	qui eststo est_`c': reg nlse `x' i.codpro, vce(cl codpro)
}
label variable densita_demografica_91_sd "Demographic density (1991)"
label variable indice_dip_anziani_91_sd "Elderly dependency index (1991)"
label variable incidenza_stranieri_91_sd "Foreigners' incidence index (1991)"
label variable incidenza_adul_dip_lau_91_sd "High education rate (1991)"
label variable ampiezza_media_famiglie_91_sd "Average household size (1991)"
label variable inc_abitazioni_proprieta_91_sd "Homeownership rate (1991)"
label variable tasso_disocc_91_sd "Unemployment rate (1991)"
label variable tasso_occ_agric_91_sd "Employment rate in agriculture (1991)"
label variable tasso_occ_industr_91_sd "Employment rate in industry (1991)"
label variable tasso_occ_terz_91_sd "Employment rate in services (1991)"
label variable inc_occ_bass_comp_91_sd "Incidence of low-skilled jobs (1991)"
label variable inc_fam_disagio_econ_91_sd "Families below poverty line (1991)"
coefplot est_1 est_2 est_3 est_4 est_5 est_6 est_7 est_8 est_9 est_10 ///
	est_11 est_12, ///
	drop(_cons *codpro) sort ///
	xline(0, lp(dash) lc(gs8)) ///
	title("Exposure to concurrent national-local elections", size(medium small)) ///
	xlabel(,labsize(small)) ///
	ylabel(, labsize(small)) ///
	mcolor(black) msymbol(O) mlabposition(12) mlabsize(small) ///
	ciopts(lc(black) recast(rcap)) ///
	yscale(reverse) ///
	ytitle("", size(medium)) ///
	legend(off) ///
	scheme(stcolor)
graph export "$output/figures/FigureA3.pdf", as(pdf) replace
restore
