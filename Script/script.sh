#!/bin/bash
############################################
####### Script - Gestion à distance ########
######## Groupe 3 - Projet 2 - 2024 ########
############################################

#### fonction pour se connecter à distance ??? SSH ???

##### fonction pour gérer le log -> ajout_log()
#Prend en argument un texte et l'ajoute avec date/user/... dans le bon fichier

##### fonction pour gérer l'affichage du menu
# Les choix correspondent aux arguments donnés.
##### fonction pour gérer l'affichage d'un menu
# Les arguments sont les différents choix.
function menu() {
    clear
    message="Entrez votre choix : 0"
    echo "Que voulez vous faire ? "
    echo " 0 : Retour"
    i=1
    for arg in "$@"
    do  
        echo " $i : $arg "
        message+="/$i"
        i=$(($i+1))
        done
    echo $message
]

##### fonction pour créer un compte --> ajout_utilisateur()

##### fonction pour changer de mdp --> change_mdp()

##### fonction pour supprimer un compte --> supp_utilisateur()

##### fonction pour désactiver un compte --> desact_utilisateur()

##### fonction pour ajouter un utilisateur à un groupe --> ajout_groupe()

##### fonction pour sortir un utilisateur d'un groupe --> sortie_groupe()

###################################################################################################################################

##### fonction pour gérer les actions concernant un utilisateur --> action_utilisateur()
menu "Création de compte utilisateur local" "Changement de mot de passse" "Suppression de compte utilisateur local" "Désactivation de compte utilisateur local" "Ajout à un groupe local" "Sortie d'un groupe local"
read rep_action_utilisateur
case $rep_action_utilisateur in 

    0) #Retour au menu précédent

    1) ajout_utilisateur # fonction pour créer un compte

    2) change_mdp # fonction pour changer de mdp

    3) supp_utilisateur # fonction pour supprimer un compte

    4) desact_utilisateur # fonction pour désactiver un compte

    5) ajout_groupe # fonction pour ajouter un utilisateur à un groupe

    6) sortie_groupe # fonction pour sortir un utilisateur d'un groupe

    *) afficher "Erreur de saisie, veuillez recommencer"

fin

#### fonction pour gérer les actions concernant un ordinateur client --> action_ordinateur()
menu "Arrêt" "Redémarrage" "Verrouillage" "Mise-à-jour du système" "Création de répertoire" "Modification de répertoire" "Suppression de répertoire" "Prise de main à distance (CLI)" "Définition de règles de pare-feu" "Activation du pare-feu" "Désactivation du pare-feu" "Installation de logiciel" "Désinstallation de logiciel" "Exécution de script sur la machine distante"
read rep_action_ordinateur
case $rep_action_ordinateur in 
    0) #Retour au menu précédent

    1) arret # fonction pour arrêter un PC

    2) redemarrage # fonction pour redemarrer un PC

    3) verrouillage # fonction pour verrouiller un PC

    4) maj # fonction pour mettre à jour un PC

    5) crea_rep # fonction pour créer un répertoire

    6) modif_rep # fonction pour modifier un répertoire

    7) supp_rep # fonction pour supprimer un répertoire

    8) cli # fonction pour prise de main CLI

    9) def_parefeu # fonction pour définir les règles de pare-feu

    10) act_parefeu # fonction pour activer le pare-feu

    11) desact_parefeu # fonction pour désactiver le pare-feu

    12) install_logi # fonction pour installer un logiciel

    13) desinstall_logi # fonction pour désinstalle un logiciel
    
    14) exec_script # fonction pour exécuter un script sur une machine distante

    *) afficher "Erreur de saisie, veuillez recommencer"

fin

#### fonction pour gérer les informations sur les utilisateurs --> info_utilisateur()

#### fonction pour gérer les informations sur les ordinateurs clients --> info_ordinateur()

#### fonction pour gérer les informations sur le script --> info_script()


####################################################################################################################################

