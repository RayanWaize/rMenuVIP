CREATE TABLE `allvip` (
  `identifier` varchar(50) NOT NULL,
  `level` int(3) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `allvip`
  ADD PRIMARY KEY (`identifier`);
COMMIT;