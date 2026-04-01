-- =============================================================================
-- Queries & Views — HIPAA Access Control Demonstrations
-- =============================================================================

-- -----------------------------------------------------------------------------
-- VIEW: Receptionist-safe patient view
-- Receptionists need scheduling info but NOT clinical notes or SSN.
-- This view enforces the HIPAA Minimum Necessary Rule.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_patient_scheduling AS
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    p.date_of_birth,
    p.phone,
    p.email,
    p.insurance_provider,
    p.is_active
    -- Excluded: ssn_hash, address, emergency_contact, insurance_policy_no
FROM patients p
WHERE p.is_active = TRUE;

-- -----------------------------------------------------------------------------
-- VIEW: Billing-safe patient view
-- Billing needs insurance info for claims but NOT clinical notes.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_patient_billing AS
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    p.date_of_birth,
    p.insurance_provider,
    p.insurance_policy_no,
    a.appointment_id,
    a.scheduled_dt,
    a.appt_type,
    a.status
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id;

-- -----------------------------------------------------------------------------
-- VIEW: Clinical records — excludes sensitive (mental health / substance use)
-- records unless accessed by MHS department providers.
-- Sensitive records (is_sensitive=TRUE) are hidden from general clinical view.
-- This reflects HIPAA's extra protections for 42 CFR Part 2 records.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_clinical_records_general AS
SELECT
    mr.record_id,
    mr.patient_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    mr.visit_date,
    mr.chief_complaint,
    mr.diagnosis_code,
    mr.diagnosis_desc,
    CONCAT(pr.first_name, ' ', pr.last_name, ', ', pr.credentials) AS provider_name
FROM medical_records mr
JOIN patients  p  ON mr.patient_id  = p.patient_id
JOIN providers pr ON mr.provider_id = pr.provider_id
WHERE mr.is_sensitive = FALSE;   -- sensitive records excluded from general view

-- -----------------------------------------------------------------------------
-- QUERY: Upcoming appointments for the next 7 days
-- Safe for receptionist use (references scheduling view only)
-- -----------------------------------------------------------------------------
SELECT
    a.appointment_id,
    CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
    CONCAT(pr.first_name, ' ', pr.last_name, ', ', pr.credentials) AS provider,
    d.dept_name,
    a.scheduled_dt,
    a.appt_type,
    a.status
FROM appointments a
JOIN patients    p  ON a.patient_id  = p.patient_id
JOIN providers   pr ON a.provider_id = pr.provider_id
JOIN departments d  ON a.dept_id     = d.department_id
WHERE a.scheduled_dt BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 7 DAY)
  AND a.status = 'Scheduled'
ORDER BY a.scheduled_dt;

-- -----------------------------------------------------------------------------
-- QUERY: Patient visit history (for treating provider only)
-- -----------------------------------------------------------------------------
SELECT
    mr.visit_date,
    mr.chief_complaint,
    mr.diagnosis_code,
    mr.diagnosis_desc,
    mr.notes,
    CONCAT(pr.first_name, ' ', pr.last_name) AS treating_provider
FROM medical_records mr
JOIN providers pr ON mr.provider_id = pr.provider_id
WHERE mr.patient_id = 1   -- parameterize in application layer
ORDER BY mr.visit_date DESC;

-- -----------------------------------------------------------------------------
-- QUERY: Audit log — access report for a specific patient record
-- HIPAA requires facilities to provide patients an accounting of disclosures.
-- This query supports that requirement.
-- -----------------------------------------------------------------------------
SELECT
    al.action_ts,
    u.username,
    u.role,
    al.action,
    al.action_detail,
    al.ip_address
FROM audit_log al
JOIN users u ON al.user_id = u.user_id
WHERE al.table_name = 'medical_records'
  AND al.record_id  = 1   -- parameterize by record/patient in application layer
ORDER BY al.action_ts DESC;

-- -----------------------------------------------------------------------------
-- QUERY: No-show rate by provider (operational/admin use)
-- De-identified — no PHI exposed in this aggregate report
-- -----------------------------------------------------------------------------
SELECT
    CONCAT(pr.first_name, ' ', pr.last_name) AS provider,
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN a.status = 'No-show'   THEN 1 ELSE 0 END) AS no_shows,
    SUM(CASE WHEN a.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND(
        SUM(CASE WHEN a.status = 'No-show' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1
    ) AS no_show_rate_pct
FROM appointments a
JOIN providers pr ON a.provider_id = pr.provider_id
GROUP BY pr.provider_id, provider
ORDER BY no_show_rate_pct DESC;
