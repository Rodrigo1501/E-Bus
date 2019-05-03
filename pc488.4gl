#################################################################################
# PROGRAMA: pc488.4gl								#
# VERSION : 1.0									#
# OBJETIVO: Funciones - Procesos de Castigo					#
# FECHA   : 07/05/2013								#
# AUTOR   : SS - SAMMY MANUEL MILLONES CUMPA					#
#################################################################################
# MODIFICACIONES
#################################################################################
# CODIGO		REQ		USUARIO					FECHA				MOTIVO
# (@#)1-A 	16900	JCH - JAIME CH. 17/08/2015	DIMENSIONAR LA VARIABLE
# (@#)2-A 		IS - JOHN VILLANUEVA. 28/08/2015	DIMENSIONAR ARRAY P2
# (@#)3-A      HD 27487 EDGARD AREVALO    CAMBIO DE CUENTA DE PROVISION DE CASTIGO
# (@#)4-A   22498 KEVIN ODAR  05/03/2018  PERMITIR AVANZAR AL NO ENCONTRAR PRESTAMOS A CASTIGAR
# (@#)5-A   22483 JUAN SABA  24/05/2018   LOGICA PARA LECTURA DE LA TABLA eefpca  
# (@#)5-B   22483 JUAN SABA  25/06/2018   DATA ENVIADA POR RIESGOS NO PASAR POR 120 DIAS DE ATRASO
# (@#)6-A   23135 ALEX LLAMO - IS   17/07/2018   NUEVA LOGICA DE SELECCION DE CREDITOS A CASTIGAR
# (@#)7-A   23135 MARIO LIMA  -  22/04/2019   OPTIMIZACION DEL PROCESO DE CASTIGOS   
#################################################################################
DATABASE tbsfi

DEFINE	
	# (@#)7-A INICIO
	#t1	RECORD	LIKE pcces.*, # (@#)7-A 24
	t1 RECORD
		pccesnces LIKE pcces.pccesnces
		END RECORD,
	# (@#)7-A FIN
		
	t3	RECORD 
		pctcrdesc LIKE pctcr.pctcrdesc,
		pctcrvctc LIKE pctcr.pctcrvctc,
		pctcrdsal LIKE pctcr.pctcrdsal,
		pctpmckvc LIKE pctpm.pctpmckvc,
		pctpmakvc LIKE pctpm.pctpmakvc,
		pctpmckvl LIKE pctpm.pctpmckvl,
		pctpmakvl LIKE pctpm.pctpmakvl,
		pctpmckm1 LIKE pctpm.pctpmckm1,
		pctpmakm1 LIKE pctpm.pctpmakm1,
		pctpmckm2 LIKE pctpm.pctpmckm2,
		pctpmakm2 LIKE pctpm.pctpmakm2,
		pctpmckej LIKE pctpm.pctpmckej,
		pctpmakej LIKE pctpm.pctpmakej,
		pctpmckca LIKE pctpm.pctpmckca,
		pctpmakca LIKE pctpm.pctpmakca,
		pctpmckad LIKE pctpm.pctpmckad,
		pctpmckaa LIKE pctpm.pctpmckaa,
		pctpmsavg LIKE pctpm.pctpmsavg,
		pctpmsav2 LIKE pctpm.pctpmsav2,
		pctpmsaej LIKE pctpm.pctpmsaej,
		pctpmsdvg LIKE pctpm.pctpmsdvg,
		pctpmsdv2 LIKE pctpm.pctpmsdv2,
		pctpmsdej LIKE pctpm.pctpmsdej,
		pctpmcpcg LIKE pctpm.pctpmcpcg,
		pctpmapcg LIKE pctpm.pctpmapcg
		END RECORD,
				
	t4	RECORD 
		pcctlndoc LIKE pcctl.pcctlndoc
		END RECORD,
				
	t5	RECORD
		pcmpcnpre LIKE pcmpc.pcmpcnpre,
		pcmpccage LIKE pcmpc.pcmpccage, 
		pcmpccmon LIKE pcmpc.pcmpccmon,
		pcmpcstat LIKE pcmpc.pcmpcstat,
		pcmpcfsta LIKE pcmpc.pcmpcfsta,
		pcmpcmpre LIKE pcmpc.pcmpcmpre,
		pcmpcfdes LIKE pcmpc.pcmpcfdes,
		pcmpcsald LIKE pcmpc.pcmpcsald,
		pcmpctcre LIKE pcmpc.pcmpctcre,
		pcmpcfvac LIKE pcmpc.pcmpcfvac,
		pcmpcfpvc LIKE pcmpc.pcmpcfpvc,
		pcmpckven LIKE pcmpc.pcmpckven,
		pcmpcpsus LIKE pcmpc.pcmpcpsus,
		pcmpcplaz LIKE pcmpc.pcmpcplaz,
		pcmpcagen LIKE pcmpc.pcmpcagen
		END RECORD,	
			
	t20	RECORD LIKE adusr.*,
	
		tp_pagos	LIKE pctdt.pctdtimpp,
		tt_pagos	LIKE pctdt.pctdtimpp,
		g_cmon		CHAR(4),
		g_stat		CHAR(20),
		g_eact		CHAR(20),
		g_plazo		SMALLINT,
		g_marca		SMALLINT,
		g_ctbl		LIKE pctcn.pctcncctb,  # Cuenta Contable
		g_adic		LIKE pctcn.pctcnadic,  # Cuenta Contable adic
		g_item		SMALLINT,
	
	p1	RECORD
			fech	DATE,
			dias	SMALLINT,
			fcas	DATE,
			tipo	CHAR,
			imax	DECIMAL(14,2)
			END RECORD,

	#(@#)2-A Inicio 					
	#p2	ARRAY[8000] OF RECORD 
	p2	ARRAY[32767] OF RECORD 
	#(@#)2-A Fin
			plaz	SMALLINT,
			cage	INTEGER,
			nomb	CHAR(29),
			capi	DECIMAL(10,2),
			inte	DECIMAL(10,2),
			dpro	DECIMAL(10,2),
			marc	CHAR(1)
			END RECORD,
	p3	RECORD
			fech	DATE,
			tsald	DECIMAL(14,2),
			tprov	DECIMAL(14,2),
			resp	CHAR(1),
			g_desc	INTEGER
			END RECORD,
			
	#p4	ARRAY[5000] OF RECORD										# (@#)1-A
	#p4	ARRAY[10000] OF RECORD										# (@#)1-A 	# (@#)6-A
	p4	ARRAY[32767] OF RECORD										# (@#)7-A
			npre	INTEGER,
			nomb	CHAR(30),
			sald	DECIMAL(14,2),
			prov	DECIMAL(14,2),
			plaz	SMALLINT
			END RECORD,
	# (@#)6-A Inicio
	p5 RECORD #record de parametros de castigo 
		fech DATE, #fecha de seleccion
		imax DECIMAL(14,2), #importe maximo parametrizado por riesgos
		darf SMALLINT, #dias de atraso para creditos refinanciados
		danr SMALLINT, #dias de atraso para creditos NO refinanciados
		tole DECIMAL(14,2), #importe de tolerancia para castigar
		tcof FLOAT, #tipo de cambio oficial
		mesr SMALLINT #meses de recurrencia
	END RECORD,
	p6 RECORD #record de cuentas contables
		cnkr LIKE pctcn.pctcncctb, #cuenta contable capital refinanciado
		cnid LIKE pctcn.pctcncctb #cuenta contable ingreso diferido
	END RECORD,
	g_flgp SMALLINT, #flag de proceso 0:reporte 1:cierre mensual
	# (@#)6-A Fin	
	g_nano		INTEGER,
	g_nmes		INTEGER,
	g_hora		CHAR(8),
	g_fpro		DATE,
	g_datr		SMALLINT,
	g_maxv		INTEGER,
	g_max2		INTEGER,
	g_user		CHAR(3),
	g_vari		INTEGER,
	g_fech		DATE,
	g_tcof		DECIMAL(10,2),
	g_mimp		SMALLINT,
	g_mcon		SMALLINT
	#(@#)4-A Inicio
	#Declarar constantes
	,g_cero SMALLINT
	#(@#)4-A Fin
  ,g_flag SMALLINT # (@#)5-A 
  #,g_proc  CHAR(8)  # (@#)5-A  # (@#)5-B
  #,g_ntri	INTEGER  # (@#)5-A  # (@#)5-B
 	# (@#)7-A INICIO
	,l_text char(500) # Variable para preparar querys
	# (@#)7-A FINAL
# (@#)6-A Inicio
#-------------------------- PROCESO DE SELECCION ----------------------------#
	# (@#)7-A INICIO
FUNCTION f0010_declara_cursores_pc488()
# Descripción: Función que declara los cursores
DEFINE
	l_text CHAR(500)

	LET l_text = " DELETE FROM efpca",
				" WHERE efpcafech = ? "
	PREPARE d_tefpca FROM l_text
	
	LET l_text=" INSERT INTO efpca VALUES(",
				" ?,?,?,?,?,?,",
				" ?,?,?,?,?,?,",
				" ?,?,?,?,?)"
	PREPARE i_tefpca FROM l_text 
	

	
	LET l_text = " SELECT pcmpcfprv,pcmpccage,pcmpcsald",
			" FROM pcmpc",
			" WHERE pcmpcnpre = ? "
	PREPARE s_tpcmpc FROM l_text 
	
	LET l_text = " SELECT pcmpccmon,pcmpcstat,pcmpcrseg,pcmpcsald,pcmpcfprv",
			" FROM pcmpc",
			" WHERE pcmpcnpre = ? "
	PREPARE s_tpcmpc02 FROM l_text
	
	LET l_text = "DELETE FROM pvprv ",
			"WHERE pvprvnopr = ? " 
	PREPARE p_tpvprv FROM l_text
	
	LET l_text = "SELECT pvtrncage,pvtrnnmod,pvtrnnopr,sum(pvtrnimpt) ",
			"FROM pvtrn ",
			"WHERE pvtrnstat = ? ",
			"AND pvtrnnopr = ? ",
			"GROUP BY 1,2,3 "
	PREPARE p_cpvtrn FROM l_text 

	LET l_text = "INSERT INTO pvprv ",
			"VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)"
	PREPARE p_ipvprv FROM l_text 
	
	LET l_text = " SELECT efpagesta,efpagfech,efpaghora,efpagarch,efpagplaz,efpagmoti,efpagcorr",
			" FROM efpag",
			" WHERE efpagnpre = ? " 
	PREPARE s_tefpag FROM l_text 
	

	LET l_text = " SELECT epcimcdatr",
	" FROM epcimc",
	" WHERE epcimcnano = ? AND epcimcnmes = ? AND epcimcmrcb = ?"
	PREPARE s_tepcimc FROM l_text
	
	LET l_text = " SELECT epcimcimes",
			" FROM epcimc",
			" WHERE epcimcnano = ?",
			" AND epcimcnmes = ?",
			" AND epcimcmrcb = ?"
	PREPARE s_tepcimc01 FROM l_text
	
	LET l_text = " SELECT SUM(pcmpcsald)",
			" FROM pcmpc",
			" WHERE pcmpcstat = ?"
	PREPARE ss_tpcmpc FROM l_text
	
	LET l_text = " SELECT COUNT(efpcafech),MAX(efpcadcas)",
			" FROM efpca",
			" WHERE efpcafech = ?",
			" AND efpcastat = ?"
	PREPARE scm_efpca FROM l_text
	
	LET l_text = " SELECT efpcanpre",
		 " FROM efpca",
		 " WHERE efpcafech = ?",
		 " AND efpcastat = ?"
	PREPARE s_tefpca02 FROM l_text
	DECLARE q_reco CURSOR FOR s_tefpca02
	
	LET l_text = " UPDATE efpca",
			" SET efpcastat = ?",
			" WHERE efpcanpre = ?",
			" AND efpcafech = ?"
	PREPARE u_tefpca02 FROM l_text
	
	LET l_text = " INSERT INTO pcces", 
		" VALUES (?,?,?,?,?,?,?,?,?,?)"
	PREPARE i_tpcces FROM l_text
	
	LET l_text = " UPDATE pcmpc",
				" SET pcmpcstat = ?,",
					" pcmpcstan = ?,",
					" pcmpcfsta = ?,",
					" pcmpcpsus = ?,",
					" pcmpcpdvg = ?",
				" WHERE pcmpcnpre = ?"
	PREPARE u_tpcmpc01 FROM l_text
	
	LET l_text = " UPDATE efpag", 
				" SET efpagesta = ?",
				" WHERE efpagnpre = ?"
	PREPARE u_tefpag01 FROM l_text
	
	LET l_text = " UPDATE efphi",
		" SET efphimrcb = ?",
		" WHERE efphinpre = ?",
		" AND efphimrcb = ?"
	PREPARE u_tefphi FROM l_text
	
	LET l_text = " INSERT INTO efphi(efphintra,efphinpre,efphiesta,efphifech,",
			" efphihora,efphiarch,efphiplaz,efphimoti,",
			" efphifpro,efphihpro,efphiuser,efphimrcb,efphicorr)",
			" VALUES(?,?,?,?,?,?,?,?,TODAY,?,?,?,?)"
	PREPARE i_tefphi FROM l_text

	LET l_text = " SELECT pcmpcnpre, pcmpccage,pcmpccmon,",
						" pcmpcstat,pcmpcfsta,pcmpcmpre,",
						" pcmpcfdes,pcmpcsald,pcmpctcre,",
						" pcmpcfvac,pcmpcfpvc,pcmpckven,",
						" pcmpcpsus,pcmpcplaz,pcmpcagen ",
					" FROM pcmpc",
					" WHERE pcmpcnpre = ?",
					" AND pcmpcstat BETWEEN 2 AND 7"
	PREPARE s_tpcmpc03 FROM l_text
	
	LET l_text = " SELECT pccondesc",
			" FROM pccon",
			" WHERE pcconpref = ?",
			" AND pcconcorr = ?"
	PREPARE s_tpccondesc FROM l_text
	
	LET l_text = " SELECT pctcrdesc,pctcrvctc,pctcrdsal,",
			" pctpmckvc,pctpmakvc,pctpmckvl,",
			" pctpmakvl,pctpmckm1,pctpmakm1,",
			" pctpmckm2,pctpmakm2,pctpmckej,",
			" pctpmakej,pctpmckca,pctpmakca,",
			" pctpmckad,pctpmckaa,pctpmsavg,",
			" pctpmsav2,pctpmsaej,pctpmsdvg,",
			" pctpmsdv2,pctpmsdej,pctpmcpcg,",
			" pctpmapcg",
			" FROM    pctcr,pctpm",
			" WHERE   pctcrtcre = ?",
			" AND     pctpmtcre = ?",
			" AND     pctpmcmon = ?"
	PREPARE s_tpct_cr_pm FROM l_text
	
	LET l_text = " SELECT efpcanpre,efpcadatr,efpcaplaz,efpcacmon",
			" FROM efpca",
			" WHERE efpcafech = ?",
			" AND efpcastat = ?"
	PREPARE s_tefpca03 FROM l_text
	DECLARE d_cursor CURSOR WITH HOLD FOR s_tefpca03
	
	LET l_text = " SELECT efpcanpre, gbagenomb, pcmpcsald, pcmpccage, pcmpcplaz",
			" FROM efpca, pcmpc, gbage",
			" WHERE efpcanpre = pcmpcnpre",
			" AND efpcafech = ?",
			" AND efpcastat = ?",
			" AND pcmpcstat < ?",
			" AND pcmpccage = gbagecage"
	PREPARE s_t_efgbpc FROM l_text
	DECLARE q_tmp CURSOR FOR s_t_efgbpc
	
END FUNCTION

FUNCTION f0010_libera_cursores_pc488()
# Descripción: Función que libera los cursores
	FREE i_tefpca
	FREE s_tpcmpc
	FREE s_tpcmpc02
	FREE p_tpvprv
	FREE p_cpvtrn
	FREE p_ipvprv
	FREE s_tefpag
	FREE s_tepcimc
	FREE d_tefpca
	FREE s_tepcimc01
	FREE ss_tpcmpc
	FREE scm_efpca
	FREE s_tefpca02
	FREE q_reco
	FREE u_tefpca02
	FREE i_tpcces
	FREE u_tpcmpc01
	FREE u_tefpag01
	FREE u_tefphi
	FREE i_tefphi
	FREE s_tpcmpc03
	FREE s_tpccondesc
	FREE s_tpct_cr_pm
	FREE s_tefpca03
	FREE d_cursor
	FREE s_t_efgbpc
	FREE q_tmp
END FUNCTION
	# (@#)7-A FINAL

