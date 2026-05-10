# Instrukcja projektu dyplomowego

**Studia podyplomowe Big Data, Collegium Da Vinci w Poznaniu**

---

## 1. Streszczenie projektu

### Tytuł roboczy
*Wpływ statusu molekularnego (IDH1/IDH2, MGMT) na przeżywalność pacjentów z glejakami - analiza danych TCGA z wykorzystaniem narzędzi Python, SQL i Tableau.*

### Pytanie badawcze
**Czy status metylacji MGMT pozostaje niezależnym czynnikiem prognostycznym przeżycia u pacjentów z glejakami po uwzględnieniu statusu IDH i innych zmiennych klinicznych?**

### Cel projektu
Projekt ma dwa cele równoległe:

1. **Cel naukowy/analityczny:** Zbadanie zależności między biomarkerami molekularnymi (IDH1/IDH2, MGMT) a przeżywalnością pacjentów z glejakami w kohorcie TCGA, z wykorzystaniem klasycznych metod analizy przeżycia (Kaplan-Meier, regresja Coxa) i prostego modelu uczenia maszynowego do stratyfikacji ryzyka.
2. **Cel praktyczny/zawodowy:** Stworzenie kompletnego projektu portfolio data scientist demonstrującego umiejętności w zakresie pozyskiwania danych z API, projektowania bazy SQL, eksploracyjnej analizy danych w Pythonie, biostatystyki, podstawowego machine learningu i wizualizacji w Tableau.

### Stos technologiczny
- **Python** (pandas, numpy, requests, matplotlib, seaborn, lifelines, scikit-learn) - pozyskiwanie, przetwarzanie i analiza danych
- **SQL** (SQLite) - relacyjna baza danych do przechowywania danych projektu
- **Tableau Public** - interaktywny dashboard
- **Git + GitHub** - wersjonowanie kodu i hosting projektu
- **Jupyter Notebook / VS Code** - środowisko pracy

### Oczekiwany rezultat
- Działający, udokumentowany pipeline od pobrania danych po dashboard
- Repozytorium GitHub z kodem, dokumentacją i wynikami
- Praca dyplomowa zawierająca opis metod, wyników i dyskusji
- Publiczny dashboard Tableau Public (URL do CV)

---

## 2. Kontekst biologiczny i kliniczny

### Glejaki - krótkie wprowadzenie
Glejaki (gliomas) to nowotwory wywodzące się z komórek glejowych ośrodkowego układu nerwowego. Stanowią najczęstszą grupę pierwotnych nowotworów mózgu u dorosłych. Obejmują szerokie spektrum guzów - od stosunkowo wolno rosnących glejaków o niższym stopniu złośliwości (LGG, lower-grade gliomas, WHO grade 2-3) do najbardziej agresywnych glejaków wielopostaciowych (GBM, glioblastoma, WHO grade 4).

Zgodnie z klasyfikacją WHO 2021 dla guzów OUN, diagnostyka glejaków opiera się nie tylko na morfologii histologicznej, ale w znacznym stopniu na charakterystyce molekularnej, w tym statusie mutacji IDH oraz kodelecji 1p/19q.

### Biomarkery w centrum projektu

**IDH1/IDH2 (izocytrynian dehydrogenaza 1 i 2)**
- Mutacje somatyczne (najczęściej IDH1 R132H) prowadzą do produkcji onkometabolitu 2-hydroksyglutaranu (2-HG)
- Status IDH-mutant vs IDH-wildtype to obecnie kluczowy podział prognostyczny w glejakach
- Pacjenci IDH-mutant zazwyczaj mają znacznie lepsze rokowanie

**MGMT (O6-metyloguanino-metylotransferaza DNA)**
- Enzym naprawczy DNA, który usuwa grupy alkilowe z O6-pozycji guaniny
- Metylacja promotora MGMT → wyciszenie ekspresji → niższa naprawa DNA → lepsza odpowiedź na temozolomid
- Status MGMT to predykcyjny biomarker odpowiedzi na chemioterapię alkilującą (temozolomid - standard leczenia GBM)

