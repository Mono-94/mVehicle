# DataBase 

- ESX Original owned_vehicles 
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