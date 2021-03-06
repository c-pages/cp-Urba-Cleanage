
	
( ----	FileIn ----
	
	


------ parametres de base	-----------------------------
menuis_nom 		= "Fen�tre"	
menuis_type			=	#fenetre
menuis_toolTip 		=	""


	
--- les parametres du composant	---------
struct menuis_params	(
	longueur 				= 0,
	hauteur					=	0,
	allege_vitree_ht		=	0,
	ouverture_sens 		= 1
)

--- les rollout du composant	---------
rollout menuis_dialog "Fen�tre" width:180 height:130
(
	
		local m_plug		
		local m_compo
		local m_rollPrt		
		
		---- golbal --------------
		label 'lbl_longueur' "Longueur:" pos:[6,-1] width:63 height:13 align:#left
		spinner 'spn_longueur' "" pos:[99,-1] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
		
		label 'lbl_hauteur' "Hauteur : " pos:[6,14] width:75 height:13 align:#left
		spinner 'spn_hauteur' "" pos:[99,14] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
		label 'lbl_ouverture' "Ouverture :" pos:[6,47] width:57 height:13 align:#left
		dropdownList 'ddl_ouverture' "" pos:[68,45] width:100 height:21 items:#("Auto", "Droite", "Gauche") align:#left
		
		label 'lbl3' "All�ge vitr�e" pos:[6,29] width:75 height:13 align:#left
		spinner 'spn_allege_vitree' "" pos:[99,29] width:70 height:16 range:[0,100000,0] type:#worldunits scale:1 align:#left
		
	
		fn actualiser =(
			spn_hauteur.value 		= m_compo.params.hauteur			
			spn_allege_vitree.value 	= m_compo.params.allege_vitree_ht
			ddl_ouverture.selection	=	m_compo.params.ouverture_sens
		)
		fn initialiser _plug = m_plug = _plug
		fn set_menuiserie _menuis =(
			m_compo	=	_menuis
			actualiser ()
		)
		
		
		
		
	on spn_hauteur changed val do
	(
				m_compo.params.hauteur		 = val
			m_rollPrt.changer_un_truc ()
			)
	on ddl_ouverture selected val do
	(
				m_compo.params.ouverture_sens		 = val
			m_rollPrt.changer_un_truc ()
			)
	on spn_allege_vitree changed val do
	(
				m_compo.params.allege_vitree_ht		 = val
			m_rollPrt.changer_un_truc ()
			)
	on spn_longueur changed val do
	(
			m_compo.params.longueur = val
			m_rollPrt.changer_un_truc ()
	)
)

------ la fonction de construction	---------
fn menuis_fnConstruire  	_plug				 _pt_origine			norm_dir:			dist_hauteur:	ptr_baie:		 this:		inverse_ouverture:false 	= (
	
	--------------------------  PARAMETRES 			-----------------------------------------------------------------------------------------------------------------
			local ptr_geo = _plug.core.get_geo ()
			
		-------------  constantes 			-----------------------------------------------------------------------------------------------------------------
			local 	norm_dir				=	norm_dir
			local		baie_longueur		=	ptr_baie.params.longueur
			local		baie_hauteur			=	dist_hauteur
			local		baie_profondeur		=	_plug.const_murExt_epaisseur
			
			local menuis_largeur			=	_plug.const_menuiseries_largeur
			local menuis_epaisseur		=	_plug.const_menuiseries_epaisseur		
			local menuis_nu				=	ptr_baie.params.profondeur		
			local vitrage_epaisseur		=	_plug.const_vitrage_epaisseur
			local fenetre_longeur			=	this.params.longueur
			
			local allege_ht					=	this.params.allege_vitree_ht
	
			local 	fenetre_hauteur		=	if this.params.hauteur == 0 then baie_hauteur - allege_ht	else this.params.hauteur - allege_ht
			if fenetre_hauteur	>baie_hauteur do fenetre_hauteur = baie_hauteur
			
			
			
			local traverses					=	ptr_baie.params.traverses
			
			
			/* 
			--- gestion du hazard -------
			local test_ouvertureFenetre = random 0 100 <  _plug.alea_volet_clos_proba
			local mtrx_rotationHasard 
			if  test_ouvertureFenetre then (
				local sens_ouvertue  = if not inverse_ouverture then 1 else -1
				local angleMin 		= sens_ouvertue * 180. * _plug.alea_volet_clos_proba/100
				local angleMax 		= sens_ouvertue * 180. * _plug.alea_volet_clos_max/100
					
				mtrx_rotationHasard 	= rotateZMatrix  	( random angleMin angleMax )
				
			)	else
				mtrx_rotationHasard = matrix3 1
			
			 */
			
						
			--- gestion du hazard -------
			local test_ouvertureFenetre = random 0 100 <  _plug.alea_ouvrant_ouvert_proba
			local mtrx_rotationHasard 
			if  test_ouvertureFenetre then (
				local sens_ouvertue  = if not inverse_ouverture then 1 else -1
				local angleMin 		= sens_ouvertue * 90. * _plug.alea_ouvrant_ouvert_min/100
				local angleMax 		= sens_ouvertue * 90. * _plug.alea_ouvrant_ouvert_max/100
					
				mtrx_rotationHasard 	= rotateZMatrix  	( random angleMin angleMax )
-- 				local vecBougeCentre 	= 
-- 				translate mtrx_rotationHasard
				
			)	else
				mtrx_rotationHasard = matrix3 1
			
			
			
		-------------  vecteurs directeurs  		-----------------------------------------------------------------------------------------------------------------
			local norm_prof				= norm_dir 		*	rotateZ ( matrix3 1 ) 90		
			
			local vec_longueur 			= norm_dir 		*	fenetre_longeur
			local vec_baie_ht	 		= [0,0,1]  		*	baie_hauteur
			
			local vec_men_ep			=	norm_prof	*	menuis_epaisseur
			local vec_men_lrg			=	norm_dir		*	menuis_largeur
			local vec_men_ht			=	[0,0,1] 		*	menuis_largeur
			local vec_men_nu			=  norm_prof 	*	menuis_nu
			
			
			local vec_fen_ht			=	[0,0,1]			*	fenetre_hauteur
			local vec_fen_long		=	( vec_longueur + vec_men_lrg/2 )	*	mtrx_rotationHasard
			local vec_fen_ep			=	vec_men_ep		*	mtrx_rotationHasard
			local vec_fen_lrg			=	vec_men_lrg		*	mtrx_rotationHasard
-- 			local vec_fen_ht			=	vec_men_ht
			
			
			
			
			
			local vec_allege_ht		= 	[0,0,1] 			*	allege_ht
			
			local vec_vitrage_ep		=	norm_prof		*	vitrage_epaisseur		 *	mtrx_rotationHasard
			local vec_murEp			=	norm_prof 	*	_plug.const_murExt_epaisseur
			
			
			
			
			
			
	--------------------------  CONSTRUCTION 			-----------------------------------------------------------------------------------------------------------------
		
		-------------   menuiserie du bas		-----------------------------------------------------------------------------------------------------------------
			local ptTmp				=	_pt_origine 	--	+ vec_allege_ht
			if inverse_ouverture then
				ptr_geo.tube		(ptTmp-	vec_men_lrg)	(vec_longueur	 + vec_men_lrg )	vec_men_ht				   vec_men_ep			matID:#menuiserie 
			else 
				ptr_geo.tube		ptTmp		vec_longueur		vec_men_ht				   vec_men_ep			matID:#menuiserie 
			
			
		-------------   allege	vitr�e 		-----------------------------------------------------------------------------------------------------------------
			if allege_ht != 0 do (				
				--- vitrage	------------
				local ptTmp					=	_pt_origine + vec_men_ht + vec_men_ep/2 + vec_vitrage_ep/2		--+ vec_allege_ht
				local vecTMP_htVitr		=  vec_allege_ht - vec_men_ht
				ptr_geo.tube		ptTmp		vecTMP_htVitr		vec_longueur			-vec_vitrage_ep				matID:#vitrage 
				
				-------------   menuiserie allege		-----------------------------------------------------------------------------------------------------------------
				local ptTmp				=	_pt_origine + vec_allege_ht
				ptr_geo.tube		ptTmp		vec_longueur		vec_men_ht				   vec_men_ep			matID:#menuiserie 
			)
			
			
		-------------   fenetre				-----------------------------------------------------------------------------------------------------------------
			
-- 				format "inverse_ouverture :%\n" inverse_ouverture
			--- Sens ouverture normal ---------------
			if not inverse_ouverture then (
				
				-------------   menuiserie bas		-----------------------------------
				local ptFen1				=	_pt_origine + vec_allege_ht +  vec_men_ht + vec_men_ep/2
				ptr_geo.tube		ptFen1		vec_fen_long		vec_men_ht				   vec_fen_ep			matID:#menuiserie

				-------------   menuiserie haut		-----------------------------------
				local ptFen2				=	ptFen1 + vec_fen_ht	- 3*vec_men_ht		--	_pt_origine + vec_fen_ht -   vec_men_ht + vec_men_ep/2
				ptr_geo.tube		ptFen2		vec_fen_long		vec_men_ht				   vec_fen_ep			matID:#menuiserie
				
				-------------   menuiserie gauche		-----------------------------------
				local ptFen3				=	ptFen1 + vec_men_ht
				local vec_fen_htTMP	=	(vec_fen_ht  - 4*vec_men_ht ) 
				ptr_geo.tube		ptFen3		vec_fen_htTMP 		vec_fen_lrg      vec_fen_ep		matID:#menuiserie
				
				-------------   menuiserie droite		-----------------------------------
				local ptFen4				=	ptFen3 + vec_fen_long -  vec_fen_lrg
				ptr_geo.tube		ptFen4			vec_fen_htTMP	vec_fen_lrg      vec_fen_ep		matID:#menuiserie
				
				--- vitrage	------------
				local ptTmp					=	ptFen1 + vec_fen_lrg + vec_men_ht + vec_fen_ep/2 + vec_vitrage_ep/2
				local vecTMP_htVitr		=  vec_fen_htTMP
				ptr_geo.tube		ptTmp		vecTMP_htVitr		( vec_fen_long - 2*vec_fen_lrg )			-vec_vitrage_ep				matID:#vitrage 
				
				
				
			--- Sens ouverture inverse  ---------------
			) else(
				
				-------------   menuiserie bas		-----------------------------------
				local ptFen1				=	_pt_origine + vec_fen_long + vec_allege_ht +  vec_men_ht + vec_men_ep/2			
				local vecBougeCentre 	= ( ptFen1 + vec_fen_long ) - ( ptFen1 + vec_longueur ) + vec_fen_long

				ptFen1 -= vecBougeCentre
				ptr_geo.tube		ptFen1		vec_fen_long		vec_men_ht				   vec_fen_ep			matID:#menuiserie

				-------------   menuiserie haut		-----------------------------------
				local ptFen2				=	ptFen1 + vec_fen_ht	- 3*vec_men_ht		--	_pt_origine + vec_fen_ht -   vec_men_ht + vec_men_ep/2
-- 				ptFen2 -= vecBougeCentre
				ptr_geo.tube		ptFen2		vec_fen_long		vec_men_ht				   vec_fen_ep			matID:#menuiserie
				
				-------------   menuiserie gauche		-----------------------------------
				local ptFen3				=	ptFen1 + vec_men_ht
-- 				ptFen3 -= vecBougeCentre
				local vec_fen_htTMP	=	(vec_fen_ht  - 4*vec_men_ht ) 
				ptr_geo.tube		ptFen3		vec_fen_htTMP 		vec_fen_lrg      vec_fen_ep		matID:#menuiserie
				
				-------------   menuiserie droite		-----------------------------------
				local ptFen4				=	ptFen3 + vec_fen_long -  vec_fen_lrg
-- 				ptFen4 -= vecBougeCentre
				ptr_geo.tube		ptFen4			vec_fen_htTMP	vec_fen_lrg      vec_fen_ep		matID:#menuiserie
				
				--- vitrage	------------
				local ptTmp					=	ptFen1 + vec_fen_lrg + vec_men_ht + vec_fen_ep/2 + vec_vitrage_ep/2
-- 				ptTmp -= vecBougeCentre
				local vecTMP_htVitr		=  vec_fen_htTMP
				ptr_geo.tube		ptTmp		vecTMP_htVitr		( vec_fen_long - 2*vec_fen_lrg )			-vec_vitrage_ep				matID:#vitrage 
			)
			
			
			
			
			
			
			
			
		-------------   Imposte vitr�e				-----------------------------------------------------------------------------------------------------------------
			if (	fenetre_hauteur < baie_hauteur ) do (
				-----	menuiserie	-------------
				local ptImposte1				=	_pt_origine + vec_allege_ht + vec_fen_ht - vec_men_ht
				ptr_geo.tube		ptImposte1		vec_longueur		vec_men_ht				   vec_men_ep			matID:#menuiserie
				
				--- vitrage	------------
				local ptTmp					=	ptImposte1  + vec_men_ht + vec_men_ep/2 + vec_vitrage_ep/2
				local vecTMP_htVitr		=  vec_baie_ht - vec_allege_ht - vec_fen_ht - vec_men_ht
				ptr_geo.tube		ptTmp		vecTMP_htVitr		vec_longueur 			-vec_vitrage_ep				matID:#vitrage 
				
			)
			
	)	----	fin construire	--------------------

------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:menuis_tooltip		nom:menuis_nom	type:menuis_type	params:(menuis_params())	dialog:menuis_dialog	fnConstruire:menuis_fnConstruire

	
) ----	FileIn ----
	
	
	
	
	
	
	