### Dlaczego ten temat ma znaczenie
W codziennej diagnostyce molekularnej (m.in. w Narodowym Instytucie Onkologii) oznaczenia IDH1/IDH2 i MGMT są rutynowo wykonywane u pacjentów z glejakami. Ich wynik bezpośrednio wpływa na decyzje terapeutyczne. Analiza danych populacyjnych z TCGA pozwala oszacować siłę prognostyczną tych biomarkerów na dużej kohorcie i zilustrować, jak dane molekularne przekładają się na wyniki kliniczne.

---

## 3. Architektura projektu (data flow)

### Diagram przepływu danych

```
┌─────────────────────┐
│   Źródło danych:    │
│   TCGA (GDC API)    │
│   + cBioPortal      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Python: pobranie   │
│  danych klinicznych │
│  + molekularnych    │
│  (skrypt + raw CSV) │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Python: czyszczenie│
│  i transformacja    │
│  (ETL)              │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│   SQLite: baza      │
│   relacyjna         │
│   (znormalizowana)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Python: EDA +      │
│  analiza przeżycia  │
│  + ML (klasyfikacja │
│  ryzyka)            │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Eksport wyników    │
│  do CSV dla Tableau │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│  Tableau Public:    │
│  interaktywny       │
│  dashboard          │
└─────────────────────┘
```

### Wyjaśnienie pojęć z diagramu (nie martw się, jeśli nie znasz)

- **API (Application Programming Interface)** - sposób, w jaki programy "rozmawiają" z innymi programami przez internet. Zamiast klikać na stronie i pobierać pliki ręcznie, piszesz skrypt, który "prosi" serwer TCGA o konkretne dane. To jest umiejętność wymagana w pracy data scientista.
- **Raw CSV** - "surowe" dane w pliku CSV (Comma-Separated Values), tak jak je pobrałyśmy, bez żadnej obróbki. Trzymasz je osobno, żeby zawsze móc wrócić do oryginału.
- **ETL (Extract-Transform-Load)** - pobierasz, przekształcasz, ładujesz. Standardowy proces przygotowania danych do analizy.
- **Znormalizowana baza** - taka, w której informacje nie są duplikowane między tabelami. Np. wiek pacjenta jest zapisany raz w tabeli `pacjenci`, a nie powtarzany w każdej z jego mutacji.

---

## 4. Plan etapów (deliverables)

Każdy etap ma jasno określony produkt (deliverable). To znaczy: na końcu każdego etapu masz coś konkretnego na dysku/GitHubie, co możesz pokazać.

### Etap 0 - Setup środowiska (start projektu)
**Co robisz:** instalujesz narzędzia, zakładasz repo, tworzysz strukturę folderów.

**Deliverables:**
- Działająca instalacja Pythona (Anaconda lub Miniconda)
- VS Code z rozszerzeniem Pythona
- Konto GitHub i puste repo z README
- Lokalne repo zsynchronizowane z GitHubem (`git clone`, `git push`)
- Środowisko wirtualne (`venv` lub `conda env`) z zainstalowanymi bibliotekami
- Plik `requirements.txt` z listą bibliotek

**Czego się uczysz:** podstawy linii poleceń Windows, Git/GitHub, środowiska wirtualne.

---

### Etap 1 - Pozyskanie danych
**Co robisz:** piszesz skrypt Pythona, który pobiera dane z TCGA-GBM i TCGA-LGG (kliniczne, mutacje, status MGMT).

**Deliverables:**
- Skrypt `01_data_acquisition.py` (lub notebook) pobierający dane
- Folder `data/raw/` z surowymi plikami CSV (dane kliniczne, mutacje, dane molekularne)
- Notatka w README opisująca źródło danych i datę pobrania

