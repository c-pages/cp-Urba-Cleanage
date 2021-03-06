


plugin simpleObject		urba_menuiserie_fixe
name:"Fixe"
classID:#(0x154a56e1, 0x726397f7)
category:"CP | Menuiserie"
-- invisible:true
(
	
	
	------------ DEBUG	----------------------------------------------------------------------------------
	local m_debug = true
-- 	local 	m_debug = false
	local 	m_dbgPrefix ="urba_menuiserie_fixe"
	fn debug 	_txt  var:	 param:    =	if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
	------------ DEBUG	----------------------------------------------------------------------------------
	
	
	---- pr� d�claration -----------
	local composants_actualiser 
	
	--- le manager de primitives---------------	
	local mgr_compo	=	str_mgr_menuiseries_composants ()
	
	--- le manager de primitives---------------	
	local mgr_prim	=	str_mgr_primitives ()
	
	
	
	parameters params_general rollout:roll_general
	(
		
		----- global ---------------------
		longueur 						type:#worldUnits 	ui:spn_longueur 			default:0.
		profondeur	 					type:#worldUnits 	ui:spn_profondeur		default:0.
		hauteur	 						type:#worldUnits 	ui:spn_hauteur 			default:0.
		
		----- les menuiseries -----------
		menuis_epaisseur	 			type:#worldUnits 	ui:spn_epaisseur			default:0.		
		traverse_B_epaisseur		type:#worldUnits 	ui:spn_traverse_B_ep	default:0.
		div_horiz		 				type:#integer		 	ui:spn_div_horiz			default:0.
		div_verti			 				type:#integer		 	ui:spn_div_verti			default:0.
		div_epaisseur	 				type:#worldUnits 	ui:spn_div_epaisseur		default:0.
		
		----- les composants -----------	
		composant_base				type:#maxObject
		composant_imposte			type:#maxObject
		
		------ options --------------
		low_poly							type:#boolean 		ui:shk_lowPoly				default:false
		
		------ mat ID ----------
		matId_menuis					type:#integer 			ui:spn_matId_menuis	default:1
		matId_vitrage					type:#integer 			ui:spn_matId_vitrage	default:2
		
		on longueur					set val 	do	composants_actualiser ()
		on profondeur					set val 	do	composants_actualiser ()
		on hauteur						set val 	do	composants_actualiser ()
		on menuis_epaisseur		set val 	do	composants_actualiser ()
		on traverse_B_epaisseur	set val 	do	composants_actualiser ()
		
		on div_horiz					set val 	do	composants_actualiser ()
		on div_verti					set val 	do	composants_actualiser ()
		on div_epaisseur				set val 	do	composants_actualiser ()
		
		on low_poly					set val 	do	composants_actualiser ()
		
		on matId_menuis				set val 	do	composants_actualiser ()
		on matId_vitrage				set val 	do	composants_actualiser ()
		
	)	-----	fin parametres --------------------
	
	parameters params_imposte rollout:roll_imposte
	(
		imposte_use					type:#boolean 		ui:shk_imposte						default:false
		imposte_trav_hauteur		type:#worldUnits 	ui:spn_imposte_trav_Ht				default:0.
		
		imposte_div_horiz		 		type:#integer		 	ui:spn_imposte_div_horiz			default:0.
		imposte_div_verti			 	type:#integer		 	ui:spn_imposte_div_verti			default:0.
		
		
		on imposte_use					set val 	do	composants_actualiser ()
		on imposte_trav_hauteur		set val 	do	composants_actualiser ()
		on imposte_div_horiz			set val 	do	composants_actualiser ()
		on imposte_div_verti			set val 	do	composants_actualiser ()
		
	)
	
	
	
	rollout roll_general  "Fixe"
	(
		group "Global" (
			spinner spn_longueur 			"longueur" 				type:#worldunits range:[0,1e20,0]
			spinner spn_hauteur 			"Hauteur" 				type:#worldunits range:[0,1e20,0]
			spinner spn_profondeur 		"Profondeur" 			type:#worldunits range:[0,1e20,0]
		)
		group "Menuiserie" (
			spinner spn_epaisseur	 		"Epaisseur" 				type:#worldunits 	range:[0,1e20,0]
			spinner spn_traverse_B_ep	"Trav. basse �p." 	type:#worldunits 	range:[0,1e20,0]
			spinner spn_div_epaisseur	"Divisions �p." 			type:#worldunits 	range:[0,1e20,0]
		)
		group "Divisions" (	
			
			spinner spn_div_horiz	 		"Div. Horizontale" 	type:#integer			range:[0,1e20,0]
			spinner spn_div_verti	 		"Div. Verticale" 		type:#integer			range:[0,1e20,0]
		)
		
		group "Qualit�" (
			checkbox	shk_lowPoly		"Low poly" 		
		)
		group "Material ID" (
			spinner spn_matId_menuis 	"Menuiseries" 			type:#integer range:[1,1000,1]
			spinner spn_matId_vitrage 	"Vitrage" 				type:#integer range:[1,1000,1]
		)
		/* 
		on spn_div_epaisseur changed val do 
			if  val>  profondeur do div_epaisseur = profondeur
		 */
	) 	---- fin rollout	-----------------------
	
	rollout roll_imposte  "Imposte"
	(
		checkbox	shk_imposte						"Imposte"
	
		spinner 	spn_imposte_trav_Ht			"Traverse ht." 				type:#worldunits 	range:[0,1e20,0]
	
		spinner 	spn_imposte_div_horiz	 		"Div. Horizontale" 	type:#integer			range:[0,1e20,0]
		spinner 	spn_imposte_div_verti	 		"Verticale" 				type:#integer			range:[0,1e20,0]
		
	
		fn actualiser = (
			spn_imposte_trav_Ht.Indeterminate 	= not imposte_use
			spn_imposte_trav_Ht.enabled 			= imposte_use
			
			spn_imposte_div_horiz.Indeterminate 	= not imposte_use
			spn_imposte_div_horiz.enabled 			= imposte_use
			
			spn_imposte_div_verti.Indeterminate 	= not imposte_use
			spn_imposte_div_verti.enabled 			= imposte_use
			
		)
		
		on roll_imposte		open 				do	actualiser ()
		on shk_imposte		changed val 	do	actualiser ()
		
	)
	
	
	
	
	
	
	
	--------------- FONCTIONS  ----------------------------------------------------------------------------------------------------------------------
	fn composants_actualiser	= with redraw off (
		
		------ definition initiales----------
		local ht_base 
		if imposte_use	then
			ht_base	=	imposte_trav_hauteur	--hauteur	-	( imposte_trav_hauteur - menuis_epaisseur )
		else 
			ht_base	=	hauteur	
		
		---- maj du composant de base ------------------
		composant_base.longueur 						= longueur
		composant_base.profondeur 					= profondeur
		composant_base.hauteur 						= ht_base
		composant_base.menuis_epaisseur 			= menuis_epaisseur
		composant_base.traverse_B_epaisseur 	= traverse_B_epaisseur
		
		composant_base.div_horiz 					= div_horiz
		composant_base.div_verti 					= div_verti
		composant_base.div_epaisseur			 	= div_epaisseur
		
		composant_base.low_poly			 			= low_poly
		
		composant_base.matId_menuis	 			= matId_menuis
		composant_base.matId_vitrage	 			= matId_vitrage
		
		---- imposte -----------
		if imposte_use do (
			
			composant_imposte.traverse_B				= false
			composant_imposte.longueur					= longueur
			composant_imposte.hauteur					= hauteur	- imposte_trav_hauteur 
			composant_imposte.profondeur				= profondeur
			composant_imposte.menuis_epaisseur 		= menuis_epaisseur
			
			composant_imposte.div_horiz 				= imposte_div_horiz
			composant_imposte.div_verti 				= imposte_div_verti
			composant_imposte.div_epaisseur			= div_epaisseur
			
			composant_imposte.low_poly			 		= low_poly
			
			composant_imposte.matId_menuis	 		= matId_menuis
			composant_imposte.matId_vitrage	 		= matId_vitrage
			
		)
		
	)  --- fin composants_actualiser  ------------------
	
	
	
	
	
	
	
	
	
	
	
	
	
	--------------- CONSTRUCTION  ----------------------------------------------------------------------------------------------------------------------
	on buildMesh do	(
		
		--- vider le mesh --------
		delete mesh
		
		---- la base -------
		meshop.attach	mesh		composant_base.mesh
		
		---- imposte -----------
		if imposte_use do (
			imposte_mesh = 		copy composant_imposte.mesh
			mgr_compo.transformer		imposte_mesh		[0,0,imposte_trav_hauteur ]
			meshop.attach	mesh		imposte_mesh
		)
		
		---  la face qui manque en low poly  --------
		if low_poly do 
			mgr_prim.ajouter_plan_horizontal	mesh		long:		( longueur - 2* menuis_epaisseur )	\
																		prof:		profondeur		\
																		transf:	[menuis_epaisseur, 0, imposte_trav_hauteur ]	\
																		matID:	matId_menuis
		
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
				5: #stop
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
					
					composants_actualiser ()
					
					pt_profondeur	=	gridPoint
					
					
				)
				3:	(
					profondeur 				= 	length ( gridPoint - pt_profondeur )
					
					composants_actualiser ()
					
					pt_hauteur				=	gridPoint
				)
				4:	(
					hauteur 					= length ( gridPoint - pt_hauteur )
					pt_epaisseur 			= gridPoint
					
					composants_actualiser ()
					
				)
				5: (
					menuis_epaisseur 	= length ( gridPoint - pt_epaisseur )					
					traverse_B_epaisseur 	= menuis_epaisseur
					
					composants_actualiser ()
				)
					
			)		
	) --- fin tool create ---------
	
	on create do (
		composant_base		= 	mgr_compo.get_chassis ()
		composant_imposte	= 	mgr_compo.get_chassis ()
	)
) ------- fin plugin ---------------------






		


