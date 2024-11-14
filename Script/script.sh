#!/bin/bash

#################################################################################################
#######                               Script - Gestion à distance                        ########
#######                               Groupe 3 - Projet 2 - 2024                         ########
#######                             Lamine - Sam - Charlène - Arnauld                    ########
#################################################################################################
#######      Script permettant d'effectuer des actions sur des machines distantes        ########
#################################################################################################



#------------------------------------------------------------------------------------------------#
#                                         Initialisation                                         #
#------------------------------------------------------------------------------------------------#

# Le compte utilisateur dédié à la connexion SSH sur chaque machine distante
user_ssh="utilisateur_ssh"
# Le préfixe du réseau de votre serveur
network_prefix="172.16.30."
# Le chemin vers le dossier du fichier de jorunalisation
path="/var/log" 


#------------------------------------------------------------------------------------------------#
#                                      Fonctions annexes                                         #
#------------------------------------------------------------------------------------------------#

##### fonction pour gérer le log du script
## Prend en argument un texte et l'ajoute avec date/user/... dans le bon fichier
function addLog() {
    ## vérifie que le fichier existe et l'initialise si ce n'est pas le cas
    if ! [ -e $path/log_evt.log ]
    then
        touch $path/log_evt.log
        echo "# Journal des activités de script.sh" > $path/log_evt.log
    fi

    ## ajoute l'entrée sous le format YYYYMMDD-HHMMSS-Utilisateur-Événement
    echo "$(date +"%Y%m%d - %H%M%S") - $SUDO_USER - $1" >> $path/log_evt.log     
    ## remplacer $SUDO_USER par $(whoami) si pas besoin de lancer le script en sudo 
}


#### fonction pour tester la connexion SSH avec l'ordinateur ciblé, vers un compte dédié $user_SSH
## Prend en argument l'adresse IP de l'ordinateur ciblé
function testSSH() {
    ## Vérification si la saisie est bien une adresse dans le réseau
    if [[ ! $1 =~ ($network_prefix)(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?) ]]
    then 
		echo "L'adresse IP n'est pas valide ou n'appartient pas au réseau "$network_prefix"0. "
	return 1
	## test pour savoir si la connexion se fait
    elif ssh $user_ssh@$1 echo "Hello World" > /dev/null
    then 
		echo "Connexion réussie à l'ordinateur $1 "
		addLog "Connexion SSH avec l'ordinateur $1 "
		return 0
    else 
		echo "Echec de la connexion, veuillez vérifier votre configuration "
		echo "Fin du script"
		sleep 2
		addLog "Echec de la connexion SSH avec l'ordinateur $1 "
		addLog "*********EndScript*********"
		exit 1
    fi
}


##### fonction pour gérer l'affichage d'un menu
## Les arguments sont les différents choix.
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

##### Fonction pour demander le mot de passe sudo
function passwordSudo() {
	echo "Ce script va utiliser le sudo pour certaines de vos demandes. Merci de rentrer le mot de passe du compte $user_ssh de la machine $address_ip, si vous êtes sûrs de votre choix."
	echo "Mot de passe : "
}

#------------------------------------------------------------------------------------------------#
#                    Fonctions d'actions et de demande d'informations                            #
#------------------------------------------------------------------------------------------------#


##### fonction pour créer un compte utilisateur local sur une machine distante
function addUser() {
	## Demander le nom d'utilisateur
	read -p "Quel est le nom d'utilisateur ? " user_name
	## Vérifier si l'utilisateur existe déjà
	if ssh $user_ssh@$address_ip "grep $user_name: /etc/passwd" > /dev/null
	then
		echo "Utilisateur $user_name existe déjà."
		return 1
	else 
		ssh $user_ssh@$address_ip "sudo -S useradd $user_name"
	fi
	## Vérifier si l'utilisateur a été créé correctement
	if ssh $user_ssh@$address_ip "grep $user_name: /etc/passwd" > /dev/null
	then
		echo "L'utilisateur $user_name a été créé."
		addLog "Réussite de la création de l'utilisateur local $user_name sur la machine $address_ip"
		return 0
    else
        echo "L'utilisateur $user_name n'a pas créé."
		addLog "Echec de la création de l'utilisateur local $user_name sur la machine $address_ip"
        return 1
    fi
}


##### fonction pour changer le mot de passe d'un compte local sur une machine distante
function changePassword() {    
	## Demande les informations de changement de mot de passe
	read -p "Entrez le nom d'utilisateur pour changer le mot de passe : " user_name
	read -s -p "Entrez le nouveau mot de passe : " password 
	## Changement + vérification de la réussite
	ssh $user_ssh@$address_ip "echo $user_name:$password | sudo -S chpasswd" > /dev/null
	if $?
	then 
		echo " La modification de mot de passe a été effectuée pour $user_name."
		addLog "Réussite du changement de mot de passe pour l'utilisateur local $user_name sur la machine $address_ip"
		return 0
	else 
		echo " La modification de mot de passe a échoué pour $user_name."
		addLog "Échec du changement de mot de passe pour l'utilisateur local $user_name sur la machine $address_ip"
		return 1
	fi    		
}

##### fonction pour changer le mot de passe d'un compte local sur une machine distante
function removeUser() {
	read -p "Entrez le nom de l'utilisateur à supprimer : " user_name
	if ssh $user_ssh@$address_ip "id $user_name" >/dev/null
	then
		ssh $user_ssh@$address_ip "sudo userdel $user_name"
		echo "L'utilisateur $user_name a été supprimé."
		addLog "Réussite de la suppression de l'utilisateur local $user_name sur la machine $address_ip"
    else
		echo "L'utilisateur $user_name n'existe pas."
		addLog "Réussite de la suppression de l'utilisateur local $user_name sur la machine $address_ip"
    fi
}