**Czego się uczysz:** Python (requests, pandas, praca z API), praca z dokumentacją API.

**Uwaga:** Najprostsza ścieżka to pobranie danych z **cBioPortal** (https://www.cbioportal.org), który ma świetne API i dane są już sensownie sformatowane. Alternatywa to GDC API (https://gdc.cancer.gov), trudniejsze, ale bardziej "natywne" dla TCGA. Zacznę od cBioPortal.

---

### Etap 2 - Czyszczenie i transformacja danych (ETL)
**Co robisz:** ładujesz surowe dane do pandas, sprawdzasz braki, ujednolicasz nazewnictwo, łączysz tabele po `patient_id`, klasyfikujesz pacjentów wg statusu IDH/MGMT.

**Deliverables:**
- Notebook `02_etl.ipynb` z udokumentowanymi krokami czyszczenia
- Folder `data/processed/` z czystymi plikami CSV gotowymi do bazy
- Raport z czyszczenia: ile rekordów odrzucono, ile braków, jakie decyzje podjęto

**Czego się uczysz:** pandas (filtrowanie, merge, groupby, fillna), myślenie o jakości danych.

---

### Etap 3 - Projektowanie i wypełnianie bazy SQL
**Co robisz:** projektujesz schemat relacyjny (3-5 tabel: `patients`, `samples`, `mutations`, `treatments`, `clinical_outcomes`), tworzysz bazę SQLite, ładujesz dane skryptem Pythona, piszesz testowe zapytania.

**Deliverables:**
- Plik `schema.sql` z definicjami tabel (CREATE TABLE...)
- Diagram ERD (Entity Relationship Diagram) - rysunek pokazujący tabele i relacje (np. w darmowym dbdiagram.io)
- Plik bazy `tcga_glioma.db` (SQLite)
- Skrypt `03_load_to_db.py` ładujący dane
- Notebook `03_sql_exploration.ipynb` z 10-15 przykładowymi zapytaniami SQL (od prostych SELECT do JOIN-ów i CTE)

**Czego się uczysz:** SQL (DDL i DML), projektowanie baz, normalizacja, JOIN, GROUP BY, window functions, CTE.

**Wyjaśnienie pojęć:**
- **DDL (Data Definition Language)** - komendy definiujące strukturę bazy: CREATE TABLE, ALTER TABLE.
- **DML (Data Manipulation Language)** - komendy operujące na danych: SELECT, INSERT, UPDATE, DELETE.
- **JOIN** - łączenie danych z dwóch tabel, np. dane pacjenta z jego mutacjami.
- **CTE (Common Table Expression)** - "tymczasowa tabela" w zapytaniu, ułatwia czytanie skomplikowanych zapytań.
- **Window functions** - funkcje liczące coś w "oknie" wierszy, np. ranking pacjentów wg wieku w obrębie podtypu guza.

---

### Etap 4 - Eksploracyjna analiza danych (EDA)
**Co robisz:** opisujesz kohortę liczbowo i wizualnie, sprawdzasz rozkłady zmiennych, szukasz wzorców i anomalii.

**Deliverables:**
- Notebook `04_eda.ipynb` z wykresami i tabelami
- Sekcja "Charakterystyka kohorty" do przyszłej pracy: tabela demograficzna (wiek, płeć, podtyp guza, status IDH, status MGMT, leczenie, status follow-up)
- Wykresy: histogramy wieku, słupkowe podziałów molekularnych, heatmapy współwystępowania mutacji

**Czego się uczysz:** matplotlib, seaborn, statystyki opisowe, myślenie eksploracyjne.

---

### Etap 5 - Analiza przeżycia (biostatystyka)
**Co robisz:** rysujesz krzywe Kaplana-Meiera dla różnych grup, robisz testy log-rank, budujesz model regresji Coxa.

**Deliverables:**
- Notebook `05_survival_analysis.ipynb`
- Wykresy KM: cała kohorta, podział na status IDH, podział na status MGMT, podział łączony (4 grupy)
- Tabela z medianą OS (overall survival) dla każdej grupy
- Wyniki log-rank testów z p-values
- Model Coxa wielowariantowy z hazard ratios, confidence intervals i p-values
- Interpretacja: czy MGMT pozostaje niezależnym predyktorem po uwzględnieniu IDH?

**Czego się uczysz:** lifelines, podstawy biostatystyki, interpretacja modeli statystycznych.

**Wyjaśnienie pojęć:**
- **Krzywa Kaplana-Meiera** - wykres pokazujący prawdopodobieństwo przeżycia w czasie. Klasyka onkologii.
- **Log-rank test** - test statystyczny porównujący krzywe KM między grupami.
- **Regresja Coxa** - model statystyczny pokazujący, jak różne czynniki wpływają na ryzyko zgonu, z możliwością uwzględnienia wielu zmiennych jednocześnie.
- **Hazard ratio (HR)** - ile razy większe/mniejsze jest ryzyko w jednej grupie vs. inna. HR=2 oznacza 2x większe ryzyko.
- **Niezależny czynnik prognostyczny** - taki, którego efekt utrzymuje się po uwzględnieniu (skontrolowaniu) innych zmiennych. To jest sedno twojego pytania badawczego.

---

### Etap 6 - Model predykcyjny ryzyka (machine learning)
**Co robisz:** budujesz prosty model klasyfikujący pacjentów do grup ryzyka (np. niskie/wysokie ryzyko zgonu w 2 lata). Porównujesz z klasyfikacją bazującą tylko na biomarkerach.

**Deliverables:**
- Notebook `06_ml_model.ipynb`
- Podział danych na train/test
- Model (logistic regression i/lub random forest)
- Walidacja krzyżowa, metryki (AUC, accuracy, sensitivity, specificity, confusion matrix)
- Interpretacja: które zmienne są najważniejsze (feature importance, ewentualnie SHAP)
- Porównanie z modelem "naiwnym" opartym tylko na IDH+MGMT

**Czego się uczysz:** scikit-learn, train/test split, walidacja krzyżowa, metryki klasyfikacji.

**Uwaga:** ten etap jest "rozszerzeniem" z wariantu B. Jeśli wcześniejsze etapy zajmą więcej czasu, można go uprościć lub pominąć - mamy plan B.

---

### Etap 7 - Dashboard w Tableau
**Co robisz:** projektujesz interaktywny dashboard pokazujący najważniejsze wyniki i pozwalający przeglądać kohortę.

**Deliverables:**
- Plik `dashboard.twbx` (Tableau workbook)
- Publiczny URL na Tableau Public
- 3-5 widoków:
  1. Charakterystyka kohorty (demografia, podział na podtypy)
  2. Krzywe przeżycia (statyczne, ale interaktywne filtrowanie)
  3. Mapa biomarkerów (heatmapa współwystępowania)
  4. Stratyfikacja ryzyka wg modelu
  5. (opcjonalnie) Eksplorator pacjenta - wybierasz pacjenta i widzisz jego profil

**Czego się uczysz:** Tableau, projektowanie dashboardów, storytelling danych.

---

### Etap 8 - Dokumentacja i pisanie pracy
**Co robisz:** porządkujesz repo, piszesz README, piszesz pracę dyplomową.

**Deliverables:**
- Profesjonalne README na GitHubie z opisem projektu, screenshotami, instrukcją uruchomienia
- Plik `requirements.txt`
- Plik `.gitignore` (żeby nie wrzucać niepotrzebnych plików)
- Praca dyplomowa (struktura w sekcji 6)
- Prezentacja na obronę

---

## 5. Struktura repozytorium na GitHubie

```
tcga-glioma-survival/
│
├── README.md                          ← główny opis projektu
├── requirements.txt                   ← lista bibliotek Pythona
├── .gitignore                         ← pliki do zignorowania przez Git
│
├── data/
│   ├── raw/                           ← surowe dane (NIE wrzucać na GitHub jeśli duże)
│   ├── processed/                     ← czyste dane do analizy
│   └── README.md                      ← opis danych i jak je odtworzyć
│
├── notebooks/
│   ├── 01_data_acquisition.ipynb
│   ├── 02_etl.ipynb
│   ├── 03_sql_exploration.ipynb
│   ├── 04_eda.ipynb
│   ├── 05_survival_analysis.ipynb
│   ├── 06_ml_model.ipynb
│
├── src/                               ← skrypty Pythona (nie notebooks)
│   ├── data_acquisition.py
│   ├── etl.py
│   └── load_to_db.py
│
├── sql/
│   ├── schema.sql                     ← definicja tabel
│   └── example_queries.sql            ← przykładowe zapytania
│
├── db/
│   └── tcga_glioma.db                 ← baza SQLite (lub w .gitignore jeśli duża)
│
├── tableau/
│   └── dashboard.twbx                 ← dashboard
│
├── reports/
│   ├── figures/                       ← wykresy do pracy dyplomowej
│   └── final_report.pdf               ← praca dyplomowa
│
└── docs/
    ├── erd_diagram.png                ← diagram bazy
    └── data_flow.png                  ← diagram pipeline'u
```

**Dlaczego to wygląda profesjonalnie?**
- Rekruter otwierający repo widzi od razu strukturę i wie, co gdzie jest.
- Numeracja notebooków (01, 02, 03...) pokazuje kolejność wykonania.
- Oddzielenie surowych vs przetworzonych danych pokazuje, że rozumiesz reproducibility.
- README jest pierwszą rzeczą, którą widzi rekruter - na nim wisi pierwsze wrażenie.

---

## 6. Struktura pracy dyplomowej

Wzorowana na strukturze pracy naukowej, którą znasz z licencjatu i magisterki:

1. **Streszczenie / Abstrakt** (PL + EN)
2. **Wstęp**
   - Glejaki - epidemiologia, klasyfikacja WHO
   - Biomarkery prognostyczne (IDH, MGMT)
   - Stan wiedzy o przeżywalności w glejakach
   - Cel pracy i pytanie badawcze
3. **Materiały i metody**
   - Źródło danych (TCGA, cBioPortal)
   - Charakterystyka kohorty
   - Narzędzia (Python, SQL, Tableau)
   - Architektura pipeline'u (z diagramem)
   - Metody statystyczne (KM, log-rank, Cox)
   - Metody machine learning
4. **Wyniki**
   - Charakterystyka kohorty (tabela)
   - Analiza przeżycia (KM dla podgrup, model Coxa)
   - Model predykcyjny (metryki, feature importance)
   - Dashboard (screenshoty)
5. **Dyskusja**
   - Interpretacja wyników w kontekście literatury
   - Porównanie z badaniami referencyjnymi (Hegi 2005, Stupp 2005, Louis 2021)
   - Terapia celowana w glejakach - vorasidenib, kandydaci do nowych terapii
   - Ograniczenia projektu (jakość danych, czas zbierania, brak danych o nowoczesnych terapiach)
6. **Wnioski**
7. **Bibliografia**
8. **Załączniki** (link do GitHuba, link do dashboardu)

---

## 7. Plan nauki - co i kiedy

Plan nauki jest sprzężony z etapami projektu. Uczysz się tego, co potrzebne na danym etapie - just-in-time learning.

### Maj 2026 (przed Etapem 1)
- Podstawy linii poleceń Windows (PowerShell)
- Git i GitHub - codzienna obsługa (clone, add, commit, push, pull)
- Środowiska wirtualne Pythona
- Powtórka pandas: `read_csv`, `head`, `info`, `describe`, `groupby`, `merge`, `dropna`, `fillna`
- Praca z API: `requests`, parsowanie JSON

### Czerwiec 2026 (Etapy 2-3)
- Zaawansowany pandas: `apply`, `pivot_table`, `melt`, `crosstab`
- SQL: SELECT, WHERE, GROUP BY, JOIN (INNER, LEFT), HAVING, podzapytania, CTE, window functions
- Projektowanie schematów relacyjnych, normalizacja
- SQLAlchemy lub `sqlite3` w Pythonie

### Lipiec 2026 (Etapy 4-5)
- Wizualizacje: matplotlib, seaborn (catplot, FacetGrid, kdeplot)
- Statystyka: testy t, Manna-Whitneya, chi-kwadrat
- Biostatystyka: KM, log-rank, regresja Coxa (lifelines)
- Interpretacja modeli statystycznych

### Sierpień 2026 (Etapy 6-7)
- Scikit-learn: train/test split, modele klasyfikacji, walidacja krzyżowa, metryki
- Tableau (od podstaw - kursy darmowe na Tableau eLearning)
- Storytelling danych

### Wrzesień 2026 (Etap 8)
- Pisanie pracy
- Przygotowanie prezentacji
- Bufor

---

## 8. Harmonogram (kamienie milowe)

| Tydzień | Etap | Konkret |
|---------|------|---------|
| 1-2 (maj) | Etap 0 | Setup środowiska, GitHub, struktura repo |
| 3-4 (maj) | Etap 1 | Pierwsze pobrania z cBioPortal, surowe dane |
| 5-6 (czerwiec) | Etap 2 | ETL, czyste dane |
| 7-8 (czerwiec) | Etap 3 | Schemat SQL, baza, podstawowe zapytania |
| 9-10 (lipiec) | Etap 4 | Pełna EDA, charakterystyka kohorty |
| 11-12 (lipiec) | Etap 5 | Analiza przeżycia (KM, Cox) |
| 13-14 (sierpień) | Etap 6 | Model ML |
| 15-16 (sierpień) | Etap 7 | Dashboard Tableau |
| 17-18 (wrzesień) | Etap 8 | Pisanie pracy, dokumentacja |
| 19+ (wrzesień) | Bufor | Poprawki, obrona |

---

## 9. Kryteria sukcesu

**Projekt jest "gotowy", jeśli:**

- ✅ Pipeline od pobrania danych po dashboard działa od początku do końca i jest reprodukowalny
- ✅ Repozytorium na GitHubie ma profesjonalny README, jasną strukturę, działający kod
- ✅ Praca dyplomowa odpowiada na pytanie badawcze i jest udokumentowana referencjami
- ✅ Dashboard jest publicznie dostępny na Tableau Public
- ✅ Potrafisz wytłumaczyć każdy fragment kodu i każdą decyzję metodologiczną
- ✅ Projekt można zaprezentować w ciągu 10 minut na rozmowie rekrutacyjnej

---

## 10. Ryzyka i plan B

| Ryzyko | Prawdopodobieństwo | Plan B |
|--------|---------------------|--------|
| Dane TCGA mają więcej braków niż się spodziewałyśmy | Średnie | Imputacja prosta (mediana) lub zawężenie kohorty do pacjentów z kompletnymi danymi |
| API cBioPortal się zmienia / ma problemy | Niskie | Pobranie danych ręcznie przez interfejs webowy jako CSV |
| Etap 6 (ML) zajmuje za dużo czasu | Średnie | Uproszczenie do regresji logistycznej z 3 zmiennymi, bez SHAP |
| Tableau nie idzie | Niskie | Zamiana na Power BI lub interaktywny dashboard w Pythonie (Plotly Dash, Streamlit) |
| Promotor zmienia oczekiwania | Niskie | Notatki z każdego seminarium, kontakt mailowy z konkretnymi pytaniami |
| Życie | Wysokie | Bufor we wrześniu, harmonogram z marginesem |

---

## 11. Zasady pracy w tym projekcie (umowa z samą sobą)

1. **Małe kroki, częste commity.** Lepiej 5 commitów dziennie po 30 minut niż 1 commit po 5 godzinach.
2. **Każdy notebook ma komentarze własnymi słowami.** Nie kopiuj wyjaśnień AI bezrefleksyjnie.
3. **Każda funkcja ma docstring.** Krótki, ale jest.
4. **Każdy wykres ma tytuł, etykiety osi i jednostki.** Tak jak w pracy magisterskiej.
5. **Co tydzień przegląd postępu.** "Co zrobiłam, co dalej, co mnie blokuje?"
6. **Pytania zadaję od razu, nie odkładam.** Szybkie pytanie do AI/promotora vs 3 dni utknięcia.
7. **Reprodukowalność > elegancja.** Lepiej brzydki kod, który działa, niż piękny, który nie chce się uruchomić.
8. **Wracam do tej instrukcji co tydzień.** Sprawdzam, gdzie jestem.

---

## 12. Słowniczek pojęć (do wracania)

| Pojęcie | Wyjaśnienie |
|---------|-------------|
| API | Sposób, w jaki programy komunikują się przez internet. |
| Pipeline | Cała seria kroków od surowych danych do wyniku. |
| ETL | Extract-Transform-Load. Pobierz, przekształć, załaduj. |
| Repozytorium / repo | Folder z projektem zhostowany na GitHubie. |
| Commit | Zapis zmiany w kodzie z opisem. |
| Branch / gałąź | Równoległa wersja kodu (na początku nie potrzebna, główna `main` wystarczy). |
| EDA | Exploratory Data Analysis - eksploracyjna analiza danych. |
| Schema | Opis struktury bazy danych (tabele i ich kolumny). |
| ERD | Entity Relationship Diagram - rysunek bazy. |
| JOIN | Łączenie danych z różnych tabel po wspólnym kluczu. |
| CTE | Common Table Expression - "tymczasowa tabela" w zapytaniu SQL. |
| Kohorta | Grupa pacjentów objętych analizą. |
| OS | Overall Survival - całkowite przeżycie od diagnozy do zgonu. |
| KM | Kaplan-Meier - metoda wykresu prawdopodobieństwa przeżycia w czasie. |
| Log-rank | Test statystyczny porównujący krzywe KM. |
| HR | Hazard Ratio - stosunek ryzyka między grupami. |
| Cox / regresja Coxa | Model statystyczny do analizy wpływu wielu zmiennych na przeżycie. |
| Train/test split | Podział danych na treningowe i testowe dla ML. |
| Walidacja krzyżowa | Sposób oceny modelu ML, w którym dane są dzielone wielokrotnie. |
| AUC | Area Under Curve - miara jakości klasyfikatora (0-1, im wyżej tym lepiej). |
| Feature importance | Ranking ważności zmiennych w modelu ML. |
| SHAP | Metoda wyjaśniania, dlaczego model dał konkretny wynik. |
| Dashboard | Interaktywna strona z wykresami i filtrami (Tableau, Power BI). |
| MVP | Minimum Viable Product - najprostsza działająca wersja produktu. |
| Reprodukowalność | Cecha projektu, że ktoś inny może odtworzyć wyniki na podstawie kodu. |
| Reading materials | Materiały referencyjne (literatura naukowa, dokumentacja narzędzi). |

---

## 13. Pierwsze kroki (zaraz po przeczytaniu)

1. Przejrzyj ten dokument całościowo, nawet jeśli dużo nie rozumiesz - ma być punktem odniesienia.
2. Wrzuć go do swojego projektu (jako `docs/instrukcja_projektu.md`).
3. Daj mi znać, co jest niejasne, co chcesz zmienić.
4. Po akceptacji zaczynamy **Etap 0 - Setup środowiska**. Zrobimy to razem krok po kroku.

---

*Dokument żywy - aktualizujemy go w trakcie projektu w miarę postępów i zmian.*
