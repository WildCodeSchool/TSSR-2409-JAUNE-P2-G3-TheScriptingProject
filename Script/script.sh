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
    	echo "Connexion réussie au PC $1 "
    	addLog "Connexion SSH avec le PC $1 "
     	return 0
    else 
    	echo "Echec de la connexion, veuillez vérifier votre configuration "
     	echo "Fin du script"
      	sleep 2
    	addLog "Echec de la connexion SSH avec le PC $1 "
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

#------------------------------------------------------------------------------------------------#
#                    Fonctions d'actions et de demande d'informations                            #
#------------------------------------------------------------------------------------------------#


##### fonction pour créer un compte utilisateur local sur une machine distante
function addUser() {
	## Demander le nom d'utilisateur
 	read -p "Quel est le nom d'utilisateur ? " user_name
	## Vérifier si l'utilisateur existe déjà
	if ssh $user_ssh@$address_ip 'grep "$user_name:" /etc/passwd > /dev/null'
	then
        	echo "Utilisateur $user_name existe déjà."
        	return 1
	else 
 		ssh $user_ssh@$address_ip 'sudo -S useradd "$user_name"'
    	fi
     
	## Vérifier si l'utilisateur a été créé correctement
	if ssh $user_ssh@$address_ip 'grep "$user_name:" /etc/passwd > /dev/null'
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
	if ssh $user_ssh@$address_ip 'echo "$user_name:$password" | sudo -S chpasswd'
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


##### fonction pour ajouter un utilisateur local d'une machine distante à un groupe local
function addGroup() {
	read -p "Entrez le nom de l'utilisateur : " user_name
 	if ! ssh $user_ssh@$address_ip 'grep "$user_name:" /etc/passwd > /dev/null'
  	then
   		echo "L'utilisateur $user_name n'existe pas"
     		addLog "Échec de l'ajout de l'utilisateur local $user_name à un groupe sur la machine $address_ip"
     		return 1
	fi
 
        read -p "Entrez le nom du groupe : " group_name
        ## Vérifier si le groupe existe avant d'ajouter l'utilisateur
        if ssh $user_ssh@$address_ip 'grep "$group_name:" /etc/group > /dev/null'
        then
		## Ajout + vérification de l'ajout
		if ssh $user_ssh@$address_ip 'sudo -S usermod -aG "$group_name" "$user_name"'
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
 	if ! ssh $user_ssh@$address_ip 'grep "$user_name:" /etc/passwd > /dev/null'
  	then
   		echo "L'utilisateur $user_name n'existe pas"
     		addLog "Échec de la sortie de l'utilisateur local $user_name d'un groupe sur la machine $address_ip"
     		return 1
	fi
 
        read -p "Entrez le nom du groupe : " group_name
        ## Vérifier si le groupe existe et que l'utilisateur fait partie du groupe
        if ssh $user_ssh@$address_ip 'grep "$group_name:" /etc/group | grep $user_name > /dev/null'
        then
		## Sortie + vérification de la sortie
		if ssh $user_ssh@$address_ip 'sudo -S gpasswd -d  "$user_name" "$group_name"'
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
            cat $path/log_evt.log | grep -i $target_name
            addLog "Consultation de la journalisation du script concernant l'$1 $target_name"
        else
            cat $path/log_evt.log | grep -i $target_name | grep -i $keyword
            addLog "Consultation de la journalisation du script concernant l'$1 $target_name avec le filtre $keyword"
        fi
    else 
        if [ -z $keyword ]
        then
            cat $path/log_evt.log | grep -i $target_name | grep -i $date
            addLog "Consultation de la journalisation du script concernant l'$1 $target_name à la date $date"
        else
            cat $path/log_evt.log | grep -i $target_name | grep -i $date | grep -i $keyword
            addLog "Consultation de la journalisation du script concernant l'$1 $target_name à la date $date avec le filtre $keyword"
        fi
    fi
}



#------------------------------------------------------------------------------------------------#
#                          Fonctions pour gérer les 4 sous-menus                                 #
#------------------------------------------------------------------------------------------------#

##### fonction pour gérer les actions concernant un utilisateur
function actionUser() {
	menu "Création de compte utilisateur local" "Changement de mot de passe" "Suppression de compte utilisateur local" "Désactivation de compte utilisateur local" "Ajout à un groupe local" "Sortie d'un groupe local"
	read ans_action_user
	case $ans_action_user in 

    		0) ## Fin du script
      		echo "Fin du script"
      		addLog "*********EndScript*********"
    		exit 0;; 

    		1) ## Choix de "Création de compte utilisateur local"
      		addLog "Choix de 'Création de compte utilisateur local'"
      		addUser;; 

    		2) ## Choix de "Changement de mot de passe"
      		addLog "Choix de 'Changement de mot de passe'"
      		changePassword;;

    		3) ## Choix de "Suppression de compte utilisateur local"
      		addLog "Choix de 'Suppression de compte utilisateur local'"
      		echo removeUser;;
	
    		4) ## Choix de "Désactivation de compte utilisateur local"
      		addLog "Choix de 'Désactivation de compte utilisateur local'"
      		echo disableUser;;

    		5) ## Choix de "Ajout à un groupe local"
      		addLog "Choix de 'Ajout à un groupe local'"
      		addGroup;; 

    		6) ## Choix de "Sortie d'un groupe local"
      		addLog "Choix de 'Sortie d'un groupe local'"
      		exitGroup;; 

    		*) ## Erreur de saisie
      		echo "Erreur de saisie, veuillez recommencer"
		addLog "Échec de saisie, retour au menu 'Action concernant un utilisateur local"
    		sleep 1
    		actionUser;;
	esac
}