FUNCTION f0100_proceso_seleccion_pc488(l_flag, l_fech, l_tcof)
#DESCRIPCION: funcion principal para seleccionar creditos a castigar
DEFINE
	l_tcof FLOAT, #tipo de cambio oficial
	l_flag SMALLINT, #flag de aplicativo
	l_fech DATE, #Fecha de proceso de seleccion
	l_const_0 SMALLINT, #constante numero 0
	l_const_1 SMALLINT #constante numero 1
	,l_const_3 SMALLINT # constante numero 3 
	,l_const_4 SMALLINT # constante numero 4
	,l_const_5 SMALLINT # constante numero cinco
	,l_const_6 SMALLINT # constante numero 6
	
	######################################
	#Constantes:
	LET l_const_0 = 0
	LET l_const_1 = 1
	LET l_const_3 = 3
	LET l_const_4 = 4
	LET l_const_5 = 5
	LET l_const_6 = 6
	######################################
	LET g_flgp = l_flag
	LET p5.tcof = l_tcof
	LET p5.fech = f5010_fin_mes_pc488(l_fech)
	IF NOT l_flag = l_const_0 THEN #reporte
		LET p1.fcas = p5.fech
	END IF
	
	IF NOT f5000_buscar_variables_seleccion_pc488() THEN
		ERROR "Se produjo error al establecer variables." SLEEP 2
		RETURN FALSE
	END IF
	
	IF NOT f0100_proceso_seleccionar_creditos_pc488() THEN
		ERROR "Se produjo error al seleccionar creditos." SLEEP 2
		RETURN FALSE
	END IF
	CALL p3000_elimina_temporales_pc488(l_const_3)
	CALL p3000_elimina_temporales_pc488(l_const_5)
	CALL p3000_elimina_temporales_pc488(l_const_6)
	IF l_flag = l_const_1 THEN #cierre mensual
		IF NOT f1000_insertar_creditos_pc488() THEN
			RETURN FALSE
		END IF
		CALL p3000_elimina_temporales_pc488(l_const_4)
	END IF
	
	RETURN TRUE
END FUNCTION

FUNCTION p0100_proceso_verificar_creditos_seleccionados_pc488()
#DESCRIPCION: verificar que los creditos seleccionados sean los correctos
DEFINE
	l_sql CHAR(1000), #cadena de consulta a BD
	l_const_1 SMALLINT, #constante numero 1
	l_const_0 SMALLINT, #constante numero 0
	l_npre INTEGER, #numero de credito
	l_sqle INTEGER #codigo de error
	
	#############################
	#Constantes:
	LET l_const_1 = 1
	LET l_const_0 = 0
	#############################
	
	IF NOT f0100_proceso_seleccionar_creditos_pc488() THEN
		ERROR "Se produjo error al seleccionar creditos." SLEEP 2
		RETURN FALSE
	END IF
	
	LET l_sql = "SELECT efpcanpre FROM efpca WHERE efpcafech = ? AND efpcastat = ", l_const_1, 
	" AND NOT efpcanpre IN (SELECT npre FROM tmp_data)"
	PREPARE p_query_25 FROM l_sql
	DECLARE c_cursor_25 CURSOR FOR p_query_25
	
	LET l_sql = "UPDATE efpca SET efpcastat = ? WHERE efpcanpre = ? "
	PREPARE p_query_26 FROM l_sql
	
	FOREACH c_cursor_25 USING p5.fech INTO l_npre
		EXECUTE p_query_26 USING l_const_0, l_npre
		LET l_sqle = SQLCA.SQLCODE
		IF l_sqle < l_const_0 THEN
			DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
			RETURN FALSE
		END IF
	END FOREACH
END FUNCTION

FUNCTION f1000_insertar_creditos_pc488()
#DESCRIPCION: Altas a los registros de creditos seleccionados a castigar
DEFINE
	l_sql CHAR(1000), #cadena de consulta a BD
	l_cmon SMALLINT, #codigo de moneda
	l_npre INTEGER, #numero de credito
	l_plaz SMALLINT, #plaza
	l_sald DECIMAL(14,2), #saldo
	l_pdvg DECIMAL(14,2), #interes devengado
	l_psus DECIMAL(14,2), #interes en suspenso
	l_mora DECIMAL(14,2), #mora
	l_gast DECIMAL(14,2), #gasto
	l_prov DECIMAL(14,2), #provision
	l_datr INTEGER, #dias de atraso
	l_const_1 SMALLINT, #constante numero uno
	l_const_0 SMALLINT, #constante numero cero
	l_user CHAR(3), #usuario
	l_fech DATE, #fecha
	l_hora VARCHAR(15), #hora
	l_atra SMALLINT, #dias parametrizados para castigar
	l_marc SMALLINT, #marca de credito refinanciado
	l_sqle INTEGER #codigo de error
	
	###############################
	#Constantes:
	LET l_const_1 = 1
	LET l_const_0 = 0
	###############################
	
	LET l_atra = l_const_0
	LET l_user = ARG_VAL(l_const_1)
	LET l_fech = TODAY
	LET l_hora = TIME
	
	LET l_sql = "DELETE FROM efpca WHERE efpcafech = ? "
	PREPARE p_query_21 FROM l_sql
	
	LET l_sql = "SELECT cmon, npre, plaz, sald, pdvg, psus, mora, gast, prov, datr, marc FROM tmp_data"
	PREPARE p_query_22 FROM l_sql
	DECLARE c_cursor_22 CURSOR WITH HOLD FOR p_query_22
		
	LET l_sql = "INSERT INTO efpca(efpcafech, efpcacmon, efpcanpre, efpcaplaz, efpcastat, efpcamovd, ",
	" efpcadcas, efpcacapi, efpcapdvg, efpcapsus, efpcamora, efpcagast, efpcaprov, efpcadatr, efpcauser, efpcafpro, efpcahora) ",
	" VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
	PREPARE p_query_23 FROM l_sql
	
	BEGIN WORK
	
	EXECUTE p_query_21 USING p5.fech
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	
	FOREACH c_cursor_22 INTO l_cmon, l_npre, l_plaz, l_sald, l_pdvg, l_psus, l_mora, l_gast, l_prov, l_datr, l_marc
		IF l_marc = l_const_1 THEN
			LET l_atra = p5.darf
		ELSE
			LET l_atra = p5.danr
		END IF
		EXECUTE p_query_23 USING p5.fech, l_cmon, l_npre, l_plaz, l_const_1, l_const_0, l_atra, l_sald, l_pdvg, 
		l_psus, l_mora, l_gast, l_prov, l_datr, l_user, l_fech, l_hora
		LET l_sqle = SQLCA.SQLCODE
		IF l_sqle < l_const_0 THEN
			DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
			ROLLBACK WORK
			RETURN FALSE
		END IF
	END FOREACH
	COMMIT WORK
	RETURN TRUE
END FUNCTION

FUNCTION f5000_buscar_variables_seleccion_pc488()
#DESCRIPCION: obtener las variables de marcado para el proceso de seleccion por mes y año
DEFINE
	l_sql CHAR(1000), #cadena de consulta a BD
	l_sqle INTEGER, #codigo de error
	l_const_0 SMALLINT, #constante numero cero
	l_const_100 SMALLINT, #constante numero cien
	l_anio SMALLINT, #año
	l_mes SMALLINT #mes
	
	############################
	#Constantes:
	LET l_const_0 = 0
	LET l_const_100 = 100
	############################
	
	LET l_anio = l_const_0
	LET l_mes = l_const_0
	LET l_sql = NULL
	#Obtener importe maximo, dias de atraso (para refinanciados y no refinanciados), tolerancia de castigo
	#y numero de meses de recurrencia de no haber pagado
	LET l_sql = "SELECT ecricaimpm, ecricaatre, ecricaatnr, ecricaimpt, ecricarepg FROM ecrica ",
	" WHERE ecricayear = ? AND ecricamont = ? AND ecricamrcb = ", l_const_0
	PREPARE p_query_03 FROM l_sql
	
	LET l_anio = YEAR(p5.fech)
	LET l_mes = MONTH(p5.fech)
	
	EXECUTE p_query_03 USING l_anio, l_mes INTO p5.imax, p5.darf, p5.danr, p5.tole, p5.mesr
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	IF l_sqle = l_const_100 THEN
		ERROR "Parametros no existen" SLEEP 2
		RETURN FALSE
	END IF
	IF p5.imax IS NULL OR p5.darf IS NULL OR p5.danr IS NULL OR p5.tole IS NULL OR p5.mesr IS NULL THEN
		ERROR "Parametros no existen" SLEEP 2
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION

FUNCTION f0100_proceso_seleccionar_creditos_pc488()
#DESCRIPCION: funcion para seleccionar los creditos a castigar
DEFINE 
	l_const_3 SMALLINT, #constante numero 3
	l_const_4 SMALLINT, #constante numero 4
	l_const_5 SMALLINT, #constante numero 5
	l_const_0 SMALLINT, #constante numero 0
	l_const_1 SMALLINT, #constante numero 1
	l_const_2 SMALLINT, #constante numero 2
	l_const_6 SMALLINT, #constante numero 6
	l_const_9 SMALLINT, #constante numero 9
	l_const_100 SMALLINT, #constante numero 100
	l_datm SMALLINT, #cantidad de dias de atraso menor
	l_sql CHAR(1000), #cadena de consulta
	l_cagn INTEGER, #codigo de agenda
	l_plaz SMALLINT, #numero de plaza
	l_datr SMALLINT, #dias de atraso
	l_cage INTEGER, #codigo de agenda
	l_nomb VARCHAR(150), #nombre
	l_npre INTEGER, #numero de credito
	l_tcre SMALLINT, #tipo de credito
	l_cmon SMALLINT, #codigo de moneda
	l_sald DECIMAL(14,2), #saldo
	l_pdvg DECIMAL(14,2), #interes devengado
	l_psus DECIMAL(14,2), #interes de suspenso
	l_atra SMALLINT, #dias de atraso
	l_flag SMALLINT, #flag de credito a castigar
	l_flcr SMALLINT, #flag de credito 1:refiananciado|0: no refinanciado
	l_cont SMALLINT, #contador
	l_fini DATE, #fecha inicio
	l_ffin DATE, #fecha fin
	l_cttr SMALLINT, #contador
	l_hoss VARCHAR(20), #hoss
	l_cali SMALLINT, #calificacion
	l_const_88 SMALLINT, #constante agencia central 88
	l_const_F CHAR(1), #constante letra F
	l_fech DATE, #fecha
	l_fechh DATE, #fecha
	l_capi DECIMAL(14,2), #capital
	l_mont DECIMAL(14,2), #monto
	l_carg SMALLINT, #cargo
	l_totm DECIMAL(14,2), #total monto
	l_totg DECIMAL(14,2), #total cargo
	l_fpvc DATE, #fecha 
	l_tasa FLOAT, #tasa
	l_const_365 SMALLINT, #constante numero 365
	l_const_143 SMALLINT, #constante numero 143
	l_desc VARCHAR(10), #descripcion
	l_const_mora CHAR(4), #constante 'mora'
	l_prov DECIMAL(14,2), #provision
	l_indi DECIMAL(10,2), #importe ingreso diferido
	l_sqle INTEGER, #codigo de error
	l_flac SMALLINT, #Flag que indica que un prestamos fue castigado, se ituliza para poder castigar los demas prestamos del cliente.
	l_impt DECIMAL(14,2), #Importe saldo a castigar
	l_fcan DATE, #fecha del cierre anterior
	l_con2 SMALLINT #contador
	# VARIABLES DE PROGRESO
	,l_n2      INTEGER #Contador para el c_cursor_00
	,l_n       INTEGER #Contador para el c_cursor_02
	,l_count   INTEGER #Cantidad total de clientes que seran procesados
	,l_count_1 INTEGER #Cantidad total de creditos que seran procesados
	# PROGRESO FIN	
	##########################
	#Constantes
	LET l_const_0 = 0
	LET l_const_1 = 1
	LET l_const_2 = 2
	LET l_const_3 = 3
	LET l_const_4 = 4
	LET l_const_5 = 5
	LET l_const_6 = 6
	LET l_const_9 = 9
	LET l_const_88 = 88
	LET l_const_F = 'F'
	LET l_const_365 = 365
	LET l_const_mora = 'MORA'
	LET l_const_100 = 100
	LET l_const_143 = 143
	##########################
	
	CALL p7000_crear_temporales_pc488(l_const_3)
	CALL p7000_crear_temporales_pc488(l_const_4)
	CALL p7000_crear_temporales_pc488(l_const_5)
	
	LET l_cage = l_const_0
	LET l_nomb = NULL
	LET l_npre = l_const_0
	LET l_tcre = l_const_0
	LET l_cmon = l_const_0
	LET l_sald = l_const_0
	LET l_pdvg = l_const_0
	LET l_psus = l_const_0
	LET l_atra = l_const_0
	LET l_flcr = l_const_0
	LET l_flag = l_const_0
	LET l_fini = NULL
	LET l_ffin = NULL
	LET l_datm = l_const_0
	LET l_cttr = l_const_0
	LET l_cali = l_const_0
	LET l_fech = NULL
	LET l_fechh = NULL
	LET l_capi = l_const_0
	LET l_mont = l_const_0
	LET l_carg = l_const_0
	LET l_totm = l_const_0
	LET l_totg = l_const_0
	LET l_prov = l_const_0
	LET l_fcan = NULL
	
	SET ISOLATION TO DIRTY READ
	
	#Verificar el menor dia de atraso para no traer data innecesaria en cursor principal
	IF p5.darf = p5.danr THEN
		LET l_datm = p5.darf
	ELSE
		IF p5.darf > p5.danr THEN
			LET l_datm = p5.danr
		ELSE
			LET l_datm = p5.darf
		END IF
	END IF
