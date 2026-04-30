clear all
set more off


**************************************************************************************************
**************************************************************************************************
**************************************************************************************************



**# Controls Dataset **
use "$data_controls/controls_9111.dta", clear

* manage comune name variable *
foreach x of varlist Comune1991 Comune2001 Comune2011 {
	replace `x' = strtrim(lower(`x'))
}



** preliminary data mgmt **
gen istat_code_110=codcom
replace istat_code_110=5043 if /*istat_code_110==999005043&*/  Comune1991=="colcavagno"
replace istat_code_110=5078 if /*istat_code_110==999005078 &*/ Comune1991=="montiglio" 
replace istat_code_110=5102 if /*istat_code_110==999005102 &*/ Comune1991=="scandeluzza"
replace istat_code_110=13076 if /*istat_code_110==999013076 &*/ Comune1991=="consiglio di rumo"
replace istat_code_110=13108 if /*istat_code_110==999013108 &*/ Comune1991=="germasino"
replace istat_code_110=13112 if /*istat_code_110==999013112 &*/ Comune1991=="gravedona"
replace istat_code_110=13208 if /*istat_code_110==999013208 &*/ Comune1991=="sant'abbondio"
replace istat_code_110=13210 if /*istat_code_110==999013210 &*/ Comune1991=="santa maria rezzonico"
replace istat_code_110=22014 if /*istat_code_110==999022014 &*/ Comune1991=="bezzecca"
replace istat_code_110=22016 if /*istat_code_110==999022016 &*/ Comune1991=="bleggio inferiore"
replace istat_code_110=22065 if /*istat_code_110==999022065 &*/ Comune1991=="concei"
replace istat_code_110=22107 if /*istat_code_110==999022107 &*/ Comune1991=="lomaso"
replace istat_code_110=22119 if /*istat_code_110==999022119 &*/ Comune1991=="molina di ledro"
replace istat_code_110=22141 if /*istat_code_110==999022141 &*/ Comune1991=="pieve di ledro"
replace istat_code_110=22197 if /*istat_code_110==999022197 &*/ Comune1991=="tiarno di sopra"
replace istat_code_110=22198 if /*istat_code_110==999022198 &*/ Comune1991=="tiarno di sotto"
replace istat_code_110=28024 if /*istat_code_110==999028024 &*/ Comune1991=="carrara san giorgio" 
replace istat_code_110=28025 if /*istat_code_110==999028025 &*/ Comune1991=="carrara santo stefano" 
replace istat_code_110=29016 if /*istat_code_110==999029016 &*/ Comune1991=="contarina" 
replace istat_code_110=29020 if /*istat_code_110==999029020 &*/ Comune1991=="donada"  
replace istat_code_110=30017 if /*istat_code_110==999030017 &*/ Comune1991=="campolongo al torre"
replace istat_code_110=30115 if /*istat_code_110==999030115 &*/ Comune1991=="tapogliano"
replace istat_code_110=2081 if /*istat_code_110==999096036 &*/ Comune1991=="mosso santa maria"
replace istat_code_110=2098 if /*istat_code_110==999096045 &*/ Comune1991=="pistolesa"
replace istat_code_110=29052 if /*istat_code_110==999096045 &*/ Comune1991=="contarina" | Comune1991=="donada" 
replace istat_code_110=28106 if /*istat_code_110==999096045 &*/ Comune1991=="carrara santo stefano" | Comune1991=="carrara san giorgio" 
replace codcom=28106 if /*istat_code_110==999096045 &*/ Comune1991=="carrara santo stefano" | Comune1991=="carrara san giorgio" 
replace codcom=29052 if /*istat_code_110==999096045 &*/ Comune1991=="contarina" | Comune1991=="donada" 
replace Comune1991="due carrare" if istat_code_110==28106
replace Comune1991="porto viro" if istat_code_110==29052

