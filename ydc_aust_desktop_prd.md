# Product Requirement Document (PRD)
## Project: Youth Development Center (YDC) Desktop Management System
**Client:** Youth Development Center, Abbottabad University of Science & Technology (AUST)  
**Target Platform:** Windows Desktop Application (`.exe`)  
**Technology Stack:** Flutter Desktop (Windows), SQLite / Supabase / PostgreSQL Local Engine, Tesseract OCR / Vision Pipeline, PDF Engine  
**Version:** 1.0.0-PROD  
**Document Author:** Co-Founder & Principal Technical Product Manager  

---

## 1. Executive Summary & Vision

### 1.1 Context & Objectives
The Youth Development Center (YDC) at Abbottabad University of Science and Technology (AUST) orchestrates student societies, institutional events, corporate and governmental linkages (such as the Prime Minister’s Youth Programme - PMYP), financial audits, and confidential legal/administrative records. 

Currently, administrative overhead is fragmented across hard-copy files, disparate spreadsheets, and disconnected social threads. The goal is to build an offline-first, enterprise-grade, secure Windows Desktop (`.exe`) client using Flutter to centralize, standardize, and automate the operations of YDC AUST.

### 1.2 Core Strategic Pillars
The software architecture maps directly to the official four operational pillars of YDC:
1. **Education** (Skill acquisition, literacy, technical workshops)
2. **Employment** (Industry linkages, career placement, PMYP fellowships)
3. **Engagement** (Campus life, national celebrations, sports, social drives)
4. **Environment** (Eco-sustainability, clean campus drives, green research)

---

## 2. System Architecture & Tech Stack

* **Front-End / Runtime:** Flutter for Windows Desktop (Win32 / C++ runner producing self-contained `.exe`).
* **State Management:** Flutter Bloc or Riverpod (predictable state and offline-first reactive stream).
* **Local Data Layer:** Drift (type-safe SQLite ORM) with SQLCipher (256-bit AES encryption at rest) for confidential records and local offline reliability.
* **Remote Sync Engine (Optional / Phase 2):** Supabase Self-Hosted or PostgreSQL with Row-Level Security (RLS) for multi-workstation sync.
* **Data Ingestion Engine:**
  * Native File Picker integration for `.csv` and `.xlsx` via `excel` and `csv` Dart packages.
  * Image Document Parsing: OCR engine (Google ML Kit Document Scanner / Tesseract OCR native bindings) with a visual review/correction modal.
* **Report Generation:** `pdf` and `printing` Dart packages with templated monthly executive digests.
* **Storage Layer:** Local AppData vault with SHA-256 hashed filenames and encrypted pointers for confidential documents (MOUs, PMYP files, Contracts).

---

## 3. Detailed Functional Modules

```
                        +------------------------------------------+
                        |           YDC AUST DESKTOP ERP           |
                        +------------------------------------------+
                                              |
    +-------------------+---------------------+--------------------+--------------------+
    |                   |                     |                    |                    |
+---+---+           +---+---+             +---+---+            +---+---+            +---+---+
| Auth  |           |Societies|           | Events|            |Records|            | Vault |
|  RBAC |           | Engine  |           | Engine|            |Reports|            | (MOU) |
+-------+           +---------+           +-------+            +-------+            +-------+
```

### Module 1: Societies & Governance
Every society is an administrative entity linked to one of the four YDC pillars.

#### 1.1 Core Components
* **Society Profile:** Name, Acronym, Dedicated Pillar, Date Founded, Faculty Advisor/Patron, Logo.
* **Cabinet Management (Tenure-Based):**
  * Tracks historical and active cabinets per academic session (e.g., `2025-2026`).
  * Mandatory Roles:
    * President
    * Vice President
    * General Secretary
    * Coordinator
    * Media Officer
  * Role Data Schema: Full Name, Email, Phone Number, CNIC (with `XXXXX-XXXXXXX-X` format validation), Department, Semester.
* **General Membership:**
  * Member attributes: Roll Number / Student ID, Full Name, CNIC, Email, Department, Current Semester, Active Status.