# PROGRESO
	LET l_sql = NULL
	LET l_sql = "SELECT COUNT(DISTINCT pcmpccage) FROM pcmpc",
		" WHERE pcmpcnpre = pcmpcnpre ",
		" AND pcmpcmrcb =",l_const_0," AND pcmpcstat BETWEEN ",l_const_2," AND ",l_const_6,
		" AND pcmpctcre NOT IN (SELECT pctcrtcre FROM tmp_hipotecarios)"
	PREPARE p_query_100 FROM l_sql
	
	LET l_sql = NULL
	LET l_sql = "SELECT COUNT(pcmpcnpre) FROM pcmpc",
		" WHERE pcmpcnpre = pcmpcnpre ",
		" AND pcmpcmrcb =",l_const_0," AND pcmpcstat BETWEEN ",l_const_2," AND ",l_const_6,
		" AND pcmpctcre NOT IN (SELECT pctcrtcre FROM tmp_hipotecarios)"
	PREPARE p_query_10_1 FROM l_sql	
	
	EXECUTE p_query_100 INTO l_count
  LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN DISPLAY "Error de base de datos: ", l_sqle SLEEP 1 RETURN FALSE END IF
			
	EXECUTE p_query_10_1 INTO l_count_1
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN DISPLAY "Error de base de datos: ", l_sqle SLEEP 1 RETURN FALSE END IF
# PROGRESO FIN	
	LET l_sql = NULL
	LET l_sql = "SELECT pcmpccage,sum(NVL(pcmpcsald,0))",
		" FROM pcmpc",
		" WHERE pcmpcnpre = pcmpcnpre ",
		" AND pcmpcmrcb = ", l_const_0,
		" AND pcmpcstat BETWEEN ", l_const_2," AND ", l_const_6,
		" AND pcmpctcre NOT IN (SELECT pctcrtcre FROM tmp_hipotecarios)",
		" GROUP BY pcmpccage",
		" ORDER BY ",l_const_2," DESC"
	PREPARE p_query_00 FROM l_sql
	DECLARE c_cursor_00 CURSOR FOR p_query_00
	
	#Obtener clientes por plaza con dias de atraso mayor a la minima cantidad de dias de atraso parametrizado
	#Cursor principal
	LET l_sql = NULL
	LET l_sql = "SELECT pcmpccage, pcmpcplaz,pcmpcnpre,pcmpctcre,pcmpccmon,pcmpcsald,pcmpcpdvg,pcmpcpsus",
		" FROM pcmpc",
		" WHERE pcmpcnpre = pcmpcnpre ",
		" AND pcmpcmrcb = ", l_const_0,
		" AND pcmpcstat BETWEEN ", l_const_2," AND ", l_const_6,
		" AND pcmpctcre NOT IN (SELECT pctcrtcre FROM tmp_hipotecarios)",
		" AND pcmpccage = ?"
	PREPARE p_query_02 FROM l_sql
	DECLARE c_cursor_02 CURSOR FOR p_query_02
	
	LET l_sql = NULL
	LET l_sql = 
		" SELECT MIN(pcppgfech)",
		" FROM pcppg",
		" WHERE pcppgnpre = ?",
		" AND pcppgmpag = ?",
		" AND pcppgfech = pcppgfech"
	PREPARE p_query_02_1 FROM l_sql
	
	LET l_sql = NULL
	LET l_sql = 
		" SELECT gbagenomb",
		" FROM gbage",
		" WHERE gbagecage = ?"
	PREPARE p_query_02_2 FROM l_sql
	
	#Verificar si el credito es refinanciado
	LET l_sql = "SELECT FIRST ", l_const_1," pcmpctcre FROM pcmpc WHERE pcmpcnpre = ? AND pcmpcmrcb = ", l_const_0
	PREPARE p_query_05 FROM l_sql
	
	#Verificar si el cliente realizo algun pago en los n(p5.mesr) meses anteriores al castigo
	LET l_sql = "SELECT COUNT(pchtrnpre) FROM pchtr ",
	" WHERE pchtrttrn = ", l_const_2,
	" AND pchtrnpre = ? ",
	" AND pchtrftra BETWEEN ? AND ? ",
	" AND pchtrmrcb = ", l_const_0
	PREPARE p_query_06 FROM l_sql
	
	LET l_hoss = f0020_buscar_bd_gb000(l_const_88,l_const_F)
	#Verificar que el cliente tenga calificacion dudosa al cierre anterior
	LET l_sql = "SELECT efragcalf FROM ", l_hoss,":efrag ", 
	" WHERE efragcage = ? AND efragfech = ? "
	PREPARE p_query_07 FROM l_sql
	
	LET l_sql = "INSERT INTO tmp_data (cage, nomb, npre, tcre, cmon, sald, pdvg, psus, datr, marc, plaz, prov, gast, mora) ",
	" VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
	PREPARE p_query_08 FROM l_sql
	
	LET l_sql = "SELECT pcppgfech, pcppgcapi, pcpcgmont, pcpcgcarg FROM pcppg, pcpcg ",
	" WHERE pcpcgnpre = pcppgnpre ",
	" AND pcppgnpre = ? ",
	" AND pcppgmpag = ", l_const_0,
	" AND NOT pcpcgmrcb = ", l_const_9,
	" ORDER BY pcppgfech "
	PREPARE p_query_10 FROM l_sql
	DECLARE c_cursor_10 CURSOR FOR p_query_10
		
	#Provision
	LET l_sql = "SELECT SUM(pvtrnimpt) FROM pvtrn ",
	" WHERE pvtrnnopr = ? AND NOT pvtrnstat = ", l_const_9
	PREPARE p_query_13 FROM l_sql
	
	LET l_sql = "DELETE FROM tmp_data WHERE cage = ?"
	PREPARE p_query_40_1 FROM l_sql
	
	LET l_indi = l_const_0
	LET l_sql = "EXECUTE FUNCTION ", f0020_buscar_bd_gb000(l_const_0,l_const_F) CLIPPED,":pa_sfi_pc_asiento_credito_refinanciado(?) "
	PREPARE p_query_43 FROM l_sql
	
	#Saldo total a castigar de la seleccion
	LET l_sql = "SELECT SUM(CASE WHEN cmon = ", l_const_1," THEN NVL(sald,0) ELSE (NVL(sald,0) * ", p5.tcof," ) END) FROM tmp_data"
	PREPARE p_query_18 FROM l_sql
	
	CALL f0100_proceso_calcular_rango_pc488() RETURNING l_fini, l_ffin
	LET l_fcan = MDY(MONTH(l_ffin),l_const_1,YEAR(l_ffin)) - 1 UNITS DAY
	LET l_n  = l_const_0  # PROGRESO
	LET l_n2 = l_const_0  # PROGRESO
	FOREACH c_cursor_00 INTO l_cage,l_sald
		LET l_con2 = l_const_0
		LET l_sald = NULL
		LET l_n2 = l_n2 + l_const_1  # PROGRESO		
		FOREACH c_cursor_02 USING l_cage INTO l_cagn, l_plaz, l_npre, l_tcre, l_cmon, l_sald, l_pdvg, l_psus
			LET l_n = l_n + l_const_1  # PROGRESO
			MESSAGE "T.CLIENT::",l_n2," de ",l_count,"/T.PREST:: PRESTAMO:",l_npre, " ...", l_n ," de ",l_count_1  # PROGRESO
			LET l_flac = TRUE
			LET l_fechh = NULL
			
			#Obtiene ultima fecha de pago (pcppg)
			EXECUTE p_query_02_1 USING l_npre, l_const_0 INTO l_fechh
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_const_0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			
			# Evaluar dias de Atraso
			LET l_datr = p5.fech - l_fechh
			LET l_atra = l_datr
			IF l_datr > l_datm THEN
			ELSE
				LET l_flac = FALSE
			END IF
			
			# Obtiene el nombre del cliente
			EXECUTE p_query_02_2 USING l_cagn INTO l_nomb
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_const_0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			
			LET l_flcr = l_const_0
			LET l_cont = l_const_0
			#Verificar si credito es refinanciado
			EXECUTE p_query_05 USING l_npre INTO l_cont
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_const_0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			IF l_cont IS NULL THEN
				LET l_cont = l_const_0
			END IF
			IF l_cont = l_const_143 THEN
				LET l_flcr = l_const_1
			END IF
			
			#Dias de atraso segun tipo de credito
			IF l_flcr = l_const_1 THEN #credito refinanciado
				IF NOT l_atra > p5.darf THEN
					LET l_flac = FALSE
				END IF
				
				#Verificar que el cliente tenga calificacion dudosa al cierre anterior
				EXECUTE p_query_07 USING l_cagn, l_fcan INTO l_cali
				LET l_sqle = SQLCA.SQLCODE
				IF l_sqle < l_const_0 THEN
					DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
					RETURN FALSE
				END IF
				IF l_sqle = l_const_100 OR l_cali IS NULL THEN
					LET l_flac = FALSE
				END IF
				IF NOT l_cali >= l_const_3 THEN
					LET l_flac = FALSE
				END IF
			ELSE #credito no refinanciado
				IF NOT l_atra > p5.danr THEN
					LET l_flac = FALSE
				END IF
			END IF
			
			#Verificar si el cliente realizo algun pago en los n(p5.mesr) meses anteriores al castigo
			EXECUTE p_query_06 USING l_npre, l_fini, l_ffin INTO l_cttr
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_const_0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			IF l_cttr IS NULL THEN
				LET l_cttr = l_const_0
			END IF
			IF NOT l_cttr = l_const_0 THEN #Realizo un pago
				LET l_flac = FALSE
			END IF
			
			IF l_flac = TRUE THEN
				LET l_con2 = l_con2 + l_const_1
			END IF
			
			LET l_cont = l_const_0
			#Verificar si credito es refinanciado
			EXECUTE p_query_05 USING l_npre INTO l_cont
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_const_0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			IF l_cont IS NULL THEN
				LET l_cont = l_const_0
			END IF
			IF l_cont = l_const_143 THEN
				LET l_flcr = l_const_1
			ELSE
				LET l_flcr = l_const_0
			END IF
			
			#guardar en temporal
			LET l_indi = l_const_0
			IF g_flgp = l_const_1 AND l_flcr = l_const_1 THEN
				EXECUTE p_query_43 USING l_npre INTO l_sald, l_indi, l_sqle
				IF l_sqle < l_const_0 THEN DISPLAY "ERROR DE BASE DE DATOS: ",l_sqle RETURN FALSE END IF
			END IF
			
			LET l_totm = l_const_0
			LET l_totg = l_const_0
			FOREACH c_cursor_10 USING l_npre INTO l_fech, l_capi, l_mont, l_carg
				LET l_desc = NULL
				CALL f0600_cargos_pc000(l_npre, l_cmon, l_fpvc, l_capi, l_const_365, l_carg, l_mont, p5.fech, l_capi, l_tasa, l_tcre, p5.fech - l_fech)
				RETURNING l_mont,l_desc
				IF l_mont IS NULL THEN 
					LET l_mont = l_const_0
				END IF
				IF l_desc[l_const_1,l_const_4] = l_const_mora THEN
					LET l_totm = l_totm + l_mont
				ELSE
					LET l_totg = l_totg + l_mont
				END IF
			END FOREACH
			
			#Provision
			EXECUTE p_query_13 USING l_npre INTO l_prov
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_const_0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			IF l_prov IS NULL THEN
				LET l_prov = l_const_0
			END IF
			
			# INSERT A LA TEMPORAL
			EXECUTE p_query_08 USING l_cagn, l_nomb, l_npre, l_tcre, l_cmon, l_sald, l_pdvg, l_psus, l_atra, l_flcr, l_plaz, l_prov, l_totg, l_totm
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_const_0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			
			-- Limpiando variables del Foreach --
			LET l_cagn = NULL
			LET l_plaz = NULL
			LET l_npre = NULL
			LET l_tcre = NULL
			LET l_cmon = NULL
			LET l_sald = NULL
			LET l_pdvg = NULL
			LET l_psus = NULL
			
		END FOREACH
		
		IF l_con2 = l_const_0 THEN # CLIENTE NO FUE CASTIGADO
			EXECUTE p_query_40_1 USING l_cage
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_const_0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			IF l_sqle = l_const_100 THEN
				DISPLAY "No se pudo quitar al cliente del tmp_data" SLEEP 1
				RETURN FALSE
			END IF
		END IF
		
		#Verificar saldo total a castigar de la seleccion
		LET l_impt = l_const_0
		EXECUTE p_query_18 INTO l_impt
		LET l_sqle = SQLCA.SQLCODE
		IF l_sqle < l_const_0 THEN
			DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		END IF
		IF l_sqle = l_const_100 THEN
			LET l_impt = l_const_0
		END IF
		
		#Verificar que el saldo total este en el rango (incluido tolerancia)
		IF l_impt < (p5.imax + p5.tole) THEN
			CONTINUE FOREACH
		END IF
		IF l_impt = (p5.imax + p5.tole) THEN
			EXIT FOREACH
		END IF
		IF l_impt > (p5.imax + p5.tole) THEN
			EXECUTE p_query_40_1 USING l_cage
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_const_0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			IF l_sqle = l_const_100 THEN
				DISPLAY "No se pudo quitar al cliente del tmp_data" SLEEP 1
				RETURN FALSE
			END IF
			EXIT FOREACH
		END IF
		
		LET l_cage = NULL
		LET l_sald = NULL
	END FOREACH
	MESSAGE "TERMINE:: TOTAL_CLIENTES: ",l_n2,"/TOTAL_PRESTAMOS: ", l_n  # PROGRESO
RETURN TRUE
END FUNCTION

FUNCTION f0100_proceso_calcular_rango_pc488()
#DESCRIPCION: calcular rango de fechas para hallar meses de recurrencia de no haber pagado
DEFINE
	l_const_1 SMALLINT, #constante numero uno
	l_const_0 SMALLINT, #constante numero cero
	l_const_12 SMALLINT, #constante numero doce
	l_fini DATE, #fecha inicial
	l_ffin DATE, #fecha final
	l_nmes SMALLINT, #mes
	l_anio SMALLINT #año
	
	################################
	#Constantes:
	LET l_const_1 = 1
	LET l_const_0 = 0
	LET l_const_12 = 12
	################################
	#Fecha inicio
	LET l_nmes = MONTH(p5.fech) - p5.mesr + l_const_1
	LET l_anio = YEAR(p5.fech)
	IF l_nmes <= l_const_0 THEN
		LET l_nmes = l_nmes + l_const_12
		LET l_anio = l_anio - l_const_1
	END IF
	LET l_fini = MDY(l_nmes,l_const_1,l_anio)
	
	#Fecha fin
	LET l_ffin = p5.fech
	RETURN l_fini, l_ffin
END FUNCTION
# (@#)6-A Fin
#-------------------------- PROCESO DE MARCADO ----------------------------#

FUNCTION f0300_proceso_marcado_pc488(l_fech)
	DEFINE	l_fech	DATE
	# (@)7-A INICIO
	CALL f0010_declara_cursores_pc488()
	# (@)7-A FIN
	IF NOT f0650_variables_marcado_pc488(l_fech) THEN
		ERROR "Se produjo error al establecer variables."		
		SLEEP 2
		RETURN FALSE
	END IF
	CALL f0400_crea_tablas_ef202l()
	IF NOT f0310_detalle_marcado_pc488() THEN
		ERROR "No se pudo completar la operacion."
		SLEEP 2
		RETURN FALSE
	END IF
	ERROR "La operacion culmino con exito."
	
	DROP TABLE tmp_atraso
	DROP TABLE filtros
	# (@)7-A INICIO
	CALL f0010_libera_cursores_pc488()
	# (@)7-A FIN
	RETURN TRUE
END FUNCTION

FUNCTION f0650_variables_marcado_pc488(l_fech)
	DEFINE	l_fech	DATE

	LET g_fech = l_fech
	LET g_hora = TIME
	LET g_fpro = TODAY
	LET g_user = ARG_VAL(1)	
	LET p1.fech = f5010_fin_mes_pc488(g_fech)	
	LET g_nano = YEAR(p1.fech)
	LET g_nmes = MONTH(p1.fech)
	LET p1.fcas = p1.fech
	LET p1.tipo = 'T'
		
	IF NOT f7000_dias_atraso_pc488(g_nano, g_nmes) THEN	
		ERROR "No se configuro Mes en Mantenedor de Indicadores Mensuales."
		RETURN FALSE 
	END IF		
		
	LET p1.imax = f0500_calcular_impmax_pc488(g_nano, g_nmes) 		
	MESSAGE "IMPORTE A CASTIGAR :",p1.imax
	IF p1.imax IS NULL OR p1.imax = 0 THEN	
		ERROR "No se configuro Mes en Mantenedor de Indicadores Mensuales."		
		RETURN FALSE 
	END IF	
	
	RETURN TRUE
END FUNCTION

FUNCTION f5010_fin_mes_pc488(l_fech)
	DEFINE	l_fech	DATE,
		l_newf	DATE

	IF MONTH(l_fech) = 12 THEN 
		LET l_newf = MDY(12,31,YEAR(l_fech))
	ELSE
		LET l_newf = MDY(MONTH(l_fech)+1,1,YEAR(l_fech))-1
	END IF
	
	RETURN l_newf	
END FUNCTION

FUNCTION f7000_dias_atraso_pc488(l_nano, l_nmes)
DEFINE	l_nano	INTEGER,
	l_nmes	INTEGER
		# (@#)7-A INICIO
	,l_const_0 SMALLINT #Constante valor 0
	,l_sqle INTEGER #Codigo de error
	LET l_const_0 = 0
	{SELECT epcimcdatr INTO p1.dias 
	  FROM epcimc 
	 WHERE epcimcnano = l_nano AND epcimcnmes = l_nmes AND epcimcmrcb = 0}
	EXECUTE s_tepcimc USING l_nano, l_nmes, l_const_0 INTO p1.dias 
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN
	IF STATUS = NOTFOUND THEN
		RETURN FALSE	
	END IF
	
	RETURN TRUE	
END FUNCTION

FUNCTION f0250_declarar_puntero_pc488(l_tipo)
	DEFINE	l_text	CHAR(300),
		l_tipo	CHAR(1)
	
	LET l_text="SELECT cage,nomb,MIN(datr) as datr,MIN(plaz),SUM(sald) as sald, ",
		"SUM(pdvg),SUM(psus),SUM(prov) ",
		"FROM filtros "
		
	CASE l_tipo
		WHEN "P"
			LET l_text = l_text CLIPPED," WHERE marc = 0"
		WHEN "N"
			LET l_text = l_text CLIPPED," WHERE marc = 5"
		WHEN "T"
			LET l_text = l_text CLIPPED," WHERE marc IN (0,5)"
	END CASE
	
	LET l_text = l_text CLIPPED," GROUP BY 1,2", "ORDER BY datr DESC, sald ASC"
	
	PREPARE p_curs FROM l_text
	DECLARE q_curs CURSOR FOR p_curs	

END FUNCTION

FUNCTION f5050_recalcular_capitales_pc488(l_imax, l_tipo)
DEFINE 	l_cage	INTEGER,
	l_nomb	CHAR(40),
	l_datr	SMALLINT,
	l_plaz	SMALLINT,
	l_sald	DECIMAL(12,2),
	l_pdvg	DECIMAL(12,2),
	l_psus	DECIMAL(12,2),
	l_prov	DECIMAL(10,2),
	l_imax	DECIMAL(14,2),
	l_tipo	CHAR(1)
	# (@#)7-A INICIO
	,l_const_0 SMALLINT #Constante valor 0
	,l_sqle INTEGER #Codigo de error
	# (@#)7-A FIN
	LET l_cage = NULL
	LET l_nomb = NULL
	LET l_datr = NULL
	LET l_plaz = NULL
	LET l_sald = NULL
	LET l_pdvg = NULL
	LET l_psus = NULL
	LET l_prov = NULL	
	# (@#)7-A INICIO
	LET l_const_0 = 0
	# (@#)7-A FIN
	CALL f0250_declarar_puntero_pc488(l_tipo)
	
	BEGIN WORK
	display "a revisar prestamos"
	FOREACH q_curs INTO l_cage, l_nomb, l_datr, l_plaz, l_sald, l_pdvg, l_psus, l_prov
		IF l_sald IS NULL THEN LET l_sald = 0 END IF			
		IF l_imax < l_sald THEN			
			# (@#)7-A INICIO
			#DELETE FROM filtros WHERE cage = l_cage 
			LET l_text = " DELETE FROM filtros",
	             " WHERE cage = ? " 
			PREPARE d_tfilt FROM l_text 
			EXECUTE d_tfilt USING l_cage
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_const_0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			FREE d_tfilt
			# (@#)7-A FIN
		IF(STATUS<0)THEN
				ROLLBACK WORK
				RETURN FALSE
			END IF
		END IF
		
		LET l_imax = l_imax - l_sald
		ERROR "CLIENTE:",l_cage," SALDO:",l_sald," RESTA:",l_imax
	END FOREACH
	
	COMMIT WORK
	RETURN TRUE	
