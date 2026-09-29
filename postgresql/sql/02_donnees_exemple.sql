/**
- 02_donnees_exemple.sql : données inventées
- Certaines lignes contiennent des erreurs volontaires pour tester les
- contrôles de 03_controles_qualite.sql (voir docs/regles_gestion.md).
*/
SET search_path = gestion;

INSERT INTO categorie (categorie_id, nom) VALUES
 (1,'Électronique'), (2,'Mobilier'), (3,'Papeterie'), (4,'Accessoires');

INSERT INTO client (client_id, prenom, nom, courriel, telephone, date_naissance, adresse, ville, province, code_postal, date_creation) VALUES
 (1,  'Marie',   'Tremblay',  'marie.tremblay@example.com',  '418-555-0101', '1990-03-12', '10 rue des Lilas',  'Québec',   'QC', 'G1R 2B5', '2025-01-10'),
 (2,  'Jean',    'Gagnon',    'jean.gagnon@example.com',     '418-555-0102', '1985-07-21', '25 av. Cartier',    'Québec',   'QC', 'G1R 2S1', '2025-01-15'),
 (3,  'Sophie',  'Roy',       'sophie.roy@example.com',      '514-555-0103', '1992-11-02', '8 rue Sherbrooke',  'Montréal', 'QC', 'H2X 1E3', '2025-02-01'),
 /** Même courriel que le client 1 (majuscules) et téléphone mal écrit */
 (4,  'Marie',   'Tremblay',  'MARIE.TREMBLAY@EXAMPLE.COM',  '418 555 0101', '1990-03-12', '10 rue des Lilas',  'Québec',   'QC', 'G1R 2B5', '2025-02-05'),
 /** Courriel invalide */
 (5,  'Lucas',   'Bouchard',  'lucas.bouchard@example',      '819-555-0105', '1988-05-30', '3 chemin du Lac',   'Gatineau', 'QC', 'J8X 2T3', '2025-02-10'),
 /** Code postal invalide */
 (6,  'Emma',    'Lavoie',    'emma.lavoie@example.com',     '418-555-0106', '1995-09-14', '77 boul. Laurier',  'Québec',   'QC', 'G1X1Y',   '2025-02-14'),
 /** Ni courriel ni téléphone */
 (7,  'Noah',    'Pelletier', NULL,                          NULL,           '1999-01-25', '5 rue Principale',  'Lévis',    'QC', 'G6V 1A1', '2025-03-01'),
 (8,  'Léa',     'Fortin',    'lea.fortin@example.com',      '450-555-0108', '1993-04-18', '12 rue du Parc',    'Laval',    'QC', 'H7N 2P4', '2025-03-05'),
 /** Date de naissance impossible */
 (9,  'Thomas',  'Gauthier',  'thomas.gauthier@example.com', '613-555-0109', '1890-01-01', '90 King Street',    'Ottawa',   'ON', 'K1P 5G4', '2025-03-10'),
 (10, 'Camille', 'Morin',     'camille.morin@example.com',   '418-555-0110', '1991-12-09', '44 rue Saint-Jean', 'Québec',   'QC', 'G1R 1N4', '2025-03-12'),
 /** Même prénom, nom et date de naissance que le client 2, mais autre courriel */
 (11, 'Jean',    'Gagnon',    'j.gagnon@example.com',        '418-555-0111', '1985-07-21', '25 av. Cartier',    'Québec',   'QC', 'G1R 2S1', '2025-03-20'),
 (12, 'Alexis',  'Côté',      'alexis.cote@example.com',     '418-555-0112', '1997-06-06', '31 rue Champlain',  'Québec',   'QC', 'G1K 3T9', '2025-04-01'),
 /** Courriel avec des espaces avant et après */
 (13, 'Olivier', 'Bergeron',  ' olivier.bergeron@example.com ', '418-555-0113', '1994-02-27', '6 rue de la Paix', 'Québec', 'QC', 'G1K 7P4', '2025-04-02');

INSERT INTO produit (produit_id, sku, nom, categorie_id, prix_unitaire, stock) VALUES
 (1, 'SKU-001', 'Clavier mécanique',   1,  89.99,  40),
 (2, 'SKU-002', 'Souris sans fil',     1,  39.99, 120),
 (3, 'SKU-003', 'Écran 24 pouces',     1, 189.00,  15),
 (4, 'SKU-004', 'Chaise ergonomique',  2, 249.00,   8),
 (5, 'SKU-005', 'Bureau ajustable',    2, 399.00,   5),
 /** Prix à zéro */
 (6, 'SKU-006', 'Lampe de bureau LED', 2,   0.00,  30),
 (7, 'SKU-007', 'Cahier de notes',     3,   4.99, 300),
 /** Même nom que le produit 1 (majuscule et espaces en trop) */
 (8, 'SKU-008', 'clavier  mécanique',  1,  92.00,  10);

INSERT INTO commande (commande_id, client_id, date_commande, date_expedition, statut) VALUES
 (1,  1,  '2026-01-10', '2026-01-12', 'LIVREE'),
 (2,  2,  '2026-01-15', '2026-01-16', 'LIVREE'),
 (3,  3,  '2026-02-01', '2026-02-03', 'EXPEDIEE'),
 (4,  4,  '2026-02-05', NULL,         'PAYEE'),
 /** Expédiée avant la date de commande */
 (5,  5,  '2026-02-10', '2026-02-08', 'LIVREE'),
 /** Livrée mais sans date d'expédition */
 (6,  6,  '2026-02-14', NULL,         'LIVREE'),
 (7,  7,  '2026-03-01', NULL,         'ANNULEE'),
 (8,  8,  '2026-03-05', '2026-03-06', 'EXPEDIEE'),
 (9,  9,  '2026-01-05', NULL,         'PAYEE'),
 (10, 10, '2026-03-20', '2026-03-22', 'LIVREE'),
 (11, 13, '2026-04-02', '2026-04-03', 'LIVREE'),
 (12, 1,  '2026-04-15', '2026-04-16', 'LIVREE'),
 /** Aucune ligne pour cette commande */
 (13, 2,  '2026-05-02', NULL,         'PAYEE'),
 /** Date de commande dans le futur */
 (14, 3,  '2031-05-10', NULL,         'PAYEE');

INSERT INTO ligne_commande (commande_id, produit_id, quantite, prix_unitaire) VALUES
 (1, 1, 1,  89.99), (1, 2, 1, 39.99),
 (2, 3, 2, 189.00),
 (3, 4, 1, 249.00),
 (4, 2, 3,  39.99),
 (5, 1, 1,  89.99),
 (6, 7, 10,  4.99), (6, 6, 1,  0.00),
 (7, 5, 1, 399.00),
 /** Prix facturé 150 au lieu de 189 (plus de 20 % d'écart) */
 (8, 3, 1, 150.00),
 /** Quantité de 500, probablement une erreur de saisie */
 (9, 7, 500, 4.99),
 (10, 2, 2, 39.99), (10, 7, 3, 4.99),
 (11, 4, 1, 249.00), (11, 1, 1, 89.99),
 (12, 3, 1, 189.00),
 (14, 2, 1, 39.99);

/** Mise à jour des compteurs SERIAL, car on a inséré des identifiants à la main */
SELECT setval('categorie_categorie_id_seq', (SELECT MAX(categorie_id) FROM categorie));
SELECT setval('client_client_id_seq',       (SELECT MAX(client_id)    FROM client));
SELECT setval('produit_produit_id_seq',     (SELECT MAX(produit_id)   FROM produit));
SELECT setval('commande_commande_id_seq',   (SELECT MAX(commande_id)  FROM commande));
