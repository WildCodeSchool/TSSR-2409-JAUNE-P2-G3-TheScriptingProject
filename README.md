# TSSR-2409-JAUNE-P2-G3-TheScriptingProject

## The Scripting Project avec Proxmox

## Le sujet ?

Le projet consiste à créer un script qui s’exécute sur une machine et effectue des tâches sur des machines distantes.
L’ensemble des machines sont sur le même réseau.

Les tâches sont des actions ou des requêtes d’information.

## Objectif

### Quel est l'objectif du projet ?

**Mise en pratique des compétences suivantes :**

- Mettre en place une architecture client/serveur
- Créer et gérer des scripts bash et PowerShell
- Réaliser un projet en équipe
- Documenter toutes les étapes
- Faire une démonstration de la réalisation finale

### Objectifs principaux et secondaires ?

#### Frist and second

**Le sujet contient 2 objectifs, 1 objectif principal et 1 objectif secondaire.**

**L’objectif principal est validé si :**
- Il est complètement réalisé et fonctionnel
- La documentation est réalisé et correct
- La présentation finale montre les 2 points précédents

L’objectif secondaire est optionnel et amènera en cas de réalisation validée, à une meilleure évaluation.

#### En détail

**Objectif principal :**
- Depuis une machine Windows Server, on exécute un script PowerShell qui cible des ordinateurs Windows
- Depuis une machine Debian, on exécute un script shell qui cible des ordinateurs Ubuntu

**Objectif secondaire :**
- Depuis un serveur, cibler une machine cliente avec un type d’OS différent

## Éléments à implémenter

### Client

####2 clients (au minimum) sont mis en place :

**Client Windows 10 : **
- Nom : CLIWIN01
- Compte utilisateur : wilder (dans le groupe des admins locaux)
- Mot de passe : Azerty1*

**Client Ubuntu 24.04 LTS :**
- Nom : CLILIN01
- Compte utilisateur : wilder (dans le groupe sudo)
- Mot de passe : Azerty1*

### Serveur

**2 serveurs sont mis en place :**

**Serveur Windows Server 2022 :**
- Nom : SRVWIN01
- Compte : Administrator (dans le groupe des admins locaux)
- Mot de passe : Azerty1*

**Serveur Debian 12 :**
- Nom : SRVLX01
- Compte : root
- Mot de passe : Azerty1*

### Configuration réseau des VM

|   OS   |   IP |
|---    |:-:    |
|   @IP Win10   |   172.16.30.20   |
|   @IP Ubuntu   |   172.16.30.30  |
|   @IP Serv.Win   |   172.16.30.5   |
|   @IP Debian   |   172.16.30.10   |
|   @IP DG   |   172.16.30.254   |

**Masque de sous-réseaux :** 255.255.255.0
**DNS : 8.8.8.8**

### Script PowerShell

#### .PS1

Ce script s’exécute sur un serveur Windows Server 2022, sous PowerShell Core dernière version LTS, soit à cette date la 7.4 .

Le script peut avoir plusieurs dépendances de fichiers.

### Script shell

#### .sh

Ce script s’exécute sur un serveur Debian 12, et utilise les commandes et instructions shell bash.

Le script peut avoir plusieurs dépendances de fichiers.

### Éxecution du script

#### Comment ça marche ?

A l’exécution, un menu s’affiche, il propose une navigation ergonomique avec des sous-menus dans lesquels l’utilisateur choisi  ce dont il a besoin :
Une cible qui peut être un ordinateur ou un utilisateur
Un choix entre une/des action(s) à effectuer et de la recherche d’information

### Exécution du script - La cible

#### Comment ça marche ?

La cible est un utilisateur ou un ordinateur.

**Utilisateur :**
- Nom partiel ou complet
- Validation

**Ordinateur :**
- Nom complet ou adresse IP
- Validation

### Exécution du script - Les actions

#### Comment ça marche ?

**On choisit 1 action et le script l’exécute :
Actions sur les utilisateurs :**
- Création de compte
- Suppression de compte
- etc.
**Sur les ordinateurs clients :**
- Arrêt
- Redémarrage
- etc.

### Exécution du script - Les informations

#### Les infos récupérées sur les clients

**On choisit 1 information ou un lot d’informations :**
- Pour 1 => affichage de l’information et enregistrement
- Pour plusieurs => enregistrement
**Information sur les utilisateurs :**
- Date de dernière connexion d’un utilisateur
- etc.
**Information sur les ordinateurs clients :**
- Version de l'OS
- etc.

### Enregistrement des informations

#### Format des infos

Les informations recueilli sur la cible (utilisateur ou ordinateur) sont enregistrées dans un fichier **info_<Cible>_<Date>.txt**

Avec:
Cible : Nom d’utilisateur ou de l’ordinateur cible
Date : Date du recueil des informations au format **yyyymmdd**

Ce fichier est dans le dossier **Documents** du dossier personnel de l’utilisateur exécutant le script ou sur le bureau (au choix du groupe).

### Journalisation

#### Tout garder

