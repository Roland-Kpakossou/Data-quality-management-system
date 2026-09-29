/**
- 01_schema.sql : modèle relationnel normalisé (3NF) - PostgreSQL
- Domaine : gestion des clients, produits et commandes
*/

DROP SCHEMA IF EXISTS gestion CASCADE;
CREATE SCHEMA gestion;
SET search_path = gestion;

/** Catégories de produits */
CREATE TABLE categorie (
    categorie_id  SERIAL       PRIMARY KEY,
    nom           VARCHAR(60)  NOT NULL UNIQUE
);

/**
- Clients
- Il n'y a pas de contrainte UNIQUE sur le courriel. Les doublons sont
- acceptés à l'insertion, puis repérés par les contrôles de qualité (DQ-03).
- Après le nettoyage, on pourrait ajouter un index unique.
*/
CREATE TABLE client (
    client_id       SERIAL       PRIMARY KEY,
    prenom          VARCHAR(60)  NOT NULL,
    nom             VARCHAR(60)  NOT NULL,
    courriel        VARCHAR(120),
    telephone       VARCHAR(20),
    date_naissance  DATE,
    adresse         VARCHAR(120),
    ville           VARCHAR(60),
    province        CHAR(2),
    code_postal     VARCHAR(10),
    date_creation   DATE         NOT NULL DEFAULT CURRENT_DATE
);

/** Produits */
CREATE TABLE produit (
    produit_id     SERIAL         PRIMARY KEY,
    sku            VARCHAR(20)    NOT NULL UNIQUE,
    nom            VARCHAR(100)   NOT NULL,
    categorie_id   INTEGER        NOT NULL REFERENCES categorie (categorie_id),
    prix_unitaire  NUMERIC(10,2)  NOT NULL CHECK (prix_unitaire >= 0),
    stock          INTEGER        NOT NULL DEFAULT 0 CHECK (stock >= 0)
);

/** Commandes */
CREATE TABLE commande (
    commande_id      SERIAL       PRIMARY KEY,
    client_id        INTEGER      NOT NULL REFERENCES client (client_id),
    date_commande    DATE         NOT NULL,
    date_expedition  DATE,
    statut           VARCHAR(12)  NOT NULL
        CHECK (statut IN ('EN_ATTENTE','PAYEE','EXPEDIEE','LIVREE','ANNULEE'))
);

/**
- Lignes de commande
- prix_unitaire est le prix facturé au moment de la vente. Ce n'est pas
- une redondance de produit.prix_unitaire : le prix du catalogue peut changer
- sans modifier les commandes déjà faites.
*/
CREATE TABLE ligne_commande (
    commande_id    INTEGER        NOT NULL REFERENCES commande (commande_id) ON DELETE CASCADE,
    produit_id     INTEGER        NOT NULL REFERENCES produit (produit_id),
    quantite       INTEGER        NOT NULL CHECK (quantite > 0),
    prix_unitaire  NUMERIC(10,2)  NOT NULL CHECK (prix_unitaire >= 0),
    PRIMARY KEY (commande_id, produit_id)
);

CREATE INDEX idx_commande_client   ON commande (client_id);
CREATE INDEX idx_produit_categorie ON produit (categorie_id);
