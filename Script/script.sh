#!/bin/bash
############################################
####### Script - Gestion à distance ########
######## Groupe 3 - Projet 2 - 2024 ########
############################################

#### fonction pour se connecter à distance ??? SSH ???

##### fonction pour gérer le log -> ajout_log()
#Prend en argument un texte et l'ajoute avec date/user/... dans le bon fichier

##### fonction pour gérer l'affichage d'un menu
# Les arguments sont les différents choix.
function menu() {
    clear
    echo -e "\e[0;36m #### The Scripting Project ####"
    message="Entrez votre choix : 0"
    echo -e "\e[0;m Que voulez vous faire ? "
    echo " 0 : Fin du script "
    i=1
    for arg in "$@"
    do  
        echo " $i : $arg "
        message+="/$i"
        i=$(($i+1))
        done
    echo $message
}

##### fonction pour créer un compte --> ajout_utilisateur()
function ajout_utilisateur() {
    # Demander le nom d'utilisateur
    read -p "Quel est le nom d'utilisateur ? " nom_utilisateur

    # Vérifier si l'utilisateur existe déjà
    if grep "$nom_utilisateur:" /etc/passwd > /dev/null
    then
        echo "Utilisateur $nom_utilisateur existe déjà."
        exit 1
    fi

    # Demander la confirmation de la création du compte
    read -p "Confirmation de la création du compte [o/n] : " confirmation

    if [ "$confirmation" == "o" ]
    then
    sudo useradd "$nom_utilisateur"
    
    else
        echo "Création de compte annulée."
        exit 1
    fi

    # Vérifier si l'utilisateur a été créé correctement

    if grep "$nom_utilisateur:" /etc/passwd > /dev/null
    then
            echo "Utilisateur $nom_utilisateur a été créé."
        else
            echo "Utilisateur $nom_utilisateur n'a pas créé."
            exit 1
        fi

    # Demander si l'utilisateur doit être associé à un groupe existant
    read -p "Associer l'utilisateur à un groupe déjà existant [o/n] ? " associer_groupe
        if [ "$associer_groupe" == "o" ]
        then
        read -p "Entrez le nom du groupe : " nom_groupe

        # Vérifier si le groupe existe avant d'ajouter l'utilisateur
        if grep "$nom_groupe:" /etc/group > /dev/null
        then
        sudo usermod -aG "$nom_groupe" "$nom_utilisateur"
        echo "Utilisateur $nom_utilisateur ajouté au groupe $nom_groupe."
        else
            echo "Le groupe $nom_groupe n'existe pas."
        fi
    fi  
}

##### fonction pour changer de mdp --> change_mdp()

##### fonction pour supprimer un compte --> supp_utilisateur()

##### fonction pour désactiver un compte --> desact_utilisateur()

##### fonction pour ajouter un utilisateur à un groupe --> ajout_groupe()

##### fonction pour sortir un utilisateur d'un groupe --> sortie_groupe()

############################################################################################################################

##### fonction pour gérer les actions concernant un utilisateur --> action_utilisateur()
function action_utilisateur() {
	menu "Création de compte utilisateur local" "Changement de mot de passe" "Suppression de compte utilisateur local" "Désactivation de compte utilisateur local" "Ajout à un groupe local" "Sortie d'un groupe local"
	read rep_action_utilisateur
	case $rep_action_utilisateur in 

    		0) echo "Fin du script"
    		exit 0;; # sortie du script

    		1) echo ajout_utilisateur;; # fonction pour créer un compte

    		2) echo change_mdp;; # fonction pour changer de mdp

    		3) echo supp_utilisateur;; # fonction pour supprimer un compte

    		4) echo desact_utilisateur;; # fonction pour désactiver un compte

    		5) echo ajout_groupe;; # fonction pour ajouter un utilisateur à un groupe

    		6) echo sortie_groupe;; # fonction pour sortir un utilisateur d'un groupe

    		*) echo "Erreur de saisie, veuillez recommencer"
    		sleep 1
    		action_utilisateur;;
	esac
}

#### fonction pour gérer les actions concernant un ordinateur client --> action_ordinateur()
function action_ordinateur() {
	menu "Arrêt" "Redémarrage" "Verrouillage" "Mise-à-jour du système" "Création de répertoire" "Modification de répertoire" "Suppression de répertoire" "Prise de main à distance (CLI)" "Définition de règles de pare-feu" "Activation du pare-feu" "Désactivation du pare-feu" "Installation de logiciel" "Désinstallation de logiciel" "Exécution de script sur la machine distante"
	read rep_action_ordinateur
	case $rep_action_ordinateur in 
		0) echo "Fin du script"
    		exit 0;; # sortie du script
		
		1) echo arret;; # fonction pour arrêter un PC
		
		2) echo redemarrage;; # fonction pour redemarrer un PC
		
		3) echo verrouillage;; # fonction pour verrouiller un PC
		
		4) echo maj;; # fonction pour mettre à jour un PC
		
		5) echo crea_rep;; # fonction pour créer un répertoire
		
		6) echo modif_rep;; # fonction pour modifier un répertoire
		
		7) echo supp_rep;; # fonction pour supprimer un répertoire
		
		8) echo cli;; # fonction pour prise de main CLI
		
		9) echo def_parefeu;; # fonction pour définir les règles de pare-feu
		
		10) echo act_parefeu;; # fonction pour activer le pare-feu
		
		11) echo desact_parefeu;; # fonction pour désactiver le pare-feu
		
		12) echo install_logi;; # fonction pour installer un logiciel
		
		13) echo desinstall_logi;; # fonction pour désinstalle un logiciel
		
		14) echo exec_script;; # fonction pour exécuter un script sur une machine distante
		
		*) echo "Erreur de saisie, veuillez recommencer"
		sleep 1
		action_ordinateur;;
		
	esac
}

