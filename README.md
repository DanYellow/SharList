Shound - Faites découvrir au monde ce que vous aimez
========
Shound - Introduce the world what you like
========

// Compte facebook de test
gqsnkky_wongsky_1415569231@tfbnw.net : 123456789C

## Mises à jour

### v 1.1.0 - Released

- Gestion de Betaseries, vous pouvez ajouter une série sur votre compte Betaseries
- Affichage du taux de "match" entre votre liste et celle d'un utilisateur tierce
- Possibilité de voir l'image de profil Facebook d'un utilisateur rencontré
- Correction de bugs

### v 1.1.1 - Released

- Ajout de notifications lors de la mise à jour d'un favori
- Améliorations

### v 1.1.2 - Released

- Correction de bugs
- Amélioration de l'expérience utilisateur
- Correction d'un bug critique qui faisait planter l'application
- Ajout de la date de sortie du prochain épisode d'une série
- Différentiation des différents types de découvertes

### v 1.1.3 - Not Released

- Correction de bugs
- Ajout du numéro du prochain épisode

### v 1.2.0 - Released

- New API !
- Gestion des emojis

- Gestion des likes Facebook (Possibilité remplir sa liste en fonction de ses likes Facebook)
- Ajout d'un système de pourcentage vis-à-vis d'un film/série découvert
- Possibilité de voir le nombre d'utilisateurs qui suivent votre liste (votre liste est parmi leur favoris)
- Possibilité de poster un commentaire sur un film/série. Avec un commentaire, une recommendation est toujours plus pertinente.
- Amélioration de l'ergonomie
- Affichage du numéro du prochain épisode d'une série (c'est toujours mieux avec sa date)
- Affichage de vos amis facebook dans les fiches.

### v 1.2.1 - Not Released

- Gestion de l'iPad
- Correction de bugs
- Filtrage de la liste d'un utilisateur rencontré
- Amélioration de la vue "Découverte"
- Changement du design

- Highlight Slider - Mise en avant de contenus


# TODO

###### 1.2.0
- Voir les messages vides pour facebook no friends / access no granted - **Done**
- Afficher les amis facebook qui ont le media parmi leur liste Shound - **Done**
- Afficher le taux de présence d'une fiche parmi **toutes** les listes Shound
- Utiliser la nouvelle API pour gérer les liens vers les stores - **Done**
- Ajouter un système de like pour les messages + tri par pertinence - **Done***
- Possibilité d'acheter sur Amazon (Blu-ray ou DVD, et ce, tout en nous supportant) - **Done**
- Possibilité d'acheter une série ou un film dans sa version originale sous-titrée (dans la limite des disponibilité d'iTunes) - **Done**

###### 1.2.1
- Inverser l'affichage des goûts en commun (X % de la liste à découvrir!) - **Done**
- Ajouter "pull to refresh" pour permettre de découvrir de nouvelles choses + Indiquer le temps restant avant la prochaine rencontre : 'XX:XX avant de pouvoir découvrir de nouvelles choses' - **Done**
- Remettre le scroll-to-top lors de la recherche d'une nouvelle récouverte' - **Done**
- Ajouter une segmentation pour la fiche de découverte pour pouvoir filtrer la liste - **Done**
- Inviter ses amis à découvrir de nouvelles choses si aucun d'eux apprécient un film ou une série - **Done**
- Afficher les dernières recherches
- Gérer l'iPad - **Done**
- Ajouter le nombre de découvertes faites - **Done**


###### X.X.X
- Afficher la série la plus présente et le film le plus présent parmi les découvertes
- Proposer un chat (prioriété de la prochaine màj)
- Créer une vue notifications (prioriété de la prochaine màj)
- Le retour de Parse (prioriété de la prochaine màj)
- Créer une vue profil (si présence de chat)
- Ajouter le taux de progression d'une série si réponse favorable de BS avec PNChart - **Done**
- Ajouter la publicité
- Améliorer les miniatures des amis facebook sur les images
- Inviter les amis facebook à découvrir la série "Faire découvrir à mes amis" - **Done**
- Lorsque l'app sera plus populaire : proposer un bouton "faire découvrir à ses abonnés" aux utilisateurs ayant atteint un certain nombre d'abonnés




