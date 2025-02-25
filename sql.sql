
--- esx

CREATE TABLE `owned_vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` varchar(46) DEFAULT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext DEFAULT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'automobile',
  `job` varchar(20) DEFAULT NULL,
  `stored` tinyint(4) NOT NULL DEFAULT 0,
  `parking` varchar(60) DEFAULT NULL,
  `pound` varchar(60) DEFAULT NULL,
  `mileage` int(11) DEFAULT 0,
  `metadata` JSON DEFAULT '{"keys":{}}',
  `glovebox` JSON DEFAULT NULL,
  `trunk` JSON DEFAULT NULL,
  `carseller` int(11) DEFAULT 0,
  `private` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_plate` (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;




--- qbox
ALTER TABLE `player_vehicles`
ADD COLUMN `mileage` INT(11) DEFAULT 0,
ADD COLUMN `metadata` JSON DEFAULT '{"keys":{}}',
ADD COLUMN `pound` VARCHAR(60) DEFAULT NULL,
ADD COLUMN `stored` TINYINT(4) DEFAULT 0
ADD COLUMN `type` varchar(20) NOT NULL DEFAULT 'automobile',
ADD COLUMN `job` varchar(20) DEFAULT NULL;