END FUNCTION

FUNCTION f0310_detalle_marcado_pc488()	
	# (@#)7-A INICIO
DEFINE
	l_const_0 SMALLINT #Constante valor 0
	,l_sqle INTEGER #Codigo de error
	LET l_const_0 = 0
	#DELETE FROM filtros 
	#DELETE FROM tmp_atraso  
	LET l_text = " DROP TABLE filtros" 
	PREPARE d_tfiltros FROM l_text 
	EXECUTE d_tfiltros
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	FREE d_tfiltros
	
	LET l_text = " DROP TABLE tmp_atraso" 
	PREPARE d_tmpatra FROM l_text 
	EXECUTE d_tmpatra
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	FREE d_tmpatra
	# (@#)7-A FIN
	
	DISPLAY "Revisando Prestamos a Castigar"
	display "fecha:",p1.fech
	display "dias:",p1.dias
	CALL f0500_genera_ef202l(p1.fech,p1.dias,1,999)		
	display "importe:",p1.imax
	display "tipo:",p1.tipo
	IF NOT f5050_recalcular_capitales_pc488(p1.imax, p1.tipo) THEN
		ERROR "No se pudo realizar el Recalculo de Capitales."
		SLEEP 2
		RETURN FALSE
	END IF	
	
	CALL f0600_llena_array_pc488()	
	
	IF g_maxv = 0 THEN
		#ERROR "No se encontraron Prestamos a Castigar." #(@#)4-A
		ERROR "Prestamos ya castigados..." #(@#)4-A
		SLEEP 2
		#RETURN FALSE #(@#)4-A
		RETURN TRUE #(@#)4-A
	END IF
	
	CALL set_count(g_maxv)
	
	FOR g_vari = 1 to g_maxv
		LET p2[g_vari].marc = 'X'
	END FOR
	DISPLAY "Registrando prestamos a castigar"
	IF NOT f9500_altas_pc488() THEN
		ERROR "Se produjo un error al insertar los datos."
		SLEEP 2
		RETURN FALSE
	END IF
	
	RETURN TRUE	
END FUNCTION

FUNCTION f0600_llena_array_pc488()
	DEFINE 	j 	INTEGER,
		l1	RECORD
			  cage	INTEGER,
			  nomb 	CHAR(40),
			  datr	SMALLINT,
			  plaz	SMALLINT,
			  sald	DECIMAL(12,2),
			  pdvg	DECIMAL(12,2),
			  psus	DECIMAL(12,2),
			  prov	DECIMAL(10,2)
			END RECORD

	#(@#)2-A Inicio
	#FOR j = 1 TO 8000
	FOR j = 1 TO 32767
	#(@#)2-A Fin
		INITIALIZE p2[j].* TO NULL
	END FOR
		
	LET j = 0
		# (@#)7-A Inicio
	#FOREACH q_curs INTO l1.* 
	FOREACH q_curs INTO l1.cage, l1.nomb, l1.datr, l1.plaz, l1.sald, l1.pdvg, l1.psus, l1.prov
	# (@#)7-A Fin
		IF l1.datr <= p1.dias THEN
		#ERROR l1.cage
		CONTINUE FOREACH
		END IF
		LET j = j + 1		
		
		LET p2[j].plaz = l1.plaz
		LET p2[j].cage = l1.cage
		LET p2[j].nomb = l1.nomb
		LET p2[j].capi = l1.sald
		LET p2[j].inte = l1.pdvg + l1.psus
		LET p2[j].dpro = l1.sald - l1.prov
		LET p2[j].marc = "X"
	END FOREACH
	LET g_maxv = j	
END FUNCTION

FUNCTION f9500_altas_pc488()
	DEFINE	l_pdvg	DECIMAL(10,2),
		l_psus	DECIMAL(10,2),
		l_mora	DECIMAL(10,2),
		l_gast	DECIMAL(10,2),
		l_datr	INTEGER,
		l_marc	SMALLINT,
		l_npre	INTEGER,
		l_dia	DATE,
		l_hora	CHAR(8),
		l_user	CHAR(3),
		l_cmon	SMALLINT,
		l_prov	DECIMAL(10,2)
		# (@#)7-A INICIO
		,l_const_0 SMALLINT #Constante valor 0
		,l_sqle INTEGER #Codigo de error
	LET l_const_0 = 0
	#--Eliminando registros anteriores
	{DELETE FROM efpca 
	WHERE efpcafech = p1.fcas}
	EXECUTE d_tefpca USING p1.fcas
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN
	LET l_dia = TODAY
	LET l_hora = TIME
	LET l_user = arg_val(1)
	
	#--Registrando los nuevos castigos
	BEGIN WORK
	# (@#)7-A INICIO
	LET l_text = " SELECT npre,cmon,pdvg,psus,mora,gast,datr,prov",
	" FROM filtros",
	" WHERE cage = ? "
	PREPARE s_tfiltros FROM l_text
	DECLARE q_det CURSOR FOR s_tfiltros
	# (@#)7-A FIN
	FOR g_vari = 1 TO g_maxv
		# (@#)7-A INICIO
		{DECLARE q_det CURSOR FOR 
			SELECT npre,cmon,pdvg,psus,mora,gast,datr,prov
			FROM filtros
			WHERE cage = p2[g_vari].cage}
		# (@#)7-A FIN
		IF p2[g_vari].marc = "X" THEN
			LET l_marc = 1
		ELSE
			LET l_marc = 0
		END IF
		# (@#)7-A INICIO
		OPEN q_det USING p2[g_vari].cage
		#FOREACH q_det INTO l_npre,l_cmon,l_pdvg,l_psus,l_mora,l_gast,l_datr,l_prov
		FETCH q_det INTO l_npre,l_cmon,l_pdvg,l_psus,l_mora,l_gast,l_datr,l_prov
		WHILE STATUS <> NOTFOUND
			{INSERT INTO efpca VALUES( 
				p1.fcas,l_cmon,l_npre,p2[g_vari].plaz,l_marc,0,
				p1.dias,p2[g_vari].capi,l_pdvg,l_psus,l_mora,l_gast,
				l_prov,l_datr,l_user,l_dia,l_hora)}
			EXECUTE i_tefpca USING p1.fcas,l_cmon,l_npre,p2[g_vari].plaz,l_marc,l_const_0,p1.dias,
				p2[g_vari].capi,l_pdvg,l_psus,l_mora,l_gast,l_prov,l_datr,l_user,l_dia,l_hora
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_const_0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			# (@#)7-A FIN
			IF STATUS < 0 THEN
			    ERROR "Error procesando registro de castigos."
			    ROLLBACK WORK
			    RETURN FALSE
			END IF
		
			# (@#)7-A INICIO
			FETCH q_det INTO l_npre,l_cmon,l_pdvg,l_psus,l_mora,l_gast,l_datr,l_prov
		END WHILE
		FREE s_tfiltros
		FREE q_det
		CLOSE q_det
		#END FOREACH
		# (@#)7-A FIN
	END FOR
	
	COMMIT WORK
	RETURN TRUE
END FUNCTION

#-------------------------- CÁLCULO DE IMPORTE MÁXIMO ----------------------------#

FUNCTION f0500_calcular_impmax_pc488(l_nano, l_nmes)
DEFINE	l_nano	INTEGER,
	l_nmes	INTEGER,
	l_imes	DECIMAL(4,2),
	l_imor	DECIMAL(14,2),
	l_svig	DECIMAL(14,2),
	l_sven	DECIMAL(14,2),
	l_sjud	DECIMAL(14,2),
	l_dind	DECIMAL(14,2),
	l_imax	DECIMAL(14,2),
	l_text	CHAR(400)
	# (@#)7-A INICIO
	,l_const_0 SMALLINT #Constante valor 0
	,l_sqle INTEGER #Codigo de error
	,l_const_6 SMALLINT #Constante valor 6
	# (@#)7-A FIN
	LET l_imes = 0
	LET l_imor = 0
	LET l_svig = 0
	LET l_sven = 0
	LET l_sjud = 0
	LET l_dind = 0
	LET l_imax = 0
	LET g_cero = 0 #(@#)4-A
	# Traer Indicador Estimado	
	# (@#)7-A INICIO
	LET l_const_0 = 0
	LET l_const_6 = 6
	#SELECT epcimcimes INTO l_imes FROM epcimc WHERE epcimcnano = l_nano AND epcimcnmes = l_nmes AND epcimcmrcb = 0  
	call f0010_declara_cursores_pc488()
	EXECUTE s_tepcimc01 USING l_nano, l_nmes, l_const_0 INTO l_imes
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN
	IF STATUS <> NOTFOUND THEN

		# Calculando Sumas
		#SELECT SUM(pcmpcsald) INTO l_svig FROM pcmpc WHERE pcmpcstat IN (2,3)
		#SELECT SUM(pcmpcsald) INTO l_sven FROM pcmpc WHERE pcmpcstat IN (4,5)
		LET l_text = "SELECT  SUM(case pcmpcstat when 5 then ",
        		"case when pcmpckven > 0 then pcmpcsald - pcmpckven else 0 end ",
                	"when 6 then 0 	else pcmpcsald end), ",
			"SUM(case pcmpcstat when 5 then ",
        		"case when pcmpckven > 0 then pcmpckven else pcmpcsald end ",
                	"when 6 then pcmpcsald	else 0 end ) ",
		"FROM pcmpc WHERE pcmpcstat BETWEEN 2 AND 5 AND pcmpcmrcb = 0"
		PREPARE p_vigven FROM l_text
		EXECUTE p_vigven INTO l_svig,l_sven
		LET l_sqle = SQLCA.SQLCODE
		IF l_sqle < l_const_0 THEN
			DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
			RETURN FALSE
		END IF
		# (@#)7-A INICIO
		#SELECT SUM(pcmpcsald) INTO l_sjud FROM pcmpc WHERE pcmpcstat = 6 
		EXECUTE ss_tpcmpc USING l_const_6 INTO l_sjud
		LET l_sqle = SQLCA.SQLCODE
		IF l_sqle < l_const_0 THEN
			DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
			RETURN FALSE
		END IF
		# (@#)7-A FIN
			#(@#)4-A Inicio
			IF l_sjud IS NULL THEN
				LET l_sjud = g_cero
			END IF
			#(@#)4-A Fin
		# Calculando Indicador de Mora	
		LET l_imor = (l_sven + l_sjud)/(l_svig + l_sven + l_sjud)*100
			
		# Calculando Diferencia de Indicadores
		#LET l_dind =  l_imes - l_imor 
		LET l_dind =  l_imor - l_imes
			
		# Calculando Importe Máximo
		LET l_imax = l_dind * (l_svig + l_sven + l_sjud)/100
	END IF
	
	RETURN l_imax;
	
END FUNCTION

#-------------------------- PROCESO DE CASTIGADO ----------------------------#

FUNCTION f0320_proceso_castigado_pc488(l_fech,l_tcof,l_mimp,l_mcon)
	DEFINE	l_fech	DATE,
		l_tcof	DECIMAL(10,2),
		l_mimp  SMALLINT,
		l_mcon	SMALLINT
		
	# (@#)7-A INICIO
	call f0010_declara_cursores_pc488()
	# (@#)7-A FIN
	LET g_fech = l_fech
	LET g_tcof = l_tcof
	LET g_mimp = l_mimp
	LET g_mcon = l_mcon
	IF NOT f0660_variables_castigado_pc488() THEN
		ERROR "Se produjo un error al establecer variables."
		SLEEP 2
		RETURN FALSE
	END IF
	IF NOT f0330_detalle_castigado_pc488() THEN
		ERROR "No se pudo completar la operacion."
		SLEEP 2
		RETURN FALSE
	END IF
	ERROR "La operacion culmino con exito."
	
	DROP TABLE tmp_atraso
	DROP TABLE filtros
	# (@#)7-A INICIO
	call f0010_libera_cursores_pc488()
	# (@#)7-A FIN
	RETURN TRUE
END FUNCTION

FUNCTION f0660_variables_castigado_pc488()	
	LET g_user = ARG_VAL(1)	
	LET g_hora = TIME
	LET g_fpro = TODAY
	
	RETURN TRUE
END FUNCTION

FUNCTION f0330_detalle_castigado_pc488()
DEFINE	l_cont	INTEGER,
	l_valo	SMALLINT
	# (@#)7-A INICIO
	,l_sqle INTEGER #Codigo de error
	,l_const_1 SMALLINT #Constante 1
	LET l_const_1 = 1
	# (@#)7-A FIN
	LET l_valo = 0
	LET g_flag = FALSE # (@#)5-A
	##--Estableciendo fecha de castigo
	LET p3.fech = f5010_fin_mes_pc488(g_fech)	
	
	display "fechita:",p3.fech
	IF p3.fech <> g_fech THEN
		ERROR "Fecha Actual diferente a fin de mes..."
		SLEEP 3
		RETURN FALSE
	END IF
	
	##--Verificando si hay castigos marcados
	LET l_cont = 0 
	LET g_datr = 0

	# (@#)7-A INICIO
	{SELECT COUNT(*),MAX(efpcadcas) INTO l_cont,g_datr 
	FROM efpca
	WHERE efpcafech = p3.fech
	AND efpcastat = 1}
	EXECUTE scm_efpca USING p3.fech, l_const_1 INTO l_cont,g_datr
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_valo THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN
	IF l_cont IS NULL THEN LET l_cont = 0 END IF
	IF l_cont = 0 THEN
		# (@#)5-A - INICIO
		{
		ERROR "No existen creditos marcados en esta fecha"
		SLEEP 3
		RETURN TRUE
		}
		LET g_flag = TRUE
		# (@#)5-A - FIN
	END IF
	
	##--Cargando Array de creditos a castigar
	IF NOT f0350_carga_prest_pc488() THEN
		ERROR "No se encontraron Prestamos a Castigar"
		SLEEP 3
		RETURN TRUE
	END IF
	##

	CALL set_count(g_max2)

	BEGIN WORK
	
	##--Provisionando creditos 
	IF NOT f0400_generando_provision_pc488(p3.fech) THEN
		ERROR "Error generando provision"
		ROLLBACK WORK
		SLEEP 3
		RETURN FALSE
	END IF
	#--Generando datos para reportes
	IF f9310_generar_datos_reporte_pc488() THEN
		ROLLBACK WORK
		RETURN FALSE
	END IF
	COMMIT WORK
	
	##--Generando ajuste de provision
{
	SELECT efprcplaz plaz
	  FROM tbsfi:efprc
	 WHERE efprcmcie = "S"
	INTO TEMP tmp_ef077 WITH NO LOG
}

	CALL f7001_crea_temporal_ef910()
	
	IF f9270_cuadresaldo_provisiones_ef910(1,999,g_user, l_valo) THEN
		ERROR "Proceso de asiento con error..."
		SLEEP 2
		RETURN TRUE
	END IF
	##
	
	##--Castigando creditos
	# (@#)6-A Inicio
	IF NOT f5000_buscar_cuentas_contables_refinanciados_pc488() THEN
		RETURN FALSE
	END IF
	# (@#)6-A Fin
	BEGIN WORK
	
	FOR g_vari = 1 TO g_max2		
		IF f5100_buscar_registro_pc488() THEN
			IF NOT f1000_cambio_de_estado_pc488(p4[g_vari].prov,p4[g_vari].npre) THEN
				ERROR "Error al cambiar de estado a castigo:",p4[g_vari].npre
				SLEEP 3
				ROLLBACK WORK
				RETURN FALSE
			END IF
		END IF
	END FOR
	
	COMMIT WORK
	MESSAGE " "
	ERROR "Proceso Concluido!"
	SLEEP 3	
	RETURN TRUE
END FUNCTION
# (@#)6-A Inicio
FUNCTION f5000_buscar_cuentas_contables_refinanciados_pc488()
#DESCRIPCION: buscar cuentas contables para creditos refinanciados
DEFINE
	l_sql CHAR(1000) #cadena de consulta a BD
	,l_sqle INTEGER #codigo de error
	,l_const_0 SMALLINT #contante numero 0
	,l_const_1  SMALLINT #constante numero 1
	,l_const_2  SMALLINT #constante numero 2
	,l_const_100 SMALLINT #constante numero 100
	,l_const_1505 SMALLINT #constante numero 1505
	##########################
	#Constantes
	LET l_const_0 = 0
	LET l_const_1  = 1
	LET l_const_2  = 2
	LET l_const_100 = 100
	LET l_const_1505 = 1505
	##########################
	LET p6.cnkr = l_const_0
	LET p6.cnid = l_const_0
	LET l_sql = NULL
	LET l_sql = "SELECT efpartxt1 FROM efpar WHERE efparpfij = ? AND efpartipo = ? AND efparstat = ", l_const_0
	PREPARE p_query_52 FROM l_sql
	EXECUTE p_query_52 USING l_const_1505, l_const_1 INTO p6.cnkr #capital refinanciado
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	IF l_sqle = l_const_100 THEN
		ERROR "NO PUDE OBTENER NUMERO CONTABLE"
		RETURN FALSE
	END IF
	EXECUTE p_query_52 USING l_const_1505, l_const_2 INTO p6.cnid #ingreso diferido
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	IF l_sqle = l_const_100 THEN
		ERROR "NO PUDE OBTENER NUMERO CONTABLE"
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION
# (@#)6-A Fin
# (@#)5-A - INICIO
FUNCTION p3000_elimina_temporales_pc488(l_flag)
#DESCRIPCION : funcion para eliminar tablas temporales
	DEFINE l_flag SMALLINT,  # codigo de tabla interno
	       l_cnu0 SMALLINT,  # constante para el numero 0
         l_cnu1 SMALLINT,  # constante para el numero 1
         l_cnu2 SMALLINT   # constante para el numero 2