##### fonction pour désactiver un compte local sur une machine distante
function disableUser() {
	read -p "Entrez le nom de l'utilisateur dont vous souhaitez désactiver le compte:" user_name
	ssh $user_ssh@$address_ip "sudo usermod -L $user_name"
	if $?
	then
		echo "Le compte de $user_name est desactivé"
		addLog "Réussite de la désactivation de l'utilisateur local $user_name sur la machine $address_ip"
	else
		echo "Le compte de $user_name n'a pas été desactivé"
		addLog "Échec de la désactivation de l'utilisateur local $user_name sur la machine $address_ip"
	fi
}


##### fonction pour ajouter un utilisateur local d'une machine distante à un groupe local
function addGroup() {
	read -p "Entrez le nom de l'utilisateur : " user_name
	if ! ssh $user_ssh@$address_ip "grep $user_name: /etc/passwd" > /dev/null
	then
	echo "L'utilisateur $user_name n'existe pas"
	addLog "Échec de l'ajout de l'utilisateur local $user_name à un groupe sur la machine $address_ip"
	return 1
	fi
    read -p "Entrez le nom du groupe : " group_name
    ## Vérifier si le groupe existe avant d'ajouter l'utilisateur
    if ssh $user_ssh@$address_ip "grep $group_name: /etc/group" > /dev/null
    then
	## Ajout + vérification de l'ajout
		if ssh $user_ssh@$address_ip "sudo -S usermod -aG $group_name $user_name"
		then
			echo "L'utilisateur $user_name a été ajouté au groupe $group_name."
			addLog "Réussite de l'ajout de l'utilisateur local $user_name au groupe $group_name sur la machine $address_ip"
			return 0
		else 
			echo "L'utilisateur $user_name n'a pas été ajouté au groupe $group_name."
			addLog "Échec de l'ajout de l'utilisateur local $user_name au groupe $group_name sur la machine $address_ip"
			return 1
		fi
    else
		echo "Le groupe $group_name n'existe pas."
		addLog "Échec de l'ajout de l'utilisateur local $user_name au groupe $group_name sur la machine $address_ip"
		return 1
    fi
}


##### fonction pour sortir un utilisateur local sur une machine distante d'un groupe local
function exitGroup() {
	read -p "Entrez le nom de l'utilisateur : " user_name
	if ! ssh $user_ssh@$address_ip "grep $user_name: /etc/passwd" > /dev/null
	then
		echo "L'utilisateur $user_name n'existe pas"
		addLog "Échec de la sortie de l'utilisateur local $user_name d'un groupe sur la machine $address_ip"
		return 1
	fi
    read -p "Entrez le nom du groupe : " group_name
    ## Vérifier si le groupe existe et que l'utilisateur fait partie du groupe
    if ssh $user_ssh@$address_ip "grep $group_name: /etc/group | grep $user_name" > /dev/null
	then
		## Sortie + vérification de la sortie
		if ssh $user_ssh@$address_ip "sudo -S gpasswd -d  $user_name $group_name"
		then
			echo "L'utilisateur $user_name a été retiré du groupe $group_name."
			addLog "Réussite de la sortie de l'utilisateur local $user_name du groupe $group_name sur la machine $address_ip"
			return 0
		else 
			echo "L'utilisateur $user_name n'est pas sorti du groupe $group_name."
			addLog "Échec de la sortie de l'utilisateur local $user_name du groupe $group_name sur la machine $address_ip"
			return 1
		fi
    else
		echo "Le groupe $group_name n'existe pas ou l'utilisateur $user_name n'en fait pas partie."
		addLog "Échec de la sortie de l'utilisateur local $user_name du groupe $group_name sur la machine $address_ip"
		return 1
    fi
}

##### fonction pour rechercher dans le journal du script
## Prend en argument soit "utilisateur local" soit "ordinateur client
function searchLog() {
    read -p "Quel $1 voulez-vous rechercher ? " target_name
    while [ -z target_name ]; do read -p "Quel $1 voulez-vous rechercher ? " target_name; done
    read -p "Voulez vous chercher une date en particulier ? (au format YYYYMMJJ) " date
    read -p "Voulez-vous chercher un mot clé en particulier ? " keyword
    if [ -z $date ]
    then
        if [ -z $keyword ]
        then
            cat $path/log_evt.log | grep -i $target_name 2> /dev/null
            addLog "Consultation de la journalisation du script concernant l'$1 $target_name"
        else
            cat $path/log_evt.log | grep -i $target_name | grep -i $keyword 2> /dev/null
            addLog "Consultation de la journalisation du script concernant l'$1 $target_name avec le filtre $keyword"
        fi
    else 
        if [ -z $keyword ]
        then
            cat $path/log_evt.log | grep -i $target_name | grep -i $date 2> /dev/null
            addLog "Consultation de la journalisation du script concernant l'$1 $target_name à la date $date"
        else
            cat $path/log_evt.log | grep -i $target_name | grep -i $date | grep -i $keyword 2> /dev/null
            addLog "Consultation de la journalisation du script concernant l'$1 $target_name à la date $date avec le filtre $keyword"
        fi
    fi
    sleep 2
}



#------------------------------------------------------------------------------------------------#
#                          Fonctions pour gérer les 4 sous-menus                                 #
#------------------------------------------------------------------------------------------------#

