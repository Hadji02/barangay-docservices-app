-- ============================================================
-- seed.sql : sample data (run AFTER schema.sql)
-- Order matters: zone -> household -> resident -> zone leaders
-- -> document_type -> official -> document_request
-- ============================================================

USE barangay_db;

-- ============================================================
-- PART 3 - INSERT SAMPLE DATA
-- Order matters: zone (no leader yet) -> household -> resident
-- -> set zone leaders -> document_type -> official -> request
-- ============================================================

-- 3.1 ZONES (leader_id filled in at step 3.4)
INSERT INTO zone (zone_id, leader_id) VALUES
(1, NULL),
(2, NULL),
(3, NULL);

-- 3.2 HOUSEHOLDS (house_no continues across zones: 1-8)
INSERT INTO household (house_no, street_name, zone_id) VALUES
(1, 'Rizal Street',       1),
(2, 'Rizal Street',       1),
(3, 'Mabini Street',      1),
(4, 'Mabini Street',      2),
(5, 'Bonifacio Street',   2),
(6, 'Bonifacio Street',   3),
(7, 'Luna Street',        3),
(8, 'Rizal Street',       3);

-- 3.3 RESIDENTS (resident_id 1-14, in this order)
INSERT INTO resident
    (first_name, last_name, birth_date, sex, civil_status, contact_no, house_no)
VALUES
('Antonio', 'Dela Cruz', '1975-03-15', 'Male',   'Married',   '09171234501', 1),  -- 1
('Elena',   'Dela Cruz', '1978-07-20', 'Female', 'Married',   '09171234502', 1),  -- 2
('Mark',    'Dela Cruz', '2005-11-05', 'Male',   'Single',    '09171234503', 1),  -- 3
('Sofia',   'Garcia',    '1992-01-10', 'Female', 'Single',    '09171234504', 2),  -- 4
('Ramon',   'Garcia',    '1980-06-25', 'Male',   'Married',   '09171234505', 3),  -- 5
('Liza',    'Garcia',    '1983-09-12', 'Female', 'Married',   '09171234506', 3),  -- 6
('Daniel',  'Reyes',     '1987-04-18', 'Male',   'Single',    '09171234507', 4),  -- 7
('Angela',  'Reyes',     '1989-12-30', 'Female', 'Married',   '09171234508', 4),  -- 8
('Roberto', 'Mendoza',   '1970-02-14', 'Male',   'Married',   '09171234509', 5),  -- 9
('Carla',   'Fernandez', '1985-05-09', 'Female', 'Single',    '09171234510', 5),  -- 10
('Miguel',  'Torres',    '1979-08-21', 'Male',   'Married',   '09171234511', 6),  -- 11
('Nena',    'Villanueva','1982-10-03', 'Female', 'Widowed',   '09171234512', 6),  -- 12
('Pedro',   'Santos',    '1968-01-27', 'Male',   'Married',   NULL,          7),  -- 13
('Maria',   'Lopez',     '1995-06-16', 'Female', 'Single',    '09171234514', 8);  -- 14

-- 3.4 SET ZONE LEADERS (leaders are residents)
UPDATE zone SET leader_id = 1  WHERE zone_id = 1;   -- Antonio Dela Cruz
UPDATE zone SET leader_id = 5  WHERE zone_id = 2;   -- Ramon Garcia
UPDATE zone SET leader_id = 13 WHERE zone_id = 3;   -- Pedro Santos

-- 3.5 DOCUMENT TYPES
INSERT INTO document_type (doctype_name, fee) VALUES
('Barangay Clearance',       50.00),   -- 1
('Certificate of Residency', 30.00),   -- 2
('Certificate of Indigency',  0.00),   -- 3
('Business Clearance',      100.00);   -- 4

-- 3.6 OFFICIALS (each is an existing resident)
INSERT INTO official (resident_id, position) VALUES
(9,  'Captain'),     -- 1 Roberto Mendoza
(10, 'Secretary'),   -- 2 Carla Fernandez
(11, 'Kagawad'),     -- 3 Miguel Torres
(12, 'Treasurer');   -- 4 Nena Villanueva

-- 3.7 DOCUMENT REQUESTS (released_at NULL = pending)
-- amount_paid = fee, or 0.00 / lower if the fee was waived
INSERT INTO document_request
    (resident_id, doctype_id, official_id, purpose, requested_at, released_at, amount_paid)
VALUES
(1,  1, 2, 'Employment requirement',  '2026-01-05 09:00:00', '2026-01-05 14:00:00',  50.00),
(2,  2, 2, 'School requirement',      '2026-01-06 10:00:00', '2026-01-06 15:00:00',  30.00),
(3,  3, 2, 'Financial assistance',    '2026-01-07 11:00:00', NULL,                    0.00),
(4,  1, 2, 'First-time jobseeker',    '2026-01-08 08:30:00', '2026-01-08 13:00:00',   0.00),  -- fee waived
(5,  4, 1, 'Business registration',   '2026-01-10 09:30:00', '2026-01-10 16:00:00', 100.00),
(6,  2, 2, 'School requirement',      '2026-01-12 10:30:00', NULL,                   30.00),
(7,  1, 3, 'Employment requirement',  '2026-01-15 13:00:00', '2026-01-15 17:00:00',  50.00),
(8,  3, 2, 'Medical assistance',      '2026-01-17 14:00:00', NULL,                    0.00),
(14, 1, 2, 'Passport application',    '2026-02-02 09:15:00', '2026-02-02 11:00:00',  50.00),
(13, 3, 3, 'Burial assistance',       '2026-02-03 10:00:00', '2026-02-03 15:30:00',   0.00),
(4,  2, 2, 'Scholarship application', '2026-02-10 08:45:00', '2026-02-11 09:00:00',  30.00),
(1,  4, 1, 'Business renewal',        '2026-02-14 13:20:00', '2026-02-14 16:45:00', 100.00),
(7,  2, 4, 'Bank requirement',        '2026-02-20 10:10:00', '2026-02-20 14:00:00',  30.00),
(12, 1, 2, 'Employment requirement',  '2026-03-01 09:00:00', NULL,                   50.00),
(9,  3, 3, 'Medical assistance',      '2026-03-04 11:30:00', '2026-03-04 15:00:00',   0.00);


