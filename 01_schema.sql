-- =============================================================================
-- HIPAA-Compliant Clinic Database Schema
-- Author: [Your Name]
-- Description: Relational database simulating a small clinic's patient
--              management system, designed with HIPAA Privacy and Security
--              Rule principles in mind.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Drop existing tables (safe re-run)
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS medical_records;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS providers;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS users;

-- -----------------------------------------------------------------------------
-- DEPARTMENTS
-- Represents clinical departments within the facility
-- -----------------------------------------------------------------------------
CREATE TABLE departments (
    department_id   INT PRIMARY KEY AUTO_INCREMENT,
    dept_name       VARCHAR(100) NOT NULL,
    dept_code       VARCHAR(10)  NOT NULL UNIQUE,
    location        VARCHAR(100),
    phone           VARCHAR(15),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- PROVIDERS
-- Clinicians who deliver care — separated from user accounts intentionally
-- (principle of least privilege: a provider record ≠ system access)
-- -----------------------------------------------------------------------------
CREATE TABLE providers (
    provider_id     INT PRIMARY KEY AUTO_INCREMENT,
    department_id   INT NOT NULL,
    first_name      VARCHAR(50)  NOT NULL,
    last_name       VARCHAR(50)  NOT NULL,
    credentials     VARCHAR(20),               -- e.g. MD, NP, PA
    specialty       VARCHAR(100),
    npi_number      CHAR(10) UNIQUE,           -- National Provider Identifier
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- -----------------------------------------------------------------------------
-- PATIENTS
-- Core PHI (Protected Health Information) table.
-- HIPAA Design Notes:
--   - PII stored centrally and referenced by ID elsewhere (minimizes exposure)
--   - SSN stored as a hash placeholder (never store plaintext SSN in production)
--   - All columns are the minimum necessary per HIPAA Minimum Necessary Rule
-- -----------------------------------------------------------------------------
CREATE TABLE patients (
    patient_id          INT PRIMARY KEY AUTO_INCREMENT,
    first_name          VARCHAR(50)  NOT NULL,
    last_name           VARCHAR(50)  NOT NULL,
    date_of_birth       DATE         NOT NULL,
    gender              ENUM('Male','Female','Non-binary','Prefer not to say'),
    ssn_hash            CHAR(64),              -- SHA-256 hash only, never plaintext
    phone               VARCHAR(15),
    email               VARCHAR(100),
    address_line1       VARCHAR(100),
    address_line2       VARCHAR(100),
    city                VARCHAR(50),
    state               CHAR(2),
    zip_code            CHAR(10),
    emergency_contact   VARCHAR(100),
    emergency_phone     VARCHAR(15),
    insurance_provider  VARCHAR(100),
    insurance_policy_no VARCHAR(50),
    is_active           BOOLEAN DEFAULT TRUE,
    created_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- MEDICAL RECORDS
-- Clinical notes and diagnoses linked to patient + provider.
-- Separated from patient demographics intentionally — a billing clerk
-- may need demographics but should NOT access clinical notes.
-- -----------------------------------------------------------------------------
CREATE TABLE medical_records (
    record_id       INT PRIMARY KEY AUTO_INCREMENT,
    patient_id      INT NOT NULL,
    provider_id     INT NOT NULL,
    visit_date      DATE NOT NULL,
    chief_complaint VARCHAR(255),
    diagnosis_code  VARCHAR(10),               -- ICD-10 code
    diagnosis_desc  VARCHAR(255),
    notes           TEXT,
    is_sensitive    BOOLEAN DEFAULT FALSE,     -- flag for extra-sensitive records
                                               -- (e.g., mental health, substance use)
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id)  REFERENCES patients(patient_id),
    FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
);

-- -----------------------------------------------------------------------------
-- APPOINTMENTS
-- Scheduling table — links patients to providers with status tracking
-- -----------------------------------------------------------------------------
CREATE TABLE appointments (
    appointment_id  INT PRIMARY KEY AUTO_INCREMENT,
    patient_id      INT NOT NULL,
    provider_id     INT NOT NULL,
    dept_id         INT NOT NULL,
    scheduled_dt    DATETIME NOT NULL,
    duration_mins   INT DEFAULT 30,
    appt_type       ENUM('New Patient','Follow-up','Urgent','Telehealth') NOT NULL,
    status          ENUM('Scheduled','Completed','Cancelled','No-show') DEFAULT 'Scheduled',
    reason          VARCHAR(255),
    notes           VARCHAR(500),
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id)  REFERENCES patients(patient_id),
    FOREIGN KEY (provider_id) REFERENCES providers(provider_id),
    FOREIGN KEY (dept_id)     REFERENCES departments(department_id)
);

-- -----------------------------------------------------------------------------
-- USERS (System Access Accounts)
-- Deliberately separate from providers — not every system user is a provider
-- and not every provider has system access. Role-based access control (RBAC)
-- is a core HIPAA Security Rule requirement (§164.312(a)(1)).
-- -----------------------------------------------------------------------------
CREATE TABLE users (
    user_id         INT PRIMARY KEY AUTO_INCREMENT,
    provider_id     INT,                       -- NULL if non-clinical staff
    username        VARCHAR(50) NOT NULL UNIQUE,
    password_hash   CHAR(64)   NOT NULL,       -- bcrypt/SHA-256 hash only
    role            ENUM('admin','clinician','billing','receptionist','readonly') NOT NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    last_login      TIMESTAMP,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (provider_id) REFERENCES providers(provider_id)
);

-- -----------------------------------------------------------------------------
-- AUDIT LOG
-- HIPAA Security Rule §164.312(b) requires audit controls — tracking who
-- accessed or modified PHI and when. This table fulfills that requirement.
-- -----------------------------------------------------------------------------
CREATE TABLE audit_log (
    log_id          BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id         INT,
    action          ENUM('SELECT','INSERT','UPDATE','DELETE') NOT NULL,
    table_name      VARCHAR(50) NOT NULL,
    record_id       INT,
    action_detail   VARCHAR(500),
    ip_address      VARCHAR(45),               -- supports IPv6
    action_ts       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);