##### fonction pour gérer les actions concernant un utilisateur
function actionUser() {
	menu "Création de compte utilisateur local" "Changement de mot de passe" "Suppression de compte utilisateur local" "Désactivation de compte utilisateur local" "Ajout à un groupe local" "Sortie d'un groupe local" "Retour"
	read ans_action_user
	case $ans_action_user in 

		0) ## Fin du script
		echo "Fin du script"
		addLog "*********EndScript*********"
		exit 0;; 

		1) ## Choix de "Création de compte utilisateur local"
		addLog "Choix de 'Création de compte utilisateur local'"
		addUser
		sleep 3;;

		2) ## Choix de "Changement de mot de passe"
		addLog "Choix de 'Changement de mot de passe'"
		changePassword
		sleep 3;;

		3) ## Choix de "Suppression de compte utilisateur local"
		addLog "Choix de 'Suppression de compte utilisateur local'"
		removeUser
		sleep 3;;

		4) ## Choix de "Désactivation de compte utilisateur local"
		addLog "Choix de 'Désactivation de compte utilisateur local'"
		disableUser
		sleep 3;;

		5) ## Choix de "Ajout à un groupe local"
		addLog "Choix de 'Ajout à un groupe local'"
		addGroup
		sleep 3;;

		6) ## Choix de "Sortie d'un groupe local"
		addLog "Choix de 'Sortie d'un groupe local'"
		exitGroup
		sleep 3;; 

		7) ### Retour au menu précédent
		addLog "Retour au menu précédent"
		break 1;;

		*) ## Erreur de saisie
		echo "Erreur de saisie, veuillez recommencer"
		addLog "Échec de saisie, retour au menu 'Action concernant un utilisateur local'"
		sleep 1
		actionUser;;
	esac
}


