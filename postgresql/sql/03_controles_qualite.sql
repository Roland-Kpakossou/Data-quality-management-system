/**
- 03_controles_qualite.sql : contrôles de qualité des données (PostgreSQL)
- v_anomalies : une ligne par enregistrement fautif
- v_rapport_qualite : nombre d'anomalies par règle
- Les règles sont décrites dans docs/regles_gestion.md
*/
SET search_path = gestion;

CREATE OR REPLACE VIEW v_anomalies AS

/** DQ-01 : courriel invalide (les espaces avant et après sont ignorés) */
SELECT 'DQ-01'::varchar AS regle_id,
       'Courriel invalide'::varchar AS regle,
       'client'::varchar AS table_cible,
       c.client_id::text AS enregistrement_id,
       c.courriel::text AS detail
FROM client c
WHERE NULLIF(trim(c.courriel), '') IS NOT NULL
  AND trim(c.courriel) !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'

UNION ALL
/** DQ-02 : courriel avec des espaces ou des majuscules */
SELECT 'DQ-02', 'Courriel non normalisé', 'client', c.client_id::text, '[' || c.courriel || ']'
FROM client c
WHERE c.courriel <> lower(trim(c.courriel))

UNION ALL
/** DQ-03 : même courriel utilisé par plusieurs clients */
SELECT 'DQ-03', 'Courriel en double', 'client', c.client_id::text, lower(trim(c.courriel))
FROM client c
WHERE lower(trim(c.courriel)) IN (
        SELECT lower(trim(courriel)) FROM client
        WHERE courriel IS NOT NULL
        GROUP BY lower(trim(courriel))
        HAVING COUNT(*) > 1)

UNION ALL
/** DQ-04 : même prénom, nom et date de naissance */
SELECT 'DQ-04', 'Doublon probable de client', 'client', c.client_id::text,
       c.prenom || ' ' || c.nom || ' ' || c.date_naissance
FROM client c
WHERE (lower(trim(c.prenom)), lower(trim(c.nom)), c.date_naissance) IN (
        SELECT lower(trim(prenom)), lower(trim(nom)), date_naissance FROM client
        WHERE date_naissance IS NOT NULL
        GROUP BY lower(trim(prenom)), lower(trim(nom)), date_naissance
        HAVING COUNT(*) > 1)

UNION ALL
/** DQ-05 : ni courriel ni téléphone */
SELECT 'DQ-05', 'Client sans courriel ni téléphone', 'client', c.client_id::text, 'Aucun contact'
FROM client c
WHERE NULLIF(trim(c.courriel), '') IS NULL AND NULLIF(trim(c.telephone), '') IS NULL

UNION ALL
/** DQ-06 : téléphone qui n'est pas au format 999-999-9999 */
SELECT 'DQ-06', 'Téléphone hors format', 'client', c.client_id::text, c.telephone
FROM client c
WHERE c.telephone !~ '^[0-9]{3}-[0-9]{3}-[0-9]{4}$'

UNION ALL
/** DQ-07 : code postal canadien invalide (format A1A 1A1) */
SELECT 'DQ-07', 'Code postal invalide', 'client', c.client_id::text, c.code_postal
FROM client c
WHERE c.code_postal !~ '^[A-Za-z][0-9][A-Za-z] ?[0-9][A-Za-z][0-9]$'

UNION ALL
/** DQ-08 : date de naissance dans le futur ou il y a plus de 120 ans */
SELECT 'DQ-08', 'Date de naissance impossible', 'client', c.client_id::text, c.date_naissance::text
FROM client c
WHERE c.date_naissance > CURRENT_DATE
   OR c.date_naissance < CURRENT_DATE - INTERVAL '120 years'

UNION ALL
/** DQ-09 : deux produits avec le même nom (sans tenir compte de la casse ni des espaces en trop) */
SELECT 'DQ-09', 'Doublon probable de produit', 'produit', p.produit_id::text, p.nom
FROM produit p
WHERE lower(regexp_replace(trim(p.nom), '\s+', ' ', 'g')) IN (
        SELECT lower(regexp_replace(trim(nom), '\s+', ' ', 'g')) FROM produit
        GROUP BY lower(regexp_replace(trim(nom), '\s+', ' ', 'g'))
        HAVING COUNT(*) > 1)

UNION ALL
/** DQ-10 : produit dont le prix est à zéro */
SELECT 'DQ-10', 'Prix du produit à zéro', 'produit', p.produit_id::text, p.nom
FROM produit p
WHERE p.prix_unitaire = 0

UNION ALL
/** DQ-11 : commande expédiée avant la date de commande */
SELECT 'DQ-11', 'Expédition avant la commande', 'commande', o.commande_id::text,
       'Commande le ' || o.date_commande || ', expédition le ' || o.date_expedition
FROM commande o
WHERE o.date_expedition < o.date_commande

UNION ALL
/** DQ-12 : statut EXPEDIEE ou LIVREE sans date d'expédition */
SELECT 'DQ-12', 'Statut avancé sans date d''expédition', 'commande', o.commande_id::text, o.statut
FROM commande o
WHERE o.statut IN ('EXPEDIEE','LIVREE') AND o.date_expedition IS NULL

UNION ALL
/** DQ-13 : commande sans aucune ligne */
SELECT 'DQ-13', 'Commande sans ligne', 'commande', o.commande_id::text, 'Aucune ligne'
FROM commande o
WHERE NOT EXISTS (SELECT 1 FROM ligne_commande l WHERE l.commande_id = o.commande_id)

UNION ALL
/** DQ-14 : prix facturé différent du prix du catalogue de plus de 20 % */
SELECT 'DQ-14', 'Écart de prix avec le catalogue', 'ligne_commande', l.commande_id || '-' || l.produit_id,
       'Facturé ' || l.prix_unitaire || ', catalogue ' || p.prix_unitaire
FROM ligne_commande l
JOIN produit p ON p.produit_id = l.produit_id
WHERE p.prix_unitaire > 0
  AND ABS(l.prix_unitaire - p.prix_unitaire) / p.prix_unitaire > 0.20

UNION ALL
/** DQ-15 : quantité de plus de 100 sur une ligne */
SELECT 'DQ-15', 'Quantité anormale', 'ligne_commande', l.commande_id || '-' || l.produit_id,
       'Quantité : ' || l.quantite
FROM ligne_commande l
WHERE l.quantite > 100

UNION ALL
/** DQ-16 : date de commande dans le futur */
SELECT 'DQ-16', 'Date de commande dans le futur', 'commande', o.commande_id::text, o.date_commande::text
FROM commande o
WHERE o.date_commande > CURRENT_DATE;

/**
- Résumé : nombre d'anomalies par règle
- Une règle sans anomalie n'apparaît pas dans le résultat.
*/
CREATE OR REPLACE VIEW v_rapport_qualite AS
SELECT regle_id, regle, table_cible, COUNT(*) AS nb_anomalies
FROM v_anomalies
GROUP BY regle_id, regle, table_cible;
