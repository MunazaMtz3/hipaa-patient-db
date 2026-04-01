-- =============================================================================
-- Sample Data — Entirely Synthetic / Fictional
-- DO NOT use real patient information. All names, dates, and identifiers
-- in this file are randomly generated and do not represent real individuals.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Departments
-- -----------------------------------------------------------------------------
INSERT INTO departments (dept_name, dept_code, location, phone) VALUES
('Primary Care',          'PC',  'Building A, Floor 1', '703-555-0101'),
('Cardiology',            'CARD','Building B, Floor 2', '703-555-0102'),
('Mental Health Services','MHS', 'Building C, Floor 1', '703-555-0103'),
('Pediatrics',            'PED', 'Building A, Floor 2', '703-555-0104'),
('Urgent Care',           'UC',  'Building A, Floor 1', '703-555-0105');

-- -----------------------------------------------------------------------------
-- Providers
-- -----------------------------------------------------------------------------
INSERT INTO providers (department_id, first_name, last_name, credentials, specialty, npi_number) VALUES
(1, 'Sarah',   'Nguyen',    'MD',  'Family Medicine',        '1234567890'),
(1, 'James',   'Okafor',    'NP',  'Primary Care',           '1234567891'),
(2, 'Linda',   'Patel',     'MD',  'Cardiology',             '1234567892'),
(3, 'Marcus',  'Chen',      'PhD', 'Clinical Psychology',    '1234567893'),
(4, 'Amara',   'Williams',  'MD',  'Pediatrics',             '1234567894'),
(5, 'Roberto', 'Castillo',  'PA',  'Emergency Medicine',     '1234567895');

-- -----------------------------------------------------------------------------
-- Patients (synthetic PHI — all fictional)
-- -----------------------------------------------------------------------------
INSERT INTO patients (
    first_name, last_name, date_of_birth, gender,
    phone, email, address_line1, city, state, zip_code,
    emergency_contact, emergency_phone,
    insurance_provider, insurance_policy_no
) VALUES
('Michael',  'Torres',   '1985-03-12', 'Male',
 '703-555-1001', 'mtorres.fake@email.com', '123 Maple St', 'Fairfax', 'VA', '22030',
 'Diana Torres', '703-555-1002', 'Blue Cross Blue Shield', 'BCBS-001-2024'),

('Jennifer', 'Wallace',  '1992-07-28', 'Female',
 '571-555-2001', 'jwallace.fake@email.com', '456 Oak Ave', 'Reston', 'VA', '20190',
 'Robert Wallace', '571-555-2002', 'Aetna', 'AET-002-2024'),

('David',    'Kim',      '1978-11-04', 'Male',
 '703-555-3001', 'dkim.fake@email.com', '789 Pine Rd', 'Alexandria', 'VA', '22301',
 'Susan Kim', '703-555-3002', 'UnitedHealthcare', 'UHC-003-2024'),

('Priya',    'Sharma',   '2015-05-19', 'Female',
 '571-555-4001', 'psharma.parent.fake@email.com', '321 Elm Dr', 'Springfield', 'VA', '22150',
 'Raj Sharma', '571-555-4002', 'Cigna', 'CIG-004-2024'),

('Carlos',   'Mendez',   '1960-09-30', 'Male',
 '703-555-5001', 'cmendez.fake@email.com', '654 Cedar Ln', 'Herndon', 'VA', '20170',
 'Maria Mendez', '703-555-5002', 'Medicare', 'MED-005-2024'),

('Aisha',    'Johnson',  '1999-01-15', 'Female',
 '571-555-6001', 'ajohnson.fake@email.com', '987 Birch Ct', 'Ashburn', 'VA', '20147',
 'Patricia Johnson', '571-555-6002', 'Medicaid', 'MCD-006-2024');

