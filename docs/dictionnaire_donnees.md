# Dictionnaire de données

Les types sont ceux de PostgreSQL. En MySQL, `SERIAL` devient `INT AUTO_INCREMENT` et `NUMERIC` devient `DECIMAL`.

PK : clé primaire, FK : clé étrangère, UK : valeur unique, NN : obligatoire.

## categorie

Catégories de classement des produits.

| Colonne | Type | Contraintes | Description |
|---|---|---|---|
| `categorie_id` | SERIAL | PK | Identifiant de la catégorie |
| `nom` | VARCHAR(60) | NN, UK | Nom de la catégorie (ex. Mobilier) |

## client

| Colonne | Type | Contraintes | Description |
|---|---|---|---|
| `client_id` | SERIAL | PK | Identifiant du client |
| `prenom` | VARCHAR(60) | NN | Prénom |
| `nom` | VARCHAR(60) | NN | Nom de famille |
| `courriel` | VARCHAR(120) | | Adresse courriel, en minuscules et sans espaces (DQ-01, DQ-02, DQ-03) |
| `telephone` | VARCHAR(20) | | Téléphone au format 999-999-9999 (DQ-06) |
| `date_naissance` | DATE | | Date de naissance (DQ-08) |
| `adresse` | VARCHAR(120) | | Adresse civique |
| `ville` | VARCHAR(60) | | Ville |
| `province` | CHAR(2) | | Code de la province (ex. QC) |
| `code_postal` | VARCHAR(10) | | Code postal canadien, format A1A 1A1 (DQ-07) |
| `date_creation` | DATE | NN, défaut la date du jour | Date de création de la fiche |

## produit

| Colonne | Type | Contraintes | Description |
|---|---|---|---|
| `produit_id` | SERIAL | PK | Identifiant du produit |
| `sku` | VARCHAR(20) | NN, UK | Code du produit |
| `nom` | VARCHAR(100) | NN | Nom du produit (DQ-09) |
| `categorie_id` | INTEGER | NN, FK vers `categorie` | Catégorie du produit |
| `prix_unitaire` | NUMERIC(10,2) | NN, >= 0 | Prix du catalogue en dollars (DQ-10) |
| `stock` | INTEGER | NN, >= 0, défaut 0 | Quantité en stock |

## commande

| Colonne | Type | Contraintes | Description |
|---|---|---|---|
| `commande_id` | SERIAL | PK | Identifiant de la commande |
| `client_id` | INTEGER | NN, FK vers `client` | Client qui a passé la commande |
| `date_commande` | DATE | NN | Date de la commande (DQ-16) |
| `date_expedition` | DATE | | Date d'expédition (DQ-11, DQ-12) |
| `statut` | VARCHAR(12) | NN | EN_ATTENTE, PAYEE, EXPEDIEE, LIVREE ou ANNULEE |

## ligne_commande

Un produit dans une commande.

| Colonne | Type | Contraintes | Description |
|---|---|---|---|
| `commande_id` | INTEGER | PK, FK vers `commande` | Commande |
| `produit_id` | INTEGER | PK, FK vers `produit` | Produit commandé |
| `quantite` | INTEGER | NN, > 0 | Quantité commandée (DQ-15) |
| `prix_unitaire` | NUMERIC(10,2) | NN, >= 0 | Prix facturé au moment de la vente (DQ-14) |

## Vues

| Vue | Description |
|---|---|
| `v_anomalies` | Une ligne par enregistrement fautif : `regle_id`, `regle`, `table_cible`, `enregistrement_id`, `detail`. Pour `ligne_commande`, l'identifiant s'écrit `commande_id-produit_id`. |
| `v_rapport_qualite` | Nombre d'anomalies par règle. |
