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
