-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               5.7.33 - MySQL Community Server (GPL)
-- Server OS:                    Win64
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for tibia
CREATE DATABASE IF NOT EXISTS `tibia` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `tibia`;

CREATE TABLE `raids` (
  `name` varchar(255) NOT NULL,
  `date` bigint NOT NULL DEFAULT '0',
  `count` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

ALTER TABLE `raids`
  ADD UNIQUE KEY `nameindex` (`name`);
COMMIT;

-- Dumping structure for table tibia.accounts
CREATE TABLE IF NOT EXISTS `accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `password` char(40) NOT NULL,
  `type` int(11) NOT NULL DEFAULT '1',
  `premium_ends_at` int(10) unsigned NOT NULL DEFAULT '0',
  `email` varchar(255) NOT NULL DEFAULT '',
  `creation` int(11) NOT NULL DEFAULT '0',
  `failed_bid_count` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1234568 DEFAULT CHARSET=utf8;

-- Dumping structure for table tibia.player_murders
CREATE TABLE `player_murders` (
  `id` int NOT NULL,
  `player_id` int NOT NULL,
  `date` bigint NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

ALTER TABLE `player_murders`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `player_murders`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

-- Dumping data for table tibia.accounts: ~1 rows (approximately)
DELETE FROM `accounts`;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` (`id`, `password`, `type`, `premium_ends_at`, `email`, `creation`, `failed_bid_count`) VALUES
	(1234567, '41da8bef22aaef9d7c5821fa0f0de7cccc4dda4d', 6, 0, '', 0, 0);
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;

-- Dumping structure for table tibia.account_bans
CREATE TABLE IF NOT EXISTS `account_bans` (
  `account_id` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `banned_at` bigint(20) NOT NULL,
  `expires_at` bigint(20) NOT NULL,
  `banned_by` int(11) NOT NULL,
  PRIMARY KEY (`account_id`),
  KEY `banned_by` (`banned_by`),
  CONSTRAINT `account_bans_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `account_bans_ibfk_2` FOREIGN KEY (`banned_by`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.account_bans: ~0 rows (approximately)
DELETE FROM `account_bans`;
/*!40000 ALTER TABLE `account_bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_bans` ENABLE KEYS */;

-- Dumping structure for table tibia.account_ban_history
CREATE TABLE IF NOT EXISTS `account_ban_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `banned_at` bigint(20) NOT NULL,
  `expired_at` bigint(20) NOT NULL,
  `banned_by` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `banned_by` (`banned_by`),
  CONSTRAINT `account_ban_history_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `account_ban_history_ibfk_2` FOREIGN KEY (`banned_by`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.account_ban_history: ~0 rows (approximately)
DELETE FROM `account_ban_history`;
/*!40000 ALTER TABLE `account_ban_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_ban_history` ENABLE KEYS */;

-- Dumping structure for table tibia.account_storage
CREATE TABLE IF NOT EXISTS `account_storage` (
  `account_id` int(11) NOT NULL,
  `key` int(10) unsigned NOT NULL,
  `value` int(11) NOT NULL,
  PRIMARY KEY (`account_id`,`key`),
  CONSTRAINT `account_storage_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.account_storage: ~0 rows (approximately)
DELETE FROM `account_storage`;
/*!40000 ALTER TABLE `account_storage` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_storage` ENABLE KEYS */;

-- Dumping structure for table tibia.account_viplist
CREATE TABLE IF NOT EXISTS `account_viplist` (
  `account_id` int(11) NOT NULL COMMENT 'id of account whose viplist entry it is',
  `player_id` int(11) NOT NULL COMMENT 'id of target player of viplist entry',
  `description` varchar(128) NOT NULL DEFAULT '',
  `icon` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `notify` tinyint(4) NOT NULL DEFAULT '0',
  UNIQUE KEY `account_player_index` (`account_id`,`player_id`),
  KEY `player_id` (`player_id`),
  CONSTRAINT `account_viplist_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `account_viplist_ibfk_2` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.account_viplist: ~0 rows (approximately)
DELETE FROM `account_viplist`;
/*!40000 ALTER TABLE `account_viplist` DISABLE KEYS */;
INSERT INTO `account_viplist` (`account_id`, `player_id`, `description`, `icon`, `notify`) VALUES
	(1234567, 2, '', 0, 0),
	(1234567, 3, '', 0, 0);
/*!40000 ALTER TABLE `account_viplist` ENABLE KEYS */;

-- Dumping structure for table tibia.guilds
CREATE TABLE IF NOT EXISTS `guilds` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `ownerid` int(11) NOT NULL,
  `creationdata` int(11) NOT NULL,
  `motd` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `ownerid` (`ownerid`),
  CONSTRAINT `guilds_ibfk_1` FOREIGN KEY (`ownerid`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.guilds: ~0 rows (approximately)
DELETE FROM `guilds`;
/*!40000 ALTER TABLE `guilds` DISABLE KEYS */;
/*!40000 ALTER TABLE `guilds` ENABLE KEYS */;

-- Dumping structure for table tibia.guildwar_kills
CREATE TABLE IF NOT EXISTS `guildwar_kills` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `killer` varchar(50) NOT NULL,
  `target` varchar(50) NOT NULL,
  `killerguild` int(11) NOT NULL DEFAULT '0',
  `targetguild` int(11) NOT NULL DEFAULT '0',
  `warid` int(11) NOT NULL DEFAULT '0',
  `time` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `warid` (`warid`),
  CONSTRAINT `guildwar_kills_ibfk_1` FOREIGN KEY (`warid`) REFERENCES `guild_wars` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.guildwar_kills: ~0 rows (approximately)
DELETE FROM `guildwar_kills`;
/*!40000 ALTER TABLE `guildwar_kills` DISABLE KEYS */;
/*!40000 ALTER TABLE `guildwar_kills` ENABLE KEYS */;

-- Dumping structure for table tibia.guild_invites
CREATE TABLE IF NOT EXISTS `guild_invites` (
  `player_id` int(11) NOT NULL DEFAULT '0',
  `guild_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`player_id`,`guild_id`),
  KEY `guild_id` (`guild_id`),
  CONSTRAINT `guild_invites_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE,
  CONSTRAINT `guild_invites_ibfk_2` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.guild_invites: ~0 rows (approximately)
DELETE FROM `guild_invites`;
/*!40000 ALTER TABLE `guild_invites` DISABLE KEYS */;
/*!40000 ALTER TABLE `guild_invites` ENABLE KEYS */;

-- Dumping structure for table tibia.guild_membership
CREATE TABLE IF NOT EXISTS `guild_membership` (
  `player_id` int(11) NOT NULL,
  `guild_id` int(11) NOT NULL,
  `rank_id` int(11) NOT NULL,
  `nick` varchar(15) NOT NULL DEFAULT '',
  PRIMARY KEY (`player_id`),
  KEY `guild_id` (`guild_id`),
  KEY `rank_id` (`rank_id`),
  CONSTRAINT `guild_membership_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `guild_membership_ibfk_2` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `guild_membership_ibfk_3` FOREIGN KEY (`rank_id`) REFERENCES `guild_ranks` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.guild_membership: ~0 rows (approximately)
DELETE FROM `guild_membership`;
/*!40000 ALTER TABLE `guild_membership` DISABLE KEYS */;
/*!40000 ALTER TABLE `guild_membership` ENABLE KEYS */;

-- Dumping structure for table tibia.guild_ranks
CREATE TABLE IF NOT EXISTS `guild_ranks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `guild_id` int(11) NOT NULL COMMENT 'guild',
  `name` varchar(255) NOT NULL COMMENT 'rank name',
  `level` int(11) NOT NULL COMMENT 'rank level - leader, vice, member, maybe something else',
  PRIMARY KEY (`id`),
  KEY `guild_id` (`guild_id`),
  CONSTRAINT `guild_ranks_ibfk_1` FOREIGN KEY (`guild_id`) REFERENCES `guilds` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.guild_ranks: ~0 rows (approximately)
DELETE FROM `guild_ranks`;
/*!40000 ALTER TABLE `guild_ranks` DISABLE KEYS */;
/*!40000 ALTER TABLE `guild_ranks` ENABLE KEYS */;

-- Dumping structure for table tibia.guild_wars
CREATE TABLE IF NOT EXISTS `guild_wars` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `guild1` int(11) NOT NULL DEFAULT '0',
  `guild2` int(11) NOT NULL DEFAULT '0',
  `name1` varchar(255) NOT NULL,
  `name2` varchar(255) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '0',
  `started` bigint(20) NOT NULL DEFAULT '0',
  `ended` bigint(20) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `guild1` (`guild1`),
  KEY `guild2` (`guild2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.guild_wars: ~0 rows (approximately)
DELETE FROM `guild_wars`;
/*!40000 ALTER TABLE `guild_wars` DISABLE KEYS */;
/*!40000 ALTER TABLE `guild_wars` ENABLE KEYS */;

-- Dumping structure for table tibia.houses
CREATE TABLE IF NOT EXISTS `houses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` int(11) NOT NULL,
  `paid` int(10) unsigned NOT NULL DEFAULT '0',
  `warnings` int(11) NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL,
  `rent` int(11) NOT NULL DEFAULT '0',
  `town_id` int(11) NOT NULL DEFAULT '0',
  `bid` int(11) NOT NULL DEFAULT '0',
  `bid_end` int(11) NOT NULL DEFAULT '0',
  `last_bid` int(11) NOT NULL DEFAULT '0',
  `highest_bidder` int(11) NOT NULL DEFAULT '0',
  `size` int(11) NOT NULL DEFAULT '0',
  `beds` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `owner` (`owner`),
  KEY `town_id` (`town_id`)
) ENGINE=InnoDB AUTO_INCREMENT=862 DEFAULT CHARSET=utf8;

CREATE TABLE `kill_statistics` (
  `name` varchar(35) NOT NULL,
  `killed_by` smallint unsigned NOT NULL,
  `killed` smallint unsigned NOT NULL,
  `time` int(10) unsigned NOT NULL DEFAULT '0',
  KEY `name` (`name`),
  KEY `time` (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.houses: ~861 rows (approximately)
DELETE FROM `houses`;
/*!40000 ALTER TABLE `houses` DISABLE KEYS */;
INSERT INTO `houses` (`id`, `owner`, `paid`, `warnings`, `name`, `rent`, `town_id`, `bid`, `bid_end`, `last_bid`, `highest_bidder`, `size`, `beds`) VALUES
	(1, 0, 0, 0, 'Spiritkeep', 19210, 1, 0, 0, 0, 0, 761, 23),
	(2, 0, 0, 0, 'Snake Tower', 29720, 1, 0, 0, 0, 0, 1063, 21),
	(3, 0, 0, 0, 'Halls of the Adventurers', 15380, 1, 0, 0, 0, 0, 512, 18),
	(4, 0, 0, 0, 'Dark Mansion', 17845, 1, 0, 0, 0, 0, 597, 17),
	(5, 0, 0, 0, 'Bloodhall', 15270, 1, 0, 0, 0, 0, 566, 16),
	(6, 0, 0, 0, 'Sunset Homes, Flat 01', 520, 1, 0, 0, 0, 0, 25, 1),
	(7, 0, 0, 0, 'Sunset Homes, Flat 02', 520, 1, 0, 0, 0, 0, 30, 1),
	(8, 0, 0, 0, 'Sunset Homes, Flat 03', 520, 1, 0, 0, 0, 0, 30, 1),
	(9, 0, 0, 0, 'Sunset Homes, Flat 11', 520, 1, 0, 0, 0, 0, 25, 1),
	(10, 0, 0, 0, 'Sunset Homes, Flat 12', 520, 1, 0, 0, 0, 0, 26, 1),
	(11, 0, 0, 0, 'Sunset Homes, Flat 13', 860, 1, 0, 0, 0, 0, 35, 2),
	(12, 0, 0, 0, 'Sunset Homes, Flat 14', 520, 1, 0, 0, 0, 0, 30, 1),
	(13, 0, 0, 0, 'Sunset Homes, Flat 21', 520, 1, 0, 0, 0, 0, 25, 1),
	(14, 0, 0, 0, 'Sunset Homes, Flat 22', 520, 1, 0, 0, 0, 0, 26, 1),
	(15, 0, 0, 0, 'Sunset Homes, Flat 23', 860, 1, 0, 0, 0, 0, 35, 2),
	(16, 0, 0, 0, 'Sunset Homes, Flat 24', 520, 1, 0, 0, 0, 0, 30, 1),
	(17, 0, 0, 0, 'Beach Home Apartments, Flat 01', 715, 1, 0, 0, 0, 0, 25, 1),
	(18, 0, 0, 0, 'Beach Home Apartments, Flat 02', 715, 1, 0, 0, 0, 0, 30, 1),
	(19, 0, 0, 0, 'Beach Home Apartments, Flat 03', 715, 1, 0, 0, 0, 0, 24, 1),
	(20, 0, 0, 0, 'Beach Home Apartments, Flat 04', 715, 1, 0, 0, 0, 0, 24, 1),
	(21, 0, 0, 0, 'Beach Home Apartments, Flat 05', 715, 1, 0, 0, 0, 0, 30, 1),
	(22, 0, 0, 0, 'Beach Home Apartments, Flat 06', 1145, 1, 0, 0, 0, 0, 40, 2),
	(23, 0, 0, 0, 'Beach Home Apartments, Flat 11', 715, 1, 0, 0, 0, 0, 25, 1),
	(24, 0, 0, 0, 'Beach Home Apartments, Flat 12', 880, 1, 0, 0, 0, 0, 30, 1),
	(25, 0, 0, 0, 'Beach Home Apartments, Flat 13', 880, 1, 0, 0, 0, 0, 30, 1),
	(26, 0, 0, 0, 'Beach Home Apartments, Flat 14', 385, 1, 0, 0, 0, 0, 15, 1),
	(27, 0, 0, 0, 'Beach Home Apartments, Flat 15', 385, 1, 0, 0, 0, 0, 20, 1),
	(28, 0, 0, 0, 'Beach Home Apartments, Flat 16', 1145, 1, 0, 0, 0, 0, 40, 2),
	(29, 0, 0, 0, 'Alai Flats, Flat 01', 765, 1, 0, 0, 0, 0, 25, 1),
	(30, 0, 0, 0, 'Alai Flats, Flat 02', 765, 1, 0, 0, 0, 0, 35, 1),
	(31, 0, 0, 0, 'Alai Flats, Flat 03', 765, 1, 0, 0, 0, 0, 36, 1),
	(32, 0, 0, 0, 'Alai Flats, Flat 04', 765, 1, 0, 0, 0, 0, 30, 1),
	(33, 0, 0, 0, 'Alai Flats, Flat 05', 1225, 1, 0, 0, 0, 0, 42, 2),
	(34, 0, 0, 0, 'Alai Flats, Flat 06', 1225, 1, 0, 0, 0, 0, 42, 2),
	(35, 0, 0, 0, 'Alai Flats, Flat 07', 765, 1, 0, 0, 0, 0, 30, 1),
	(36, 0, 0, 0, 'Alai Flats, Flat 08', 765, 1, 0, 0, 0, 0, 36, 1),
	(37, 0, 0, 0, 'Alai Flats, Flat 11', 765, 1, 0, 0, 0, 0, 30, 1),
	(38, 0, 0, 0, 'Alai Flats, Flat 12', 765, 1, 0, 0, 0, 0, 30, 1),
	(39, 0, 0, 0, 'Alai Flats, Flat 13', 765, 1, 0, 0, 0, 0, 36, 1),
	(40, 0, 0, 0, 'Alai Flats, Flat 14', 900, 1, 0, 0, 0, 0, 38, 1),
	(41, 0, 0, 0, 'Alai Flats, Flat 15', 1450, 1, 0, 0, 0, 0, 54, 2),
	(42, 0, 0, 0, 'Alai Flats, Flat 16', 1450, 1, 0, 0, 0, 0, 54, 2),
	(43, 0, 0, 0, 'Alai Flats, Flat 17', 900, 1, 0, 0, 0, 0, 38, 1),
	(44, 0, 0, 0, 'Alai Flats, Flat 18', 900, 1, 0, 0, 0, 0, 44, 1),
	(45, 0, 0, 0, 'Alai Flats, Flat 22', 765, 1, 0, 0, 0, 0, 25, 1),
	(46, 0, 0, 0, 'Alai Flats, Flat 21', 765, 1, 0, 0, 0, 0, 35, 1),
	(47, 0, 0, 0, 'Alai Flats, Flat 23', 765, 1, 0, 0, 0, 0, 36, 1),
	(48, 0, 0, 0, 'Alai Flats, Flat 24', 900, 1, 0, 0, 0, 0, 38, 1),
	(49, 0, 0, 0, 'Alai Flats, Flat 25', 1450, 1, 0, 0, 0, 0, 54, 2),
	(50, 0, 0, 0, 'Alai Flats, Flat 26', 1450, 1, 0, 0, 0, 0, 54, 2),
	(51, 0, 0, 0, 'Alai Flats, Flat 27', 900, 1, 0, 0, 0, 0, 38, 1),
	(52, 0, 0, 0, 'Alai Flats, Flat 28', 900, 1, 0, 0, 0, 0, 44, 1),
	(53, 0, 0, 0, 'Upper Swamp Lane 2', 4740, 1, 0, 0, 0, 0, 156, 4),
	(54, 0, 0, 0, 'Upper Swamp Lane 4', 4740, 1, 0, 0, 0, 0, 156, 4),
	(55, 0, 0, 0, 'Lower Swamp Lane 1', 4740, 1, 0, 0, 0, 0, 156, 4),
	(56, 0, 0, 0, 'Lower Swamp Lane 3', 4740, 1, 0, 0, 0, 0, 156, 4),
	(57, 0, 0, 0, 'Upper Swamp Lane 8', 8120, 1, 0, 0, 0, 0, 247, 3),
	(58, 0, 0, 0, 'Southern Thais Guildhall', 22260, 1, 0, 0, 0, 0, 634, 16),
	(59, 0, 0, 0, 'Upper Swamp Lane 10', 2060, 1, 0, 0, 0, 0, 70, 3),
	(60, 0, 0, 0, 'Upper Swamp Lane 12', 3800, 1, 0, 0, 0, 0, 130, 3),
	(61, 0, 0, 0, 'Sorcerer\'s Avenue 1a', 1255, 1, 0, 0, 0, 0, 42, 2),
	(62, 0, 0, 0, 'Sorcerer\'s Avenue 1b', 1035, 1, 0, 0, 0, 0, 30, 2),
	(63, 0, 0, 0, 'Sorcerer\'s Avenue 1c', 1255, 1, 0, 0, 0, 0, 42, 2),
	(64, 0, 0, 0, 'Sorcerer\'s Avenue 5', 2695, 1, 0, 0, 0, 0, 95, 1),
	(65, 0, 0, 0, 'Sorcerer\'s Avenue Labs 2a', 715, 1, 0, 0, 0, 0, 24, 1),
	(66, 0, 0, 0, 'Sorcerer\'s Avenue Labs 2b', 715, 1, 0, 0, 0, 0, 30, 1),
	(67, 0, 0, 0, 'Sorcerer\'s Avenue Labs 2c', 715, 1, 0, 0, 0, 0, 24, 1),
	(68, 0, 0, 0, 'Sorcerer\'s Avenue Labs 2d', 715, 1, 0, 0, 0, 0, 24, 1),
	(69, 0, 0, 0, 'Sorcerer\'s Avenue Labs 2e', 715, 1, 0, 0, 0, 0, 24, 1),
	(70, 0, 0, 0, 'Sorcerer\'s Avenue Labs 2f', 715, 1, 0, 0, 0, 0, 30, 1),
	(71, 0, 0, 0, 'Thais Clanhall', 8420, 1, 0, 0, 0, 0, 380, 10),
	(72, 0, 0, 0, 'Harbour Street 4', 935, 1, 0, 0, 0, 0, 36, 1),
	(73, 0, 0, 0, 'Thais Hostel', 6980, 1, 0, 0, 0, 0, 171, 24),
	(74, 0, 0, 0, 'Farm Lane, Basement (Shop)', 945, 1, 0, 0, 0, 0, 42, 0),
	(75, 0, 0, 0, 'Farm Lane, 1st floor (Shop)', 945, 1, 0, 0, 0, 0, 36, 0),
	(76, 0, 0, 0, 'Farm Lane, 2nd Floor (Shop)', 945, 1, 0, 0, 0, 0, 36, 0),
	(77, 0, 0, 0, 'Warriors Guildhall', 14725, 1, 0, 0, 0, 0, 543, 11),
	(78, 0, 0, 0, 'Main Street 9, 1st floor (Shop)', 1440, 1, 0, 0, 0, 0, 63, 0),
	(79, 0, 0, 0, 'Main Street 9a, 2nd floor (Shop)', 765, 1, 0, 0, 0, 0, 30, 0),
	(80, 0, 0, 0, 'Main Street 9b, 2nd floor (Shop)', 1260, 1, 0, 0, 0, 0, 57, 0),
	(81, 0, 0, 0, 'Mill Avenue 1 (Shop)', 1300, 1, 0, 0, 0, 0, 54, 1),
	(82, 0, 0, 0, 'Mill Avenue 2 (Shop)', 2350, 1, 0, 0, 0, 0, 100, 2),
	(83, 0, 0, 0, 'Mill Avenue 3', 1400, 1, 0, 0, 0, 0, 49, 2),
	(84, 0, 0, 0, 'Mill Avenue 4', 1400, 1, 0, 0, 0, 0, 49, 2),
	(85, 0, 0, 0, 'Mill Avenue 5', 3250, 1, 0, 0, 0, 0, 127, 4),
	(86, 0, 0, 0, 'The City Wall 5a', 585, 1, 0, 0, 0, 0, 24, 1),
	(87, 0, 0, 0, 'The City Wall 5b', 585, 1, 0, 0, 0, 0, 24, 1),
	(88, 0, 0, 0, 'The City Wall 5c', 585, 1, 0, 0, 0, 0, 24, 1),
	(89, 0, 0, 0, 'The City Wall 5d', 585, 1, 0, 0, 0, 0, 24, 1),
	(90, 0, 0, 0, 'The City Wall 5e', 585, 1, 0, 0, 0, 0, 30, 1),
	(91, 0, 0, 0, 'The City Wall 5f', 585, 1, 0, 0, 0, 0, 30, 1),
	(92, 0, 0, 0, 'The City Wall 7a', 585, 1, 0, 0, 0, 0, 30, 1),
	(93, 0, 0, 0, 'The City Wall 7b', 585, 1, 0, 0, 0, 0, 30, 1),
	(94, 0, 0, 0, 'The City Wall 7c', 865, 1, 0, 0, 0, 0, 36, 2),
	(95, 0, 0, 0, 'The City Wall 7d', 865, 1, 0, 0, 0, 0, 36, 2),
	(96, 0, 0, 0, 'The City Wall 7e', 865, 1, 0, 0, 0, 0, 36, 2),
	(97, 0, 0, 0, 'The City Wall 7f', 865, 1, 0, 0, 0, 0, 36, 2),
	(98, 0, 0, 0, 'The City Wall 7g', 585, 1, 0, 0, 0, 0, 30, 1),
	(99, 0, 0, 0, 'The City Wall 7h', 585, 1, 0, 0, 0, 0, 30, 1),
	(100, 0, 0, 0, 'The City Wall 9', 955, 1, 0, 0, 0, 0, 50, 2),
	(101, 0, 0, 0, 'The City Wall 3a', 1045, 1, 0, 0, 0, 0, 35, 2),
	(102, 0, 0, 0, 'The City Wall 3b', 1045, 1, 0, 0, 0, 0, 35, 2),
	(103, 0, 0, 0, 'The City Wall 3c', 1045, 1, 0, 0, 0, 0, 42, 2),
	(104, 0, 0, 0, 'The City Wall 3d', 1045, 1, 0, 0, 0, 0, 35, 2),
	(105, 0, 0, 0, 'The City Wall 3e', 1045, 1, 0, 0, 0, 0, 35, 2),
	(106, 0, 0, 0, 'The City Wall 3f', 1045, 1, 0, 0, 0, 0, 42, 2),
	(107, 0, 0, 0, 'The City Wall 1a', 1270, 1, 0, 0, 0, 0, 49, 2),
	(108, 0, 0, 0, 'The City Wall 1b', 1270, 1, 0, 0, 0, 0, 49, 2),
	(109, 0, 0, 0, 'Harbour Place 2 (Shop)', 1300, 1, 0, 0, 0, 0, 54, 1),
	(110, 0, 0, 0, 'Harbour Place 1 (Shop)', 1100, 1, 0, 0, 0, 0, 48, 0),
	(111, 0, 0, 0, 'Mercenary Tower', 41955, 1, 0, 0, 0, 0, 1013, 26),
	(112, 0, 0, 0, 'Guildhall of the Red Rose', 27725, 1, 0, 0, 0, 0, 610, 15),
	(113, 0, 0, 0, 'Fibula Village 1', 845, 1, 0, 0, 0, 0, 30, 1),
	(114, 0, 0, 0, 'Fibula Village 2', 845, 1, 0, 0, 0, 0, 30, 1),
	(115, 0, 0, 0, 'Fibula Village 3', 3810, 1, 0, 0, 0, 0, 109, 4),
	(116, 0, 0, 0, 'Fibula Village 4', 1790, 1, 0, 0, 0, 0, 42, 2),
	(117, 0, 0, 0, 'Fibula Village 5', 1790, 1, 0, 0, 0, 0, 49, 2),
	(118, 0, 0, 0, 'Fibula Village, Tower Flat', 5105, 1, 0, 0, 0, 0, 166, 2),
	(119, 0, 0, 0, 'Fibula Village, Bar', 5235, 1, 0, 0, 0, 0, 137, 2),
	(120, 0, 0, 0, 'Fibula Clanhall', 11430, 1, 0, 0, 0, 0, 305, 10),
	(121, 0, 0, 0, 'Fibula Village, Villa', 11490, 1, 0, 0, 0, 0, 452, 7),
	(122, 0, 0, 0, 'The Tibianic', 34500, 1, 0, 0, 0, 0, 833, 22),
	(123, 0, 0, 0, 'Castle of Greenshore', 18740, 1, 0, 0, 0, 0, 579, 12),
	(124, 0, 0, 0, 'Greenshore Village, Villa', 10440, 1, 0, 0, 0, 0, 290, 4),
	(125, 0, 0, 0, 'Greenshore Village, Shop', 1800, 1, 0, 0, 0, 0, 64, 1),
	(126, 0, 0, 0, 'Greenshore Village 1', 2420, 1, 0, 0, 0, 0, 64, 3),
	(127, 0, 0, 0, 'Greenshore Village 2', 780, 1, 0, 0, 0, 0, 25, 1),
	(128, 0, 0, 0, 'Greenshore Village 3', 780, 1, 0, 0, 0, 0, 30, 1),
	(129, 0, 0, 0, 'Greenshore Village 4', 780, 1, 0, 0, 0, 0, 25, 1),
	(130, 0, 0, 0, 'Greenshore Village 5', 780, 1, 0, 0, 0, 0, 30, 1),
	(131, 0, 0, 0, 'Greenshore Village 6', 4360, 1, 0, 0, 0, 0, 126, 2),
	(132, 0, 0, 0, 'Greenshore Village 7', 1260, 1, 0, 0, 0, 0, 42, 1),
	(133, 0, 0, 0, 'Greenshore Clanhall', 10800, 1, 0, 0, 0, 0, 312, 10),
	(134, 0, 0, 0, 'Moonkeep', 13020, 2, 0, 0, 0, 0, 506, 16),
	(135, 0, 0, 0, 'House of Recreation', 22980, 2, 0, 0, 0, 0, 708, 16),
	(136, 0, 0, 0, 'Nordic Stronghold', 18300, 2, 0, 0, 0, 0, 751, 21),
	(137, 0, 0, 0, 'Druids Retreat A', 1340, 2, 0, 0, 0, 0, 60, 2),
	(138, 0, 0, 0, 'Druids Retreat B', 1260, 2, 0, 0, 0, 0, 56, 2),
	(139, 0, 0, 0, 'Druids Retreat C', 980, 2, 0, 0, 0, 0, 45, 2),
	(140, 0, 0, 0, 'Druids Retreat D', 1180, 2, 0, 0, 0, 0, 54, 2),
	(141, 0, 0, 0, 'Central Plaza 3', 600, 2, 0, 0, 0, 0, 30, 0),
	(142, 0, 0, 0, 'Central Plaza 2', 600, 2, 0, 0, 0, 0, 30, 0),
	(143, 0, 0, 0, 'Central Plaza 1', 600, 2, 0, 0, 0, 0, 30, 0),
	(144, 0, 0, 0, 'Park Lane 1a', 1220, 2, 0, 0, 0, 0, 48, 2),
	(145, 0, 0, 0, 'Park Lane 1b', 1380, 2, 0, 0, 0, 0, 64, 2),
	(146, 0, 0, 0, 'Park Lane 3b', 1100, 2, 0, 0, 0, 0, 48, 2),
	(147, 0, 0, 0, 'Park Lane 3a', 1220, 2, 0, 0, 0, 0, 53, 2),
	(148, 0, 0, 0, 'Park Lane 4', 980, 2, 0, 0, 0, 0, 42, 2),
	(149, 0, 0, 0, 'Park Lane 2', 980, 2, 0, 0, 0, 0, 42, 2),
	(150, 0, 0, 0, 'Theater Avenue 6a', 820, 2, 0, 0, 0, 0, 31, 2),
	(151, 0, 0, 0, 'Theater Avenue 6b', 820, 2, 0, 0, 0, 0, 31, 2),
	(152, 0, 0, 0, 'Theater Avenue 6c', 225, 2, 0, 0, 0, 0, 12, 1),
	(153, 0, 0, 0, 'Theater Avenue 6d', 225, 2, 0, 0, 0, 0, 12, 1),
	(154, 0, 0, 0, 'Theater Avenue 6e', 820, 2, 0, 0, 0, 0, 35, 2),
	(155, 0, 0, 0, 'Theater Avenue 6f', 820, 2, 0, 0, 0, 0, 35, 2),
	(156, 0, 0, 0, 'Theater Avenue 5a', 450, 2, 0, 0, 0, 0, 20, 1),
	(157, 0, 0, 0, 'Theater Avenue 5b', 450, 2, 0, 0, 0, 0, 25, 1),
	(158, 0, 0, 0, 'Theater Avenue 5c', 450, 2, 0, 0, 0, 0, 20, 1),
	(159, 0, 0, 0, 'Theater Avenue 5d', 450, 2, 0, 0, 0, 0, 25, 1),
	(160, 0, 0, 0, 'Theater Avenue 8a', 1270, 2, 0, 0, 0, 0, 49, 2),
	(161, 0, 0, 0, 'Theater Avenue 8b', 1370, 2, 0, 0, 0, 0, 49, 3),
	(162, 0, 0, 0, 'Theater Avenue 7, Flat 01', 315, 2, 0, 0, 0, 0, 16, 1),
	(163, 0, 0, 0, 'Theater Avenue 7, Flat 02', 405, 2, 0, 0, 0, 0, 20, 1),
	(164, 0, 0, 0, 'Theater Avenue 7, Flat 03', 405, 2, 0, 0, 0, 0, 20, 1),
	(165, 0, 0, 0, 'Theater Avenue 7, Flat 04', 495, 2, 0, 0, 0, 0, 24, 1),
	(166, 0, 0, 0, 'Theater Avenue 7, Flat 05', 405, 2, 0, 0, 0, 0, 20, 1),
	(167, 0, 0, 0, 'Theater Avenue 7, Flat 06', 315, 2, 0, 0, 0, 0, 20, 1),
	(168, 0, 0, 0, 'Theater Avenue 7, Flat 11', 495, 2, 0, 0, 0, 0, 20, 1),
	(169, 0, 0, 0, 'Theater Avenue 7, Flat 12', 405, 2, 0, 0, 0, 0, 20, 1),
	(170, 0, 0, 0, 'Theater Avenue 7, Flat 13', 405, 2, 0, 0, 0, 0, 20, 1),
	(171, 0, 0, 0, 'Theater Avenue 7, Flat 14', 495, 2, 0, 0, 0, 0, 24, 1),
	(172, 0, 0, 0, 'Theater Avenue 7, Flat 15', 405, 2, 0, 0, 0, 0, 20, 1),
	(173, 0, 0, 0, 'Theater Avenue 7, Flat 16', 405, 2, 0, 0, 0, 0, 24, 1),
	(174, 0, 0, 0, 'Theater Avenue 10', 1090, 2, 0, 0, 0, 0, 36, 2),
	(175, 0, 0, 0, 'Theater Avenue 12', 955, 2, 0, 0, 0, 0, 32, 2),
	(176, 0, 0, 0, 'Theater Avenue 14 (Shop)', 2115, 2, 0, 0, 0, 0, 83, 1),
	(177, 0, 0, 0, 'Theater Avenue 11a', 1405, 2, 0, 0, 0, 0, 48, 2),
	(178, 0, 0, 0, 'Theater Avenue 11b', 585, 2, 0, 0, 0, 0, 24, 1),
	(179, 0, 0, 0, 'Theater Avenue 11c', 585, 2, 0, 0, 0, 0, 30, 1),
	(180, 0, 0, 0, 'Magician\'s Alley 1', 1050, 2, 0, 0, 0, 0, 40, 2),
	(181, 0, 0, 0, 'Magician\'s Alley 1a', 700, 2, 0, 0, 0, 0, 23, 2),
	(182, 0, 0, 0, 'Magician\'s Alley 1b', 750, 2, 0, 0, 0, 0, 30, 2),
	(183, 0, 0, 0, 'Magician\'s Alley 1c', 500, 2, 0, 0, 0, 0, 20, 1),
	(184, 0, 0, 0, 'Magician\'s Alley 1d', 450, 2, 0, 0, 0, 0, 24, 1),
	(185, 0, 0, 0, 'Magician\'s Alley 5a', 350, 2, 0, 0, 0, 0, 15, 1),
	(186, 0, 0, 0, 'Magician\'s Alley 5b', 500, 2, 0, 0, 0, 0, 25, 1),
	(187, 0, 0, 0, 'Magician\'s Alley 5c', 1150, 2, 0, 0, 0, 0, 35, 2),
	(188, 0, 0, 0, 'Magician\'s Alley 5d', 500, 2, 0, 0, 0, 0, 20, 1),
	(189, 0, 0, 0, 'Magician\'s Alley 5e', 500, 2, 0, 0, 0, 0, 25, 1),
	(190, 0, 0, 0, 'Magician\'s Alley 5f', 1150, 2, 0, 0, 0, 0, 42, 2),
	(191, 0, 0, 0, 'Magician\'s Alley 4', 2750, 2, 0, 0, 0, 0, 96, 4),
	(192, 0, 0, 0, 'Magician\'s Alley 8', 1400, 2, 0, 0, 0, 0, 49, 2),
	(193, 0, 0, 0, 'Carlin Clanhall', 11800, 2, 0, 0, 0, 0, 401, 10),
	(194, 0, 0, 0, 'Northern Street 1a', 940, 2, 0, 0, 0, 0, 42, 2),
	(195, 0, 0, 0, 'Northern Street 1b', 940, 2, 0, 0, 0, 0, 37, 2),
	(196, 0, 0, 0, 'Northern Street 1c', 740, 2, 0, 0, 0, 0, 35, 2),
	(197, 0, 0, 0, 'Northern Street 3a', 740, 2, 0, 0, 0, 0, 34, 2),
	(198, 0, 0, 0, 'Northern Street 3b', 780, 2, 0, 0, 0, 0, 36, 2),
	(199, 0, 0, 0, 'Northern Street 5', 1980, 2, 0, 0, 0, 0, 94, 2),
	(200, 0, 0, 0, 'Northern Street 7', 1700, 2, 0, 0, 0, 0, 83, 2),
	(201, 0, 0, 0, 'Harbour Lane 1 (Shop)', 1040, 2, 0, 0, 0, 0, 54, 0),
	(202, 0, 0, 0, 'Harbour Lane 3', 3560, 2, 0, 0, 0, 0, 145, 3),
	(203, 0, 0, 0, 'Harbour Lane 2a (Shop)', 680, 2, 0, 0, 0, 0, 32, 0),
	(204, 0, 0, 0, 'Harbour Lane 2b (Shop)', 680, 2, 0, 0, 0, 0, 40, 0),
	(205, 0, 0, 0, 'Harbour Flats, Flat 11', 520, 2, 0, 0, 0, 0, 24, 1),
	(206, 0, 0, 0, 'Harbour Flats, Flat 12', 400, 2, 0, 0, 0, 0, 20, 1),
	(207, 0, 0, 0, 'Harbour Flats, Flat 13', 520, 2, 0, 0, 0, 0, 24, 1),
	(208, 0, 0, 0, 'Harbour Flats, Flat 14', 400, 2, 0, 0, 0, 0, 20, 1),
	(209, 0, 0, 0, 'Harbour Flats, Flat 15', 360, 2, 0, 0, 0, 0, 18, 1),
	(210, 0, 0, 0, 'Harbour Flats, Flat 16', 400, 2, 0, 0, 0, 0, 20, 1),
	(211, 0, 0, 0, 'Harbour Flats, Flat 17', 360, 2, 0, 0, 0, 0, 24, 1),
	(212, 0, 0, 0, 'Harbour Flats, Flat 18', 400, 2, 0, 0, 0, 0, 25, 1),
	(213, 0, 0, 0, 'Harbour Flats, Flat 21', 860, 2, 0, 0, 0, 0, 35, 2),
	(214, 0, 0, 0, 'Harbour Flats, Flat 22', 980, 2, 0, 0, 0, 0, 45, 2),
	(215, 0, 0, 0, 'Harbour Flats, Flat 23', 400, 2, 0, 0, 0, 0, 25, 1),
	(216, 0, 0, 0, 'East Lane 1a', 2260, 2, 0, 0, 0, 0, 96, 2),
	(217, 0, 0, 0, 'East Lane 1b', 1700, 2, 0, 0, 0, 0, 83, 2),
	(218, 0, 0, 0, 'East Lane 2', 4580, 2, 0, 0, 0, 0, 193, 2),
	(219, 0, 0, 0, 'Suntower', 10080, 2, 0, 0, 0, 0, 451, 9),
	(220, 0, 0, 0, 'Lonely Sea Side Hostel', 12180, 2, 0, 0, 0, 0, 489, 8),
	(221, 0, 0, 0, 'Northport Village 1', 1475, 2, 0, 0, 0, 0, 40, 2),
	(222, 0, 0, 0, 'Northport Village 2', 1475, 2, 0, 0, 0, 0, 48, 2),
	(223, 0, 0, 0, 'Northport Village 3', 5435, 2, 0, 0, 0, 0, 169, 2),
	(224, 0, 0, 0, 'Northport Village 4', 2630, 2, 0, 0, 0, 0, 91, 2),
	(225, 0, 0, 0, 'Seawatch', 25010, 2, 0, 0, 0, 0, 726, 19),
	(226, 0, 0, 0, 'Northport Village 5', 1805, 2, 0, 0, 0, 0, 56, 2),
	(227, 0, 0, 0, 'Northport Village 6', 2135, 2, 0, 0, 0, 0, 64, 2),
	(228, 0, 0, 0, 'Northport Clanhall', 9810, 2, 0, 0, 0, 0, 306, 10),
	(229, 0, 0, 0, 'Senja Village 1a', 765, 2, 0, 0, 0, 0, 30, 1),
	(230, 0, 0, 0, 'Senja Village 1b', 1630, 2, 0, 0, 0, 0, 60, 2),
	(231, 0, 0, 0, 'Senja Village 2', 765, 2, 0, 0, 0, 0, 30, 1),
	(232, 0, 0, 0, 'Senja Village 3', 1765, 2, 0, 0, 0, 0, 72, 2),
	(233, 0, 0, 0, 'Senja Village 4', 765, 2, 0, 0, 0, 0, 36, 1),
	(234, 0, 0, 0, 'Senja Village 5', 1225, 2, 0, 0, 0, 0, 48, 2),
	(235, 0, 0, 0, 'Senja Village 6a', 765, 2, 0, 0, 0, 0, 36, 1),
	(236, 0, 0, 0, 'Senja Village 6b', 765, 2, 0, 0, 0, 0, 36, 1),
	(237, 0, 0, 0, 'Senja Village 7', 865, 2, 0, 0, 0, 0, 36, 2),
	(238, 0, 0, 0, 'Senja Village 8', 1675, 2, 0, 0, 0, 0, 72, 2),
	(239, 0, 0, 0, 'Senja Village 9', 2575, 2, 0, 0, 0, 0, 108, 2),
	(240, 0, 0, 0, 'Senja Village 10', 1485, 2, 0, 0, 0, 0, 72, 1),
	(241, 0, 0, 0, 'Senja Village 11', 2620, 2, 0, 0, 0, 0, 96, 2),
	(242, 0, 0, 0, 'Senja Clanhall', 10575, 2, 0, 0, 0, 0, 395, 10),
	(243, 0, 0, 0, 'Wolftower', 21550, 3, 0, 0, 0, 0, 710, 23),
	(244, 0, 0, 0, 'Hill Hideout', 13950, 3, 0, 0, 0, 0, 399, 15),
	(245, 0, 0, 0, 'Riverspring', 19450, 3, 0, 0, 0, 0, 632, 19),
	(246, 0, 0, 0, 'The Farms 1', 2510, 3, 0, 0, 0, 0, 78, 3),
	(247, 0, 0, 0, 'The Farms 2', 1530, 3, 0, 0, 0, 0, 49, 2),
	(248, 0, 0, 0, 'The Farms 3', 1530, 3, 0, 0, 0, 0, 49, 2),
	(249, 0, 0, 0, 'The Farms 4', 1530, 3, 0, 0, 0, 0, 49, 2),
	(250, 0, 0, 0, 'The Farms 5', 1530, 3, 0, 0, 0, 0, 49, 2),
	(251, 0, 0, 0, 'The Farms 6, Fishing Hut', 1255, 3, 0, 0, 0, 0, 42, 2),
	(252, 0, 0, 0, 'Nobility Quarter 1', 1865, 3, 0, 0, 0, 0, 61, 3),
	(253, 0, 0, 0, 'Nobility Quarter 2', 1865, 3, 0, 0, 0, 0, 56, 3),
	(254, 0, 0, 0, 'Nobility Quarter 3', 1865, 3, 0, 0, 0, 0, 64, 3),
	(255, 0, 0, 0, 'Nobility Quarter 4', 765, 3, 0, 0, 0, 0, 30, 1),
	(256, 0, 0, 0, 'Nobility Quarter 5', 765, 3, 0, 0, 0, 0, 36, 1),
	(257, 0, 0, 0, 'Nobility Quarter 6', 765, 3, 0, 0, 0, 0, 30, 1),
	(258, 0, 0, 0, 'Nobility Quarter 7', 765, 3, 0, 0, 0, 0, 36, 1),
	(259, 0, 0, 0, 'Nobility Quarter 8', 765, 3, 0, 0, 0, 0, 30, 1),
	(260, 0, 0, 0, 'Nobility Quarter 9', 765, 3, 0, 0, 0, 0, 36, 1),
	(261, 0, 0, 0, 'Upper Barracks 1', 210, 3, 0, 0, 0, 0, 15, 1),
	(262, 0, 0, 0, 'Upper Barracks 2', 210, 3, 0, 0, 0, 0, 15, 1),
	(263, 0, 0, 0, 'Upper Barracks 3', 210, 3, 0, 0, 0, 0, 15, 1),
	(264, 0, 0, 0, 'Upper Barracks 4', 210, 3, 0, 0, 0, 0, 20, 1),
	(265, 0, 0, 0, 'Upper Barracks 5', 210, 3, 0, 0, 0, 0, 12, 1),
	(266, 0, 0, 0, 'Upper Barracks 6', 210, 3, 0, 0, 0, 0, 12, 1),
	(267, 0, 0, 0, 'Upper Barracks 7', 210, 3, 0, 0, 0, 0, 16, 1),
	(268, 0, 0, 0, 'Upper Barracks 8', 210, 3, 0, 0, 0, 0, 15, 1),
	(269, 0, 0, 0, 'Upper Barracks 9', 210, 3, 0, 0, 0, 0, 15, 1),
	(270, 0, 0, 0, 'Upper Barracks 10', 210, 3, 0, 0, 0, 0, 15, 1),
	(271, 0, 0, 0, 'Upper Barracks 11', 210, 3, 0, 0, 0, 0, 20, 1),
	(272, 0, 0, 0, 'Upper Barracks 12', 210, 3, 0, 0, 0, 0, 20, 1),
	(273, 0, 0, 0, 'Upper Barracks 13', 580, 3, 0, 0, 0, 0, 35, 2),
	(274, 0, 0, 0, 'The Market 1 (Shop)', 650, 3, 0, 0, 0, 0, 25, 0),
	(275, 0, 0, 0, 'The Market 2 (Shop)', 1100, 3, 0, 0, 0, 0, 45, 0),
	(276, 0, 0, 0, 'The Market 3 (Shop)', 1450, 3, 0, 0, 0, 0, 54, 0),
	(277, 0, 0, 0, 'The Market 4 (Shop)', 1800, 3, 0, 0, 0, 0, 63, 0),
	(278, 0, 0, 0, 'Lower Barracks 1', 300, 3, 0, 0, 0, 0, 25, 1),
	(279, 0, 0, 0, 'Lower Barracks 2', 300, 3, 0, 0, 0, 0, 25, 1),
	(280, 0, 0, 0, 'Lower Barracks 3', 300, 3, 0, 0, 0, 0, 25, 1),
	(281, 0, 0, 0, 'Lower Barracks 4', 300, 3, 0, 0, 0, 0, 25, 1),
	(282, 0, 0, 0, 'Lower Barracks 5', 300, 3, 0, 0, 0, 0, 25, 1),
	(283, 0, 0, 0, 'Lower Barracks 6', 300, 3, 0, 0, 0, 0, 25, 1),
	(284, 0, 0, 0, 'Lower Barracks 7', 300, 3, 0, 0, 0, 0, 25, 1),
	(285, 0, 0, 0, 'Lower Barracks 8', 300, 3, 0, 0, 0, 0, 25, 1),
	(286, 0, 0, 0, 'Lower Barracks 9', 300, 3, 0, 0, 0, 0, 25, 1),
	(287, 0, 0, 0, 'Lower Barracks 10', 300, 3, 0, 0, 0, 0, 25, 1),
	(288, 0, 0, 0, 'Lower Barracks 11', 300, 3, 0, 0, 0, 0, 25, 1),
	(289, 0, 0, 0, 'Lower Barracks 12', 300, 3, 0, 0, 0, 0, 25, 1),
	(290, 0, 0, 0, 'Lower Barracks 13', 300, 3, 0, 0, 0, 0, 25, 1),
	(291, 0, 0, 0, 'Lower Barracks 14', 300, 3, 0, 0, 0, 0, 25, 1),
	(292, 0, 0, 0, 'Lower Barracks 15', 300, 3, 0, 0, 0, 0, 25, 1),
	(293, 0, 0, 0, 'Lower Barracks 16', 300, 3, 0, 0, 0, 0, 25, 1),
	(294, 0, 0, 0, 'Lower Barracks 17', 300, 3, 0, 0, 0, 0, 25, 1),
	(295, 0, 0, 0, 'Lower Barracks 18', 300, 3, 0, 0, 0, 0, 25, 1),
	(296, 0, 0, 0, 'Lower Barracks 19', 300, 3, 0, 0, 0, 0, 25, 1),
	(297, 0, 0, 0, 'Lower Barracks 20', 300, 3, 0, 0, 0, 0, 25, 1),
	(298, 0, 0, 0, 'Lower Barracks 21', 300, 3, 0, 0, 0, 0, 25, 1),
	(299, 0, 0, 0, 'Lower Barracks 22', 300, 3, 0, 0, 0, 0, 25, 1),
	(300, 0, 0, 0, 'Lower Barracks 23', 300, 3, 0, 0, 0, 0, 25, 1),
	(301, 0, 0, 0, 'Lower Barracks 24', 300, 3, 0, 0, 0, 0, 25, 1),
	(302, 0, 0, 0, 'Tunnel Gardens 1', 1820, 3, 0, 0, 0, 0, 47, 3),
	(303, 0, 0, 0, 'Tunnel Gardens 2 ', 1820, 3, 0, 0, 0, 0, 47, 3),
	(304, 0, 0, 0, 'Tunnel Gardens 3', 2000, 3, 0, 0, 0, 0, 65, 3),
	(305, 0, 0, 0, 'Tunnel Gardens 4', 2000, 3, 0, 0, 0, 0, 65, 3),
	(306, 0, 0, 0, 'Tunnel Gardens 5', 1360, 3, 0, 0, 0, 0, 35, 2),
	(307, 0, 0, 0, 'Tunnel Gardens 6', 1360, 3, 0, 0, 0, 0, 42, 2),
	(308, 0, 0, 0, 'Tunnel Gardens 7', 1360, 3, 0, 0, 0, 0, 35, 2),
	(309, 0, 0, 0, 'Tunnel Gardens 8', 1360, 3, 0, 0, 0, 0, 42, 2),
	(310, 0, 0, 0, 'Tunnel Gardens 9', 1000, 3, 0, 0, 0, 0, 34, 2),
	(311, 0, 0, 0, 'Tunnel Gardens 10', 1000, 3, 0, 0, 0, 0, 34, 2),
	(312, 0, 0, 0, 'Tunnel Gardens 11', 1060, 3, 0, 0, 0, 0, 35, 2),
	(313, 0, 0, 0, 'Tunnel Gardens 12', 1060, 3, 0, 0, 0, 0, 35, 2),
	(314, 0, 0, 0, 'Marble Guildhall', 16810, 3, 0, 0, 0, 0, 592, 17),
	(315, 0, 0, 0, 'Iron Guildhall', 15560, 3, 0, 0, 0, 0, 522, 18),
	(316, 0, 0, 0, 'Granite Guildhall', 17845, 3, 0, 0, 0, 0, 617, 17),
	(317, 0, 0, 0, 'Outlaw Camp 1', 1660, 3, 0, 0, 0, 0, 91, 2),
	(318, 0, 0, 0, 'Outlaw Camp 2', 280, 3, 0, 0, 0, 0, 20, 1),
	(319, 0, 0, 0, 'Outlaw Camp 3', 740, 3, 0, 0, 0, 0, 35, 2),
	(320, 0, 0, 0, 'Outlaw Camp 4', 200, 3, 0, 0, 0, 0, 12, 1),
	(321, 0, 0, 0, 'Outlaw Camp 5', 200, 3, 0, 0, 0, 0, 12, 1),
	(322, 0, 0, 0, 'Outlaw Camp 6', 200, 3, 0, 0, 0, 0, 16, 1),
	(323, 0, 0, 0, 'Outlaw Camp 7', 780, 3, 0, 0, 0, 0, 38, 2),
	(324, 0, 0, 0, 'Outlaw Camp 8', 280, 3, 0, 0, 0, 0, 20, 1),
	(325, 0, 0, 0, 'Outlaw Camp 9', 200, 3, 0, 0, 0, 0, 12, 1),
	(326, 0, 0, 0, 'Outlaw Camp 10', 200, 3, 0, 0, 0, 0, 12, 1),
	(327, 0, 0, 0, 'Outlaw Camp 11', 200, 3, 0, 0, 0, 0, 16, 1),
	(328, 0, 0, 0, 'Outlaw Camp 12 (Shop)', 280, 3, 0, 0, 0, 0, 20, 0),
	(329, 0, 0, 0, 'Outlaw Camp 13 (Shop)', 280, 3, 0, 0, 0, 0, 20, 0),
	(330, 0, 0, 0, 'Outlaw Camp 14 (Shop)', 640, 3, 0, 0, 0, 0, 35, 0),
	(331, 0, 0, 0, 'Outlaw Castle', 8000, 3, 0, 0, 0, 0, 401, 9),
	(332, 0, 0, 0, 'Blessed Shield Guildhall', 8090, 7, 0, 0, 0, 0, 297, 9),
	(333, 0, 0, 0, 'Steel Home', 13845, 7, 0, 0, 0, 0, 462, 13),
	(334, 0, 0, 0, 'Swamp Watch', 11090, 7, 0, 0, 0, 0, 420, 12),
	(335, 0, 0, 0, 'Golden Axe Guildhall', 10485, 7, 0, 0, 0, 0, 390, 10),
	(336, 0, 0, 0, 'Valorous Venore', 14435, 7, 0, 0, 0, 0, 507, 9),
	(337, 0, 0, 0, 'Dagger Alley 1', 2665, 7, 0, 0, 0, 0, 126, 2),
	(338, 0, 0, 0, 'Iron Alley 1', 3450, 7, 0, 0, 0, 0, 120, 4),
	(339, 0, 0, 0, 'Iron Alley 2', 3450, 7, 0, 0, 0, 0, 144, 4),
	(340, 0, 0, 0, 'Dream Street 1 (Shop)', 4330, 7, 0, 0, 0, 0, 192, 2),
	(341, 0, 0, 0, 'Dream Street 2', 3340, 7, 0, 0, 0, 0, 149, 2),
	(342, 0, 0, 0, 'Dream Street 3', 2710, 7, 0, 0, 0, 0, 126, 2),
	(343, 0, 0, 0, 'Dream Street 4', 3765, 7, 0, 0, 0, 0, 166, 4),
	(344, 0, 0, 0, 'Elm Street 1', 2710, 7, 0, 0, 0, 0, 114, 2),
	(345, 0, 0, 0, 'Elm Street 2', 2665, 7, 0, 0, 0, 0, 119, 2),
	(346, 0, 0, 0, 'Elm Street 3', 2855, 7, 0, 0, 0, 0, 120, 3),
	(347, 0, 0, 0, 'Elm Street 4', 2620, 7, 0, 0, 0, 0, 124, 2),
	(348, 0, 0, 0, 'Seagull Walk 1', 5095, 7, 0, 0, 0, 0, 220, 2),
	(349, 0, 0, 0, 'Seagull Walk 2', 2765, 7, 0, 0, 0, 0, 132, 3),
	(350, 0, 0, 0, 'Lucky Lane 1 (Shop)', 6960, 7, 0, 0, 0, 0, 270, 4),
	(351, 0, 0, 0, 'Paupers Palace, Flat 01', 405, 7, 0, 0, 0, 0, 24, 1),
	(352, 0, 0, 0, 'Paupers Palace, Flat 02', 450, 7, 0, 0, 0, 0, 20, 1),
	(353, 0, 0, 0, 'Paupers Palace, Flat 03', 405, 7, 0, 0, 0, 0, 18, 1),
	(354, 0, 0, 0, 'Paupers Palace, Flat 04', 450, 7, 0, 0, 0, 0, 20, 1),
	(355, 0, 0, 0, 'Paupers Palace, Flat 05', 315, 7, 0, 0, 0, 0, 15, 1),
	(356, 0, 0, 0, 'Paupers Palace, Flat 06', 450, 7, 0, 0, 0, 0, 25, 1),
	(357, 0, 0, 0, 'Paupers Palace, Flat 07', 685, 7, 0, 0, 0, 0, 30, 2),
	(358, 0, 0, 0, 'Paupers Palace, Flat 11', 315, 7, 0, 0, 0, 0, 15, 1),
	(359, 0, 0, 0, 'Paupers Palace, Flat 12', 685, 7, 0, 0, 0, 0, 25, 2),
	(360, 0, 0, 0, 'Paupers Palace, Flat 13', 450, 7, 0, 0, 0, 0, 20, 1),
	(361, 0, 0, 0, 'Paupers Palace, Flat 14', 585, 7, 0, 0, 0, 0, 25, 1),
	(362, 0, 0, 0, 'Paupers Palace, Flat 15', 450, 7, 0, 0, 0, 0, 20, 1),
	(363, 0, 0, 0, 'Paupers Palace, Flat 16', 585, 7, 0, 0, 0, 0, 30, 1),
	(364, 0, 0, 0, 'Paupers Palace, Flat 17', 450, 7, 0, 0, 0, 0, 20, 1),
	(365, 0, 0, 0, 'Paupers Palace, Flat 18', 315, 7, 0, 0, 0, 0, 20, 1),
	(366, 0, 0, 0, 'Paupers Palace, Flat 21', 315, 7, 0, 0, 0, 0, 15, 1),
	(367, 0, 0, 0, 'Paupers Palace, Flat 22', 450, 7, 0, 0, 0, 0, 20, 1),
	(368, 0, 0, 0, 'Paupers Palace, Flat 23', 585, 7, 0, 0, 0, 0, 25, 1),
	(369, 0, 0, 0, 'Paupers Palace, Flat 24', 450, 7, 0, 0, 0, 0, 20, 1),
	(370, 0, 0, 0, 'Paupers Palace, Flat 25', 585, 7, 0, 0, 0, 0, 25, 1),
	(371, 0, 0, 0, 'Paupers Palace, Flat 26', 450, 7, 0, 0, 0, 0, 20, 1),
	(372, 0, 0, 0, 'Paupers Palace, Flat 27', 685, 7, 0, 0, 0, 0, 30, 2),
	(373, 0, 0, 0, 'Paupers Palace, Flat 28', 315, 7, 0, 0, 0, 0, 20, 1),
	(374, 0, 0, 0, 'Paupers Palace, Flat 31', 855, 7, 0, 0, 0, 0, 35, 1),
	(375, 0, 0, 0, 'Paupers Palace, Flat 32', 1135, 7, 0, 0, 0, 0, 45, 2),
	(376, 0, 0, 0, 'Paupers Palace, Flat 33', 765, 7, 0, 0, 0, 0, 35, 1),
	(377, 0, 0, 0, 'Paupers Palace, Flat 34', 1675, 7, 0, 0, 0, 0, 70, 2),
	(378, 0, 0, 0, 'Salvation Street 1 (Shop)', 6240, 7, 0, 0, 0, 0, 249, 4),
	(379, 0, 0, 0, 'Salvation Street 2', 3790, 7, 0, 0, 0, 0, 135, 2),
	(380, 0, 0, 0, 'Salvation Street 3', 3790, 7, 0, 0, 0, 0, 162, 2),
	(381, 0, 0, 0, 'Mystic Lane 1', 2945, 7, 0, 0, 0, 0, 110, 3),
	(382, 0, 0, 0, 'Mystic Lane 2', 2980, 7, 0, 0, 0, 0, 139, 2),
	(383, 0, 0, 0, 'Silver Street 1', 2565, 7, 0, 0, 0, 0, 129, 1),
	(384, 0, 0, 0, 'Silver Street 2', 1980, 7, 0, 0, 0, 0, 84, 1),
	(385, 0, 0, 0, 'Silver Street 3', 1980, 7, 0, 0, 0, 0, 105, 1),
	(386, 0, 0, 0, 'Silver Street 4', 3295, 7, 0, 0, 0, 0, 153, 2),
	(387, 0, 0, 0, 'Loot Lane 1 (Shop)', 4565, 7, 0, 0, 0, 0, 198, 3),
	(388, 0, 0, 0, 'Old Lighthouse', 3610, 7, 0, 0, 0, 0, 177, 2),
	(389, 0, 0, 0, 'Market Street 1', 6680, 7, 0, 0, 0, 0, 258, 3),
	(390, 0, 0, 0, 'Market Street 2', 4925, 7, 0, 0, 0, 0, 204, 3),
	(391, 0, 0, 0, 'Market Street 3', 3475, 7, 0, 0, 0, 0, 154, 2),
	(392, 0, 0, 0, 'Market Street 4 (Shop)', 5105, 7, 0, 0, 0, 0, 209, 3),
	(393, 0, 0, 0, 'Market Street 5 (Shop)', 6375, 7, 0, 0, 0, 0, 243, 4),
	(394, 0, 0, 0, 'Market Street 6', 5485, 7, 0, 0, 0, 0, 216, 5),
	(395, 0, 0, 0, 'Market Street 7', 2305, 7, 0, 0, 0, 0, 114, 2),
	(396, 0, 0, 0, 'Shadow Towers', 21800, 4, 0, 0, 0, 0, 726, 18),
	(397, 0, 0, 0, 'The Hideout', 20800, 4, 0, 0, 0, 0, 628, 20),
	(398, 0, 0, 0, 'Underwood 1', 1495, 4, 0, 0, 0, 0, 56, 2),
	(399, 0, 0, 0, 'Underwood 2', 1495, 4, 0, 0, 0, 0, 56, 2),
	(400, 0, 0, 0, 'Underwood 3', 1685, 4, 0, 0, 0, 0, 60, 3),
	(401, 0, 0, 0, 'Underwood 4', 2235, 4, 0, 0, 0, 0, 72, 4),
	(402, 0, 0, 0, 'Underwood 5', 1370, 4, 0, 0, 0, 0, 49, 3),
	(403, 0, 0, 0, 'Underwood 6', 1595, 4, 0, 0, 0, 0, 56, 3),
	(404, 0, 0, 0, 'Underwood 7', 1460, 4, 0, 0, 0, 0, 53, 3),
	(405, 0, 0, 0, 'Underwood 8', 865, 4, 0, 0, 0, 0, 36, 2),
	(406, 0, 0, 0, 'Underwood 9', 585, 4, 0, 0, 0, 0, 30, 1),
	(407, 0, 0, 0, 'Underwood 10', 585, 4, 0, 0, 0, 0, 30, 1),
	(408, 0, 0, 0, 'Ab\'Dendriel Clanhall', 14850, 4, 0, 0, 0, 0, 521, 10),
	(409, 0, 0, 0, 'Castle of the Winds', 23885, 4, 0, 0, 0, 0, 863, 18),
	(410, 0, 0, 0, 'Great Willow 1a', 500, 4, 0, 0, 0, 0, 25, 1),
	(411, 0, 0, 0, 'Great Willow 1b', 650, 4, 0, 0, 0, 0, 25, 1),
	(412, 0, 0, 0, 'Great Willow 1c', 650, 4, 0, 0, 0, 0, 30, 1),
	(413, 0, 0, 0, 'Great Willow 2a', 650, 4, 0, 0, 0, 0, 30, 1),
	(414, 0, 0, 0, 'Great Willow 2b', 450, 4, 0, 0, 0, 0, 18, 1),
	(415, 0, 0, 0, 'Great Willow 2c', 650, 4, 0, 0, 0, 0, 24, 1),
	(416, 0, 0, 0, 'Great Willow 2d', 450, 4, 0, 0, 0, 0, 24, 1),
	(417, 0, 0, 0, 'Great Willow 3a', 650, 4, 0, 0, 0, 0, 30, 1),
	(418, 0, 0, 0, 'Great Willow 3b', 450, 4, 0, 0, 0, 0, 18, 1),
	(419, 0, 0, 0, 'Great Willow 3c', 650, 4, 0, 0, 0, 0, 24, 1),
	(420, 0, 0, 0, 'Great Willow 3d', 450, 4, 0, 0, 0, 0, 24, 1),
	(421, 0, 0, 0, 'Great Willow 4a', 950, 4, 0, 0, 0, 0, 34, 2),
	(422, 0, 0, 0, 'Great Willow 4b', 950, 4, 0, 0, 0, 0, 30, 2),
	(423, 0, 0, 0, 'Great Willow 4c', 950, 4, 0, 0, 0, 0, 32, 2),
	(424, 0, 0, 0, 'Great Willow 4d', 750, 4, 0, 0, 0, 0, 36, 1),
	(425, 0, 0, 0, 'Mangrove 1', 1750, 4, 0, 0, 0, 0, 56, 3),
	(426, 0, 0, 0, 'Mangrove 2', 1350, 4, 0, 0, 0, 0, 48, 2),
	(427, 0, 0, 0, 'Mangrove 3', 1150, 4, 0, 0, 0, 0, 42, 2),
	(428, 0, 0, 0, 'Mangrove 4', 950, 4, 0, 0, 0, 0, 36, 2),
	(429, 0, 0, 0, 'Treetop 1', 650, 4, 0, 0, 0, 0, 24, 1),
	(430, 0, 0, 0, 'Treetop 2', 650, 4, 0, 0, 0, 0, 30, 1),
	(431, 0, 0, 0, 'Treetop 3 (Shop)', 1250, 4, 0, 0, 0, 0, 48, 1),
	(432, 0, 0, 0, 'Treetop 4 (Shop)', 1250, 4, 0, 0, 0, 0, 60, 1),
	(433, 0, 0, 0, 'Treetop 5 (Shop)', 1350, 4, 0, 0, 0, 0, 54, 1),
	(434, 0, 0, 0, 'Treetop 6', 450, 4, 0, 0, 0, 0, 18, 1),
	(435, 0, 0, 0, 'Treetop 7', 800, 4, 0, 0, 0, 0, 35, 1),
	(436, 0, 0, 0, 'Treetop 8', 800, 4, 0, 0, 0, 0, 28, 1),
	(437, 0, 0, 0, 'Treetop 9', 1150, 4, 0, 0, 0, 0, 42, 2),
	(438, 0, 0, 0, 'Treetop 10', 1150, 4, 0, 0, 0, 0, 42, 2),
	(439, 0, 0, 0, 'Treetop 11', 900, 4, 0, 0, 0, 0, 35, 2),
	(440, 0, 0, 0, 'Treetop 12 (Shop)', 1350, 4, 0, 0, 0, 0, 55, 1),
	(441, 0, 0, 0, 'Treetop 13', 1400, 4, 0, 0, 0, 0, 49, 2),
	(442, 0, 0, 0, 'Coastwood 1', 980, 4, 0, 0, 0, 0, 28, 2),
	(443, 0, 0, 0, 'Coastwood 2', 980, 4, 0, 0, 0, 0, 35, 2),
	(444, 0, 0, 0, 'Coastwood 3', 1310, 4, 0, 0, 0, 0, 37, 2),
	(445, 0, 0, 0, 'Coastwood 4', 1145, 4, 0, 0, 0, 0, 42, 2),
	(446, 0, 0, 0, 'Coastwood 5', 1530, 4, 0, 0, 0, 0, 49, 2),
	(447, 0, 0, 0, 'Coastwood 6 (Shop)', 1595, 4, 0, 0, 0, 0, 52, 1),
	(448, 0, 0, 0, 'Coastwood 7', 660, 4, 0, 0, 0, 0, 29, 1),
	(449, 0, 0, 0, 'Coastwood 8', 1255, 4, 0, 0, 0, 0, 42, 2),
	(450, 0, 0, 0, 'Coastwood 9', 935, 4, 0, 0, 0, 0, 36, 1),
	(451, 0, 0, 0, 'Coastwood 10', 1630, 4, 0, 0, 0, 0, 49, 3),
	(452, 0, 0, 0, 'Shadow Caves 1', 300, 4, 0, 0, 0, 0, 20, 1),
	(453, 0, 0, 0, 'Shadow Caves 2', 300, 4, 0, 0, 0, 0, 20, 1),
	(454, 0, 0, 0, 'Shadow Caves 3', 300, 4, 0, 0, 0, 0, 25, 1),
	(455, 0, 0, 0, 'Shadow Caves 4', 300, 4, 0, 0, 0, 0, 25, 1),
	(456, 0, 0, 0, 'Shadow Caves 11', 300, 4, 0, 0, 0, 0, 20, 1),
	(457, 0, 0, 0, 'Shadow Caves 12', 300, 4, 0, 0, 0, 0, 20, 1),
	(458, 0, 0, 0, 'Shadow Caves 13', 300, 4, 0, 0, 0, 0, 20, 1),
	(459, 0, 0, 0, 'Shadow Caves 14', 300, 4, 0, 0, 0, 0, 20, 1),
	(460, 0, 0, 0, 'Shadow Caves 15', 300, 4, 0, 0, 0, 0, 20, 1),
	(461, 0, 0, 0, 'Shadow Caves 16', 300, 4, 0, 0, 0, 0, 20, 1),
	(462, 0, 0, 0, 'Shadow Caves 17', 300, 4, 0, 0, 0, 0, 25, 1),
	(463, 0, 0, 0, 'Shadow Caves 18', 300, 4, 0, 0, 0, 0, 25, 1),
	(464, 0, 0, 0, 'Shadow Caves 21', 300, 4, 0, 0, 0, 0, 20, 1),
	(465, 0, 0, 0, 'Shadow Caves 22', 300, 4, 0, 0, 0, 0, 20, 1),
	(466, 0, 0, 0, 'Shadow Caves 23', 300, 4, 0, 0, 0, 0, 20, 1),
	(467, 0, 0, 0, 'Shadow Caves 24', 300, 4, 0, 0, 0, 0, 20, 1),
	(468, 0, 0, 0, 'Shadow Caves 25', 300, 4, 0, 0, 0, 0, 20, 1),
	(469, 0, 0, 0, 'Shadow Caves 26', 300, 4, 0, 0, 0, 0, 20, 1),
	(470, 0, 0, 0, 'Shadow Caves 27', 300, 4, 0, 0, 0, 0, 25, 1),
	(471, 0, 0, 0, 'Shadow Caves 28', 300, 4, 0, 0, 0, 0, 25, 1),
	(472, 0, 0, 0, 'Haggler\'s Hangout 1', 1400, 9, 0, 0, 0, 0, 49, 2),
	(473, 0, 0, 0, 'Haggler\'s Hangout 2', 1300, 9, 0, 0, 0, 0, 49, 1),
	(474, 0, 0, 0, 'Haggler\'s Hangout 3', 7550, 9, 0, 0, 0, 0, 256, 4),
	(475, 0, 0, 0, 'Haggler\'s Hangout 4a', 1850, 9, 0, 0, 0, 0, 56, 1),
	(476, 0, 0, 0, 'Haggler\'s Hangout 4b', 1550, 9, 0, 0, 0, 0, 56, 1),
	(477, 0, 0, 0, 'Haggler\'s Hangout 5', 1550, 9, 0, 0, 0, 0, 56, 1),
	(478, 0, 0, 0, 'Haggler\'s Hangout 6', 6450, 9, 0, 0, 0, 0, 208, 4),
	(479, 0, 0, 0, 'Banana Bay 1', 450, 9, 0, 0, 0, 0, 25, 1),
	(480, 0, 0, 0, 'Banana Bay 2', 765, 9, 0, 0, 0, 0, 36, 1),
	(481, 0, 0, 0, 'Banana Bay 3', 450, 9, 0, 0, 0, 0, 25, 1),
	(482, 0, 0, 0, 'Banana Bay 4', 450, 9, 0, 0, 0, 0, 25, 1),
	(483, 0, 0, 0, 'Crocodile Bridge 1', 1045, 9, 0, 0, 0, 0, 42, 2),
	(484, 0, 0, 0, 'Crocodile Bridge 2', 865, 9, 0, 0, 0, 0, 36, 2),
	(485, 0, 0, 0, 'Crocodile Bridge 3', 1270, 9, 0, 0, 0, 0, 49, 2),
	(486, 0, 0, 0, 'Crocodile Bridge 4', 4755, 9, 0, 0, 0, 0, 176, 4),
	(487, 0, 0, 0, 'Crocodile Bridge 5', 3970, 9, 0, 0, 0, 0, 154, 2),
	(488, 0, 0, 0, 'Woodway 1', 765, 9, 0, 0, 0, 0, 36, 1),
	(489, 0, 0, 0, 'Woodway 2', 585, 9, 0, 0, 0, 0, 30, 1),
	(490, 0, 0, 0, 'Woodway 3', 1540, 9, 0, 0, 0, 0, 65, 2),
	(491, 0, 0, 0, 'Woodway 4', 405, 9, 0, 0, 0, 0, 24, 1),
	(492, 0, 0, 0, 'Flamingo Flats 1', 685, 9, 0, 0, 0, 0, 30, 2),
	(493, 0, 0, 0, 'Flamingo Flats 2', 1045, 9, 0, 0, 0, 0, 42, 2),
	(494, 0, 0, 0, 'Flamingo Flats 3', 685, 9, 0, 0, 0, 0, 30, 2),
	(495, 0, 0, 0, 'Flamingo Flats 4', 865, 9, 0, 0, 0, 0, 36, 2),
	(496, 0, 0, 0, 'Flamingo Flats 5', 1845, 9, 0, 0, 0, 0, 84, 1),
	(497, 0, 0, 0, 'Bamboo Garden 1', 1640, 9, 0, 0, 0, 0, 63, 3),
	(498, 0, 0, 0, 'Bamboo Garden 2', 1045, 9, 0, 0, 0, 0, 42, 2),
	(499, 0, 0, 0, 'Bamboo Garden 3', 1540, 9, 0, 0, 0, 0, 63, 2),
	(500, 0, 0, 0, 'Coconut Quay 1', 1765, 9, 0, 0, 0, 0, 64, 2),
	(501, 0, 0, 0, 'Coconut Quay 2', 1045, 9, 0, 0, 0, 0, 42, 2),
	(502, 0, 0, 0, 'Coconut Quay 3', 2145, 9, 0, 0, 0, 0, 70, 4),
	(503, 0, 0, 0, 'Coconut Quay 4', 2135, 9, 0, 0, 0, 0, 72, 3),
	(504, 0, 0, 0, 'River Homes 1', 3485, 9, 0, 0, 0, 0, 128, 3),
	(505, 0, 0, 0, 'River Homes 2a', 1270, 9, 0, 0, 0, 0, 42, 2),
	(506, 0, 0, 0, 'River Homes 2b', 1595, 9, 0, 0, 0, 0, 56, 3),
	(507, 0, 0, 0, 'River Homes 3', 5055, 9, 0, 0, 0, 0, 176, 7),
	(508, 0, 0, 0, 'Jungle Edge 1', 2495, 9, 0, 0, 0, 0, 98, 3),
	(509, 0, 0, 0, 'Jungle Edge 2', 3170, 9, 0, 0, 0, 0, 128, 3),
	(510, 0, 0, 0, 'Jungle Edge 3', 865, 9, 0, 0, 0, 0, 36, 2),
	(511, 0, 0, 0, 'Jungle Edge 4', 865, 9, 0, 0, 0, 0, 36, 2),
	(512, 0, 0, 0, 'Jungle Edge 5', 865, 9, 0, 0, 0, 0, 36, 2),
	(513, 0, 0, 0, 'Jungle Edge 6', 450, 9, 0, 0, 0, 0, 25, 1),
	(514, 0, 0, 0, 'Shark Manor', 8780, 9, 0, 0, 0, 0, 286, 15),
	(515, 0, 0, 0, 'Bamboo Fortress', 21970, 9, 0, 0, 0, 0, 852, 20),
	(516, 0, 0, 0, 'The Treehouse', 24120, 9, 0, 0, 0, 0, 917, 23),
	(517, 0, 0, 0, 'Castle Shop 1', 1890, 5, 0, 0, 0, 0, 70, 1),
	(518, 0, 0, 0, 'Castle Shop 2', 1890, 5, 0, 0, 0, 0, 70, 1),
	(519, 0, 0, 0, 'Castle Shop 3', 1890, 5, 0, 0, 0, 0, 78, 1),
	(520, 0, 0, 0, 'Castle, 3rd Floor, Flat 01', 585, 5, 0, 0, 0, 0, 24, 1),
	(521, 0, 0, 0, 'Castle, 3rd Floor, Flat 02', 765, 5, 0, 0, 0, 0, 30, 1),
	(522, 0, 0, 0, 'Castle, 3rd Floor, Flat 03', 585, 5, 0, 0, 0, 0, 25, 1),
	(523, 0, 0, 0, 'Castle, 3rd Floor, Flat 04', 585, 5, 0, 0, 0, 0, 25, 1),
	(524, 0, 0, 0, 'Castle, 3rd Floor, Flat 05', 765, 5, 0, 0, 0, 0, 30, 1),
	(525, 0, 0, 0, 'Castle, 3rd Floor, Flat 06', 1045, 5, 0, 0, 0, 0, 42, 2),
	(526, 0, 0, 0, 'Castle, 3rd Floor, Flat 07', 720, 5, 0, 0, 0, 0, 35, 1),
	(527, 0, 0, 0, 'Castle, 4th Floor, Flat 01', 585, 5, 0, 0, 0, 0, 24, 1),
	(528, 0, 0, 0, 'Castle, 4th Floor, Flat 02', 765, 5, 0, 0, 0, 0, 30, 1),
	(529, 0, 0, 0, 'Castle, 4th Floor, Flat 03', 585, 5, 0, 0, 0, 0, 25, 1),
	(530, 0, 0, 0, 'Castle, 4th Floor, Flat 04', 585, 5, 0, 0, 0, 0, 25, 1),
	(531, 0, 0, 0, 'Castle, 4th Floor, Flat 05', 765, 5, 0, 0, 0, 0, 30, 1),
	(532, 0, 0, 0, 'Castle, 4th Floor, Flat 06', 945, 5, 0, 0, 0, 0, 42, 1),
	(533, 0, 0, 0, 'Castle, 4th Floor, Flat 07', 720, 5, 0, 0, 0, 0, 35, 1),
	(534, 0, 0, 0, 'Castle, 4th Floor, Flat 08', 945, 5, 0, 0, 0, 0, 35, 1),
	(535, 0, 0, 0, 'Castle, 4th Floor, Flat 09', 720, 5, 0, 0, 0, 0, 35, 1),
	(536, 0, 0, 0, 'Castle, Basement, Flat 01', 585, 5, 0, 0, 0, 0, 30, 1),
	(537, 0, 0, 0, 'Castle, Basement, Flat 02', 585, 5, 0, 0, 0, 0, 24, 1),
	(538, 0, 0, 0, 'Castle, Basement, Flat 03', 585, 5, 0, 0, 0, 0, 24, 1),
	(539, 0, 0, 0, 'Castle, Basement, Flat 04', 585, 5, 0, 0, 0, 0, 24, 1),
	(540, 0, 0, 0, 'Castle, Basement, Flat 05', 585, 5, 0, 0, 0, 0, 24, 1),
	(541, 0, 0, 0, 'Castle, Basement, Flat 06', 585, 5, 0, 0, 0, 0, 24, 1),
	(542, 0, 0, 0, 'Castle, Basement, Flat 07', 585, 5, 0, 0, 0, 0, 24, 1),
	(543, 0, 0, 0, 'Castle, Basement, Flat 08', 585, 5, 0, 0, 0, 0, 30, 1),
	(544, 0, 0, 0, 'Castle, Basement, Flat 09', 585, 5, 0, 0, 0, 0, 30, 1),
	(545, 0, 0, 0, 'Castle Street 1', 2900, 5, 0, 0, 0, 0, 111, 3),
	(546, 0, 0, 0, 'Castle Street 2', 1495, 5, 0, 0, 0, 0, 56, 2),
	(547, 0, 0, 0, 'Castle Street 3', 1765, 5, 0, 0, 0, 0, 64, 2),
	(548, 0, 0, 0, 'Castle Street 4', 1765, 5, 0, 0, 0, 0, 61, 2),
	(549, 0, 0, 0, 'Castle Street 5', 1765, 5, 0, 0, 0, 0, 64, 2),
	(550, 0, 0, 0, 'Edron Flats, Flat 01', 400, 5, 0, 0, 0, 0, 25, 1),
	(551, 0, 0, 0, 'Edron Flats, Flat 02', 860, 5, 0, 0, 0, 0, 35, 2),
	(552, 0, 0, 0, 'Edron Flats, Flat 03', 400, 5, 0, 0, 0, 0, 20, 1),
	(553, 0, 0, 0, 'Edron Flats, Flat 04', 400, 5, 0, 0, 0, 0, 20, 1),
	(554, 0, 0, 0, 'Edron Flats, Flat 05', 400, 5, 0, 0, 0, 0, 20, 1),
	(555, 0, 0, 0, 'Edron Flats, Flat 06', 400, 5, 0, 0, 0, 0, 20, 1),
	(556, 0, 0, 0, 'Edron Flats, Flat 07', 400, 5, 0, 0, 0, 0, 25, 1),
	(557, 0, 0, 0, 'Edron Flats, Flat 08', 400, 5, 0, 0, 0, 0, 25, 1),
	(558, 0, 0, 0, 'Edron Flats, Flat 11', 400, 5, 0, 0, 0, 0, 25, 1),
	(559, 0, 0, 0, 'Edron Flats, Flat 12', 400, 5, 0, 0, 0, 0, 25, 1),
	(560, 0, 0, 0, 'Edron Flats, Flat 13', 400, 5, 0, 0, 0, 0, 20, 1),
	(561, 0, 0, 0, 'Edron Flats, Flat 14', 400, 5, 0, 0, 0, 0, 20, 1),
	(562, 0, 0, 0, 'Edron Flats, Flat 15', 400, 5, 0, 0, 0, 0, 20, 1),
	(563, 0, 0, 0, 'Edron Flats, Flat 16', 400, 5, 0, 0, 0, 0, 20, 1),
	(564, 0, 0, 0, 'Edron Flats, Flat 17', 400, 5, 0, 0, 0, 0, 25, 1),
	(565, 0, 0, 0, 'Edron Flats, Flat 18', 400, 5, 0, 0, 0, 0, 25, 1),
	(566, 0, 0, 0, 'Edron Flats, Flat 21', 860, 5, 0, 0, 0, 0, 35, 2),
	(567, 0, 0, 0, 'Edron Flats, Flat 22', 400, 5, 0, 0, 0, 0, 25, 1),
	(568, 0, 0, 0, 'Edron Flats, Flat 23', 400, 5, 0, 0, 0, 0, 20, 1),
	(569, 0, 0, 0, 'Edron Flats, Flat 24', 400, 5, 0, 0, 0, 0, 20, 1),
	(570, 0, 0, 0, 'Edron Flats, Flat 25', 400, 5, 0, 0, 0, 0, 20, 1),
	(571, 0, 0, 0, 'Edron Flats, Flat 26', 400, 5, 0, 0, 0, 0, 20, 1),
	(572, 0, 0, 0, 'Edron Flats, Flat 27', 400, 5, 0, 0, 0, 0, 25, 1),
	(573, 0, 0, 0, 'Edron Flats, Flat 28', 400, 5, 0, 0, 0, 0, 25, 1),
	(574, 0, 0, 0, 'Edron Flats, Basement Flat 1', 1540, 5, 0, 0, 0, 0, 54, 2),
	(575, 0, 0, 0, 'Edron Flats, Basement Flat 2', 1540, 5, 0, 0, 0, 0, 63, 2),
	(576, 0, 0, 0, 'Central Circle 1', 3020, 5, 0, 0, 0, 0, 119, 2),
	(577, 0, 0, 0, 'Central Circle 2', 3300, 5, 0, 0, 0, 0, 145, 2),
	(578, 0, 0, 0, 'Central Circle 3', 4160, 5, 0, 0, 0, 0, 147, 5),
	(579, 0, 0, 0, 'Central Circle 4', 4160, 5, 0, 0, 0, 0, 147, 5),
	(580, 0, 0, 0, 'Central Circle 5', 4160, 5, 0, 0, 0, 0, 167, 5),
	(581, 0, 0, 0, 'Central Circle 6 (Shop)', 3980, 5, 0, 0, 0, 0, 168, 2),
	(582, 0, 0, 0, 'Central Circle 7 (Shop)', 3980, 5, 0, 0, 0, 0, 168, 2),
	(583, 0, 0, 0, 'Central Circle 8 (Shop)', 3980, 5, 0, 0, 0, 0, 192, 2),
	(584, 0, 0, 0, 'Central Circle 9a', 940, 5, 0, 0, 0, 0, 42, 2),
	(585, 0, 0, 0, 'Central Circle 9b', 940, 5, 0, 0, 0, 0, 42, 2),
	(586, 0, 0, 0, 'Wood Avenue 1', 1765, 5, 0, 0, 0, 0, 64, 2),
	(587, 0, 0, 0, 'Wood Avenue 2', 1765, 5, 0, 0, 0, 0, 56, 2),
	(588, 0, 0, 0, 'Wood Avenue 3', 1765, 5, 0, 0, 0, 0, 56, 2),
	(589, 0, 0, 0, 'Wood Avenue 4', 1765, 5, 0, 0, 0, 0, 64, 2),
	(590, 0, 0, 0, 'Wood Avenue 5', 1765, 5, 0, 0, 0, 0, 64, 2),
	(591, 0, 0, 0, 'Wood Avenue 6a', 1450, 5, 0, 0, 0, 0, 56, 2),
	(592, 0, 0, 0, 'Wood Avenue 6b', 1450, 5, 0, 0, 0, 0, 56, 2),
	(593, 0, 0, 0, 'Wood Avenue 7', 5960, 5, 0, 0, 0, 0, 210, 3),
	(594, 0, 0, 0, 'Wood Avenue 8', 5960, 5, 0, 0, 0, 0, 222, 3),
	(595, 0, 0, 0, 'Wood Avenue 9a', 1540, 5, 0, 0, 0, 0, 56, 2),
	(596, 0, 0, 0, 'Wood Avenue 9b', 1495, 5, 0, 0, 0, 0, 56, 2),
	(597, 0, 0, 0, 'Wood Avenue 10a', 1540, 5, 0, 0, 0, 0, 64, 2),
	(598, 0, 0, 0, 'Wood Avenue 10b', 1595, 5, 0, 0, 0, 0, 64, 3),
	(599, 0, 0, 0, 'Wood Avenue 11', 7205, 5, 0, 0, 0, 0, 263, 6),
	(600, 0, 0, 0, 'Wood Avenue 4a', 1495, 5, 0, 0, 0, 0, 52, 2),
	(601, 0, 0, 0, 'Wood Avenue 4b', 1495, 5, 0, 0, 0, 0, 53, 2),
	(602, 0, 0, 0, 'Wood Avenue 4c', 1765, 5, 0, 0, 0, 0, 64, 2),
	(603, 0, 0, 0, 'Sky Lane, Guild 1', 21145, 5, 0, 0, 0, 0, 684, 23),
	(604, 0, 0, 0, 'Sky Lane, Guild 2', 19300, 5, 0, 0, 0, 0, 676, 14),
	(605, 0, 0, 0, 'Sky Lane, Guild 3', 17315, 5, 0, 0, 0, 0, 576, 18),
	(606, 0, 0, 0, 'Sky Lane, Sea Tower', 4775, 5, 0, 0, 0, 0, 196, 6),
	(607, 0, 0, 0, 'Magic Academy, Guild', 12025, 5, 0, 0, 0, 0, 407, 14),
	(608, 0, 0, 0, 'Magic Academy, Shop', 1595, 5, 0, 0, 0, 0, 57, 1),
	(609, 0, 0, 0, 'Magic Academy, Flat 1', 1465, 5, 0, 0, 0, 0, 54, 3),
	(610, 0, 0, 0, 'Magic Academy, Flat 2', 1530, 5, 0, 0, 0, 0, 55, 2),
	(611, 0, 0, 0, 'Magic Academy, Flat 3', 1430, 5, 0, 0, 0, 0, 55, 1),
	(612, 0, 0, 0, 'Magic Academy, Flat 4', 1530, 5, 0, 0, 0, 0, 55, 2),
	(613, 0, 0, 0, 'Magic Academy, Flat 5', 1430, 5, 0, 0, 0, 0, 55, 1),
	(614, 0, 0, 0, 'Stonehome Village 1', 1780, 5, 0, 0, 0, 0, 77, 2),
	(615, 0, 0, 0, 'Stonehome Village 2', 640, 5, 0, 0, 0, 0, 35, 1),
	(616, 0, 0, 0, 'Stonehome Village 3', 680, 5, 0, 0, 0, 0, 36, 1),
	(617, 0, 0, 0, 'Stonehome Village 4', 940, 5, 0, 0, 0, 0, 42, 2),
	(618, 0, 0, 0, 'Stonehome Village 5', 1140, 5, 0, 0, 0, 0, 49, 2),
	(619, 0, 0, 0, 'Stonehome Village 6', 1300, 5, 0, 0, 0, 0, 55, 2),
	(620, 0, 0, 0, 'Stonehome Village 7', 1140, 5, 0, 0, 0, 0, 49, 2),
	(621, 0, 0, 0, 'Stonehome Village 8', 680, 5, 0, 0, 0, 0, 36, 1),
	(622, 0, 0, 0, 'Stonehome Village 9', 680, 5, 0, 0, 0, 0, 36, 1),
	(623, 0, 0, 0, 'Stonehome Flats, Flat 01', 400, 5, 0, 0, 0, 0, 25, 1),
	(624, 0, 0, 0, 'Stonehome Flats, Flat 02', 740, 5, 0, 0, 0, 0, 30, 2),
	(625, 0, 0, 0, 'Stonehome Flats, Flat 03', 400, 5, 0, 0, 0, 0, 20, 1),
	(626, 0, 0, 0, 'Stonehome Flats, Flat 04', 400, 5, 0, 0, 0, 0, 20, 1),
	(627, 0, 0, 0, 'Stonehome Flats, Flat 05', 400, 5, 0, 0, 0, 0, 25, 1),
	(628, 0, 0, 0, 'Stonehome Flats, Flat 06', 400, 5, 0, 0, 0, 0, 25, 1),
	(629, 0, 0, 0, 'Stonehome Flats, Flat 11', 740, 5, 0, 0, 0, 0, 30, 2),
	(630, 0, 0, 0, 'Stonehome Flats, Flat 12', 740, 5, 0, 0, 0, 0, 30, 2),
	(631, 0, 0, 0, 'Stonehome Flats, Flat 13', 400, 5, 0, 0, 0, 0, 20, 1),
	(632, 0, 0, 0, 'Stonehome Flats, Flat 14', 400, 5, 0, 0, 0, 0, 20, 1),
	(633, 0, 0, 0, 'Stonehome Flats, Flat 15', 400, 5, 0, 0, 0, 0, 25, 1),
	(634, 0, 0, 0, 'Stonehome Flats, Flat 16', 400, 5, 0, 0, 0, 0, 25, 1),
	(635, 0, 0, 0, 'Stonehome Clanhall', 8580, 5, 0, 0, 0, 0, 364, 10),
	(636, 0, 0, 0, 'Cormaya Flats, Flat 01', 450, 5, 0, 0, 0, 0, 20, 1),
	(637, 0, 0, 0, 'Cormaya Flats, Flat 02', 450, 5, 0, 0, 0, 0, 20, 1),
	(638, 0, 0, 0, 'Cormaya Flats, Flat 03', 820, 5, 0, 0, 0, 0, 35, 2),
	(639, 0, 0, 0, 'Cormaya Flats, Flat 04', 820, 5, 0, 0, 0, 0, 30, 2),
	(640, 0, 0, 0, 'Cormaya Flats, Flat 05', 450, 5, 0, 0, 0, 0, 20, 1),
	(641, 0, 0, 0, 'Cormaya Flats, Flat 06', 450, 5, 0, 0, 0, 0, 25, 1),
	(642, 0, 0, 0, 'Cormaya Flats, Flat 11', 450, 5, 0, 0, 0, 0, 20, 1),
	(643, 0, 0, 0, 'Cormaya Flats, Flat 12', 450, 5, 0, 0, 0, 0, 20, 1),
	(644, 0, 0, 0, 'Cormaya Flats, Flat 13', 820, 5, 0, 0, 0, 0, 35, 2),
	(645, 0, 0, 0, 'Cormaya Flats, Flat 14', 820, 5, 0, 0, 0, 0, 30, 2),
	(646, 0, 0, 0, 'Cormaya Flats, Flat 15', 450, 5, 0, 0, 0, 0, 20, 1),
	(647, 0, 0, 0, 'Cormaya Flats, Flat 16', 450, 5, 0, 0, 0, 0, 25, 1),
	(648, 0, 0, 0, 'Cormaya 1', 1270, 5, 0, 0, 0, 0, 49, 2),
	(649, 0, 0, 0, 'Cormaya 2', 3710, 5, 0, 0, 0, 0, 144, 3),
	(650, 0, 0, 0, 'Cormaya 3', 2035, 5, 0, 0, 0, 0, 72, 2),
	(651, 0, 0, 0, 'Cormaya 4', 1720, 5, 0, 0, 0, 0, 63, 2),
	(652, 0, 0, 0, 'Cormaya 5', 5600, 5, 0, 0, 0, 0, 201, 3),
	(653, 0, 0, 0, 'Cormaya 6', 2395, 5, 0, 0, 0, 0, 84, 2),
	(654, 0, 0, 0, 'Cormaya 7', 2395, 5, 0, 0, 0, 0, 84, 2),
	(655, 0, 0, 0, 'Cormaya 8', 2710, 5, 0, 0, 0, 0, 113, 2),
	(656, 0, 0, 0, 'Cormaya 9a', 1225, 5, 0, 0, 0, 0, 40, 2),
	(657, 0, 0, 0, 'Cormaya 9b', 2620, 5, 0, 0, 0, 0, 96, 2),
	(658, 0, 0, 0, 'Cormaya 9c', 1225, 5, 0, 0, 0, 0, 40, 2),
	(659, 0, 0, 0, 'Cormaya 9d', 2620, 5, 0, 0, 0, 0, 96, 2),
	(660, 0, 0, 0, 'Cormaya 10', 3800, 5, 0, 0, 0, 0, 144, 3),
	(661, 0, 0, 0, 'Cormaya 11', 2035, 5, 0, 0, 0, 0, 72, 2),
	(662, 0, 0, 0, 'Castle of the White Dragon', 24975, 5, 0, 0, 0, 0, 890, 19),
	(663, 0, 0, 0, 'Chameken I', 850, 8, 0, 0, 0, 0, 36, 1),
	(664, 0, 0, 0, 'Chameken II', 850, 8, 0, 0, 0, 0, 36, 1),
	(665, 0, 0, 0, 'Thanah I a', 850, 8, 0, 0, 0, 0, 36, 1),
	(666, 0, 0, 0, 'Thanah I b', 3000, 8, 0, 0, 0, 0, 100, 3),
	(667, 0, 0, 0, 'Thanah I c', 3250, 8, 0, 0, 0, 0, 98, 3),
	(668, 0, 0, 0, 'Thanah I d', 2900, 8, 0, 0, 0, 0, 98, 4),
	(669, 0, 0, 0, 'Thanah II a', 850, 8, 0, 0, 0, 0, 36, 1),
	(670, 0, 0, 0, 'Thanah II b', 450, 8, 0, 0, 0, 0, 20, 1),
	(671, 0, 0, 0, 'Thanah II c', 450, 8, 0, 0, 0, 0, 20, 1),
	(672, 0, 0, 0, 'Thanah II d', 350, 8, 0, 0, 0, 0, 20, 1),
	(673, 0, 0, 0, 'Thanah II e', 350, 8, 0, 0, 0, 0, 20, 1),
	(674, 0, 0, 0, 'Thanah II f', 2850, 8, 0, 0, 0, 0, 86, 3),
	(675, 0, 0, 0, 'Thanah II g', 1650, 8, 0, 0, 0, 0, 51, 2),
	(676, 0, 0, 0, 'Thanah II h', 1400, 8, 0, 0, 0, 0, 55, 2),
	(677, 0, 0, 0, 'Thrarhor I a (Shop)', 1050, 8, 0, 0, 0, 0, 45, 1),
	(678, 0, 0, 0, 'Thrarhor I b (Shop)', 1050, 8, 0, 0, 0, 0, 45, 1),
	(679, 0, 0, 0, 'Thrarhor I c (Shop)', 1050, 8, 0, 0, 0, 0, 45, 1),
	(680, 0, 0, 0, 'Thrarhor I d (Shop)', 1050, 8, 0, 0, 0, 0, 45, 1),
	(681, 0, 0, 0, 'Botham I a', 950, 8, 0, 0, 0, 0, 40, 1),
	(682, 0, 0, 0, 'Botham I b', 3000, 8, 0, 0, 0, 0, 100, 3),
	(683, 0, 0, 0, 'Botham I c', 1700, 8, 0, 0, 0, 0, 49, 2),
	(684, 0, 0, 0, 'Botham I d', 3050, 8, 0, 0, 0, 0, 91, 3),
	(685, 0, 0, 0, 'Botham I e', 1650, 8, 0, 0, 0, 0, 56, 2),
	(686, 0, 0, 0, 'Botham II a', 850, 8, 0, 0, 0, 0, 36, 1),
	(687, 0, 0, 0, 'Botham II b', 1600, 8, 0, 0, 0, 0, 50, 2),
	(688, 0, 0, 0, 'Botham II c', 1250, 8, 0, 0, 0, 0, 50, 2),
	(689, 0, 0, 0, 'Botham II d', 1950, 8, 0, 0, 0, 0, 49, 2),
	(690, 0, 0, 0, 'Botham II e', 1650, 8, 0, 0, 0, 0, 49, 2),
	(691, 0, 0, 0, 'Botham II f', 1650, 8, 0, 0, 0, 0, 49, 2),
	(692, 0, 0, 0, 'Botham II g', 1400, 8, 0, 0, 0, 0, 49, 2),
	(693, 0, 0, 0, 'Botham III a', 1400, 8, 0, 0, 0, 0, 49, 2),
	(694, 0, 0, 0, 'Botham III b', 950, 8, 0, 0, 0, 0, 25, 2),
	(695, 0, 0, 0, 'Botham III c', 850, 8, 0, 0, 0, 0, 30, 1),
	(696, 0, 0, 0, 'Botham III d', 850, 8, 0, 0, 0, 0, 30, 1),
	(697, 0, 0, 0, 'Botham III e', 850, 8, 0, 0, 0, 0, 36, 1),
	(698, 0, 0, 0, 'Botham III f', 2350, 8, 0, 0, 0, 0, 56, 3),
	(699, 0, 0, 0, 'Botham III g', 1650, 8, 0, 0, 0, 0, 49, 2),
	(700, 0, 0, 0, 'Botham III h', 3750, 8, 0, 0, 0, 0, 120, 3),
	(701, 0, 0, 0, 'Botham IV a', 1400, 8, 0, 0, 0, 0, 49, 2),
	(702, 0, 0, 0, 'Botham IV b', 850, 8, 0, 0, 0, 0, 25, 1),
	(703, 0, 0, 0, 'Botham IV c', 850, 8, 0, 0, 0, 0, 30, 1),
	(704, 0, 0, 0, 'Botham IV d', 850, 8, 0, 0, 0, 0, 30, 1),
	(705, 0, 0, 0, 'Botham IV e', 850, 8, 0, 0, 0, 0, 36, 1),
	(706, 0, 0, 0, 'Botham IV f', 1700, 8, 0, 0, 0, 0, 49, 2),
	(707, 0, 0, 0, 'Botham IV g', 1650, 8, 0, 0, 0, 0, 56, 2),
	(708, 0, 0, 0, 'Botham IV h', 1850, 8, 0, 0, 0, 0, 56, 1),
	(709, 0, 0, 0, 'Botham IV i', 1800, 8, 0, 0, 0, 0, 64, 3),
	(710, 0, 0, 0, 'Ramen Tah', 7650, 8, 0, 0, 0, 0, 227, 16),
	(711, 0, 0, 0, 'Charsirakh I a', 280, 8, 0, 0, 0, 0, 20, 1),
	(712, 0, 0, 0, 'Charsirakh I b', 1580, 8, 0, 0, 0, 0, 64, 2),
	(713, 0, 0, 0, 'Charsirakh II', 1140, 8, 0, 0, 0, 0, 49, 2),
	(714, 0, 0, 0, 'Charsirakh III', 680, 8, 0, 0, 0, 0, 36, 1),
	(715, 0, 0, 0, 'Othehothep I a', 280, 8, 0, 0, 0, 0, 20, 1),
	(716, 0, 0, 0, 'Othehothep I b', 1380, 8, 0, 0, 0, 0, 64, 2),
	(717, 0, 0, 0, 'Othehothep I c', 1720, 8, 0, 0, 0, 0, 60, 3),
	(718, 0, 0, 0, 'Othehothep I d', 2020, 8, 0, 0, 0, 0, 84, 4),
	(719, 0, 0, 0, 'Othehothep II a', 400, 8, 0, 0, 0, 0, 25, 1),
	(720, 0, 0, 0, 'Othehothep II b', 1920, 8, 0, 0, 0, 0, 81, 3),
	(721, 0, 0, 0, 'Othehothep II c', 840, 8, 0, 0, 0, 0, 30, 1),
	(722, 0, 0, 0, 'Othehothep II d', 840, 8, 0, 0, 0, 0, 35, 1),
	(723, 0, 0, 0, 'Othehothep II e', 1340, 8, 0, 0, 0, 0, 48, 2),
	(724, 0, 0, 0, 'Othehothep II f', 1340, 8, 0, 0, 0, 0, 56, 2),
	(725, 0, 0, 0, 'Othehothep III a', 280, 8, 0, 0, 0, 0, 20, 1),
	(726, 0, 0, 0, 'Othehothep III b', 1340, 8, 0, 0, 0, 0, 64, 2),
	(727, 0, 0, 0, 'Othehothep III c', 940, 8, 0, 0, 0, 0, 30, 2),
	(728, 0, 0, 0, 'Othehothep III d', 1040, 8, 0, 0, 0, 0, 42, 1),
	(729, 0, 0, 0, 'Othehothep III e', 840, 8, 0, 0, 0, 0, 36, 1),
	(730, 0, 0, 0, 'Othehothep III f', 680, 8, 0, 0, 0, 0, 36, 1),
	(731, 0, 0, 0, 'Harrah I', 5740, 8, 0, 0, 0, 0, 231, 10),
	(732, 0, 0, 0, 'Murkhol I a', 440, 8, 0, 0, 0, 0, 20, 1),
	(733, 0, 0, 0, 'Murkhol I b', 440, 8, 0, 0, 0, 0, 24, 1),
	(734, 0, 0, 0, 'Murkhol I c', 440, 8, 0, 0, 0, 0, 24, 1),
	(735, 0, 0, 0, 'Murkhol I d', 440, 8, 0, 0, 0, 0, 28, 1),
	(736, 0, 0, 0, 'Oskahl I a', 1580, 8, 0, 0, 0, 0, 64, 2),
	(737, 0, 0, 0, 'Oskahl I b', 840, 8, 0, 0, 0, 0, 30, 1),
	(738, 0, 0, 0, 'Oskahl I c', 680, 8, 0, 0, 0, 0, 30, 1),
	(739, 0, 0, 0, 'Oskahl I d', 1140, 8, 0, 0, 0, 0, 42, 2),
	(740, 0, 0, 0, 'Oskahl I e', 840, 8, 0, 0, 0, 0, 42, 1),
	(741, 0, 0, 0, 'Oskahl I f', 840, 8, 0, 0, 0, 0, 35, 1),
	(742, 0, 0, 0, 'Oskahl I g', 1140, 8, 0, 0, 0, 0, 42, 2),
	(743, 0, 0, 0, 'Oskahl I h', 1760, 8, 0, 0, 0, 0, 74, 3),
	(744, 0, 0, 0, 'Oskahl I i', 840, 8, 0, 0, 0, 0, 36, 1),
	(745, 0, 0, 0, 'Oskahl I j', 680, 8, 0, 0, 0, 0, 36, 1),
	(746, 0, 0, 0, 'Mothrem I', 1140, 8, 0, 0, 0, 0, 49, 2),
	(747, 0, 0, 0, 'Arakmehn I', 1320, 8, 0, 0, 0, 0, 53, 3),
	(748, 0, 0, 0, 'Arakmehn II', 1040, 8, 0, 0, 0, 0, 49, 1),
	(749, 0, 0, 0, 'Arakmehn III', 1140, 8, 0, 0, 0, 0, 49, 2),
	(750, 0, 0, 0, 'Arakmehn IV', 1220, 8, 0, 0, 0, 0, 53, 2),
	(751, 0, 0, 0, 'Unklath I a', 1140, 8, 0, 0, 0, 0, 49, 2),
	(752, 0, 0, 0, 'Unklath I b', 1460, 8, 0, 0, 0, 0, 55, 2),
	(753, 0, 0, 0, 'Unklath I c', 1460, 8, 0, 0, 0, 0, 66, 2),
	(754, 0, 0, 0, 'Unklath I d', 1680, 8, 0, 0, 0, 0, 49, 3),
	(755, 0, 0, 0, 'Unklath I e', 1580, 8, 0, 0, 0, 0, 56, 2),
	(756, 0, 0, 0, 'Unklath I f', 1580, 8, 0, 0, 0, 0, 56, 2),
	(757, 0, 0, 0, 'Unklath I g', 1480, 8, 0, 0, 0, 0, 64, 1),
	(758, 0, 0, 0, 'Unklath II a', 1040, 8, 0, 0, 0, 0, 49, 1),
	(759, 0, 0, 0, 'Unklath II b', 680, 8, 0, 0, 0, 0, 25, 1),
	(760, 0, 0, 0, 'Unklath II c', 680, 8, 0, 0, 0, 0, 30, 1),
	(761, 0, 0, 0, 'Unklath II d', 1580, 8, 0, 0, 0, 0, 66, 2),
	(762, 0, 0, 0, 'Rathal I a', 1140, 8, 0, 0, 0, 0, 49, 2),
	(763, 0, 0, 0, 'Rathal I b', 680, 8, 0, 0, 0, 0, 25, 1),
	(764, 0, 0, 0, 'Rathal I c', 680, 8, 0, 0, 0, 0, 30, 1),
	(765, 0, 0, 0, 'Rathal I d', 780, 8, 0, 0, 0, 0, 30, 2),
	(766, 0, 0, 0, 'Rathal I e', 780, 8, 0, 0, 0, 0, 36, 2),
	(767, 0, 0, 0, 'Rathal II a', 1040, 8, 0, 0, 0, 0, 49, 1),
	(768, 0, 0, 0, 'Rathal II b', 680, 8, 0, 0, 0, 0, 25, 1),
	(769, 0, 0, 0, 'Rathal II c', 680, 8, 0, 0, 0, 0, 30, 1),
	(770, 0, 0, 0, 'Rathal II d', 1460, 8, 0, 0, 0, 0, 66, 2),
	(771, 0, 0, 0, 'Uthemath I a', 400, 8, 0, 0, 0, 0, 25, 1),
	(772, 0, 0, 0, 'Uthemath I b', 800, 8, 0, 0, 0, 0, 36, 1),
	(773, 0, 0, 0, 'Uthemath I c', 900, 8, 0, 0, 0, 0, 45, 2),
	(774, 0, 0, 0, 'Uthemath I d', 840, 8, 0, 0, 0, 0, 30, 1),
	(775, 0, 0, 0, 'Uthemath I e', 940, 8, 0, 0, 0, 0, 35, 2),
	(776, 0, 0, 0, 'Uthemath I f', 2440, 8, 0, 0, 0, 0, 104, 3),
	(777, 0, 0, 0, 'Uthemath II', 4460, 8, 0, 0, 0, 0, 170, 8),
	(778, 0, 0, 0, 'Esuph I', 680, 8, 0, 0, 0, 0, 36, 1),
	(779, 0, 0, 0, 'Esuph II a', 280, 8, 0, 0, 0, 0, 20, 1),
	(780, 0, 0, 0, 'Esuph II b', 1380, 8, 0, 0, 0, 0, 64, 2),
	(781, 0, 0, 0, 'Esuph III a', 280, 8, 0, 0, 0, 0, 20, 1),
	(782, 0, 0, 0, 'Esuph III b', 1340, 8, 0, 0, 0, 0, 64, 2),
	(783, 0, 0, 0, 'Esuph IV a', 400, 8, 0, 0, 0, 0, 25, 1),
	(784, 0, 0, 0, 'Esuph IV b', 400, 8, 0, 0, 0, 0, 16, 1),
	(785, 0, 0, 0, 'Esuph IV c', 400, 8, 0, 0, 0, 0, 20, 1),
	(786, 0, 0, 0, 'Esuph IV d', 800, 8, 0, 0, 0, 0, 45, 1),
	(787, 0, 0, 0, 'Horakhal', 9420, 8, 0, 0, 0, 0, 332, 14),
	(788, 0, 0, 0, 'Darashia 1, Flat 01', 1100, 6, 0, 0, 0, 0, 42, 2),
	(789, 0, 0, 0, 'Darashia 1, Flat 02', 1000, 6, 0, 0, 0, 0, 42, 1),
	(790, 0, 0, 0, 'Darashia 1, Flat 03', 2660, 6, 0, 0, 0, 0, 102, 4),
	(791, 0, 0, 0, 'Darashia 1, Flat 04', 1000, 6, 0, 0, 0, 0, 42, 1),
	(792, 0, 0, 0, 'Darashia 1, Flat 05', 1100, 6, 0, 0, 0, 0, 48, 2),
	(793, 0, 0, 0, 'Darashia 1, Flat 11', 1100, 6, 0, 0, 0, 0, 36, 2),
	(794, 0, 0, 0, 'Darashia 1, Flat 12', 1780, 6, 0, 0, 0, 0, 72, 2),
	(795, 0, 0, 0, 'Darashia 1, Flat 13', 1780, 6, 0, 0, 0, 0, 72, 2),
	(796, 0, 0, 0, 'Darashia 1, Flat 14', 2760, 6, 0, 0, 0, 0, 108, 5),
	(797, 0, 0, 0, 'Darashia 2, Flat 01', 1000, 6, 0, 0, 0, 0, 42, 1),
	(798, 0, 0, 0, 'Darashia 2, Flat 02', 1000, 6, 0, 0, 0, 0, 42, 1),
	(799, 0, 0, 0, 'Darashia 2, Flat 03', 1160, 6, 0, 0, 0, 0, 48, 1),
	(800, 0, 0, 0, 'Darashia 2, Flat 04', 520, 6, 0, 0, 0, 0, 24, 1),
	(801, 0, 0, 0, 'Darashia 2, Flat 05', 1260, 6, 0, 0, 0, 0, 48, 2),
	(802, 0, 0, 0, 'Darashia 2, Flat 06', 520, 6, 0, 0, 0, 0, 24, 1),
	(803, 0, 0, 0, 'Darashia 2, Flat 07', 1000, 6, 0, 0, 0, 0, 48, 1),
	(804, 0, 0, 0, 'Darashia 2, Flat 11', 1000, 6, 0, 0, 0, 0, 36, 1),
	(805, 0, 0, 0, 'Darashia 2, Flat 12', 520, 6, 0, 0, 0, 0, 24, 1),
	(806, 0, 0, 0, 'Darashia 2, Flat 13', 1160, 6, 0, 0, 0, 0, 48, 1),
	(807, 0, 0, 0, 'Darashia 2, Flat 14', 520, 6, 0, 0, 0, 0, 24, 1),
	(808, 0, 0, 0, 'Darashia 2, Flat 15', 1260, 6, 0, 0, 0, 0, 48, 2),
	(809, 0, 0, 0, 'Darashia 2, Flat 16', 680, 6, 0, 0, 0, 0, 30, 1),
	(810, 0, 0, 0, 'Darashia 2, Flat 17', 1000, 6, 0, 0, 0, 0, 42, 1),
	(811, 0, 0, 0, 'Darashia 2, Flat 18', 680, 6, 0, 0, 0, 0, 36, 1),
	(812, 0, 0, 0, 'Darashia 3, Flat 01', 1100, 6, 0, 0, 0, 0, 42, 2),
	(813, 0, 0, 0, 'Darashia 3, Flat 02', 1620, 6, 0, 0, 0, 0, 66, 2),
	(814, 0, 0, 0, 'Darashia 3, Flat 03', 1100, 6, 0, 0, 0, 0, 42, 2),
	(815, 0, 0, 0, 'Darashia 3, Flat 04', 1620, 6, 0, 0, 0, 0, 66, 2),
	(816, 0, 0, 0, 'Darashia 3, Flat 05', 1000, 6, 0, 0, 0, 0, 48, 1),
	(817, 0, 0, 0, 'Darashia 3, Flat 11', 1000, 6, 0, 0, 0, 0, 36, 1),
	(818, 0, 0, 0, 'Darashia 3, Flat 12', 2600, 6, 0, 0, 0, 0, 96, 5),
	(819, 0, 0, 0, 'Darashia 3, Flat 13', 1100, 6, 0, 0, 0, 0, 42, 2),
	(820, 0, 0, 0, 'Darashia 3, Flat 14', 2400, 6, 0, 0, 0, 0, 102, 3),
	(821, 0, 0, 0, 'Darashia 4, Flat 01', 1000, 6, 0, 0, 0, 0, 42, 1),
	(822, 0, 0, 0, 'Darashia 4, Flat 02', 1780, 6, 0, 0, 0, 0, 72, 2),
	(823, 0, 0, 0, 'Darashia 4, Flat 03', 1000, 6, 0, 0, 0, 0, 42, 1),
	(824, 0, 0, 0, 'Darashia 4, Flat 04', 1780, 6, 0, 0, 0, 0, 72, 2),
	(825, 0, 0, 0, 'Darashia 4, Flat 05', 1100, 6, 0, 0, 0, 0, 48, 2),
	(826, 0, 0, 0, 'Darashia 4, Flat 11', 1000, 6, 0, 0, 0, 0, 36, 1),
	(827, 0, 0, 0, 'Darashia 4, Flat 12', 2560, 6, 0, 0, 0, 0, 102, 3),
	(828, 0, 0, 0, 'Darashia 4, Flat 13', 1780, 6, 0, 0, 0, 0, 72, 2),
	(829, 0, 0, 0, 'Darashia 4, Flat 14', 1780, 6, 0, 0, 0, 0, 78, 2),
	(830, 0, 0, 0, 'Darashia 5, Flat 01', 1000, 6, 0, 0, 0, 0, 42, 1),
	(831, 0, 0, 0, 'Darashia 5, Flat 02', 1620, 6, 0, 0, 0, 0, 66, 2),
	(832, 0, 0, 0, 'Darashia 5, Flat 03', 1000, 6, 0, 0, 0, 0, 42, 1),
	(833, 0, 0, 0, 'Darashia 5, Flat 04', 1620, 6, 0, 0, 0, 0, 66, 2),
	(834, 0, 0, 0, 'Darashia 5, Flat 05', 1000, 6, 0, 0, 0, 0, 48, 1),
	(835, 0, 0, 0, 'Darashia 5, Flat 11', 1780, 6, 0, 0, 0, 0, 66, 2),
	(836, 0, 0, 0, 'Darashia 5, Flat 12', 1620, 6, 0, 0, 0, 0, 66, 2),
	(837, 0, 0, 0, 'Darashia 5, Flat 13', 1780, 6, 0, 0, 0, 0, 72, 2),
	(838, 0, 0, 0, 'Darashia 5, Flat 14', 1620, 6, 0, 0, 0, 0, 72, 2),
	(839, 0, 0, 0, 'Darashia 6a', 3115, 6, 0, 0, 0, 0, 115, 2),
	(840, 0, 0, 0, 'Darashia 6b', 3430, 6, 0, 0, 0, 0, 139, 2),
	(841, 0, 0, 0, 'Darashia 7, Flat 01', 1125, 6, 0, 0, 0, 0, 42, 1),
	(842, 0, 0, 0, 'Darashia 7, Flat 02', 1125, 6, 0, 0, 0, 0, 42, 1),
	(843, 0, 0, 0, 'Darashia 7, Flat 03', 2955, 6, 0, 0, 0, 0, 102, 4),
	(844, 0, 0, 0, 'Darashia 7, Flat 04', 1125, 6, 0, 0, 0, 0, 42, 1),
	(845, 0, 0, 0, 'Darashia 7, Flat 05', 1225, 6, 0, 0, 0, 0, 48, 2),
	(846, 0, 0, 0, 'Darashia 7, Flat 11', 1125, 6, 0, 0, 0, 0, 36, 1),
	(847, 0, 0, 0, 'Darashia 7, Flat 12', 2955, 6, 0, 0, 0, 0, 102, 4),
	(848, 0, 0, 0, 'Darashia 7, Flat 13', 1125, 6, 0, 0, 0, 0, 42, 1),
	(849, 0, 0, 0, 'Darashia 7, Flat 14', 2955, 6, 0, 0, 0, 0, 108, 4),
	(850, 0, 0, 0, 'Darashia 8, Flat 01', 2485, 6, 0, 0, 0, 0, 82, 2),
	(851, 0, 0, 0, 'Darashia 8, Flat 02', 3385, 6, 0, 0, 0, 0, 114, 2),
	(852, 0, 0, 0, 'Darashia 8, Flat 03', 4700, 6, 0, 0, 0, 0, 170, 3),
	(853, 0, 0, 0, 'Darashia 8, Flat 04', 2845, 6, 0, 0, 0, 0, 96, 2),
	(854, 0, 0, 0, 'Darashia 8, Flat 05', 2665, 6, 0, 0, 0, 0, 108, 2),
	(855, 0, 0, 0, 'Darashia, Villa', 5385, 6, 0, 0, 0, 0, 233, 4),
	(856, 0, 0, 0, 'Darashia, Western Guildhall', 10435, 6, 0, 0, 0, 0, 376, 14),
	(857, 0, 0, 0, 'Darashia, Eastern Guildhall', 12660, 6, 0, 0, 0, 0, 456, 16),
	(858, 0, 0, 0, 'Darashia 8, Flat 11', 1990, 6, 0, 0, 0, 0, 66, 2),
	(859, 0, 0, 0, 'Darashia 8, Flat 12', 1810, 6, 0, 0, 0, 0, 66, 2),
	(860, 0, 0, 0, 'Darashia 8, Flat 13', 1990, 6, 0, 0, 0, 0, 72, 2),
	(861, 0, 0, 0, 'Darashia 8, Flat 14', 1810, 6, 0, 0, 0, 0, 72, 2);
/*!40000 ALTER TABLE `houses` ENABLE KEYS */;

-- Dumping structure for table tibia.house_lists
CREATE TABLE IF NOT EXISTS `house_lists` (
  `house_id` int(11) NOT NULL,
  `listid` int(11) NOT NULL,
  `list` text NOT NULL,
  KEY `house_id` (`house_id`),
  CONSTRAINT `house_lists_ibfk_1` FOREIGN KEY (`house_id`) REFERENCES `houses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.house_lists: ~0 rows (approximately)
DELETE FROM `house_lists`;
/*!40000 ALTER TABLE `house_lists` DISABLE KEYS */;
/*!40000 ALTER TABLE `house_lists` ENABLE KEYS */;

-- Dumping structure for table tibia.ip_bans
CREATE TABLE IF NOT EXISTS `ip_bans` (
  `ip` int(10) unsigned NOT NULL,
  `reason` varchar(255) NOT NULL,
  `banned_at` bigint(20) NOT NULL,
  `expires_at` bigint(20) NOT NULL,
  `banned_by` int(11) NOT NULL,
  PRIMARY KEY (`ip`),
  KEY `banned_by` (`banned_by`),
  CONSTRAINT `ip_bans_ibfk_1` FOREIGN KEY (`banned_by`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.ip_bans: ~0 rows (approximately)
DELETE FROM `ip_bans`;
/*!40000 ALTER TABLE `ip_bans` DISABLE KEYS */;
/*!40000 ALTER TABLE `ip_bans` ENABLE KEYS */;

-- Dumping structure for table tibia.players
CREATE TABLE IF NOT EXISTS `players` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `group_id` int(11) NOT NULL DEFAULT '1',
  `account_id` int(11) NOT NULL DEFAULT '0',
  `level` int(11) NOT NULL DEFAULT '1',
  `vocation` int(11) NOT NULL DEFAULT '0',
  `health` int(11) NOT NULL DEFAULT '150',
  `healthmax` int(11) NOT NULL DEFAULT '150',
  `experience` bigint(20) unsigned NOT NULL DEFAULT '0',
  `lookbody` int(11) NOT NULL DEFAULT '0',
  `lookfeet` int(11) NOT NULL DEFAULT '0',
  `lookhead` int(11) NOT NULL DEFAULT '0',
  `looklegs` int(11) NOT NULL DEFAULT '0',
  `looktype` int(11) NOT NULL DEFAULT '136',
  `maglevel` int(11) NOT NULL DEFAULT '0',
  `mana` int(11) NOT NULL DEFAULT '0',
  `manamax` int(11) NOT NULL DEFAULT '0',
  `manaspent` bigint(20) unsigned NOT NULL DEFAULT '0',
  `soul` int(10) unsigned NOT NULL DEFAULT '0',
  `town_id` int(11) NOT NULL DEFAULT '1',
  `posx` int(11) NOT NULL DEFAULT '0',
  `posy` int(11) NOT NULL DEFAULT '0',
  `posz` int(11) NOT NULL DEFAULT '0',
  `conditions` blob NOT NULL,
  `cap` int(11) NOT NULL DEFAULT '400',
  `sex` int(11) NOT NULL DEFAULT '0',
  `lastlogin` bigint(20) unsigned NOT NULL DEFAULT '0',
  `lastip` int(10) unsigned NOT NULL DEFAULT '0',
  `save` tinyint(4) NOT NULL DEFAULT '1',
  `skull` tinyint(4) NOT NULL DEFAULT '0',
  `skulltime` bigint(20) NOT NULL DEFAULT '0',
  `lastlogout` bigint(20) unsigned NOT NULL DEFAULT '0',
  `blessings` tinyint(4) NOT NULL DEFAULT '0',
  `onlinetime` bigint(20) NOT NULL DEFAULT '0',
  `deletion` bigint(20) NOT NULL DEFAULT '0',
  `balance` bigint(20) unsigned NOT NULL DEFAULT '0',
  `stamina` smallint(5) unsigned NOT NULL DEFAULT '2520',
  `skill_fist` int(10) unsigned NOT NULL DEFAULT '10',
  `skill_fist_tries` bigint(20) unsigned NOT NULL DEFAULT '0',
  `skill_club` int(10) unsigned NOT NULL DEFAULT '10',
  `skill_club_tries` bigint(20) unsigned NOT NULL DEFAULT '0',
  `skill_sword` int(10) unsigned NOT NULL DEFAULT '10',
  `skill_sword_tries` bigint(20) unsigned NOT NULL DEFAULT '0',
  `skill_axe` int(10) unsigned NOT NULL DEFAULT '10',
  `skill_axe_tries` bigint(20) unsigned NOT NULL DEFAULT '0',
  `skill_dist` int(10) unsigned NOT NULL DEFAULT '10',
  `skill_dist_tries` bigint(20) unsigned NOT NULL DEFAULT '0',
  `skill_shielding` int(10) unsigned NOT NULL DEFAULT '10',
  `skill_shielding_tries` bigint(20) unsigned NOT NULL DEFAULT '0',
  `skill_fishing` int(10) unsigned NOT NULL DEFAULT '10',
  `skill_fishing_tries` bigint(20) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `account_id` (`account_id`),
  KEY `vocation` (`vocation`),
  CONSTRAINT `players_ibfk_1` FOREIGN KEY (`account_id`) REFERENCES `accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.players: ~4 rows (approximately)
DELETE FROM `players`;
/*!40000 ALTER TABLE `players` DISABLE KEYS */;
INSERT INTO `players` (`id`, `name`, `group_id`, `account_id`, `level`, `vocation`, `health`, `healthmax`, `experience`, `lookbody`, `lookfeet`, `lookhead`, `looklegs`, `looktype`, `maglevel`, `mana`, `manamax`, `manaspent`, `soul`, `town_id`, `posx`, `posy`, `posz`, `conditions`, `cap`, `sex`, `lastlogin`, `lastip`, `save`, `skull`, `skulltime`, `lastlogout`, `blessings`, `onlinetime`, `deletion`, `balance`, `stamina`, `skill_fist`, `skill_fist_tries`, `skill_club`, `skill_club_tries`, `skill_sword`, `skill_sword_tries`, `skill_axe`, `skill_axe_tries`, `skill_dist`, `skill_dist_tries`, `skill_shielding`, `skill_shielding_tries`, `skill_fishing`, `skill_fishing_tries`) VALUES
	(1, 'GM Violet', 6, 1234567, 1000, 0, 150, 150, 16566949800, 0, 0, 0, 0, 75, 1000, 0, 0, 0, 0, 1, 32370, 32214, 7, _binary '', 400, 0, 1640047409, 16777343, 1, 0, 0, 1640047486, 0, 55331, 0, 0, 2520, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0),
	(2, 'GM Ezzz', 6, 1234567, 100, 0, 150, 150, 15694800, 0, 0, 0, 0, 75, 3, 0, 0, 0, 0, 1, 32366, 32204, 7, _binary '', 400, 0, 1639789456, 1842107080, 1, 0, 0, 1639789457, 0, 9148, 0, 0, 2520, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0, 10, 0),
	(3, 'Knight', 1, 1234567, 108, 4, 6080, 6080, 19871288, 0, 0, 0, 0, 75, 9, 4938, 8180, 5912, 2, 1, 32369, 32229, 7, _binary 0x010004000002FFFFFFFF0390E200001A001B000000001C00FE010010000002FFFFFFFF0348D005001A001B000000001C0004B80B0000050500000006701700000705000000FE010020000002FFFFFFFF03B0A103001A001B000000001C00150100000014C0D40100FE, 12260, 0, 1639945853, 16777343, 1, 0, 0, 1639945896, 0, 32986, 0, 0, 2518, 12, 6, 10, 0, 77, 11, 10, 0, 11, 12, 12, 72, 10, 0),
	(4, 'Druid', 1, 1234567, 50, 2, 10606, 10640, 1848515, 0, 0, 0, 0, 75, 22, 4871, 10490, 340, 3, 1, 32369, 32179, 7, _binary '', 21380, 0, 1639938740, 16777343, 1, 0, 0, 1639938742, 0, 24390, 0, 0, 2520, 12, 72, 10, 0, 11, 19, 10, 0, 10, 8, 11, 45, 11, 5);
/*!40000 ALTER TABLE `players` ENABLE KEYS */;

-- Dumping structure for table tibia.players_online
CREATE TABLE IF NOT EXISTS `players_online` (
  `player_id` int(11) NOT NULL,
  PRIMARY KEY (`player_id`)
) ENGINE=MEMORY DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.players_online: 0 rows
DELETE FROM `players_online`;
/*!40000 ALTER TABLE `players_online` DISABLE KEYS */;
/*!40000 ALTER TABLE `players_online` ENABLE KEYS */;

-- Dumping structure for table tibia.player_deaths
CREATE TABLE IF NOT EXISTS `player_deaths` (
  `player_id` int(11) NOT NULL,
  `time` bigint(20) unsigned NOT NULL DEFAULT '0',
  `level` int(11) NOT NULL DEFAULT '1',
  `killed_by` varchar(255) NOT NULL,
  `is_player` tinyint(4) NOT NULL DEFAULT '1',
  `mostdamage_by` varchar(100) NOT NULL,
  `mostdamage_is_player` tinyint(4) NOT NULL DEFAULT '0',
  `unjustified` tinyint(4) NOT NULL DEFAULT '0',
  `mostdamage_unjustified` tinyint(4) NOT NULL DEFAULT '0',
  KEY `player_id` (`player_id`),
  KEY `killed_by` (`killed_by`),
  KEY `mostdamage_by` (`mostdamage_by`),
  CONSTRAINT `player_deaths_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.player_deaths: ~5 rows (approximately)
DELETE FROM `player_deaths`;
/*!40000 ALTER TABLE `player_deaths` DISABLE KEYS */;
INSERT INTO `player_deaths` (`player_id`, `time`, `level`, `killed_by`, `is_player`, `mostdamage_by`, `mostdamage_is_player`, `unjustified`, `mostdamage_unjustified`) VALUES
	(3, 1638235355, 1, 'Black Knight', 0, 'Scorpion', 0, 0, 0),
	(3, 1638417983, 101, 'Orc Berserker', 0, 'Orc Berserker', 0, 0, 0),
	(3, 1638419638, 99, 'Orc Berserker', 0, 'Orc Berserker', 0, 0, 0),
	(3, 1639776281, 20, 'Dragon', 0, 'Dragon', 0, 0, 0),
	(3, 1639776987, 19, 'Warlock', 0, 'Warlock', 0, 0, 0);
/*!40000 ALTER TABLE `player_deaths` ENABLE KEYS */;

-- Dumping structure for table tibia.player_depotitems
CREATE TABLE IF NOT EXISTS `player_depotitems` (
  `player_id` int(11) NOT NULL,
  `sid` int(11) NOT NULL COMMENT 'any given range eg 0-100 will be reserved for depot lockers and all > 100 will be then normal items inside depots',
  `pid` int(11) NOT NULL DEFAULT '0',
  `itemtype` smallint(5) unsigned NOT NULL,
  `count` smallint(6) NOT NULL DEFAULT '0',
  `attributes` blob NOT NULL,
  UNIQUE KEY `player_id_2` (`player_id`,`sid`),
  CONSTRAINT `player_depotitems_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.player_depotitems: ~0 rows (approximately)
DELETE FROM `player_depotitems`;
/*!40000 ALTER TABLE `player_depotitems` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_depotitems` ENABLE KEYS */;

-- Dumping structure for table tibia.player_items
CREATE TABLE IF NOT EXISTS `player_items` (
  `player_id` int(11) NOT NULL DEFAULT '0',
  `pid` int(11) NOT NULL DEFAULT '0',
  `sid` int(11) NOT NULL DEFAULT '0',
  `itemtype` smallint(5) unsigned NOT NULL DEFAULT '0',
  `count` smallint(6) NOT NULL DEFAULT '0',
  `attributes` blob NOT NULL,
  KEY `player_id` (`player_id`),
  KEY `sid` (`sid`),
  CONSTRAINT `player_items_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.player_items: ~6 rows (approximately)
DELETE FROM `player_items`;
/*!40000 ALTER TABLE `player_items` DISABLE KEYS */;
INSERT INTO `player_items` (`player_id`, `pid`, `sid`, `itemtype`, `count`, `attributes`) VALUES
	(2, 5, 101, 2595, 1, _binary ''),
	(3, 6, 101, 2407, 1, _binary ''),
	(3, 10, 102, 2544, 47, _binary 0x0F2F),
	(1, 5, 101, 2274, 1, _binary ''),
	(1, 6, 102, 2275, 1, _binary ''),
	(1, 10, 103, 2276, 1, _binary '');
/*!40000 ALTER TABLE `player_items` ENABLE KEYS */;

-- Dumping structure for table tibia.player_namelocks
CREATE TABLE IF NOT EXISTS `player_namelocks` (
  `player_id` int(11) NOT NULL,
  `reason` varchar(255) NOT NULL,
  `namelocked_at` bigint(20) NOT NULL,
  `namelocked_by` int(11) NOT NULL,
  PRIMARY KEY (`player_id`),
  KEY `namelocked_by` (`namelocked_by`),
  CONSTRAINT `player_namelocks_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `player_namelocks_ibfk_2` FOREIGN KEY (`namelocked_by`) REFERENCES `players` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.player_namelocks: ~0 rows (approximately)
DELETE FROM `player_namelocks`;
/*!40000 ALTER TABLE `player_namelocks` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_namelocks` ENABLE KEYS */;

-- Dumping structure for table tibia.player_spells
CREATE TABLE IF NOT EXISTS `player_spells` (
  `player_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  KEY `player_id` (`player_id`),
  CONSTRAINT `player_spells_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.player_spells: ~0 rows (approximately)
DELETE FROM `player_spells`;
/*!40000 ALTER TABLE `player_spells` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_spells` ENABLE KEYS */;

-- Dumping structure for table tibia.player_storage
CREATE TABLE IF NOT EXISTS `player_storage` (
  `player_id` int(11) NOT NULL DEFAULT '0',
  `key` int(10) unsigned NOT NULL DEFAULT '0',
  `value` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`player_id`,`key`),
  CONSTRAINT `player_storage_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.player_storage: ~0 rows (approximately)
DELETE FROM `player_storage`;
/*!40000 ALTER TABLE `player_storage` DISABLE KEYS */;
/*!40000 ALTER TABLE `player_storage` ENABLE KEYS */;

-- Dumping structure for table tibia.server_config
CREATE TABLE IF NOT EXISTS `server_config` (
  `config` varchar(50) NOT NULL,
  `value` varchar(256) NOT NULL DEFAULT '',
  PRIMARY KEY (`config`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.server_config: ~4 rows (approximately)
DELETE FROM `server_config`;
/*!40000 ALTER TABLE `server_config` DISABLE KEYS */;
INSERT INTO `server_config` (`config`, `value`) VALUES
	('db_version', '0'),
	('motd_hash', '8af41933638e522422ef2d1e0648b65bfd456e0d'),
	('motd_num', '3'),
	('players_record', '3');
/*!40000 ALTER TABLE `server_config` ENABLE KEYS */;

-- Dumping structure for table tibia.towns
CREATE TABLE IF NOT EXISTS `towns` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `posx` int(11) NOT NULL DEFAULT '0',
  `posy` int(11) NOT NULL DEFAULT '0',
  `posz` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

-- Dumping data for table tibia.towns: ~9 rows (approximately)
DELETE FROM `towns`;
/*!40000 ALTER TABLE `towns` DISABLE KEYS */;
INSERT INTO `towns` (`id`, `name`, `posx`, `posy`, `posz`) VALUES
	(1, 'Thais', 32369, 32241, 7),
	(2, 'Carlin', 32360, 31782, 7),
	(3, 'Kazordoon', 32649, 31925, 11),
	(4, 'Ab\'Dendriel', 32732, 31634, 7),
	(5, 'Edron', 33217, 31814, 8),
	(6, 'Darashia', 33213, 32454, 1),
	(7, 'Venore', 32957, 32076, 7),
	(8, 'Ankrahmun', 33195, 32853, 8),
	(9, 'Port Hope', 32595, 32745, 7);
/*!40000 ALTER TABLE `towns` ENABLE KEYS */;

-- Dumping structure for trigger tibia.oncreate_guilds
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `oncreate_guilds` AFTER INSERT ON `guilds`
 FOR EACH ROW BEGIN
    INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('the Leader', 3, NEW.`id`);
    INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('a Vice-Leader', 2, NEW.`id`);
    INSERT INTO `guild_ranks` (`name`, `level`, `guild_id`) VALUES ('a Member', 1, NEW.`id`);
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Dumping structure for trigger tibia.ondelete_players
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `ondelete_players` BEFORE DELETE ON `players`
 FOR EACH ROW BEGIN
    UPDATE `houses` SET `owner` = 0 WHERE `owner` = OLD.`id`;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
