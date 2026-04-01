# HIPAA-Compliant Clinic Database

A relational database project simulating a small clinic's patient management system, designed with HIPAA Privacy and Security Rule compliance principles throughout.

Built as a portfolio project demonstrating Health IT database design, access control modeling, and healthcare compliance knowledge.

---

## Project Overview

This project models the data infrastructure of a small multi-department clinic. The schema reflects real-world Health IT design decisions — separating PHI from clinical notes, enforcing role-based access, and maintaining a full audit trail — all requirements under the HIPAA Security Rule.

**All patient data is entirely synthetic and fictional. No real PHI is present anywhere in this project.**

---

## Database Schema

| Table | Purpose |
|---|---|
| `patients` | Core PHI — demographics, contact info, insurance |
| `providers` | Clinicians delivering care (separate from system access) |
| `departments` | Clinical departments within the facility |
| `medical_records` | Clinical notes and ICD-10 diagnoses |
| `appointments` | Scheduling — links patients, providers, departments |
| `users` | System access accounts with role-based access control |
| `audit_log` | Tracks all PHI access and modifications |

### Entity Relationship Diagram

```
departments
    │
    ├──< providers >──┐
                      │
patients >────────< appointments
    │                 │
    └──────────< medical_records
                      │
                   providers

users ──────────────> audit_log
```

---

## HIPAA Design Decisions

### 1. Separation of PHI Layers
Patient demographics (`patients`) are stored separately from clinical records (`medical_records`). This means a billing staff member can access insurance information without ever touching clinical notes — consistent with the **HIPAA Minimum Necessary Rule (§164.502(b))**.

### 2. Role-Based Access Control (RBAC)
The `users` table assigns one of five roles: `admin`, `clinician`, `billing`, `receptionist`, `readonly`. Each role should be granted access only to the views and tables relevant to their function — a core requirement under **HIPAA Security Rule §164.312(a)(1)**.

### 3. Role-Specific Views
Three views enforce minimum necessary access at the database level:

| View | Accessible By | Excludes |
|---|---|---|
| `vw_patient_scheduling` | Receptionist | SSN, clinical notes, insurance policy numbers |
| `vw_patient_billing` | Billing | Clinical notes, SSN, address |
| `vw_clinical_records_general` | Clinicians | Sensitive (mental health/substance use) records |

### 4. Sensitive Record Flagging
The `is_sensitive` flag on `medical_records` identifies records subject to extra protections (mental health, substance use disorder) under **42 CFR Part 2** and HIPAA. These records are excluded from the general clinical view.

### 5. Audit Log
The `audit_log` table records every SELECT, INSERT, UPDATE, and DELETE against PHI tables — including the user, timestamp, IP address, and action detail. This fulfills the **HIPAA Security Rule Audit Control requirement (§164.312(b))** and supports the patient right to an accounting of disclosures.

### 6. No Plaintext Secrets
SSNs are stored as hash placeholders (`ssn_hash CHAR(64)`). Passwords in the `users` table are hash-only fields. In a production system these would use bcrypt or Argon2. Plaintext storage of either would be a HIPAA violation.

---

## Files

```
hipaa-patient-db/
├── sql/
│   ├── 01_schema.sql           # Table definitions with HIPAA annotations
│   ├── 02_sample_data.sql      # Synthetic sample data
│   └── 03_views_and_queries.sql # Access-controlled views and example queries
└── README.md
```

---

## How to Run

**Requirements:** MySQL 8.0+ or MariaDB 10.5+

```bash
# 1. Create the database
mysql -u root -p -e "CREATE DATABASE clinic_db;"

# 2. Run schema
mysql -u root -p clinic_db < sql/01_schema.sql

# 3. Load sample data
mysql -u root -p clinic_db < sql/02_sample_data.sql

# 4. Create views and run queries
mysql -u root -p clinic_db < sql/03_views_and_queries.sql
```

---

## Technologies Used

- **MySQL 8.0** — relational database engine
- **SQL** — DDL (schema design) and DML (queries, views)
- **HIPAA Privacy Rule** — minimum necessary, PHI separation
- **HIPAA Security Rule** — RBAC, audit controls, access management
- **ICD-10** — diagnosis coding standard used in medical_records
- **NPI** — National Provider Identifier standard for providers

---

## Key Concepts Demonstrated

- Relational database normalization (3NF)
- Foreign key constraints and referential integrity
- Role-based access control modeled at the schema level
- View-based data access restriction
- Healthcare compliance (HIPAA) applied to database design
- Audit trail design for regulatory requirements
- ICD-10 and NPI integration

---

## Disclaimer

This is an academic/portfolio project. All patient data is entirely fictional and computer-generated. This database is not intended for use in any real clinical environment.