#### fonction pour gérer les informations sur les utilisateurs --> info_utilisateur()

#### fonction pour gérer les informations sur les ordinateurs clients --> info_ordinateur()

#### fonction pour gérer les informations sur le script --> info_script()


####################################################################################################################################

# fonction qui gère les informations sur l'utilisateur --> info_utilisateur()
function info_utilisateur() {
	menu "Date de dernière connexion d’un utilisateur" "Date de dernière modification du mot de passe" "Liste des sessions ouvertes par l'utilisateur" "Groupe d’appartenance d’un utilisateur" "Historique des commandes exécutées par l'utilisateur" "Droits/permissions de l’utilisateur sur un dossier" "Droits/permissions de l’utilisateur sur un fichier"
	read rep_info_utilisateur
	case $rep_info_utilisateur in 
		0) echo "Fin du script"
    		exit 0;; # sortie du script
    		
		1) echo date_co;; # fonction pour extraire la date de dernière connexion d’un utilisateur
		
		2) echo date_modif_mdp;; # fonction pour extraire la Date de dernière modification du mot de passe
		
		3) echo liste_session;; # fonction pour Lister les sessions ouvertes par l'utilisateur
		
		4) echo groupe_utilisateur;; # fonction pour savoir groupe d’appartenance d’un utilisateur
		
		5) echo historique_commande;; # fonction pour avoir l'historique de commande de l'utilisateur
		
		6) echo droit_dossier;; # fonction pour connaître les droits d'un utilisateur sur un dossier
		
		7) echo droit_fichier;; # fonction pour connaître les droits d'un utilisateur sur un fichier
		
		*) echo "Erreur de saisie, veuillez recommencer"
		sleep 1
		info_utilisateur;;
	
	esac
}

# fonction qui gère les informations sur l'ordinateur client --> info_ordinateur()
function info_ordinateur() {
	menu "Version de l'OS" "Nombre de disque" "Partition (nombre, nom, FS, taille) par disque" "Liste des applications/paquets installées" "Liste des services en cours d'execution" "Liste des utilisateurs locaux" "Type de CPU, nombre de coeurs, etc." "Mémoire RAM totale" "Utilisation de la RAM" "Utilisation du disque" "Utilisation du processeur"
	read rep_info_ordinateur
	case $rep_info_ordinateur in 
		
		0) echo "Fin du script"
    		exit 0;; # sortie du script
    		
		1) echo version_os;; # fonction pour avoir la version de l'OS
		
		2) echo nbr_disque;; # fonction pour savoir le nombre de disque
		
		3) echo partition;; # fonction pour avoir les partitions par disque
		
		4) echo liste_application;; # fonction pour Lister les applications/paquets installés
		
		5) echo liste_service;; # fonction pour lister les services en cours d'exécution
		
		6) echo liste_utilisateur;; # fonction pour lister les utilisateurs locaux
		
		7) echo info_cpu;; # fonction pour connaître le type de CPU
		
		8) echo info_ram;; # fonction pour connaître le nombre de RAM
		
		9) echo utilisation_ram;; # fonction pour connaître la quantité de RAM utilisée
		
		10) echo utilisation_disque;; # fonction pour connaître la quantité de disque utilisée
		
		11) echo utilisation_cpu;; # fonction pour connaître la quantité de processeurs utilisée
		
		*) echo "Erreur de saisie, veuillez recommencer"
		sleep 1
		info_ordinateur;;
		
	esac
}

# fonction qui gère les informations sur le script --> info_script()
function info_script() {
	menu "Recherche des événements dans le fichier log_evt.log pour un utilisateur" "Recherche des événements dans le fichier log_evt.log pour un ordinateur"
	read rep_info_script
	case $rep_info_script in 
		0) echo "Fin du script"
    		exit 0;; # sortie du script
    		
		1) echo recherche_utilisateur;; # fonction pour rechercher des événements dans le fichier log_evt.log pour un utilisateur
		
		2) echo recherche_ordinateur;; # fonction pour rechercher des événements dans le fichier log_evt.log pour un ordinateur
		
		*) echo "Erreur de saisie, veuillez recommencer"
		sleep 1
		info_script;;
		
	esac
}

####################################################################################################################################
#### Début du Script principal
echo "Début du script - Gestion à distance"
#ajout_log "Lancement du script"
menu "Effectuer une action" "Récupérer une information"
read rep_principale
 
# Traitement de la réponse
while true;
do
	case $rep_principale in
		0) #ajout_log "Arrêt du script"
		exit 0 ;;   #fin du script
		
		1) menu "Une action concernant un utilisateur" "Une action concernant un ordinateur client"
		read rep_action
       		case $rep_action in
       			0) echo "Fin du script"
			exit 0;; # sortie du script
			
			1) action_utilisateur
			exit 0;;
			
			2) action_ordinateur
			exit 0;;
			
			*) echo "Erreur de saisie, veuillez recommencer"
			sleep 1
			continue;;
		esac;;
		
		2) menu "Une information sur un utilisateur" "Une information sur un ordinateur client" "Une information sur le Script"
       		read rep_info
       		case $rep_info in 
            		O) echo "Fin du script"
    			exit 0;; # sortie du script
    		
            		1) info_utilisateur
            		exit 0;;

            		2) info_ordinateur
            		exit 0;;

            		3) info_script
            		exit 0;;

            		*) echo "Erreur de saisie, veuillez recommencer"
            		sleep 1
            		continue;;

        	esac;;

    		*) echo "Erreur de saisie, veuillez recommencer"
    		sleep 1
    		./script.sh;;
    
	esac
done
exit 0
