-- Przykładowe zapytania SQL: TCGA Glioma Survival Analysis
-- Etap 3, projekt dyplomowy, Collegium Da Vinci, 2026
-- Baza: db/tcga_glioma.db (tabele: patients, biomarkers, survival)
-- Uwaga: to samo SQL co w notebooks/03_sql_exploration.ipynb, tu zebrane
-- jako czysty zapis DML do repo (bez otoczki pd.read_sql_query).

-- ============================================================
-- 1. PODSTAWY: SELECT, WHERE, ORDER BY, DISTINCT, GROUP BY, HAVING
-- ============================================================

-- 1. Ile pacjentów mamy w każdym typie guza?
SELECT study, COUNT(*) AS liczba_pacjentow
FROM patients
GROUP BY study;

-- 2. Pacjenci powyżej 60 lat, tylko GBM, posortowani od najstarszych
SELECT patient_id, age_at_diagnosis, gender
FROM patients
WHERE study = 'GBM' AND age_at_diagnosis > 60
ORDER BY age_at_diagnosis DESC;

-- 3. Jakie unikalne typy histologiczne występują w danych?
SELECT DISTINCT histology
FROM patients;

-- 4. Średni wiek diagnozy per typ guza
SELECT study, AVG(age_at_diagnosis) AS sredni_wiek, COUNT(*) AS n
FROM patients
GROUP BY study;

-- 5. Typy histologiczne, które mają więcej niż 50 pacjentów
SELECT histology, COUNT(*) AS n
FROM patients
GROUP BY histology
HAVING COUNT(*) > 50;

-- ============================================================
-- 2. JOIN: łączenie patients + biomarkers + survival
-- ============================================================

-- 6. Wiek i płeć pacjentów z IDH mutant
SELECT p.patient_id, p.age_at_diagnosis, p.gender, b.idh_status
FROM patients p
JOIN biomarkers b ON p.patient_id = b.patient_id
WHERE b.idh_status = 'Mutant'
ORDER BY p.age_at_diagnosis;

-- 7. Pełny obraz pacjenta: dane kliniczne + biomarkery + przeżycie (3 tabele naraz)
SELECT p.patient_id, p.study, p.age_at_diagnosis,
       b.idh_status, b.mgmt_status,
       s.os_months, s.os_event
FROM patients p
JOIN biomarkers b ON p.patient_id = b.patient_id
JOIN survival s ON p.patient_id = s.patient_id
LIMIT 10;

-- 8. Czy są pacjenci bez danych o przeżyciu? (LEFT JOIN sprawdza braki)
SELECT p.patient_id, s.os_months, s.os_event
FROM patients p
LEFT JOIN survival s ON p.patient_id = s.patient_id
WHERE s.os_months IS NULL;

-- ============================================================
-- 3. AGREGACJE NA ZŁĄCZONYCH TABELACH (pytanie badawcze)
-- ============================================================

-- 9. Średni OS wg statusu IDH
SELECT b.idh_status,
       AVG(s.os_months) AS sredni_os,
       COUNT(*) AS n
FROM biomarkers b
JOIN survival s ON b.patient_id = s.patient_id
GROUP BY b.idh_status;

-- 10. Średni OS wg statusu MGMT
SELECT b.mgmt_status,
       AVG(s.os_months) AS sredni_os,
       COUNT(*) AS n
FROM biomarkers b
JOIN survival s ON b.patient_id = s.patient_id
GROUP BY b.mgmt_status;

-- 11. Współwystępowanie IDH i MGMT (cross-tab przez GROUP BY na dwóch kolumnach)
SELECT idh_status, mgmt_status, COUNT(*) AS n
FROM biomarkers
GROUP BY idh_status, mgmt_status
ORDER BY idh_status, mgmt_status;

-- ============================================================
-- 4. SUBQUERY I CTE
-- ============================================================

-- 12. Braki w danych biomarkerowych - CTE liczy surowe wartości,
--     zewnętrzny SELECT dolicza procenty
-- Decyzja projektowa: pacjenci z brakiem IDH i/lub MGMT są wykluczani
-- z analiz wykorzystujących te zmienne (bez imputacji).
-- Efektywna kohorta z kompletnym IDH+MGMT: n=812 (77,6%).
WITH braki AS (
    SELECT
        SUM(CASE WHEN idh_status IS NULL THEN 1 ELSE 0 END) AS brak_idh,
        SUM(CASE WHEN mgmt_status IS NULL THEN 1 ELSE 0 END) AS brak_mgmt,
        COUNT(*) AS total
    FROM biomarkers
)
SELECT total,
       brak_idh,
       ROUND(100.0 * brak_idh / total, 1) AS pct_brak_idh,
       brak_mgmt,
       ROUND(100.0 * brak_mgmt / total, 1) AS pct_brak_mgmt
FROM braki;

-- 13. Pacjenci starsi niż średnia wieku w całej kohorcie (podzapytanie w WHERE)
SELECT patient_id, study, age_at_diagnosis
FROM patients
WHERE age_at_diagnosis > (SELECT AVG(age_at_diagnosis) FROM patients)
ORDER BY age_at_diagnosis DESC
LIMIT 10;

-- ============================================================
-- 5. WINDOW FUNCTION
-- ============================================================

-- 14. Ranking pacjentów wg wieku wewnątrz każdego typu guza
SELECT patient_id, study, age_at_diagnosis,
       RANK() OVER (PARTITION BY study ORDER BY age_at_diagnosis DESC) AS ranking_wieku
FROM patients
ORDER BY study, ranking_wieku
LIMIT 20;