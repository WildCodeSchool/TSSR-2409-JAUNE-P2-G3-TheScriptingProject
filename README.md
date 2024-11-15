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
| Lamine     | Membre | Débuggage de la partie Powershell, modification des livrables                                     |
| Sam        |   PO   | Débuggage de la partie Powershell                                                                 |
| Charlène   |   SM   | Débuggage de la partie POwershell, modification des livrables                                     |
| Arnauld    | Membre | Écriture de fonctions                                                                             |


## Choix techniques
Les quatre machines sont sur Proxmox. Nous avons également créé des versions sur VirtualBox, afin de faciliter les tests.  

Les adresses IP et les OS ont été imposées par le client.  

Nous avons fait le choix d'une connexion SSH ente les Linux et d'une connexion WinRM pour les Windows, afin de faciliter les échanges en gardant les connexions prévues pour les OS.  

Nous avons fait le choix de diviser le code en sous-menus, gérés par des fonctions, puis de rediviser chqaque action en fonction également.   

Nous avons choisi de créer un compte dédié à la connexion SSH sur chaque machine Linux, afin de faciliter la connexion et la configuration.   

### Difficultés rencontrées et solutions trouvées
1. L'utilisation de Proxmox a posé quelques problèmes qui se sont résolus avec l'entrainement.  
2. Notre méconnaissance de Powershell a retardé notre avancée dans la rédaction de script. Nous nous sommes aidé de forum Powershell et de la commande ```Get-Help```.
3. Nous n'avons pas réussi à écrire et débugger toutes les fonctionnalités, par manque de temps. Nous avons donc décidé de ne pas les inclure.  



### Améliorations possibles
1. Nous pourrions améliorer la mise en page et l'ergonomie du script, avec par exemple l'ajout de couleurs.  
2. Nous pourrions ajouter les fonctionnalités manquantes.  
3. Nous pourrions créer un script pour automatiser la mise en place du script, surtout la partie création des comptes dédiés au SSH.  
4. Nous pourrions améliorer la sécurité des échanges, en changeant le port du SSH ou en adaptant le pare-feu des Windows.   


