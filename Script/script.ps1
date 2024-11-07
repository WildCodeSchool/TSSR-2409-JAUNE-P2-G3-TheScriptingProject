
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

# Le préfixe du réseau de votre serveur
$network_prefix="172.16.30."
# Le chemin vers le dossier du fichier de jorunalisation
$path="C:\Windows\System32\Logfiles" 


#------------------------------------------------------------------------------------------------#
#                                      Fonctions annexes                                         #
#------------------------------------------------------------------------------------------------#

#region Fonction annexe
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
            -Value "# Journal des activités de script.ps1 `r`n" *> $NULL
    }
    ## ajoute l'entrée sous le format YYYYMMDD-HHMMSS-Utilisateur-Événement
    add-Content -Path $path\log_evt.log "$(get-date -Format "yyyyMMdd") - $(get-date -Format "HHmmss") - $env:USERNAME - $event" 
}
#endregion

#------------------------------------------------------------------------------------------------#
#                    Fonctions d'actions et de demande d'informations                            #
#------------------------------------------------------------------------------------------------#

#region Action Computer

#endregion

#region Action User

#endregion

#region Information User

#endregion

#region Information Computer
# Version de l'OS
function osVersion
{
    Invoke-Command -session $session -ScriptBlock {Get-Computerinfo | Select-Object -Property OsName, OsVersion | Format-List} >> $file_info_computer
    addLog "Consultation de la version de l'OS de l'ordinateur $address_ip"
}

## Nombre de disque
function diskNumber
{
    $DiskNbr=Invoke-Command -session $session -ScriptBlock {Get-Disk | Select-Object -Property FriendlyName,Number}
    addLog "Consultation du nombre de disques de l'ordinateur $address_ip"
    return $DiskNbr
}

## Partition (nombre, nom, FS, taille) par disque
function partDisk
{
    $Part=Invoke-Command -session $session -ScriptBlock {Get-Partition | Select-Object DriveLetter,PartitionNumber,Size,UniqueId,Type}
    addLog "Consultation des partitions de l'ordinateur $address_ip"
    return $Part
}

## Liste des applications/paquets installées
function appInstalled
{
    $App=Invoke-Command -session $session -ScriptBlock {Get-Package | Select-Object -Property Name | Format-List}
    addLog "Consultation de la liste des applications installées de l'ordinateur $address_ip"
    return $App
}

## Liste des services en cours d'execution
function serviceRunning
{
    $Service=Invoke-Command -session $session -ScriptBlock {Get-Service | Where-Object {$_.Status -eq "Running"}}
    addLog "Consultation de la liste des services en cours d'exécution de l'ordinateur $address_ip"
    return $Service
}

## Liste des utilisateurs locaux
function localUser
{
    $LocalUser=Invoke-Command -session $session -ScriptBlock {Get-LocalUser | Select-Object -Property Name,Enabled}
    addLog "Consultation de la liste des utilisateurs locaux de l'ordinateur $address_ip"
    return $LocalUser
}

## Type de CPU, nombre de coeurs, etc.
function cpuInfo
{
    $CPU=Invoke-Command -session $session -ScriptBlock {Get-CimInstance -ClassName Win32_Processor | Select-Object -ExcludeProperty "CIM*"}
    addLog "Consultation des informations sur le CPU de l'ordinateur $address_ip"
    return $CPU
    
}
## Mémoire RAM totale
function ramTotal
{
    Invoke-Command  -session $session -scriptblock `
        { $ram = ([math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2))}
    return $ram
}

## Utilisation du disque
function diskUse 
{
    Invoke-Command  -session $session -scriptblock `
        {Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }} >> $file_info_computer
}

## Utilisation du processeur
function CPUUSe
{

}
#endregion

#region Information Script

#endregion


#------------------------------------------------------------------------------------------------#
#                          Fonctions pour gérer les 4 sous-menus                                 #
#------------------------------------------------------------------------------------------------#


