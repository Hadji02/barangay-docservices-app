-- ============================================================
-- schema.sql : CREATE DATABASE and CREATE TABLE statements
-- Barangay San Rafael Document Services and Resident Records System
-- Target: MySQL 8.x / InnoDB (Laragon + HeidiSQL)
-- Run this file FIRST, then seed.sql
-- WARNING: drops the 6 project tables if they already exist.
-- ============================================================

-- ============================================================
-- PART 1 - CREATE DATABASE
-- ============================================================

CREATE DATABASE IF NOT EXISTS barangay_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE barangay_db;


-- ============================================================
-- PART 2 - CREATE TABLES AND CONSTRAINTS
-- ============================================================
-- FOREIGN KEY POLICY (justification):
--   ON DELETE RESTRICT everywhere. Zones, households, residents,
--   officials, document types and requests are permanent
--   records (and requests involve money). Deleting a parent
--   must never silently delete or orphan its children.
--   ON UPDATE CASCADE everywhere. If a key value is ever
--   corrected, the change flows to every child row.
--   (No CASCADE delete is used: the old Blotter/Involvement
--   tables were the only ones that needed it, and they are
--   now out of scope.)
-- ============================================================

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS document_request;
DROP TABLE IF EXISTS official;
DROP TABLE IF EXISTS document_type;
DROP TABLE IF EXISTS resident;
DROP TABLE IF EXISTS household;
DROP TABLE IF EXISTS zone;

SET FOREIGN_KEY_CHECKS = 1;


-- ------------------------------------------------------------
-- 2.1 ZONE
-- zone_id IS the zone number (Zone 1, Zone 2, ...), so it is
-- NOT auto-increment and there is no zone_name column.
-- leader_id is NULL at first, because the leader is a resident
-- and residents cannot exist before their zone/household.
-- The FK to resident is added in 2.7 (circular reference).
-- ------------------------------------------------------------

CREATE TABLE zone (
    zone_id   INT UNSIGNED NOT NULL,
    leader_id INT UNSIGNED NULL,

    PRIMARY KEY (zone_id),
    CONSTRAINT uq_zone_leader UNIQUE (leader_id)
) ENGINE=InnoDB;


-- ------------------------------------------------------------
-- 2.2 HOUSEHOLD
-- house_no is continuous across the whole barangay
-- (never repeats in another zone), so it is the sole PK.
-- zone_id is an ordinary FK.
-- ------------------------------------------------------------

CREATE TABLE household (
    house_no    INT UNSIGNED NOT NULL AUTO_INCREMENT,
    street_name VARCHAR(100) NOT NULL,
    zone_id     INT UNSIGNED NOT NULL,

    PRIMARY KEY (house_no),

    CONSTRAINT fk_household_zone
        FOREIGN KEY (zone_id) REFERENCES zone (zone_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;


-- ------------------------------------------------------------
-- 2.3 RESIDENT
-- ------------------------------------------------------------

CREATE TABLE resident (
    resident_id  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    first_name   VARCHAR(50)  NOT NULL,
    last_name    VARCHAR(50)  NOT NULL,
    birth_date   DATE         NOT NULL,
    sex          VARCHAR(10)  NOT NULL,
    civil_status VARCHAR(15)  NOT NULL,
    contact_no   VARCHAR(15)  NULL,
    house_no     INT UNSIGNED NOT NULL,

    PRIMARY KEY (resident_id),

    CONSTRAINT fk_resident_household
        FOREIGN KEY (house_no) REFERENCES household (house_no)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_resident_sex
        CHECK (sex IN ('Male', 'Female')),

    CONSTRAINT chk_resident_civil_status
        CHECK (civil_status IN ('Single', 'Married', 'Widowed', 'Separated'))
) ENGINE=InnoDB;


-- ------------------------------------------------------------
-- 2.4 DOCUMENT_TYPE
-- ------------------------------------------------------------

CREATE TABLE document_type (
    doctype_id   INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    doctype_name VARCHAR(50)   NOT NULL,
    fee          DECIMAL(8,2)  NOT NULL DEFAULT 0.00,

    PRIMARY KEY (doctype_id),
    CONSTRAINT uq_doctype_name UNIQUE (doctype_name),
    CONSTRAINT chk_doctype_fee CHECK (fee >= 0)
) ENGINE=InnoDB;


-- ------------------------------------------------------------
-- 2.5 OFFICIAL
-- An official IS a resident who holds a position, so name and
-- contact details are NOT repeated here (they live in resident).
-- UNIQUE(resident_id): one resident holds at most one position.
-- ------------------------------------------------------------

CREATE TABLE official (
    official_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    resident_id INT UNSIGNED NOT NULL,
    position    VARCHAR(20)  NOT NULL,

    PRIMARY KEY (official_id),
    CONSTRAINT uq_official_resident UNIQUE (resident_id),

    CONSTRAINT fk_official_resident
        FOREIGN KEY (resident_id) REFERENCES resident (resident_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_official_position
        CHECK (position IN ('Captain', 'Kagawad', 'Secretary', 'Treasurer'))
) ENGINE=InnoDB;


-- ------------------------------------------------------------
-- 2.6 DOCUMENT_REQUEST (associative entity)
-- released_at stays NULL while the request is pending.
-- ------------------------------------------------------------

CREATE TABLE document_request (
    request_id   INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    resident_id  INT UNSIGNED  NOT NULL,
    doctype_id   INT UNSIGNED  NOT NULL,
    official_id  INT UNSIGNED  NOT NULL,
    purpose      VARCHAR(100)  NOT NULL,
    requested_at DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    released_at  DATETIME      NULL,
    amount_paid  DECIMAL(8,2)  NOT NULL DEFAULT 0.00,

    PRIMARY KEY (request_id),

    CONSTRAINT fk_request_resident
        FOREIGN KEY (resident_id) REFERENCES resident (resident_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_request_doctype
        FOREIGN KEY (doctype_id) REFERENCES document_type (doctype_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_request_official
        FOREIGN KEY (official_id) REFERENCES official (official_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT chk_request_amount_paid
        CHECK (amount_paid >= 0),

    CONSTRAINT chk_request_release_date
        CHECK (released_at IS NULL OR released_at >= requested_at)
) ENGINE=InnoDB;


-- ------------------------------------------------------------
-- 2.7 CIRCULAR FK: zone.leader_id -> resident.resident_id
-- Added last because resident did not exist when zone was made.
-- ------------------------------------------------------------

ALTER TABLE zone
    ADD CONSTRAINT fk_zone_leader
        FOREIGN KEY (leader_id) REFERENCES resident (resident_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE;