* **Multi-Channel Data Ingestion Pipeline:**
  * **Manual Entry:** Form-based validation with real-time field masks.
  * **Excel / CSV Import:** Batch ingestion supporting schema mapping (handles inconsistent column headers via column-picker modal).
  * **Sheet Photo / OCR Extraction:** Camera/Image file upload of physical sign-up sheets. Image undergoes thresholding, OCR text extraction, regex parsing into a structured review grid where the admin can verify/edit rows before saving to the database.
* **Society Event History:** Embedded sub-view listing all historical events hosted or co-hosted by the specific society.

---

### Module 2: Events Management Engine
Manages the end-to-end lifecycle of university-wide and society-specific events.

#### 2.1 Event Schema & Metadata
* **Basic Details:** Title, Short Tagline, Detailed Narrative / Description, Event Cover Banner / High-Res Pictures.
* **Host Type:**
  * `Self` (Hosted solely by a single society or YDC central team).
  * `Collaboration` (Co-hosted; requires dynamic inputs for External Partners / Internal Societies).
* **Affiliation:** Foreign Key link to Society (or central YDC).
* **Schedule & Location:** Event Date, Start Time, End Time, Campus Venue / Auditorium.
* **Finance Tracking:** Incurred Costs, Allocated Budget, Revenue/Sponsorships.
* **Impact Metric:** Impact Type (Quantitative: Attendees Count; Qualitative: Positive Impact Statement, Academic outcomes, Community value).
* **Guest & Keynote Speaker Directory:**
  * Full Name
  * Official Designation & Organization / Affiliation
  * Contact Info (Phone, Email, LinkedIn)
  * Honorarium / Travel Cost (if any)

#### 2.2 Event Actions
* Real-time search, multi-filter by pillar, society, date range, or collaborative status.
* Export Single Event Summary to Print/PDF.

---

### Module 3: All Records, Auditing & Monthly Reporting
The institutional intelligence hub of YDC.

#### 3.1 Aggregated Record Sets
* **Total YDC Enrollment Master File:** Unified view of all active students across all societies. Displays: Student Name, CNIC, Email, Department, Associated Society, Date Enrolled.
* **Central Events Archive:** Master searchable index of every event executed across the university.
* **Achievements of the Month:** Curated records of student awards, external competitions won, regional/national recognitions, and media coverage.
* **Monthly Financial & Audit Logs:** Itemized expenditure vs. balance ledgers, petty cash logs, university allocation receipts, and external sponsorships.
* **Sponsorships & Donors Ledger:** Sponsor Name, Focal Person, Contact, Agreement Value, Allocated Purpose.

#### 3.2 Automated Monthly Executive Dossier (PDF Engine)
The system contains an automated generator that compiles the entire month's operational performance into a formal, formatted A4 PDF containing:
1. University & YDC Header + Seal.
2. Executive Summary Metrics (Total Active Societies, New Enrollments, Events Hosted, Total Attendees).
3. Pillar Breakdown (Education, Employment, Engagement, Environment distribution).
4. Major Achievements Catalog.
5. Itemized Financial Audit & Sponsorship Inflows.
6. High-res Photo Collage of key events.
7. Signature lines for YDC Director, Patron, and Student Leadership.

---

### Module 4: Confidential Vault & Institutional Memory
A secured repository for sensitive legal, financial, and strategic documents.

#### 4.1 Vault Categories
* **MOUs (Memorandums of Understanding):** External industry/academic partners, signing date, expiry date, scope summary, signed PDF attachment.
* **Contracts & Legal Documents:** Vendor contracts, venue agreements, trainer retainers.
* **PMYP (Prime Minister’s Youth Programme) Dossiers:** Official correspondence, quota allotments, laptop/scholarship distributions, training initiatives.
* **YDC Fellowships & Internees:** Records of students completing official administrative internships within YDC (Stipend status, evaluations, clearance certificates).
* **Financial Ledger Audits:** Audited bank statements, internal auditor sign-offs, and voucher bundles.

#### 4.2 Security Architecture
* **Access Control:** Master PIN / Master Password protection before unlocking the Vault view.
* **File Encryption:** Uploaded documents are saved locally in an encrypted directory (`AppData/Local/YDC_AUST/Vault/`) using AES-256 GCM.
* **Export Restrictions:** Documents can only be viewed through the internal desktop document viewer with optional watermarking ("CONFIDENTIAL - YDC AUST").