# (@#)6-A Inicio
         ,l_const_3 SMALLINT # constante numero 3
         ,l_const_4 SMALLINT # constante numero 4
         ,l_const_5 SMALLINT # constante numero cinco
         ,l_const_6 SMALLINT # constante numero 6
   LET l_const_3 = 3
   LET l_const_4 = 4
   LET l_const_5 = 5
   LET l_const_6 = 6
# (@#)6-A Fin
   LET l_cnu0=0 LET l_cnu1=1 LET l_cnu2=2
  
  IF l_flag = l_cnu0 OR l_flag = l_cnu1 THEN
  	SQL DROP TABLE IF EXISTS tmp_sistema; END SQL
  END IF
	
	IF l_flag = l_cnu0 OR l_flag = l_cnu2 THEN
  	SQL DROP TABLE IF EXISTS tmp_riesgos; END SQL
  END IF
# (@#)6-A Inicio
	IF l_flag = l_cnu0 OR l_flag = l_const_3 THEN
		SQL DROP TABLE IF EXISTS tmp_hipotecarios; END SQL
	END IF
	IF l_flag = l_cnu0 OR l_flag = l_const_4 THEN
		SQL DROP TABLE IF EXISTS tmp_data; END SQL
	END IF
	IF l_flag = l_cnu0 OR l_flag = l_const_5 THEN
		SQL DROP TABLE IF EXISTS tmp_incautados; END SQL
	END IF
	IF l_flag = l_cnu0 OR l_flag = l_const_6 THEN
		SQL DROP TABLE IF EXISTS tmp_eefpca; END SQL
	END IF
# (@#)6-A Fin
END FUNCTION

FUNCTION p7000_crear_temporales_pc488(l_flag)
#DESCRIPCION : funcion para crear tablas temporales
DEFINE l_flag SMALLINT,  # codigo de tabla interno
       l_cnu0 SMALLINT,  # constante para el numero 0
       l_cnu1 SMALLINT,  # constante para el numero 1
       l_cnu2 SMALLINT   # constante para el numero 2
       # (@#)6-A Inicio
       ,l_sqle INTEGER #codigo de error
       ,l_sql CHAR(1000) #cadena de consulta
       ,l_const_13 SMALLINT #constante numero trece
       ,l_const_3 SMALLINT #constante numero tres
       ,l_const_4 SMALLINT #constante numero cuatro
       ,l_const_5 SMALLINT #constante numero cinco
       ,l_const_6 SMALLINT #constante numero seis
       ,l_const_m1 SMALLINT #constante numero -1
       ,l_const_9999 INTEGER #constante numero 9999
       LET l_const_3 = 3
       LET l_const_4 = 4
       LET l_const_13 = 13
       LET l_const_5 = 5
       LET l_const_6 = 6
       LET l_const_m1 = -1
       LET l_const_9999 = 9999
       # (@#)6-A Fin
   LET l_cnu0=0 LET l_cnu1=1 LET l_cnu2=2
   
   CALL p3000_elimina_temporales_pc488(l_flag)
   
IF l_flag = l_cnu0 OR l_flag = l_cnu1 THEN
 CREATE TEMP TABLE tmp_sistema( 
	efpcacmon SMALLINT,       #Codigo de moneda
	efpcanpre INTEGER,        #Numero de prestamo 
	efpcaplaz SMALLINT,       #Plaza del prestamo
	efpcadcas SMALLINT,       #Dias de castigo 
	efpcacapi DECIMAL(10,2),  #Capital
  efpcapdvg DECIMAL(10,2),  #Interes devangado 
  efpcapsus DECIMAL(10,2),  #Interes suspenso
  efpcamora DECIMAL(10,2),  #Mora
  efpcagast DECIMAL(10,2),  #Gasto administrativo
  efpcaprov DECIMAL(10,2),  #Provision
  efpcadatr SMALLINT        #Dias de atraso
  ) WITH NO LOG; 
END IF  

IF l_flag = l_cnu0 OR l_flag = l_cnu2 THEN
 CREATE TEMP TABLE tmp_riesgos(
  eefpcacmon SMALLINT,      #Codigo de moneda
  eefpcanpre INTEGER,       #Numero de prestamo
  eefpcaplaz SMALLINT,      #Plaza del prestamo
  eefpcadcas SMALLINT,      #Dias de castigo
  eefpcacapi DECIMAL(10,2), #Capital
  eefpcapdvg DECIMAL(10,2), #Interes devangado
  eefpcapsus DECIMAL(10,2), #Interes suspenso
  eefpcamora DECIMAL(10,2), #Mora
  eefpcagast DECIMAL(10,2), #Gasto administrativo
  eefpcaprov DECIMAL(10,2), #Provision
  eefpcadatr INTEGER        #Dias de atraso
 )WITH NO LOG;
END IF
# (@#)6-A Inicio
IF l_flag = l_cnu0 OR l_flag = l_const_3 THEN
	LET l_sql = "SELECT pctcrtcre FROM pctcr WHERE pctcrcred = ", l_const_13," INTO TEMP tmp_hipotecarios WITH NO LOG"
	PREPARE p_query_01 FROM l_sql
	EXECUTE p_query_01
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_cnu0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN 
	END IF
END IF
IF l_flag = l_cnu0 OR l_flag = l_const_4 THEN
	LET l_sql =
		"SELECT ",
			"CAST(efpcanpre AS INTEGER) cage, ",
			"CAST(efpcauser AS VARCHAR(100)) nomb, ",
			"efpcanpre npre, ",
			"CAST(efpcadatr AS SMALLINT) tcre, ",
			"efpcacmon cmon, ",
			"efpcacapi sald, ",
			"efpcapdvg pdvg, ",
			"efpcapsus psus, ",
			"efpcagast gast, ",
			"efpcamora mora, ",
			"efpcadatr datr, ",
			"CAST(efpcadatr AS SMALLINT) cvia, ",
			"efpcaprov prov, ",
			"efpcaplaz plaz, ",
			"efpcacmon marc ", 
		"FROM efpca ",
		"WHERE efpcacmon = ",l_const_9999," ",
		" INTO TEMP tmp_data WITH NO LOG"
	PREPARE p_query_97 FROM l_sql
	EXECUTE p_query_97
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_cnu0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN 
	END IF
	CREATE INDEX tmp_data_011 ON tmp_data (cage);
END IF
IF l_flag = l_cnu0 OR l_flag = l_const_5 THEN
	LET l_sql = "SELECT pcmpcnpre npre FROM pcmpc WHERE pcmpcnpre = ", l_const_m1," AND pcmpcmrcb = ", l_const_9999," INTO TEMP tmp_incautados WITH NO LOG"
	PREPARE p_query_98 FROM l_sql
	EXECUTE p_query_98
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_cnu0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN 
	END IF
END IF
IF l_flag = l_cnu0 OR l_flag = l_const_6 THEN
	LET l_sql = "SELECT eefpcacmon, eefpcanpre, eefpcaplaz, eefpcadcas, eefpcacapi, eefpcapdvg, eefpcapsus, eefpcamora, eefpcagast, eefpcaprov, eefpcadatr ",
	" FROM eefpca WHERE eefpcanpre = ", l_const_m1," AND eefpcamrcb = ", l_const_9999," INTO TEMP tmp_eefpca WITH NO LOG "
	PREPARE p_query_99 FROM l_sql
	EXECUTE p_query_99
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_cnu0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN 
	END IF
END IF
# (@#)6-A Fin
END FUNCTION

FUNCTION f0100_proceso_carga_prestamos_castigar_pc488()
DEFINE l_cnu1 SMALLINT       #Constante que almacena el numero 1
       ,l_cnu0 SMALLINT       #Constante que almacena el numero 0
       ,l_sql  CHAR(2000)   #Cadena para la preparacion de sentencias sql
       ,l_sqlc INTEGER        #Control de transaccion
       ,l_hora	CHAR(8)       #Hora del proceso
       ,l_user	CHAR(3)       #Usuario que ejecuta el proceso
	     ,l_dia	DATE            #Dia del proceso
	     ,l_const_6 SMALLINT #coonstante numero 6 # (@#)6-A
	     LET l_const_6 = 6 # (@#)6-A	     
  LET l_cnu0 = 0 LET l_cnu1 = 1
  LET l_dia =  TODAY
	LET l_hora = TIME
	LET l_user = arg_val(1)
	CALL p7000_crear_temporales_pc488 (l_cnu0)
	
	#### INICIO PREPARANDO SENTENCIAS ####
  LET l_sql = "INSERT INTO tmp_sistema(efpcacmon,efpcanpre,efpcaplaz,efpcadcas,efpcacapi,efpcapdvg,efpcapsus,efpcamora,efpcagast,efpcaprov,efpcadatr)",
              #" SELECT efpcacmon,efpcanpre,efpcaplaz,efpcadcas,efpcacapi,efpcapdvg,efpcapsus,efpcamora,efpcagast,efpcaprov,efpcadatr ",# (@#)6-A
              " SELECT efpcacmon,efpcanpre,efpcaplaz,efpcadcas,efpcacapi,efpcapdvg,efpcapsus,efpcamora,efpcagast,efpcaprov,NVL(efpcadatr,0) ",# (@#)6-A
              " FROM efpca WHERE efpcafech =? AND efpcastat =?"
  PREPARE l_query01 FROM l_sql
   
  LET l_sql = "INSERT INTO tmp_riesgos(eefpcacmon,eefpcanpre,eefpcaplaz,eefpcadcas,eefpcacapi,eefpcapdvg,eefpcapsus,eefpcamora,eefpcagast,eefpcaprov,eefpcadatr)",
              " SELECT eefpcacmon,eefpcanpre,eefpcaplaz,eefpcadcas,eefpcacapi,eefpcapdvg,eefpcapsus,eefpcamora,eefpcagast,eefpcaprov,eefpcadatr ",
              #" FROM eefpca WHERE eefpcafech =? AND eefpcanpre NOT IN (SELECT efpcanpre FROM tmp_sistema) AND eefpcastat =? AND eefpcaiden=?" # (@#)6-A
              " FROM eefpca WHERE eefpcafech =? AND eefpcanpre NOT IN (SELECT efpcanpre FROM tmp_sistema) AND eefpcastat =? AND eefpcaiden=? AND eefpcamrcb = ?"# (@#)6-A
  PREPARE l_query02 FROM l_sql
    
  LET l_sql = "INSERT INTO eefpca(eefpcafech,eefpcacmon,eefpcanpre,eefpcaplaz,eefpcastat,eefpcamovd,eefpcadcas,eefpcacapi,eefpcapdvg,eefpcapsus,eefpcamora,",
              "eefpcagast,eefpcaprov,eefpcadatr,eefpcaiden,eefpcauser)",
              " SELECT '",p1.fcas,"',efpcacmon,efpcanpre,efpcaplaz,",l_cnu1,",",l_cnu0,",efpcadcas,efpcacapi,efpcapdvg,efpcapsus,efpcamora,",
              #"efpcagast,efpcaprov,efpcadatr,",l_cnu0,",'",l_user,"' FROM tmp_sistema" # (@#)6-A
              "efpcagast,efpcaprov,NVL(efpcadatr,0),",l_cnu0,",'",l_user,"' FROM tmp_sistema WHERE efpcanpre NOT IN (SELECT eefpcanpre FROM tmp_eefpca) " # (@#)6-A
  PREPARE l_query03 FROM l_sql

  LET l_sql = "INSERT INTO efpca(efpcafech,efpcacmon,efpcanpre,efpcaplaz,efpcastat,efpcamovd,efpcadcas,efpcacapi,efpcapdvg,efpcapsus,efpcamora,efpcagast,efpcaprov,",
              "efpcadatr,efpcauser,efpcafpro,efpcahora)",
              " SELECT '",p1.fcas,"',eefpcacmon,eefpcanpre,eefpcaplaz,",l_cnu1,",",l_cnu0,",eefpcadcas,eefpcacapi,eefpcapdvg,",
              "eefpcapsus,eefpcamora,eefpcagast,eefpcaprov,eefpcadatr,'",l_user,"','",l_dia,"','",l_hora,"' FROM tmp_riesgos"
  PREPARE l_query04 FROM l_sql  
  # (@#)6-A Inicio
	LET l_sql = "INSERT INTO tmp_eefpca(eefpcacmon,eefpcanpre,eefpcaplaz,eefpcadcas,eefpcacapi,eefpcapdvg,eefpcapsus,eefpcamora,eefpcagast,eefpcaprov,eefpcadatr)",
	#" SELECT eefpcacmon,eefpcanpre,eefpcaplaz,eefpcadcas,eefpcacapi,eefpcapdvg,eefpcapsus,eefpcamora,eefpcagast,eefpcaprov,eefpcadatr ", #(@#)6-A
	" SELECT eefpcacmon,eefpcanpre,eefpcaplaz,eefpcadcas,eefpcacapi,eefpcapdvg,eefpcapsus,eefpcamora,eefpcagast,eefpcaprov,NVL(eefpcadatr,0) ", #(@#)6-A
	" FROM eefpca WHERE eefpcafech =? AND eefpcastat =? AND eefpcaiden=? AND eefpcamrcb = ?"
	PREPARE l_query07 FROM l_sql
  # (@#)6-A Fin
  #### FIN PREPARANDO SENTENCIAS ####
  	
  EXECUTE l_query01 USING p1.fcas,l_cnu1
	LET l_sqlc = SQLCA.SQLCODE
 	IF l_sqlc < l_cnu0 THEN DISPLAY "ERROR DE BASE DE DATOS: ",l_sqlc END IF  		
 
  #EXECUTE l_query02 USING p1.fcas,l_cnu1,l_cnu1 # (@#)6-A
  EXECUTE l_query02 USING p1.fcas,l_cnu1,l_cnu1, l_cnu0 # (@#)6-A
	LET l_sqlc = SQLCA.SQLCODE
 	IF l_sqlc < l_cnu0 THEN DISPLAY "ERROR DE BASE DE DATOS: ",l_sqlc END IF 	
 	
 	EXECUTE l_query04
	LET l_sqlc = SQLCA.SQLCODE
 	IF l_sqlc < l_cnu0 THEN DISPLAY "ERROR DE BASE DE DATOS: ",l_sqlc END IF 	
	# (@#)6-A Inicio
	EXECUTE l_query07 USING p1.fcas,l_cnu1,l_cnu1, l_cnu0 
	LET l_sqlc = SQLCA.SQLCODE
	IF l_sqlc < l_cnu0 THEN DISPLAY "ERROR DE BASE DE DATOS: ",l_sqlc END IF 	
	# (@#)6-A Fin 		 	
	EXECUTE l_query03
	LET l_sqlc = SQLCA.SQLCODE
 	IF l_sqlc < l_cnu0 THEN DISPLAY "ERROR DE BASE DE DATOS: ",l_sqlc END IF 	
 	#CALL p3000_elimina_temporales_pc488(l_cnu0) # (@#)5-B
 	 CALL p3000_elimina_temporales_pc488(l_cnu1) # (@#)5-B
 	 CALL p3000_elimina_temporales_pc488(l_const_6) # (@#)6-A
END FUNCTION
# (@#)5-A - FIN
FUNCTION f0350_carga_prest_pc488()
	DEFINE	l_cage	INTEGER,
	# (@#)7-A Inicio
	l_const_32767 INTEGER #constante del numero 32767
	,l_const_1 INTEGER #constante del numero 1
	,l_const_7 INTEGER #constante del numero 7
	LET l_const_32767 = 32767
	LET l_const_1 = 1
	LET l_const_7 = 7
	# (@#)7-A Fin
	MESSAGE "Espere un momento ... "

	##--Volviendo a determinar que clientes se puede castigar
	CALL f0400_crea_tablas_ef202l()
