/* DATA MGMT OF LOCAL ELECTIONS */
clear

** defines directory **
cd "$maindir/data/elections/raw"



**# ** unzip folders **
local myfilelist : dir . files"*.zip"
foreach file of local myfilelist {
	unzipfile "`file'", replace
}



**# ** import in Stata **
local myfilelist : dir . files"comunali*.txt"
foreach file of local myfilelist {
	di "`file'"
	import delimited "`file'", delimiter(";") varnames(1) asdouble encoding(ISO-8859-1) stringcols(_all) clear 
	local year = substr("`file'",10,4)
	di "`year'"
	gen year = "`year'"
	local ele_date = substr("`file'",10,8)
	gen ele_date = "`ele_date'"
	local outfile=subinstr("`file'",".txt","",.)
	save `outfile'.dta, replace
}



**# ** append resulting datasets **
// use "comunali-20160605.dta", clear
// gen todrop = 1
local myfilelist : dir . files"comunali*.dta"
foreach file of local myfilelist {
	append using `file'
}
duplicates drop



**# ** inspect data **

* codebook *
// codebook _all
// regione, provincia, comune have missing values //
ta year if comune == ""  // 2015, 40 obs, common across comune, provincia and regione
drop if comune == ""

* fix regioni *
replace regione = "ABRUZZO" if regione == "ABRUZZI"
replace regione = "EMILIA ROMAGNA" if regione == "EMILIA-ROMAGNA"
drop if substr(regione,1,8) == "TRENTINO" // special statute region
drop if regione == "VALLE D'AOSTA" // special statute region
drop if regione == "SICILIA" // special statute region
drop if regione == "SARDEGNA" // special statute region

* fix provincie *
replace provincia = "MASSA CARRARA" if provincia == "MASSA-CARRARA"
replace provincia = "PESARO URBINO" if provincia == "PESARO E URBINO"
replace provincia = "REGGIO CALABRIA" if provincia == "REGGIO DI CALABRIA"
replace provincia = "REGGIO EMILIA" if provincia == "REGGIO NELL' EMILIA"
replace provincia = "REGGIO EMILIA" if provincia == "REGGIO NELL'EMILIA"
replace provincia = "VERBANO-CUSIO-OSSOLA" if provincia == "VERB.-CUS.OSSOLA"

* manage city names *
// manage cities with double name (just peglio and castro because the rest has a double in a special status region, not in the sample)
replace comune="PEGLIO (CO)" if comune=="PEGLIO" & regione == "LOMBARDIA"
replace comune="PEGLIO (PU)" if comune=="PEGLIO" & regione == "MARCHE"
replace comune="CASTRO (BG)" if comune=="CASTRO" & regione == "LOMBARDIA"
replace comune="CASTRO (LE)" if comune=="CASTRO" & regione == "PUGLIA"
replace comune = "CORTENUOVA" if comune == "CORTENOVA" & provincia == "BERGAMO"

* remove blanks *
foreach x of varlist _all {
	replace `x' = strtrim(`x')
}

* drop useless variables *
drop dataelezione codtipoelezione descrregione descrprovincia descrcomune votilista *maschi

* destring *
foreach x of varlist turno elettori votanti schede_bianche voti_candidato voti_lista seggi_lista {
	destring `x', replace
}

* date mgmt *
gen month = substr(ele_date,5,2)
replace month = subinstr(month,"0","",.) if substr(month,1,1) == "0"
gen day = substr(ele_date,7,2)
replace day = subinstr(day,"0","",.) if substr(day,1,1) == "0"
foreach x of varlist month day year {
	destring `x', replace
}
drop ele_date
gen ele_date = mdy(month,day,year)
format ele_date %td

* gen full name *
gen nome_cognome = strtrim(cognome+" "+nome)
drop nome cognome

* format strings *
ds, has(type string) 
local strvars "`r(varlist)'"
format `strvars' %15s

* sort *
gsort regione provincia comune ele_date turno -voti_candidato -seggi_lista

* gen tot n seggi *
ta turno year, m
replace turno = 1 if turno == . // missing in 1991 and 1992.
replace voti_candidato = voti_lista if inlist(year,1991,1992) & voti_candidato == .
bys regione provincia comune ele_date turno (voti_candidato seggi_lista): egen temp = sum(seggi_lista) if turno == 1
bys regione provincia comune ele_date (turno voti_candidato seggi_lista): egen tot_seggi = max(temp)
drop temp
gen temp = seggi_lista/tot_seggi if turno == 1
bys regione provincia comune ele_date nome_cognome lista (turno): egen share_seggi_lista = max(temp)
drop temp
gsort regione provincia comune ele_date turno -voti_candidato -seggi_lista

* move party affiliation, vote for party and number of seats for the same candidate to the same line *
replace nome_cognome = "PARTY: "+lista if inlist(year,1991,1992) & nome_cognome == ""
bys comune ele_date turno nome_cognome: egen test=seq()
bys comune ele_date turno nome_cognome: egen matest=max(test)
ta matest
qui forvalues x=1/21 {
	foreach y in "lista" "seggi_lista" "voti_lista" "share_seggi_lista" {
	bys comune ele_date turno nome_cognome: gen `y'_`x'=`y' if `x'==test
	bys comune ele_date turno nome_cognome: egen temp=mode(`y'_`x'), maxmode
	bys comune ele_date turno nome_cognome: replace `y'_`x'=temp
	drop temp
	}
}

* collapse to remove unnecesary observations (unnecessary due to lines 112/129) *
collapse (first) voti_candidato eletto lista_* seggi_lista_* share_seggi_lista_* voti_lista_* elettori votanti schede_bianche, by(regione provincia comune ele_date year month day turno nome_cognome)

* modify name of 1st or 2nd turn variable
tostring turno, replace
replace turno = strtrim("_"+turno)

* drop votilista and seggi (no use for them now) *
drop voti_lista_* seggi_lista_*

* reshape to wide (to have 1st turn and 2nd turn on the same line). then ordering *
reshape wide lista_* share_seggi_lista_* voti_candidato eletto elettori votanti schede_bianche, i(comune regione provincia ele_date nome_cognome year month day) j(turno) string
order regione provincia comune ele_date nome_cognome voti_candidato_1 voti_candidato_2 eletto_1 eletto_2 votanti* elettori* schede_bianche*

* identify election with 2nd round and candidates who did go to the second round only *
bys comune ele_date: gen temp = 1 if voti_candidato_2 !=.
bys comune ele_date: egen ballottaggio = max(temp)
drop temp
recode ballottaggio .=0
bys comune ele_date: gen ballot_cand = 1 if voti_candidato_2 != .
recode ballot_cand .=0

* variable that counts the number of candidates *
// overall
bys comune ele_date: egen temp = seq()
bys comune ele_date: egen n_cand = max(temp)
drop temp