#### fonction pour gérer les actions concernant un ordinateur client
function actionComputer() {
	menu "Arrêt" "Redémarrage" "Verrouillage" "Mise-à-jour du système" "Création de répertoire" "Modification de répertoire" "Suppression de répertoire" "Définition de règles de pare-feu" "Activation du pare-feu" "Désactivation du pare-feu" "Installation de logiciel" "Désinstallation de logiciel" "Exécution de script sur la machine distante"
	read ans_action_computer
	case $ans_action_computer in 
		0) ## Fin du script
  		echo "Fin du script"
  		addLog "*********EndScript*********"
    		exit 0;; 
		
		1) ## Choix de "Arrêt de l'ordinateur $address_ip"
      		addLog "Choix de 'Arrêt de l'ordinateur $address_ip'"
		echo "L'ordinateur $address_ip va s'arrêter."
  		ssh $user_ssh@$address_ip 'shutdown -h now'
  		addLog "Réussite de l'arrêt  de l'ordinateur $address_ip";;
		
		2) ## Choix de "Redémarrage de l'ordinateur $address_ip"
      		addLog "Choix de 'Redémarrage de l'ordinateur $address_ip'"
		ssh $user_ssh@$address_ip 'reboot'
  		addLog "Réussite du redémarrage de l'ordinateur $address_ip";; 
		
		3) ## Choix de "Verrouillage de l'ordinateur $address_ip"
      		addLog "Choix de 'Verrouillage de l'ordinateur $address_ip'"
		ssh $user_ssh@$address_ip 'systemctl suspend'
  		addLog "Réussite du verrouillage de l'ordinateur $address_ip";;
		
		4) ## Choix de "Mise à jour du système de l'ordinateur $address_ip"
      		addLog "Choix de 'Mise à jour du système de l'ordinateur $address_ip'"
		ssh $user_ssh@$address_ip 'apt upgrade && apt upgrade -y'
  		addLog "Réussite de la mise à jour du système de l'ordinateur $address_ip'";;
		
		5) ## Choix de "Création d'un répertoire sur l'ordinateur $address_ip"
      		addLog "Choix de 'Création d'un répertoire sur l'ordinateur $address_ip'"
		read -p "Entrez l'endroit où vous voulez créer le nouveau dossier : " rep_path
		while [ -z $rep_path ]
  		do
			read -p "Saisie vide. Entrez l'endroit où vous voulez créer le nouveau dossier : " rep_path
		done
  		read -p "Entrez le nom du dossier à créer: " rep_name
     		if mkdir -p "$rep_path/$rep_name"
       		then
	 		echo "Création du répertoire $rep_name réussie."
    			addLog "Réussite de la création du dossier $rep_name dans $rep_path de l'ordinateur $address_ip"
   		else
      			 echo "$rep_name existe dejà dans $rep_path"
			addLog "Échec de la création du dossier $rep_name dans $rep_path de l'ordinateur $address_ip"
		fi;;
		
		6) ## Choix de "Modification d'un répertoire de l'ordinateur $address_ip"
      		addLog "Choix de 'Modification d'un répertoire de l'ordinateur $address_ip'"
		echo editRep;;
		
		7) ## Choix de "Suppression d'un répertoire de l'ordinateur $address_ip"
      		addLog "Choix de 'Suppression d'un répertoire de l'ordinateur $address_ip'"
		echo deleteRep;;
		
		8) ## Choix de "Définitions de règles de pare-feu de l'ordinateur $address_ip"
      		addLog "Choix de 'Définitions de règles de pare-feu de l'ordinateur $address_ip'"
		echo defineFirewall;;
		
		9) ## Choix de "Activation du pare-feu de l'ordinateur $address_ip"
      		addLog "Choix de 'Activation du pare-feu de l'ordinateur $address_ip'"
		echo enableFirewall;;
		
		10) ## Choix de "Désactivation du pare-feu de l'ordinateur $address_ip"
      		addLog "Choix de 'Désactivation du pare-feu de l'ordinateur $address_ip'"
		echo disableFirewall;;
		
		11) ## Choix de "Installation de logiciel de l'ordinateur $address_ip"
      		addLog "Choix de 'Installation de logiciel de l'ordinateur $address_ip'"
		echo installSoftware;;
		
		12) ## Choix de "Désinstallation de logiciel"
      		addLog "Choix de 'Désinstallation de logiciel'"
		echo uninstallSoftware;;
		
		13) ## Choix de "Exécution de script sur la machine distante"
      		addLog "Choix de 'Exécution de script sur la machine distante'"
		echo executeScript;;
  
		*) ## Erreur de saise
      		addLog "Erreur de saisie, retour au menu 'Action concernant un ordinateur client'"
		echo "Erreur de saisie, veuillez recommencer"
		sleep 1
		actionComputer;;
	esac
}

