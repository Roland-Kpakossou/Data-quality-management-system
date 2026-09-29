# Système de gestion et de qualité des données

Projet personnel. C'est une petite base de données relationnelle (3NF) pour gérer des clients, des produits et des commandes, avec des requêtes SQL qui repèrent des erreurs de saisie, des doublons et des incohérences. Le projet est fait en PostgreSQL et en MySQL.

Les données sont inventées. Elles contiennent des erreurs volontaires pour tester les requêtes. C'est un projet d'apprentissage : les règles sont simples et ne couvrent pas tous les cas possibles.

## Contenu
- `01_schema.sql` crée les tables, les clés et les contraintes.
- `02_donnees_exemple.sql` ajoute des données inventées, avec des erreurs.
- `03_controles_qualite.sql` crée les vues `v_anomalies` et `v_rapport_qualite`.
- `04_corrections_exemple.sql` corrige ce qui peut l'être sans risque (facultatif).

## Modèle de données

Le détail des colonnes est dans [docs/modele_donnees.md](docs/modele_donnees.md) et [docs/dictionnaire_donnees.md](docs/dictionnaire_donnees.md).

## Lancer le projet

Avec Docker, choisir PostgreSQL ou MySQL.

PostgreSQL :

```bash
cd postgresql
docker compose up -d
docker exec -it dq-postgres psql -U demo -d gestion_qualite
```

MySQL (attendre une trentaine de secondes au premier démarrage) :

```bash
cd mysql
docker compose up -d
docker exec -it dq-mysql mysql -uroot -pdemo --default-character-set=utf8mb4 gestion
```

Pour tout supprimer : `docker compose down -v`.

Sans Docker, on peut lancer les scripts un par un :

```bash
# PostgreSQL
createdb gestion_qualite
psql -d gestion_qualite -f postgresql/sql/01_schema.sql
psql -d gestion_qualite -f postgresql/sql/02_donnees_exemple.sql
psql -d gestion_qualite -f postgresql/sql/03_controles_qualite.sql

# MySQL
mysql -u root -p --default-character-set=utf8mb4 < mysql/sql/01_schema.sql
mysql -u root -p --default-character-set=utf8mb4 < mysql/sql/02_donnees_exemple.sql
mysql -u root -p --default-character-set=utf8mb4 < mysql/sql/03_controles_qualite.sql
```

## Utilisation

Avec PostgreSQL, lancer d'abord `SET search_path = gestion;`. Avec MySQL, la base `gestion` est déjà choisie par les scripts (sinon `USE gestion;`).

```sql
-- nombre d'anomalies par règle
SELECT * FROM v_rapport_qualite ORDER BY regle_id;

-- détail des anomalies d'une règle
SELECT * FROM v_anomalies WHERE regle_id = 'DQ-03';
```

Résultat sur les données d'exemple (22 anomalies au total) :

| Règle | Ce qu'on cherche | Anomalies |
|---|---|---|
| DQ-01 | Courriel invalide | 1 |
| DQ-02 | Courriel avec des espaces ou des majuscules | 2 |
| DQ-03 | Même courriel pour plusieurs clients | 2 |
| DQ-04 | Doublon probable de client | 4 |
| DQ-05 | Client sans courriel ni téléphone | 1 |
| DQ-06 | Téléphone hors format | 1 |
| DQ-07 | Code postal invalide | 1 |
| DQ-08 | Date de naissance impossible | 1 |
| DQ-09 | Doublon probable de produit | 2 |
| DQ-10 | Prix du produit à zéro | 1 |
| DQ-11 | Expédition avant la commande | 1 |
| DQ-12 | Statut avancé sans date d'expédition | 1 |
| DQ-13 | Commande sans ligne | 1 |
| DQ-14 | Écart de prix avec le catalogue | 1 |
| DQ-15 | Quantité anormale | 1 |
| DQ-16 | Date de commande dans le futur | 1 |

Toutes les règles sont expliquées dans [docs/regles_gestion.md](docs/regles_gestion.md).

## Différences entre PostgreSQL et MySQL

Les tables, les données et les règles sont les mêmes. Seule la syntaxe SQL change.

Versions testées : PostgreSQL 16 et MySQL 8.0.

## Auteur

Roland Koko Kpakossou, étudiant en informatique à l'Université Laval.
[LinkedIn](https://www.linkedin.com/in/roland-koko-kpakossou)

Licence (voir [LICENSE](LICENSE)).