La **journalisation**, également connue sous le nom de **logging**, consiste à enregistrer de manière systématique les événements significatifs qui se produisent dans un système, une application ou un réseau.
Les informations enregistrées sont souvent les timestamps, les actions effectuées, les utilisateurs concernés, les machines cibles.

### La journalisation dans le projet 

#### Dans le contexte

Les traces des activités effectuées sont dans le fichier **log_evt.log** qui contient l’enregistrement textuel de _toutes les activités de navigation dans les menus du script_, ainsi que _les demandes d’informations_ et _les actions_.
Les informations enregistrées sont des éléments factuels (date, heure, utilisateur concerné, utilisateur distant, ordinateur distant, etc.).
Ce fichier journal se situe :
- Pour le serveur windows, dans **C:\Windows\System32\LogFiles**
- Pour le serveur Linux, dans **/var/log**

### Fichier journal

#### Format

Les enregistrements du **fichier log_evt.log** sont sous la forme :

**<Date>-<Heure>-<Utilisateur>-<Evenement>**

Avec:  
Date : Date de l’evenement au format **yyyymmdd**  
Heure : Heure de l’evenement au format **hhmmss**  
Utilisateur : Nom de l’utilisateur courant exécutant le script  
Evenement : Action effectuée (à définir par le groupe)  

### Fichier journal (suite)

#### Format du début et de la fin

La 1ère entrée de journal (lancement du script) et la dernière (sortie du script) sont indiquées par des lignes spéciales :

**<Date>-<Heure>-<Utilisateur>-StartScript**
et
**<Date>-<Heure>-<Utilisateur>-EndScript**

### Documentation

#### What’s up doc ?

La documentation est sous format markdown.
Elle est écrite en Français courant, correct, et technique.
Elle peut inclure des copies d’écrans pour étayer les explications données.

### Documentation générale

#### La principale

On doit avoir dans cette documentation :  
- Présentation du projet, objectifs finaux  
- Introduction : mise en contexte  
- Membres du groupe de projet (rôles par sprint)  
- Choix techniques : quel OS, quelle version, etc.  
- Difficultés rencontrées : problèmes techniques rencontrés  
- Solutions trouvées : Solutions et alternatives trouvées  
- Améliorations possibles : suggestions d’améliorations futures  

### Documentation administrateur

#### Pour les admins

On doit avoir dans cette documentation :
- Prérequis techniques
- Étapes d'installation et de conf. : instruction étape par étape
- FAQ : solutions aux problèmes connus et communs liés à l’installation et à la configuration

### Documentation utilisateur

#### Pour les autres

On doit avoir dans cette documentation :
Utilisation de base : comment utiliser les fonctionnalités clés
Utilisation avancée : comment utiliser au mieux les options
FAQ : solutions aux problèmes connus et communs liés à l’utilisation

### Synthèse des éléments à implémenter

#### À mettre en place

- 1 serveur Windows Server 2022 (avec GUI)
- 1 client Windows 10
- 1 serveur Debian 12 (en CLI sans GUI)
- 1 client Ubuntu 22.04/24.04 LTS
- 1 script PowerShell
- 1 script shell bash

## Livrables

### Scripts

#### À rendre à la fin

- 1 scripts PowerShell
- 1 script shell bash

### Scripts (suite)

#### Contenus

Les scripts :
- Ont des commentaires
- Ont une structure de code hierarchisé (indentation, etc.)
- Ont une syntaxe de code claire (nom des variables, etc.)

### Dépôt Github

#### En ligne

Un dépôt Git/github par groupe dont le nom est sous la forme **TSSR-2409-P2-Gx** (avec x le numéro du groupe de projet).

Les dépôts sont créer par ton formateur.
L’adresse email que tu as fourni en début de formation est utilisée pour l'accès au dépôt Github. Si ce n’est pas la même pour ton compte Github, indique le à ton formateur.

### Documentation

#### À rendre à la fin

- Un fichier README.md par groupe
- Un fichier INSTALL.md par groupe
- Un fichier USER_GUIDE.md par groupe
- Un script PowerShell fonctionnel
- Un script shell bash fonctionnel

## Groupes

### Rôles dans les groupes (SM et PO)

#### Des rôles importants

**Scrum Master (SM)**
Le SM est le garant de la bonne application de la méthode Scrum. Il est responsable de la communication entre les membres de l'équipe et de la bonne réalisation des tâches.

**Product Owner (PO)**
Le PO est le représentant du client. Il est responsable de la définition des besoins et de la priorisation des tâches. Il est le garant de la qualité du produit final.

### Rôles dans les groupes (SM et PO) (suite)

#### Des rôles importants


Les rôles seront attribués dans chaque groupe, et seront tournants (changement de rôle à chaque sprint).
Le formateur aura comme seul interlocuteur du projet le PO de chaque groupe.


## Rôles et missions par sprint

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
| Lamine     | Membre | Configuration et mise en réseau des VM Debian 12 et Ubuntu 24.04 LTS                              |
| Sam        |   SM   | Création de la fonction addUser en Bash                                                           |
| Charlène   |   PO   | Création de l'architecture du menu en Bash                                                        |
| Arnauld    | Membre | Configuration et mise en réseau des VM Windows Serveur 2022 et Windows 10, préparation du Trello  |


