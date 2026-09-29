/**
- 01_schema.sql : modèle relationnel normalisé (3NF) - MySQL 8.0.17 ou plus
- Domaine : gestion des clients, produits et commandes
- Les contraintes CHECK sont appliquées à partir de MySQL 8.0.16.
*/
SET NAMES utf8mb4;

DROP DATABASE IF EXISTS gestion;
CREATE DATABASE gestion CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE gestion;

/** Catégories de produits */
CREATE TABLE categorie (
    categorie_id  INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nom           VARCHAR(60)  NOT NULL UNIQUE
) ENGINE=InnoDB;

/**
- Clients
- Il n'y a pas de contrainte UNIQUE sur le courriel. Les doublons sont
- acceptés à l'insertion, puis repérés par les contrôles de qualité (DQ-03).
- Après le nettoyage, on pourrait ajouter un index unique.
*/
CREATE TABLE client (
    client_id       INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    prenom          VARCHAR(60)  NOT NULL,
    nom             VARCHAR(60)  NOT NULL,
    courriel        VARCHAR(120),
    telephone       VARCHAR(20),
    date_naissance  DATE,
    adresse         VARCHAR(120),
    ville           VARCHAR(60),
    province        CHAR(2),
    code_postal     VARCHAR(10),
    date_creation   DATE         NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

/** Produits */
CREATE TABLE produit (
    produit_id     INT            NOT NULL AUTO_INCREMENT PRIMARY KEY,
    sku            VARCHAR(20)    NOT NULL UNIQUE,
    nom            VARCHAR(100)   NOT NULL,
    categorie_id   INT            NOT NULL,
    prix_unitaire  DECIMAL(10,2)  NOT NULL,
    stock          INT            NOT NULL DEFAULT 0,
    CONSTRAINT fk_produit_categorie FOREIGN KEY (categorie_id) REFERENCES categorie (categorie_id),
    CONSTRAINT ck_produit_prix  CHECK (prix_unitaire >= 0),
    CONSTRAINT ck_produit_stock CHECK (stock >= 0)
) ENGINE=InnoDB;

/** Commandes */
CREATE TABLE commande (
    commande_id      INT          NOT NULL AUTO_INCREMENT PRIMARY KEY,
    client_id        INT          NOT NULL,
    date_commande    DATE         NOT NULL,
    date_expedition  DATE,
    statut           VARCHAR(12)  NOT NULL,
    CONSTRAINT fk_commande_client FOREIGN KEY (client_id) REFERENCES client (client_id),
    CONSTRAINT ck_commande_statut CHECK (statut IN ('EN_ATTENTE','PAYEE','EXPEDIEE','LIVREE','ANNULEE'))
) ENGINE=InnoDB;

/**
- Lignes de commande
- prix_unitaire est le prix facturé au moment de la vente. Ce n'est pas
- une redondance de produit.prix_unitaire : le prix du catalogue peut changer
- sans modifier les commandes déjà faites.
*/
CREATE TABLE ligne_commande (
    commande_id    INT            NOT NULL,
    produit_id     INT            NOT NULL,
    quantite       INT            NOT NULL,
    prix_unitaire  DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (commande_id, produit_id),
    CONSTRAINT fk_ligne_commande FOREIGN KEY (commande_id) REFERENCES commande (commande_id) ON DELETE CASCADE,
    CONSTRAINT fk_ligne_produit  FOREIGN KEY (produit_id)  REFERENCES produit (produit_id),
    CONSTRAINT ck_ligne_quantite CHECK (quantite > 0),
    CONSTRAINT ck_ligne_prix     CHECK (prix_unitaire >= 0)
) ENGINE=InnoDB;

CREATE INDEX idx_commande_client   ON commande (client_id);
CREATE INDEX idx_produit_categorie ON produit (categorie_id);
