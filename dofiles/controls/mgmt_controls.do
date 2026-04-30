
*** set wd ***
cd "$data_controls/raw"



*** open and save in dta raw data ***
local myfilelist : dir . files"confini-epoca_*.xlsx"
di `myfilelist'	
foreach file of local myfilelist {
	di "`file'"
	local x = substr("`file'",15,2)
	di "`x'"
	if "`x'"=="01" {
	local reg "Piemonte"
	}
	else if "`x'"=="02" {
	local reg "ValleDA"
	}
	else if "`x'"=="03"{
	local reg "Lombardia"
	}
	else if "`x'"=="04"{
	local reg "Trentino"
	}
	else if "`x'"=="05"{
	local reg "Veneto"
	}
	else if "`x'"=="06"{
	local reg "Friuli VG"
	}
	else if "`x'"=="07"{
	local reg "Liguria"
	}
	else if "`x'"=="08"{
	local reg "EmiliaR"
	}
	else if "`x'"=="09"{
	local reg "Toscana"
	}
	else if "`x'"=="10"{
	local reg "Umbria"
	}
	else if "`x'"=="11"{
	local reg "Marche"
	}
	else if "`x'"=="12"{
	local reg "Lazio"
	}
	else if "`x'"=="13"{
	local reg "Abruzzi"
	}
	else if "`x'"=="14"{
	local reg "Molise"
	}
	else if "`x'"=="15"{
	local reg "Campania"
	}
	else if "`x'"=="16"{
	local reg "Puglia"
	}
	else if "`x'"=="17"{
	local reg "Basilicata"
	}
	else if "`x'"=="18"{
	local reg "Calabria"
	}
	else if "`x'"=="19"{
	local reg "Sicilia"
	}
	else if "`x'"=="20"{
	local reg "Sardegna"
	}
	import excel "`file'", sheet("`reg' 51-11 confepoca") firstrow allstring clear
	destring AnnoCP, replace
	drop if AnnoCP == .
	rename P1 popolazione_residente
	rename P7 densita_demografica
	rename P8 rapp_maschi_femm
	rename P11 indice_dip_anziani
	rename P13 indice_vecchiaia
	rename S1 incidenza_stranieri
	rename S3 incidenza_coppie_miste
	rename S4 tasso_occ_straniera
	rename S5 rapp_occ_ita_stra
	rename S6 rapp_disocc_ita_stra
	rename S8 indice_freq_scol_stra
	rename S9 rapp_freq_scol_ita_stra
	rename F1 ampiezza_media_famiglie
	rename A1 incidenza_abitazioni_proprieta
	rename I1 diff_genere_istr_sup
	rename I3 rapp_adul_dip_lau_su_lic_med
	rename I4 incidenza_analfabeti
	rename I5 usc_prec_istr
	rename I6 incidenza_adul_dip_lau
	rename I7 incidenza_giov_uni
	rename L2 partecipazione_mercato_lavoro_f
	rename L3 partecipazione_mercato_lavoro
	rename L4 incidenza_giov_nostud_nolav
	rename L5 rapp_giov_att_nonatt
	rename L7 tasso_disocc_f
	rename L8 tasso_disocc
	rename L9 tasso_disocc_giov
	rename L11 tasso_occ_f
	rename L12 tasso_occupazione
	rename L15 tasso_occ_agric
	rename L16 tasso_occ_industr
	rename L17 tasso_occ_terz
	rename L18 tasso_occ_comm
	rename L19 incidenza_occ_alta_media_spec
	rename L20 incidenza_occ_artig_ope_agric
	rename L21 incidenza_occ_bass_comp
	rename V6 incidenza_fam_disagio_econ
	rename V9 incidenza_fam_disagio_assist
// 	to add other, reference file: "$controls/raw/Variables confini storici 1951-2011.xlsx"
	keep AnnoCP Livelloterritoriale CodiceRegione2011 CodiceProvincia2011 CodiceComuneallepoca ///
	Codicecomune2011 Denominazionedelterritorio Flagcomuniconvariazionianno ///
	popolazione_residente	densita_demografica	rapp_maschi_femm	indice_dip_anziani	indice_vecchiaia	///
	incidenza_stranieri	incidenza_coppie_miste	tasso_occ_straniera	rapp_occ_ita_stra	rapp_disocc_ita_stra	///
	indice_freq_scol_stra	rapp_freq_scol_ita_stra	ampiezza_media_famiglie	incidenza_abitazioni_proprieta	diff_genere_istr_sup	///
	rapp_adul_dip_lau_su_lic_med	incidenza_analfabeti	usc_prec_istr	incidenza_adul_dip_lau	incidenza_giov_uni	///
	partecipazione_mercato_lavoro_f	partecipazione_mercato_lavoro	incidenza_giov_nostud_nolav	rapp_giov_att_nonatt	///
	tasso_disocc_f	tasso_disocc	tasso_disocc_giov	tasso_occ_f	tasso_occupazione	tasso_occ_agric	tasso_occ_industr	///
	tasso_occ_terz	tasso_occ_comm	incidenza_occ_alta_media_spec	incidenza_occ_artig_ope_agric	incidenza_occ_bass_comp	///
	incidenza_fam_disagio_econ	incidenza_fam_disagio_assist	tasso_occ_industr	tasso_occ_terz	tasso_occ_comm	///
	incidenza_occ_alta_media_spec	incidenza_occ_artig_ope_agric	incidenza_occ_bass_comp	incidenza_fam_disagio_econ	///
	incidenza_fam_disagio_assist
	gen regione="`reg'"
	local outfile=subinstr("`file'",".xlsx","",.)
	save "`outfile'.dta", replace
}