# fonction qui gère les informations sur l'utilisateur --> info_utilisateur()
menu "Date de dernière connexion d’un utilisateur" "Date de dernière modification du mot de passe" "Liste des sessions ouvertes par l'utilisateur" "Groupe d’appartenance d’un utilisateur" "Historique des commandes exécutées par l'utilisateur" "Droits/permissions de l’utilisateur sur un dossier" "Droits/permissions de l’utilisateur sur un fichier"
read rep_info_utilisateur
case $rep_info_utilisateur in 
    0) #Retour au menu précédent

    1) date_co # fonction pour extraire la date de dernière connexion d’un utilisateur

    2) date_modif_mdp # fonction pour extraire la Date de dernière modification du mot de passe

    3) liste_session # fonction pour Lister les sessions ouvertes par l'utilisateur

    4) groupe_utilisateur # fonction pour savoir groupe d’appartenance d’un utilisateur

    5) historique_commande # fonction pour avoir l'historique de commande de l'utilisateur

    6) droit_dossier # fonction pour connaître les droits d'un utilisateur sur un dossier

    7) droit_fichier # fonction pour connaître les droits d'un utilisateur sur un fichier

    *) afficher "Erreur de saisie, veuillez recommencer"

fin

# fonction qui gère les informations sur l'ordinateur client --> info_ordinateur_client()
menu "Version de l'OS" "Nombre de disque" "Partition (nombre, nom, FS, taille) par disque" "Liste des applications/paquets installées" "Liste des services en cours d'execution" "Liste des utilisateurs locaux" "Type de CPU, nombre de coeurs, etc." "Mémoire RAM totale" "Utilisation de la RAM" "Utilisation du disque" "Utilisation du processeur"
read rep_info_ordinateur
case $rep_info_ordinateur in 
    0) #Retour au menu précédent

    1) version_os # fonction pour avoir la version de l'OS

    2) partition # fonction pour avoir les partitions par disque

    3) liste_application # fonction pour Lister les applications/paquets installés

    4) lsite_service # fonction pour lister les services en cours d'exécution

    5) liste_utilisateur # fonction pour lister les utilisateurs locaux

    6) info_cpu # fonction pour connaître le type de CPU

    7) info_ram # fonction pour connaître le nombre de RAM

    8) utilisation_ram # fonction pour connaître la quantité de RAM utilisée

    9) utilisation_disque # fonction pour connaître la quantité de disque utilisée

    10) utilisation_cpu # fonction pour connaître la quantité de processeurs utilisée


    *) afficher "Erreur de saisie, veuillez recommencer"

fin

# fonction qui gère les informations sur le script --> info_script()
menu "Recherche des evenements dans le fichier log_evt.log pour un utilisateur" "Recherche des evenements dans le fichier log_evt.log pour un ordinateur"
read rep_info_script
case $rep_info_script in 
    0) #Retour au menu précédent

    1) recherche_utilisateur # fonction pour echercher des evenements dans le fichier log_evt.log pour un utilisateur

    2) recherche_ordinateur # fonction pour echercher des evenements dans le fichier log_evt.log pour un ordinateur

    *) afficher "Erreur de saisie, veuillez recommencer"

fin

####################################################################################################################################
#### Début du Script principal
afficher "Début du script - Gestion à distance"
ajout_log "Lancement du script"
menu "Effectuer une action" "Récupérer une information"
read rep_principale
 
# Traitement de la réponse
case $rep_principale in
    0) ajout_log "Arrêt du script";; exit 0   #fin du script

    1) menu "Une action concernant un utilisateur" "Une action concernant un ordinateur client"
       read rep_action
       case $rep_action in
            0) #retour au menu précédent

            1) action_utilisateur;;

            2) action_ordinateur;;

            *) afficher "Erreur de saisie, veuillez recommencer"

        fin

    2) menu "Une information sur un utilisateur" "Une information sur un ordinateur client" "Une information sur le Script"
       read rep_info
       case rep_info in 
            O) #retour au menu précédent

            1) info_utilisateur;;

            2) info_ordinateur;;

            3) info_script;;;

            *)afficher "Erreur de saisie, veuillez recommencer"

        fin

    *) afficher "Erreur de saisie, veuillez recommencer"
    fin
fin