#### fonction pour gérer les actions concernant un ordinateur client
function actionComputer() {
	menu "Arrêt" "Redémarrage" "Verrouillage" "Mise-à-jour du système" "Création de répertoire" "Modification de répertoire" "Suppression de répertoire" "Définition de règles de pare-feu" "Activation du pare-feu" "Désactivation du pare-feu" "Installation de logiciel" "Désinstallation de logiciel" "Retour"
	read ans_action_computer
	case $ans_action_computer in 
		0) ## Fin du script
		echo "Fin du script"
		addLog "*********EndScript*********"
		exit 0;; 
		
		1) ## Choix de "Arrêt de l'ordinateur $address_ip"
		addLog "Choix de 'Arrêt de l'ordinateur $address_ip'"
		if ssh -t $user_ssh@$address_ip "sudo shutdown -h now"
		then
			echo "L'ordinateur $address_ip est arrêté."
			addLog "Réussite de l'arrêt  de l'ordinateur $address_ip"
		else
			echo "L'ordinateur $address_ip ne s'est pas arrêté."
			addLog "Échec de l'arrêt  de l'ordinateur $address_ip"
		fi
		sleep 3;;
		
		2) ## Choix de "Redémarrage de l'ordinateur $address_ip"
		addLog "Choix de 'Redémarrage de l'ordinateur $address_ip'"
		if ssh -t $user_ssh@$address_ip 'sudo reboot'
		then
			echo "L'ordinateur $address_ip a redemarré."
			addLog "Réussite du redémarrage de l'ordinateur $address_ip"
		else
			echo "L'ordinateur $address_ip n'a pas redemarré."
			addLog "Échec du redémarrage de l'ordinateur $address_ip"
		fi
		sleep 3;;
		
		3) ## Choix de "Verrouillage de l'ordinateur $address_ip"
		addLog "Choix de 'Verrouillage de l'ordinateur $address_ip'"
		if ssh -t $user_ssh@$address_ip "sudo systemctl suspend"
		then
			echo "L'ordinateur $address_ip est verrouillé."
			addLog "Réussite du verrouillage de l'ordinateur $address_ip"
		else
			echo "L'ordinateur $address_ip n'a pas été verrouillé."
			addLog "Échec du verrouillage de l'ordinateur $address_ip"
		fi
		sleep 3;;
		
		4) ## Choix de "Mise à jour du système de l'ordinateur $address_ip"
		addLog "Choix de 'Mise à jour du système de l'ordinateur $address_ip'"
		if ssh $user_ssh@$address_ip "sudo apt update && sudo apt upgrade -y"
		then
			echo "L'ordinateur $address_ip est mis à jour."
			addLog "Réussite de la mise à jour du système de l'ordinateur $address_ip'"
		else
			echo "L'ordinateur $address_ip n'a pas été mis à jour."
			addLog "Échec de la mise à jour du système de l'ordinateur $address_ip'"
		fi
		sleep 3;;
		
		5) ## Choix de "Création d'un répertoire sur l'ordinateur $address_ip"
		addLog "Choix de 'Création d'un répertoire sur l'ordinateur $address_ip'"
		read -p "Entrez l'endroit où vous voulez créer le nouveau dossier : " rep_path
		while [ -z $rep_path ]
		do
			read -p "Saisie vide. Entrez l'endroit où vous voulez créer le nouveau dossier : " rep_path
		done
		read -p "Entrez le nom du dossier à créer: " rep_name
		if ssh -t $user_ssh@$address_ip "sudo mkdir -p $rep_path/$rep_name" 2> /dev/null
		then
			echo "Création du répertoire $rep_name réussie."
			addLog "Réussite de la création du dossier $rep_name dans $rep_path de l'ordinateur $address_ip"
		else
			echo "$rep_name existe dejà dans $rep_path"
			addLog "Échec de la création du dossier $rep_name dans $rep_path de l'ordinateur $address_ip"
		fi
		sleep 3;;
		
		6) ## Choix de "Modification d'un répertoire de l ordinateur $address_ip"
		addLog "Choix de 'Modification d'un répertoire de l ordinateur $address_ip'"
		while ! ssh $user_ssh@$address_ip "[ -d $rep_path/$rep_name ]" 2> /dev/null
		do
			read -p "Entrez le nom du dossier : " rep_name
			read -p "Entrez le dossier dans lequel $rep_name se trouve (chemin absolu) :" rep_path
		done
		read -p  "Souhaitez-vous renommer ou déplacer votre dossier ? Tapez 1 pour renommer, 2 pour déplacer " ans_modify
		case $ans_modify in
			1)  ## Pour renommer
			read -p "Entrez le nouveau nom : " rep_newname
			ssh $user_ssh@$address_ip "sudo mv $rep_path/$rep_name $rep_path/$rep_newname"
			echo "Le dossier $rep_name a été renommé en $rep_newname"
			addLog "Réussite du renommage du dossier $rep_name en $rep_newname sur l'ordinateur client $address_ip";;
			2) ## Pour déplacer
			read -p "Entrez le nouveau chemin absolu : " rep_newpath
			ssh $user_ssh@$address_ip "sudo mv $rep_path/$rep_name $rep_newpath/$rep_name"
			echo "Le dossier $rep_name a été déplacé en dans le dossier $rep_newpath"
			addLog "Réussite du déplacement du dossier $rep_name vers $rep_newpath sur l'ordinateur client $address_ip";;
			*) ## Erreur de saisie
			echo "Erreur de saisie, échec de la modification du dossier"
			addLog "Échec de la modification du dossier $rep_name sur l'ordinateur client $address_ip";;
		esac
		sleep 3;;
		
		7) ## Choix de "Suppression d'un répertoire de l'ordinateur $address_ip"
		addLog "Choix de 'Suppression d'un répertoire de l'ordinateur $address_ip'"
		while [ -z $rep_path ]
		do
			read -p "Entrez le nom du dossier avec son chemin absolu : " rep_path
		done
		if ssh -t $user_ssh@$address_ip "sudo rm -r $rep_path"
		
		then
			echo "Suppression du répertoire $rep_path réussie."
			addLog "Réussite de la suppression du dossier $rep_path de l'ordinateur $address_ip"
		else
			echo "Erreur lors de la suppression"
			addLog "Échec de la suppression du dossier $rep_path de l'ordinateur $address_ip"
		fi
		sleep 3;;
		
		8) ## Choix de "Définitions de règles de pare-feu de l'ordinateur $address_ip"
		addLog "Choix de 'Définitions de règles de pare-feu de l'ordinateur $address_ip'"
		read -p "Voulez-vous autoriser ou refuser le HTTP sur le port 80 ? 1 pour autoriser, 2 pour refuser " ans_firewall
		case $ans_firewall in
			1) # Pour autoriser
			if ssh $user_ssh@$address_ip "sudo ufw allow 80"
			then
				echo "Le port 80 est autorisé sur la machine $address_ip"
				addLog "Réussite de l'autorisation de l'utilisation du port 80 sur l'ordinateur client $address_ip"
			else
				echo "Le port 80 n'a pas été autorisé sur la machine $address_ip"
				addLog "Échec de l'autorisation de l'utilisation du port 80 sur l'ordinateur client $address_ip"
			fi;;
	
			2) # Pour refuser
			if ssh $user_ssh@$address_ip "sudo ufw deny 80"
			then
				echo "Le port 80 est refusé sur la machine $address_ip"
				addLog "Réussite du refus de l'utilisation du port 80 sur l'ordinateur client $address_ip"
			else
				echo "Le port 80 est refusé sur la machine $address_ip"
				addLog "Réussite du refus de l'utilisation du port 80 sur l'ordinateur client $address_ip"
			fi;;
			*) # Erreur de saisie
			echo "Erreur de saisie, échec du changement"
			addLog "Échec du changement de l'utilisation du port 80 sur l'ordinateur client $address_ip";;
		esac
		sleep 3;;
		
		9) ## Choix de "Activation du pare-feu de l'ordinateur $address_ip"
		addLog "Choix de 'Activation du pare-feu de l'ordinateur $address_ip'"
		if ssh $user_ssh@$address_ip "sudo ufw enable"
		then
			echo "Le pare-feu de la machine $address_ip a été activé."
			addLog "Réussite de l'activation du pare-feu de l'ordinateur $address_ip'"
		else
			echo "Le pare-feu de la machine $address_ip n'a pas été activé."
			addLog "Échec de l'activation du pare-feu de l'ordinateur $address_ip'"
		fi
		sleep 3;;

		10) ## Choix de "Désactivation du pare-feu de l'ordinateur $address_ip"
		addLog "Choix de 'Désactivation du pare-feu de l'ordinateur $address_ip'"
		if ssh $user_ssh@$address_ip "sudo ufw disable"
		then
			echo "Le pare-feu de la machine $address_ip a été désactivé."
			addLog "Réussite de la désactivation du pare-feu de l'ordinateur $address_ip'"
		else
			echo "Le pare-feu de la machine $address_ip n'a pas été désactivé."
			addLog "Échec de la désactivation du pare-feu de l'ordinateur $address_ip'"
		fi
		sleep 3;;

		11) ## Choix de "Installation de logiciel de l'ordinateur $address_ip"
		addLog "Choix de 'Installation de logiciel de l'ordinateur $address_ip'"
		read -p "Entrez le nom du logiciel à installer sur l'ordinateur $address_ip: " software_name
		if ssh $user_ssh@$address_ip "dpkg -s $software_name" &> /dev/null
		then
			echo -e "\033[31m$software_name est déjà installé sur l'ordinateur $address_ip"
			addLog "Échec de  l'installation du logiciel $software_name sur l'ordinateur $address_ip"
		elif ssh $user_ssh@$address_ip "sudo apt install $software_name" &> /dev/null
		then
			echo -e "\033[31m$software_name est installé sur l'ordinateur $address_ip"
			addLog "Réussite de l'installation du logiciel $software_name sur l'ordinateur $address_ip"
		else
			echo "Échec de l'installation"
			addLog "Échec de l'installation du logiciel $software_name sur l'ordinateur $address_ip"
		fi
		sleep 3;;
		
		12) ## Choix de "Désinstallation de logiciel"
		addLog "Choix de 'Désinstallation de logiciel'"
		read -p "Entrez le nom du logiciel à désinstaller sur l'ordinateur $address_ip: " software_name
		if ssh $user_ssh@$address_ip "dpkg -s $software_name" &> /dev/null
		then
			if ssh $user_ssh@$address_ip "sudo apt-get -y purge $software_name" &> /dev/null
			then
				echo -e "\033[31m$software_name est désinstallé sur l'ordinateur $address_ip"
				addLog "Réussite de la désinstallation du logiciel $software_name sur l'ordinateur $address_ip"
			else
				echo "Échec de la désinstallation"
				addLog "Échec de la désinstallation du logiciel $software_name sur l'ordinateur $address_ip"
			fi
		else
			echo -e "\033[31m$software_name n'est pas installé sur l'ordinateur $address_ip"
			addLog "Échec de  la désinstallation du logiciel $software_name sur l'ordinateur $address_ip"
		fi
		sleep 3;;

		13) ### Retour au menu précédent
		addLog "Retour au menu précédent"
		break 1;;

		*) ## Erreur de saise
		addLog "Erreur de saisie, retour au menu 'Action concernant un ordinateur client'"
		echo "Erreur de saisie, veuillez recommencer"
		sleep 1
		actionComputer;;
	esac

}

