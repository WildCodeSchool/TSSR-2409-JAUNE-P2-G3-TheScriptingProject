
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

# Le chemin vers le dossier du fichier de jorunalisation
$path = "C:\Windows\System32\Logfiles" 


#------------------------------------------------------------------------------------------------#
#                                      Fonctions annexes                                         #
#------------------------------------------------------------------------------------------------#

#region Fonction annexe
##### fonction pour gérer l'affichage d'un menu
## Les arguments sont les différents choix.
function menu {
    Clear-Host
    Write-Host "#### The Scripting Project ####" -ForegroundColor Cyan
    $message = "Entrez votre choix : 0"
    Write-Host "Que voulez vous faire ? " -ForegroundColor Cyan
    Write-Host "0 : Fin du script "
    $i = 1
    foreach ($arg in $ARGS) {
        Write-Host "$i : $arg"
        $message += "/$i"
        $i += 1
    }
    Write-Host "Que voulez-vous faire ? "
}

##### fonction pour gérer le log du script
## Prend en argument un texte et l'ajoute avec date/user/... dans le bon fichier
function addLog {
    param ( [string] $event )
    ## vérifie que le fichier existe et l'initialise si ce n'est pas le cas
    if ( ! ( Test-Path $path\log_evt.log ) ) {
        New-Item -Path $path -Name "log_evt.log" -ItemType "file" `
            -Value "# Journal des activités de script.ps1 `r`n" *> $NULL
    }
    ## ajoute l'entrée sous le format YYYYMMDD-HHMMSS-Utilisateur-Événement
    add-Content -Path $path\log_evt.log "$(get-date -Format "yyyyMMdd") - $(get-date -Format "HHmmss") - $env:USERNAME - $event" 
}
#endregion

#------------------------------------------------------------------------------------------------#
#                    Fonctions de demande d'informations sur un ordinateur                       #
#------------------------------------------------------------------------------------------------#



#region Information Computer
# Version de l'OS
function osVersion {
    Invoke-Command -session $session -ScriptBlock { Get-Computerinfo | Select-Object -Property OsName, OsVersion | Format-List } >> $file_info_computer
    addLog "Consultation de la version de l'OS de l'ordinateur $address_ip"
}

## Nombre de disque
function diskNumber {
    $DiskNbr = Invoke-Command -session $session -ScriptBlock { Get-Disk | Select-Object -Property FriendlyName, Number }
    addLog "Consultation du nombre de disques de l'ordinateur $address_ip"
    return $DiskNbr
}

## Partition (nombre, nom, FS, taille) par disque
function partDisk {
    $Part = Invoke-Command -session $session -ScriptBlock { Get-Partition | Select-Object -Property DriveLetter, PartitionNumber, Size, UniqueId, Type }
    addLog "Consultation des partitions de l'ordinateur $address_ip"
    return $Part
}

## Liste des applications/paquets installées
function appInstalled {
    $App = Invoke-Command -session $session -ScriptBlock { Get-Package | Select-Object -Property Name | Format-List }
    addLog "Consultation de la liste des applications installées de l'ordinateur $address_ip"
    return $App
}

## Liste des services en cours d'execution
function serviceRunning {
    $Service = Invoke-Command -session $session -ScriptBlock { Get-Service | Where-Object { $_.Status -eq "Running" } }
    addLog "Consultation de la liste des services en cours d'exécution de l'ordinateur $address_ip"
    return $Service
}

## Liste des utilisateurs locaux
function localUser {
    $LocalUser = Invoke-Command -session $session -ScriptBlock { Get-LocalUser | Select-Object -Property Name, Enabled }
    addLog "Consultation de la liste des utilisateurs locaux de l'ordinateur $address_ip"
    return $LocalUser
}

## Type de CPU, nombre de coeurs, etc.
function cpuInfo {
    $CPU = Invoke-Command -session $session -ScriptBlock { Get-CimInstance -ClassName Win32_Processor | Select-Object -ExcludeProperty "CIM*" }
    addLog "Consultation des informations sur le CPU de l'ordinateur $address_ip"
    return $CPU
    
}
## Mémoire RAM totale
function ramTotal {
    $ram=Invoke-Command -session $session -scriptblock `
    { $ram = ([math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)) 
    return $ram}
    return $ram
}


## Utilisation de la RAM
function ramUSe {
    $ramFree = Invoke-Command -session $session -scriptblock { ([math]::Round((Get-CimInstance -ClassName Win32_OperatingSystem).freePhysicalMemory / 1MB, 2)) }
    $ramTotal = ramTotal
    $ramUsed = $RamTotal - $ramFree
    return $ramUsed
}

## Utilisation du disque
function diskUse {
    Invoke-Command -session $session -scriptblock `
    { Get-PSDrive -PSProvider FileSystem } >> $file_info_computer
}


## Utilisation du processeur
function cpuUSe {
    $use = Invoke-Command -session $session -scriptblock `
    { (Get-WmiObject Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average }
    return $use
}
#endregion


#------------------------------------------------------------------------------------------------#
#                          Fonctions pour gérer les 4 sous-menus                                 #
#------------------------------------------------------------------------------------------------#


##### fonction pour gérer les actions concernant un utilisateur
function actionUser {
    menu "Création de compte utilisateur local" "Suppression de compte utilisateur local" "Désactivation de compte utilisateur local" "Ajout à un groupe local" "Sortie d'un groupe local" "Retour"
    $ans_action_user = Read-Host 
    switch ($ans_action_user) {

        0 {
            ## Fin du script
            Write-Host "Fin du script"
            addLog "*********EndScript*********"
            exit
        }

        1 {
            ## Choix de "Création de compte utilisateur local"
            addLog "Choix de 'Création de compte utilisateur local'"
            $username = Read-Host "Entrez le nom du nouvel utilisateur"
            $password = Read-Host "Entrez le mot de passe pour le nouvel utilisateur" -AsSecureString
            try {
                Invoke-Command -session $Session -ScriptBlock { param ( $username , $password ) New-LocalUser -Name $username -Password $Password -FullName $username -ErrorAction Stop } -ArgumentList $username, $password *> $null
                Write-Host "L'utilisateur '$username' a été créé avec succès."
                addLog "Réussite de la création de l'utilisateur $username"
                Start-Sleep -Seconds 1
            }
            catch {
                Write-Host "Erreur lors de la création de l'utilisateur '$username'."
                addLog "Échec de la création de l'utilisateur $username"
                Start-Sleep -Seconds 1 
            }
        }

        2 {
            ## Choix de "Suppression de compte utilisateur local"
            addLog "Choix de 'Suppression de compte utilisateur local'"
            $username = Read-Host "Entrez le nom de l'utilisateur à supprimer"
            if ( Invoke-Command -Session $Session -ScriptBlock { param ($username) Get-LocalUser -Name $username} -ArgumentList $username )
            {
                try {
                    Invoke-Command -Session $Session -ScriptBlock { param ($username) Remove-LocalUser -Name $username -ErrorAction Stop} -ArgumentList $username 
                    Write-Host "L'utilisateur '$username' a été supprimé avec succès."
                    addLog "Réussite de la suppression de l'utilisateur $username"
                    Start-Sleep -Seconds 1
                    }
                catch {
                    Write-Host "Erreur lors de la suppression de l'utilisateur '$username'."
                    addLog "Échec de la suppression de l'utilisateur $username"
                    Start-Sleep -Seconds 1
                }
            }
            else {
                Write-Host "L'utilisateur '$username' n'existe pas."
                addLog "Échec de la suppression de l'utilisateur $username"
                Start-Sleep -Seconds 1
            } 
            } 

        3 {
            ## Choix de "Désactivation de compte utilisateur local"
            addLog "Choix de 'Désactivation de compte utilisateur local'"
            $username = Read-Host "Entrez le nom de l'utilisateur que vous souhaitez désactiver "
            if (Invoke-Command -session $session -ScriptBlock { param ($username) Get-LocalUser -Name $username} -ArgumentList $username)
            {
                try {
                    Invoke-Command -session $Session -ScriptBlock {
                        param ($username)
                        Disable-LocalUser -Name $username -ErrorAction Stop
                    } -ArgumentList $username *> $null
                    Write-Host "L'utilisateur '$username' a été désactivé avec succès."
                    addLog "Réussite de la désactivation de l'utilisateur $username"
                    Start-Sleep -Seconds 1
                }
                catch {
                    Write-Host "Erreur lors de la désactivation de l'utilisateur '$username'."
                    addLog "Échec de la désactivation de l'utilisateur $username"
                    Start-Sleep -Seconds 1
                }
            }
            else {
                Write-Host "L'utilisateur '$username' n'existe pas."
                addLog "Échec de la désactivation de l'utilisateur $username"
                Start-Sleep -Seconds 1
            } 
        }

        4 {
            ## Choix de "Ajout à un groupe local"
            addLog "Choix de 'Ajout à un groupe local'"
            $username = Read-Host "Entrez le nom de l'utilisateur à ajouter au groupe"
            $groupname = Read-Host "Entrez le nom du groupe local"
            try {
                Invoke-Command -session $Session -ScriptBlock {
                    param ($username, $groupname)
                    Add-LocalGroupMember -Group $groupname -Member $username -ErrorAction Stop
                } -ArgumentList $username, $groupname *> $null
                Write-Host "L'utilisateur '$username' a été ajouté au groupe '$groupname' avec succès."
                addLog "Réussite de l'ajout de l'utilisateur $username au groupe $groupname"
                Start-Sleep -Seconds 1
            }
            catch {
                Write-Host "Erreur lors de l'ajout de l'utilisateur '$username' au groupe '$groupname'."
                addLog "Échec de l'ajout de l'utilisateur $username au groupe $groupname"
                Start-Sleep -Seconds 1        
            }
        }

        5 {
            ## Choix de "Sortie d'un groupe local"
            addLog "Choix de 'Sortie d'un groupe local'"
            $username = Read-Host "Entrez le nom de l'utilisateur à retirer du groupe"
            $groupname = Read-Host "Entrez le nom du groupe local"
            try {
                Invoke-Command -session $Session -ScriptBlock {
                    param ($username, $groupname)
                    Remove-LocalGroupMember -Group $groupname -Member $username -ErrorAction Stop
                } -ArgumentList $username, $groupname *> $null
                Write-Host "L'utilisateur '$username' a été retiré du groupe '$groupname' avec succès."
                addLog "réussite du retrait de l'utilisateur $username du groupe $groupname"
                Start-Sleep -Seconds 1
            }
            catch {
                Write-Host "Erreur lors du retrait de l'utilisateur '$username' du groupe '$groupname'."
                addLog "Échec du retrait de l'utilisateur $username du groupe $groupname"
                Start-Sleep -Seconds 1
            }
        }

        6 {
            ### Retour au menu précédent
            addLog "Retour au menu précédent"
            return
        }
        
        default {
            ## Erreur de saisie
            Write-Host "Erreur de saisie, veuillez recommencer"
            addLog "Échec de saisie, retour au menu 'Action concernant un utilisateur local"
            continue
        }
    }
}


#### fonction pour gérer les actions concernant un ordinateur client
function actionComputer {
    menu "Création de répertoire" "Suppression de répertoire" "Installation de logiciel" "Désinstallation de logiciel" `
        "Arrêt" "Redémarrage" "Verrouillage" "Activation du pare-feu" "Désactivation du pare-feu" "Retour"
    $ans_action_computer = Read-Host 
    Switch ($ans_action_computer) { 
        0 {
            ## Fin du script
            Write-Host "Fin du script"
            addLog "*********EndScript*********"
            exit
        }

        1 {
            ## Choix de "Création d'un répertoire sur l'ordinateur $address_ip"
            addLog "Choix de 'Création d'un répertoire sur l'ordinateur $address_ip'"
            $NewDir = Read-Host "Entrez le nom du dossier que vous voulez créer"
            $pathDir = Read-Host "Entrez le chemin absolu où vous souhaitez créer le dossier"
            try {
                Invoke-Command -session $session -ScriptBlock { param ($pathDir, $NewDir ) `
                    New-Item -Path "$pathDir\$NewDir" -ItemType Directory} -ArgumentList $pathDir,$NewDir
                Write-Host "Le dossier $NewDir a été crée dans le chemin $pathDir"
                addLog "Réussite de la création du dossier $NewDir"
                Start-Sleep -Seconds 2
            }
            catch {
                Write-Host "La création n'a pas réussi."
                addLog "Échec de la création du dossier $NewDir"
                Start-Sleep -Seconds 2
            }
        }

        2 {
            ## Choix de "Suppression d'un répertoire de l'ordinateur $address_ip"
            addLog "Choix de 'Suppression d'un répertoire de l'ordinateur $address_ip'"
            $suppDir = Read-Host "Entrez le nom du dossier que vous voulez supprimer"
            $pathDir = Read-Host "Entrez le chemin où se trouve le dossier"
            try {
                Invoke-Command -session $session -ScriptBlock { param ($pathDir, $suppDir ) `
                    Remove-Item -Path "$pathDir\$suppDir"} -ArgumentList $pathDir,$suppDir
                Write-Host "Le dossier $suppDir est supprimé du chemin $pathDir"
                addLog "Réussite de la suppression du dossier $suppDir"
                Start-Sleep -Seconds 2
            }
            catch {
                Write-Host "La suppression a échoué."
                addLog "Échec de la suppression du dossier $suppDir"
                Start-Sleep -Seconds 2
            }
        }
		
        
        3 {
            ## Choix de "Installation de logiciel de l'ordinateur $address_ip"
            addLog "Choix de 'Installation de logiciel de l'ordinateur $address_ip'"
            $name = Read-Host "Entrez le nom du logiciel à installer: "
            $results=Invoke-Command -session $session -ScriptBlock {
                param($name)
                $install = choco list 
                if ($install -match $name) {
                    $results="Échec de l'installation de $name"
                } else {
                    choco install $name -y *> $NULL
                    $results="Réussite de l'installation de $name"
                }
                return $results
            } -ArgumentList $name
            write-host $results
            addLog $results
            Start-Sleep -Seconds 2
        }
		
        4 {
            ## Choix de "Désinstallation de logiciel"
            addLog "Choix de 'Désinstallation de logiciel'"
            $name = Read-Host "Entrez le nom du logiciel à désinstaller: "
            $results=Invoke-Command -session $session -ScriptBlock {
                param($name)
                $install = choco list
                if ($install -match $name) {
                    choco uninstall $name -yx *> $NULL
                    $results="Réussite de la désinstallation de $name"
                    
                } else {
                    $results="Échec de la désinstallation de $name"
                }
                return $results
            } -ArgumentList $name
            write-host $results
            addLog $results
            Start-Sleep -Seconds 2
        }

        5 { # Choix de Arrêt
            addLog "Choix de 'Arrêt'"
            Invoke-Command -Session $session -ScriptBlock { shutdown /s /f /t 0 }
            addLog "L'ordinateur $addressip est éteint"
            write-host "L'ordinateur $address_ip est éteint"
            Start-Sleep -Seconds 2
        }

        6 { # Choix de Redémarrage
            addLog "Choix de 'Redémarrage'"
            Invoke-Command -Session $session -ScriptBlock { shutdown /r /t 1 }
            addLog "L'ordinateur $address_ip va redémarrer."
            write-host "L'ordinateur $address_ip est en train de redémarrer"
            Start-Sleep -Seconds 2
        }

        7 { ## Choix de verrouillage
            addLog "Choix de 'Verrouillage'"
            Invoke-Command -Session $session -ScriptBlock { logoff console }
            addLog "L'ordinateur $address_ip est verrouillé"
            write-host "L'ordinateur $address_ip est verrouillé."
            Start-Sleep -Seconds 2
        }

        8 { ## Choix de Activation du Pare-feu
            addLog "Choix de 'Activation du pare-feu'"
            Invoke-Command -Session $session -ScriptBlock { set-netFirewallProfile -enabled true }
            addLog "Le pare-feu de l'ordinateur $address_ip est activé"
            write-host "Le pare-feu de l'ordinateur $address_ip est activé"
            Start-Sleep -Seconds 2
        }

        9 { ## Choix de désactivation du Pare-feu
            addLog "Choix de 'Désactivation du pare-feu'"
            Invoke-Command -Session $session -ScriptBlock { set-netFirewallProfile -enabled false }
            addLog "Le pare-feu de l'ordinateur $address_ip est désactivé"
            write-host "Le pare-feu de l'ordinateur $address_ip est désactivé"
            Start-Sleep -Seconds 2
        }

        10 {
            ### Retour au menu précédent
            addLog "Retour au menu précédent"
            break
        }
        

        default {
            ## Erreur de saise
            addLog "Erreur de saisie, retour au menu 'Action concernant un ordinateur client'"

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
    $ans_info_user = Read-Host 
    $username = Read-Host "Entrez le nom de l'utilisateur que vous voulez cibler"
    ## chemin vers le fichier d'enregistrement d'informations
    $file_info_user = "C:\Users\$env:USERNAME\Documents\info_$($username)_$(get-date -Format "yyyyMMdd").txt"
    ## sortie du script si il y a un 0, retour si 12. Création et/ou initialisation du fichier d'enregistrement
    if ($ans_info_user | Select-String -Pattern " 0 |^0| 0$") {
        ## Fin du script
        Write-Host "Fin du script"
        addLog "*********EndScript*********"
        exit
    }
    if ($ans_info_user | Select-String -Pattern "8") {
        ## Retour en arrière
        addLog "Retour au menu précédent, le menu Information"
        break
    }
    New-Item -type file $file_info_user *> $NULL
    add-Content -Value "`n ####### `n# Informations sur l'utilisateur $username demandées le $(get-date -Format "yyyyMMdd") à $(get-date -Format "HHmm") `n#######`n" `
        -path $file_info_user

    foreach ($ans in $ans_info_user.Split(" ")) {
        
        Switch ($ans) {

            0 {
                ## Fin du script
                Write-Host "Fin du script"
                addLog "*********EndScript********"
                exit
            }

            1 {
                
                try {
                    # Exécution de la commande sur la session distante et stockage du résultat
                    $result = Invoke-Command -Session $Session -ScriptBlock {
                        param ($username)
        
                        # Récupération de l'événement de connexion avec ID 4624 pour Windows 10
                        $derniereConnexion = Get-WinEvent -FilterHashtable @{ Logname='Security'; ID=4624 } | Where-Object { $_.Properties.Count -gt 5 -and $_.Properties[5].Value -eq $username } | Select-Object -Last 1

                        # Si une connexion est trouvée, retourner l'heure de connexion
                        if ($derniereConnexion) {
                            $timeGenerated = $derniereConnexion.TimeCreated
                            return "L'utilisateur '$username' s'est connecté pour la dernière fois le : $timeGenerated"
                        }
                        else {
                            # Si aucune connexion n'est trouvée
                            return "Aucune connexion trouvée pour l'utilisateur '$username'."
                        }
                    } -ArgumentList $username
                    # Affichage et enregistrement des résultats dans le fichier de log
                    Add-Content -Path $file_info_user -value "`n"
                    Add-Content -path $file_info_user -Value $result
                    addlog "Consultation de la date de dernière connexion de l'utilisateur $username"
                    Start-Sleep -Seconds 1
                }
                catch {
                    # En cas d'erreur, afficher un message et ajouter au log
                    Write-Host "Erreur lors de la récupération des informations de connexion pour '$username'."
                    addLog "Erreur lors de la récupération des informations de connexion pour '$username'."
                    Start-Sleep -Seconds 1
                }
            }

            2 {
                try {
                    $results=Invoke-Command -Session $Session -ScriptBlock {
                        param ($username)
                        $user = Get-LocalUser -Name $username -ErrorAction SilentlyContinue
        
                        if ($user) {
                            $results="Dernière modification du mot de passe de l'utilisateur '$username' : $($user.PasswordLastSet)"
                        }
                        else {
                            $results="L'utilisateur '$username' n'existe pas."
                        }
                        return $results
                    } -ArgumentList $username
                Add-Content -Path $file_info_user -value "`n"
                Add-Content -path $file_info_user -Value $results
                addLog "Consultation de la date de modification du mot de passe de l'utilisateur $username"
                Start-Sleep -Seconds 1
                }
                catch {
                    Write-Host "Erreur lors de la récupération de la date de modification du mot de passe pour '$username'." *> $null
                    addLog "Erreur lors de la récupération de la date de modification du mot de passe pour '$username'."
                    Start-Sleep -Seconds 1
                }
            }

            3 {
                try {
                    $sessions=Invoke-Command -Session $Session -ScriptBlock {
                        param ($username)
                        $sessions = query user | Select-String $username 
                    return $sessions } -ArgumentList $username 
                    if ($sessions) 
                    {
                        Add-Content -Path $file_info_user -value "`n"
                        Add-Content -path $file_info_user -Value  "Sessions ouverte"Définition de règles de pare-feu" s pour l'utilisateur '$username' :"
                        Add-Content -Path $file_info_user -value $sessions
                        Start-Sleep -Seconds 1
                    }
                    else {
                        Add-Content -Path $file_info_user -value "`n"
                        Add-Content -path $file_info_user -Value "Aucune session ouverte trouvée pour l'utilisateur '$username'." *> $null
                        Start-Sleep -Seconds 1
                    }
                    addLog "Consultations des sessions ouvertes par '$username'."
                }
                catch {
                    Write-Host "Erreur lors de la récupération des sessions ouvertes pour '$username'." *> $null
                    addLog "Erreur lors de la récupération des sessions ouvertes pour '$username'."
                    Start-Sleep -Seconds 1
                }
            }

            4 {
                try {
                    $groupes=Invoke-Command -Session $Session -ScriptBlock {
                        param ($username)
                        $groupes = (net user $username)[22,23]
                        return $groupes } -ArgumentList $username
                    Add-Content -Path $file_info_user -value "`n"
                    Add-Content -path $file_info_user -Value "Groupes d'appartenance de l'utilisateur '$username' :"
                    Add-Content -path $file_info_user -Value $groupes
                    addLog "Consultation des groupes de '$username'."
                    Start-Sleep -Seconds 1
                }
                catch {
                    Write-Host "Erreur lors de la récupération des groupes pour l'utilisateur '$username'."
                    addLog "Erreur lors de la récupération des groupes pour '$username'."
                    Start-Sleep -Seconds 1
                }
                
            }

            5 {
                try {

                    $results=Invoke-Command -Session $Session -ScriptBlock {
                        param ($username)
                        $historyFilePath = "C:\Users\$username\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt"
                        if (Test-Path $historyFilePath) {
                            $results=Get-Content $historyFilePath
                        }
                        else {
                            $results="Aucun historique de commandes trouvé pour l'utilisateur '$username'."
                        }
                        return $results
                    } -ArgumentList $username
                    Add-Content -Path $file_info_user -value "`n"
                    Add-Content -path $file_info_user -Value "Historique des commandes pour l utilisateur '$username' :"
                    Add-Content -path $file_info_user -Value $results
                    addLog "Historique des commandes pour '$username' listé avec succès."
                }
                catch {
                    Write-Host "Erreur lors de la récupération de l'historique des commandes pour '$username'." *> $null
                    addLog "Erreur lors de la récupération de l'historique des commandes pour '$username'."
                    Start-Sleep -Seconds 1
                }
            }

            6 {
                $dossier = Read-Host "Entrez le chemin absolu du dossier dont vous voulez connaître les droits"
                try {
                    
                    Add-Content -Path $file_info_user -value "`n"
                    Add-Content -path $file_info_user -Value "Permissions de l'utilisateur '$username' sur le dossier '$dossier' :"
                    Invoke-Command -Session $Session -ScriptBlock {
                        param ($dossier)
                        Get-Acl -Path $dossier | Format-List
                    } -ArgumentList $dossier >> $file_info_user
                    addLog "Permissions sur le dossier '$dossier' listées avec succès pour '$username'."
                    Start-Sleep -Seconds 1
                }
                catch {
                    Write-Host "Erreur lors de la récupération des permissions pour '$username' sur le dossier '$dossier'." *> $null
                    addLog "Erreur lors de la récupération des permissions pour '$username' sur le dossier '$dossier'."
                    Start-Sleep -Seconds 1
                }
            }

            7 {
                $fichier = Read-Host "Entrez le chemin absolu du fichier dont vous voulez connaître les droits"
                try {
                    
                    Add-Content -Path $file_info_user -value "`n"
                    Add-Content -path $file_info_user -Value "Permissions de l'utilisateur '$username' sur le fichier '$fichier' :"
                    Invoke-Command -Session $Session -ScriptBlock {
                        param ($fichier)
                        Get-Acl -Path $fichier | Format-List
                    } -ArgumentList $fichier >> $file_info_user
                    addLog "Permissions sur le fichier '$fichier' listées avec succès pour '$username'."
                    Start-Sleep -Seconds 1
                }
                catch {
                    Write-Host "Erreur lors de la récupération des permissions pour '$username' sur le fichier '$fichier'." *> $null
                    addLog "Erreur lors de la récupération des permissions pour '$username' sur le fichier '$fichier'."
                    Start-Sleep -Seconds 1
                }
            }
            
            8 {
                Write-Host "Retour au menu principal"
                addLog "Retour au menu principal"
                break
            }
            
            default {
                ## Erreur de saisie
                Write-Host "Erreur de saisie, veuillez recommencer"
                Start-Sleep -Seconds 1
                addLog "Échec de saisie, retour au menu 'Récupérer une information sur un utilisateur'"
                continue
            }
        }
    }
    if ($ans_info_user.Length -le 2)
    { Get-Content $file_info_user | Select-String -Pattern "# Informations" -Context 1,1000 | Select-Object -Last 1}
    Write-Host "Les informations sont dans le fichier $file_info_user."
    Read-Host "Appuyez sur Entrée pour continuer."
}

#### fonction qui gère les informations sur l'ordinateur client
function infoComputer {
    menu "Version de l'OS" "Nombre de disque" "Partition (nombre, nom, FS, taille) par disque" `
        "Liste des applications/paquets installées" "Liste des services en cours d'execution" `
        "Liste des utilisateurs locaux" "Type de CPU, nombre de coeurs, etc." "Mémoire RAM totale" `
        "Utilisation de la RAM" "Utilisation du disque" "Utilisation du processeur" "Retour"
    Write-Host "Si vous souhaitez plusieurs informations, écrivez les différents chiffres à la suite, avec un espace entre chaque. "
    $ans_info_computer = Read-Host 

    ## chemin vers le fichier d'enregistrement d'informations
    $file_info_computer = "C:\Users\$env:USERNAME\Documents\info_$($address_ip)_$(get-date -Format "yyyyMMdd").txt"

    ## sortie du script si il y a un 0, retour si 12. Création et/ou initialisation du fichier d'enregistrement
    if ($ans_info_computer | Select-String -Pattern " 0 |^0| 0$") {
        ## Fin du script
        Write-Host "Fin du script"
        addLog "*********EndScript*********"
        exit
    }
    if ($ans_info_computer | Select-String -Pattern "12") {
        ## Retour en arrière
        addLog "Retour au menu précédent, le menu Information"
        break
    }
    New-Item -type file $file_info_computer *> $NULL
    add-Content -Value "####### `n# Informations sur l'ordinateur $address_ip demandées le $(get-date -Format "yyyyMMdd") à $(get-date -Format "HHmm") `n#######`n" `
        -path $file_info_computer


    Foreach ($ans in $ans_info_computer.Split(" ")) {
        Switch ($ans) {
            1 {
                ## Version de l'OS
                add-Content -Path $file_info_computer -Value " La version de l'OS : `n"
                osVersion 
                add-Content -Path $file_info_computer -Value "`n"
            }

            2 {
                ## Nombre de disque
                add-Content -Path $file_info_computer -Value " Le nombre de disques : `n"
                diskNumber >> $file_info_computer
                add-Content -Path $file_info_computer -Value "`n"
            }

            3 {
                ## Partition (nombre, nom, FS, taille) par disque
                add-Content -Path $file_info_computer -Value " Les partitions : `n"
                partDisk >> $file_info_computer
                add-Content -Path $file_info_computer -Value "`n"
            }

            4 {
                ## Liste des applications/paquets installées
                add-Content -Path $file_info_computer -Value " Les applications installées : `n"
                appInstalled >> $file_info_computer
                add-Content -Path $file_info_computer -Value "`n"
            }

            5 {
                ## Liste des services en cours d'execution
                add-Content -Path $file_info_computer -Value " Les services en cours d'exécution : `n"
                serviceRunning >> $file_info_computer
                add-Content -Path $file_info_computer -Value "`n"
            }

            6 {
                ## Liste des utilisateurs locaux
                add-Content -Path $file_info_computer -Value " Les utilisateurs locaux : `n"
                localUser >> $file_info_computer
                add-Content -Path $file_info_computer -Value "`n"
            }

            7 {
                ## Type de CPU, nombre de coeurs, etc.
                add-Content -Path $file_info_computer -Value " Les informations sur le CPU : `n"
                cpuInfo >> $file_info_computer
                add-Content -Path $file_info_computer -Value "`n"
            }

            8 {
                # Mémoire RAM totale
                add-Content -Path $file_info_computer -Value " La taille de la RAM : $( ramtotal ) Go. `n"
                add-Content -Path $file_info_computer -Value "`n"
            }

            9 {
                ## Utilisation de la RAM

                add-Content -Path $file_info_computer -Value " L'utilisation de la RAM : $( ramUse ) Go utilisée `n"
                add-Content -Path $file_info_computer -Value "`n"
            }

            10 {
                ## Utilisation des disques
                add-Content -Path $file_info_computer -Value " L'utilisation des disques : `n"
                diskUse
                add-Content -Path $file_info_computer -Value "`n"
            }
            
            11 {
                ## Utilisation du processeur
                add-Content -Path $file_info_computer -Value " L'utilisation du processeur : $(cpuUse) % `n"
                add-Content -Path $file_info_computer -Value "`n"
            }
            
            default {
                ## Erreur de saisie
                Write-Host "Erreur de saisie, veuillez recommencer"
                Start-Sleep -Seconds 1
                addLog "Échec de saisie, retour au menu 'Récupérer une information sur un ordinateur'"
                continue
            }
        }   
    }
    if ($ans_info_computer.Length -le 2)
    { Get-Content $file_info_computer | Select-String -Pattern "# Informations" -Context 1,100 | Select-Object -Last 1}
    Write-Host "Les informations sont dans le fichier $file_info_computer."
    Read-Host "Appuyez sur Entrée pour continuer."
}


#### fonction qui gère les informations sur le script
function infoScript {
    menu "Recherche des événements dans le fichier log_evt.log pour un utilisateur" `
        "Recherche des événements dans le fichier log_evt.log pour un ordinateur" "Retour"
    $ans_info_script = Read-Host
    if ($ans_info_script -eq 0)
    {
    	## Fin du script
        Write-Host "Fin du script"
        addLog "*********EndScript*********"
        exit
    }
    Switch ($ans_info_script) { 
        1 {
            ## Choix de "Recherche des événements dans le fichier log_evt.log pour un utilisateur"
            addLog "Choix de 'Recherche des événements dans le fichier log_evt.log pour un utilisateur'"
            $user = Read-Host "Quel utilisateur voulez-vous cibler ?"
            Get-content $path\log_evt.log | Select-String -Pattern $user
            if (!(Get-content $path\log_evt.log | Select-String -Pattern $user))
            { write-host "Aucune correspondance trouvée" }
            read-host "Appuyez sur Entrée pour continuer."
            addLog "Recherche des événements dans le fichier log_evt.log pour l'utilisateur $user"
            return
        }
		
        2 {
            ## Choix de "Recherche des événements dans le fichier log_evt.log pour un ordinateur client"
            addLog "Choix de 'Recherche des événements dans le fichier log_evt.log pour un ordinateur client'"
            $computer = Read-Host "Quelle est l'adresse ip de l'ordinateur cible ?"
            Get-content $path\log_evt.log | Select-String -Pattern $computer
            if (!(Get-content $path\log_evt.log | Select-String -Pattern $computer))
            { write-host "Aucune correspondance trouvée" }
            read-host "Appuyez sur Entrée pour continuer."
            addLog "Recherche des événements dans le fichier log_evt.log pour l'ordinateur client $computer"
            return
        }

        3 {
            ### Retour au menu précédent
            addLog "Retour au menu précédent"
            break
        }
		
        default {
            ## Erreur de saisie
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
$address_ip = Read-Host "Quel est l'adresse IPv4 de l'ordinateur à cibler ? "
$user = Read-Host "Quel est le nom de l'utilisateur local à cibler ? Par défaut, wilder. "
if ([String]::IsNullOrEmpty($user)) {
    $user = "wilder"
}
$session = New-PSSEssion -computerName $address_ip -credential $user

if (! ($session)) {
    Write-Host "La connexion n'a pas fonctionné. Merci de recommencer "
    addLog "Sortie du Script suite à une erreur de connexion avec la machine cible"
    addLog "*********EndScript*********"
    exit
}
else {
    addLog "Connexion réussie avec l'ordinateur $address_ip et l'utilisateur $user "
}

menu "Effectuer une action" "Récupérer une information"
$ans_main = Read-Host
addLog "Entrée dans le menu principal"

while ($TRUE) {
    Switch ($ans_main) {
        0 {
            ## Fin du script
            Write-Host "Fin de Script"
            addLog "*********EndScript*********"
            return
        }  
		
        1 {
            ## Choix de "Effectuer une action"
            menu "Une action concernant un utilisateur" "Une action concernant un ordinateur client" "Retour"
            $ans_action = Read-Host 
            addLog "Entrée dans le menu 'Effectuer une action' "
            Switch ($ans_action) {
                0 {
                    ## Fin du script
                    Write-Host "Fin du script"
                    addLog "*********EndScript*********"
                    return
                }
			
                1 {
                    ## Choix de "Utilisateur"
                    addLog "Entrée dans le menu 'Action concernant un utilisateur'"
                    actionUser
                }
			
                2 {
                    ## Choix de "Ordinateur client"
                    addLog "Entrée dans le menu 'Action concernant un ordinateur client'"
                    actionComputer
                }

                3 {
                    ## Retour au menu précédent
                    addLog "Retour au menu précédent"
                    addLog "Entrée dans le menu principal"
                    menu "Effectuer une action" "Récupérer une information"
                    $ans_main = Read-Host 
                    continue
                }
			
                default {
                    ## Erreur de saisie
                    Write-Host "Erreur de saisie, veuillez recommencer"
                    Start-Sleep -Seconds 1
                    addLog "Échec de saisie, retour au menu 'Effectuer une action'"
                    continue
                }
            }
        }
		
        2 {
            ## Choix de "Récupérer une information"
            menu "Une information sur un utilisateur" "Une information sur un ordinateur client" "Une information sur le Script" "Retour"
            $ans_info = Read-Host 
            addLog "Entrée dans le menu 'Récupérer une information' "
            Switch ($ans_info) {
                O {
                    ## Fin du script
                    Write-Host "Fin du script"
                    addLog "*********EndScript*********"
                    return
                }
            
                1 {
                    ## Choix de "Utilisateur"
                    addLog "Entrée dans le menu 'Information concernant un utilisateur'"
                    infoUser
                }
            
                2 {
                    ## Choix de "Ordinateur"
                    addLog "Entrée dans le menu 'Information concernant un ordinateur client'"
                    infoComputer
                }

                3 {
                    ## Choix de "Script"
                    addLog "Entrée dans le menu 'Information concernant le script'"
                    infoScript
                }

                4 {
                    ## Retour au menu précédent
                    addLog "Retour au menu précédent"
                    menu "Effectuer une action" "Récupérer une information"
                    $ans_main = Read-Host 
                    addLog "Entrée dans le menu principal"
                    continue
                }

                default {
                    ## Erreur de saisie
                    Write-Host "Erreur de saisie, veuillez recommencer"
                    Start-Sleep -Seconds 1
                    addLog "Échec de saisie, retour au menu 'Récupérer une information'"
                    continue
                }
            }
        }    

        default {
            ## Erreur de saisie
            Write-Host "Erreur de saisie, veuillez recommencer"
            Start-Sleep -Seconds 1
            addLog "Échec de saisie, retour au menu principal"
            menu "Effectuer une action" "Récupérer une information"
            $ans_main = Read-Host 
            continue
        }
    }
}

Write-Host "Fin du script"
addLog "*********EndScript*********"
