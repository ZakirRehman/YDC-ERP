# UI/UX & System Design Specification Document
## Project: Youth Development Center (YDC) Desktop ERP System
**Institution:** Abbottabad University of Science and Technology (AUST)  
**Target Runtime:** Windows Desktop Application (`.exe`)  
**Design Reference:** SYQOR Enterprise ERP System UI Pattern  
**Author:** Co-Founder & Principal UI/UX Architect  
**Version:** 1.0.0-DESIGN  

---

## 1. Visual Identity & Design Tokens

### 1.1 The 70 / 30 Color Rule
The application strictly respects the 70/30 distribution rule to ensure an institutional, readable, and fatigue-free desktop experience.

| Role | Token Key | Hex Value | Application & Behavioral Context |
| :--- | :--- | :--- | :--- |
| **Canvas / Foundation (70%)** | `color.surface.bg` | `#F4F6F9` | Primary desktop app backdrop, workspace canvas |
| **Container / Card** | `color.surface.panel` | `#FFFFFF` | Elevated metric cards, tabular views, modal dialogs |
| **Dark Analytical Card** | `color.surface.darkHero`| `#1F242D` | High-contrast hero metric card (SYQOR-inspired) |
| **Stroke & Dividers** | `color.border.subtle` | `#E4E7EC` | 1px border lines on cards, data tables, separators |
| **Typography - Primary** | `color.text.dark` | `#111827` | Headings, vital metrics, prominent student records |
| **Typography - Muted** | `color.text.muted` | `#717D96` | Subtitles, helper text, session tags, empty states |
| **Pillar 1: Environment (30% Accent)** | `color.accent.green` | `#198754` | Primary actions, confirmation CTAs, Green initiatives |
| **Pillar 2: Education** | `color.accent.blue` | `#0D6EFD` | Academic societies, enrollment counts, verify badges |
| **Pillar 3: Employment** | `color.accent.orange` | `#E65100` | Internships, PMYP linkages, fiscal logs, alerts |
| **Pillar 4: Engagement** | `color.accent.yellow` | `#FFB300` | Campus events, sports, cultural societies, notifications |
| **Attribution Accent** | `color.brand.purple` | `#7A1CAC` | ALLDOTDEV powered-by badge, OCR engine indicators |

### 1.2 Desktop Typography Scale
* **Font Family:** `Segoe UI`, `Inter`, or system fallback `sans-serif` (Crisp text rendering on Windows DirectWrite).
* **Display Metric:** `28px` / SemiBold 700 / `#111827`
* **Card Heading:** `18px` / SemiBold 700 / `#111827`
* **Sub-Header / Label:** `13px` / Medium 600 / `#717D96`
* **Body / Table Cells:** `13px` / Regular 400 / `#111827`
* **Badge / Pill Text:** `11px` / Bold 700 / Uppercase / Letter spacing 0.5px

### 1.3 Elevation, Border Radius & Shadows
* **Border Radius:**
  * Cards / Containers: `16px` to `18px`
  * Tab Pills: `12px`
  * Action Buttons: `10px`
  * Data Inputs: `8px`
* **Card Shadow:** `0 8px 24px rgba(17, 24, 39, 0.04), 0 1px 2px rgba(17, 24, 39, 0.02)`
* **Modal Shadow:** `0 20px 48px rgba(0, 0, 0, 0.16)`

---

## 2. Global Layout Wireframe (Desktop Real Estate)

```text
+---+-----------------------------------------------------------------------------------+
| L | [AUST Time / Abbottabad, PK]                         [+ Quick Entry]  [Admin: YDC]|
| O +-----------------------------------------------------------------------------------+
| G |  DASHBOARD                                                                        |
| O |  [ Overview ]  [ Societies ]  [ Events ]  [ Records ]  [ Vault ]        [Settings]|
|   +---------------------------------------+-------------------------------------------+
| S | [ Dark Hero Card: #1F242D            ] | [ Pillar Breakdown / Operational Matrix ] |
| I | - Donut Chart: 4 Pillars Ratio        | - Society Domain | Events | Active Members|
| D | - 1,938 Registered Students           | - Education      |   8    |      420      |
| E | - 24 Active Chapters                  | - Employment     |   4    |      310      |
| B | - 89 Pending Verifications            | - Engagement     |   9    |      880      |
| A |                                       | - Environment    |   3    |      328      |
| R +---------------------------------------+-------------------------------------------+
|   | [ Card 1 ]      [ Card 2 ]      [ Card 3 ]      [ Card 4 ]      [ Card 5 ]        |
| P | 675 Enrolled    420 Ingested    18 Vault Docs   Rs. 240k Budget Monthly Audit     |
| W | (Excel Import)  (OCR Scanned)   (MoUs/PMYP)     (Allocated)     [Ready to Export] |
+---+-----------------------------------------------------------------------------------+
```