#### fonction qui gère les informations sur l'utilisateur
function infoUser() {
	## Demande quel utilisateur
	read -p "Quel est le nom d'utilisateur sur lequel vous souhaitez des informations? " user_name
	while ! ssh $user_ssh@$address_ip "grep $user_name: /etc/passwd" > /dev/null
	do
		echo "$user_name n'est pas un utilisateur local de la machine $address_ip"
		read -p "Quel est le nom d'utilisateur ? " user_name
	done
	addLog "Choix de récupérer des informations sur l'uilisateur local $user_name de l'ordinateur $address_ip"
	menu "Date de dernière connexion d’un utilisateur" "Date de dernière modification du mot de passe" "Liste des sessions ouvertes par l'utilisateur" "Groupe d’appartenance d’un utilisateur" "Historique des commandes exécutées par l'utilisateur" "Droits/permissions de l’utilisateur sur un dossier" "Droits/permissions de l’utilisateur sur un fichier" "Retour"
	echo "Si vous souhaitez plusieurs informations, écrivez les différents chiffres à la suite, avec un espace entre chaque. "
	read ans_info_user

	## chemin vers le fichier d'enregistrement d'informations
	file_info_user="/home/$SUDO_USER/info_"$user_name"_$(date +"%Y%m%d").txt"

	## sortie du script si il y a un 0, retour si il y a un 8. Création et/ou initialisation du fichier d'enregistrement si aucun des deux.
	if echo $ans_info_user | grep " 0\| 0 \|^0" > /dev/null
	then 
    ## Fin du script
        echo "Fin du script"
		addLog "*********EndScript*********"
		exit 0
	elif echo $ans_info_user | grep "8" > /dev/null
	then
	### Retour au menu précédent
		addLog "Retour au menu précédent"
		break 1
	else
		touch $file_info_user > /dev/null 2>&1 
		echo -e "####### \n# Informations sur l'utilisateur local $user_name de l'ordinateur $address_ip demandées le $(date +"%Y%m%d") à $(date +"%H:%M") \n#######\n" >> $file_info_user
	fi

	## Demande de mot de passe si besoin 
	if echo $ans_info_user | grep "2\|5 " > /dev/null
	then
		passwordSudo
		read -s password
	fi

	## Traitement de chaque réponse
	for ans in $ans_info_user
	do 
		case $ans in 
		0) ## Fin du script
		echo "Fin du script"
		addLog "*********EndScript*********"
		exit 0;; 

		1) ## Choix de "Date de dernière connexion d’un utilisateur"
		addLog "Choix de 'Date de dernière connexion de l'utilisateur'"
		echo "Date de dernière connexion de l'utilisateur : " >> $file_info_user 
		ssh $utilisateur_ssh@$address_ip "last -R $user_name | head -n 1" >> $file_info_user
		echo -e "\n " >> $file_info_user 
		addLog "Consultation de la dernière connexion de l'utilisateur local $user_name sur l'ordinateur client $address_ip";;
		
		2) ## Choix de "Date de dernière modification du mot de passe"
		addLog "Choix de 'Date de dernière modification du mot de passe de l'utilisateur'"
		echo "Date de dernière modification du mot de passe de l'utilisateur : " >> $file_info_user 
		ssh $utilisateur_ssh@$address_ip "echo $password | sudo -S chage -l $user_name | head -n 1" >> $file_info_user
		echo -e "\n " >> $file_info_user 
		addLog "Consultation de la dernière modification du mot de passe de l'utilisateur local $user_name sur l'ordinateur client $address_ip";;
		
		3) ## Choix de "Liste des sessions ouvertes par l'utilisateur"
		addLog "Choix de 'Liste des sessions ouvertes par l'utilisateur'"
		echo "Liste des sessions ouvertes par l'utilisateur : " >> $file_info_user 
		if ! ssh $utilisateur_ssh@$address_ip "who | grep $user_name" >> $file_info_user
		then    
			echo "Aucune session ouverte par l'utilisateur $user_name" >> $file_info_user
		fi
		echo -e "\n " >> $file_info_user 
		addLog "Consultation de la liste des sessions ouvertes par l'utilisateur local $user_name sur l'ordinateur client $address_ip";;
		
		4) ## Choix de "Groupe d’appartenance d’un utilisateur"
		addLog "Choix de 'Groupe d’appartenance d’un utilisateur'"
		echo "Groupe d'appartenance de l'utilisateur local : " >> $file_info_user 
		ssh $utilisateur_ssh@$address_ip "groups $user_name" >> $file_info_user
		echo -e "\n " >> $file_info_user 
		addLog "Consultation des groupes d'appartenance de l'utilisateur local $user_name sur l'ordinateur client $address_ip";;
		
		5) ## Choix de "Historique des commandes exécutées par l'utilisateur"
        addLog "Choix de 'Historique des commandes exécutées par l'utilisateur'"
        echo "Historique des commandes exécutées par l'utilisateur local : " >> $file_info_user
        read -p "Voulez-vous voir l'intégrité des commandes exécutées par $user_name ou uniquement une partie ? Tapez le nombre de lignes voulues ou la touche 'Entrée' pour la totalité : " ans_history
		if [ -z $ans_history ]
		then
			ssh $utilisateur_ssh@$address_ip "echo $password | sudo -S cat /home/$user_name/.bash_history" >> $file_info_user
			addLog "Consultation de l'historique des ccommandes exécutées par l'utilisateur local $user_name sur l'ordinateur client $address_ip"
		else
			ssh $utilisateur_ssh@$address_ip "echo $password | sudo -S tail -n $ans_history /home/$user_name/.bash_history" >> $file_info_user
			addLog "Consultation des $ans_history dernières lignes de l'historique des ccommandes exécutées par l'utilisateur local $user_name sur l'ordinateur client $address_ip"
		fi
		echo -e "\n " >> $file_info_user;;
		
		6) ## Choix de "Droits/permissions de l’utilisateur sur un dossier"
		addLog "Choix de 'Droits/permissions de l’utilisateur sur un dossier'"
		## Choix + vérif du dossier
		read -p " Entrez le nom et le chemin absolu du dossier sur lequel vous voulez vérifier les droits de $user_name : " rep_name
		ssh $utilisateur_ssh@$address_ip "[ -d $rep_name ]"
		while ! $?
		do 
			echo "Le dossier n'existe pas."
			read -p " Entrez le nom et le chemin absolu du dossier sur lequel vous voulez vérifier les droits de $user_name : " rep_name
		done
		echo "Droits de l'utilisateur local sur le dossier $rep_name : " >> $file_info_user
		ssh $utilisateur_ssh@$address_ip "ls -ld  $rep_name" >> $file_info_user
		if cat $file_info_user | tail -n 1 | grep $user_name > /dev/null 2>&1
		then
			echo "$user_name est le propriétaire du dossier $rep_name" >> $file_info_user
		elif ssh $utilisateur_ssh@$address_ip "groups $user_name | grep $(ls -ld  $rep_name | awk -F: '{print $4}' > /dev/null 2>&1)" 
		then
			echo "$user_name est dans le groupe propriétaire du dossier $rep_name" >> $file_info_user
		else
			echo "$user_name fait partie des Autres" >> $file_info_user
		fi
		echo -e "\n " >> $file_info_user 
		addLog "Consultation des droits de l'utilisateur local $user_name du dossier $rep_name sur l'ordinateur client $address_ip";;

		7) ## Choix de "Droits/permissions de l’utilisateur sur un fichier"
		addLog "Choix de 'Droits/permissions de l’utilisateur sur un fichier'"
		## Choix + vérif du fichier
        read -p " Entrez le nom et le chemin absolu du fichier sur lequel vous voulez vérifier les droits de $user_name" file_name
		ssh $utilisateur_ssh@$address_ip "[ -e $file_name ]"
		while ! $?
		do 
			echo "Le fichier n'existe pas."
			read -p " Entrez le nom et le chemin absolu du fichier sur lequel vous voulez vérifier les droits de $user_name : " file_name
		done
		echo "Droits de l'utilisateur local sur le fichier $file_name : " >> $file_info_user
		$ssh "ls -l $file_name" >> $file_info_user
		if cat $file_info_user | tail -n 1 | grep $user_name > /dev/null 2>&1
		then
			echo "$user_name est le propriétaire du fichier $file_name" >> $file_info_user
		elif ssh $utilisateur_ssh@$address_ip "groups $user_name | grep $(ls -l $file_name | awk -F: '{print $4}') > /dev/null 2>&1" 
		then
			echo "$user_name est dans le groupe propriétaire du fichier $file_name" >> $file_info_user
		else
			echo "$user_name fait partie des Autres" >> $file_info_user
		fi 
		echo -e "\n " >> $file_info_user 
		addLog "Consultation des droits de l'utilisateur local $user_name du fichier $file_name sur l'ordinateur client $address_ip";;
		
		*) ## Erreur de saisie
		addLog "Erreur de saisie, retour au menu 'Information concernant un utilisateur local'"
		echo "Erreur de saisie, veuillez recommencer"
		sleep 1
		infoUser;;
		esac
	done
	
	## Affichage selon le nombre d'info souhaitée
	if [ $(echo $ans_info_user | wc -w) -eq 1 ]
	then 
		tac $file_info_user | sed -e '/#######/q' | tac
	fi
	echo " Les informations demandées sont dans le fichier $file_info_user ."
	addLog "*********EndScript*********"
	exit 0
}

