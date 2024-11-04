
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
$path="" 


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

function infoUser
{
    menu "Date de dernière connexion d’un utilisateur" "Date de dernière modification du mot de passe" "Liste des sessions ouvertes par l'utilisateur" "Groupe d’appartenance d’un utilisateur" "Historique des commandes exécutées par l'utilisateur" "Droits/permissions de l’utilisateur sur un dossier" "Droits/permissions de l’utilisateur sur un fichier" "Retour"
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
    menu "Version de l'OS" "Nombre de disque" "Partition (nombre, nom, FS, taille) par disque" "Liste des applications/paquets installées" "Liste des services en cours d'execution" "Liste des utilisateurs locaux" "Type de CPU, nombre de coeurs, etc." "Mémoire RAM totale" "Utilisation de la RAM" "Utilisation du disque" "Utilisation du processeur" "Retour"
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
        defaults {}
    }
}




#*******************************************************************************************************************************************#

#------------------------------------------------------------------------------------------------#
#                                         Début du Script                                        #
#------------------------------------------------------------------------------------------------#

Write-Host "Début du script - Gestion à distance"