*** append data ***
clear
local myfilelist : dir . files"confini-epoca_*.dta"
foreach file of local myfilelist {
	append using `file'
}



*** data management ***


** drop special statute regions **
// drop if inlist(regione,"Sicilia","Sardegna","ValleDA","Trentino")


** destring **
sort Codicecomune2011 AnnoCP
foreach var of varlist Livelloterritoriale CodiceRegione2011 CodiceProvincia2011 CodiceComuneallepoca Codicecomune2011 popolazione_residente	densita_demografica	rapp_maschi_femm	indice_dip_anziani	indice_vecchiaia	incidenza_stranieri	incidenza_coppie_miste	tasso_occ_straniera	rapp_occ_ita_stra	rapp_disocc_ita_stra	indice_freq_scol_stra	rapp_freq_scol_ita_stra	ampiezza_media_famiglie	incidenza_abitazioni_proprieta	diff_genere_istr_sup	rapp_adul_dip_lau_su_lic_med	incidenza_analfabeti	usc_prec_istr	incidenza_adul_dip_lau	incidenza_giov_uni	partecipazione_mercato_lavoro_f	partecipazione_mercato_lavoro	incidenza_giov_nostud_nolav	rapp_giov_att_nonatt	tasso_disocc_f	tasso_disocc	tasso_disocc_giov	tasso_occ_f	tasso_occupazione	tasso_occ_agric	tasso_occ_industr	tasso_occ_terz	tasso_occ_comm	incidenza_occ_alta_media_spec	incidenza_occ_artig_ope_agric	incidenza_occ_bass_comp	incidenza_fam_disagio_econ	incidenza_fam_disagio_assist{
	replace `var' = strtrim(`var')
	replace `var' = "." if strpos(`var',"…") > 0
	replace `var' = "." if `var' == "-"
	replace `var' = "." if `var' == ""
	destring `var', replace
}


** rename **
rename Denominazionedelterritorio Comune
rename incidenza_abitazioni_proprieta inc_abitazioni_proprieta
rename partecipazione_mercato_lavoro part_mercato_lavoro
rename partecipazione_mercato_lavoro_f part_mercato_lavoro_f
rename incidenza_occ_alta_media_spec inc_occ_alta_media_spec
rename incidenza_occ_artig_ope_agric inc_occ_artig_ope_agric
rename incidenza_occ_bass_comp inc_occ_bass_comp
rename incidenza_fam_disagio_econ inc_fam_disagio_econ
rename incidenza_fam_disagio_assist inc_fam_disagio_assist
rename Codicecomune2011 codcom


** reshape **
rename CodiceComuneallepoca codcom_
drop if AnnoCP==.
keep if AnnoCP >= 1991

* keep mostly balanced panel of municipalities *
duplicates report codcom AnnoCP 
duplicates drop codcom AnnoCP, force
// bys codcom (AnnoCP): egen n_anni = seq()
// bys codcom (AnnoCP): egen ma_n_anni = max(n_anni)
// keep if ma_n_anni == 3 // may want to revisit this
// drop ma_n_anni n_anni
reshape wide popolazione_residente	densita_demografica	rapp_maschi_femm	indice_dip_anziani	indice_vecchiaia	incidenza_stranieri	incidenza_coppie_miste	tasso_occ_straniera	rapp_occ_ita_stra	rapp_disocc_ita_stra	indice_freq_scol_stra	rapp_freq_scol_ita_stra	ampiezza_media_famiglie	inc_abitazioni_proprieta	diff_genere_istr_sup	rapp_adul_dip_lau_su_lic_med	incidenza_analfabeti	usc_prec_istr	incidenza_adul_dip_lau	incidenza_giov_uni	part_mercato_lavoro_f	part_mercato_lavoro	incidenza_giov_nostud_nolav	rapp_giov_att_nonatt	tasso_disocc_f	tasso_disocc	tasso_disocc_giov	tasso_occ_f	tasso_occupazione	tasso_occ_agric	tasso_occ_industr	tasso_occ_terz	tasso_occ_comm	inc_occ_alta_media_spec	inc_occ_artig_ope_agric	inc_occ_bass_comp	inc_fam_disagio_econ	inc_fam_disagio_assist Comune codcom_, i(codcom) j(AnnoCP)

* sorting and adjusting a few city names *
sort codcom 
replace Comune1991="brione (bs)" if Comune1991=="Brione" & regione=="Lombardia"
replace Comune1991="brione (tn)" if Comune1991=="Brione" & regione=="Trentino"
replace Comune2001=Comune1991 if  Comune1991=="Contarina" & Comune2001==""
replace codcom_2001=codcom_1991 if  Comune1991=="Contarina" & codcom_2001==.
replace Comune2001=Comune1991 if  Comune1991=="Massa Fiscaglia" & Comune2001==""
replace codcom_2001=codcom_1991 if  Comune1991=="Massa Fiscaglia" & codcom_2001==.
replace Comune2001=Comune2011 if  Comune2011=="Baranzate" & Comune2001==""
replace codcom_2001=codcom_2011 if Comune2011=="Baranzate" & codcom_2001==.



*** save dataset ***
save "$data_controls/controls_9111.dta", replace