* collapse *
collapse (sum) popolazione_residente1991 popolazione_residente2001 popolazione_residente2011 (max) CodiceRegione2011 CodiceProvincia2011 Livelloterritoriale codcom (mean) densita_demografica1991 rapp_maschi_femm1991 indice_dip_anziani1991 indice_vecchiaia1991 incidenza_stranieri1991 incidenza_coppie_miste1991 tasso_occ_straniera1991 rapp_occ_ita_stra1991 rapp_disocc_ita_stra1991 indice_freq_scol_stra1991 rapp_freq_scol_ita_stra1991 ampiezza_media_famiglie1991 inc_abitazioni_proprieta1991 diff_genere_istr_sup1991 rapp_adul_dip_lau_su_lic_med1991 incidenza_analfabeti1991 usc_prec_istr1991 incidenza_adul_dip_lau1991 incidenza_giov_uni1991 part_mercato_lavoro_f1991 part_mercato_lavoro1991 incidenza_giov_nostud_nolav1991 rapp_giov_att_nonatt1991 tasso_disocc_f1991 tasso_disocc1991 tasso_disocc_giov1991 tasso_occ_f1991 tasso_occupazione1991 tasso_occ_agric1991 tasso_occ_industr1991 tasso_occ_terz1991 tasso_occ_comm1991 inc_occ_alta_media_spec1991 inc_occ_artig_ope_agric1991 inc_occ_bass_comp1991 inc_fam_disagio_econ1991 inc_fam_disagio_assist1991 densita_demografica2001 rapp_maschi_femm2001 indice_dip_anziani2001 indice_vecchiaia2001 incidenza_stranieri2001 incidenza_coppie_miste2001 tasso_occ_straniera2001 rapp_occ_ita_stra2001 rapp_disocc_ita_stra2001 indice_freq_scol_stra2001 rapp_freq_scol_ita_stra2001 ampiezza_media_famiglie2001 inc_abitazioni_proprieta2001 diff_genere_istr_sup2001 rapp_adul_dip_lau_su_lic_med2001 incidenza_analfabeti2001 usc_prec_istr2001 incidenza_adul_dip_lau2001 incidenza_giov_uni2001 part_mercato_lavoro_f2001 part_mercato_lavoro2001 incidenza_giov_nostud_nolav2001 rapp_giov_att_nonatt2001 tasso_disocc_f2001 tasso_disocc2001 tasso_disocc_giov2001 tasso_occ_f2001 tasso_occupazione2001 tasso_occ_agric2001 tasso_occ_industr2001 tasso_occ_terz2001 tasso_occ_comm2001 inc_occ_alta_media_spec2001 inc_occ_artig_ope_agric2001 inc_occ_bass_comp2001 inc_fam_disagio_econ2001 inc_fam_disagio_assist2001 densita_demografica2011 rapp_maschi_femm2011 indice_dip_anziani2011 indice_vecchiaia2011 incidenza_stranieri2011 incidenza_coppie_miste2011 tasso_occ_straniera2011 rapp_occ_ita_stra2011 rapp_disocc_ita_stra2011 indice_freq_scol_stra2011 rapp_freq_scol_ita_stra2011 ampiezza_media_famiglie2011 inc_abitazioni_proprieta2011 diff_genere_istr_sup2011 rapp_adul_dip_lau_su_lic_med2011 incidenza_analfabeti2011 usc_prec_istr2011 incidenza_adul_dip_lau2011 incidenza_giov_uni2011 part_mercato_lavoro_f2011 part_mercato_lavoro2011 incidenza_giov_nostud_nolav2011 rapp_giov_att_nonatt2011 tasso_disocc_f2011 tasso_disocc2011 tasso_disocc_giov2011 tasso_occ_f2011 tasso_occupazione2011 tasso_occ_agric2011 tasso_occ_industr2011 tasso_occ_terz2011 tasso_occ_comm2011 inc_occ_alta_media_spec2011 inc_occ_artig_ope_agric2011 inc_occ_bass_comp2011 inc_fam_disagio_econ2011 inc_fam_disagio_assist2011, by(istat_code_110 Comune1991 regione)

* merge *
merge 1:1 istat_code_110 using "$data_controls/panel_years_1.dta", gen(mm)   
keep if mm==3 
drop mm

