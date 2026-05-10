\# TCGA Glioma Survival Analysis



Praca dyplomowa - studia podyplomowe Big Data, Collegium Da Vinci w Poznaniu.



\## Pytanie badawcze



Czy status metylacji \*\*MGMT\*\* pozostaje niezależnym czynnikiem prognostycznym przeżycia u pacjentów z glejakami po uwzględnieniu statusu \*\*IDH\*\* i innych zmiennych klinicznych?



\## Cel projektu



Analiza wpływu biomarkerów molekularnych (IDH1/IDH2, MGMT) na przeżywalność pacjentów z glejakami w kohorcie TCGA (TCGA-GBM + TCGA-LGG), z wykorzystaniem klasycznych metod analizy przeżycia (Kaplan-Meier, regresja Coxa) i prostego modelu uczenia maszynowego do stratyfikacji ryzyka.



\## Stos technologiczny



\- \*\*Python\*\* - pandas, numpy, requests, matplotlib, seaborn, lifelines, scikit-learn

\- \*\*SQL\*\* - SQLite (relacyjna baza danych projektu)

\- \*\*Tableau Public\*\* - interaktywny dashboard

\- \*\*Git + GitHub\*\* - wersjonowanie i hosting



\## Struktura repozytorium







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







\## Status projektu



🚧 \*\*W trakcie realizacji\*\* (deadline: wrzesień 2026)



\### Etapy



\- \[x] Etap 0 - Setup środowiska

\- \[ ] Etap 1 - Pozyskanie danych (cBioPortal API)

\- \[ ] Etap 2 - ETL (czyszczenie i transformacja)

\- \[ ] Etap 3 - Baza SQL

\- \[ ] Etap 4 - EDA (eksploracyjna analiza danych)

\- \[ ] Etap 5 - Analiza przeżycia (KM, Cox)

\- \[ ] Etap 6 - Model ML (klasyfikacja ryzyka)

\- \[ ] Etap 7 - Dashboard Tableau

\- \[ ] Etap 8 - Dokumentacja i praca dyplomowa



\## Źródło danych



Dane pochodzą z \*\*The Cancer Genome Atlas (TCGA)\*\*, projektów:

\- \*\*TCGA-GBM\*\* (Glioblastoma Multiforme)

\- \*\*TCGA-LGG\*\* (Lower Grade Glioma)



Pobierane przez \*\*cBioPortal API\*\* (https://www.cbioportal.org).



\## Autor



\*\*Anna Zimniewicz\*\* - biotechnolog (diagnostyka molekularna), Narodowy Instytut Onkologii