# (@#)6-A - INICIO	
{
IF NOT g_flag THEN # (@#)5-A
	CALL f0500_genera_ef202l(p3.fech,g_datr,1,999)
	CALL f0600_confirmando_marcas_pc488()	
END IF             # (@#)5-A
}
# (@#)6-A - FIN
  CALL f0100_proceso_carga_prestamos_castigar_pc488() # (@#)5-A
	##--Cursor para llenar detalle
	# (@#)7-A INICIO
	{DECLARE q_tmp CURSOR FOR 
		SELECT efpcanpre, gbagenomb, pcmpcsald, pcmpccage, pcmpcplaz
		  FROM efpca, pcmpc, gbage
		 WHERE efpcanpre = pcmpcnpre
		   AND efpcafech = p3.fech
		   AND efpcastat = 1
		   AND pcmpcstat < 7
		   AND pcmpccage = gbagecage}
	OPEN q_tmp USING p3.fech, l_const_1, l_const_7
	# (@#)7-A FIN
	LET p3.tsald = 0
	LET p3.tprov = 0
	LET g_vari = 1
	
		# (@#)7-A INICIO
	#FOREACH q_tmp INTO p4[g_vari].npre,p4[g_vari].nomb,p4[g_vari].sald,l_cage,p4[g_vari].plaz
	FETCH q_tmp INTO p4[g_vari].npre,p4[g_vari].nomb,p4[g_vari].sald,l_cage,p4[g_vari].plaz
	WHILE STATUS <> NOTFOUND
	# (@#)7-A FIN
		LET p4[g_vari].prov = f7200_provision_pc488(l_cage,p4[g_vari].npre,p4[g_vari].plaz)
		LET p3.tsald = p3.tsald + p4[g_vari].sald
		LET p3.tprov = p3.tprov + p4[g_vari].prov
		##
		LET g_vari = g_vari + 1
	# (@#)7-A INICIO
		IF g_vari > l_const_32767 THEN
			ERROR "Los registros exceden el límite máximo del arreglo (",l_const_32767,")"
			SLEEP 2
			EXIT WHILE
		END IF
	FETCH q_tmp INTO p4[g_vari].npre,p4[g_vari].nomb,p4[g_vari].sald,l_cage,p4[g_vari].plaz
	END WHILE 
	CLOSE q_tmp
	#END FOREACH
	# (@#)7-A FIN
	MESSAGE " "
	
	LET g_max2 = g_vari - 1	
	IF g_max2 = 0 THEN
		RETURN FALSE
	END IF
	
	RETURN TRUE
END FUNCTION 

FUNCTION f0600_confirmando_marcas_pc488()
	DEFINE	l_npre	INTEGER,
		l_marc	SMALLINT
	# (@#)7-A INICIO
	,c_marc	SMALLINT # Maximo prestamos marcados
	,l_const_0 SMALLINT #Constante valor 0
	,l_sqle INTEGER #Codigo de error
	,l_const_1 SMALLINT #Constante valor 1
	{DECLARE q_reco CURSOR FOR 
		SELECT efpcanpre FROM efpca
		 WHERE efpcafech = p3.fech
		   AND efpcastat = 1}
	LET l_const_0 = 0
	LET l_const_1 = 1
	OPEN q_reco USING p3.fech, l_const_1
	# (@#)7-A FIN
	
	MESSAGE "Validando prestamos marcados..."
	
	CREATE TEMP TABLE tmp_marcas
	(
		npre	INTEGER,
		marc	SMALLINT
	)WITH NO LOG
	
	##--Recorriendo el cursor de creeditos marcados para castigo
	# (@#)7-A INICIO
	#FOREACH q_reco INTO l_npre
	FETCH q_reco INTO l_npre
	WHILE STATUS <> NOTFOUND
		##--Buncando credito marcado en filtros actualizado
		{SELECT MAX(marc) INTO l_marc 
		  FROM filtros
		 WHERE npre = l_npre}
			LET l_text = " SELECT MAX(marc)",
			" FROM filtros",
			" WHERE npre = ? "
		PREPARE s_tfilt FROM l_text
		EXECUTE s_tfilt USING l_npre INTO l_marc
		LET l_sqle = SQLCA.SQLCODE
		IF l_sqle < l_const_0 THEN
			DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
			RETURN FALSE
		END IF
		FREE s_tfilt
		# (@#)7-A FIN

		IF STATUS = NOTFOUND THEN
			LET l_marc = 9
		END IF
	    
		##--Marcas mayor a 0 menos las no provisionadas
		IF l_marc > 0 AND l_marc <> 5 THEN
			# (@#)7-A INICIO
			#INSERT INTO tmp_marcas VALUES(l_npre,l_marc)
			LET l_text = "INSERT INTO tmp_marcas VALUES(?,?)"
			PREPARE i_tmpmarc FROM l_text 
			EXECUTE i_tmpmarc USING l_npre,l_marc
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_const_0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			FREE i_tmpmarc
			# (@#)7-A FIN
		END IF 
	# (@#)7-A INICIO
		FETCH q_reco INTO l_npre
	END WHILE
	CLOSE q_reco
	#END FOREACH
	LET l_text = " SELECT MAX(marc)",
	             " FROM tmp_marcas",
					 " WHERE npre=efpcanpre"
	PREPARE sm_tmpmarcas FROM l_text
	EXECUTE sm_tmpmarcas INTO c_marc
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	FREE sm_tmpmarcas
	##--Desmarcando creditos con marca actualizada mayor a cero
	{UPDATE efpca 
	   SET efpcastat = 0,
	       efpcamovd = c_marc
	 WHERE efpcastat = 1
	   AND efpcanpre IN (SELECT npre FROM tmp_marcas WHERE marc > 0)
	DROP TABLE tmp_marcas} 
	LET l_text = " UPDATE efpca",
			" SET efpcastat = 0,",
			" efpcamovd = ?",
			" WHERE efpcastat = 1",
			" AND efpcanpre IN (SELECT npre FROM tmp_marcas WHERE marc > 0)"
	PREPARE u_tefpca FROM l_text
	EXECUTE u_tefpca USING c_marc
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	FREE u_tefpca
	
	LET l_text = " DROP TABLE tmp_marcas"
	PREPARE d_tmpmarcas FROM l_text
	EXECUTE d_tmpmarcas
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	FREE d_tmpmarcas
	# (@#)7-A  FIN
	
		
END FUNCTION

FUNCTION f1000_cambio_de_estado_pc488(l_prov,l_npre)
	DEFINE	l_prov	DECIMAL(14,2),
		l_npre	INTEGER
		# (@#)7-A INICIO
		,l_const_0 SMALLINT #Constante valor 0
		,l_sqle INTEGER #Codigo de error
		,l_const_2 SMALLINT #Constante valor 2
	LET l_const_0 = 0
	LET l_const_2 = 2
	# (@#)7-A FIN
	LOCK TABLE pcmpc IN EXCLUSIVE MODE 
	LOCK TABLE pctcn IN EXCLUSIVE MODE 
	
	IF  NOT f5230_buscar_tipo_prestamo_pc488()  THEN
		ERROR "NO EXISTEN DATOS DE PARAMETROS"
		RETURN FALSE
	END IF
	
	IF f1100_insert_pcces_pc488() THEN		
		ERROR "NO PUDE EJECUTAR LA OPERACION (pcces)"
		RETURN FALSE
	END IF
	
	IF f2000_cambio_estado_pc488(l_prov) THEN		
		ERROR "NO PUDE EJECUTAR LA OPERACION (castigo)"
		RETURN FALSE
	END IF
	
	#--Actualizando la marca de castigo 
	# (@#)7-A INICIO
	{UPDATE efpca 
	   SET efpcastat = 2
	 WHERE efpcanpre = l_npre
	   AND efpcafech = p3.fech	}
	EXECUTE u_tefpca02 USING l_const_2, l_npre, p3.fech
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN
	RETURN TRUE
END FUNCTION

FUNCTION f1100_insert_pcces_pc488() 
# (@#)7-A INICIO
DEFINE 
	l_const_0 SMALLINT #Constante valor 0
	,l_sqle INTEGER #Codigo de error
	,l_const_M CHAR(10) #Constante valor 'M'
	,l_const_7 SMALLINT #Constante valor 7
	{INSERT INTO pcces 
		VALUES (t5.pcmpcnpre,0           ,g_fech,
			"M"         ,t5.pcmpcstat,t5.pcmpcfsta,
			7           ,g_user      ,g_hora      ,
			g_fpro)}
	LET l_const_0 = 0
	LET l_const_M = 'M'
	LET l_const_7 = 7
	EXECUTE i_tpcces USING t5.pcmpcnpre, l_const_0, g_fech, l_const_M, t5.pcmpcstat, t5.pcmpcfsta, g_user, l_const_7, g_hora, g_fpro
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN
	IF STATUS < 0 THEN
		RETURN TRUE
	END IF
	
	RETURN FALSE
END FUNCTION

FUNCTION f2000_cambio_estado_pc488(l_prov)
	DEFINE	l_prov	DECIMAL(14,2),
		l_desc	CHAR(20),
		l_impi  LIKE pctcn.pctcnimpi,  # Importe de Imputacion
		l_impc  LIKE pctcn.pctcnimpc,  # Importe de Conversion
		l_glosa LIKE pctcn.pctcndesc,
	# (@#)7-A INICIO
	#l_pagare 	RECORD LIKE efpag.*
	l_pagare RECORD
		efpagesta LIKE efpag.efpagesta,
		efpagfech LIKE efpag.efpagfech,
		efpaghora LIKE efpag.efpaghora,
		efpagarch LIKE efpag.efpagarch,
		efpagplaz LIKE efpag.efpagplaz,
		efpagmoti LIKE efpag.efpagmoti,
		efpagcorr LIKE efpag.efpagcorr
		END RECORD
		,l_const_7 SMALLINT #Constante valor 7
		,l_const_9 SMALLINT #Constante valor 9
	# (@#)7-A FIN
# (@#)6-A Inicio
		,l_const_143 SMALLINT #constante numero 143
		,l_const_0 SMALLINT #contante numero 0
		,l_const_1  SMALLINT #constante numero 1
		,l_const_20  SMALLINT #constante numero 20
		,l_const_menos1 SMALLINT #constante -1
		,l_capi DECIMAL(14,2) #capital neto del saldo refinanciado
		,l_indi DECIMAL(14,2) #ingreso diferido del saldo refinanciado
		,l_sql CHAR(500) #cadena de consulta a BD
		,l_sqle INTEGER #codigo de error SQL
		,l_const_f CHAR(1) #constante letra F
		##########################
		#Constantes
		LET l_const_143 = 143
		LET l_const_0 = 0
		LET l_const_1  = 1
		LET l_const_20 = 20
		LET l_const_menos1 = -1
		LET l_const_f = 'F'
		##########################
		LET l_capi = l_const_0
		LET l_indi = l_const_0
		LET l_sql = "EXECUTE FUNCTION ", f0020_buscar_bd_gb000(l_const_0,l_const_f) CLIPPED,":pa_sfi_pc_asiento_credito_refinanciado(?) "
		PREPARE p_query_53 FROM l_sql
# (@#)6-A Fin
	#--------- Pasar saldo Prestamo----#
	IF NOT f5200_nro_contable_pc488() THEN
		ERROR "NO PUDE RECUPERAR NUMERO CONTABLE"
		RETURN TRUE
	END IF
	#---------Actualizacion de maestro de prestamo -----------#
	# (@#)7-A INICIO
	{UPDATE pcmpc SET	pcmpcstat = 7, 
				pcmpcstan = t5.pcmpcstat,
				pcmpcfsta = g_fech,
				pcmpcpsus = 0,
				pcmpcpdvg = 0
	 WHERE pcmpcnpre = t5.pcmpcnpre}
	 LET l_const_7 = 7
	 LET l_const_9 = 9
	 EXECUTE u_tpcmpc01 USING l_const_7, t5.pcmpcstat, g_fech, l_const_0, l_const_0, t5.pcmpcnpre
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN
	IF STATUS < 0 THEN
		RETURN TRUE
	END IF
	# (@#)7-A INICIO
	{SELECT * INTO l_pagare.* 
	  FROM efpag
	 WHERE efpagnpre = t5.pcmpcnpre }
	EXECUTE s_tefpag USING t5.pcmpcnpre INTO l_pagare.efpagesta,l_pagare.efpagfech,l_pagare.efpaghora,l_pagare.efpagarch,l_pagare.efpagplaz,l_pagare.efpagmoti,l_pagare.efpagcorr
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	{UPDATE efpag SET efpagesta = 7 
	 WHERE efpagnpre = t5.pcmpcnpre}
	EXECUTE u_tefpag01 USING l_const_7, t5.pcmpcnpre
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN
	IF STATUS <>  0 THEN
		RETURN TRUE
	END IF
	
	# (@#)7-A INICIO
	{UPDATE efphi 
	   SET efphimrcb = 9
	 WHERE efphinpre = t5.pcmpcnpre
	   AND efphimrcb = 0}
	EXECUTE u_tefphi USING l_const_9, t5.pcmpcnpre, l_const_0
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN
	IF STATUS <>  0 THEN
		RETURN TRUE
	END IF
	
	# (@#)7-A INICIO
	{INSERT INTO efphi(efphintra,efphinpre,efphiesta,efphifech, 
			efphihora,efphiarch,efphiplaz,efphimoti,
			efphifpro,efphihpro,efphiuser,efphimrcb,efphicorr)
	VALUES(0,t5.pcmpcnpre,l_pagare.efpagesta,l_pagare.efpagfech,l_pagare.efpaghora,l_pagare.efpagarch,
		l_pagare.efpagplaz,l_pagare.efpagmoti,TODAY,g_hora,g_user,0,l_pagare.efpagcorr)}
	EXECUTE i_tefphi USING l_const_0, t5.pcmpcnpre, l_pagare.efpagesta, l_pagare.efpagfech, l_pagare.efpaghora,
				l_pagare.efpagarch, l_pagare.efpagplaz, l_pagare.efpagmoti, g_hora, g_user, l_const_0, l_pagare.efpagcorr
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN
	IF STATUS <> 0 THEN
		ERROR "No pude actualizar historico de cambio de estado de pagare"
		SLEEP 3
		RETURN TRUE
	END IF

	LET g_item = 0
	#----------- Capital castigo al DEBE -------------#
	# (@#)6-A Inicio
	IF t5.pcmpctcre = l_const_143 THEN
		LET g_ctbl = p6.cnid #cuenta contable de ingreso diferido
		LET g_adic = NULL
	ELSE
	# (@#)6-A Fin
	LET g_ctbl = t3.pctpmckca
	LET g_adic = t3.pctpmakca
	END IF # (@#)6-A
	IF g_ctbl[3,3] MATCHES "[mM]" THEN
		LET g_ctbl[3,3] = t5.pcmpccmon USING "#"
	END IF
	# (@#)6-A Inicio
	IF t5.pcmpctcre = l_const_143 THEN
		EXECUTE p_query_53 USING t5.pcmpcnpre INTO l_capi, l_indi, l_sqle
		IF l_sqle < l_const_0 THEN DISPLAY "ERROR DE BASE DE DATOS: ",l_sqle RETURN TRUE END IF
			
		#Cuenta para ingresos diferidos
		CALL f7000_impts_para_contab_pc488(l_indi, t5.pcmpccmon) RETURNING l_impi,l_impc
		LET l_glosa= "INGRESOS DIFERIDOS ",t5.pcmpcnpre USING "<<<<<<<<<<<<<<<<"
		LET g_item = g_item + l_const_1
		IF f7100_ins_asiento_pc488(l_const_20, l_const_1, l_glosa, l_impi, l_impc) THEN RETURN TRUE END IF
		
		#Cuenta para Provision Balance
		LET g_ctbl = t3.pctpmckca #cuenta contable de ingreso diferido
		LET g_adic = t3.pctpmakca
		CALL f7000_impts_para_contab_pc488(l_capi, t5.pcmpccmon) RETURNING l_impi,l_impc
		LET l_glosa= "PROVISION BALANCE ",t5.pcmpcnpre USING "<<<<<<<<<<<<<<<<"
		LET g_item = g_item + l_const_1
		IF f7100_ins_asiento_pc488(l_const_20, l_const_1, l_glosa, l_impi, l_impc) THEN RETURN TRUE END IF
	ELSE
	# (@#)6-A Fin	
	CALL f7000_impts_para_contab_pc488(l_prov, t5.pcmpccmon)
	RETURNING l_impi,l_impc
	
	LET l_glosa= "CAPITAL CASTIGO PRESTAMO ",t5.pcmpcnpre 
			USING "<<<<<<<<<<<<<<<<"
	LET g_item = g_item + 1
	
	IF f7100_ins_asiento_pc488(20,1,l_glosa,l_impi,l_impc) THEN
		RETURN TRUE
	END IF
	END IF # (@#)6-A
	#------------  Capital al HABER ------------#
# (@#)6-A Inicio
IF t5.pcmpctcre = l_const_143 THEN
	#Cuenta para Capital Refinanciado
	LET g_ctbl = p6.cnkr #cuenta contable de capital refinanciado
	LET g_adic = NULL
	CALL f7000_impts_para_contab_pc488(t5.pcmpcsald, t5.pcmpccmon) RETURNING l_impi,l_impc
	LET l_glosa= "CAPITAL REFINANCIADO ",t5.pcmpcnpre USING "<<<<<<<<<<<<<<<<"
	LET g_item = g_item + l_const_1
	IF f7100_ins_asiento_pc488(l_const_20, l_const_1, l_glosa, l_impi*(l_const_menos1), l_impc*(l_const_menos1)) THEN RETURN TRUE END IF
