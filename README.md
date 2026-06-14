# TCGA Glioma Survival Analysis

Praca dyplomowa - studia podyplomowe Big Data, Collegium Da Vinci w Poznaniu.

## Pytanie badawcze

Czy status metylacji **MGMT** pozostaje niezależnym czynnikiem prognostycznym przeżycia u pacjentów z glejakami po uwzględnieniu statusu **IDH** i innych zmiennych klinicznych?

## Cel projektu

Analiza wpływu biomarkerów molekularnych (IDH1/IDH2, MGMT) na przeżywalność pacjentów z glejakami w kohorcie TCGA (TCGA-GBM + TCGA-LGG), z wykorzystaniem klasycznych metod analizy przeżycia (Kaplan-Meier, regresja Coxa) i prostego modelu uczenia maszynowego do stratyfikacji ryzyka.

## Stos technologiczny

- **Python** - pandas, numpy, requests, matplotlib, seaborn, lifelines, scikit-learn
- **SQL** - SQLite (relacyjna baza danych projektu)
- **Tableau Public** - interaktywny dashboard
- **Git + GitHub** - wersjonowanie i hosting

## Struktura repozytorium



tcga-glioma-survival/

├── data/              # surowe i przetworzone dane (poza repo, odtwarzalne ze skryptu)

│   ├── raw/

│   └── processed/

├── notebooks/         # notebooks Jupyter z analizami (numerowane: 01\_, 02\_, ...)

├── src/               # skrypty Pythona

├── sql/               # schematy i przykładowe zapytania

├── db/                # baza SQLite (poza repo)

├── tableau/           # workbook Tableau

├── reports/           # praca dyplomowa, wykresy

└── docs/              # dokumentacja, diagramy



## Status projektu

🚧 **W trakcie realizacji** (deadline: wrzesień 2026)

### Etapy

- [x] Etap 0 - Setup środowiska
- [x] Etap 1 - Pozyskanie danych (cBioPortal API + Ceccarelli 2016)
- [x] Etap 2 - ETL (czyszczenie i transformacja)
- [ ] Etap 3 - Baza SQL
- [ ] Etap 4 - EDA (eksploracyjna analiza danych)
- [ ] Etap 5 - Analiza przeżycia (KM, Cox)
- [ ] Etap 6 - Model ML (klasyfikacja ryzyka)
- [ ] Etap 7 - Dashboard Tableau
- [ ] Etap 8 - Dokumentacja i praca dyplomowa

## Dane

### Źródła

Dane pochodzą z **The Cancer Genome Atlas (TCGA)**, projektów **TCGA-GBM** (Glioblastoma Multiforme) i **TCGA-LGG** (Lower Grade Glioma). Pobierane przez [cBioPortal API](https://www.cbioportal.org) oraz z materiałów suplementarnych publikacji Ceccarelli et al. 2016.

| Plik | Źródło | Opis |
|------|--------|------|
| `data/raw/ceccarelli_2016_table_s1.xlsx` | Materiały suplementarne Ceccarelli et al. 2016, *Cell* 164:550-563 | Pełna tabela kliniczna + status molekularny dla 1122 pacjentów TCGA Pan-Glioma (606 GBM + 516 LGG). 51 kolumn, w tym IDH, MGMT, 1p/19q codeletion. |
| `data/raw/ceccarelli_clinical_clean.csv` | Wynik selekcji z tabeli powyżej | 16 kluczowych kolumn: identyfikatory, dane kliniczne, outcome (OS), biomarkery (IDH, MGMT, 1p/19q, TERT, ATRX). Snake_case. |


| `data/processed/clinical_processed.csv` | Wynik ETL (Etap 2) | 1047 pacjentów z kompletnymi danymi follow-up, 19 kolumn. Gotowy do załadowania do bazy SQL. Wykluczone: 75 pacjentów bez danych OS. Braki w IDH/MGMT zachowane jako NA. |


### Kohorta

- **Liczba pacjentów**: 1122 (606 Glioblastoma, 516 Lower-Grade Glioma)
- **Pokrycie kluczowych biomarkerów**:
  - IDH status: 995/1122 (89%)
  - MGMT promoter status: 932/1122 (83%)
  - 1p/19q codeletion: 1093/1122 (97%)
- **Pokrycie outcome (OS)**: 1047/1122 (93%)
- 75 pacjentów ma kompletny brak danych klinicznych follow-up – zostaną wykluczeni w Etapie 2 (ETL)

### Walidacja

Identyfikatory `patient_id` z Ceccarelli vs `patientId` z cBioPortal API: zgodność 1:1 dla wszystkich 1122 pacjentów (sprawdzone w `notebooks/01_data_acquisition.ipynb`, sekcja 8).

### Decyzja metodologiczna

Dane molekularne (IDH, MGMT) **nie są dostępne** jako atrybuty kliniczne na poziomie pacjenta w żadnej wersji cBioPortal (Firehose Legacy, PanCancer Atlas, GDC 2025). Dlatego za źródło tych zmiennych przyjmujemy materiały suplementarne Ceccarelli 2016 – obejmują dokładnie tę samą kohortę 1122 pacjentów.

## Autor

**Anna Zimniewicz** - biotechnolog (diagnostyka molekularna), Narodowy Instytut Onkologii


