-- =======================================================
-- BALE ODY VILLA & CAMPING GROUND - DATABASE SCHEMA (MYSQL)
-- Generated for Local Simulation & Production Deployment
-- =======================================================

CREATE DATABASE IF NOT EXISTS `bald6243_u12345_baleody` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `bald6243_u12345_baleody`;

-- -------------------------------------------------------
-- 1. TABEL AKUN PENGGUNA (ACCOUNTS)
-- -------------------------------------------------------
DROP TABLE IF EXISTS `accounts`;
CREATE TABLE `accounts` (
  `id` VARCHAR(64) NOT NULL,
  `username` VARCHAR(100) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `role` ENUM('Administrator', 'Kasir') NOT NULL DEFAULT 'Kasir',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `accounts` (`id`, `username`, `password`, `role`) VALUES
('u-admin', 'admin', 'admin123', 'Administrator'),
('u-kasir', 'kasir', 'kasir123', 'Kasir');

-- -------------------------------------------------------
-- 2. TABEL MASTER VILLA / KAMAR (VILLAS)
-- -------------------------------------------------------
DROP TABLE IF EXISTS `villas`;
CREATE TABLE `villas` (
  `id` VARCHAR(64) NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `price` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `stock` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `villas` (`id`, `name`, `price`, `stock`) VALUES
('v-lumbung', 'Villa Lumbung Tradisional', 750000.00, 4),
('v-glamping', 'Villa Glamping Deluxe', 950000.00, 3),
('v-suite', 'Family Suite Mountain View', 1500000.00, 2),
('v-camping', 'Tenda Camping VIP (Ground)', 350000.00, 8);

-- -------------------------------------------------------
-- 3. TABEL RESERVASI / BOOKING (BOOKINGS)
-- -------------------------------------------------------
DROP TABLE IF EXISTS `bookings`;
CREATE TABLE `bookings` (
  `id` VARCHAR(64) NOT NULL,
  `customer_name` VARCHAR(150) NOT NULL,
  `check_in` DATE NOT NULL,
  `check_out` DATE NOT NULL,
  `discount` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `dp` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `dp_payment_method` VARCHAR(50) NOT NULL DEFAULT 'None',
  `lunas_payment_method` VARCHAR(50) NOT NULL DEFAULT 'None',
  `total_price` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_check_dates` (`check_in`, `check_out`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- 4. TABEL ITEM KAMAR PER BOOKING (BOOKING_ITEMS)
-- -------------------------------------------------------
DROP TABLE IF EXISTS `booking_items`;
CREATE TABLE `booking_items` (
  `id` INT AUTO_INCREMENT NOT NULL,
  `booking_id` VARCHAR(64) NOT NULL,
  `villa_id` VARCHAR(64) NOT NULL,
  `qty` INT NOT NULL DEFAULT 1,
  `price_paid` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `idx_booking_id` (`booking_id`),
  KEY `idx_villa_id` (`villa_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- 5. TABEL ADD-ON / TAMBAHAN BIAYA (BOOKING_ADDONS)
-- -------------------------------------------------------
DROP TABLE IF EXISTS `booking_addons`;
CREATE TABLE `booking_addons` (
  `id` INT AUTO_INCREMENT NOT NULL,
  `booking_id` VARCHAR(64) NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `price` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `idx_booking_id` (`booking_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -------------------------------------------------------
-- 6. TABEL PENGATURAN / IDENTITAS BRAND (SETTINGS)
-- -------------------------------------------------------
DROP TABLE IF EXISTS `settings`;
CREATE TABLE `settings` (
  `setting_key` VARCHAR(100) NOT NULL,
  `setting_value` LONGTEXT NULL,
  PRIMARY KEY (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `settings` (`setting_key`, `setting_value`) VALUES
('villaName', 'Bale Ody Villa & Camping Ground'),
('villaLogo', ''),
('villaFavicon', '');

-- -------------------------------------------------------
-- DUMMY TRANSACTION DATA (UNTUK PENGUJIAN KALENDER & LAPORAN)
-- -------------------------------------------------------
INSERT INTO `bookings` (`id`, `customer_name`, `check_in`, `check_out`, `discount`, `dp`, `dp_payment_method`, `lunas_payment_method`, `total_price`, `created_at`) VALUES
('b-demo-01', 'Bpk. Hendra Gunawan', CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 2 DAY), 50000.00, 1850000.00, 'Transfer BCA', 'Cash', 1850000.00, NOW()),
('b-demo-02', 'Ibu Maya Safitri', DATE_ADD(CURRENT_DATE, INTERVAL 3 DAY), DATE_ADD(CURRENT_DATE, INTERVAL 5 DAY), 0.00, 500000.00, 'QRIS', 'None', 1500000.00, NOW());

INSERT INTO `booking_items` (`booking_id`, `villa_id`, `qty`, `price_paid`) VALUES
('b-demo-01', 'v-glamping', 1, 950000.00),
('b-demo-02', 'v-lumbung', 1, 750000.00);

INSERT INTO `booking_addons` (`booking_id`, `name`, `price`) VALUES
('b-demo-01', 'Extra Bed', 100000.00),
('b-demo-01', 'Paket Api Unggun & Jagung Bakar', 150000.00);