ELSE
# (@#)6-A Fin
	CASE t5.pcmpcstat
		WHEN 2  #----------cuentas de vigente corto plazo ----#
			LET g_ctbl = t3.pctpmckvc
			LET g_adic = t3.pctpmakvc
		WHEN 3  #----------cuentas de vvigene largo plazo ----#
			LET g_ctbl = t3.pctpmckvl
			LET g_adic = t3.pctpmakvl
		WHEN 4  #----------cuentas de vencido1 ----#
			LET g_ctbl = t3.pctpmckm1
			LET g_adic = t3.pctpmakm1
		WHEN 5  #----------cuentas de vencido2 ----#
			LET g_ctbl = t3.pctpmckm2
			LET g_adic = t3.pctpmakm2
		WHEN 6  #----------cuentas de ejecucion ----#
			LET g_ctbl = t3.pctpmckej
			LET g_adic = t3.pctpmakej
	END CASE
	
	IF g_ctbl[3,3] MATCHES "[mM]" THEN
		LET g_ctbl[3,3] = t5.pcmpccmon USING "#"
	END IF
	
	LET g_item = g_item + 1
	LET l_desc= f5120_buscar_estado_pc488(t5.pcmpcstat)
	LET l_glosa= "CAPITAL ",l_desc[1,10] CLIPPED," PREST ", t5.pcmpcnpre USING "<<<<<<<<<"
	
	CALL f7000_impts_para_contab_pc488(t5.pcmpcsald, t5.pcmpccmon)
	RETURNING l_impi,l_impc
	
	IF f7100_ins_asiento_pc488(20,1,l_glosa,l_impi*(-1),l_impc*(-1)) THEN
		RETURN TRUE
	END IF
END IF# (@#)6-A
	#----------------- Diferencia Provision y Capital ---------------------#
IF NOT t5.pcmpctcre = l_const_143 THEN # (@#)6-A
	IF t5.pcmpcsald > l_prov THEN
		LET g_ctbl = t3.pctpmckca   ##(@#)3-A
		LET g_ctbl[1,4] = "4312"
		LET l_prov = t5.pcmpcsald - l_prov
		
		CALL f7000_impts_para_contab_pc488(l_prov,t5.pcmpccmon)
		RETURNING l_impi,l_impc
		
		LET l_glosa= "AJUSTE PROVISION"
		LET g_item = g_item + 1
		
		IF f7100_ins_asiento_pc488(20,1,l_glosa,l_impi,l_impc) THEN
			RETURN TRUE
		END IF
	END IF
END IF# (@#)6-A
	#------------------ Extorno de Interses en Suspenso -------------------#
	CASE t5.pcmpcstat
		WHEN 2   LET g_ctbl = t3.pctpmsavg
		WHEN 3   LET g_ctbl = t3.pctpmsavg
		WHEN 5   LET g_ctbl = t3.pctpmsav2
		WHEN 6   LET g_ctbl = t3.pctpmsaej
	END CASE
	
	LET g_adic = NULL
	
	IF g_ctbl[3,3] MATCHES "[mM]" THEN
		LET g_ctbl[3,3] = t5.pcmpccmon USING "#"
	END IF
	
	LET g_item = g_item + 1
	LET l_glosa= "ACREEDORA INTERESES EN SUSPENSO"
	
	CALL f7000_impts_para_contab_pc488(t5.pcmpcpsus,t5.pcmpccmon)
	RETURNING l_impi,l_impc
		
	IF f7100_ins_asiento_pc488(20,1,l_glosa,l_impi,l_impc) THEN
			RETURN TRUE
	END IF
	
	CASE t5.pcmpcstat
		WHEN 2   LET g_ctbl = t3.pctpmsdvg
		WHEN 3   LET g_ctbl = t3.pctpmsdvg
		WHEN 5   LET g_ctbl = t3.pctpmsdv2
		WHEN 6   LET g_ctbl = t3.pctpmsdej
	END CASE
	
	LET g_adic = NULL
	
	IF g_ctbl[3,3] MATCHES "[mM]" THEN
		LET g_ctbl[3,3] = t5.pcmpccmon USING "#"
	END IF
	
	LET g_item = g_item + 1
	LET l_glosa= "DEUDORA INTERESES EN SUSPENSO"
	
	IF f7100_ins_asiento_pc488(20,1,l_glosa,l_impi*(-1),l_impc*(-1)) THEN
		RETURN TRUE
	END IF
	
	#------------------------- Cuentas de Orden ---------------------------#
# (@#)6-A - INICIO
IF t5.pcmpctcre = l_const_143 THEN 	
	CALL f7000_impts_para_contab_pc488(l_capi, t5.pcmpccmon) RETURNING l_impi,l_impc
ELSE	 
# (@#)6-A - FIN
	CALL f7000_impts_para_contab_pc488(t5.pcmpcsald, t5.pcmpccmon)
	RETURNING l_impi,l_impc
END IF # (@#)6-A
	##
	
	LET g_ctbl = t3.pctpmckad
	LET g_adic = NULL
	
	IF g_ctbl[3,3] MATCHES "[mM]" THEN
		LET g_ctbl[3,3] = t5.pcmpccmon USING "#"
	END IF
	
	LET g_item = g_item + 1
	LET l_glosa= "DEUDORA CAPITAL CASTIGO ", t5.pcmpcnpre USING "<<<<<<<<<<<<<<<<"

	IF f7100_ins_asiento_pc488(20,1,l_glosa,l_impi,l_impc) THEN
		RETURN TRUE
	END IF
	
	LET g_ctbl = t3.pctpmckaa
	LET g_adic = NULL
	
	IF g_ctbl[3,3] MATCHES "[mM]" THEN
		LET g_ctbl[3,3] = t5.pcmpccmon USING "#"
	END IF
	
	LET g_item = g_item + 1
	LET l_glosa= "ACREEDORA CAPITAL CASTIGO ", t5.pcmpcnpre USING "<<<<<<<<<<<<<<<<"
	
	IF f7100_ins_asiento_pc488(20,1,l_glosa,l_impi*(-1),l_impc*(-1)) THEN
		RETURN TRUE
	END IF
	#------------------ Registro de Intereses Castigados  -----------------#
	LET g_ctbl = t3.pctpmcpcg
	LET g_adic = t3.pctpmapcg
	
	IF g_ctbl[3,3] MATCHES "[mM]" THEN
		LET g_ctbl[3,3] = t5.pcmpccmon USING "#"
	END IF
	
	LET g_item = g_item + 1
	LET l_glosa= "DEUDORA INTERESES CASTIGO"
	
	CALL f7000_impts_para_contab_pc488(t5.pcmpcpsus,t5.pcmpccmon)
		RETURNING l_impi,l_impc
		
	IF f7100_ins_asiento_pc488(20,1,l_glosa,l_impi,l_impc) THEN
			RETURN TRUE
	END IF
	
	LET g_ctbl[2,2] = "2"
	
	IF g_ctbl[3,3] MATCHES "[mM]" THEN
		LET g_ctbl[3,3] = t5.pcmpccmon USING "#"
	END IF
	
	LET g_item = g_item + 1
	LET l_glosa= "ACREEDORA INTERESES CASTIGO"

	IF f7100_ins_asiento_pc488(20,1,l_glosa,l_impi*(-1),l_impc*(-1)) THEN
		RETURN TRUE
	END IF
	
	RETURN FALSE
END FUNCTION

FUNCTION f5100_buscar_registro_pc488()
# (@#)7-A INICIO
DEFINE
	l_const_0 SMALLINT #Constante valor 0
	,l_sqle INTEGER #Codigo de error
	 {SELECT pcmpcnpre, pcmpccage,pcmpccmon, 
		pcmpcstat,pcmpcfsta,pcmpcmpre,
		pcmpcfdes,pcmpcsald,pcmpctcre,
		pcmpcfvac,pcmpcfpvc,pcmpckven,
		pcmpcpsus,pcmpcplaz,pcmpcagen INTO t5.*
	   FROM pcmpc
	  WHERE pcmpcnpre = p4[g_vari].npre       	
	    AND pcmpcstat BETWEEN 2 AND 7}
	LET l_const_0 = 0
	EXECUTE s_tpcmpc03 USING p4[g_vari].npre INTO t5.pcmpcnpre, t5.pcmpccage, t5.pcmpccmon, t5.pcmpcstat, t5.pcmpcfsta,
				t5.pcmpcmpre, t5.pcmpcfdes, t5.pcmpcsald, t5.pcmpctcre, t5.pcmpcfvac,
				t5.pcmpcfpvc, t5.pcmpckven, t5.pcmpcpsus, t5.pcmpcplaz, t5.pcmpcagen
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN 
	IF STATUS = NOTFOUND THEN
		RETURN FALSE
	END IF
	
	RETURN TRUE
END FUNCTION

FUNCTION f5120_buscar_estado_pc488(l_stat)
	DEFINE  l_stat LIKE pcces.pcceseact,
		l_desc LIKE pccon.pccondesc
		# (@#)7-A INICIO
		,l_const_0 SMALLINT #Constante valor 0
		,l_const_4 SMALLINT #Constante valor 4
		,l_sqle INTEGER #Codigo de error
		# (@#)7-A FIN
	INITIALIZE l_desc TO NULL
	
	# (@#)7-A INICIO
	{SELECT pccondesc INTO l_desc 
	  FROM pccon
	 WHERE pcconpref = 4
	   AND pcconcorr = l_stat}
	LET l_const_0 = 0
	LET l_const_4 = 4
	EXECUTE s_tpccondesc USING l_const_4, l_stat INTO l_desc
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN
	
	IF STATUS = NOTFOUND THEN
		LET l_desc = "*No Existe*"
	END IF
	
	RETURN l_desc
END FUNCTION

FUNCTION f5200_nro_contable_pc488()
	DEFINE	l_text	CHAR(250),
		l_host 	CHAR(50)		
		# (@#)7-A INICIO
		,l_const_0 SMALLINT #Constante valor 0
		,l_sqle INTEGER #Codigo de error
		# (@#)7-A FIN
		
	LET l_host = f0020_buscar_bd_gb000(t5.pcmpcplaz,"F")
	LET l_text = "SELECT pcctlndoc FROM ",l_host CLIPPED,":pcctl"

	PREPARE p_sndoc FROM l_text
	# (@#)7-A INICIO
	#EXECUTE p_sndoc INTO t4.* 
	LET l_const_0 = 0
	EXECUTE p_sndoc INTO t4.pcctlndoc
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN
	IF STATUS < 0 THEN
		RETURN FALSE
	END IF
	
	IF t4.pcctlndoc IS NULL THEN
		LET t4.pcctlndoc = 0
	END IF
	
	LET t4.pcctlndoc = t4.pcctlndoc + 1
	LET l_text = "UPDATE ",l_host CLIPPED,":pcctl SET pcctlndoc = ? "

	PREPARE p_undoc FROM l_text
	EXECUTE p_undoc USING t4.pcctlndoc
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	IF STATUS < 0 THEN
		RETURN FALSE
	END IF
	
	RETURN TRUE
END FUNCTION

FUNCTION f5230_buscar_tipo_prestamo_pc488()
	# (@#)7-A INICIO
DEFINE
	l_const_0 SMALLINT #Constante valor 0
	,l_sqle INTEGER #Codigo de error
	# (@#)7-A FIN
	INITIALIZE t3.* TO NULL
	
	# (@#)7-A INICIO
	{SELECT  pctcrdesc,pctcrvctc,pctcrdsal, 
		pctpmckvc,pctpmakvc,pctpmckvl,
		pctpmakvl,pctpmckm1,pctpmakm1,
		pctpmckm2,pctpmakm2,pctpmckej,
		pctpmakej,pctpmckca,pctpmakca,
		pctpmckad,pctpmckaa,pctpmsavg,
		pctpmsav2,pctpmsaej,pctpmsdvg,
		pctpmsdv2,pctpmsdej,pctpmcpcg,
		pctpmapcg
		INTO t3.*
	FROM    pctcr,pctpm
	WHERE   pctcrtcre = t5.pcmpctcre
	AND     pctpmtcre = t5.pcmpctcre
	AND     pctpmcmon = t5.pcmpccmon}
	LET l_const_0 = 0
	EXECUTE s_tpct_cr_pm USING t5.pcmpctcre, t5.pcmpctcre, t5.pcmpccmon INTO t3.pctcrdesc, t3.pctcrvctc, t3.pctcrdsal, t3.pctpmckvc, t3.pctpmakvc, t3.pctpmckvl,
		t3.pctpmakvl, t3.pctpmckm1, t3.pctpmakm1, t3.pctpmckm2, t3.pctpmakm2, t3.pctpmckej,
		t3.pctpmakej, t3.pctpmckca, t3.pctpmakca, t3.pctpmckad, t3.pctpmckaa, t3.pctpmsavg,
		t3.pctpmsav2, t3.pctpmsaej, t3.pctpmsdvg, t3.pctpmsdv2, t3.pctpmsdej, t3.pctpmcpcg,
		t3.pctpmapcg
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	# (@#)7-A FIN
	IF STATUS = NOTFOUND THEN
		LET t3.pctcrdesc = "**NO EXISTE**"
		RETURN FALSE
	END IF
	
	RETURN TRUE
END FUNCTION

FUNCTION f7000_impts_para_contab_pc488(l_impt,l_cmon)
DEFINE  l_impt	LIKE pchtr.pchtrimpt,
	l_cmon	LIKE pchtr.pchtrcmon,
	l_impi	LIKE pctcn.pctcnimpi,
	l_impc	LIKE pctcn.pctcnimpc
	
	LET l_impi = l_impt
	LET l_impc = l_impt
	
	IF l_cmon = 1 AND g_mimp = 2 THEN
		LET l_impi = f0100_redondeo_gb000((l_impi/g_tcof),2)
	END IF
	
	IF l_cmon = 2 AND g_mimp = 1 THEN
		LET l_impi = f0100_redondeo_gb000((l_impi*g_tcof),2)
	END IF
	
	IF l_cmon = 3 AND g_mimp = 1 THEN
		LET l_impi = f0100_redondeo_gb000((l_impi*g_tcof),2)
	END IF
	
	IF l_cmon = 1 AND g_mcon = 2 THEN
		LET l_impc = f0100_redondeo_gb000((l_impc/g_tcof),2)
	END IF
	
	IF l_cmon = 2 AND g_mcon = 1 THEN
		LET l_impc = f0100_redondeo_gb000((l_impc*g_tcof),2)
	END IF
	
	IF l_cmon = 3 AND g_mcon = 1 THEN
		LET l_impc = f0100_redondeo_gb000((l_impc*g_tcof),2)
	END IF
	
	RETURN l_impi,l_impc
END FUNCTION

FUNCTION f7100_ins_asiento_pc488(pref,ccon,desc,impi,impc)
DEFINE  pref LIKE pctcn.pctcnpref,
	ccon LIKE pctcn.pctcnccon,
	desc LIKE pctcn.pctcndesc,
	impi LIKE pctcn.pctcnimpi,
	impc LIKE pctcn.pctcnimpc,
	l_host 	CHAR(50),
	l_text	CHAR(300),
	l_dia	DATE
	# (@#)7-A INICIO
	,l_const_0 SMALLINT #Constante valor 0
	,l_sqle INTEGER #Codigo de error
	# (@#)7-A FIN
	
	IF g_adic IS NULL THEN LET g_adic = 0 END IF
	# (@#)7-A INICIO
	LET l_const_0 = 0
	# (@#)7-A FIN
	LET g_hora = TIME
	LET l_host = f0020_buscar_bd_gb000(t5.pcmpcplaz,"F")
	LET l_text = "INSERT INTO ",l_host CLIPPED,":pctcn ",
			"VALUES(?,?,?,?,3,?,?,?,?,?,?,?,?,?,0,?,?,?,?,?)"
	PREPARE p_ipctcn FROM l_text
	
	LET l_dia = TODAY
	
	EXECUTE p_ipctcn USING t4.pcctlndoc,g_item,g_fech,t5.pcmpcnpre,
		t1.pccesnces,pref,ccon,desc,g_ctbl,g_adic,impi,impc,
		g_tcof,t5.pcmpcplaz,t5.pcmpcagen,g_user,g_hora,l_dia
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	IF STATUS < 0 THEN
		RETURN TRUE
	END IF
	
	RETURN FALSE
END FUNCTION

FUNCTION f7200_provision_pc488(l_cage, l_npre,l_plaz)
	DEFINE	l_cage	INTEGER,
		l_npre	INTEGER,
		l_prov	DECIMAL(14,2),
		l_plaz	SMALLINT,
		l_host	CHAR(50),
		l_text	CHAR(300)
		# (@#)7-A INICIO
		,l_const_0 SMALLINT #Constante valor 0
		,l_sqle INTEGER #Codigo de error
		# (@#)7-A FIN
	INITIALIZE l_prov TO NULL
	# (@#)7-A INICIO
	LET l_const_0 = 0
	# (@#)7-A FIN
	LET l_text = 	"SELECT SUM(pvtrnimpt) ",
			"FROM pvtrn ",
			"WHERE pvtrncage = ",l_cage," ",
			"AND pvtrnnopr = ",l_npre," ",
			"AND pvtrnstat <> 9 "
	PREPARE p_sprov FROM l_text
	EXECUTE p_sprov INTO l_prov
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	IF l_prov IS NULL THEN
		LET l_prov = 0
	END IF
	
	RETURN l_prov
