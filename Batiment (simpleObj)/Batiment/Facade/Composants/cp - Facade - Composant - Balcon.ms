
plugin simpleObject		cp_facadeCompo_balcon
name:"Balcon"
classID:#(0x5b4e91a1, 0x66f01359)
category:"CP | Facade	| Composant"
-- invisible:true
(
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="cp_facadeCompo_balcon"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pr� d�claration -----------
	local corriger_parametres 
	
	--- composant ---
	local compo_cadre, compo_vitrage
	
	---- manager de mesh -------------------
	local mgr_mesh = str_mgr_mesh ()
	
	
	---- la sequence � construire issue de la sequence	------------------------
	local sequence_aConstruire
	
	--------------- PARAMETERES  ----------------------------------------------------------------------------------------------------------------------
	parameters params_parameters rollout:roll_parametres	(
		
		nom	 					type:#string 		/* 	ui:edTxt_nom	 */				default:"Balcon"
		
-- 		etirable					type:#boolean 	/* 	ui:shk_etirable			 */		default:false
		
		longueur 				type:#worldUnits 	/* ui:spn_longueur 	 */			default:0.
		hauteur	 				type:#worldUnits 	/* ui:spn_hauteur  */			default:0.
		dalle_epaisseur 		type:#worldUnits /* 	ui:spn_dalle_epaisseur	 */		default:20.
		dalle_porteAFaux	 	type:#worldUnits 	ui:spn_dalle_porteAFaux 	default:60.
		profondeur	 			type:#worldUnits 	ui:spn_profondeur 			default:60.
		
		
		elements				type:#maxObjectTab		tabSizeVariable:true
		
		gardeCorps				type:#integer		 	ui:ddl_gardeCorps 			default:1
		
-- 		
-- 		on elements 	tabChanged  	_operation		 _index	_count		do (
-- 			longueur = 0
-- 			for elem in elements do
-- 				longueur += elem.longueur
-- 		)
		/* 
		on longueur 	get 	_arg do (
			local result_longueur = 0
			for elem in elements do
				result_longueur += elem.longueur
			result_longueur
		) */
	)
	parameters params_divers rollout:roll_divers
	(
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_huisserie				type:#integer 			ui:spn_matId_huisserie	default:3
		matId_mur						type:#integer 			ui:spn_matId_mur		default:4
		
	)	-----	fin parametres --------------------
	
	parameters params_hasard rollout:roll_hasard
	(
		hasard_seed					type:#integer 			ui:spn_hasard_seed		default:123456
		
		fen_proba_ouv				type:#float 			ui:spn_fen_proba_ouv		default:0.
		fen_ouvMax					type:#float 			ui:spn_fen_ouvMax			default:0.
	)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	rollout roll_hasard  "Hasard"	(
		
		spinner spn_hasard_seed 			"Seed" 					type:#integer		 range:[0,1e20,0]
		
		group "Fenetres" (
			spinner spn_fen_proba_ouv 		"Proba (%)" 			type:#float			 range:[0,100,0]
			spinner spn_fen_ouvMax 			"Max (�)" 		type:#float			 range:[0,180,0]
		)
	
	)
	
	
	
	
	
	--------------- ROLLOUTS  ----------------------------------------------------------------------------------------------------------------------
	rollout roll_parametres 				"Param�tres"	(
-- 		editText 	edTxt_nom		 		"Nom:" 	
-- 		spinner 	spn_longueur 		"Longueur" 				type:#worldunits 	range:[0,1e20,0]
		group  "Dimensions" (
-- 			spinner 	spn_dalle_epaisseur 		"Ep. dalle" 				type:#worldunits 	range:[0,1e20,0]
			spinner 	spn_dalle_porteAFaux 		"Porte-�-faux" 			type:#worldunits 	range:[0,1e20,0]
-- 		)
-- 		group "loggia" (
			
			spinner 	spn_profondeur 		"Profondeur" 			type:#worldunits 	range:[0,1e20,0]
		)
		group "Garde corps" (
			dropDownList	ddl_gardeCorps	""	items:#("Aucun", "Simple", "Bareaudage")
			
		)
	)
	
	rollout roll_divers  "Divers"	(
		 group "Qualit�" (
			checkbox	shk_lowPoly		"Low poly" 		
		) 
		group "Material ID" (
			spinner spn_matId_huisserie 	"Huisserie" 				type:#integer range:[1,1000,1]
			spinner spn_matId_mur 			"Mur" 					type:#integer range:[1,1000,1]
		)
	) 	---- fin rollout	-----------------------
	
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	fn est_ouvrable		_compo	=	classof	_compo	==	cp_facadeCompo_ensemble
	
	
	
	fn get_longueur	=	(
		local result_longueur = 0
		for elem in elements do
			result_longueur += elem.get_longueur ()
		result_longueur
	) 
	fn set_hasard	_fen_ouvMax	_fen_proba_ouv =(
		
		
		fen_ouvMax 		= _fen_ouvMax
		fen_proba_ouv 	= _fen_proba_ouv
		for elem in elements do
			elem.set_hasard	_fen_ouvMax	_fen_proba_ouv
	)
	/* 
	-----elements -------------
	fn ajouter_element		_elem	id:		=(
		append elements		_elem
		_elem.parent = this
	)
	fn retirer_element		_id		=(
		local elem_avirer	=	elements[_id]
		deleteItem	 elements	_id
		elem_avirer.parent = undefined
		
		elem_avirer
	) */
	
	
	
	
	
	fn actualiser_composants	= with redraw off (
		
		sequence_aConstruire 				= 	#()
		
		for elem in elements do (
			
			--- le composant ----------------
			local compo_temp 				= 	copy elem				
			compo_temp.hauteur			=	hauteur
			compo_temp.low_poly			=	low_poly
			compo_temp.set_hasard	fen_ouvMax	fen_proba_ouv 
			append sequence_aConstruire		compo_temp
			
		) --- fin for sequence ------------------
		
	)  --- fin actualiser_composants  ------------------
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		---- maj des composants -----
		actualiser_composants ()
		
		--- vider le mesh --------
		delete mesh
		
		
		--- Construction ---------------------------------------------------------------------------------------		
		local compo_dalle		= 	createInstance 	cp_prim_boite	matId:matId_mur
		compo_dalle.hauteur 		= 	dalle_epaisseur
		compo_dalle.profondeur		=	dalle_porteAFaux
		compo_dalle.longueur		=	get_longueur()
		mgr_mesh.attacher		mesh		compo_dalle			transf:[0,-dalle_porteAFaux ,-dalle_epaisseur]
		
		---- la sequence	-----		
		local depos_composant = [ 0, 0, 0 ]
		for i = 1 to	sequence_aConstruire.count do (
			
			---- le composant -----
			local composant 		= sequence_aConstruire [i]
-- 			local align_y 			=	profondeur
			mgr_mesh.attacher		mesh		composant	transf:( depos_composant + [0,profondeur,0] )
						
			depos_composant.x += composant.get_longueur()
			
		)
		
		
		
		--- les element pour la loggia , si besoin	---------
		if profondeur > 0 do (
			--- sol ------
			local compo_mur			= 	createInstance 	cp_prim_planHorizontal	matId:matId_mur
			compo_mur.longueur 	=	get_longueur()
			compo_mur.profondeur 	=	profondeur			
			mgr_mesh.attacher		mesh		compo_mur		--transf:( rotateZMatrix	90 )
			
			--- plafond ----
			mgr_mesh.attacher		mesh		compo_mur		transf:( ( rotateYMatrix	180  )	*	transMatrix	[get_longueur(), 0, hauteur ] )
			
			
			--- mur G  ------
			local compo_mur			= 	createInstance 	cp_prim_planVertical		matId:matId_mur
			compo_mur.longueur 	=	profondeur
			compo_mur.hauteur	 	=	hauteur			
			mgr_mesh.attacher		mesh		compo_mur		transf:( rotateZMatrix	90 )
			
			
			--- mur D ----
			mgr_mesh.attacher		mesh		compo_mur		transf:( ( rotateZMatrix	-90  )	*	transMatrix	[get_longueur(), profondeur, 0 ] )
			
			
		)
		
		
	)
	
	
	
	
	
	------------ TOOLS	----------------------------------------------------------------------------------------------------------------------
	tool create
	(
		local pt_debut
		local pt_profondeur
		local pt_hauteur
		
		on mousePoint click do
			case click of
			(
				1: (	pt_debut 	=  gridPoint
						nodeTM.translation = pt_debut
				)
				2: #stop
			)
		on mouseMove click do
			case click of
			(
				2: ( 
					longueur 				= length ( gridPoint - pt_debut )
					local norm_dir 		=	normalize (gridPoint - pt_debut )
					local angle_pts		=	acos(dot  [1,0,0]  norm_dir)		
					if  norm_dir.y < 0 do angle_pts = 360 - angle_pts 
					nodeTM  				= rotateZMatrix angle_pts
					nodeTM.translation 	= pt_debut
					
				)
			)
	) --- fin tool create ---------
	
	
	
) ---- fin du plugin --------------------------