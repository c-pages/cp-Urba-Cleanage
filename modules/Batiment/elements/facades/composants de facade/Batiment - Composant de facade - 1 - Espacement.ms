
	
( ----	FileIn ----
	
	


------ parametres de base	-----------------------------
compo_nom 		= "Espacement"	
compo_type		=	#espacement
compo_toolTip 	=	"Ajouter un espacement. Mur plein de longueur varirable, r�partis par facade, entre tous les espacement"


------ la fonction de construction	---------
fn compo_fnConstruire  	_plug		pts_accroches		_normDir		 _composant		= ()
	
--- les parametres du composant	---------
struct compo_params	(
	longueur = 0.,
	longueur_min = 0,
	longueur_max = 0
	
)

--- les rollout du composant	---------
rollout compo_dialog "Espacement" width:180 height:70	(
	local m_rollPrt
	local m_compo
	local m_plug
	fn actualiser =()
)



------------------CONSTANT ------------------------
--- on importe le fichier mere des composants ----
_str_contructeur = fileIn "$userScripts\cp-Urba\modules\Batiment\elements\Batiment - Constructeur.ms"
--- Creation de la structure mere	-----------------
_str_contructeur 	tooltip:compo_tooltip		nom:compo_nom	type:compo_type	params:(compo_params())	dialog:compo_dialog	fnConstruire:compo_fnConstruire		invisible:true

	
) ----	FileIn ----
	
	
	
	
	
	
	
	
	