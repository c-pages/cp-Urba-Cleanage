
plugin simpleObject		cp_menuis_ensemble
name:"Ensemble"
classID:#(0x3872840c, 0xa1a0c21)
category:"CP | Facade	| Menuiserie"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_menuisEnsemble"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pr� d�claration -----------
	local corriger_parametres , 	actualiser_composants 
	local	ajouter_element, retirer_element, monter_element, descendre_element, renommer_element
	local est_instance
	
	local sequence_tmp
	
	--- composant ---
	local compo_cadre, compo_meneau--, compo_travBas
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	
	parameters params_general rollout:roll_general
	(
		----- global ---------------------
		longueur 						type:#worldUnits 	ui:spn_longueur 					default:120.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur				default:10.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 					default:0.
		
		----- les menuiseries -----------
		cadre_largeur					type:#worldUnits 	ui:spn_cadre_largeur			default:2.5
		
		
		on profondeur	set val do corriger_parametres ()
		on longueur 	set val do corriger_parametres ()
		
	)
	
-- 	parameters params_sequence rollout:roll_parametres (
	parameters params_general rollout:roll_parametres	(
	
		align_prof					type:#worldUnits 		ui:spn_aling_prof	default:5.
		
		sequence					type:#maxObjectTab	tabSizeVariable:true
		sequence_elem_long		type:#floatTab			tabSizeVariable:true
		
		on align_prof					set val do corriger_parametres ()
		on sequence_elem_long 	set arg1 arg2 do corriger_parametres ()
		
		
	)
	
	parameters params_divers rollout:roll_divers
	(
		
		nom	 							type:#string 			default:"Ensemble"
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
	)	-----	fin parametres --------------------
	
	
	
	
	
	
	
	
	rollout roll_general  "Param�tres"
	(
		
		spinner spn_longueur 				"longueur" 				type:#worldunits range:[0,1e20,0]
		spinner spn_hauteur 				"Hauteur" 				type:#worldunits range:[0,1e20,0]
		spinner spn_profondeur 			"Profondeur" 			type:#worldunits range:[0,1e20,0]
		
		group "Cadre" (
			spinner spn_cadre_largeur			"Largeur" 				type:#worldunits 	range:[0,1e20,0]
		)
	)
	
	rollout roll_parametres  "S�quence"
	(
		--- divers ------------------------------------------------------------------------------------------------------
		fn get_menuiserie_plugins =(
			local geo_classes			=	GeometryClass.classes 
			local menuiseries_classes 	= for geo_classe in geo_classes	where findstring ( geo_classe as string )		"cp_menuis_" != undefined	 and geo_classe != cp_menuis_ensemble	collect	geo_classe
			menuiseries_classes
		)
		
		--- menus clique droit --------------------------------------------------------------
		fn creer_RCM_ajouter	=(

			
			
			--- on recupere les plug necessaires ---------
			local menuiseries_plugins = get_menuiserie_plugins ()
			
			--- on ecrit le menu ---------
			local menu_txt=""
			menu_txt += "rcmenu  menu_ajouter (\n"
			
-- 			menu_txt += "fn est_copiable = $.est_copiable ()\n"
			
			
			---- les boutons ------------------------------------------
			for menuis_plug in menuiseries_plugins do
				menu_txt += "menuItem	btn_" + menuis_plug.name as string + "	\"" + menuis_plug.name + "\"\n" 
			
			---- les evenements ---------------------------------------------
			for menuis_plug in menuiseries_plugins do
				menu_txt += "on		btn_" + menuis_plug.name as string + " picked do $.ajouter_element_menuis " + menuis_plug as string+ "\n" 
			
			--- fin du rc menu -----
			menu_txt += ")"
			
			---- on ouvre le menu -----
			RCmenu_ajouter	=	execute menu_txt
			popUpMenu	RCmenu_ajouter
			
		) --- fin creer_RCM_ajouter ---------------
		fn creer_RCM_edition	=(

			rcmenu  RCmenu_edition (
				
				local this_test
				
				menuItem	btn_dupliquer	 		"Dupliquer" 			enabled:($.est_copiable 	())
				menuItem	btn_instancier	 		"Instancier" 		enabled:($.est_copiable	())
				menuItem	btn_rendreUnique	 	"Rendre unique" 	enabled:($.est_instance	())
				
				on		btn_dupliquer 		picked 	do $.dupliquer_element_menuis ()
				on		btn_instancier 	picked 	do $.instancier_element_menuis ()
				on		btn_rendreUnique picked 	do $.rendreUnique_element_menuis ()
				
			)
			RCmenu_edition.this_test = $
			popUpMenu	RCmenu_edition
			
			format "par LA\n"
		) --- fin creer_RCM_ajouter ---------------
		
		
		
		
		spinner 	spn_aling_prof 		"Alignement" 		type:#worldunits range:[0,1e20,0]
		
		button 		btn_ajouter 		"+"			across:4
		button 		btn_retirer	 		"-"			
		button 		btn_monter			"/\\"			
		button 		btn_descendre	"\\/"
		
		listBox		lbx_sequence		""	height:5
		
		group "" (	
			editText 	edTxt_nom		 	"Nom:" 	
			spinner 	spn_elem_long		"Longeur" 		type:#worldunits range:[0,1e20,0]		tooltip:"La longueur de l'�l�ment.\n0.0: Longueur automatique (R�partition r�guli�re des longueurs)"
		)
		
		subrollout	subroll_param		""	height:300
		dotNetControl btn_resize 	"System.Windows.Forms.Button" 		align:#left width:150 height:10
		
		
		
		
		fn actualiser =(
			
			---- l'affichage de la sequence -------------------
			local elements_noms 	= #()
			for i = 1 to sequence.count do (
				local elem_nom = sequence[i].nom
				if est_instance 	id:i 	do elem_nom += " *"
				append elements_noms	elem_nom
			)	
			lbx_sequence.items 		=  for elem_nom in elements_noms collect elem_nom
			
			
			--- les parametres de l'element (le subrollout)  ---------------			
			--- on retire les vieux rollouts --------
			if subroll_param.rollouts.count > 0 do 
				for subRoll in subroll_param.rollouts  do
					removeSubRollout subroll_param	subRoll
				
			---- on ajoute le nouveau -----------------
			if lbx_sequence.selection > 0 then (
				
				local composant_actif 		=  sequence[  lbx_sequence.selection ]
				addSubRollout 	subroll_param		composant_actif.roll_parametres
				
				spn_elem_long.indeterminate		=	false
				spn_elem_long.enabled 				=	true
				
				spn_elem_long.value = sequence_elem_long[  lbx_sequence.selection ]				
				edTxt_nom.text	=	sequence[  lbx_sequence.selection ].nom
				
			) else(
				
				spn_elem_long.indeterminate		=	true
				spn_elem_long.enabled 				=	false
				
				edTxt_nom.enabled = false
				edTxt_nom.text	=	""
			)
			
			---- les boutons ------
			btn_retirer.enabled 		= lbx_sequence.selection != 0
			btn_monter.enabled 		= lbx_sequence.selection > 1
			btn_descendre.enabled = lbx_sequence.selection < sequence.count and lbx_sequence.selection != 0
			
			
			
		) --- fin actualiser -----------
		
		
		
		----- Gestion du resize du subRollout -----------------------
		local resize_enCours 			= false
		local pos_initial					=	[0,0]
		local subRoll_hauteur_init		=	0
		local btnResize_pos_init		=	[0,0]
		local rollParam_hauteur_init	=	[0,0]
		fn resize_surbRoll =(
			if resize_enCours do (
				local mouse_pos 			= mouse.posUnscaled
				local changement_ht 	= mouse_pos.y - pos_initial.y
				local subRoll_nvl_ht 	= subRoll_hauteur_init 		+ 	changement_ht
				
				if subRoll_nvl_ht >	50 do (
					subroll_param.height		=	subRoll_nvl_ht
					btn_resize.pos.y			=	btnResize_pos_init.y		+	changement_ht
					roll_parametres.height	=	rollParam_hauteur_init 	+ 	changement_ht
				)
			)
		)
		
		
		
		
		on roll_parametres		open 				do 	(
			actualiser ()
			
			---- le bouton resize -----------------------
			btn_resize.FlatStyle	=		(dotNetClass "System.Windows.Forms.FlatStyle").flat	
			btn_resize.BackColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
			btn_resize.ForeColor	=		(dotNetClass "System.Drawing.Color").fromARGB 	110	110	110
		)
		on lbx_sequence 		selected sel 	do	actualiser ()
		
		on lbx_sequence	 rightClick 	_id 	do	(
			lbx_sequence.selection = _id
			actualiser ()
			creer_RCM_edition ()
			
		)
		
		
		
		on btn_ajouter 		pressed 			do 	creer_RCM_ajouter ()
		on btn_retirer 		pressed 			do	$.retirer_element_menuis 		lbx_sequence.selection 
		on btn_monter 		pressed 			do	$.monter_element_menuis 		lbx_sequence.selection 
		on btn_descendre 	pressed		 	do	$.descendre_element_menuis 	lbx_sequence.selection 
		on spn_elem_long 	changed val	do	(
			sequence_elem_long[  lbx_sequence.selection ] = val
			redrawviews ()
		)
		
		on edTxt_nom entered txt do renommer_element		lbx_sequence.selection 	txt
		
		
		
		
		
		
		
		
		
		------------ le bouton resize -----------------------
		on	btn_resize	MouseDown 	do (
			resize_enCours 			= true
			pos_initial					=	mouse.posUnscaled
			subRoll_hauteur_init		= subroll_param.height
			btnResize_pos_init		=	btn_resize.pos
			rollParam_hauteur_init	=	roll_parametres.height
		)
		on	btn_resize	MouseUp 		do	resize_enCours = false		
		on	btn_resize	MouseMove 	do 	resize_surbRoll ()
		on	btn_resize	MouseLeave 	do	resize_enCours = false		
		
		
		
		
	)
	rollout roll_divers  "Divers"
	(
		group "Qualit�" (
			checkbox	shk_lowPoly		"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 	"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 	"Vitrage" 				type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	
	------------ FONCTIONS	----------------------------------------------------------------------------------
	---- les parametres ----------------
	fn corriger_parametres 	=(
		
		--- rester dans les bonnes limites ------
		if align_prof > profondeur do align_prof = profondeur
		
		
		--- longueur de l'ensemble ----------
		local longueur_est_contrainte = true
		local longueur_contrainte = 0
		for elem_long in sequence_elem_long do
			if elem_long == 0 do longueur_est_contrainte	=	false
		if longueur_est_contrainte and sequence.count > 0  do (
			for elem_long in sequence_elem_long do (
				longueur_contrainte += elem_long
				longueur_contrainte += cadre_largeur
			)
			longueur_contrainte += cadre_largeur
			longueur = longueur_contrainte
		)
		
	)
	
	--------- divers ------------------
	fn est_porte	_compo	=	classof	_compo	==	cp_menuis_porte
	fn est_fixe		_compo	=	classof	_compo	==	cp_menuis_fixe
	fn est_copiable			=	 roll_parametres.lbx_sequence.selection != 0
	fn est_instance	id:		= (
		if id == unsupplied do id = roll_parametres.lbx_sequence.selection
		local result =false
		for i = 1 to sequence.count where i != id do
			if sequence[i] == sequence[ id] do result = true
		result
	)
	
	
	--------------- comopsants ----------------------------------
	fn actualiser_composants	= with redraw off (
		
		---- creation des composants ------------------
		if compo_cadre 		== undefined	do	compo_cadre		= 	createInstance  cp_compo_cadre
		if compo_meneau		== undefined	do	compo_meneau	= 	createInstance  cp_compo_meneau
		
		----- maj du cadre ----------------------
		compo_cadre.longueur 						= longueur
		compo_cadre.profondeur 					= profondeur
		compo_cadre.hauteur 						= hauteur	
		compo_cadre.menuis_largeur	 			= cadre_largeur	
		compo_cadre.travBasse_hauteur	 		= cadre_largeur	
		compo_cadre.low_poly			 			= low_poly		
		compo_cadre.matId_menuis	 			= matId_menuis
		compo_cadre.travBasse					=	false
		
		----- Meneaux  ----------------------
		compo_meneau.longueur 					= cadre_largeur
		compo_meneau.profondeur 				= profondeur
		compo_meneau.hauteur 					= hauteur	-  cadre_largeur
		compo_meneau.low_poly			 		= low_poly		
		
		
		
		
		--- maj des composants de la sequence -------------
		local longueur_passage 			= longueur 	- 2*cadre_largeur
		local nbr_meneaux					= sequence.count - 1		
		local longueur_total_meneaux	=	( sequence.count - 1 )* compo_meneau.longueur 		
		local longueur_definies_total 		= 0
		local nbr_elem_definies 			= 0
		for i = 1 to sequence.count do (
			if sequence_elem_long[i] != 0 do (
				longueur_definies_total+= sequence_elem_long[i]
				nbr_elem_definies += 1
			)
		)		
		local longueur_composant	= ( longueur_passage - ( longueur_total_meneaux + longueur_definies_total ) ) / ( sequence.count - nbr_elem_definies )
		
		
		
		sequence_tmp 				= #()
		for i = 1 to sequence.count do (
			
			local compo_temp 				= 	copy sequence[i]
	
			if sequence_elem_long[i] != 0 then	compo_temp.longueur 	= 	sequence_elem_long[i]
													else		compo_temp.longueur	=	longueur_composant
			
			if est_porte 	compo_temp 	then
				compo_temp.hauteur			=	hauteur - cadre_largeur
			else
				compo_temp.hauteur			=	hauteur - 2*cadre_largeur
			
			compo_temp.profondeur		=	0 -- profondeur
			compo_temp.cadre_use			= false
			compo_temp.low_poly			=	low_poly
			
			append sequence_tmp		compo_temp
		)
		
		
		--- Si notre sequence est vide
		if sequence.count == 0 do (
			local compo_temp = createInstance cp_menuis_fixe
			
			append	sequence_tmp  	compo_temp
			
			compo_temp.hauteur		=	hauteur - 2*cadre_largeur
			compo_temp.profondeur		=	profondeur
			compo_temp.cadre_use			= false
			compo_temp.low_poly			=	low_poly
			compo_temp.longueur			=	longueur 	- 2*cadre_largeur
		)
		
		
	)  --- fin composants_actualiser  ------------------
	
	
	fn actualiser = (
		corriger_parametres ()		
		actualiser_composants()		
		if roll_parametres.open do	roll_parametres.actualiser ()		
		redrawViews ()
	)
	
	
	
	
	
	
	
	
	--------------- sequence ----------------------------------
	fn ajouter_element_menuis		_element_plug	 =(
		
		local	id_elem_select 	= 	roll_parametres.lbx_sequence.selection
		local	id_elem_insert		= 	id_elem_select + 1
		
		local nvl_element 		= createinstance	_element_plug
		
		if id_elem_select != 0 and id_elem_select	!= sequence.count	then	(
			insertItem nvl_element 		sequence 		id_elem_insert
			insertItem 0. 		sequence_elem_long 	id_elem_insert
		) else (		
			append sequence		nvl_element
			append sequence_elem_long	0.
		)		
		---- actualisations -----------
		actualiser ()
		
		if roll_parametres.open do	(
			roll_parametres.lbx_sequence.selection = id_elem_insert 
			roll_parametres.actualiser ()	
		)
		
	)
	fn retirer_element_menuis		_id	 	=(
		
		deleteItem sequence 				_id
		deleteItem sequence_elem_long 	_id
		
		---- actualisations -----------
		actualiser ()
	)
	fn monter_element_menuis 		_id 		=(
		
		local elem_temp 		= sequence[ _id ]
		local meneau_temp 	= sequence_elem_long[ _id ]
		deleteItem 	sequence 				_id
		deleteItem sequence_elem_long 	_id
		insertItem 	elem_temp			sequence  					(	_id - 1 )
		insertItem 	meneau_temp		sequence_elem_long  	(	_id - 1 )
		
		---- actualisations -----------
		actualiser ()
		
		if roll_parametres.open do	(
			roll_parametres.lbx_sequence.selection -=  1
			roll_parametres.actualiser ()	
		)
	)
	fn	descendre_element_menuis 	_id 		=(
		
		local elem_temp 		= sequence[ _id ]
		local meneau_temp 	= sequence_elem_long[ _id ]
		deleteItem 	sequence 				_id
		deleteItem sequence_elem_long 	_id
		if _id == sequence.count then (
			append sequence 				elem_temp
			append sequence_elem_long	meneau_temp
		) else (
			insertItem 	elem_temp		sequence  					(	_id + 1 )
			insertItem 	meneau_temp		sequence_elem_long  	(	_id + 1 )
		)
		
		
		---- actualisations -----------
		actualiser ()
		
		if roll_parametres.open do	(
			roll_parametres.lbx_sequence.selection +=  1
			roll_parametres.actualiser ()	
		)
	)
	fn renommer_element_menuis	_id	_nv_nom =(
		sequence[ _id ].nom = _nv_nom
		if roll_parametres.open do	roll_parametres.actualiser ()
	)
	
	
	fn dupliquer_element_menuis 	id_elem_select:		=(
		
		if id_elem_select 	== unsupplied do
			id_elem_select 		= 	roll_parametres.lbx_sequence.selection
		local	id_elem_insert		= 	id_elem_select + 1
		
		local nvl_element 			= copy sequence[ id_elem_select ]
		local nvl_element_long 	= copy sequence_elem_long[ id_elem_select ]
		
		if id_elem_select != 0 and id_elem_select	!= sequence.count	then	(
			insertItem nvl_element 		sequence 		id_elem_insert
			insertItem nvl_element_long 		sequence_elem_long 	id_elem_insert
		) else (		
			append sequence		nvl_element
			append sequence_elem_long	nvl_element_long
		)		
		---- actualisations -----------
		actualiser ()
		
		if roll_parametres.open do	(
			roll_parametres.lbx_sequence.selection = id_elem_insert 
			roll_parametres.actualiser ()	
		)
	)
	fn instancier_element_menuis 	id_elem_select:		=(

		if id_elem_select 	== unsupplied do
			id_elem_select 		= 	roll_parametres.lbx_sequence.selection
		local	id_elem_insert		= 	id_elem_select + 1
		
		local nvl_element 			=  sequence[ id_elem_select ]
		local nvl_element_long 	=  sequence_elem_long[ id_elem_select ]
		
		if id_elem_select != 0 and id_elem_select	!= sequence.count	then	(
			insertItem nvl_element 		sequence 		id_elem_insert
			insertItem nvl_element_long 		sequence_elem_long 	id_elem_insert
		) else (		
			append sequence		nvl_element
			append sequence_elem_long	nvl_element_long
		)		
		---- actualisations -----------
		actualiser ()
		
		if roll_parametres.open do	(
			roll_parametres.lbx_sequence.selection = id_elem_insert 
			roll_parametres.actualiser ()	
		)
	)
	
	fn rendreUnique_element_menuis	 id_elem_select:		=(
		
		if id_elem_select 	== unsupplied do
			id_elem_select 		= 	roll_parametres.lbx_sequence.selection
		sequence[ id_elem_select ] = copy sequence[ id_elem_select ] 
		
		---- actualisations -----------
		actualiser ()
	)
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		---- le cadre  -------
		mesh	+	compo_cadre.mesh
		
		
		
		---- la sequence	-----
		local compo_travBas	= 	if low_poly	then	createInstance  cp_prim_boiteL else createInstance 	cp_prim_boite
		local depos_composant = [ cadre_largeur, 0, 0 ]
		for i = 1 to	sequence_tmp.count do (
			
			---- le composant -----
			local composant 		= sequence_tmp [i]
			local calage_y		= 	0	--	if est_fixe		composant		then 	0 else  -( composant.ouvrant_profondeur / 2 )
			local calage_z			= if est_porte		composant		then 	0 else  cadre_largeur
			
			local depose_temp 	= if  not est_fixe 	composant 	then  	depos_composant  	+ [0, align_prof + calage_y ,calage_z ]
																					else		depos_composant 	+ [0,align_prof,cadre_largeur ]
			
			
			mgr_mesh.attacher		mesh		composant	transf:depose_temp
			
			---- la traverse du bas ------------
			if not est_porte 	composant 	do (
				compo_travBas.hauteur 		= 	cadre_largeur
				compo_travBas.profondeur		=	profondeur
				compo_travBas.longueur		=	composant.longueur
				mgr_mesh.attacher		mesh		compo_travBas	transf:depos_composant
			)
				
			
			depos_composant.x += composant.longueur
			
			--- le meneau- ----
			if i != sequence_tmp.count do (				
				mgr_mesh.attacher		mesh		compo_meneau	transf:depos_composant
				depos_composant.x += compo_meneau.longueur
			)
		)
		
		
		
	)  ----- fin on buld mesh -----------------
	
	
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		local pt_epaisseur
		
		on mousePoint click do
			case click of
			(
				1: (	
						pt_debut 		=  gridPoint
						nodeTM.translation = pt_debut
				)
				3: #stop
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 				= 	length 		( gridPoint - pt_debut )
					local norm_dir 		=	normalize 	(gridPoint - pt_debut )
					local angle_pts		=	acos			(dot  [1,0,0]  norm_dir)	
					
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
					pt_hauteur	=	gridPoint
					
				)
				3:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
					
				)
			)		
	) --- fin tool create ---------
	
	
	
)		------- fin plugin		-----------------










