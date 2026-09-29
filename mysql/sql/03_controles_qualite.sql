/**
- 03_controles_qualite.sql : contrôles de qualité des données (MySQL)
- v_anomalies : une ligne par enregistrement fautif
- v_rapport_qualite : nombre d'anomalies par règle
- Les règles sont décrites dans docs/regles_gestion.md
-
- Attention : la collation par défaut (utf8mb4_0900_ai_ci) ne fait pas de
- différence entre majuscules et minuscules. Pour DQ-02, on compare donc
- avec la collation utf8mb4_0900_bin, sinon MARIE@X.COM serait considéré
- comme égal à marie@x.com et rien ne serait détecté.
*/
SET NAMES utf8mb4;
USE gestion;

CREATE OR REPLACE VIEW v_anomalies AS

/** DQ-01 : courriel invalide (les espaces avant et après sont ignorés) */
SELECT 'DQ-01' AS regle_id,
       'Courriel invalide' AS regle,
       'client' AS table_cible,
       CAST(c.client_id AS CHAR) AS enregistrement_id,
       c.courriel AS detail
FROM client c
WHERE NULLIF(TRIM(c.courriel), '') IS NOT NULL
  AND TRIM(c.courriel) NOT REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$'

UNION ALL
/** DQ-02 : courriel avec des espaces ou des majuscules */
SELECT 'DQ-02', 'Courriel non normalisé', 'client', CAST(c.client_id AS CHAR), CONCAT('[', c.courriel, ']')
FROM client c
WHERE c.courriel COLLATE utf8mb4_0900_bin <> LOWER(TRIM(c.courriel)) COLLATE utf8mb4_0900_bin

UNION ALL
/** DQ-03 : même courriel utilisé par plusieurs clients */
SELECT 'DQ-03', 'Courriel en double', 'client', CAST(c.client_id AS CHAR), LOWER(TRIM(c.courriel))
FROM client c
WHERE LOWER(TRIM(c.courriel)) IN (
        SELECT d.cle
        FROM (SELECT LOWER(TRIM(courriel)) AS cle FROM client WHERE courriel IS NOT NULL) d
        GROUP BY d.cle
        HAVING COUNT(*) > 1)

UNION ALL
/** DQ-04 : même prénom, nom et date de naissance */
SELECT 'DQ-04', 'Doublon probable de client', 'client', CAST(c.client_id AS CHAR),
       CONCAT(c.prenom, ' ', c.nom, ' ', c.date_naissance)
FROM client c
WHERE (LOWER(TRIM(c.prenom)), LOWER(TRIM(c.nom)), c.date_naissance) IN (
        SELECT d.prenom_n, d.nom_n, d.date_naissance
        FROM (SELECT LOWER(TRIM(prenom)) AS prenom_n, LOWER(TRIM(nom)) AS nom_n, date_naissance
              FROM client WHERE date_naissance IS NOT NULL) d
        GROUP BY d.prenom_n, d.nom_n, d.date_naissance
        HAVING COUNT(*) > 1)

UNION ALL
/** DQ-05 : ni courriel ni téléphone */
SELECT 'DQ-05', 'Client sans courriel ni téléphone', 'client', CAST(c.client_id AS CHAR), 'Aucun contact'
FROM client c
WHERE NULLIF(TRIM(c.courriel), '') IS NULL AND NULLIF(TRIM(c.telephone), '') IS NULL

UNION ALL
/** DQ-06 : téléphone qui n'est pas au format 999-999-9999 */
SELECT 'DQ-06', 'Téléphone hors format', 'client', CAST(c.client_id AS CHAR), c.telephone
FROM client c
WHERE c.telephone NOT REGEXP '^[0-9]{3}-[0-9]{3}-[0-9]{4}$'

UNION ALL
/** DQ-07 : code postal canadien invalide (format A1A 1A1) */
SELECT 'DQ-07', 'Code postal invalide', 'client', CAST(c.client_id AS CHAR), c.code_postal
FROM client c
WHERE c.code_postal NOT REGEXP '^[A-Za-z][0-9][A-Za-z] ?[0-9][A-Za-z][0-9]$'