#### fonction qui gère les informations sur l'ordinateur client
function infoComputer() {
	menu "Version de l'OS" "Nombre de disque" "Partition (nombre, nom, FS, taille) par disque" "Liste des applications/paquets installées" "Liste des services en cours d'execution" "Liste des utilisateurs locaux" "Type de CPU, nombre de coeurs, etc." "Mémoire RAM totale" "Utilisation de la RAM" "Utilisation du disque" "Utilisation du processeur" "Retour"
	echo "Si vous souhaitez plusieurs informations, écrivez les différents chiffres à la suite, avec un espace entre chaque. "
	read ans_info_computer

	## chemin vers le fichier d'enregistrement d'informations
	file_info_computer="/home/$SUDO_USER/info_"$address_ip"_$(date +"%Y%m%d").txt"

	## sortie du script si il y a un 0, retour si 12. Création et/ou initialisation du fichier d'enregistrement
	if echo $ans_info_computer | grep " 0\| 0 \|^0" > /dev/null
	then 
	## Fin du script
		echo "Fin du script"
		addLog "*********EndScript*********"
		exit 0
	elif echo $ans_info_computer | grep "12" > /dev/null
	then 
		### Retour au menu précédent
		addLog "Retour au menu précédent"
		break 1
	else
		touch $file_info_computer > /dev/null 2>&1 
		echo -e "####### \n# Informations sur l'ordinateur $address_ip demandées le $(date +"%Y%m%d") à $(date +"%H:%M") \n#######\n" >> $file_info_computer
	fi

	## Traitement de chaque réponse
	for ans in $ans_info_computer
	do 
		case $ans in 
		
		1) ## pour avoir la version de l'OS
			echo "Version de l'OS : " >> $file_info_computer 
			ssh $user_ssh@$address_ip "lsb_release -a 2> /dev/null | grep Description" >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation de la version de l'OS de l'ordinateur client $address_ip";;
		
		2) ## pour avoir le nombre de disques
			echo "Nombre de disques :" $(ssh $user_ssh@$address_ip "lsblk | grep disk | wc -l") >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation du nombre de disques de l'ordinateur client $address_ip";; 
		
		3) ## pour avoir les partitions par disque
			echo "Les partitions :" >> $file_info_computer 
			ssh $user_ssh@$address_ip "lsblk -f" >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation des partitions de l'ordinateur client $address_ip";; 

		4) ## pour lister les applications/paquets installés, avec ou sans filtre
			read -p " La commande pour lister les applications et paquets installées donne de très nombreuses lignes. Si vous souhaitez filtre la recherche, merci de taper votre mot. Pour avoir la liste complète, appuyez sur Entrée. " filter
			if [ -z $filter ]
			then 
				echo "Les applications et paquets installés :" >> $file_info_computer 
				ssh $user_ssh@$address_ip "apt list 2> /dev/null">> $file_info_computer 
				echo -e "\n " >> $file_info_computer 
				addLog "Consultation des applications et paquets installés de l'ordinateur client $address_ip"
			else 
				echo "Les applications et paquets installés filtrés avec $filter :" >> $file_info_computer 
				ssh $user_ssh@$address_ip "apt list 2> /dev/null | grep $filter" >> $file_info_computer 
				echo -e "\n " >> $file_info_computer 
				addLog "Consultation des applications et paquets installés avec un filtre ($filter) de l'ordinateur client $address_ip"
			fi;;
		
		5) ## pour lister les services en cours d'exécution
			echo "La liste des services en cours d'exécution :" >> $file_info_computer 
			ssh $user_ssh@$address_ip "service --status-all | grep '\[ + \]'" >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation de la liste des services en cours d'exécution sur l'ordinateur client $address_ip";; 
		
		6) ## pour lister les utilisateurs locaux
			echo "La liste des utilisateurs locaux :" >> $file_info_computer 
			ssh $user_ssh@$address_ip "awk -F: '{print $1}' /etc/passwd" >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation de la liste des utilisateurs locaux de l'ordinateur client $address_ip";; 
		
		7) ## pour connaître le type de CPU
			echo "Les informations sur le CPU :" >> $file_info_computer 
			ssh $user_ssh@$address_ip "lscpu | head -n13" >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation des informations sur le CPU de l'ordinateur client $address_ip";; 
		
		8) ## pour connaître le nombre de RAM
			echo "Taille de la RAM :" $(ssh $user_ssh@$address_ip "free -h") >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation de la taille de la RAM de l'ordinateur client $address_ip";; 
		
		9) ## pour connaître la quantité de RAM utilisée
			echo "Quantité de RAM utilisée :" $(ssh $user_ssh@$address_ip "free -h") >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation de la quantité de RAM utilisée de l'ordinateur client $address_ip";; 
		
		10) ## pour connaître la quantité de disque utilisée
			echo "Les quantités de disque utilisées :" >> $file_info_computer 
			ssh $user_ssh@$address_ip "df -h" >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation des quantités de disque utilisées de l'ordinateur client $address_ip";; 
		
		11) ## pour connaître la quantité de processeurs utilisée
			echo "La quantité de processeurs utilisée :" >> $file_info_computer 
			ssh $user_ssh@$address_ip "top -n1 | grep %Cpu"  >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation de la quantité de processeur utilisée de l'ordinateur client $address_ip";; 
		
		*) ## Erreur de saisie
			echo "Erreur de saisie, veuillez recommencer"
			addLog "Erreur de saisie, retour au menu 'Une information concernant un ordinateur client'"
			sleep 1
			infoComputer;;
		esac
	done
	
	## Affichage selon le nombre d'info souhaitée
	if [ $(echo $ans_info_computer | wc -w) -eq 1 ]
	then tac $file_info_computer | sed -e '/#######/q' | tac
	fi
	echo " Les informations demandées sont dans le fichier $file_info_computer."
	addLog "*********EndScript*********"
    exit 0
}