## Améliorations potentielles
- Gérer le système de géoloc lors de l'actualisation par bouton (ça garde l'ancienne position) - **done !!!!**
- Système de succès (voir liste) 
- Indiquer les comptes premium
- Voir la liste de followers
- Afficher le nombre de followers - **done !!!!**
- Ajouter la clé "last_air_date": "2015-06-04", pour les séries -> savoir la date de diffusion du dernier épisode - done

## API

### Media

#### The movie DB
Cette API est l'API tierce principale de l'application, elle permet de récupérer les données des films et des séries.
Clef API The movie DB : f09cf27014943c8114e504bf5fbd352b (http://docs.themoviedb.apiary.io)

#### Betaseries
Clef API Betaseries : 8bc04c11b4c283b72a3fa48cfc6149f3 (https://www.betaseries.com/api/docs)
- Ajouter / retirer une série au compte betaserie de l'utilisateur : https://api.betaseries.com/shows/display
-- Paramètres : imdb_id : id imdb de la série (fournie par l'API de Shound) | client_id : clef d'api pour Betaseries

#### Shound
User
{
    "id":"174",
    "fbiduser":"1405994199720672",
    "list":
                {
                    "book" : null, 
                    "movie" : [
                        {
                            "imdbID" : "tt1034032",
                            "themoviedbID" : "", 
                            "id" : "1438",
                            "year" : "2009",
                            "type" : "movie",
                            "hits" : "0",
                            "name" : "Ultimate Game"
                        }],
                    "serie" : null
                }",
    "last_position_lat":"0",
    "last_position_long":"0",
    "last_update":"2015-04-17 22:57:24",
    "isAnonymous":"0",
    "isFamous":"0"
}

id : auto-increment
fbiduser : unique - string
user_favs : JSON Object (converted to string object in database) - ALL KEYS MUST EXISTS - Put null if someone has no items for a key
last_position_lat : double - Last position of user latitude
last_position_long : double - Last position of user longitude
last_update : date - last update of user list | Automatically updated by the database
isAnonymous : Boolean | Useful to hide or not user in meetings
isFamous : Boolean | Useful to know if a meeting is done with someone famous

WIP : Build of a REAL API under sf 2.6 (silex)


### Listes de fonctionnalités à implementer (ou implémentée)
- Système de "keep", l'utilisateur doit pouvoir garder une élement sans pour autant l'ajouter à la liste des choses qu'il souhaite faire découvrir
- Création de groupes/cahier - comme Pinterest
- Chat
- Le header dynamique

## Design 
### Polices 
- HelveticaNeue et ses variantes



### Liste de succès (non-exhaustive)
- Nombre de rencontres
- Nombre de films / séries aimées
_ Nombre de films / séries retirées
- Nombre de personnes suivies
- Nombre de personnes qui suivent l'utilisateur
- Nombre de rencontres basées sur la géoloc
- Nombre de rencontres avec des goûts en commun
- Distance parcourue au scroll
- Like qu'une fiche avec un taux de présence supérieur ou égal à 75% parmi ses découvertes
- Post d'un premier commentaire
- Post de 5 commentaires
- Post de 15 commentaires
- Post de X commentaires...
- Update d'un commentaire
- Rencontrer tous ses amis facebook
- Rencontrer X % de ses amis
- Avoir plus de X % de ses amis qui aiment la même série / films que l'utilisateur
- Avoir X % de progression dans une série


Martine Aubry : Vous avez regardé plus de 35 heures d'épisodes. C'est la lutte

## Pods dependancies

- AFNetworking
- MagicalRecord
- FBSDKCoreKit
- FBSDKLoginKit
- FBSDKShareKit
- SWTableViewCell
- CRGradientNavigationBar
- JLTMDbClient 
- Parse
- XCDYouTubeKit