* 1st, 2nd and last votes of candidates (last only for first round) *
// 1st round
bys comune ele_date: egen votes_first_cand_1st = max(voti_candidato_1)
bys comune ele_date: egen votes_last_cand_1st = min(voti_candidato_1) if n_cand != 1
bys comune ele_date: egen rank = rank(voti_candidato_1), field
bys comune ele_date: gen temp = voti_candidato_1 if rank == 2
bys comune ele_date: egen votes_second_cand_1st = max(temp)
drop rank temp
// 2nd round
bys comune ele_date: egen votes_first_cand_2nd = max(voti_candidato_2)
bys comune ele_date: egen rank = rank(voti_candidato_2), field
bys comune ele_date: gen temp = voti_candidato_2 if rank == 2
bys comune ele_date: egen votes_second_cand_2nd = max(temp)
drop rank temp

* name winner election *
bys comune ele_date: egen rank = rank(voti_candidato_1) if ballottaggio==0 , field 
bys comune ele_date: egen temp_rank = rank(voti_candidato_2) if ballottaggio==1 , field 
bys comune ele_date: gen temp = nome_cognome if rank == 1 & ballottaggio == 0
bys comune ele_date: replace temp = nome_cognome if temp_rank == 1 & ballottaggio == 1
bys comune ele_date: egen name_winner = mode(temp), maxmode // missings in 1991 and 1992
drop temp
levelsof rank, local(ranks)
foreach x of local ranks {
	bys comune ele_date: gen temp = nome_cognome if rank == `x' & ballottaggio == 0
	bys comune ele_date: replace temp = nome_cognome if temp_rank == `x' & ballottaggio == 1
	bys comune ele_date: egen name_loser_`x' = mode(temp), maxmode // missings in 1991 and 1992	
	drop temp
}
drop rank temp_rank
drop name_loser_1
// drop name_loser_6 name_loser_7 name_loser_8 name_loser_9 name_loser_10 name_loser_11 name_loser_12 name_loser_13 name_loser_14 name_loser_15

* drop second round parties (assuming they are not different from first round in terms of left-right orientation)*
drop lista_*_2
drop share_seggi_lista_*_2

* rename lista *
rename (lista_*_1) (lista_*)
rename (share_seggi_lista_*_1) (share_seggi_lista_*)



**# ** compute shares **


** compute turnout **

* first round *
// overall
bys comune ele_date: gen turn_1st_mun = votanti_1/elettori_1

* second round *
// overall 
bys comune ele_date: gen turn_2nd_mun = votanti_2/elettori_2


** compute votes share **

* first round per candidate rank *
// 1st candidate
bys comune ele_date: gen sh_votes_first_cand_1st = votes_first_cand_1st/(votanti_1 - schede_bianche_1)
// 2nd candidate 
bys comune ele_date: gen sh_votes_second_cand_1st = votes_second_cand_1st/(votanti_1 - schede_bianche_1)

* second round per candidate rank *
// 1st candidate
bys comune ele_date: gen sh_votes_first_cand_2nd = votes_first_cand_2nd/(votanti_2 - schede_bianche_2)
// 2nd candidate 
bys comune ele_date: gen sh_votes_second_cand_2nd = votes_second_cand_2nd/(votanti_2 - schede_bianche_2)

* carryforward 2nd round *
foreach x of varlist turn_2nd_mun sh_votes_first_cand_2nd sh_votes_second_cand_2nd {
	bys comune ele_date: egen temp = max(`x')
	replace `x' = temp
	drop temp
}



**# Code parties ***


** desc_partito variables mgmt **
forvalues x=1/21 {
	replace lista_`x'=strltrim(upper(lista_`x'))
	replace lista_`x'=trim(upper(lista_`x'))
}