#### fonction qui gère les informations sur le script
function infoScript() {
	menu "Recherche des événements dans le fichier log_evt.log pour un utilisateur" "Recherche des événements dans le fichier log_evt.log pour un ordinateur" "Retour"
	read ans_info_script
	case $ans_info_script in 
		0) ## Fin du script
		echo "Fin du script"
		addLog "*********EndScript*********"
		exit 0;; 

		1) ## Choix de "Recherche des événements dans le fichier log_evt.log pour un utilisateur"
		addLog "Choix de 'Recherche des événements dans le fichier log_evt.log pour un utilisateur'"
		searchLog "utilisateur local"
		addLog "*********EndScript*********"
		exit 0;;
		
		2)  ## Choix de "Recherche des événements dans le fichier log_evt.log pour un ordinateur client"
		addLog "Choix de 'Recherche des événements dans le fichier log_evt.log pour un ordinateur client'"
		searchLog "ordinateur client"
		addLog "*********EndScript*********"
		exit 0;;

		3) ### Retour au menu précédent
		addLog "Retour au menu précédent"
		break 1;;
		
		*) ## Erreur de saisie
		echo "Erreur de saisie, veuillez recommencer"
		addLog "Erreur de saisie, retour au menu 'Une information concernant le script'"
		sleep 1
		infoScript;;
		
	esac
}