#### fonction qui gère les informations sur l'utilisateur --> info_utilisateur()
function infoUser() {
	menu "Date de dernière connexion d’un utilisateur" "Date de dernière modification du mot de passe" "Liste des sessions ouvertes par l'utilisateur" "Groupe d’appartenance d’un utilisateur" "Historique des commandes exécutées par l'utilisateur" "Droits/permissions de l’utilisateur sur un dossier" "Droits/permissions de l’utilisateur sur un fichier"
	read ans_info_user
	case $ans_info_user in 
		0) ## Fin du script
  		echo "Fin du script"
  		addLog "*********EndScript*********"
    		exit 0;; 
    		
		1) ## Choix de "Date de dernière connexion d’un utilisateur"
      		addLog "Choix de 'Date de dernière connexion d’un utilisateur'"
  		echo date_last_connection;;
		
		2) ## Choix de "Date de dernière modification du mot de passe"
      		addLog "Choix de 'Date de dernière modification du mot de passe'"
  		echo date_change_password;;
		
		3) ## Choix de "Liste des sessions ouvertes par l'utilisateur"
      		addLog "Choix de 'Liste des sessions ouvertes par l'utilisateur'"
  		echo list_session;;
		
		4) ## Choix de "Groupe d’appartenance d’un utilisateur"
      		addLog "Choix de 'Groupe d’appartenance d’un utilisateur'"
  		echo group_user;;
		
		5) ## Choix de "Historique des commandes exécutées par l'utilisateur"
      		addLog "Choix de 'Historique des commandes exécutées par l'utilisateur'"
  		echo history_user;;
		
		6) ## Choix de "Droits/permissions de l’utilisateur sur un dossier"
      		addLog "Choix de 'Droits/permissions de l’utilisateur sur un dossier'"
  		echo rights_repertory;;
    
		7) ## Choix de "Droits/permissions de l’utilisateur sur un fichier"
      		addLog "Choix de 'Droits/permissions de l’utilisateur sur un fichier'"
  		echo rights_file;;
		
		*) ## Erreur de saise
      		addLog "Erreur de saisie, retour au menu 'Information concernant un utilisateur local'"
  		echo "Erreur de saisie, veuillez recommencer"
		sleep 1
		infoUser;;
	
	esac
}