---

## 4. Database Schema (Relational Blueprint)

```sql
-- Societies Table
CREATE TABLE societies (
    id TEXT PRIMARY KEY, -- UUID v4
    name TEXT NOT NULL,
    acronym TEXT,
    pillar TEXT CHECK(pillar IN ('Education', 'Employment', 'Engagement', 'Environment')),
    faculty_advisor TEXT NOT NULL,
    logo_path TEXT,
    is_active INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Cabinet Members Table
CREATE TABLE cabinet_members (
    id TEXT PRIMARY KEY,
    society_id TEXT REFERENCES societies(id) ON DELETE CASCADE,
    tenure_session TEXT NOT NULL, -- e.g. "2025-2026"
    role TEXT CHECK(role IN ('President', 'Vice President', 'General Secretary', 'Coordinator', 'Media Officer')),
    full_name TEXT NOT NULL,
    cnic TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    department TEXT NOT NULL,
    semester INTEGER NOT NULL,
    is_active INTEGER DEFAULT 1
);

-- General Society Members
CREATE TABLE society_members (
    id TEXT PRIMARY KEY,
    society_id TEXT REFERENCES societies(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    cnic TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    department TEXT NOT NULL,
    semester INTEGER NOT NULL,
    joined_date DATE,
    is_active INTEGER DEFAULT 1
);

-- Events Table
CREATE TABLE events (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    event_date DATE NOT NULL,
    society_id TEXT REFERENCES societies(id),
    is_collaboration INTEGER DEFAULT 0,
    collaborator_names TEXT,
    venue TEXT,
    allocated_budget REAL DEFAULT 0.0,
    actual_expense REAL DEFAULT 0.0,
    positive_impact_summary TEXT,
    attendees_count INTEGER DEFAULT 0,
    banner_image_path TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Event Speakers
CREATE TABLE event_speakers (
    id TEXT PRIMARY KEY,
    event_id TEXT REFERENCES events(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    designation TEXT,
    organization TEXT NOT NULL,
    contact_phone TEXT,
    contact_email TEXT
);

-- Monthly Achievements
CREATE TABLE achievements (
    id TEXT PRIMARY KEY,
    month_year TEXT NOT NULL, -- "MM-YYYY"
    title TEXT NOT NULL,
    description TEXT,
    society_id TEXT REFERENCES societies(id),
    proof_image_path TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Financial Audits & Sponsors
CREATE TABLE financial_records (
    id TEXT PRIMARY KEY,
    month_year TEXT NOT NULL,
    type TEXT CHECK(type IN ('Expense', 'Revenue', 'Sponsorship', 'Grant')),
    title TEXT NOT NULL,
    amount REAL NOT NULL,
    sponsor_name TEXT,
    voucher_path TEXT,
    notes TEXT,
    recorded_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Confidential Vault Records
CREATE TABLE confidential_vault (
    id TEXT PRIMARY KEY,
    category TEXT CHECK(category IN ('MOU', 'Contract', 'PMYP', 'Internee_Record', 'Audit')),
    title TEXT NOT NULL,
    reference_number TEXT,
    effective_date DATE,
    expiry_date DATE,
    encrypted_file_path TEXT NOT NULL,
    file_checksum TEXT NOT NULL,
    metadata_notes TEXT,
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

---

## 5. Non-Functional Requirements (NFRs)

1. **Performance & Footprint:**
   * Cold start time under 1.5 seconds on mid-range institutional hardware (Intel Core i3 / 8GB RAM).
   * App memory consumption < 220MB idle.
2. **Offline-First Resilience:**
   * 100% of data reads and writes execute against the local encrypted SQLite store. The `.exe` runs without internet access.
3. **Data Protection & Compliance:**
   * Student CNIC and phone numbers protected locally.
   * Hardened Vault module preventing direct access via standard Windows Explorer browsing.
4. **Data Portability:**
   * One-click automated database backup to a single timestamped file (`ydc_backup_YYYYMMDD.db.enc`).
   * Complete export of all tabular data to `.xlsx` and `.csv`.