#*******************************************************************************************************************************************#

#------------------------------------------------------------------------------------------------#
#                                         Début du Script                                        #
#------------------------------------------------------------------------------------------------#

echo "Début du script - Gestion à distance"
addLog "********StartScript********"
read -p "Quel est l'adresse IPv4 de l'ordinateur à cibler ? " address_ip
testSSH $address_ip
if [ $? -eq 1 ]
then
	read -p "Quel est l'adresse IPv4 de l'ordinateur à cibler ? " address_ip
	testSSH $address_ip
	if [ $? -eq 1 ]
	then
		echo "Votre saisie n'est pas bonne, merci de vérifier et de relancer le script"
		addLog "Sortie du Script suite à deux erreurs de saisie de l'adresse IP cible"
		addLog "*********EndScript*********"
		exit 1
	fi
fi
sleep 2
menu "Effectuer une action" "Récupérer une information"
read ans_main
addLog "Entrée dans le menu principal"

# Traitement de la réponse
while true;
do
	case $ans_main in
		0)  ## Fin du script
		addLog "*********EndScript*********"
		exit 0 ;;  
		
		1) ## Choix de "Effectuer une action"
		menu "Une action concernant un utilisateur" "Une action concernant un ordinateur client" "Retour"
		read ans_action
		addLog "Entrée dans le menu 'Effectuer une action' "
		case $ans_action in
			0) ## Fin du script
			echo "Fin du script"
			addLog "*********EndScript*********"
			exit 0;; 
			
			1) ## Choix de "Utilisateur"
			addLog "Entrée dans le menu 'Action concernant un utilisateur'"
			actionUser
			if [ $?=1 ]
			then
				ans_main=1
				addLog "Entrée dans le menu 'Effectuer une action' "
				continue
			else
				addLog "*********EndScript*********"
				exit 0
			fi;;
			
			2) ## Choix de "Ordinateur client"
			addLog "Entrée dans le menu 'Action concernant un ordinateur client'"
			actionComputer
			if [ $?=1 ]
			then
				ans_main=1
				addLog "Entrée dans le menu 'Effectuer une action' "
				continue
			else
				addLog "*********EndScript*********"
				exit 0
			fi;;

			3) ## Retour au menu précédent
			addLog "Retour au menu précédent"
			menu "Effectuer une action" "Récupérer une information"
			read ans_main
			addLog "Entrée dans le menu principal"
			continue;;
			
			*) ## Erreur de saisie
			echo "Erreur de saisie, veuillez recommencer"
			addLog "Échec de saisie, retour au menu 'Effectuer une action'"
			sleep 1
			continue;;
		esac;;
		
		2)  ## Choix de "Récupérer une information"
		menu "Une information sur un utilisateur" "Une information sur un ordinateur client" "Une information sur le Script" "Retour"
		read ans_info
		addLog "Entrée dans le menu 'Récupérer une information' "
		case $ans_info in 
		O) ## Fin du script
		echo "Fin du script"
		addLog "*********EndScript*********"
		exit 0;; 

		1) ## Choix de "Utilisateur"
		addLog "Entrée dans le menu 'Information concernant un utilisateur'"
		infoUser
		if [ $?=1 ] 
		then
			addLog "Entrée dans le menu 'Récupérer une information' "
			ans_main=2
			continue
		else
			addLog "*********EndScript*********"
			exit 0
		fi;;

		2) ## Choix de "Ordinateur"
		addLog "Entrée dans le menu 'Information concernant un ordinateur client'"
		infoComputer
		if [ $?=1 ]
		then
			addLog "Entrée dans le menu 'Récupérer une information' "
			ans_main=2
			continue
		else
			addLog "*********EndScript*********"
			exit 0
		fi;;

        3) ## Choix de "Script"
		addLog "Entrée dans le menu 'Information concernant le script'"
		infoScript
		if [ $?=1 ]
		then
			addLog "Entrée dans le menu 'Récupérer une information' "
			ans_main=2
			continue
		else
			addLog "*********EndScript*********"
			exit 0
		fi;;

		4) ## Retour au menu précédent
		addLog "Retour au menu précédent"
		menu "Effectuer une action" "Récupérer une information"
		read ans_main
		addLog "Entrée dans le menu principal"
		continue;;
		
		*) ## Erreur de saisie
		echo "Erreur de saisie, veuillez recommencer"
		addLog "Échec de saisie, retour au menu 'Récupérer une information'"
		sleep 1
		continue;;
		esac;;

	*) # Erreur de saisie
	echo "Erreur de saisie, veuillez recommencer"
	addLog "Échec de saisie, retour au menu principal"
	sleep 1
	menu "Effectuer une action" "Récupérer une information"
	read ans_main
    continue;;
    
	esac
done
addLog "*********EndScript*********"
exit 0