#### fonction qui gère les informations sur l'ordinateur client
function infoComputer() {
	menu "Version de l'OS" "Nombre de disque" "Partition (nombre, nom, FS, taille) par disque" "Liste des applications/paquets installées" "Liste des services en cours d'execution" "Liste des utilisateurs locaux" "Type de CPU, nombre de coeurs, etc." "Mémoire RAM totale" "Utilisation de la RAM" "Utilisation du disque" "Utilisation du processeur"
	echo "Si vous souhaitez plusieurs informations, écrivez les différents chiffres à la suite, avec un espace entre chaque. "
	read ans_info_computer
 
	## chemin vers le fichier d'enregistrement d'informations
	file_info_computer="/home/$SUDO_USER/info_"$address_ip"_$(date +"%Y%m%d").txt"
 
	## sortie du script si il y a un 0
	if echo $ans_info_computer | grep " 0 " > /dev/null
	then 
 		echo "Fin du script"
  		addLog "*********EndScript*********"
    		exit 0 
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
			ssh $user_ssh@$address_ip 'lsb_release -a | grep Description' >> $file_info_computer
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation de la version de l'OS de l'ordinateur client $address_ip";;
		
		2) ## pour avoir le nombre de disques
			echo "Nombre de disques :" $(ssh $user_ssh@$address_ip 'lsblk | grep disk | wc -l') >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation du nombre de disques de l'ordinateur client $address_ip";; 
		
		3) ## pour avoir les partitions par disque
			echo "Les partitions :" >> $file_info_computer 
			ssh $user_ssh@$address_ip 'lsblk -f' >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation des partitions de l'ordinateur client $address_ip";; 

		4) ## pour lister les applications/paquets installés, avec ou sans filtre
			read -p " La commande pour lister les applications et paquets installées donne de très nombreuses lignes. Si vous souhaitez filtre la recherche, merci de taper votre mot. Pour avoir la liste complète, appuyez sur Entrée. " filter
			if [ -z $filter ]
			then 
				echo "Les applications et paquets installés :" >> $file_info_computer 
				ssh $user_ssh@$address_ip 'apt list' >> $file_info_computer 2> /dev/null
				echo -e "\n " >> $file_info_computer 
				addLog "Consultation des applications et paquets installés de l'ordinateur client $address_ip"
			else 
				echo "Les applications et paquets installés filtrés avec $filter :" >> $file_info_computer 
				ssh $user_ssh@$address_ip 'apt list | grep "$filter"' >> $file_info_computer 2> /dev/null
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
			ssh $user_ssh@$address_ip "awk -F: '{ print $1}' /etc/passwd" >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation de la liste des utilisateurs locaux de l'ordinateur client $address_ip";; 
		
		7) ## pour connaître le type de CPU
			echo "Les informations sur le CPU :" >> $file_info_computer 
			ssh $user_ssh@$address_ip 'lscpu | head -n13' >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation des informations sur le CPU de l'ordinateur client $address_ip";; 
		
		8) ## pour connaître le nombre de RAM
			echo "Taille de la RAM :" $(ssh $user_ssh@$address_ip "free -h | grep Mem: | awk '{print $2}'") >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation de la taille de la RAM de l'ordinateur client $address_ip";; 
		
		9) ## pour connaître la quantité de RAM utilisée
			echo "Quantité de RAM utilisée :" $(ssh $user_ssh@$address_ip "free -h | grep Mem: | awk '{print $3}'") >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation de la quantité de RAM utilisée de l'ordinateur client $address_ip";; 
		
		10) ## pour connaître la quantité de disque utilisée
			echo "Les quantités de disque utilisées :" >> $file_info_computer 
			ssh $user_ssh@$address_ip 'df -h' >> $file_info_computer 
			echo -e "\n " >> $file_info_computer 
			addLog "Consultation des quantités de disque utilisées de l'ordinateur client $address_ip";; 
		
		11) ## pour connaître la quantité de processeurs utilisée
			echo "La quantité de processeurs utilisée :" >> $file_info_computer 
			ssh $user_ssh@$address_ip 'top -n 1 | grep -i "Cpu"'  >> $file_info_computer 
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
	then tac $file_info_computer | sed -e '/Informations sur l ordinateur/q' | tac
	fi
	echo " Les informations demandées sont dans le fichier $file_info_computer."
	addLog "*********EndScript*********"
    exit 0
}

