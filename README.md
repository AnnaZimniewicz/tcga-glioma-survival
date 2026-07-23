# TCGA Glioma Survival Analysis

Praca dyplomowa - studia podyplomowe Big Data, Collegium Da Vinci w Poznaniu.

## Pytanie badawcze

Czy status metylacji **MGMT** pozostaje niezależnym czynnikiem prognostycznym przeżycia u pacjentów z glejakami po uwzględnieniu statusu **IDH** i innych zmiennych klinicznych?

## Cel projektu

Analiza wpływu biomarkerów molekularnych (IDH1/IDH2, MGMT) na przeżywalność pacjentów
z glejakami w kohorcie TCGA (TCGA-GBM + TCGA-LGG), z wykorzystaniem klasycznych metod
analizy przeżycia (Kaplan-Meier, regresja Coxa).

## Stos technologiczny

- **Python** - pandas, numpy, requests, matplotlib, seaborn, lifelines
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
- [x] Etap 3 - Baza SQL
- [x] Etap 4 - EDA (eksploracyjna analiza danych)
- [ ] Etap 5 - Analiza przeżycia (KM, Cox)
- [ ] Etap 6 - Dashboard Tableau
- [ ] Etap 7 - Dokumentacja i praca dyplomowa

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

## Baza danych (Etap 3)

Dane z `data/processed/clinical_processed.csv` (1047 pacjentów, 19 kolumn) załadowane
do znormalizowanej bazy SQLite (`db/tcga_glioma.db`, poza repo) w trzech tabelach:
`patients`, `biomarkers`, `survival`, połączonych przez `patient_id`.

- Schemat: [`sql/schema.sql`](sql/schema.sql)
- Przykładowe zapytania (14, od SELECT do window functions): [`sql/example_queries.sql`](sql/example_queries.sql)
- Diagram ERD: [`docs/erd_diagram.png`](docs/erd_diagram.png)

## Eksploracyjna analiza danych (Etap 4)

Notebook: [`notebooks/04_eda.ipynb`](notebooks/04_eda.ipynb)

**Kohorta:** 1047 pacjentów (590 GBM, 457 LGG); po wykluczeniu 3 pacjentów z błędnym
(ujemnym) `os_months` (source site TCGA-QH) - **n=1044**.

**Wiek:** średnio 51,4 lat (SD 15,8); GBM 57,8 lat vs LGG 43,2 lat - rozkład kohorty
jest lekko dwumodalny, co odzwierciedla dwie różne subpopulacje kliniczne.

**Biomarkery:**

| Zmienna | Braki | Rozkład |
|---|---|---|
| IDH status | 121 (11,6%) | Mutant silnie skoncentrowany w LGG (81%), rzadki w GBM (8%) |
| MGMT status | 185 (17,7%) | Methylated częstszy w LGG (82%) niż GBM (45%) |
| 1p/19q codeletion | 22 (2,1%) | Praktycznie nieobecna w GBM, częsta w LGG (33%) |
| KPS | 350 (33,5%) | - |
| Liczba mutacji somatycznych | 293 (28,1%) | Silnie prawoskośny rozkład (mediana 35, średnia 54,2, max 12255 — fenotyp hipermutacyjny) |

**Decyzja o brakach danych:** bez imputacji dla biomarkerów - pacjenci z brakiem w IDH
i/lub MGMT wykluczani z analiz wykorzystujących te zmienne. Efektywna kohorta
z kompletnym IDH+MGMT (do modelu Coxa, Etap 5): **n=809**.


## Autor

**Anna Zimniewicz** - biotechnolog (diagnostyka molekularna), Narodowy Instytut Onkologii