##### fonction pour gérer les actions concernant un utilisateur
function actionUser {
	menu "Création de compte utilisateur local" "Changement de mot de passe" "Suppression de compte utilisateur local" `
    "Désactivation de compte utilisateur local" "Ajout à un groupe local" "Sortie d'un groupe local" "Retour"
	$ans_action_user=Read-Host 

	switch ($ans_action_user) {

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
        
        default { ## Erreur de saisie
        Write-Host "Erreur de saisie, veuillez recommencer"
		addLog "Échec de saisie, retour au menu 'Action concernant un utilisateur local"
        continue
        }
    }
}


#### fonction pour gérer les actions concernant un ordinateur client
function actionComputer {
	menu "Arrêt" "Redémarrage" "Verrouillage" "Mise-à-jour du système" "Création de répertoire" `
        "Modification de répertoire" "Suppression de répertoire" "Définition de règles de pare-feu" `
        "Activation du pare-feu" "Désactivation du pare-feu" "Installation de logiciel" `
        "Désinstallation de logiciel" "Exécution de script sur la machine distante" `
        "Prise de main à distance (CLI)" "Retour"
	$ans_action_computer=Read-Host 
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
        

		default { ## Erreur de saise
        addLog "Erreur de saisie, retour au menu 'Action concernant un ordinateur client'"
		Read-Host "Erreur de saisie, veuillez recommencer"
        Write-Host "Erreur de saisie, veuillez recommencer"
        Start-Sleep -Seconds 1
        continue
        }
    }
}

function infoUser {
    menu "Date de dernière connexion d’un utilisateur" "Date de dernière modification du mot de passe" `
        "Liste des sessions ouvertes par l'utilisateur" "Groupe d’appartenance d’un utilisateur" `
        "Historique des commandes exécutées par l'utilisateur" "Droits/permissions de l’utilisateur sur un dossier" `
        "Droits/permissions de l’utilisateur sur un fichier" "Retour"
	Write-Host "Si vous souhaitez plusieurs informations, écrivez les différents chiffres à la suite, avec un espace entre chaque. "
	$ans_info_user=Read-Host 
    foreach ($ans in $ans_info_user) {
        
        Switch ($ans)
        {

            0 { ## Fin du script
            Write-Host "Fin du script"
            addLog "*********EndScript*********"
            return
            }
            1 {}
            2 {}
            3 {}
            4 {}
            5 {}
            6 {}
            7 {}
            8 {}
            
            default {## Erreur de saisie
            Write-Host "Erreur de saisie, veuillez recommencer"
            Start-Sleep -Seconds 1
            addLog "Échec de saisie, retour au menu 'Récupérer une information sur un utilisateur'"
            continue
            }
        }
    }
}

