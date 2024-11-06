
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
$user_ssh="utilisateur_ssh"
# Le préfixe du réseau de votre serveur
$network_prefix="172.16.30."
# Le chemin vers le dossier du fichier de jorunalisation
$path="C:\Windows\System32\Logfiles" 


#------------------------------------------------------------------------------------------------#
#                                      Fonctions annexes                                         #
#------------------------------------------------------------------------------------------------#

##### fonction pour gérer l'affichage d'un menu
## Les arguments sont les différents choix.
function menu {
	Clear-Host
	Write-Host "#### The Scripting Project ####" -ForegroundColor Cyan
	$message="Entrez votre choix : 0"
	Write-Host "Que voulez vous faire ? " -ForegroundColor Cyan
	Write-Host "0 : Fin du script "
	$i=1
	foreach ($arg in $ARGS) {
        Write-Host "$i : $arg"
        $message+="/$i"
        $i+=1
    }
	Write-Host "Que voulez-vous faire ? "
}

##### fonction pour gérer le log du script
## Prend en argument un texte et l'ajoute avec date/user/... dans le bon fichier
function addLog {
    param ( [string] $event )
    ## vérifie que le fichier existe et l'initialise si ce n'est pas le cas
    if ( ! ( Test-Path $path\log_evt.log ) )
    {
        New-Item -Path $path -Name "log_evt.log" -ItemType "file" `
            -Value "# Journal des activités de script.ps1" *> $NULL
    }
    ## ajoute l'entrée sous le format YYYYMMDD-HHMMSS-Utilisateur-Événement
    add-Content - Path $path\log_evt.log (get-date -Format "yyyyMMdd - HHmmss") "-" $env:USERNAME $event 
}


#------------------------------------------------------------------------------------------------#
#                    Fonctions d'actions et de demande d'informations                            #
#------------------------------------------------------------------------------------------------#

# Version de l'OS
function osVersion
{
    Get-Computerinfo | Select-Object -Property OsName, OsVersion | Format-List
}

## Nombre de disque
function diskNumber
{
    Get-Disk
}

## Partition (nombre, nom, FS, taille) par disque
function partDisk
{
    Get-Partition
}
## Liste des applications/paquets installées
function appInstalled
{
    Get-Package
}
## Liste des services en cours d'execution
function serviceRunning
{
    Get-Service | Where-Object {$_.Status -eq "Running"}
}
## Liste des utilisateurs locaux
function localUser
{
    Get-LocalUser
}
## Type de CPU, nombre de coeurs, etc.
function cpuInfo
{
    Get-CimInstance -ClassName Win32_Processor | Select-Object -ExcludeProperty "CIM*"
}
## Mémoire RAM totale
function ramTotal
{

}




Get-WmiObject -Class Win32_Processor | Out-File D:\Backup\informations.txt -Append

#------------------------------------------------------------------------------------------------#
#                          Fonctions pour gérer les 4 sous-menus                                 #
#------------------------------------------------------------------------------------------------#


##### fonction pour gérer les actions concernant un utilisateur
function actionUser {
	menu "Création de compte utilisateur local" "Changement de mot de passe" "Suppression de compte utilisateur local" "Désactivation de compte utilisateur local" "Ajout à un groupe local" "Sortie d'un groupe local" "Retour"
	Read-Host $ans_action_user
	switch ($ans_action_user) 

        0 { ## Fin du script
        Write-Host "Fin du script"
        addLog "*********EndScript*********"
        }

        1 { ## Choix de "Création de compte utilisateur local"
        addLog "Choix de 'Création de compte utilisateur local'"
        }

        2 { ## Choix de "Changement de mot de passe"
        addLog "Choix de 'Changement de mot de passe'"
        }

        3 { ## Choix de "Suppression de compte utilisateur local"
        addLog "Choix de 'Suppression de compte utilisateur local'"
        }

        4 { ## Choix de "Désactivation de compte utilisateur local"
        addLog "Choix de 'Désactivation de compte utilisateur local'"
        }

        5 { ## Choix de "Ajout à un groupe local"
        addLog "Choix de 'Ajout à un groupe local'"
        }

        6 { ## Choix de "Sortie d'un groupe local"
        addLog "Choix de 'Sortie d'un groupe local'"
        }

        7 { ### Retour au menu précédent
		addLog "Retour au menu précédent"
        }

        defaults { ## Erreur de saisie
        Write-Host "Erreur de saisie, veuillez recommencer"
		addLog "Échec de saisie, retour au menu 'Action concernant un utilisateur local"
        }
}


#### fonction pour gérer les actions concernant un ordinateur client
function actionComputer {
	menu "Arrêt" "Redémarrage" "Verrouillage" "Mise-à-jour du système" "Création de répertoire" `
        "Modification de répertoire" "Suppression de répertoire" "Définition de règles de pare-feu" `
        "Activation du pare-feu" "Désactivation du pare-feu" "Installation de logiciel" `
        "Désinstallation de logiciel" "Exécution de script sur la machine distante" `
        "Prise de main à distance (CLI)" "Retour"
	Read-Host $ans_action_computer
	Switch ($ans_action_computer) { 
		0 { ## Fin du script
        Write-Host "Fin du script"
        addLog "*********EndScript*********"
        }

		1 { ## Choix de "Arrêt de l'ordinateur $address_ip"
        addLog "Choix de 'Arrêt de l'ordinateur $address_ip'"
        }

		2 {## Choix de "Redémarrage de l'ordinateur $address_ip"
        addLog "Choix de 'Redémarrage de l'ordinateur $address_ip'"
        }

		3 { ## Choix de "Verrouillage de l'ordinateur $address_ip"
        addLog "Choix de 'Verrouillage de l'ordinateur $address_ip'"
        }

		4 { ## Choix de "Mise à jour du système de l'ordinateur $address_ip"
        addLog "Choix de 'Mise à jour du système de l'ordinateur $address_ip'"
        }

		5 {## Choix de "Création d'un répertoire sur l'ordinateur $address_ip"
        addLog "Choix de 'Création d'un répertoire sur l'ordinateur $address_ip'"
        }

		6 { ## Choix de "Modification d'un répertoire de l'ordinateur $address_ip"
        addLog "Choix de 'Modification d'un répertoire de l'ordinateur $address_ip'"
        }

		7 { ## Choix de "Suppression d'un répertoire de l'ordinateur $address_ip"
        addLog "Choix de 'Suppression d'un répertoire de l'ordinateur $address_ip'"
        }
		
		8 { ## Choix de "Définitions de règles de pare-feu de l'ordinateur $address_ip"
        addLog "Choix de 'Définitions de règles de pare-feu de l'ordinateur $address_ip'"
        }
		
		9 { ## Choix de "Activation du pare-feu de l'ordinateur $address_ip"
        addLog "Choix de 'Activation du pare-feu de l'ordinateur $address_ip'"
        }

		10 { ## Choix de "Désactivation du pare-feu de l'ordinateur $address_ip"
        addLog "Choix de 'Désactivation du pare-feu de l'ordinateur $address_ip'"
        }
        
		11 { ## Choix de "Installation de logiciel de l'ordinateur $address_ip"
        addLog "Choix de 'Installation de logiciel de l'ordinateur $address_ip'"
        }
		
		12 { ## Choix de "Désinstallation de logiciel"
        addLog "Choix de 'Désinstallation de logiciel'"
        }
		
		13 { ## Choix de "Exécution de script sur la machine distante"
        addLog "Choix de 'Exécution de script sur la machine distante'"
        }
        
        14 {## Choix de "Prise de main à distance (CLI)"
        addLog "Choix de 'Prise de main à distance (CLI)'"
        }

        15 { ### Retour au menu précédent
		addLog "Retour au menu précédent"
        }
        
		defaults { ## Erreur de saise
        addLog "Erreur de saisie, retour au menu 'Action concernant un ordinateur client'"
		Read-Host "Erreur de saisie, veuillez recommencer"
        }
    }
}

function infoUser {
    menu "Date de dernière connexion d’un utilisateur" "Date de dernière modification du mot de passe" `
        "Liste des sessions ouvertes par l'utilisateur" "Groupe d’appartenance d’un utilisateur" `
        "Historique des commandes exécutées par l'utilisateur" "Droits/permissions de l’utilisateur sur un dossier" `
        "Droits/permissions de l’utilisateur sur un fichier" "Retour"
	Write-Host "Si vous souhaitez plusieurs informations, écrivez les différents chiffres à la suite, avec un espace entre chaque. "
	Read-Host $ans_info_user
    foreach ($ans in $ans_info_user) {
        
        Switch ($ans_inf_computer)
        {
            0 {}
            1 {}
            2 {}
            3 {}
            4 {}
            5 {}
            6 {}
            7 {}
            8 {}
            defaults {}
        }
    }
}

function infoComputer
{
    menu "Version de l'OS" "Nombre de disque" "Partition (nombre, nom, FS, taille) par disque" `
        "Liste des applications/paquets installées" "Liste des services en cours d'execution" `
        "Liste des utilisateurs locaux" "Type de CPU, nombre de coeurs, etc." "Mémoire RAM totale" `
        "Utilisation de la RAM" "Utilisation du disque" "Utilisation du processeur" "Retour"
	Write-Host "Si vous souhaitez plusieurs informations, écrivez les différents chiffres à la suite, avec un espace entre chaque. "
	Read-Host ans_info_computer
    Switch ($ans_inf_computer)
    {
        0 {}
        1 {}
        2 {}
        3 {}
        4 {}
        5 {}
        6 {}
        7 {}
        8 {}
        9 {}
        10 {}
        11 {}
        12 {}
        defaults {}
    }
}




#*******************************************************************************************************************************************#

#------------------------------------------------------------------------------------------------#
#                                         Début du Script                                        #
#------------------------------------------------------------------------------------------------#

Write-Host "Début du script - Gestion à distance"
addLog "********StartScript********"
menu "Effectuer une action" "Récupérer une information"
$ans_main=Read-Host
addLog "Entrée dans le menu principal"

Switch ($ans_main)
{
    O {}
    1 {}
    2 {}
    defaults {
        Write-Host "Erreur de saisie, veuillez recommencer."
        addLog "Erreur de saisie, retour au menu principal"
    }
}