UNION ALL
/** DQ-08 : date de naissance dans le futur ou il y a plus de 120 ans */
SELECT 'DQ-08', 'Date de naissance impossible', 'client', CAST(c.client_id AS CHAR), CAST(c.date_naissance AS CHAR)
FROM client c
WHERE c.date_naissance > CURDATE()
   OR c.date_naissance < DATE_SUB(CURDATE(), INTERVAL 120 YEAR)

UNION ALL
/** DQ-09 : deux produits avec le même nom (sans tenir compte de la casse ni des espaces en trop) */
SELECT 'DQ-09', 'Doublon probable de produit', 'produit', CAST(p.produit_id AS CHAR), p.nom
FROM produit p
WHERE LOWER(REGEXP_REPLACE(TRIM(p.nom), '[[:space:]]+', ' ')) IN (
        SELECT d.cle
        FROM (SELECT LOWER(REGEXP_REPLACE(TRIM(nom), '[[:space:]]+', ' ')) AS cle FROM produit) d
        GROUP BY d.cle
        HAVING COUNT(*) > 1)

UNION ALL
/** DQ-10 : produit dont le prix est à zéro */
SELECT 'DQ-10', 'Prix du produit à zéro', 'produit', CAST(p.produit_id AS CHAR), p.nom
FROM produit p
WHERE p.prix_unitaire = 0

UNION ALL
/** DQ-11 : commande expédiée avant la date de commande */
SELECT 'DQ-11', 'Expédition avant la commande', 'commande', CAST(o.commande_id AS CHAR),
       CONCAT('Commande le ', o.date_commande, ', expédition le ', o.date_expedition)
FROM commande o
WHERE o.date_expedition < o.date_commande

UNION ALL
/** DQ-12 : statut EXPEDIEE ou LIVREE sans date d'expédition */
SELECT 'DQ-12', 'Statut avancé sans date d''expédition', 'commande', CAST(o.commande_id AS CHAR), o.statut
FROM commande o
WHERE o.statut IN ('EXPEDIEE','LIVREE') AND o.date_expedition IS NULL

UNION ALL
/** DQ-13 : commande sans aucune ligne */
SELECT 'DQ-13', 'Commande sans ligne', 'commande', CAST(o.commande_id AS CHAR), 'Aucune ligne'
FROM commande o
WHERE NOT EXISTS (SELECT 1 FROM ligne_commande l WHERE l.commande_id = o.commande_id)

UNION ALL
/** DQ-14 : prix facturé différent du prix du catalogue de plus de 20 % */
SELECT 'DQ-14', 'Écart de prix avec le catalogue', 'ligne_commande', CONCAT(l.commande_id, '-', l.produit_id),
       CONCAT('Facturé ', l.prix_unitaire, ', catalogue ', p.prix_unitaire)
FROM ligne_commande l
JOIN produit p ON p.produit_id = l.produit_id
WHERE p.prix_unitaire > 0
  AND ABS(l.prix_unitaire - p.prix_unitaire) / p.prix_unitaire > 0.20

UNION ALL
/** DQ-15 : quantité de plus de 100 sur une ligne */
SELECT 'DQ-15', 'Quantité anormale', 'ligne_commande', CONCAT(l.commande_id, '-', l.produit_id),
       CONCAT('Quantité : ', l.quantite)
FROM ligne_commande l
WHERE l.quantite > 100

UNION ALL
/** DQ-16 : date de commande dans le futur */
SELECT 'DQ-16', 'Date de commande dans le futur', 'commande', CAST(o.commande_id AS CHAR), CAST(o.date_commande AS CHAR)
FROM commande o
WHERE o.date_commande > CURDATE();

/**
- Résumé : nombre d'anomalies par règle
- Une règle sans anomalie n'apparaît pas dans le résultat.
*/
CREATE OR REPLACE VIEW v_rapport_qualite AS
SELECT regle_id, regle, table_cible, COUNT(*) AS nb_anomalies
FROM v_anomalies
GROUP BY regle_id, regle, table_cible;