#### fonction qui gère les informations sur l'ordinateur client
function infoComputer {
    menu "Version de l'OS" "Nombre de disque" "Partition (nombre, nom, FS, taille) par disque" `
        "Liste des applications/paquets installées" "Liste des services en cours d'execution" `
        "Liste des utilisateurs locaux" "Type de CPU, nombre de coeurs, etc." "Mémoire RAM totale" `
        "Utilisation de la RAM" "Utilisation du disque" "Utilisation du processeur" "Retour"
	Write-Host "Si vous souhaitez plusieurs informations, écrivez les différents chiffres à la suite, avec un espace entre chaque. "
	$ans_info_computer=Read-Host 

	## chemin vers le fichier d'enregistrement d'informations
	$file_info_computer="C:\Users\$env:USERNAME\Documents\info_$($address_ip)_$(get-date -Format "yyyyMMdd").txt"

	## sortie du script si il y a un 0, retour si 12. Création et/ou initialisation du fichier d'enregistrement
	New-Item -type file $file_info_computer *> $NULL
	add-Content -Value "####### `n# Informations sur l'ordinateur $address_ip demandées le $(get-date -Format "yyyyMMdd") à $(get-date -Format "HHmm") `n#######`n" `
        -path $file_info_computer


    Switch ($ans_info_computer)
    {
        0 { ## Fin du script
        Write-Host "Fin du script"
        addLog "*********EndScript*********"
        return
        }

        1 { ## Version de l'OS
        add-Content -Path $file_info_computer -Value " La version de l'OS : `n"
        write-output osVersion >> $file_info_computer
        add-Content -Path $file_info_computer -Value "`n"
        }

        2 { ## Nombre de disque
        add-Content -Path $file_info_computer -Value " Le nombre de disques : `n"
        write-output diskNumber >> $file_info_computer
        add-Content -Path $file_info_computer -Value "`n"
        }

        3 { ## Partition (nombre, nom, FS, taille) par disque
        add-Content -Path $file_info_computer -Value " Les partitions : `n"
        write-output partDisk >> $file_info_computer
        add-Content -Path $file_info_computer -Value "`n"
        }

        4 { ## Liste des applications/paquets installées
        add-Content -Path $file_info_computer -Value " Les applications installées : `n"
        appInstalled >> $file_info_computer
        add-Content -Path $file_info_computer -Value "`n"
        }

        5 { ## Liste des services en cours d'execution
        add-Content -Path $file_info_computer -Value " Les services en cours d'exécution : `n"
        serviceRunning >> $file_info_computer
        add-Content -Path $file_info_computer -Value "`n"
        }

        6 { ## Liste des utilisateurs locaux
        add-Content -Path $file_info_computer -Value " Les utilisateurs locaux : `n"
        localUser >> $file_info_computer
        add-Content -Path $file_info_computer -Value "`n"
        }

        7 { ## Type de CPU, nombre de coeurs, etc.
        add-Content -Path $file_info_computer -Value " Les informations sur le CPU : `n"
        cpuInfo >> $file_info_computer
        add-Content -Path $file_info_computer -Value "`n"
        }

        8 { # Mémoire RAM totale
        add-Content -Path $file_info_computer -Value " La taille de la RAM : `n"
        add-Content -Path $file_info_computer -Value "`n"
        }

        9 { ## Utilisation de la RAM
        add-Content -Path $file_info_computer -Value " L'utilisation de la RAM : `n"
        add-Content -Path $file_info_computer -Value "`n"
        }

        10 { ## Utilisation des disques
        add-Content -Path $file_info_computer -Value " L'utilisation des disques : `n"
        add-Content -Path $file_info_computer -Value "`n"
        }
        
        11 { ## Utilisation du processeur
        add-Content -Path $file_info_computer -Value " L'utilisation du processeur : `n"
        add-Content -Path $file_info_computer -Value "`n"
        }
        
        12 { ## Retour en arrière
        addLog "Retour au menu précédent, le menu Information"
        break
        }
        
        default { ## Erreur de saisie
        Write-Host "Erreur de saisie, veuillez recommencer"
        Start-Sleep -Seconds 1
        addLog "Échec de saisie, retour au menu 'Récupérer une information sur un ordinateur'"
        continue
        }
    }
}


