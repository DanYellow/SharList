Shound - Faites découvrir au monde ce que vous aimez
========
Shound - Introduce the world what you like
========

// Compte facebook de test
gqsnkky_wongsky_1415569231@tfbnw.net : 123456789C

## Mises à jour

### v 1.1.0

- Gestion de Betaseries, vous pouvez ajouter une série sur votre compte Betaseries
- Affichage du taux de "match" entre votre liste et celle d'un utilisateur tierce
- Possibilité de voir l'image de profil Facebook d'un utilisateur rencontré
- Correction de bugs

### v 1.1.1

- Ajout de notifications lors de la mise à jour d'un favori
- Améliorations

### v 1.1.2

- Correction de bugs
- Amélioration de l'expérience utilisateur
- Correction d'un bug critique qui faisait planter l'application
- Ajout de la date de sortie du prochain épisode d'une série
- Différentiation des différents types de découvertes



## Améliorations potentielles
- Gérer le système de géoloc lors de l'actualisation par bouton (ça garde l'ancienne position) - **done !!!!**
- Système de succès (voir liste)
- Indiquer les comptes premium
- Voir la liste de followers
- Ajouter la clé "last_air_date": "2015-06-04", pour les séries -> savoir la date de diffusion du dernier épisode - done

## API

### Media

#### The movie DB
Cette API est l'API tierce principale de l'application, elle permet de récupérer les données des films et des séries.
Clef API The movie DB : f09cf27014943c8114e504bf5fbd352b (http://docs.themoviedb.apiary.io)


Clef API Betaseries : 8bc04c11b4c283b72a3fa48cfc6149f3 (https://www.betaseries.com/api/docs)
- Ajouter / retirer une série au compte betaserie de l'utilisateur : https://api.betaseries.com/shows/display
-- Paramètres : imdb_id : id imdb de la série (fournie par l'API de Shound) | client_id : clef d'api pour Betaseries


## Design 
### Polices 
- HelveticaNeue et ses variantes



### Liste de succès (non-exhaustive)
- Nombre de rencontres
- Nombre de films / séries aimées
_ Nombre de films / séries retirées
- Nombre de personnes suivies
- Nombre de rencontres basées sur la géoloc
- Nombre de rencontres avec des goûts en commun
- Distance parcourue au scroll

## Pods dependancies

- AFNetworking
- MagicalRecord
- Facebook-iOS-SDK
- SWTableViewCell
- TDBadgedCell (plus utilisé)
- CRGradientNavigationBar
- JLTMDbClient
- Parse
- XCDYouTubeKit