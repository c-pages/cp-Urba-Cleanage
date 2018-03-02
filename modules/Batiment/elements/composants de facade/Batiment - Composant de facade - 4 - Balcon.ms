


	
( ----	FileIn ----
	
	


--- parametres de base	-----------------------------
compo_nom 	= "Balcon"	
compo_type	=	#balcon
compo_toolTip =	""


--- les parametres du composant	---------
struct compo_params	(
	longueur = 0,
	largeur	= 100
)


--- les rollout du composant	---------
rollout compo_dialog "Balcon" width:180 height:70	(
	
	local m_compo
	local m_rollPrt
	local m_plug

	edittext 'edt_nom' "" pos:[7,3] width:166 height:16 align:#left
	GroupBox 'grp1' "G�n�rale" pos:[6,21] width:167 height:37 align:#left
	label 'lbl_largeur' "Largeur:" pos:[13,37] width:49 height:13 align:#left
	spinner 'spn_largeur' "" pos:[96,36] width:70 height:16 range:[1,100000,0] type:#worldunits scale:1 align:#left
	
	fn actualiser =(
		spn_largeur.value 	= 	m_compo.params.largeur
		edt_nom.text 		=	m_compo.nom
	)

	on spn_largeur changed val do 
		m_compo.params.largeur = val		
	
	on edt_nom	 entered txt 	do	(
		m_compo.nom = txt
		m_rollPrt.actualiser ()
	)
	
)


--- la fonction de construction	---------
fn compo_fnConstruire  	_plug		pts_accroches		_normDir		 _composant		= (

	local ptr_geo 				= 	_plug.core.get_geo ()
	
	--- Result -------------
	local pt_result_1, pt_result_2, pt_result_3
	
	--- Vecteurs ------------
	local vec_ep_dalle 	= [0,0,1] 			* 	_plug.const_dalle_epaisseur			
	local vec_longueur 	= _normDir 		* 	_composant.params.longueur
	local norm_balcon	= _normDir * rotateZ ( matrix3 1 ) -90
	local vec_largeur		= norm_balcon 	*	 _composant.params.largeur				
	
	--- Points d'accroche ------------
	local id_ptAccroche_1 	= pts_accroches[1]
	local id_ptAccroche_2 	= pts_accroches[2]
	local id_ptAccroche_3 	= pts_accroches[3]
	
	local ptAccroche_1		=	polyop.getVert 	_plug.delegate		id_ptAccroche_1	
	local ptAccroche_2		=	polyop.getVert 	_plug.delegate		id_ptAccroche_2	
	local ptAccroche_3		=	polyop.getVert 	_plug.delegate		id_ptAccroche_3	
	
	
	-------	Placement des points 	--------
	local pt_1 		= ptAccroche_1
	local pt_2 		= pt_1		+  vec_longueur
	local pt_3 		= pt_2		+ 	vec_ep_dalle				
	local pt_4		= pt_1		+ 	vec_ep_dalle
	
	local pt_5		= pt_1		+	vec_largeur
	local pt_6		= pt_2		+	vec_largeur		
	local pt_7		= pt_3		+	vec_largeur
	local pt_8		= pt_4		+	vec_largeur
	
	--- creation des points --------------
	local pts_pos 	= #( 	pt_1, pt_2, pt_3, pt_4, pt_5, pt_6, pt_7, pt_8 )
	local pts_ids 	= ptr_geo.points 	pts_pos		
	
	-------	Creation des faces 	--------
	local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[5], 		pts_ids[8], 		pts_ids[4] )
	ptr_geo.set_matID 	nvlFace	#mur 	
	local nvlFace = ptr_geo.face 		#(	pts_ids[5], 		pts_ids[6], 		pts_ids[7] , 	pts_ids[8] )	
	ptr_geo.set_matID 	nvlFace	#mur 	
	local nvlFace = ptr_geo.face 		#(	pts_ids[6], 		pts_ids[2], 		pts_ids[3] , 	pts_ids[7] )	
	ptr_geo.set_matID 	nvlFace	#mur 	
	local nvlFace = ptr_geo.face 		#(	pts_ids[1], 		pts_ids[2], 		pts_ids[6], 		pts_ids[5] )	
	ptr_geo.set_matID 	nvlFace	#mur 	
	local nvlFace = ptr_geo.face 		#(	pts_ids[8], 		pts_ids[7], 		pts_ids[3], 		pts_ids[4] )	
	ptr_geo.set_matID 	nvlFace	#mur 		 				
	
	
	--- on reinitialise la longueur � 0 --------
	_composant.params.longueur = 	0
	
	
	#()
		
)
	



------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur  	tooltip:compo_tooltip		nom:compo_nom	type:compo_type	params:(compo_params())	dialog:compo_dialog	fnConstruire:compo_fnConstruire

	
	
	
	
	
	
	
	
	
	
) ----	FileIn ----


	
	
	
	
	
	
	
	