#### fonction qui gère les informations sur le script
function infoScript() {
	menu "Recherche des événements dans le fichier log_evt.log pour un utilisateur" "Recherche des événements dans le fichier log_evt.log pour un ordinateur"
	read ans_info_script
	case $ans_info_script in 
		0) ## Fin du script
  		echo "Fin du script"
  		addLog "*********EndScript*********"
    		exit 0;; 
    		
		1) ## Choix de "Recherche des événements dans le fichier log_evt.log pour un utilisateur"
  		addLog "Choix de 'Recherche des événements dans le fichier log_evt.log pour un utilisateur'"
  		searchLog "utilisateur local";;
		
		2)  ## Choix de "Recherche des événements dans le fichier log_evt.log pour un ordinateur client"
  		addLog "Choix de 'Recherche des événements dans le fichier log_evt.log pour un ordinateur client'"
  		searchLog "ordinateur client";;
		
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
		
		1) ## Choix de "Efectuer une action"
  		menu "Une action concernant un utilisateur" "Une action concernant un ordinateur client"
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
      			addLog "*********EndScript*********"
			exit 0;;
			
			2) ## Choix de "Ordinateur client"
   			addLog "Entrée dans le menu 'Action concernant un ordinateur client'"
   			actionComputer
      			addLog "*********EndScript*********"
			exit 0;;
			
			*) ## Erreur de saisie
   			echo "Erreur de saisie, veuillez recommencer"
   			addLog "Échec de saisie, retour au menu 'Effectuer une action'"
			sleep 1
			continue;;
		esac;;
		
		2)  ## Choix de "Récupérer une information"
  		menu "Une information sur un utilisateur" "Une information sur un ordinateur client" "Une information sur le Script"
       		read ans_info
       		case $ans_info in 
            		O) ## Fin du script
	      		echo "Fin du script"
	      		addLog "*********EndScript*********"
    			exit 0;; 
    		
            		1) ## Choix de "Utilisateur"
	      		addLog "Entrée dans le menu 'Information concernant un utilisateur'"
	      		infoUser
	 		addLog "*********EndScript*********"
            		exit 0;;

            		2) ## Choix de "Ordinateur"
	      		addLog "Entrée dans le menu 'Information concernant un ordinateur client'"
	      		infoComputer
	 		addLog "*********EndScript*********"
            		exit 0;;

            		3) ## Choix de "Script"
	      		addLog "Entrée dans le menu 'Information concernant le script'"
	      		infoScript
	 		addLog "*********EndScript*********"
            		exit 0;;

            		*) ## Erreur de saisie
	      		echo "Erreur de saisie, veuillez recommencer"
	      		addLog "Échec de saisie, retour au menu 'Récupérer une information'"
            		sleep 1
            		continue;;

        	esac;;

    		*) echo "Erreur de saisie, veuillez recommencer"
      		addLog "Échec de saisie, retour au menu principal"
    		sleep 1
    		./script.sh;;
    
	esac
done
addLog "*********EndScript*********"
exit 0
