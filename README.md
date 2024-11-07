# TSSR-2409-JAUNE-P2-G3-TheScriptingProject

## The Scripting Project avec Proxmox


### Présentation du projet et objectifs
Le projet consiste à créer un script qui s’exécute sur un serveur et effectue des tâches sur des machines distantes.  L’ensemble des machines sont sur le même réseau.
Il doit y avoir un Script en Bash et un script en Powershell.  
Les tâches sont des actions ou des requêtes d’information, au nombre de 40.  

L'objectif principal est validé si les deux scripts sont complétement réalisés et fonctionnels et si la documentation est réalisée et correcte.  

### Mise en contexte
Depuis une machine Windows Server, on exécute un script PowerShell qui cible des ordinateurs Windows.  
Depuis une machine Debian, on exécute un script shell qui cible des ordinateurs Ubuntu.
Les tâches sont regroupées en cinq parties : une action sur un utilisateur local, une action sur un ordinateur client, une information sur un utilisateru local, une information sur un ordinateur client et une information sur le script.  


### Présentation de l'équipe, rôles par sprint
Nous sommes un groupe de quatre personnes, de la formation TSSR de septembre 2024. Ce projet est notre deuxième projet et dure quatre semaines, donc quatre sprints.  

Pour le sprint 1 : 

| Équipe     | Rôle   | Missions                                                                                          |
| ---------- | ------ | ------------------------------------------------------------------------------------------------- |
| Lamine     |   SM   | Configuration et mise en réseau des VM Debian 12 et Ubuntu 24.04 LTS                              |
| Sam        | Membre | Création de la fonction addUser en Bash                                                           |
| Charlène   | Membre | Création de l'architecture du menu en Bash                                                        |
| Arnauld    |   PO   | Configuration et mise en réseau des VM Windows Serveur 2022 et Windows 10, préparation du Trello  |

Pour le sprint 2 : 

| Équipe     | Rôle   | Missions                                                                                          |
| ---------- | ------ | ------------------------------------------------------------------------------------------------- |
| Lamine     | Membre | Création des fonctions Action en Bash, Débuggage de script.sh                                     |
| Sam        |   SM   | Création des fonctions Action en Bash, Préparation des machines Windows                           |
| Charlène   |   PO   | Création des fonctions Info en Bash                                                               |
| Arnauld    | Membre | Création des fonctions Info en Bash                                                               |

Pour le sprint 3 : 

| Équipe     | Rôle   | Missions                                                                                          |
| ---------- | ------ | ------------------------------------------------------------------------------------------------- |
| Lamine     |   PO   | Création des fonctions Action en Powershell                                                       |
| Sam        | Membre | Création des fonctions Action en Powershell                                                       |
| Charlène   | Membre | Création des fonctions Info en Powershell, création du menu et de la journalisation               |
| Arnauld    |   SM   | Création des fonctions Info en Powershell                                                         |

Pour le sprint 4 : 

| Équipe     | Rôle   | Missions                                                                                          |
| ---------- | ------ | ------------------------------------------------------------------------------------------------- |
| Lamine     | Membre | Débuggage, modification des livrables                                                             |
| Sam        |   PO   | Débuggage, modification des livrables                                                             |
| Charlène   |   SM   | Débuggage, modification des livrables                                                             |
| Arnauld    | Membre | Débuggage, modification des livrables                                                             |


## Choix techniques
Les quatre machines sont sur Proxmox. Nous avons également créé des versions sur VirtualBox, afin de faciliter les tests.

**Client Windows 10 :**
- Nom : CLIWIN01
- Compte utilisateur : wilder (dans le groupe des admins locaux)
- Mot de passe : Azerty1*

**Client Ubuntu 24.04 LTS :**
- Nom : CLILIN01
- Compte utilisateur : wilder (dans le groupe sudo)
- Mot de passe : Azerty1*

**Serveur Windows Server 2022 :**
- Nom : SRVWIN01
- Compte : Administrator (dans le groupe des admins locaux)
- Mot de passe : Azerty1*

**Serveur Debian 12 :**
- Nom : SRVLX01
- Compte : wilder (dans le groupe sudo)
- Mot de passe : Azerty1*

Les adresses IP ont été imposées par le client.

|   OS   |   IP |
|---    |:-:    |
|   @IP Win10   |   172.16.30.20   |
|   @IP Ubuntu   |   172.16.30.30  |
|   @IP Serv.Win   |   172.16.30.5   |
|   @IP Debian   |   172.16.30.10   |
|   @IP DG   |   172.16.30.254   |

**Masque de sous-réseaux :** 255.255.255.0  
**DNS : 8.8.8.8**  

Nous avons fait le choix de diviser le code en sous-menus, gérés par des fonctions, puis de rediviser chqaque action en fonction également.  
Nous avons choisi de créer un compte dédié à la connexion SSH sur chaque machine Linux, afin de faciliter la connexion et la configuration.  

### Difficultés rencontrées et solutions trouvées
1. L'utilisation de Proxmox a posé quelques problèmes qui se sont résolus avec l'entrainement.
2. 





### Améliorations possibles
1. Nous pourrions améliorer la mise en page et l'ergonomie du script, avec par exemple l'ajout de couleurs.
2. Nous pourrions créer un script pour automatiser la mise en place du script, surtout la partie création des comptes dédiés au SSH.
3. 


