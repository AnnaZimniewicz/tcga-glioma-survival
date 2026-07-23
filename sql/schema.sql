-- Schemat bazy danych: TCGA Glioma Survival Analysis
-- Projekt dyplomowy, Collegium Da Vinci, 2026
-- Dane: TCGA-GBM + TCGA-LGG (Ceccarelli et al. 2016, n=1047)

-- Tabela 1: dane demograficzne i kliniczne pacjentów
CREATE TABLE IF NOT EXISTS patients (
    patient_id        TEXT PRIMARY KEY,  -- unikalny identyfikator pacjenta TCGA
    study             TEXT,              -- GBM lub LGG
    histology         TEXT,              -- typ histologiczny guza
    grade             TEXT,              -- stopień złośliwości wg WHO
    age_at_diagnosis  REAL,              -- wiek w momencie diagnozy (lata)
    gender            TEXT,              -- płeć
    kps               REAL,              -- Karnofsky Performance Status (sprawność pacjenta)
    mutation_count    REAL               -- liczba mutacji somatycznych
);

-- Tabela 2: status biomarkerów molekularnych
CREATE TABLE IF NOT EXISTS biomarkers (
    patient_id            TEXT PRIMARY KEY,  -- klucz obcy do tabeli patients
    idh_status            TEXT,              -- IDH: Mutant lub WT (wildtype)
    mgmt_status           TEXT,              -- MGMT: Methylated lub Unmethylated
    codel_1p19q           TEXT,              -- kodelecja 1p/19q: codel lub non-codel
    idh_codel_subtype     TEXT,              -- podtyp molekularny (IDH + 1p/19q łącznie)
    tert_promoter_status  TEXT,              -- status promotora TERT
    atrx_status           TEXT,              -- status genu ATRX
    idh_mutant            REAL,              -- 1 = IDH mutant, 0 = wildtype (do modelu Coxa)
    mgmt_methylated       REAL,              -- 1 = metylowany, 0 = nieme, ten tylowany (do modelu Coxa)
    codel                 REAL,              -- 1 = kodelecja obecna, 0 = brak (do modelu Coxa)

    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);

-- Tabela 3: dane o przeżyciu
CREATE TABLE IF NOT EXISTS survival (
    patient_id  TEXT PRIMARY KEY,  -- klucz obcy do tabeli patients
    os_months   REAL,              -- czas przeżycia w miesiącach (Overall Survival)
    os_event    REAL,              -- 1 = zgon odnotowany, 0 = cenzurowanie (pacjent żyje lub utracony z obserwacji)

    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);