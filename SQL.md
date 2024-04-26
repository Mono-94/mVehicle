# DataBase 

## ESX 
- Original owned_vehicles 
- - to use it 'standalone' use this same database
```sql
CREATE TABLE `owned_vehicles` (
  `owner` varchar(60) DEFAULT NULL,
  `plate` varchar(12) NOT NULL,
  `vehicle` longtext DEFAULT NULL,
  `type` varchar(20) NOT NULL DEFAULT 'car',
  `job` varchar(20) DEFAULT NULL,
  `stored` tinyint(4) NOT NULL DEFAULT 0,
  `parking` VARCHAR(60) DEFAULT NULL,
  `pound` VARCHAR(60) DEFAULT NULL
) ENGINE=InnoDB;
```

- To inssert new
```sql
ALTER TABLE `owned_vehicles`
ADD COLUMN `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST,
ADD COLUMN `mileage` int(11) DEFAULT 0,
ADD COLUMN `coords` longtext,
ADD COLUMN `lastparking` varchar(100),
ADD COLUMN `keys` longtext DEFAULT '[]',
ADD COLUMN `metadata` longtext
```



## OX 
- Original table
```sql
CREATE TABLE
  IF NOT EXISTS `vehicles` (
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
    `plate` CHAR(8) NOT NULL DEFAULT '',
    `vin` CHAR(17) NOT NULL,
    `owner` INT UNSIGNED NULL DEFAULT NULL,
    `group` VARCHAR(50) NULL DEFAULT NULL,
    `model` VARCHAR(20) NOT NULL,
    `class` TINYINT UNSIGNED NULL DEFAULT NULL,
    `data` LONGTEXT NOT NULL,
    `trunk` LONGTEXT NULL DEFAULT NULL,
    `glovebox` LONGTEXT NULL DEFAULT NULL,
    `stored` VARCHAR(50) NULL DEFAULT NULL,
    PRIMARY KEY (`id`) USING BTREE,
    UNIQUE INDEX `plate` (`plate`) USING BTREE,
    UNIQUE INDEX `vin` (`vin`) USING BTREE,
    INDEX `FK_vehicles_characters` (`owner`) USING BTREE,
    CONSTRAINT `FK_vehicles_characters` FOREIGN KEY (`owner`) REFERENCES `characters` (`charId`) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT `FK_vehicles_groups` FOREIGN KEY (`group`) REFERENCES `ox_groups` (`name`) ON UPDATE CASCADE ON DELETE CASCADE
  );
```
- To inssert new
```sql
ALTER TABLE `vehicles`
ADD COLUMN `mileage` int(11) DEFAULT 0,
ADD COLUMN `coords` longtext,
ADD COLUMN `lastparking` varchar(100),
ADD COLUMN `type` varchar(20) DEFAULT NULL,
ADD COLUMN `keys` longtext DEFAULT '[]',
ADD COLUMN `pound` VARCHAR(60) 
```