---

## 3. Screen Specifications & Module Workflows

### 3.1 Splash Screen (App Initialization)
* **Visual Presentation:** 100% clean white background `#FFFFFF`.
* **Center Hero:** YDC 4-pillar puzzle emblem (240px wide) smoothly fading in over 900ms, followed by an elegant pulsing linear progress bar.
* **Bottom Anchor:** Clean typography displaying `POWERED BY` in muted dark slate, accompanied by the `ALLDOTDEV` gradient logo (height: 26px).
* **Boot Hook:** Performs local database integrity check (`ydc_master.db`), loads encryption key store, and navigates to the Dashboard within 2.2 seconds.

### 3.2 Societies Module Screen
* **Left Sub-Panel:** Societies card grid grouped by Pillar (Education, Employment, Engagement, Environment).
* **Right Sub-Panel (Detail Flyout):**
  * **Cabinet Hierarchy:** Active tenure (e.g., 2025–2026), displaying cards for President, Vice President, General Secretary, Coordinator, and Media Officer (Name, CNIC, Phone, Email, Department, Semester).
  * **Member Ingestion Toolbar:** Three distinct action triggers:
    1. `Manual Single Entry Form` (CNIC mask `XXXXX-XXXXXXX-X`, Department drop-down).
    2. `Batch Excel (.xlsx / .csv) Uploader` (With field column mapping preview).
    3. `OCR Document Scanner` (Allows uploading or snapping a photo of attendance/sign-up sheets, extracting names and roll numbers with an interactive correction preview grid).

### 3.3 Events Management Screen
* **Calendar & List Split View:** Filter by Date Range, Host Society, or Collaboration Mode.
* **Event Detail Card:**
  * High-res banner image with pill status (`Self-Organized` or `Collaboration with [Partner]`).
  * Positive Impact statement box, attendance tally, and itemized financial expenditure.
  * Dedicated Speaker Roster widget containing guest names, organization, and official contacts.

### 3.4 All Records & Audit Dossier Screen
* **Central Master Table:** Searchable table indexing all YDC enrollments, linked societies, student CNICs, and semester standings.
* **Export Action Center:** Floating pill button titled `Generate Monthly Dossier`. Initiates the automated generation of an executive A4-sized PDF report with university insignia, budget breakdowns, and monthly highlights.

### 3.5 Confidential Vault Screen
* **Security Gate:** PIN / Password protected lock screen before records become visible.
* **Categorized Asset Vault:** Filterable tiles for MOUs, PMYP Documents, Internee Records, and Audit Vouchers.
* **Integrated In-Memory PDF/Doc Viewer:** Allows confidential viewing without creating decrypted temporary files on Windows disk storage.

---

## 4. Frontend Component Hierarchy (Flutter Windows)

```text
lib/
├── main.dart                          # Window manager initialization & root theme
├── app_theme.dart                     # 70/30 Color tokens, text styles & shapes
├── views/
│   ├── splash_screen.dart             # YDC & ALLDOTDEV branded loader
│   ├── dashboard_screen.dart          # SYQOR-style desktop grid
│   ├── societies_screen.dart          # Cabinet, members, and multi-mode ingestion
│   ├── events_screen.dart             # Calendar, collaboration tags & speaker records
│   ├── records_screen.dart            # Unified enrollment search & PDF audit export
│   └── vault_screen.dart              # PIN-gated encrypted document vault
├── widgets/
│   ├── desktop_sidebar.dart           # Fixed 76px icon dock
│   ├── hero_metric_tile.dart          # #1F242D dark analytical container
│   ├── operational_table_tile.dart    # Pillar distribution white card
│   ├── kpi_shelf_card.dart            # Lower 5-card metric row
│   └── ocr_review_modal.dart          # Image-to-table editable parser preview
└── services/
    ├── database_service.dart          # Local Drift/SQLite encrypted instance
    ├── ocr_parser_service.dart        # Tesseract/ML OCR text parser
    └── report_generator_service.dart  # Monthly dossier A4 PDF engine
```