* rename to reshape
forvalues x=1990/2019 {
	foreach y in "ab" {
		rename `y'_`x' `y'`x'
	}
}
 
* reshape from wide to long *
reshape long popolazione_residente densita_demografica rapp_maschi_femm indice_dip_anziani indice_vecchiaia incidenza_stranieri incidenza_coppie_miste tasso_occ_straniera rapp_occ_ita_stra rapp_disocc_ita_stra indice_freq_scol_stra rapp_freq_scol_ita_stra ampiezza_media_famiglie inc_abitazioni_proprieta diff_genere_istr_sup rapp_adul_dip_lau_su_lic_med incidenza_analfabeti usc_prec_istr incidenza_adul_dip_lau incidenza_giov_uni part_mercato_lavoro_f part_mercato_lavoro incidenza_giov_nostud_nolav rapp_giov_att_nonatt tasso_disocc_f tasso_disocc tasso_disocc_giov tasso_occ_f tasso_occupazione tasso_occ_agric tasso_occ_industr tasso_occ_terz tasso_occ_comm inc_occ_alta_media_spec inc_occ_artig_ope_agric inc_occ_bass_comp inc_fam_disagio_econ inc_fam_disagio_assist ab, i(codcom) j(anno) 

* merge with panel of years *
xtset codcom anno

* carryforward census vars *
foreach x of varlist  popolazione_residente densita_demografica rapp_maschi_femm indice_dip_anziani indice_vecchiaia incidenza_stranieri incidenza_coppie_miste tasso_occ_straniera rapp_occ_ita_stra rapp_disocc_ita_stra indice_freq_scol_stra rapp_freq_scol_ita_stra ampiezza_media_famiglie inc_abitazioni_proprieta diff_genere_istr_sup rapp_adul_dip_lau_su_lic_med incidenza_analfabeti usc_prec_istr incidenza_adul_dip_lau incidenza_giov_uni part_mercato_lavoro_f part_mercato_lavoro incidenza_giov_nostud_nolav rapp_giov_att_nonatt tasso_disocc_f tasso_disocc tasso_disocc_giov tasso_occ_f tasso_occupazione tasso_occ_agric tasso_occ_industr tasso_occ_terz tasso_occ_comm inc_occ_alta_media_spec inc_occ_artig_ope_agric inc_occ_bass_comp inc_fam_disagio_econ inc_fam_disagio_assist ab {
	bys codcom (anno): carryforward `x', replace
	gsort codcom -anno
	bys codcom: carryforward `x', replace
	sort codcom anno
}

* replace missing controls with first ever observed *
gsort codcom -anno
foreach x of varlist popolazione_residente densita_demografica rapp_maschi_femm indice_dip_anziani indice_vecchiaia incidenza_stranieri incidenza_coppie_miste tasso_occ_straniera rapp_occ_ita_stra rapp_disocc_ita_stra indice_freq_scol_stra rapp_freq_scol_ita_stra ampiezza_media_famiglie inc_abitazioni_proprieta diff_genere_istr_sup rapp_adul_dip_lau_su_lic_med incidenza_analfabeti usc_prec_istr incidenza_adul_dip_lau incidenza_giov_uni part_mercato_lavoro_f part_mercato_lavoro incidenza_giov_nostud_nolav rapp_giov_att_nonatt tasso_disocc_f tasso_disocc tasso_disocc_giov tasso_occ_f tasso_occupazione tasso_occ_agric tasso_occ_industr tasso_occ_terz tasso_occ_comm inc_occ_alta_media_spec inc_occ_artig_ope_agric inc_occ_bass_comp inc_fam_disagio_econ inc_fam_disagio_assist ab {
	bys codcom: carryforward `x', replace
}
sort codcom anno

* gen city controls at baseline (1991) *
foreach x of varlist popolazione_residente densita_demografica rapp_maschi_femm indice_dip_anziani indice_vecchiaia incidenza_stranieri incidenza_coppie_miste tasso_occ_straniera rapp_occ_ita_stra rapp_disocc_ita_stra indice_freq_scol_stra rapp_freq_scol_ita_stra ampiezza_media_famiglie inc_abitazioni_proprieta diff_genere_istr_sup rapp_adul_dip_lau_su_lic_med incidenza_analfabeti usc_prec_istr incidenza_adul_dip_lau incidenza_giov_uni part_mercato_lavoro_f part_mercato_lavoro incidenza_giov_nostud_nolav rapp_giov_att_nonatt tasso_disocc_f tasso_disocc tasso_disocc_giov tasso_occ_f tasso_occupazione tasso_occ_agric tasso_occ_industr tasso_occ_terz tasso_occ_comm inc_occ_alta_media_spec inc_occ_artig_ope_agric inc_occ_bass_comp inc_fam_disagio_econ inc_fam_disagio_assist {
	gen temp = `x' if anno == 1991
	bys codcom (anno): egen `x'_91 = max(temp)
	drop temp
}


* drop special statute regions *
drop if inlist(regione,"Sicilia","ValleDA","Sardegna","Trentino")
rename Comune1991 comune_mayors
replace comune_mayors = subinstr(comune_mayors,"è","e'",.)
replace comune_mayors = subinstr(comune_mayors,"é","e'",.)
replace comune_mayors = subinstr(comune_mayors,"à","a'",.)
replace comune_mayors = subinstr(comune_mayors,"á","a'",.)
replace comune_mayors = subinstr(comune_mayors,"í","i'",.)
replace comune_mayors = subinstr(comune_mayors,"ì","i'",.)
replace comune_mayors = subinstr(comune_mayors,"ò","o'",.)
replace comune_mayors = subinstr(comune_mayors,"ó","o'",.)
replace comune_mayors = subinstr(comune_mayors,"ú","u'",.)
replace comune_mayors = subinstr(comune_mayors,"ù","u'",.)
replace comune_mayors = upper(comune_mayors)
replace comune_mayors="PEGLIO (co)" if comune_mayors=="PEGLIO" & regione=="Lombardia"
replace comune_mayors="PEGLIO (pu)" if comune_mayors=="PEGLIO" & regione=="Marche"
replace comune_mayors="CASTRO (bg)" if comune_mayors=="CASTRO" & regione=="Lombardia"
replace comune_mayors="CASTRO (le)" if comune_mayors=="CASTRO" & regione=="Puglia"
drop if comune_mayors == ""



**# Merge with elections data **
merge 1:1 comune_mayors anno using "$data_elezioni/elections_data_0525.dta", gen(mmm)
/*
  
   Result                           # of obs.
    -----------------------------------------
    not matched                       138,010
        from master                   137,929  (mm==1)
        from using                         81  (mm==2)

    matched                            34,779  (mm==3)
    -----------------------------------------
*/
keep if mmm == 3
drop mmm
sort codcom anno

* gen simele vars *
gen temp = ele_date
gen nlse = 1 if ele_date == 15108 | ele_date == 17635
gen nlse_did = nlse
bys codcom (anno): carryforward nlse_did, replace
foreach x of varlist nlse nlse_did {
	recode `x' .=0
}

** gen regional local sim_ele variable **
// one_ele
gen rlse = .
foreach reg in "Piemonte" "Lombardia" "Veneto" "Liguria" "EmiliaR" "Toscana" "Umbria" "Marche" "Lazio" "Abruzzi" "Molise" "Campania" "Puglia" "Basilicata" "Calabria" {
	replace rlse = 1 if ele_date == td("23apr1995") & regione ==  "`reg'"
	replace rlse = 1 if ele_date == td("16apr2000") & regione ==  "`reg'"
}
foreach reg in "Piemonte" "Lombardia" "Veneto" "Liguria" "EmiliaR" "Toscana" "Umbria" "Marche" "Lazio" "Abruzzi" "Campania" "Puglia" "Calabria" {
	replace rlse = 1 if ele_date == td("03apr2005") & regione ==  "`reg'"
}
foreach reg in "Basilicata" {
	replace rlse = 1 if ele_date == td("17apr2005") & regione ==  "`reg'"
}
foreach reg in "Piemonte" "Lombardia" "Veneto" "Liguria" "EmiliaR" "Toscana" "Umbria" "Marche" "Lazio" "Campania" "Puglia" "Basilicata" "Calabria" {
	replace rlse = 1 if ele_date == td("28mar2010") & regione ==  "`reg'"
}
foreach reg in "Basilicata" {
	replace rlse = 1 if ele_date == td("17nov2013") & regione ==  "`reg'"
}
foreach reg in "Piemonte" "Abruzzi" {
	replace rlse = 1 if ele_date == td("25may2014") & regione ==  "`reg'"
}
foreach reg in "Veneto" "Liguria" "Toscana" "Umbria" "Marche" "Campania" "Puglia" {
	replace rlse = 1 if ele_date == td("31may2015") & regione ==  "`reg'"
}
recode rlse . = 0
// did
gen rlse_did = rlse if rlse == 1
bys codcom (ele_date): carryforward rlse_did, replace
recode rlse_did . = 0

* any simele *
gen ase = 1 if nlse == 1 | rlse == 1
gen ase_did = ase
bys codcom (ele_date): carryforward ase_did, replace
foreach x of varlist ase ase_did {
	recode `x' .=0
}

* rename codreg codpro *
rename CodiceRegione2011 codreg 
rename CodiceProvincia2011 codpro

* gen month of elections *
gen mese = month(ele_date)

* drop Friuli VG * 
drop if regione == "Friuli VG"

* 
summ inv_hhi, d
replace inv_hhi = 0 if inv_hhi < 0

** save **
save "$maindir\data\final_data.dta", replace