END FUNCTION

FUNCTION f0400_generando_provision_pc488(l_fech)
	DEFINE 	l_impt 	DEC(14,2),
		l_prev	DEC(14,2),
		l_acon	DEC(14,2),
		l_calf	LIKE gbage.gbagecalf,
		l_porc	LIKE pvtpr.pvtprtab2,
		l_sald	LIKE pcmpc.pcmpcsald,
		l_cont	SMALLINT,
		l_tabl  SMALLINT,
		l_fpvc	DATE,
		l_dias	INTEGER,
		l_fech	DATE,
		l_user	CHAR(3),
		l_fprv	LIKE pcmpc.pcmpcfprv,
		l_cage	INTEGER,
	# (@#)7-A INICIO
	#l2	RECORD LIKE efpca.*,
	l2	RECORD
		efpcanpre LIKE efpca.efpcanpre,
		efpcadatr LIKE efpca.efpcadatr,
		efpcaplaz LIKE efpca.efpcaplaz,
		efpcacmon LIKE efpca.efpcacmon
		END RECORD,
	# (@#)7-A FIN
		l6	RECORD LIKE pvtpr.*
	# (@#)5-B - INICIO
    ,l_cnu0 SMALLINT       #Constante que almacena el numero 0
    ,l_cnu2 SMALLINT       #Constante que almacena el numero 2
    ,l_cnu4 SMALLINT       #Constante que almacena el numero 4
    ,l_cn18 SMALLINT       #Constante que almacena el numero 18
    ,l_sql  CHAR(2000)     #Cadena para la preparacion de sentencias sql
    ,l_sqlc INTEGER        #Control de transaccion
    ,l_coun SMALLINT       #Cantidad de registros
    # (@#)6-A Inicio
    ,l_const_143 SMALLINT #constante numero 143
    ,l_tcre SMALLINT #tipo de credito
    ,l_const_F CHAR(1) #constante letra 'F'
    ,l_impd DECIMAL(14,2) #importe diferido del saldo del credito refinanciado
	 # (@#)7-A INICIO
	 ,l_sqle INTEGER #Codigo de error
	 ,l_const_1 SMALLINT #Constante valor 1
	 LET l_const_1 = 1
	 # (@#)7-A FIN
    LET l_const_143 = 143
    LET l_const_F = 'F'
    # (@#)6-A Fin
    LET l_cnu0=0  LET l_cnu2=2 LET l_cnu4=4  LET l_cn18=18
  # (@#)5-B - FIN
	LET l_calf = 4

	CREATE TEMP TABLE tmp_prov
	(	npre	INTEGER,
		plaz	SMALLINT
	)WITH NO LOG
	# (@#)5-B - INICIO
	  LET l_sql = "SELECT COUNT(eefpcanpre) FROM tmp_riesgos WHERE eefpcanpre=?"
    PREPARE l_query05 FROM l_sql
    LET l_sql = "INSERT INTO tmp_prov VALUES (?,?)"
    PREPARE l_query06 FROM l_sql
  # (@#)5-B - FIN
  # (@#)6-A Inicio
  LET l_sql = "SELECT pcmpctcre FROM pcmpc WHERE pcmpcnpre = ? AND pcmpcmrcb = ", l_cnu0
	PREPARE p_query_60 FROM l_sql
	LET l_sql = "EXECUTE FUNCTION ", f0020_buscar_bd_gb000(l_cnu0,l_const_F) CLIPPED,":pa_sfi_pc_asiento_credito_refinanciado(?) "
	PREPARE p_query_61 FROM l_sql
  # (@#)6-A Fin
	MESSAGE "Generando provision..."
	# (@#)7-A INICIO
	{DECLARE d_cursor CURSOR WITH HOLD FOR
		SELECT * 
		  FROM efpca 
		 WHERE efpcafech = l_fech
		   AND efpcastat = 1
			
	FOREACH d_cursor  INTO l2.*
		IF STATUS <> NOTFOUND THEN}
			#DISPLAY l2.efpcanpre AT 3,24
			
			{SELECT pcmpcfprv,pcmpccage,pcmpcsald INTO l_fprv,l_cage,l_sald 
			FROM pcmpc
			WHERE pcmpcnpre = l2.efpcanpre}
	OPEN d_cursor USING l_fech, l_const_1
	FETCH d_cursor  INTO l2.efpcanpre, l2.efpcadatr, l2.efpcaplaz, l2.efpcacmon
		WHILE STATUS <> NOTFOUND
			EXECUTE s_tpcmpc USING l2.efpcanpre INTO l_fprv,l_cage,l_sald
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_cnu0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			# (@#)7-A FIN 
		##------------- Prevision Automatica ------------##
		IF l_fprv = 2 OR l_fprv = 4 THEN
		# (@#)5-B - INICIO
		  LET l_coun = l_cnu0
			EXECUTE l_query05 USING l2.efpcanpre INTO l_coun
			LET l_sqle = SQLCA.SQLCODE
		IF l_sqle < l_cnu0 THEN
			DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
			RETURN FALSE
		END IF
				LET l_sqlc = SQLCA.SQLCODE
		  IF l_sqlc < l_cnu0 THEN DISPLAY "ERROR DE BASE DE DATOS: ",l_sqlc END IF
		 IF l_coun = l_cnu0 THEN 	
		# (@#)5-B - FIN
		    ##--------- Calificacion --------##
		    IF l2.efpcadatr > 120 THEN
			LET l_calf = 4
			# (@#)6-A Inicio
			EXECUTE p_query_60 USING l2.efpcanpre INTO l_tcre
			LET l_sqlc = SQLCA.SQLCODE
		  IF l_sqlc < l_cnu0 THEN DISPLAY "ERROR DE BASE DE DATOS: ",l_sqlc END IF
			# (@#)6-A Fin
			# -------------- Prev. Constituida ----------------#
			LET l_prev = 0
			LET l_prev =f5100_buscar_previ_pc488(18,l2.efpcanpre,
								l2.efpcaplaz)
			# --------------- Prev. Actual --------------------#			 
			# --------------- Prev. A Contituir ---------------#
			# (@#)6-A Inicio
			LET l_impd = l_cnu0
			IF l_tcre = l_const_143 THEN #Si el credito es refinanciado se halla el capital neto del saldo del credito
				EXECUTE p_query_61 USING l2.efpcanpre INTO l_sald, l_impd, l_sqlc
				IF l_sqlc < l_cnu0 THEN DISPLAY "ERROR DE BASE DE DATOS: ",l_sqlc END IF
			END IF
			# (@#)6-A Fin
			LET l_acon = 0
			LET l_acon = l_sald - l_prev
			IF l_acon <> 0 THEN
				IF NOT f1100_actualiza_pvtrn_pc488(l_cage,
						              l2.efpcacmon,
							      l_acon      ,
							      l_calf      ,
							      l2.efpcaplaz,
							      l2.efpcanpre) THEN
					ERROR "NO PUEDE AL REGISTRAR PREVISION.."
					SLEEP 4
					RETURN FALSE
				END IF
							# (@#)7-A INICIO
							#INSERT INTO tmp_prov VALUES (l2.efpcanpre,l2.efpcaplaz) 
								LET l_text = " INSERT INTO tmp_prov VALUES (?,?) "
								PREPARE i_tmpprov FROM l_text
								EXECUTE i_tmpprov USING l2.efpcanpre,l2.efpcaplaz
								LET l_sqle = SQLCA.SQLCODE
								IF l_sqle < l_cnu0 THEN
									DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
									RETURN FALSE
								END IF
								FREE i_tmpprov
							# (@#)7-A FIN
			END IF
		    END IF
		# (@#)5-B - INICIO   
		 ELSE
		 	  LET l_calf = l_cnu4  LET l_prev = l_cnu0
				LET l_prev =f5100_buscar_previ_pc488(l_cn18,l2.efpcanpre,l2.efpcaplaz) 
				LET l_acon = l_cnu0
				LET l_acon = l_sald - l_prev
				IF NOT l_acon = l_cnu0 THEN
					IF NOT f1100_actualiza_pvtrn_pc488(l_cage,l2.efpcacmon,l_acon,l_calf,l2.efpcaplaz,l2.efpcanpre) THEN
						ERROR "NO PUEDE AL REGISTRAR PREVISION.."	RETURN FALSE
					END IF
				 EXECUTE l_query06 USING l2.efpcanpre,l2.efpcaplaz
		     LET l_sqlc = SQLCA.SQLCODE
		     IF l_sqlc < l_cnu0 THEN DISPLAY "ERROR DE BASE DE DATOS: ",l_sqlc END IF
				END IF
		 END IF
		# (@#)5-B - FIN
		END IF
	# (@#)7-A INICIO
	#END IF
	#END FOREACH
	FETCH d_cursor INTO l2.efpcanpre, l2.efpcadatr, l2.efpcaplaz, l2.efpcacmon
	END WHILE
	CLOSE d_cursor
	# (@#)7-A FIN
	CALL p3000_elimina_temporales_pc488(l_cnu2) # (@#)5-B
	RETURN TRUE
END FUNCTION

FUNCTION f1100_actualiza_pvtrn_pc488(l_cage,l_cmon,l_previ,l_calf,l_plaz,l_npre)
	DEFINE 	l_cage		INTEGER,
		l_cmon		SMALLINT,
		l_previ  	DEC(14,2),
		l_calf		CHAR(1),
		l_plaz		SMALLINT,
		l_host		CHAR(50),
		l_text		CHAR(450),
		l_fech		DATE,
		l_npre		INTEGER
		# (@#)7-A INICIO
		,l_const_0 SMALLINT #Constante valor 0
		,l_sqle INTEGER #Codigo de error
	LET l_const_0 = 0
		# (@#)7-A FIN
	LET l_text = "INSERT INTO pvtrn ",
		"VALUES (0,?,?,18,?,?,?,?,0,?,?,?,?,0) "
	LET l_fech = TODAY
	PREPARE p_ipvtrn FROM l_text
	EXECUTE p_ipvtrn USING g_fech,l_cage,l_npre,l_calf,
			l_cmon,l_previ,g_user ,g_hora,l_fech,l_plaz
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	IF	STATUS	<  0 THEN
		ERROR "2 NO PUDE EJECUTAR OPERACION (pvtrn)" 
		ATTRIBUTE(REVERSE)
		RETURN FALSE
	END IF
	RETURN TRUE
END FUNCTION

FUNCTION f5100_buscar_previ_pc488(l_nmod,l_nopr,l_plaz)
	DEFINE	l_nmod	DECIMAL(02,0),
		l_nopr	LIKE pvtrn.pvtrnnopr,
		l_previ LIKE pvtrn.pvtrnimpt,
		l_plaz	SMALLINT,
		l_host	CHAR(50),
		l_text	CHAR(350)
		# (@#)7-A INICIO
		,l_const_0 SMALLINT #Constante valor 0
		,l_sqle INTEGER #Codigo de error
	LET l_const_0 = 0
	# (@#)7-A FIN
	LET l_previ = 0	
	LET l_text = "SELECT sum(pvtrnimpt) FROM pvtrn ",
		"WHERE pvtrnnopr = ",l_nopr," ",
		"AND pvtrnnmod = ",l_nmod," ",
		"AND pvtrnstat = 0 "
	PREPARE p_spvtrn FROM l_text
	EXECUTE p_spvtrn INTO l_previ
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	IF l_previ IS NULL THEN 
		LET l_previ = 0 
	END IF
	RETURN l_previ
END FUNCTION

FUNCTION f9310_generar_datos_reporte_pc488()
	DEFINE	l1	RECORD
			fech	DATE,
			cmon    SMALLINT,
			cage	INTEGER,
			cfun	INTEGER,
			calf	SMALLINT,
			fcal	CHAR(1),
			nmod	SMALLINT,
			nopr	DEC(16),
			esta    SMALLINT,
			sald    DEC(14,2),
			impt	DEC(14,2),
			clas	CHAR(1)
			END RECORD,
			
		l_cicl  SMALLINT ,
		l_flag  SMALLINT ,
		l_ntrj  DEC(16),
		l_plaz	SMALLINT,
		l_host	CHAR(50),
		l_text	CHAR(350),
		l_npre	INTEGER
		# (@#)7-A INICIO
		,l_const_0 SMALLINT #Constante valor 0
		,l_sqle INTEGER #Codigo de error
	{DECLARE q_rep CURSOR FOR
	SELECT * FROM tmp_prov 
	FOREACH q_rep INTO l_npre,l_plaz
		##--Eliminando el registro del prestamo en pvprv
		LET l_text = "DELETE FROM pvprv ",	#jzena
				"WHERE pvprvnopr =",l_npre 
		PREPARE p_tpvprv FROM l_text}
	LET l_const_0 = 0
	LET l_text = " SELECT npre,plaz",
			" FROM tmp_prov"
	PREPARE s_tmpprov FROM l_text
	DECLARE q_rep CURSOR FOR s_tmpprov
	OPEN q_rep 
	FETCH q_rep INTO l_npre,l_plaz
		WHILE STATUS <> NOTFOUND
		EXECUTE p_tpvprv USING l_npre
		##--Creando el prepare para obtener datos de provision
		{LET l_text = "SELECT pvtrncage,pvtrnnmod,pvtrnnopr,sum(pvtrnimpt) ",
			"FROM pvtrn ",
			"WHERE pvtrnstat = 0 ",
			"AND pvtrnnopr = ",l_npre," ",
			"GROUP BY 1,2,3 "
		PREPARE p_cpvtrn FROM l_text }
	    ##--Prepare para la insercion de pvprv
		{LET l_text = "INSERT INTO pvprv ",
			"VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)"
		PREPARE p_ipvprv FROM l_text 
		EXECUTE p_cpvtrn INTO  l1.cage,l1.nmod,l1.nopr,l1.impt}
		EXECUTE p_cpvtrn USING l_const_0,l_npre INTO  l1.cage,l1.nmod,l1.nopr,l1.impt	    
		LET l_sqle = SQLCA.SQLCODE
		IF l_sqle < l_const_0 THEN
			DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
			RETURN FALSE
		END IF
		# (@#)7-A FIN
	    IF l1.impt IS NOT NULL AND l1.impt > 0 THEN
		LET l1.calf = 4
		CASE l1.nmod
		   WHEN 18 #----------Prestamos Consumo-------------#			
			LET l1.cmon = NULL LET l1.esta = NULL LET l1.cfun = NULL
			LET l1.sald = 0
			LET l_flag = TRUE
			# (@#)7-A INICIO
			{SELECT pcmpccmon,pcmpcstat,pcmpcrseg,pcmpcsald,pcmpcfprv 
			INTO l1.cmon,l1.esta,l1.cfun,l1.sald,l1.fcal
			FROM pcmpc
			WHERE pcmpcnpre = l1.nopr}
			EXECUTE s_tpcmpc02 USING l1.nopr INTO l1.cmon,l1.esta,l1.cfun,l1.sald,l1.fcal
			LET l_sqle = SQLCA.SQLCODE
			IF l_sqle < l_const_0 THEN
				DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
				RETURN FALSE
			END IF
			# (@#)7-A FIN
			IF STATUS = NOTFOUND THEN	
				LET l_flag = FALSE
			END IF
			
			#--Agregado para que castigados no pasen - EAY
			IF l1.esta = 7 THEN
				LET l_flag = FALSE
			END IF
			#-------------
			
			IF l_flag THEN
			   EXECUTE p_ipvprv USING g_fech,l1.cmon,l1.cage,
				l1.cfun,l1.calf,l1.fcal,l1.nmod,l1.nopr,l1.esta,
				l1.sald,l1.impt,l1.clas,l_plaz
				LET l_sqle = SQLCA.SQLCODE
				IF l_sqle < l_const_0 THEN
					DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
					RETURN FALSE
				END IF
			   IF STATUS < 0 THEN
				ERROR "Error al insertar pvprv CONSUMO"
				SLEEP 3
				RETURN TRUE
			   END IF
			END IF
		END CASE
	    END IF
	# (@#)7-A INICIO
		FETCH q_rep INTO l_npre,l_plaz
	END WHILE 
	FREE s_tmpprov
	FREE q_rep
	CLOSE q_rep
	
	#DROP TABLE tmp_prov 
	LET l_text = " DROP TABLE tmp_prov "
	PREPARE d_tmpprov FROM l_text
	EXECUTE d_tmpprov
	LET l_sqle = SQLCA.SQLCODE
	IF l_sqle < l_const_0 THEN
		DISPLAY "Error de base de datos: ", l_sqle SLEEP 1
		RETURN FALSE
	END IF
	FREE d_tmpprov
	# (@#)7-A FIN
    	RETURN FALSE
END FUNCTION



