# Projet DS_9 - Déploiement d'un traitement Big Data sur AWS EMR

Ce dépôt contient mon travail pour le projet OpenClassrooms "Déployez un modèle dans le cloud".

L'objectif du projet n'était pas d'entraîner un modèle de classification final, mais de mettre en place une première chaîne de traitement Big Data capable de monter en charge pour un cas d'usage AgriTech autour de la reconnaissance de fruits.

## Contexte du projet

La startup fictive **Fruits!** souhaite proposer une application mobile permettant de photographier un fruit afin d'obtenir des informations sur celui-ci. Dans ce cadre, le besoin principal de ce projet est de préparer une architecture de traitement distribuée, compatible avec un futur passage à l'échelle.

Le cadre d'évaluation demandait notamment de :
- identifier les briques Cloud pertinentes pour un projet Big Data ;
- mettre en place un environnement conforme au RGPD ;
- exécuter la chaîne de traitement dans le cloud ;
- stocker les données d'entrée et de sortie dans un stockage cloud ;
- produire un script PySpark exploitable sur une architecture distribuée.

## Point de départ

Le notebook n'a pas été construit from scratch. Une base de travail était fournie dans les ressources pédagogiques du projet, correspondant au travail initial d'un alternant.

Je me suis appuyé sur ce notebook fourni comme ressource d'entrée, puis je l'ai adapté pour en faire une version exploitable dans mon environnement de travail et dans AWS EMR.

En pratique, ma contribution sur la logique de traitement a consisté principalement à :
- conserver la structure générale du notebook fourni ;
- ajouter l'étape de **scaling** des features ;
- ajouter l'étape de **PCA sous PySpark** pour la réduction de dimension.

## Architecture mise en place

L'architecture retenue repose sur des services AWS situés en Europe (Paris) afin de respecter la contrainte RGPD du projet :
- **S3** pour stocker les données d'entrée et les résultats ;
- **EMR** pour exécuter le traitement distribué en PySpark ;
- **IAM** pour gérer les droits d'accès entre le cluster et les ressources AWS ;
- un environnement de test local sous Linux / VM pour limiter les coûts pendant la phase de mise au point.

## Pipeline de traitement

Version de Python utilisée : 3.12.3

La chaîne de traitement implémentée suit la logique suivante :
- lecture des images et des labels ;
- extraction de features via **MobileNetV2** ;
- vectorisation des features pour Spark ;
- **standardisation des features** avec `StandardScaler` ;
- **réduction de dimension avec PCA** ;
- sauvegarde des résultats dans un format exploitable sur le stockage cible.

## Environnement et exécution

Le dépôt contient plusieurs notebooks et scripts utilitaires :
- [Mode_operatoire/P9_Notebook_Linux_EMR_PySpark_local.ipynb](Mode_operatoire/P9_Notebook_Linux_EMR_PySpark_local.ipynb) : travail et essais en local, avec un dataset réduit ;
- [Mode_operatoire/P9_Notebook_Linux_EMR_PySpark_remote.ipynb](Mode_operatoire/P9_Notebook_Linux_EMR_PySpark_remote.ipynb) : notebook uploadé sur s3 pour exécution dans le cluster ;
- [bootstrap-emr.sh](/c:/Applications/Git-OpenClassrooms/DS_9/bootstrap-emr.sh) : bootstrap simple, deprecated ;
- [bootstrap-emr-venv.sh](/c:/Applications/Git-OpenClassrooms/DS_9/bootstrap-emr-venv.sh) : bootstrap avec environnement Python dédié, installation de TensforFlow incluse dans le bootstrap pour éviter les problèmes de versions avec le TensforFlow fourni par aws lors de la création d'un cluster.

Le cluster EMR n'est pas maintenu actif en permanence. Il est résilié pour limiter les coûts, mais il peut être recréé par clonage de la configuration existante.

Ordre de grandeur opérationnel :
- clonage / recréation du cluster : environ **15 minutes** ;
- exécution du notebook sur le cluster : environ **15 minutes** supplémentaires.

Cette organisation permet de respecter la contrainte budgétaire du projet en réservant EMR aux démonstrations et aux tests finaux.

## Pourquoi une phase locale avant EMR

Le notebook fourni étant destiné à un environnement Linux / Spark, les mises au point ont intérêt à être faites localement dans un environnement proche de la cible avant exécution sur AWS. Cela permet de corriger plus vite les erreurs de code et de réduire les coûts cloud. Les opérations en local ont été effectuées sur un dataset de 300 images aléatoires seulement pour gagner du temps, l'objectif étant simplement de valider la logique du process.