-- -----------------------------------------------------------------------------
-- Medical Records
-- Note: ICD-10 codes used are real codes applied to fictional patients
-- -----------------------------------------------------------------------------
INSERT INTO medical_records (patient_id, provider_id, visit_date, chief_complaint, diagnosis_code, diagnosis_desc, notes, is_sensitive) VALUES
(1, 1, '2024-11-10', 'Persistent cough and fatigue',      'J06.9',  'Acute upper respiratory infection', 'Patient reports symptoms for 5 days. Prescribed rest and fluids.', FALSE),
(2, 3, '2024-11-15', 'Chest pain on exertion',            'I25.10', 'Atherosclerotic heart disease',     'Referred for stress test. Patient advised to reduce sodium intake.', FALSE),
(3, 1, '2024-12-01', 'Annual wellness visit',              'Z00.00', 'Encounter for general adult exam',  'All vitals normal. Bloodwork ordered.', FALSE),
(4, 5, '2024-12-10', 'Ear pain and fever',                 'H66.90', 'Otitis media, unspecified',         'Amoxicillin prescribed. Follow up in 10 days.', FALSE),
(5, 3, '2025-01-05', 'Shortness of breath',                'I50.9',  'Heart failure, unspecified',        'Echo ordered. Patient instructed to monitor fluid intake.', FALSE),
(6, 4, '2025-01-20', 'Anxiety and difficulty sleeping',   'F41.1',  'Generalized anxiety disorder',      'CBT sessions recommended. Follow-up in 4 weeks.', TRUE);
-- Note: Record 6 flagged is_sensitive=TRUE (mental health) — restricts access per HIPAA

-- -----------------------------------------------------------------------------
-- Appointments
-- -----------------------------------------------------------------------------
INSERT INTO appointments (patient_id, provider_id, dept_id, scheduled_dt, appt_type, status, reason) VALUES
(1, 1, 1, '2025-02-10 09:00:00', 'Follow-up',   'Completed',  'Follow up on respiratory infection'),
(2, 3, 2, '2025-02-12 10:30:00', 'Follow-up',   'Completed',  'Stress test results review'),
(3, 2, 1, '2025-03-01 08:00:00', 'Follow-up',   'Completed',  'Bloodwork results'),
(4, 5, 4, '2025-03-15 14:00:00', 'Follow-up',   'Completed',  'Post-treatment ear check'),
(5, 3, 2, '2025-04-01 11:00:00', 'Follow-up',   'Scheduled',  'Echo results and medication review'),
(6, 4, 3, '2025-04-10 13:00:00', 'Follow-up',   'Scheduled',  'CBT session 2'),
(1, 2, 1, '2025-04-20 09:30:00', 'New Patient', 'Scheduled',  'Switching primary care provider'),
(3, 1, 5, '2025-04-25 16:00:00', 'Urgent',      'Scheduled',  'Acute back pain');

-- -----------------------------------------------------------------------------
-- Users (system accounts — passwords shown as hash placeholders)
-- -----------------------------------------------------------------------------
INSERT INTO users (provider_id, username, password_hash, role) VALUES
(NULL, 'admin.user',     'HASH_PLACEHOLDER_bcrypt', 'admin'),
(1,    'snguyen',        'HASH_PLACEHOLDER_bcrypt', 'clinician'),
(2,    'jokafor',        'HASH_PLACEHOLDER_bcrypt', 'clinician'),
(3,    'lpatel',         'HASH_PLACEHOLDER_bcrypt', 'clinician'),
(4,    'mchen',          'HASH_PLACEHOLDER_bcrypt', 'clinician'),
(NULL, 'billing.desk1', 'HASH_PLACEHOLDER_bcrypt', 'billing'),
(NULL, 'front.desk1',   'HASH_PLACEHOLDER_bcrypt', 'receptionist');

-- -----------------------------------------------------------------------------
-- Seed audit log with example entries
-- -----------------------------------------------------------------------------
INSERT INTO audit_log (user_id, action, table_name, record_id, action_detail, ip_address) VALUES
(2, 'SELECT', 'medical_records', 1, 'Provider viewed patient record', '192.168.1.10'),
(6, 'SELECT', 'patients',        2, 'Billing accessed patient demographics for claims', '192.168.1.20'),
(7, 'INSERT', 'appointments',    8, 'Receptionist scheduled new appointment', '192.168.1.30'),
(1, 'UPDATE', 'users',           3, 'Admin reset provider account status', '192.168.1.1');