#### fonction qui gère les informations sur le script
function infoScript {
	menu "Recherche des événements dans le fichier log_evt.log pour un utilisateur" `
        "Recherche des événements dans le fichier log_evt.log pour un ordinateur" "Retour"
	$ans_info_script=Read-Host
	Switch ($ans_info_script) { 
		0 { ## Fin du script
        Write-Host "Fin du script"
        addLog "*********EndScript*********"
        return
        }

		1 { ## Choix de "Recherche des événements dans le fichier log_evt.log pour un utilisateur"
        addLog "Choix de 'Recherche des événements dans le fichier log_evt.log pour un utilisateur'"
        return
        }
		
		2 { ## Choix de "Recherche des événements dans le fichier log_evt.log pour un ordinateur client"
        addLog "Choix de 'Recherche des événements dans le fichier log_evt.log pour un ordinateur client'"
        return
        }

        3 { ### Retour au menu précédent
		addLog "Retour au menu précédent"
        }
		
		default { ## Erreur de saisie
        Write-Host "Erreur de saisie, veuillez recommencer"
        Start-Sleep -Seconds 1
        addLog "Erreur de saisie, retour au menu 'Une information concernant le script'"
		continue
        }
    }
}


#*******************************************************************************************************************************************#

#------------------------------------------------------------------------------------------------#
#                                         Début du Script                                        #
#------------------------------------------------------------------------------------------------#

Write-Host "Début du script - Gestion à distance"
addLog "********StartScript********"

## Connexion avec la cible
$address_ip=Read-Host "Quel est l'adresse IPv4 de l'ordinateur à cibler ? "
$user=Read-Host "Quel est le nom de l'utilisateur local à cibler ? Par défaut, wilder. "
if ([String]::IsNullOrEmpty($user))
{
    $user="wilder"
}
$session=New-PSSEssion -computerName $address_ip -credential $user

if (! ($session))
{
    Write-Host "La connexion n'a pas fonctionné. Merci de recommencer "
    addLog "Sortie du Script suite à une erreur de connexion avec la machine cible"
	addLog "*********EndScript*********"
    exit
}
else
{
    addLog "Connexion réussie avec l'ordinateur $address_ip et l'utilisateur $user "
}

menu "Effectuer une action" "Récupérer une information"
$ans_main=Read-Host
addLog "Entrée dans le menu principal"

while ($TRUE) {
	Switch ($ans_main) {
		0 { ## Fin du script
        Write-Host "Fin de Script"
        addLog "*********EndScript*********"
		return
        }  
		
		1 { ## Choix de "Effectuer une action"
        menu "Une action concernant un utilisateur" "Une action concernant un ordinateur client" "Retour"
		$ans_action=Read-Host 
        addLog "Entrée dans le menu 'Effectuer une action' "
        Switch ($ans_action) {
            0 { ## Fin du script
            Write-Host "Fin du script"
            addLog "*********EndScript*********"
            return
            }
			
			1 { ## Choix de "Utilisateur"
            addLog "Entrée dans le menu 'Action concernant un utilisateur'"
            actionUser
            }
			
			2 { ## Choix de "Ordinateur client"
            addLog "Entrée dans le menu 'Action concernant un ordinateur client'"
            actionComputer
            }

            3 { ## Retour au menu précédent
			addLog "Retour au menu précédent"
            addLog "Entrée dans le menu principal"
			menu "Effectuer une action" "Récupérer une information"
			$ans_main=Read-Host 
            continue
            }
			
			default { ## Erreur de saisie
            Write-Host "Erreur de saisie, veuillez recommencer"
            Start-Sleep -Seconds 1
            addLog "Échec de saisie, retour au menu 'Effectuer une action'"
			continue
            }
        }
        }
		
		2 {  ## Choix de "Récupérer une information"
        menu "Une information sur un utilisateur" "Une information sur un ordinateur client" "Une information sur le Script" "Retour"
        $ans_info=Read-Host 
        addLog "Entrée dans le menu 'Récupérer une information' "
        Switch ($ans_info) {
            O {## Fin du script
            Write-Host "Fin du script"
            addLog "*********EndScript*********"
            return
            }
            
            1 { ## Choix de "Utilisateur"
            addLog "Entrée dans le menu 'Information concernant un utilisateur'"
            infoUser
            }
            
            2 { ## Choix de "Ordinateur"
            addLog "Entrée dans le menu 'Information concernant un ordinateur client'"
            infoComputer
            }

            3 { ## Choix de "Script"
            addLog "Entrée dans le menu 'Information concernant le script'"
            infoScript
            }

            4 { ## Retour au menu précédent
			addLog "Retour au menu précédent"
			menu "Effectuer une action" "Récupérer une information"
			$ans_main=Read-Host 
			addLog "Entrée dans le menu principal"
			continue
            }

            default { ## Erreur de saisie
            Write-Host "Erreur de saisie, veuillez recommencer"
            Start-Sleep -Seconds 1
            addLog "Échec de saisie, retour au menu 'Récupérer une information'"
            continue
            }
        }
        }    

    default { ## Erreur de saisie
    Write-Host "Erreur de saisie, veuillez recommencer"
    Start-Sleep -Seconds 1
    addLog "Échec de saisie, retour au menu principal"
    menu "Effectuer une action" "Récupérer une information"
	$ans_main=Read-Host 
    continue
    }
    }
}

Write-Host "Fin du script"
addLog "*********EndScript*********"