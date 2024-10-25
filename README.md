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


## Rôles et missions par sprint

Pour le sprint 1 : 

| Équipe     | Rôle   | Missions                                                                                          |
| ---------- | ------ | ------------------------------------------------------------------------------------------------- |
| Lamine     |   SM   | Configuration et mise en réseau des VM Debian 12 et Ubuntu 24.04 LTS                              |
| Sam        | Membre | Création de la fonction addUser en Bash                                                           |
| Charlène   | Membre | Création de l'architecture du menu en Bash                                                        |
| Arnauld    |   PO   | Configuration et mise en réseau des VM Windows Serveur 2022 et Windows 10, préparation du Trello  |


