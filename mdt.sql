-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               10.4.32-MariaDB - mariadb.org binary distribution
-- Server OS:                    Win64
-- HeidiSQL Version:             12.10.0.7000
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for acerp_rdmrsg
CREATE DATABASE IF NOT EXISTS `acerp_rdmrsg` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci */;
USE `acerp_rdmrsg`;

-- Dumping structure for table acerp_rdmrsg.mdt_reports
CREATE TABLE IF NOT EXISTS `mdt_reports` (
  `id` int(11) DEFAULT NULL,
  `suspect` varchar(50) DEFAULT NULL,
  `officer` varchar(50) DEFAULT NULL,
  `title` varchar(50) DEFAULT NULL,
  `text` longtext DEFAULT NULL,
  `warrant` varchar(50) DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  `deleted` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- Dumping data for table acerp_rdmrsg.mdt_reports: ~0 rows (approximately)
DELETE FROM `mdt_reports`;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
