# Règles de gestion et de qualité

## Règles de gestion

| Id | Règle | Comment elle est appliquée |
|---|---|---|
| RG-01 | Une commande appartient à un seul client. Un client peut avoir 0 ou plusieurs commandes. | Clé étrangère `commande.client_id` |
| RG-02 | Une commande contient au moins une ligne. | Contrôle DQ-13 (pas bloqué par la base, car la commande est créée avant ses lignes) |
| RG-03 | Un produit appartient à une seule catégorie. | `produit.categorie_id` obligatoire, avec clé étrangère |
| RG-04 | Le prix et le stock ne sont pas négatifs, la quantité commandée est plus grande que 0. | Contraintes `CHECK` |
| RG-05 | Statuts possibles : EN_ATTENTE, PAYEE, EXPEDIEE, LIVREE, ANNULEE. | Contrainte `CHECK` |
| RG-06 | Une commande EXPEDIEE ou LIVREE a une date d'expédition, qui ne vient pas avant la date de commande. | Contrôles DQ-11 et DQ-12 |
| RG-07 | Le prix facturé est gardé sur la ligne de commande. Il ne devrait pas s'éloigner de plus de 20 % du prix du catalogue. | Contrôle DQ-14 |
| RG-08 | Chaque produit a un SKU unique. | `UNIQUE` sur `sku` |
| RG-09 | On doit pouvoir joindre un client par courriel ou par téléphone. | Contrôle DQ-05 |

## Règles de qualité

Chaque règle correspond à une requête de la vue `v_anomalies`.

| Id | Ce qu'on cherche | Quoi faire |
|---|---|---|
| DQ-01 | Courriel invalide | Corriger le courriel |
| DQ-02 | Courriel avec des espaces ou des majuscules | Correction automatique (`04_corrections_exemple.sql`) |
| DQ-03 | Même courriel pour plusieurs clients | Vérifier, puis fusionner les fiches |
| DQ-04 | Même prénom, nom et date de naissance | Vérifier à la main, ce n'est pas toujours la même personne |
| DQ-05 | Client sans courriel ni téléphone | Compléter la fiche |
| DQ-06 | Téléphone qui n'est pas au format 999-999-9999 | Correction automatique s'il y a 10 chiffres |
| DQ-07 | Code postal invalide | Corriger le code postal |
| DQ-08 | Date de naissance dans le futur ou il y a plus de 120 ans | Corriger ou mettre NULL |
| DQ-09 | Produits avec le même nom | Fusionner ou renommer |
| DQ-10 | Produit avec un prix à zéro | Mettre le bon prix |
| DQ-11 | Expédition avant la date de commande | Corriger la date |
| DQ-12 | Statut EXPEDIEE ou LIVREE sans date d'expédition | Ajouter la date ou changer le statut |
| DQ-13 | Commande sans ligne | Ajouter les lignes ou annuler la commande |
| DQ-14 | Prix facturé à plus de 20 % d'écart avec le catalogue | Vérifier si c'est une remise ou une erreur |
| DQ-15 | Quantité de plus de 100 sur une ligne | Confirmer la quantité |
| DQ-16 | Date de commande dans le futur | Corriger la date |

## Erreurs mises dans les données d'exemple

| Règle | Enregistrements |
|---|---|
| DQ-01 | client 5 |
| DQ-02 | clients 4 et 13 |
| DQ-03 | clients 1 et 4 |
| DQ-04 | clients 1, 4, 2 et 11 |
| DQ-05 | client 7 |
| DQ-06 | client 4 |
| DQ-07 | client 6 |
| DQ-08 | client 9 |
| DQ-09 | produits 1 et 8 |
| DQ-10 | produit 6 |
| DQ-11 | commande 5 |
| DQ-12 | commande 6 |
| DQ-13 | commande 13 |
| DQ-14 | ligne 8-3 (commande 8, produit 3) |
| DQ-15 | ligne 9-7 (commande 9, produit 7) |
| DQ-16 | commande 14 |

