/**
- 04_corrections_exemple.sql : exemple de corrections (facultatif)
- Ce script n'est pas lancé automatiquement par Docker.
- On corrige seulement ce qui peut l'être sans risque : les courriels (DQ-02)
- et les téléphones (DQ-06). Les doublons (DQ-03 et DQ-04) demandent une
- vérification humaine avant de fusionner des fiches.
*/
SET search_path = gestion;

BEGIN;

/** DQ-02 : courriels en minuscules et sans espaces */
UPDATE client
SET courriel = lower(trim(courriel))
WHERE courriel <> lower(trim(courriel));

/** DQ-06 : téléphones de 10 chiffres au format 999-999-9999 */
UPDATE client
SET telephone = regexp_replace(
        regexp_replace(telephone, '[^0-9]', '', 'g'),
        '^([0-9]{3})([0-9]{3})([0-9]{4})$', '\1-\2-\3')
WHERE telephone !~ '^[0-9]{3}-[0-9]{3}-[0-9]{4}$'
  AND length(regexp_replace(telephone, '[^0-9]', '', 'g')) = 10;

COMMIT;

/** DQ-02 et DQ-06 ne doivent plus apparaître, DQ-03 et DQ-04 restent */
SELECT regle_id, regle, nb_anomalies
FROM v_rapport_qualite
WHERE regle_id IN ('DQ-02','DQ-03','DQ-04','DQ-06')
ORDER BY regle_id;