** identify nationally affiliated parties **
gen natparty=.
qui foreach y in "LEGA NORD" "L.NORD" "L.NORD-CIVICHE" "LEGA SALVINI" "NOI CON SALVINI" "FORZA IT-LG NORD" "LG.NORD-LG.VENETA" "LEGA SALVINI" "CIVICI LEGA E CENTRODESTRA" "LEGA - CIVICA" "LEGA - FORZA ITALIA" "LEGA - FORZA ITALIA - FRATELLI D'ITALIA" "LEGA PADANA" "LEGA PADANA LOMBARDIA - ALTRI" "LEGA PADANA PIEMONT" "LEGA-CIVICA" "LEGA-F.IT-MOV.ANIMALISTA-CIVICA" "LEGA-FI-FRAT.D'IT-NOI CON L'ITALIA" "LEGA-FI-FRAT.D'IT-UDC" "LEGA-FI-NOI CON L'ITALIA-CIVICA" "LEGA-FORZA IT-FRAT.D'IT-CIVICA" "LEGA-FORZA IT-FRAT.D'IT-CIVICHE" "LEGA-FORZA ITALIA-CIVICA" "LEGA-FORZA ITALIA-FRATELLI D'ITALIA" "LEGA-FRATELLI D'ITALIA-ALTRI" "LEGA-IL POPOLO DELLA FAMIGLIA" "LEGA-LISTA CIVICA" "LEGASALVINI-LISTA CIVICA" "NOI CON L'IT-FRAT.D'IT-FI-LEGA-UDC" "LEGA LOMBARDA" "LEGA VENETA" "LEGA LOMBARDA VENETA" "LEGA AUT.VENETA" "LEGA AUT.LOMBARDA" "L.VEN.AUTONOMO" "FRAT.D'IT-AN-L.NORD-FI" "FI-L.NORD-B.URO-F.D'ITALIA-AN-UDC-NCD" "FI-FRAT.D'IT-AN-L.NORD-B.URO-UDC-NCD" "FI-NCD-L.NORD-BASTA -CIVICA" "FI-L.NORD-BASTA-NCD-CIVICA" "FI-L.NORD-BASTA URO-FR. D'IT.-AN" "FI-L.NORD-B.-F.D'IT-AN-CIVICA" "FI-F.D'IT-AN-NCD-UDC-L.NORD-B.-CIV." "FI-L.NORD-FR.D'IT-AN-CIVICA" "L.NORD-BASTA-FRAT.D'IT-AN-FI" "FI-NCD-UDC-LEGA NORD-BASTA" "FI-NCD-UDC-FRAT.D'IT-AN-L.NORD-BASTA" "NCD-L.NORD-B.URO-F.D'IT-AN-FI" "L.NORD-BASTA-FRAT.D'IT-AN-NCD-FI" "FI-L.NORD-BASTA-NCD-IND" "FI-NCD-UDC-FRAT.D'IT.-AN-L.NORD-BASTA" "L.NORD-B.URO-FRAT.D'IT-AN-FI" "UNIONE DI CENTRO-PDL-L.NORD" "PDL-L.NORD-UNIONE DI CENTRO" "PDL-L.NORD-LA DESTRA" "FRATELLI D'ITALIA-PDL-L. NORD" "PDL-L.NORD-CIVICA" "PDL-L. NORD-UNIONE DI CENTRO-CIVICA" "PDL-LEGA NORD-CIVICA" "PDL - LEGA NORD - UNIONE DI CENTRO" "PDL - LEGA NORD - UDC" "PDL-FRATELLI D'ITALIA-L.NORD-CIVICA" "L. NORD-PDL-UNIONE DI CENTRO" "PDL-L. NORD-CIVICA" "PDL-L.NORD-UNIONE DI CENTRO-CIVICA" "PDL-L. NORD-UNIONE DI CENTRO" "PDL-L.NORD" "PDL-L. NORD-INDIPENDENTI" "ALLEANZA LOMBARDA AUTONOMIA" "L.VEN.AUTONOMO" "LEGA AUT.TOSCANA" "LEGA AUT.VENETA" "LEGA LOMBARDA" "LEGA LOMBARDA VENETA" "L.VEN-L.NORD" "L.VEN.AUTONOMO" "LEGA AUT.LIGURIA" "LEGA AUT.TOSCANA" "LEGA AUT.VENETA" "LEGA AUTONOM. FRIULI" "LEGA LOMB-LEGA NORD" "LEGA LOMBARDA" "LEGA LOMBARDA VENETA" "LEGA VENETA" "LG.AUT.TOSCANA-M.A.T" "LG.PENS. L.LOMB." "PIEMONT-L.NORD" "FORZA ITALIA" "POPOLO DELLE LIBERTA'" "POPOLO DELLA LIBERTA'" "CASA DELLE LIBERTA'" "FORZA IT" "F. ITALIA" "F.IT" "F.I.-" "LEGA - FORZA ITALIA" "LEGA - FORZA ITALIA - FRATELLI D'ITALIA" "LEGA-F.IT-MOV.ANIMALISTA-CIVICA" "LEGA-FI-FRAT.D'IT-NOI CON L'ITALIA" "LEGA-FI-FRAT.D'IT-UDC" "LEGA-FI-NOI CON L'ITALIA-CIVICA" "LEGA-FORZA IT-FRAT.D'IT-CIVICA" "LEGA-FORZA IT-FRAT.D'IT-CIVICHE" "LEGA-FORZA ITALIA-CIVICA" "LEGA-FORZA ITALIA-FRATELLI D'ITALIA" "NOI CON L'IT-FRAT.D'IT-FI-LEGA-UDC" "FI-CCD-AN" "FI-AN" "FI-CCD-UDC" "FI-CCD-CDU" "FI-AN-CIVICHE" "FI-CCD-ALTRI" "FI-ALTRI" "FI-CCD-AN-PPI" "FRAT.D'IT-AN-L.NORD-FI" "FI-CCD-POLO-POP" "FI-L.NORD-B.URO-F.D'ITALIA-AN-UDC-NCD" "FI-CCD-UDC-FEDERAL" "FI-AN-UDC" "FI-NCD-LA DESTRA-UDC" "FI-UDC-NCD-FRAT. D'IT.-AN" "FI-CDU-P.SEGNI" "FI-FRAT.D'IT-AN-L.NORD-B.URO-UDC-NCD" "FI-AN-PPI" "FI-CCD-PSR-UDC-FED" "FI-NCD-L.NORD-BASTA -CIVICA" "FI-CPA" "FI-UDC" "FI-FRAT.D'IT.-AN-L.NORD-BASTA-NCD-UDC" "FI-L.NORD-B.URO-FRAT.D'IT-AN" "FI-CDU" "FI-L.NORD-BASTA-NCD-CIVICA" "FI-L.NORD-BASTA URO-FR. D'IT.-AN" "FI-AN-CCD-CPA-SOC-LS" "FI-N.PSI-FR.IT-AN-POP.PER L'IT." "FI-L.NORD-B.-F.D'IT-AN-CIVICA" "FI-CCD-SDI" "FI-F.D'IT-AN-NCD-UDC-L.NORD-B.-CIV." "FI-L.NORD-FR.D'IT-AN-CIVICA" "L.NORD-BASTA-FRAT.D'IT-AN-FI" "FI-PPI" "FI-AN-CCD-POLO CIVIC" "FI-RIFORMATORI" "FI-NCD-UDC-LEGA NORD-BASTA" "FI-NCD-UDC-FRAT.D'IT-AN-L.NORD-BASTA" "FI-FEDERALISTI" "NCD-L.NORD-B.URO-F.D'IT-AN-FI" "NCD-L.NORD-B.URO-F.D'IT-AN-FI" "L.NORD-BASTA-FRAT.D'IT-AN-NCD-FI" "FI-L.NORD-BASTA-NCD-IND" "FI-CCD-AN-UDC-CPA" "FI-SLE-PPI-I SOC." "FI-PRI-SLE-CCD-LN-PP" "FI-NCD-FRAT.D'IT-AN-CIVICA" "FI-CCD-UDC-FED-PPI" "FI-NCD-UDC-FRAT.D'IT.-AN-L.NORD-BASTA" "FI-CCD-CRIST.DEM-FED" "FI-UDC-FRAT.D'IT-AN" "FI-CDU-ALTRI" "FI-UDC-NCD-PUGLIA PRIMA DI TUTTO" "L.NORD-B.URO-FRAT.D'IT-AN-FI" "PDL - UNIONE DI CENTRO" "UNIONE DI CENTRO-PDL-L.NORD" "PDL-UDC-FLI-LA DESTRA-CIVICA" "PDL-L.NORD-UNIONE DI CENTRO" "PDL-MPA-LA DESTRA" "PDL-UDC-LA DESTRA-CIVICA" "PDL-L.NORD-LA DESTRA" "PDL-UNIONE DI CENTRO" "PDL-UDC-CIVICA" "FRATELLI D'ITALIA-PDL-L. NORD" "PDL-UNIONE DI CENTRO-CIVICA" "PDL-L.NORD-CIVICA" "PDL-L. NORD-UNIONE DI CENTRO-CIVICA" "PDL-LEGA NORD-CIVICA" "PDL - LEGA NORD - UNIONE DI CENTRO" "PDL - LEGA NORD - UDC" "UNIONE DI CENTRO-PDL-CIVICA" "UNIONE DI CENTRO-PDL-INDIPENDENTI" "PDL-FRATELLI D'ITALIA-L.NORD-CIVICA" "L. NORD-PDL-UNIONE DI CENTRO" "PDL-L. NORD-CIVICA" "PDL-L.NORD-UNIONE DI CENTRO-CIVICA" "PDL-L. NORD-UNIONE DI CENTRO" "PDL-L.NORD" "PDL-L. NORD-INDIPENDENTI" "PDL-UNIONE DI CENTRO-INDIPENDENTI" "RIFONDAZIONE COMUNISTA" "ALLEANZA NAZIONALE" "MOVIMENTO 5 STELLE BEPPEGRILLO.IT" "DC" "PARTITO DEMOCRATICO" "UNIONE DI CENTRO" "PDS" "L'ULIVO" "MOVIMENTO 5 STELLE" "MOVIMENTO 5 STELLE.IT" "MSI-DN" "FEDERAZIONE DEI VERDI" "DEMOCRATICI SINISTRA" "PSI" "P.POPOLARE ITALIANO" "PPI (POP)" "DI PIETRO ITALIA DEI VALORI" "CENTRO CRIST.DEM." "COMUNISTI ITALIANI" "FIAMMA TRICOLORE" "PROGRESSISTI" "PRI" "MOV.SOC.TRICOLORE" "FORZA NUOVA" "SDI" "C.AREA GOV." "LISTA AREA GOV." "DL.LA MARGHERITA" "POPOLARI" "LA DESTRA" "RINNOVAMENTO" "PSDI" "DESTRA" "ALLEANZA DEMOCRATICA" "UNIONE DEM." "NUOVO PSI" "FRATELLI D'ITALIA - ALLEANZA NAZIONALE" "SINISTRA ECOLOGIA LIBERTA'" "PARTITO PENSIONATI" "RIFOND.COM. - SIN.EUROPEA - COM.ITALIANI" "PARTITO COMUNISTA DEI LAVORATORI" "CDU" "LISTA DI PIETRO" "RIF.COM-COM.IT" "PROGRESSISTI-ALTRI" "CASAPOUND ITALIA" "PLI" "RINNOVAMENTO IT-DINI" "FRATELLI D'ITALIA" "L'UNIONE" "U.D.EUR POPOLARI" "UNIONE DEMOCRATICA" "PATTO DEMOCRATICI" "LA RETE-MOV.DEM." "DEMOCRAZIA EUROPEA" "PARTITO SOCIALISTA ITALIANO" "U.D.EUR" "FRONTE NAZIONALE" "BEPPEGRILLO.IT" "LA SINISTRA L'ARCOBALENO" "FI-CCD-AN" "PARTITO DEMOCRATICO - CIVICA" "CCD-CDU" "DEM.CR.PER AUTONOMIE" "LA DESTRA - FIAMMA TRICOLORE" "LG.VENETA REPUBBLICA" "LEGA SALVINI PREMIER-FORZA ITALIA-FRATELLI D'ITALIA" "ALL.POP." "L'ALTRA ITALIA" "PART.UMANISTA" "AN-CCD" "C.AREA GOV.-ALTRI" "SOCIALISTA" "DEMOCRAZIA CRISTIANA" "FASCISMO E LIBERTA'" "ALTERNATIVA SOCIALE MUSSOLINI" "LISTA AREA GOV-ALTRI" "DIPIETRO OCCHETTO" "MOV.FED.IT." "PANNELLA-RIFORMATORI" "LIBERTAS DEMOCRAZIA CRISTIANA" "ALLEANZA-PATTO" "NUOVO CENTRO DESTRA" "PARTITO SOCIALISTA" "LEGA SALVINI PREMIER" "LEGA AUT.VENETA" "PARTITO COMUNISTA" "SOCIALISTI UNITI" "ITALIA DEI VALORI" "MPA MOVIMENTO PER LE AUTONOMIE" "LISTA ECOLOGICA" "UNIONE DI CENTRO - CIVICA" "AZ.SOCIALE MUSSOLINI" "LISTA ARCOBALENO" "LEGA D'AZIONE MERID." "AN-CIVICA" "ARCOBALENO" "RINNOVAMENTO DEMOCRATICO" "LA ROSA NEL PUGNO" "FED.DEI VERDI" "MOVIMENTO SOCIALE ITALICO" "DEMOCRATICI" "LEGA ITALIA FEDERALE" "MOVIMENTO NAZ. E SOC. DEI LAVORATORI" "LA SINISTRA" "SI" "LOMBARDIA AUTONOMA" "PROGETTO NORDEST" "PIRATEPARTY.IT" "RIF.COM-F.VERDI" "LG.PADANA LOMBARDIA" "A.P. UDEUR" "TERZO POLO" "DEM.CRIST." "FED.LABURISTA" "LEGA ALPINA LUMBARDA" "NOI CON SALVINI" "SINISTRA UNITA" "LA PUGLIA PRIMA DI TUTTO" "PARTITO VALORE UMANO" "IO SUD" "FI-AN" "I LIBERAL SGARBI" "FEDERAZIONE DEI VERDI-ALTRI" "DEM.E SOLIDARIETA'" "ALLEANZA PER L'ITALIA" "UDR" "SINISTRA CRITICA" "PPI-CIVICA" "L'ARCOBALENO" "VERDI-VERDI" "DESTRE UNITE" "UN.DEM." "PARTECIPAZIONE DEMOCRATICA" "PATTO SEGNI" "RINASCITA DEM." "INTESA DEMOCRATICA" "VENETO STATO" "LISTA DEL GRILLO PARLANTE" "RIF.COM-CIVICHE" "RINASCITA DEMOCRATICA" "LIBERI DI SCEGLIERE" "RIN.DEMOCRATICO" "LEGA MOLISE" "SOCIALISTI DEM." "NUOVO CENTRO DESTRA - UDC" "RIFONDAZIONE COMUNISTA-ALTRE" "FI-CCD-CDU" "LIGA FRONTE VENETO" "PARTITO DI ALTERNATIVA COMUNISTA" "UNIONE POP." "P.LIBERALE ITALIANO" "FED.VERDI-CIVICA" "ITALIA FEDERALE" "PART.DEMOCRATICO-ALTRI" "MOVIMENTO POLITICO SCHITTULLI" "LA MARGHERITA" "LIBERTA'  E AUTONOMIA NOI SUD" "POLO CIVICO DI CENTRO" "SINISTRA DEMOCRATICA" "F.VERDI-COM.ITALIANI" "CDL" "NO EURO" "ALLEANZA LOMBARDA AUTONOMIA" "DEMOCRAZIA E LIBERTA'" "UNIONE POPOLARE" "LISTA COMUNISTA" "UNITI PER IL PAESE" "ITALIA DEI DIRITTI" "LEGA - CIVICA" "GRANDE NORD" "ALLEANZA SOCIALISTA" "RAMOSCELLO D'ULIVO" "PCI" "COMUNISTI" "DEMOCRAZIA CRISTIANA - LIBERTA' - DC" "PARTITO DEMOCRATICO-DI PIETRO IT. VALORI" "M.NAZ.SOC.LAVORATORI" "POPOLARI DEMOCRATICI" "PDL-UNIONE DI CENTRO-CIVICA" "MOV.AUT.TOSCANO" "TOSCANA GRANDUC-FED." "F.VER-COM.IT-RIF.COM" "FI-ALTRI" "FEDERALISTI" "UN.POP." "MISTA DI DESTRA" "F.VERDI-COM.ITALIANI" "FI-ALTRI" "DEM.SOLIDARIETA'" "TOSCANA GRANDUC-FED." "SINISTRA ECOLOGIA LIBERTA'-RIF.COM" "P.S.N." "POPOLARI DEMOCRATICI" "ALLEANZA POPOLARE" "L.VERDE-VERDI ARC." "UDC - CIVICA" "PARTITO DEMOCRATICO - SIN.ECOL.LIBERTA'" "INDIPENDENZA VENETA" "MOVIMENTO POPOLARE" "LIBERTA'  E AUTONOMIA NOI SUD" "MOV.AUT.TOSCANO" "SOCIALDEMOCRAZIA" "REPUBBLICANI EUROPEI" "FRONTE INDIPENDENTISTA LOMBARDIA" "PRI-ALTRI" "UNIONE DEM. CONSUMATORI E PENSIONATI" "IL POPOLO DELLA LIBERTA' - CIVICA" "AMBIENTALISTI" "TOSCANA GRANDUCALE" "UN.POP." "MOV.IDEA SOC. RAUTI" "UNIONE DI CENTRO-ALTRI" "UNIONE ITALIANA" "LEGA PADANA LOMBARDIA - ALTRI" "FED.VERDI-CIVICA" "UNITI NELL'ULIVO" "F.VER-COM.IT-RIF.COM" "CENTROSINISTRA" "UNIONE NORD EST" "LIBERAL SGARBI-ALTRI" "MOV.IND.BIELLESE" "PARTITO COMUNISTA ITALIANO" "RIFONDAZIONE COMUNISTA-PARTITO COMUNISTA ITALIANO" "SIN.ECOL.LIB-RIF.COM-COM.IT" "P.SEGNI SCOGNAMIGLIO" "UDEUR-ALTRI" "FRATELLI D'ITALIA-AN-L.NORD" "LIBERI E UGUALI" "VERDI" "ALLEANZA DI CENTRO" "LEGA SALVINI-FORZA ITALIA-CIVICA" "PARTITO SOCIALISTA ITALIANO - ALTRI" "CPA" "SI SINISTRA ITALIANA" "CENTRO SINISTRA" "VERDI-FVG" "ITALIA AGLI ITALIANI" "LEGA AUTONOM. FRIULI" "DEM.CRISTIANA" "PENSIONATI INVALIDI" "LEGA PADANA" "SOCIALISTI RIFORM." "FI-CCD-AN-PPI" "LEGA SALVINI PREMIER-FRATELLI D'ITALIA" "L.NORD-PPI" "PROGETTO NAZIONALE" "NUOVO CDU" "PARTITO DEMOCRATICO-PART. SOC.IT" "PDL-UDC-CIVICA" "LEGA-FORZA ITALIA-FRATELLI D'ITALIA" "L'ITALIA DEI VALORI" "P.D.C." "FI-AN-UDC" "DEMOCRAZIA-LIBERTA'" "PENSIONATI EUROPA" "RINASCITA DEM.CRI." "CCD-PPI" "PART.FEDERAL." "VERDI AUTONOMISTI" "UNIONE ITALIANA - ALTRI" "POPOLARI PER L'ITALIA" "I SOCIALISTI" "ALL. PER L'ITALIA - UDC - FUTURO E LIB." "UDC - ALTRI" "MOV. PER L'AUTONOMIA" "LEGA SALVINI-FRATELLI D'ITALIA-CIVICA" "UNIONE PADANA" "LISTA RAUTI" "LISTA PANNELLA" "FI-AN-CIVICHE" "ALLEANZA DI CENTRO PER LA LIBERTA'" "MOVIMENTO PER L'AUTONOMIA ALL.PER IL SUD" "FRATELLI D'ITALIA CON GIORGIA MELONI" "FRAT.D'IT-AN-L.NORD-BASTA URO" "MOVIMENTO SOCIALE ITALICO MSI" "PARTITO DEMOCRATICO-RIF.COMUNISTA" "SINISTRA E LIBERTA'" "LEGA SALVINI-FRATELLI D'ITALIA-FORZA ITALIA-CIVICA" "FI-CCD-CDU" "L.NORD-F.ITALIA-FRAT.D'IT-AN" "LEGA PADANA PIEMONT" "LEGA SALVINI-FORZA ITALIA-FRATELLI D'ITALIA-CIVICHE" "PENSIONATI E INVALIDI GIOVANI INSIEME" "PDS-POPOLARI" "SOCIALISTI" "F.IT-L.NORD-FRAT.D'IT-AN" "PARTITO DEL SUD-ALLEANZA MERIDIONALE" "RIF.COM-COM.IT-ALTRI" "FORZA IT-L.NORD-FRAT.D'IT-AN" "FORZA ITALIA-LEGA SALVINI-FRATELLI D'ITALIA-CIVICA" "LA DESTRA - ALTRI" "PATTO DEM-POPOLARI" "NUOVO PSI-ALTRI" "P.COM.MARX-LEN." "PARTITO SOCIALISTA NAZIONALE" "MONARCHICI UNITI" "RINNOV.IT-ALTRI" "VERDI FEDERALISTI" "NUOVO PSI-PRI" "I PIRATI" "POPOLARI E DEMOCRATICI" "VENETO NORD EST" "FI-CDU" "UNIONE NAZIONALE" "LEGA TOSCANA" "PDL-L.NORD-UNIONE DI CENTRO-CIVICA" "BUNGA BUNGA" "DC DEMOCRAZIA CRISTIANA" "PATTO DEMOCRATICO" "AN-U.UMBRIA-CPA" "SINISTRA ECOLOGIA LIBERTA' - CIVICA" "NUOVO PSI-CIVICA" "L.NORD-FORZA IT-CIVICA" "PDL-L.NORD-PART.PENS." "FASCIO REPUBBLICA ROMANA" "LEGA SALVINI PREMIER-FORZA ITALIA" "DESTRA EUROPEA-MSE" "RIF.COM-COM.ITALIANI-CIVICA" "LEGA SALVINI-LISTA CIVICA" "PPI-RINNOVAMENTO IT." "F.I-L.NORD-FRAT.D'IT-AN-CIVICA" "PSDI-ALTRI" "CCD-ALTRI" "LEGA NORD-BASTA URO-FORZA ITALIA" "LS.CITO LG.AZ.MERID." "LEGA-FORZA IT-FRAT.D'IT-CIVICA" "ALTERNATIVA CON ALESSANDRA MUSSOLINI" "NUOVO CENTRO DESTRA-ALTRI" "L.VEN.AUTONOMO" "IT.VALORI-ALTRI" "FRATELLI D'ITALIA-AN-FORZA ITALIA" "L.NORD-F.VERDI" "F.IT-FRAT.D'IT-AN-L.NORD-CIVICA" "COM.IT-IT.VALORI" "UNITA' DEMOCRATICA RIFORMISTA" "UNIONE DI CENTRO-PDL-CIVICA" "LEGA ALPINA PIEMONT" "MOV.FED.CALABRIA LIB" "F.VER-COMIT-DIPIETRO" "IL CENTRO SINISTRA" "CENTRODESTRA UNITO" "L.NORD-PATTO D." "PARTITO COMUNISTA ITALIANO-RIFONDAZIONE COMUNISTA" "SINISTRA CIVICA" "UN.DEM.POP." "CCD-CIVICA" "PDL-L. NORD-CIVICA" "F.I-L.NORD-FRAT.D'IT-AN" "CENTRO" "SINISTRA" "DESTRA" {

	forvalues x=1/21 {
		replace natparty = 1 if lista_`x'=="`y'" & natparty == .
	}
}
qui foreach y in "LEGA NORD" "L.NORD" "SALVINI" "LG NORD" "LG.NORD" "LEGA-" "LEGA -" "-LEGA" "- LEGA" "POPOLO DELLE LIBERTA'" "POPOLO DELLA LIBERTA'" "CASA DELLE LIBERTA'" "FORZA ITALIA-" "FORZA ITALIA -" "-FORZA ITALIA" "- FORZA ITALIA" "FORZA IT." "FORZA IT-" "FORZA IT -" "-FORZA IT" "- FORZA IT" "F. ITALIA" "F.IT" "F.I.-" "-FI-" "- FI -" "PDL-" "PDL -" "-PDL" "- PDL" "FRATELLI D'ITALIA" "PARTITO DEMOCRATICO" "ULIVO" "MARGHERITA" "PD" "ITALIA DEI VALORI" "ALTERNATIVA POPOLARE" "CENTRO DEMOCRATICO" "EUROPA VERDE" "ITALIA VIVA" "LIBERAL DEMOCRATICI" "MOVIMENTO 5 STELLE" "MSI" "MOVIMENTO SOCIALE FIAMMA TRICOLORE" "PARTITO COMUNISTA" "COMUNISTI ITALIANI" "PARTITO COMUNISTA DEI LAVORATORI" "RIFONDAZIONE COMUNISTA" "PARTITO DEMOCRATICO" "PARTITO RADICALE" "PARTITO REPUBBLICANO ITALIANO" "PARTITO SOCIALISTA ITALIANO" "SINISTRA ITALIANA" "UNIONE DI CENTRO" "FEDERAZIONE DEI VERDI" "DC" "DEMOCRAZIA CRISTIANA" "FORZA NUOVA"  "CASAPOUND" "PSI" "MARGHERITA" "POTERE AL POPOLO" "FASCISMO" "MOVIMENTO PER L'AUTONOMIA" "MOVIMENTO MONARCHICO ITALIANO" {
	forvalues x=1/21 {
		replace natparty = 1 if strpos(lista_`x',"`y'") > 0 & natparty == .
	}
}

	
** recode . at 0's **
foreach y of varlist natparty {
	recode `y' .=0
}

* identify residually civic parties *
gen civicparty = 1 if natparty == 0
recode civicparty .=0

// here
* count number of candidates by nat and civic *
bys comune ele_date: egen temp = seq() if civicparty == 1
bys comune ele_date: egen n_civp = max(temp)
drop temp
bys comune ele_date: egen temp = seq() if natparty == 1
bys comune ele_date: egen n_natp = max(temp)
drop temp
foreach x of varlist n_civp n_natp {
	recode `x' .=0
}

* ever present at either round *
bys comune ele_date: egen ever_natp_1 = max(natparty)
bys comune ele_date: egen ever_civp_1 = max(civicparty)
bys comune ele_date: egen temp = max(natparty) if ballot_cand == 1
bys comune ele_date: egen ever_natp_2 = max(temp)
drop temp
bys comune ele_date: egen temp = max(civicparty) if ballot_cand == 1
bys comune ele_date: egen ever_civp_2 = max(temp)
drop temp
recode ever_natp_2 .=0
recode ever_civp_2 .=0

** gen votes share **
bys comune ele_date: egen temp = sum(voti_candidato_1) if natparty == 1 & ballot_cand == 0
bys comune ele_date: egen voti_natp_1 = max(temp)
drop temp
bys comune ele_date: egen temp = sum(voti_candidato_1) if civicparty == 1 & ballot_cand == 0
bys comune ele_date: egen voti_civp_1 = max(temp)
drop temp
bys comune ele_date: egen temp = sum(voti_candidato_2) if natparty == 1 & ballot_cand == 1
bys comune ele_date: egen voti_natp_2 = max(temp)
drop temp
bys comune ele_date: egen temp = sum(voti_candidato_2) if civicparty == 1 & ballot_cand == 1
bys comune ele_date: egen voti_civp_2 = max(temp)
drop temp
bys comune ele_date: gen temp = voti_natp_1/(votanti_1 - schede_bianche_1) if natparty == 1 & ballot_cand == 0
bys comune ele_date: egen sh_votes_natp_1st = max(temp)
drop temp
bys comune ele_date: gen temp = voti_natp_2/(votanti_2 - schede_bianche_2) if natparty == 1 & ballot_cand == 1
bys comune ele_date: egen sh_votes_natp_2nd = max(temp) 
drop temp
bys comune ele_date: gen temp = voti_civp_1/(votanti_1 - schede_bianche_1) if civicparty == 1 & ballot_cand == 0
bys comune ele_date: egen sh_votes_civp_1st = max(temp)
drop temp
bys comune ele_date: gen temp = voti_civp_2/(votanti_2 - schede_bianche_2) if civicparty == 1 & ballot_cand == 1
bys comune ele_date: egen sh_votes_civp_2nd = max(temp) 
drop temp


// **
// gen share_seggi_natparty = .


** gen dummies for winner **
gen natwin = 1 if sh_votes_natp_1st > sh_votes_civp_1st & ballottaggio == 0 & sh_votes_natp_1st != . & sh_votes_civp_1st != .
replace natwin = 1 if ballottaggio == 0 & sh_votes_natp_1st != . & sh_votes_civp_1st == .
replace natwin = 1 if sh_votes_natp_2nd > sh_votes_civp_2nd & ballottaggio == 1 & sh_votes_natp_2nd != . & sh_votes_civp_2nd != .
replace natwin = 1 if ballottaggio == 1 & sh_votes_natp_2nd != . & sh_votes_civp_2nd == .
gen civwin = 1 if sh_votes_civp_1st > sh_votes_natp_1st & ballottaggio == 0 & sh_votes_natp_1st != . & sh_votes_civp_1st != .
replace civwin = 1 if ballottaggio == 0 & sh_votes_natp_1st == . & sh_votes_civp_1st != .
replace civwin = 1 if sh_votes_civp_2nd > sh_votes_natp_2nd & ballottaggio == 1 & sh_votes_natp_2nd != . & sh_votes_civp_2nd != .
replace civwin = 1 if ballottaggio == 1 & sh_votes_natp_2nd == . & sh_votes_civp_2nd != .
foreach x of varlist natwin civwin {
	recode `x' .=0
}

* compute inv_hhi *
bys comune ele_date nome_cognome: gen sh_votes_1 = voti_candidato_1/(votanti_1 - schede_bianche_1)
bys comune ele_date nome_cognome: gen sh_votes_1_sq = sh_votes_1^2 
bys comune ele_date: egen sum_sh_votes_1_sq  = sum(sh_votes_1_sq)
bys comune ele_date: gen inv_hhi = 1 - sum_sh_votes_1_sq  

* gen dummy for relabelling *
bys nome_cognome comune (ele_date): gen relabel = 1 if natparty == 1 & civicparty[_n-1] == 1
recode relabel .=0

** collapse **
rename elettori_1 elettori
collapse (max) ever_natp_1 ever_civp_1 ever_natp_2 ever_civp_2 voti_natp_1 voti_civp_1 voti_natp_2 voti_civp_2 sh_votes_natp_1st sh_votes_natp_2nd sh_votes_civp_1st sh_votes_civp_2nd natwin civwin n_cand n_civp n_natp turn_1st_mun turn_2nd_mun elettori ballottaggio inv_hhi relabel (firstnm) name_winner name_loser*, by(comune regione provincia ele_date)

* quick data mgmt *
foreach x of varlist regione provincia {
	rename `x' `x'_elections
}

* gen anno variable *
gen anno = year(ele_date)

* remove multiple elections in one year (38 obs) - to think about *
// these are elections that were taken within the same muni within the same year.
// They are likely to result from scioglimenti.
duplicates report comune anno
bys comune anno: gen asd = _n == 1
bys comune anno: egen miasd = min(asd)
ta anno if miasd == 0 // mostly between 1992 and 1998, with one case in 2006.
// as a criteria, we take the most recent one, that is the one that ruled till the next election.
bys comune (ele_date): egen temp = seq() if miasd == 0
drop if miasd == 0 & temp == 1
drop asd miasd temp


** adjust muni names **
replace comune="JESOLO" if comune=="IESOLO" & provincia_elections=="VENEZIA"
replace comune="ALME'" if comune=="ALME¿" & provincia_elections=="BERGAMO"
*Baranzate creato per scorporo nel 2004... perdiamo questa info perchè non c'è il rispettivo canone rai
replace comune="BRIONE (BS)" if comune=="BRIONE" & provincia_elections=="BRESCIA"
*cavallino-treporti
*contarina, creato Porto Viro (MISSING PURE)
*due carrare
replace comune="GORNATE-OLONA" if comune=="GORNATE OLONA" & provincia_elections=="VARESE"
replace comune="LEINI" if comune=="LEINI'" & provincia_elections=="TORINO"
replace comune="LIMONE SUL GARDA" if comune=="LIMONE S/GARDA" & provincia_elections=="BRESCIA"
replace comune="LONATO DEL GARDA" if comune=="LONATO" & provincia_elections=="BRESCIA"
*massa fiscaglia ora comune di fiscaglia...??
replace comune="MASSA FISCAGLIA" if comune=="MASSAFISCAGLIA" & provincia_elections=="FERRARA"
replace comune="MONTEGRINO VALTRAVAGLIA" if comune=="MONTEGRINO-VALTRAVAGLIA" & provincia_elections=="VARESE"
replace comune="MONTICELLO BRIANZA" if comune=="MONTICELLO" & provincia_elections=="LECCO"
replace comune="PALAZZOLO SULL'OGLIO" if comune=="PALAZZOLO SULL¿OGLIO" & provincia_elections=="BRESCIA"
replace comune="PAVONE DEL MELLA" if comune=="PAVONE MELLA" & provincia_elections=="BRESCIA"
replace comune="PUEGNAGO SUL GARDA" if comune=="PUEGNAGO DEL GARDA" & provincia_elections=="BRESCIA"
*ROBECCHETTO CON INDUNO ????
replace comune="RODENGO SAIANO" if comune=="RODENGO-SAIANO" & provincia_elections=="BRESCIA"
replace comune="SAN GIORGIO DI MANTOVA" if comune=="S. GIORGIO DI MANTOVA" & provincia_elections=="MANTOVA"
replace comune="SAN MARTINO DALL'ARGINE" if comune=="S. MARTINO DALL'ARGINE" & provincia_elections=="MANTOVA"
replace comune="SALSOMAGGIORE TERME" if comune=="SALSOMAGGIORE T.ME" & provincia_elections=="PARMA"
replace comune="SANREMO" if comune=="SAN REMO" & provincia_elections=="IMPERIA"
replace comune="SANT'OMOBONO TERME" if comune=="SANT'OMOBONO IMAGNA" & provincia_elections=="BERGAMO"
*REZZONICO
replace comune="SAN STINO DI LIVENZA" if comune=="SANTO STINO DI LIVENZA" & provincia_elections=="VENEZIA"
replace comune="TOSCOLANO-MADERNO" if comune=="TOSCOLANO MADERNO" & provincia_elections=="BRESCIA"
replace comune="VILLANUOVA SUL CLISI" if comune=="VILLANUOVA S/CLISI" & provincia_elections=="BRESCIA"
replace comune="VO'" if comune=="VO" & provincia_elections=="PADOVA"

* continue *
gen comune_mayors=comune

//to merge with main data
replace comune_mayors="AGLIANO TERME" if anno==1995 & comune_mayors=="AGLIANO"
replace comune_mayors="ALBAREDO D'ADIGE" if comune_mayors=="ALBAREDO D¿ADIGE"
replace comune_mayors="ALBIANO D'IVREA" if comune_mayors=="ALBIANO D¿IVREA"
replace comune_mayors="ALBISSOLA MARINA" if comune_mayors=="ALBISOLA MARINA"
replace comune_mayors="ALBANO VERCELLESE" if comune_mayors=="ALBANO V.SE"
replace comune_mayors="ALAGNA VALSESIA" if comune_mayors=="ALAGNA V.SA"
replace comune_mayors="CASTELLAVAZZO" if comune_mayors=="CASTELLO LAVAZZO"
replace comune_mayors="CASTELNUOVO BOCCA D'ADDA" if comune_mayors=="CASTELNUOVO B. D'ADDA"
replace comune_mayors="FORIO" if comune_mayors=="FORIO D'ISCHIA"
replace comune_mayors="ISOLA DI CAPO RIZZUTO" if comune_mayors=="ISOLA CAPO RIZZUTO"

replace comune_mayors="AQUILA D'ARROSCIA" if comune_mayors=="AQUILA DI ARROSCIA"
replace comune_mayors="BAJARDO" if comune_mayors=="BAIARDO"
replace comune_mayors="BASTIDA DE' DOSSI" if comune_mayors=="BASTIDA DE'DOSSI"
replace comune_mayors="BRIONE" if comune_mayors=="BRIONE (BS)"
replace comune_mayors="BUJA" if comune_mayors=="BUIA"
replace comune_mayors="CALVAGESE DELLA RIVIERA" if comune_mayors=="CALVAGESE D/RIVIERA"
replace comune_mayors="CASSANO ALL'IONIO" if comune_mayors=="CASSANO ALL' IONIO"
replace comune_mayors="CASSANO ALL'IONIO" if comune_mayors=="CASSANO ALLO IONIO"
replace comune_mayors="CASTELFRANCO PIANDISCO'" if comune_mayors=="CASTELFRANCO PIANDISCO'"
replace comune_mayors="CASTRONUOVO DI SANT'ANDREA" if comune_mayors=="CASTRONUOVO DI SANT¿ANDREA"
replace comune_mayors="CERRETTO LANGHE" if comune_mayors=="CERRETO DELLE LANGHE"
replace comune_mayors="CERRETO D'ASTI" if comune_mayors=="CERRETO D¿ASTI"
replace comune_mayors="CERRINA" if comune_mayors=="CERRINA MONFERRATO"
*replace comune_mayors="CLAUZETTO" if comune_mayors=="CLAUZETTO   *"
replace comune_mayors="COMEZZANO-CIZZAGO" if comune_mayors=="COMEZZANO CIZZAGO"
replace comune_mayors="CONTURSI TERME" if comune_mayors=="CONTURSI-TERME"
replace comune_mayors="COSIO D'ARROSCIA" if comune_mayors=="COSIO DI ARROSCIA"
replace comune_mayors="COSTA SERINA" if comune_mayors=="COSTA DI SERINA"
replace comune_mayors="FARRA D'ALPAGO" if comune_mayors=="FARRA D¿ALPAGO"
replace comune_mayors="FIORENZUOLA D'ARDA" if comune_mayors=="FIORENZUOLA D¿ARDA"
replace comune_mayors="FORLI' DEL SANNIO" if comune_mayors=="FORLI¿ DEL SANNIO"
replace comune_mayors="GABBIONETA BINANUOVA" if comune_mayors=="GABBIONETA-BINANUOVA"
replace comune_mayors="GORNATE OLONA" if comune_mayors=="GORNATE-OLONA"
replace comune_mayors="JOLANDA DI SAVOIA" if comune_mayors=="IOLANDA DI SAVOIA"
replace comune_mayors="ISOLA DEL GRAN SASSO D'ITALIA" if comune_mayors=="ISOLA DEL GRAN SASSO D¿ITALIA"
replace comune_mayors="MAIERA'" if comune_mayors=="MAIERA¿"
replace comune_mayors="MALBORGHETTO VALBRUNA" if comune_mayors=="MALBORGHETTO-VALBRUNA"
replace comune_mayors="MASSA LUBRENSE" if comune_mayors=="MASSALUBRENSE"
replace comune_mayors="MONTALBANO JONICO" if comune_mayors=="MONTALBANO IONICO"
replace comune_mayors="MONTE COLOMBO" if comune_mayors=="MONTE  COLOMBO"
replace comune_mayors="MONTECASTELLO" if comune_mayors=="MONTE CASTELLO"
replace comune_mayors="MONTE SAN GIOVANNI IN SABINA" if comune_mayors=="MONTE SAN GIOVANNI"
replace comune_mayors="MONTEBELLO JONICO" if comune_mayors=="MONTEBELLO IONICO"
replace comune_mayors="MONTE COMPATRI" if comune_mayors=="MONTECOMPATRI"
replace comune_mayors="OSPEDALETTO D'ALPINOLO" if comune_mayors=="OSPEDALETTO D¿ALPINOLO"
replace comune_mayors="OLTRONA DI SAN MAMETTE" if comune_mayors=="OLTRONA DI S. MAMETTE"
replace comune_mayors="PENNA SANT'ANDREA" if comune_mayors=="PENNA SANT'ANDREA"
replace comune_mayors="PERSICO DOSIMO" if comune_mayors=="PERSICO D'OSIMO"
replace comune_mayors="PETRIZZI" if comune_mayors=="PETRIZZI*"
replace comune_mayors="PIEVE D'ALPAGO" if comune_mayors=="PIEVE D¿ALPAGO"
replace comune_mayors="POJANA MAGGIORE" if comune_mayors=="POIANA MAGGIORE"
replace comune_mayors="POJANA MINORE" if comune_mayors=="POIANA MINORE"
replace comune_mayors="PUEGNAGO DEL GARDA" if comune_mayors=="PUEGNAGO SUL GARDA"
replace comune_mayors="QUINTO VERCELLESE" if comune_mayors=="QUINTO V.SE"
replace comune_mayors="REANA DEL ROJALE" if comune_mayors=="REANA DEL ROIALE"
replace comune_mayors="ROCCHETTA SANT'ANTONIO" if comune_mayors=="ROCCHETTA SANT¿ANTONIO"
replace comune_mayors="ROVERE' VERONESE" if comune_mayors=="ROVERE¿ VERONESE"
replace comune_mayors="SAN BENEDETTO PO" if comune_mayors=="S. BENEDETTO PO"
replace comune_mayors="SAN GIACOMO DELLE SEGNATE" if comune_mayors=="S. GIACOMO DELLE SEGNATE"
replace comune_mayors="SAN GIOVANNI DEL DOSSO" if comune_mayors=="S. GIOVANNI DEL DOSSO"
replace comune_mayors="S. MARTINO DI VENEZZE" if comune_mayors=="S. MARTINO DI V."
replace comune_mayors="SAN POLOMATESE" if comune_mayors=="S. POLO MATESE"
replace comune_mayors="SANTARCANGELO DI ROMAGNA" if comune_mayors=="S.ARCANGELO  R."
replace comune_mayors="SAN GIULIANO DEL SANNIO" if comune_mayors=="S.GIULIANO DEL SANNIO"
replace comune_mayors="SALI VERCELLESE" if comune_mayors=="SALI"
replace comune_mayors="SAN BARTOLOMEO VAL CARVAGNA" if comune_mayors=="SAN BARTOLOMEO V. C."
replace comune_mayors="SAN GERVASIO BRESCIANO" if comune_mayors=="SAN GERVASIO B/NO"
replace comune_mayors="SAN NAZZARO VAL CARVAGNA" if comune_mayors=="SAN NAZZARO V. C."
replace comune_mayors="SANTO STINO DI LIVENZA" if comune_mayors=="SAN STINO DI LIVENZA"
replace comune_mayors="SANT'OMOBONO IMAGNA" if comune_mayors=="SANT'OMOBONO TERME"
replace comune_mayors="SANT'ANDREA APOSTOLO DELLO IONIO" if comune_mayors=="SANT¿ANDREA APOSTOLO DELLO IONIO"
replace comune_mayors="SAVIORE DELL'ADAMELLO" if comune_mayors=="SAVIORE D/ADAMELLO"
replace comune_mayors="SERRA DE' CONTI" if comune_mayors=="SERRA DE'CONTI"
replace comune_mayors="TEANA" if comune_mayors=="TEANA   *"
replace comune_mayors="TORELLA DEI LOMBARDI" if comune_mayors=="TORELLA DE' LOMBARDI"
replace comune_mayors="TOSCOLANO MADERNO" if comune_mayors=="TOSCOLANO-MADERNO"
replace comune_mayors="TRENTOLA DUCENTA" if comune_mayors=="TRENTOLA-DUCENTA"
replace comune_mayors="VESPOLATE" if comune_mayors=="VESPOLATE    *"
replace comune_mayors="VIALE" if comune_mayors=="VIALE D'ASTI"



* gen local legislature *
// set fake ele_date in 1994 to account for prior 1994 local legislatures
bys comune_mayors (ele_date): gen local_legi = _n

* save data *
save "$maindir/data/elections/elections_data_0525.dta", replace





