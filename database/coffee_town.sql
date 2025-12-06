-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 01, 2024 at 04:31 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `coffee_town`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_on_delete_cascade` ()   BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE constraint_name VARCHAR(255);
    DECLARE table_name VARCHAR(255);
    DECLARE fk_cursor CURSOR FOR
        SELECT TABLE_NAME, CONSTRAINT_NAME
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE REFERENCED_TABLE_NAME = 'products' AND TABLE_SCHEMA = 'coffee_town';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN fk_cursor;
    
    -- Loop through all foreign key constraints referencing the 'products' table
    read_loop: LOOP
        FETCH fk_cursor INTO table_name, constraint_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Drop the existing foreign key constraint
        SET @drop_fk_sql = CONCAT('ALTER TABLE ', table_name, ' DROP FOREIGN KEY ', constraint_name);
        PREPARE stmt FROM @drop_fk_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        -- Add the foreign key with ON DELETE CASCADE
        SET @add_fk_sql = CONCAT('ALTER TABLE ', table_name, ' ADD CONSTRAINT ', constraint_name,
                                  ' FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE');
        PREPARE stmt FROM @add_fk_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE fk_cursor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_add_to_cart` (IN `p_customer_id` INT, IN `p_item_name` VARCHAR(255), IN `p_quantity` INT, IN `p_price` DECIMAL(10,2))   BEGIN
    INSERT INTO cart (customer_id, item_name, quantity, price, added_at)
    VALUES (p_customer_id, p_item_name, p_quantity, p_price, CURRENT_TIMESTAMP);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_get_customer_purchases` (IN `p_customer_id` INT)   BEGIN
    SELECT * 
    FROM purchases 
    WHERE customerID = p_customer_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_update_inventory` (IN `p_product_id` INT, IN `p_new_quantity` INT)   BEGIN
    UPDATE inventory
    SET quantity = p_new_quantity
    WHERE id = p_product_id;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_calculate_total_purchase` (`p_customer_id` INT) RETURNS DECIMAL(10,2) DETERMINISTIC BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(total_amount) INTO total 
    FROM purchases 
    WHERE customerID = p_customer_id;
    RETURN IFNULL(total, 0);
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_check_inventory_quantity` (`p_product_id` INT, `p_quantity` INT) RETURNS TINYINT(1) DETERMINISTIC BEGIN
    DECLARE available_quantity INT;
    SELECT quantity INTO available_quantity 
    FROM inventory 
    WHERE id = p_product_id;
    
    IF available_quantity >= p_quantity THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `fn_get_product_price` (`p_product_id` INT) RETURNS DECIMAL(10,2) DETERMINISTIC BEGIN
    DECLARE price DECIMAL(10,2);
    SELECT price INTO price 
    FROM products 
    WHERE id = p_product_id;
    RETURN price;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `id` int(11) NOT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `item_name` varchar(255) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `added_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cart`
--

INSERT INTO `cart` (`id`, `customer_id`, `item_name`, `quantity`, `price`, `added_at`) VALUES
(1, 1, 'Latte', 2, 4.50, '2024-10-14 20:21:18');

-- --------------------------------------------------------

--
-- Table structure for table `categorized_expenses`
--

CREATE TABLE `categorized_expenses` (
  `id` int(11) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `total_cost` decimal(10,2) DEFAULT NULL,
  `order_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `categorized_purchases`
--

CREATE TABLE `categorized_purchases` (
  `id` int(11) NOT NULL,
  `category` varchar(50) DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL,
  `purchase_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `customerID` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `contact_number` varchar(15) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`customerID`, `name`, `contact_number`, `created_at`) VALUES
(68, 'Mlejay', '12332', '2024-10-11 08:03:26'),
(69, 'gfh', '22323', '2024-10-11 08:11:51'),
(70, 'mlejay', '312', '2024-10-11 14:53:26'),
(71, 'jhbhbj', '4345', '2024-10-11 15:17:01'),
(72, 'nesfs', '3422345', '2024-10-11 15:20:09'),
(73, 'nvvf', '433', '2024-10-11 15:22:46'),
(74, 'Mlejay', '132123', '2024-10-11 15:25:31'),
(75, 'jad', '1234', '2024-10-11 15:26:08'),
(76, 'Customer', '234234', '2024-10-11 15:32:30'),
(77, 'Jay', '123312', '2024-10-11 15:43:14'),
(78, 'fdsdf', '23312', '2024-10-11 15:44:50'),
(79, 'das21', '12', '2024-10-11 15:57:36'),
(80, 'jay12', '324', '2024-10-11 15:58:05'),
(81, 'msda', '123', '2024-10-11 16:09:11'),
(82, 'mahal', '123', '2024-10-11 16:10:21'),
(83, 'msd', '312', '2024-10-11 16:10:31'),
(84, 'Mlk', '123', '2024-10-11 16:11:58'),
(85, '21', '2323', '2024-10-11 16:12:08'),
(86, 'mdsa', '12342', '2024-10-11 16:14:18'),
(87, 'Mas', '432', '2024-10-11 16:16:28'),
(88, '123', '213', '2024-10-11 16:16:46'),
(89, 'sad', '213', '2024-10-11 16:21:02'),
(90, '213', '324', '2024-10-11 16:21:19'),
(91, '12', '321', '2024-10-11 16:29:45'),
(92, '123', '123', '2024-10-11 16:31:04'),
(93, '312', '321', '2024-10-11 16:31:21'),
(94, '312', '3', '2024-10-11 16:31:27'),
(95, '123', '43', '2024-10-11 17:21:32'),
(96, 'dsa', '312', '2024-10-11 17:22:49'),
(97, 'Jay', '09606491454', '2024-10-12 14:22:59'),
(98, 'Melja7', '09332244323', '2024-10-12 14:23:24'),
(99, 'asd', '09232323243', '2024-10-12 16:56:00'),
(100, 'Jay', '09606491454', '2024-10-12 23:20:20'),
(101, 'Jay', '09606491454', '2024-10-12 23:53:19'),
(102, 'Meljau', '09606491454', '2024-10-12 23:58:19'),
(103, 'JASPER', '09606491454', '2024-10-13 00:11:52'),
(104, 'jay', '09606491454', '2024-10-13 00:15:16'),
(105, 'asdas', '09606491454', '2024-10-13 00:24:30'),
(106, 'alam', '09606491454', '2024-10-13 00:25:41'),
(107, 'alam', '09606491454', '2024-10-13 00:27:48'),
(108, 'jay1', '09606491454', '2024-10-13 00:28:06'),
(109, 'jay', '09606491454', '2024-10-13 06:03:54'),
(110, 'jay', '09606491454', '2024-10-13 06:36:57'),
(111, 'jay', '09123134334', '2024-10-13 06:37:24'),
(112, 'mdsa', '09606491454', '2024-10-13 08:20:17'),
(113, 'dsa', '09606491454', '2024-10-13 11:27:36'),
(114, 'adsd', '09606491454', '2024-10-13 12:12:23'),
(115, 'asd', '09606491454', '2024-10-13 12:13:07'),
(116, 'das', '09606491454', '2024-10-14 12:52:53'),
(117, '132', '09606491454', '2024-10-14 13:36:44'),
(118, '312', '09606491454', '2024-10-14 13:48:01'),
(119, '12', '09606491454', '2024-10-14 13:48:45'),
(120, 'sd', '09606491454', '2024-10-14 14:02:12'),
(121, 'marielrequina', '09123567890', '2024-10-14 12:03:37'),
(122, 'marielrequina', '09123456789', '2024-10-14 12:25:09'),
(123, 'Jay', '09606491454', '2024-10-15 03:52:59'),
(124, 'asd', '09606491454', '2024-10-15 03:56:06'),
(125, 'dsasd', '09606491454', '2024-10-15 03:58:59'),
(126, 'Jay', '09606391454', '2024-10-20 03:27:53'),
(127, 'Jay', '09606491454', '2024-10-20 10:22:39'),
(128, 'Juay', '09606491454', '2024-10-20 11:43:25'),
(129, 'pucii', '09312334234', '2024-10-20 11:50:10'),
(130, 'saddas', '09606491454', '2024-10-20 13:19:41'),
(131, 'sad', '09606491454', '2024-10-20 13:45:34'),
(132, 'dssd', '09606491454', '2024-10-20 16:43:49'),
(133, 'dsf', '09606491454', '2024-10-20 16:45:26'),
(134, 'fdsf', '09606491454', '2024-10-20 16:48:16'),
(135, 'Maying', '09123456789', '2024-11-26 23:54:06'),
(136, 'Maying', '09123456789', '2024-11-26 23:57:11'),
(137, 'mayi', '09123456789', '2024-11-27 00:24:44'),
(138, 'as', '09123456789', '2024-11-30 22:05:26'),
(139, 'Mariel', '09123456789', '2024-11-30 22:07:47'),
(140, 'Mari', '09091234567', '2024-11-30 22:14:24'),
(141, 'as', '09123456789', '2024-11-30 22:37:46'),
(142, 'as', '09123456789', '2024-11-30 23:29:45'),
(143, 'as', '09123456789', '2024-12-01 00:23:26'),
(144, 'Mariel', '09123456789', '2024-12-01 02:31:50');

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `product_id` int(11) NOT NULL,
  `order_quantity` int(11) NOT NULL,
  `total_cost` decimal(10,2) NOT NULL,
  `order_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `id` int(11) DEFAULT NULL,
  `supplier_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expenses`
--

INSERT INTO `expenses` (`product_id`, `order_quantity`, `total_cost`, `order_date`, `id`, `supplier_id`) VALUES
(1, 1, 47.00, '2024-10-12 07:00:53', 0, NULL),
(1, 1, 47.00, '2024-10-12 07:00:55', 0, NULL),
(1, 1, 47.00, '2024-10-12 07:01:21', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:04:13', 0, NULL),
(1, 1, 47.00, '2024-10-12 07:10:01', 0, NULL),
(1, 1, 47.00, '2024-10-12 07:10:02', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:11:13', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:11:13', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:11:14', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:11:14', 0, NULL),
(3, 1, 49.00, '2024-10-12 07:13:35', 0, NULL),
(3, 1, 49.00, '2024-10-12 07:13:36', 0, NULL),
(3, 1, 49.00, '2024-10-12 07:13:36', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:19:37', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:19:37', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:19:38', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:30:40', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:30:41', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:30:41', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:30:41', 0, NULL),
(3, 1, 49.00, '2024-10-12 07:31:49', 0, NULL),
(3, 1, 49.00, '2024-10-12 07:31:50', 0, NULL),
(3, 1, 49.00, '2024-10-12 07:31:50', 0, NULL),
(3, 1, 49.00, '2024-10-12 07:31:50', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:44:46', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:44:46', 0, NULL),
(2, 1, 52.00, '2024-10-12 07:44:47', 0, NULL),
(3, 1, 49.00, '2024-10-12 07:48:12', 0, NULL),
(3, 1, 49.00, '2024-10-12 07:48:13', 0, NULL),
(3, 1, 49.00, '2024-10-12 07:48:13', 0, NULL),
(3, 1, 49.00, '2024-10-12 07:50:15', 0, NULL),
(3, 1, 49.00, '2024-10-12 07:50:16', 0, NULL),
(3, 1, 49.00, '2024-10-12 07:50:16', 0, NULL),
(2, 1, 52.00, '2024-10-12 08:26:40', 0, NULL),
(2, 1, 52.00, '2024-10-12 08:26:40', 0, NULL),
(2, 1, 52.00, '2024-10-12 08:26:40', 0, NULL),
(3, 1, 49.00, '2024-10-12 08:39:00', 0, NULL),
(3, 1, 49.00, '2024-10-12 08:39:01', 0, NULL),
(3, 1, 49.00, '2024-10-12 08:39:01', 0, NULL),
(3, 1, 49.00, '2024-10-12 08:48:12', 0, NULL),
(3, 1, 49.00, '2024-10-12 08:48:12', 0, NULL),
(3, 1, 49.00, '2024-10-12 08:48:13', 0, NULL),
(3, 1, 49.00, '2024-10-12 08:53:02', 0, NULL),
(3, 1, 49.00, '2024-10-12 08:53:02', 0, NULL),
(3, 1, 49.00, '2024-10-12 08:57:25', 0, NULL),
(3, 1, 49.00, '2024-10-12 08:57:25', 0, NULL),
(3, 1, 49.00, '2024-10-12 09:02:27', 0, NULL),
(3, 1, 49.00, '2024-10-12 09:02:29', 0, NULL),
(1, 1, 47.00, '2024-10-12 09:06:33', 0, NULL),
(1, 1, 47.00, '2024-10-12 09:06:33', 0, NULL),
(3, 1, 49.00, '2024-10-12 09:13:11', 0, NULL),
(3, 1, 49.00, '2024-10-12 09:13:12', 0, NULL),
(1, 1, 47.00, '2024-10-12 15:20:50', 0, NULL),
(1, 1, 47.00, '2024-10-12 15:20:50', 0, NULL),
(2, 1, 52.00, '2024-10-12 15:21:15', 0, NULL),
(2, 1, 52.00, '2024-10-12 15:21:15', 0, NULL),
(2, 1, 52.00, '2024-10-12 15:26:21', 0, NULL),
(2, 1, 52.00, '2024-10-12 15:26:23', 0, NULL),
(3, 1, 49.00, '2024-10-12 15:26:37', 0, NULL),
(3, 1, 49.00, '2024-10-12 15:26:38', 0, NULL),
(3, 1, 49.00, '2024-10-12 15:26:39', 0, NULL),
(1, 1, 47.00, '2024-10-12 15:34:27', 0, NULL),
(1, 1, 47.00, '2024-10-12 15:34:27', 0, NULL),
(1, 1, 47.00, '2024-10-12 15:34:29', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:07:28', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:07:29', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:07:30', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:07:39', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:21:21', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:21:22', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:21:22', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:21:24', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:21:31', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:21:32', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:21:32', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:21:43', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:21:43', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:21:44', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:26:53', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:26:54', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:26:56', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:27:09', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:27:09', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:27:10', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:27:10', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:27:22', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:27:22', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:27:22', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:27:23', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:28:54', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:28:55', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:28:55', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:29:05', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:29:05', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:29:05', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:29:05', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:09', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:09', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:09', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:10', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:23', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:23', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:23', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:38', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:38', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:39', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:50', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:51', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:51', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:31:51', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:32:19', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:32:20', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:37:42', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:37:42', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:37:43', 0, NULL),
(1, 1, 47.00, '2024-10-12 22:37:43', 0, NULL),
(1, 1, 47.00, '2024-10-13 00:02:36', 0, NULL),
(1, 1, 47.00, '2024-10-13 00:02:39', 0, NULL),
(1, 1, 47.00, '2024-10-13 00:03:07', 0, NULL),
(1, 1, 47.00, '2024-10-13 00:03:21', 0, NULL),
(1, 1, 47.00, '2024-10-13 04:02:41', 0, NULL),
(1, 1, 47.00, '2024-10-13 04:02:41', 0, NULL),
(1, 1, 47.00, '2024-10-13 04:11:02', 0, NULL),
(1, 1, 47.00, '2024-10-13 04:11:13', 0, NULL),
(1, 1, 47.00, '2024-10-13 04:11:14', 0, NULL),
(1, 1, 47.00, '2024-10-13 04:11:14', 0, NULL),
(1, 1, 47.00, '2024-10-13 04:11:17', 0, NULL),
(1, 1, 47.00, '2024-10-13 04:12:01', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:12:01', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:12:02', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:12:05', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:12:06', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:13:17', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:17:14', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:17:16', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:17:18', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:17:22', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:17:24', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:17:26', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:17:34', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:18:17', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:18:20', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:19:24', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:19:26', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:20:12', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:20:15', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:20:27', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:22:08', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:22:10', NULL, NULL),
(1, 10, 470.00, '2024-10-13 04:22:36', NULL, NULL),
(1, 10, 470.00, '2024-10-13 04:22:38', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:22:42', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:22:43', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:22:44', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:22:45', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:22:47', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:22:50', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:22:52', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:24:56', NULL, NULL),
(1, 1, 47.00, '2024-10-13 04:24:58', NULL, NULL),
(2, 1, 52.00, '2024-10-13 04:25:00', NULL, NULL),
(2, 1, 52.00, '2024-10-13 04:25:03', NULL, NULL),
(2, 1, 52.00, '2024-10-13 04:25:05', NULL, NULL),
(1, 10, 470.00, '2024-10-14 05:03:46', NULL, NULL),
(1, 1, 47.00, '2024-10-14 05:35:18', NULL, NULL),
(1, 1, 47.00, '2024-10-14 05:35:30', NULL, NULL),
(1, 1, 47.00, '2024-10-14 05:35:30', NULL, NULL),
(1, 1, 47.00, '2024-10-14 05:37:24', NULL, NULL),
(1, 1, 47.00, '2024-10-14 05:37:24', NULL, NULL),
(1, 1, 47.00, '2024-10-14 05:37:24', NULL, NULL),
(1, 1, 47.00, '2024-10-14 05:37:26', NULL, NULL),
(1, 1, 47.00, '2024-10-14 05:37:26', NULL, NULL),
(1, 1, 47.00, '2024-10-14 05:56:49', NULL, NULL),
(1, 2, 94.00, '2024-10-14 04:22:00', NULL, NULL),
(1, 2, 94.00, '2024-10-14 04:22:26', NULL, NULL),
(1, 1, 47.00, '2024-10-14 04:22:35', NULL, NULL),
(2, 3, 156.00, '2024-10-14 04:24:07', NULL, NULL),
(2, 5, 260.00, '2024-10-14 04:24:16', NULL, NULL),
(3, 2, 98.00, '2024-10-14 04:24:26', NULL, NULL),
(2, 10, 520.00, '2024-10-14 04:25:42', NULL, NULL),
(1, 1, 47.00, '2024-10-14 19:54:55', NULL, NULL),
(1, 1, 47.00, '2024-10-14 19:55:42', NULL, NULL),
(1, 10, 470.00, '2024-10-19 19:28:31', NULL, NULL),
(31, 10, 900.00, '2024-10-20 01:48:33', NULL, NULL),
(31, 1, 90.00, '2024-10-20 01:51:04', NULL, NULL),
(31, 1, 90.00, '2024-10-20 01:51:44', NULL, NULL),
(31, 10, 900.00, '2024-10-20 01:52:15', NULL, NULL),
(30, 10, 900.00, '2024-10-20 01:53:00', NULL, NULL);

--
-- Triggers `expenses`
--
DELIMITER $$
CREATE TRIGGER `update_inventory_supplier` AFTER INSERT ON `expenses` FOR EACH ROW BEGIN
    -- Increase quantity in the inventory table
    UPDATE inventory
    SET quantity = quantity + NEW.order_quantity,
        stock_supply = stock_supply - NEW.order_quantity -- Deduct stock supply
    WHERE id = NEW.product_id;

    -- Deduct stock supply from the suppliers table
    UPDATE suppliers
    SET stock_supply = stock_supply - NEW.order_quantity
    WHERE id = (SELECT supplier_id FROM inventory WHERE id = NEW.product_id);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `financial_summary`
--

CREATE TABLE `financial_summary` (
  `id` int(11) NOT NULL,
  `summary_date` date NOT NULL,
  `category` enum('daily','weekly','monthly','yearly') NOT NULL,
  `summary_name` varchar(50) NOT NULL,
  `total_sales` decimal(10,2) NOT NULL,
  `total_expenses` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `financial_summary`
--

INSERT INTO `financial_summary` (`id`, `summary_date`, `category`, `summary_name`, `total_sales`, `total_expenses`, `created_at`) VALUES
(7, '2024-10-19', '', 'Daily Summary', 570.00, 3350.00, '2024-10-20 13:49:06'),
(8, '2024-10-13', '', 'Weekly Summary', 3230.00, 2162.00, '2024-10-20 13:49:06'),
(9, '2024-09-20', '', 'Monthly Summary', 1810.00, 1652.00, '2024-10-20 13:49:06'),
(10, '2023-10-20', '', 'Yearly Summary', 1810.00, 1652.00, '2024-10-20 13:49:06'),
(11, '2024-10-19', '', 'Daily Summary', 570.00, 3350.00, '2024-10-20 14:01:06'),
(12, '2024-10-13', '', 'Weekly Summary', 3230.00, 2162.00, '2024-10-20 14:01:06'),
(13, '2024-09-20', '', 'Monthly Summary', 1810.00, 1652.00, '2024-10-20 14:01:06'),
(14, '2023-10-20', '', 'Yearly Summary', 1810.00, 1652.00, '2024-10-20 14:01:06'),
(15, '2024-10-19', '', 'Daily Summary', 570.00, 3350.00, '2024-10-20 14:03:11'),
(16, '2024-10-13', '', 'Weekly Summary', 3230.00, 2162.00, '2024-10-20 14:03:11'),
(17, '2024-09-20', '', 'Monthly Summary', 1810.00, 1652.00, '2024-10-20 14:03:11'),
(18, '2023-10-20', '', 'Yearly Summary', 1810.00, 1652.00, '2024-10-20 14:03:11'),
(19, '2024-10-19', '', 'Daily Summary', 570.00, 3350.00, '2024-10-20 14:03:28'),
(20, '2024-10-13', '', 'Weekly Summary', 3230.00, 2162.00, '2024-10-20 14:03:28'),
(21, '2024-09-20', '', 'Monthly Summary', 1810.00, 1652.00, '2024-10-20 14:03:28'),
(22, '2023-10-20', '', 'Yearly Summary', 1810.00, 1652.00, '2024-10-20 14:03:28'),
(23, '2024-10-19', '', 'Daily Summary', 570.00, 3350.00, '2024-10-20 16:20:43'),
(24, '2024-10-13', '', 'Weekly Summary', 3230.00, 2162.00, '2024-10-20 16:20:43'),
(25, '2024-09-20', '', 'Monthly Summary', 1810.00, 3178.00, '2024-10-20 16:20:43'),
(26, '2023-10-20', '', 'Yearly Summary', 1810.00, 3178.00, '2024-10-20 16:20:43'),
(27, '2024-11-15', '', 'Daily Summary', 0.00, 0.00, '2024-11-16 01:25:38'),
(28, '2024-11-09', '', 'Weekly Summary', 0.00, 0.00, '2024-11-16 01:25:38'),
(29, '2024-10-16', '', 'Monthly Summary', 570.00, 3350.00, '2024-11-16 01:25:38'),
(30, '2023-11-16', '', 'Yearly Summary', 1810.00, 3178.00, '2024-11-16 01:25:38'),
(31, '2024-11-26', '', 'Daily Summary', 120.00, 0.00, '2024-11-26 23:55:38'),
(32, '2024-11-20', '', 'Weekly Summary', 120.00, 0.00, '2024-11-26 23:55:38'),
(33, '2024-10-27', '', 'Monthly Summary', 120.00, 0.00, '2024-11-26 23:55:38'),
(34, '2023-11-27', '', 'Yearly Summary', 1810.00, 3178.00, '2024-11-26 23:55:38');

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE `inventory` (
  `id` int(11) NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `raw_material_cost` decimal(10,2) NOT NULL,
  `labor_cost` decimal(10,2) NOT NULL,
  `overhead_cost` decimal(10,2) NOT NULL,
  `packaging_cost` decimal(10,2) NOT NULL,
  `total_cost` decimal(10,2) GENERATED ALWAYS AS (`raw_material_cost` + `labor_cost` + `overhead_cost` + `packaging_cost`) STORED,
  `price` decimal(10,2) NOT NULL,
  `quantity` int(11) DEFAULT 50,
  `stock_supply` int(11) DEFAULT 100,
  `supplier_id` int(11) DEFAULT NULL,
  `is_new` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inventory`
--

INSERT INTO `inventory` (`id`, `product_name`, `raw_material_cost`, `labor_cost`, `overhead_cost`, `packaging_cost`, `price`, `quantity`, `stock_supply`, `supplier_id`, `is_new`) VALUES
(1, 'Classic Milk Tea', 30.00, 10.00, 5.00, 2.00, 100.00, 10, 100, NULL, 0),
(2, 'Brown Sugar Milk Tea', 35.00, 10.00, 5.00, 2.00, 120.00, 111, 100, NULL, 0),
(3, 'Taro Milk Tea', 32.00, 10.00, 5.00, 2.00, 110.00, 101, 100, NULL, 0),
(4, 'Wintermelon Milk Tea', 34.00, 10.00, 5.00, 2.00, 115.00, 100, 100, NULL, 0),
(5, 'Matcha Milk Tea', 38.00, 10.00, 5.00, 2.00, 130.00, 50, 100, NULL, 0),
(6, 'Okinawa Milk Tea', 36.00, 10.00, 5.00, 2.00, 125.00, 50, 100, NULL, 0),
(7, 'Hokkaido Milk Tea', 35.00, 10.00, 5.00, 2.00, 120.00, 50, 100, NULL, 0),
(8, 'Thai Milk Tea', 32.00, 10.00, 5.00, 2.00, 110.00, 50, 100, NULL, 0),
(9, 'Chocolate Milk Tea', 31.00, 10.00, 5.00, 2.00, 105.00, 50, 100, NULL, 0),
(10, 'Jasmine Milk Tea', 34.00, 10.00, 5.00, 2.00, 115.00, 50, 100, NULL, 0),
(11, 'Espresso', 20.00, 10.00, 5.00, 1.00, 80.00, 45, 100, NULL, 0),
(12, 'Americano', 18.00, 10.00, 5.00, 1.00, 90.00, 49, 100, NULL, 0),
(13, 'Cappuccino', 30.00, 10.00, 5.00, 2.00, 120.00, 41, 100, NULL, 0),
(14, 'Latte', 30.00, 10.00, 5.00, 2.00, 130.00, 46, 100, NULL, 0),
(15, 'Mocha', 35.00, 10.00, 5.00, 2.00, 140.00, 50, 100, NULL, 0),
(16, 'Macchiato', 33.00, 10.00, 5.00, 2.00, 135.00, 50, 100, NULL, 0),
(17, 'Caramel Latte', 37.00, 10.00, 5.00, 2.00, 145.00, 50, 100, NULL, 0),
(18, 'Flat White', 34.00, 10.00, 5.00, 2.00, 125.00, 51, 100, NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `login_logs`
--

CREATE TABLE `login_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `login_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `login_logs`
--

INSERT INTO `login_logs` (`id`, `user_id`, `login_time`) VALUES
(1, 3, '2024-09-29 14:20:27'),
(2, 4, '2024-09-29 14:21:13'),
(3, 4, '2024-09-29 14:23:14'),
(4, 6, '2024-09-29 15:48:37'),
(5, 6, '2024-09-29 16:25:05'),
(6, 7, '2024-09-30 02:37:28'),
(7, 6, '2024-09-30 02:45:14'),
(8, 6, '2024-09-30 06:24:36'),
(9, 6, '2024-10-02 22:25:09'),
(10, 6, '2024-10-03 10:46:15'),
(11, 6, '2024-10-03 10:47:30'),
(12, 6, '2024-10-04 00:33:31'),
(13, 6, '2024-10-04 06:09:24'),
(14, 6, '2024-10-04 06:10:27'),
(15, 6, '2024-10-04 06:20:19'),
(16, 6, '2024-10-04 09:05:03'),
(17, 6, '2024-10-04 09:05:42'),
(18, 6, '2024-10-04 09:15:08'),
(19, 6, '2024-10-07 10:55:03'),
(20, 6, '2024-10-07 10:57:46'),
(21, 6, '2024-10-07 11:01:43'),
(22, 6, '2024-10-07 11:05:56'),
(23, 6, '2024-10-07 11:50:48'),
(24, 6, '2024-10-08 09:26:41'),
(25, 6, '2024-10-08 13:38:51'),
(26, 6, '2024-10-10 05:41:11'),
(27, 9, '2024-10-10 05:49:22'),
(28, 6, '2024-10-10 06:13:44'),
(29, 10, '2024-10-10 17:04:21'),
(30, 10, '2024-10-10 17:28:24'),
(31, 10, '2024-10-11 03:17:29'),
(32, 10, '2024-10-11 14:37:54'),
(33, 10, '2024-10-12 12:36:51'),
(34, 10, '2024-10-12 12:46:31'),
(35, 10, '2024-10-12 12:58:36'),
(36, 12, '2024-10-12 13:08:36'),
(37, 10, '2024-10-12 13:21:22'),
(38, 10, '2024-10-12 23:19:49'),
(39, 10, '2024-10-13 06:03:36'),
(40, 10, '2024-10-13 07:27:52'),
(41, 10, '2024-10-13 08:17:44'),
(42, 10, '2024-10-13 08:17:48'),
(43, 10, '2024-10-13 08:17:52'),
(44, 10, '2024-10-13 08:18:01'),
(45, 10, '2024-10-13 08:18:06'),
(46, 10, '2024-10-13 08:18:09'),
(47, 10, '2024-10-13 08:18:14'),
(48, 10, '2024-10-13 08:19:16'),
(49, 10, '2024-10-13 08:19:19'),
(50, 10, '2024-10-13 08:20:05'),
(51, 10, '2024-10-13 10:52:21'),
(52, 10, '2024-10-13 12:26:25'),
(53, 10, '2024-10-14 12:52:02'),
(54, 6, '2024-10-14 12:03:04'),
(55, 10, '2024-10-15 03:16:53'),
(56, 10, '2024-10-15 03:48:30'),
(57, 13, '2024-10-15 03:49:14'),
(58, 10, '2024-10-15 03:52:33'),
(59, 10, '2024-10-15 03:57:30'),
(60, 10, '2024-10-20 03:06:18'),
(61, 14, '2024-10-20 03:07:33'),
(62, 15, '2024-10-20 03:08:11'),
(63, 16, '2024-11-16 00:43:03'),
(64, 16, '2024-11-16 08:32:41'),
(65, 17, '2024-11-17 13:58:58'),
(66, 18, '2024-11-26 03:06:19'),
(67, 18, '2024-11-26 07:02:07'),
(68, 18, '2024-11-26 10:55:05'),
(69, 18, '2024-11-26 23:43:14'),
(70, 18, '2024-11-30 00:31:39'),
(71, 18, '2024-11-30 11:00:51');

-- --------------------------------------------------------

--
-- Table structure for table `payment`
--

CREATE TABLE `payment` (
  `paymentID` int(11) NOT NULL,
  `amount_pay` decimal(10,2) NOT NULL,
  `paymentDate` date NOT NULL,
  `purchaseID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `product_name` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `images` varchar(255) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `product_name`, `price`, `type`, `description`, `images`, `quantity`) VALUES
(1, 'Classic Milk Tea', 100.00, 'milktea', NULL, 'images/milk_tea.jpg', NULL),
(2, 'Brown Sugar Milk Tea', 120.00, 'milktea', NULL, 'images/brown_sugar_milk_tea.jpg', NULL),
(3, 'Taro Milk Tea', 110.00, 'milktea', NULL, 'images/taro_milk_tea.jpg', NULL),
(4, 'Wintermelon Milk Tea', 115.00, 'milktea', NULL, 'images/wintermelon_milk_tea.jpg', NULL),
(5, 'Matcha Milk Tea', 130.00, 'milktea', NULL, 'images/matcha_milk_tea.jpg', NULL),
(6, 'Okinawa Milk Tea', 125.00, 'milktea', NULL, 'images/okinawa_milk_tea.jpg', NULL),
(7, 'Hokkaido Milk Tea', 120.00, 'milktea', NULL, 'images/hokkaido_milk_tea.jpg', NULL),
(8, 'Thai Milk Tea', 110.00, 'milktea', NULL, 'images/thai_milk_tea.jpg', NULL),
(9, 'Chocolate Milk Tea', 105.00, 'milktea', NULL, 'images/chocolate_milk_tea.jpg', NULL),
(10, 'Jasmine Milk Tea', 115.00, 'milktea', NULL, 'images/jasmine_milk_tea.jpg', NULL),
(11, 'Espresso', 80.00, 'coffee', NULL, 'images/espresso.jpg', NULL),
(12, 'Americano', 90.00, 'coffee', NULL, 'images/americano.jpg', NULL),
(13, 'Cappuccino', 120.00, 'coffee', NULL, 'images/cappuccino.jpg', NULL),
(14, 'Latte', 130.00, 'coffee', NULL, 'images/latte.jpg', NULL),
(15, 'Mocha', 140.00, 'coffee', NULL, 'images/mocha.jpg', NULL),
(16, 'Macchiato', 135.00, 'coffee', NULL, 'images/macchiato.jpg', NULL),
(17, 'Caramel Latte', 145.00, 'coffee', NULL, 'images/caramel_latte.jpg', NULL),
(18, 'Flat White', 125.00, 'coffee', NULL, 'images/flat_white.jpg', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `purchases`
--

CREATE TABLE `purchases` (
  `purchaseID` int(11) NOT NULL,
  `customerID` int(11) NOT NULL,
  `item_name` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL,
  `purchase_date` datetime DEFAULT current_timestamp(),
  `price` decimal(10,2) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `purchases`
--

INSERT INTO `purchases` (`purchaseID`, `customerID`, `item_name`, `quantity`, `purchase_date`, `price`, `total_amount`) VALUES
(76, 68, 'Cappuccino', 1, '2024-10-11 16:03:26', 120.00, 120.00),
(77, 69, 'Americano', 1, '2024-10-11 16:11:51', 90.00, 90.00),
(78, 70, 'Cappuccino', 1, '2024-10-11 22:53:26', 120.00, 120.00),
(79, 71, 'Americano', 1, '2024-10-11 23:17:01', 90.00, 90.00),
(80, 72, 'Latte', 1, '2024-10-11 23:20:09', 130.00, 130.00),
(81, 73, 'Cappuccino', 1, '2024-10-11 23:22:46', 120.00, 120.00),
(82, 74, 'Latte', 1, '2024-10-11 23:25:31', 130.00, 130.00),
(83, 75, 'Latte', 1, '2024-10-11 23:26:08', 130.00, 130.00),
(84, 76, 'Cappuccino', 1, '2024-10-11 23:32:30', 120.00, 120.00),
(85, 76, 'Americano', 1, '2024-10-11 23:32:30', 90.00, 90.00),
(86, 77, 'Cappuccino', 1, '2024-10-11 23:43:14', 120.00, 120.00),
(87, 77, 'Americano', 1, '2024-10-11 23:43:14', 90.00, 90.00),
(88, 77, 'Espresso', 1, '2024-10-11 23:43:14', 80.00, 80.00),
(89, 78, 'Latte', 1, '2024-10-11 23:44:50', 130.00, 130.00),
(90, 79, 'Cappuccino', 1, '2024-10-11 23:57:36', 120.00, 120.00),
(91, 80, 'Latte', 1, '2024-10-11 23:58:05', 130.00, 130.00),
(92, 81, 'Cappuccino', 1, '2024-10-12 00:09:11', 120.00, 120.00),
(93, 82, 'Cappuccino', 1, '2024-10-12 00:10:21', 120.00, 120.00),
(94, 83, 'Latte', 1, '2024-10-12 00:10:31', 130.00, 130.00),
(95, 84, 'Cappuccino', 1, '2024-10-12 00:11:58', 120.00, 120.00),
(96, 85, 'Espresso', 1, '2024-10-12 00:12:08', 80.00, 80.00),
(97, 86, 'Macchiato', 1, '2024-10-12 00:14:18', 135.00, 135.00),
(98, 87, 'Americano', 1, '2024-10-12 00:16:28', 90.00, 90.00),
(99, 88, 'Cappuccino', 1, '2024-10-12 00:16:46', 120.00, 120.00),
(100, 89, 'Espresso', 1, '2024-10-12 00:21:02', 80.00, 80.00),
(101, 90, 'Macchiato', 1, '2024-10-12 00:21:19', 135.00, 135.00),
(102, 91, 'Americano', 1, '2024-10-12 00:29:45', 90.00, 90.00),
(103, 92, 'Americano', 1, '2024-10-12 00:31:04', 90.00, 90.00),
(104, 93, 'Latte', 1, '2024-10-12 00:31:21', 130.00, 130.00),
(105, 94, 'Latte', 1, '2024-10-12 00:31:27', 130.00, 130.00),
(106, 95, 'Espresso', 1, '2024-10-12 01:21:32', 80.00, 80.00),
(107, 96, 'Americano', 1, '2024-10-12 01:22:49', 90.00, 90.00),
(108, 97, 'Cappuccino', 1, '2024-10-12 22:22:59', 120.00, 120.00),
(109, 98, 'Cappuccino', 1, '2024-10-12 22:23:24', 120.00, 120.00),
(110, 99, 'Latte', 1, '2024-10-13 00:56:00', 130.00, 130.00),
(111, 100, 'Brown Sugar Milk Tea', 1, '2024-10-13 07:20:20', 120.00, 120.00),
(112, 101, 'Cappuccino', 1, '2024-10-13 07:53:19', 120.00, 120.00),
(113, 102, 'Americano', 1, '2024-10-13 07:58:19', 90.00, 90.00),
(114, 103, 'Cappuccino', 1, '2024-10-13 08:11:52', 120.00, 120.00),
(115, 104, 'Cappuccino', 1, '2024-10-13 08:15:16', 120.00, 120.00),
(116, 105, 'Classic Milk Tea', 1, '2024-10-13 08:24:30', 100.00, 100.00),
(117, 106, 'Classic Milk Tea', 1, '2024-10-13 08:25:41', 100.00, 100.00),
(118, 107, 'Classic Milk Tea', 1, '2024-10-13 08:27:48', 100.00, 100.00),
(119, 108, 'Classic Milk Tea', 1, '2024-10-13 08:28:06', 100.00, 100.00),
(120, 109, 'Classic Milk Tea', 1, '2024-10-13 14:03:54', 100.00, 100.00),
(121, 110, 'Classic Milk Tea', 10, '2024-10-13 14:36:57', 100.00, 1000.00),
(122, 111, 'Classic Milk Tea', 10, '2024-10-13 14:37:24', 100.00, 1000.00),
(123, 112, 'Latte', 1, '2024-10-13 16:20:17', 130.00, 130.00),
(124, 113, 'Cappuccino', 1, '2024-10-13 19:27:36', 120.00, 120.00),
(125, 114, 'Classic Milk Tea', 10, '2024-10-13 20:12:23', 100.00, 1000.00),
(126, 115, 'Classic Milk Tea', 10, '2024-10-13 20:13:07', 100.00, 1000.00),
(127, 116, 'Classic Milk Tea', 2, '2024-10-14 20:52:53', 100.00, 200.00),
(128, 117, 'Classic Milk Tea', 6, '2024-10-14 21:36:44', 100.00, 600.00),
(129, 119, 'Classic Milk Tea', 1, '2024-10-14 21:48:45', 100.00, 100.00),
(130, 120, 'Classic Milk Tea', 9, '2024-10-14 22:02:12', 100.00, 900.00),
(131, 121, 'Cappuccino', 1, '2024-10-14 20:03:37', 120.00, 120.00),
(132, 121, 'Taro Milk Tea', 1, '2024-10-14 20:03:37', 110.00, 110.00),
(133, 122, 'Brown Sugar Milk Tea', 10, '2024-10-14 20:25:09', 120.00, 1200.00),
(134, 123, 'Espresso', 1, '2024-10-15 11:52:59', 80.00, 80.00),
(135, 124, 'Classic Milk Tea', 1, '2024-10-15 11:56:06', 100.00, 100.00),
(136, 125, 'Classic Milk Tea', 1, '2024-10-15 11:58:59', 100.00, 100.00),
(137, 127, 'Espresso', 1, '2024-10-20 18:22:39', 80.00, 80.00),
(138, 128, 'Cappuccino', 1, '2024-10-20 19:43:25', 120.00, 120.00),
(139, 129, 'Cappuccino', 1, '2024-10-20 19:50:10', 120.00, 120.00),
(140, 130, 'Cappuccino', 1, '2024-10-20 21:19:41', 120.00, 120.00),
(141, 131, 'Latte', 1, '2024-10-20 21:45:34', 130.00, 130.00),
(142, 144, 'Espresso', 1, '2024-12-01 10:31:50', 80.00, 80.00),
(143, 144, 'Americano', 1, '2024-12-01 10:31:50', 90.00, 90.00),
(144, 144, 'Cappuccino', 1, '2024-12-01 10:31:50', 120.00, 120.00);

--
-- Triggers `purchases`
--
DELIMITER $$
CREATE TRIGGER `deduct_inventory_quantity` AFTER INSERT ON `purchases` FOR EACH ROW BEGIN
    UPDATE inventory
    SET quantity = quantity - NEW.quantity
    WHERE id = NEW.purchaseID;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `receipts`
--

CREATE TABLE `receipts` (
  `id` int(11) NOT NULL,
  `customerID` int(11) NOT NULL,
  `item_name` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `order_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `receipts`
--

INSERT INTO `receipts` (`id`, `customerID`, `item_name`, `quantity`, `price`, `total_amount`, `order_date`) VALUES
(13, 68, 'Cappuccino', 1, 120.00, 120.00, '2024-10-11 08:03:27'),
(14, 69, 'Americano', 1, 90.00, 90.00, '2024-10-11 08:11:52'),
(15, 70, 'Cappuccino', 1, 120.00, 120.00, '2024-10-11 14:53:28'),
(16, 71, 'Americano', 1, 90.00, 90.00, '2024-10-11 15:17:02'),
(17, 72, 'Latte', 1, 130.00, 130.00, '2024-10-11 15:20:10'),
(18, 73, 'Cappuccino', 1, 120.00, 120.00, '2024-10-11 15:22:47'),
(19, 74, 'Latte', 1, 130.00, 130.00, '2024-10-11 15:25:32'),
(20, 75, 'Latte', 1, 130.00, 130.00, '2024-10-11 15:26:09'),
(21, 76, 'Cappuccino', 1, 120.00, 120.00, '2024-10-11 15:32:31'),
(22, 76, 'Americano', 1, 90.00, 90.00, '2024-10-11 15:32:31'),
(23, 77, 'Cappuccino', 1, 120.00, 120.00, '2024-10-11 15:43:15'),
(24, 77, 'Americano', 1, 90.00, 90.00, '2024-10-11 15:43:15'),
(25, 77, 'Espresso', 1, 80.00, 80.00, '2024-10-11 15:43:15'),
(26, 78, 'Latte', 1, 130.00, 130.00, '2024-10-11 15:44:53'),
(27, 79, 'Cappuccino', 1, 120.00, 120.00, '2024-10-11 15:57:37'),
(28, 80, 'Latte', 1, 130.00, 130.00, '2024-10-11 15:58:07'),
(29, 81, 'Cappuccino', 1, 120.00, 120.00, '2024-10-11 16:09:19'),
(30, 82, 'Cappuccino', 1, 120.00, 120.00, '2024-10-11 16:10:21'),
(31, 83, 'Latte', 1, 130.00, 130.00, '2024-10-11 16:10:31'),
(32, 84, 'Cappuccino', 1, 120.00, 120.00, '2024-10-11 16:11:58'),
(33, 85, 'Espresso', 1, 80.00, 80.00, '2024-10-11 16:12:08'),
(34, 86, 'Macchiato', 1, 135.00, 135.00, '2024-10-11 16:14:19'),
(35, 87, 'Americano', 1, 90.00, 90.00, '2024-10-11 16:16:28'),
(36, 88, 'Cappuccino', 1, 120.00, 120.00, '2024-10-11 16:16:46'),
(37, 89, 'Espresso', 1, 80.00, 80.00, '2024-10-11 16:21:02'),
(38, 90, 'Macchiato', 1, 135.00, 135.00, '2024-10-11 16:21:19'),
(39, 94, 'Latte', 1, 130.00, 130.00, '2024-10-11 16:32:11'),
(40, 95, 'Espresso', 1, 80.00, 80.00, '2024-10-11 17:21:32'),
(41, 96, 'Americano', 1, 90.00, 90.00, '2024-10-11 17:22:49');

-- --------------------------------------------------------

--
-- Table structure for table `staff`
--

CREATE TABLE `staff` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `staff`
--

INSERT INTO `staff` (`id`, `username`, `email`, `password`, `created_at`) VALUES
(15, 'meljay', 'sayaw@gmail.com', '$2y$10$eUreSCIFc5YSc01mbFFKLuWmy/GlKACtrT32aZvlDF7SAtUVAUVga', '2024-10-20 03:08:05'),
(16, 'mariel', 'mari@gmail.com', '$2y$10$9Uu/nLhKC4399Z7dLl8Tue2/DJ94YfgdZuWYTa5Dkl4y7dyLd3lvi', '2024-11-16 00:43:01'),
(17, 'mariel123', 'marie@gmail.com', '$2y$10$64laqTN3A1Pzf8NhlTjMA.abbolIdw9AiaK1u/.2Dg6hT1ZOxDh.O', '2024-11-17 13:56:24'),
(18, 'marielrequina', 'mr@gmail.com', '$2y$10$JEDmPtjCLl50RHavcwKd4.SOcWomH45T852tW8dP.XKUnH2TyPKEy', '2024-11-26 03:06:11');

-- --------------------------------------------------------

--
-- Table structure for table `store`
--

CREATE TABLE `store` (
  `storeID` int(11) NOT NULL,
  `name_store` varchar(200) NOT NULL,
  `location_store` varchar(200) NOT NULL,
  `contactNo` varchar(15) DEFAULT NULL,
  `opening_hours` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `supplier_name` varchar(100) NOT NULL,
  `stock_supply` int(11) DEFAULT 100
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`id`, `product_id`, `supplier_name`, `stock_supply`) VALUES
(1, 1, 'Supplier A', -1954),
(2, 2, 'Supplier B', 72),
(3, 3, 'Supplier C', 76),
(4, 4, 'Supplier D', 100),
(5, 5, 'Supplier E', 100),
(6, 6, 'Supplier F', 100),
(7, 7, 'Supplier G', 100),
(8, 8, 'Supplier H', 100),
(9, 9, 'Supplier I', 100),
(10, 10, 'Supplier J', 100),
(11, 11, 'Supplier K', 100),
(12, 12, 'Supplier L', 100),
(13, 13, 'Supplier M', 100),
(14, 14, 'Supplier N', 100),
(15, 15, 'Supplier O', 100),
(16, 16, 'Supplier P', 100),
(17, 17, 'Supplier Q', 100),
(18, 18, 'Supplier R', 100);

-- --------------------------------------------------------

--
-- Table structure for table `total_expense`
--

CREATE TABLE `total_expense` (
  `id` int(11) NOT NULL,
  `expenses` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `total_expense`
--

INSERT INTO `total_expense` (`id`, `expenses`, `created_at`) VALUES
(8, 0.00, '2024-10-12 15:15:06'),
(9, 2490.00, '2024-10-12 17:12:55'),
(10, 2588.00, '2024-10-12 17:13:15'),
(11, 2588.00, '2024-10-12 17:14:06'),
(12, 2786.00, '2024-10-12 23:21:31'),
(13, 2786.00, '2024-10-12 23:21:53'),
(14, 3037.00, '2024-10-12 23:26:47'),
(15, 3037.00, '2024-10-12 23:26:48'),
(16, 3037.00, '2024-10-12 23:34:21'),
(17, 3178.00, '2024-10-12 23:34:39'),
(18, 3178.00, '2024-10-12 23:53:03'),
(19, 3178.00, '2024-10-12 23:53:33'),
(20, 3178.00, '2024-10-13 00:28:15'),
(21, 3178.00, '2024-10-13 00:31:36'),
(22, 3178.00, '2024-10-13 00:31:52'),
(23, 3178.00, '2024-10-13 06:03:59'),
(24, 3366.00, '2024-10-13 06:21:19'),
(25, 3695.00, '2024-10-13 06:21:33'),
(26, 3695.00, '2024-10-13 06:21:37'),
(27, 3836.00, '2024-10-13 06:22:21'),
(28, 3836.00, '2024-10-13 06:25:20'),
(29, 3977.00, '2024-10-13 06:26:58'),
(30, 3977.00, '2024-10-13 06:27:01'),
(31, 4870.00, '2024-10-13 06:31:14'),
(32, 4870.00, '2024-10-13 06:31:15'),
(33, 4870.00, '2024-10-13 06:31:20'),
(34, 5152.00, '2024-10-13 06:31:40'),
(35, 5152.00, '2024-10-13 06:31:46'),
(36, 5340.00, '2024-10-13 06:31:52'),
(37, 5340.00, '2024-10-13 06:31:57'),
(38, 5434.00, '2024-10-13 06:32:21'),
(39, 5622.00, '2024-10-13 07:27:54'),
(40, 5622.00, '2024-10-13 07:31:01'),
(41, 5622.00, '2024-10-13 07:31:13'),
(42, 5622.00, '2024-10-13 07:31:30'),
(43, 5622.00, '2024-10-13 07:31:34'),
(44, 5622.00, '2024-10-13 07:31:55'),
(45, 5622.00, '2024-10-13 07:32:42'),
(46, 5622.00, '2024-10-13 07:40:52'),
(47, 5622.00, '2024-10-13 07:49:54'),
(48, 5622.00, '2024-10-13 07:54:53'),
(49, 5622.00, '2024-10-13 07:54:54'),
(50, 5622.00, '2024-10-13 07:54:59'),
(51, 5622.00, '2024-10-13 07:55:08'),
(52, 5622.00, '2024-10-13 07:55:12'),
(53, 5810.00, '2024-10-13 08:03:24'),
(54, 5810.00, '2024-10-13 08:08:21'),
(55, 5810.00, '2024-10-13 08:08:23'),
(56, 5810.00, '2024-10-13 08:08:34'),
(57, 5810.00, '2024-10-13 08:08:36'),
(58, 5810.00, '2024-10-13 08:08:41'),
(59, 5810.00, '2024-10-13 08:09:17'),
(60, 5810.00, '2024-10-13 08:12:31'),
(61, 5810.00, '2024-10-13 08:12:36'),
(62, 5810.00, '2024-10-13 10:57:03'),
(63, 5810.00, '2024-10-13 11:12:19'),
(64, 5810.00, '2024-10-13 11:13:24'),
(65, 5810.00, '2024-10-13 11:27:43'),
(66, 5810.00, '2024-10-13 11:28:02'),
(67, 5810.00, '2024-10-13 11:28:06'),
(68, 5810.00, '2024-10-13 11:29:16'),
(69, 5810.00, '2024-10-13 11:29:17'),
(70, 5810.00, '2024-10-13 11:53:37'),
(71, 5810.00, '2024-10-13 11:54:15'),
(72, 5810.00, '2024-10-13 11:54:25'),
(73, 5810.00, '2024-10-13 11:54:33'),
(74, 5810.00, '2024-10-13 11:54:41'),
(75, 5810.00, '2024-10-13 11:55:05'),
(76, 5810.00, '2024-10-13 11:55:32'),
(77, 5904.00, '2024-10-13 12:02:43'),
(78, 5904.00, '2024-10-13 12:07:11'),
(79, 5904.00, '2024-10-13 12:07:23'),
(80, 5904.00, '2024-10-13 12:07:29'),
(81, 5951.00, '2024-10-13 12:11:11'),
(82, 6703.00, '2024-10-13 12:17:32'),
(83, 8442.00, '2024-10-13 12:23:04'),
(84, 8442.00, '2024-10-13 12:24:53'),
(85, 8692.00, '2024-10-13 12:26:05'),
(86, 8692.00, '2024-10-13 12:26:07'),
(87, 8692.00, '2024-10-13 12:26:15'),
(88, 8692.00, '2024-10-13 12:27:04'),
(89, 8692.00, '2024-10-13 12:28:24'),
(90, 9162.00, '2024-10-14 13:28:09'),
(91, 9162.00, '2024-10-14 13:28:16'),
(92, 9820.00, '2024-10-14 12:23:19'),
(93, 10334.00, '2024-10-14 12:24:44'),
(94, 10854.00, '2024-10-15 03:17:09'),
(95, 10854.00, '2024-10-15 03:17:47'),
(96, 10854.00, '2024-10-15 03:48:33'),
(97, 10854.00, '2024-10-15 03:53:25'),
(98, 10854.00, '2024-10-15 03:54:03'),
(99, 10854.00, '2024-10-15 03:54:41'),
(100, 10901.00, '2024-10-15 03:54:58'),
(101, 10901.00, '2024-10-15 03:55:18'),
(102, 10948.00, '2024-10-15 03:56:57'),
(103, 10948.00, '2024-10-15 03:57:02'),
(104, 10948.00, '2024-10-15 03:58:35'),
(105, 10948.00, '2024-10-20 03:27:40'),
(106, 10948.00, '2024-10-20 03:28:11'),
(107, 10948.00, '2024-10-20 03:28:13'),
(108, 11418.00, '2024-10-20 09:48:01'),
(109, 12318.00, '2024-10-20 09:48:52'),
(110, 12318.00, '2024-10-20 09:50:50'),
(111, 12408.00, '2024-10-20 09:51:08'),
(112, 12498.00, '2024-10-20 09:51:51'),
(113, 14298.00, '2024-10-20 09:53:58'),
(114, 14298.00, '2024-10-20 10:12:23'),
(115, 14298.00, '2024-10-20 10:20:36'),
(116, 14298.00, '2024-10-20 10:22:42'),
(117, 14298.00, '2024-10-20 11:05:56'),
(118, 14298.00, '2024-10-20 11:07:19'),
(119, 14298.00, '2024-10-20 11:43:30'),
(120, 14298.00, '2024-10-20 11:43:31'),
(121, 14298.00, '2024-10-20 11:49:33'),
(122, 14298.00, '2024-10-20 11:49:42'),
(123, 14298.00, '2024-10-20 11:49:42'),
(124, 14298.00, '2024-10-20 11:49:42'),
(125, 14298.00, '2024-10-20 11:49:42'),
(126, 14298.00, '2024-10-20 11:49:43'),
(127, 14298.00, '2024-10-20 11:49:47'),
(128, 14298.00, '2024-10-20 11:50:14'),
(129, 14298.00, '2024-10-20 11:50:16'),
(130, 14298.00, '2024-10-20 11:54:42'),
(131, 14298.00, '2024-10-20 11:55:06'),
(132, 14298.00, '2024-10-20 11:59:29'),
(133, 14298.00, '2024-10-20 11:59:59'),
(134, 14298.00, '2024-10-20 12:02:33'),
(135, 14298.00, '2024-10-20 12:03:14'),
(136, 14298.00, '2024-10-20 12:05:25'),
(137, 14298.00, '2024-10-20 12:12:16'),
(138, 14298.00, '2024-10-20 12:34:19'),
(139, 14298.00, '2024-10-20 12:41:26'),
(140, 14298.00, '2024-10-20 12:52:44'),
(141, 14298.00, '2024-10-20 12:53:08'),
(142, 14298.00, '2024-10-20 13:19:29'),
(143, 14298.00, '2024-10-20 13:19:45'),
(144, 14298.00, '2024-10-20 13:20:19'),
(145, 14298.00, '2024-10-20 13:24:11'),
(146, 14298.00, '2024-10-20 13:25:36'),
(147, 14298.00, '2024-10-20 13:28:09'),
(148, 14298.00, '2024-10-20 13:31:32'),
(149, 14298.00, '2024-10-20 13:34:46'),
(150, 14298.00, '2024-10-20 13:45:27'),
(151, 14298.00, '2024-10-20 13:45:47'),
(152, 14298.00, '2024-10-20 13:49:57'),
(153, 14298.00, '2024-10-20 13:50:19'),
(154, 14298.00, '2024-10-20 13:53:03'),
(155, 14298.00, '2024-10-20 13:53:04'),
(156, 14298.00, '2024-10-20 13:53:58'),
(157, 14298.00, '2024-10-20 13:55:36'),
(158, 14298.00, '2024-10-20 13:55:46'),
(159, 14298.00, '2024-10-20 13:56:01'),
(160, 14298.00, '2024-10-20 13:56:01'),
(161, 14298.00, '2024-10-20 13:56:02'),
(162, 14298.00, '2024-10-20 13:56:05'),
(163, 14298.00, '2024-10-20 13:56:05'),
(164, 14298.00, '2024-10-20 13:56:34'),
(165, 14298.00, '2024-10-20 13:57:21'),
(166, 14298.00, '2024-10-20 13:57:24'),
(167, 14298.00, '2024-10-20 13:57:30'),
(168, 14298.00, '2024-10-20 13:57:33'),
(169, 14298.00, '2024-10-20 13:57:34'),
(170, 14298.00, '2024-10-20 13:57:36'),
(171, 14298.00, '2024-10-20 13:57:38'),
(172, 14298.00, '2024-10-20 13:57:46'),
(173, 14298.00, '2024-10-20 13:57:48'),
(174, 14298.00, '2024-10-20 13:57:51'),
(175, 14298.00, '2024-10-20 13:59:32'),
(176, 14298.00, '2024-10-20 13:59:32'),
(177, 14298.00, '2024-10-20 13:59:33'),
(178, 14298.00, '2024-10-20 13:59:51'),
(179, 14298.00, '2024-10-20 13:59:54'),
(180, 14298.00, '2024-10-20 14:00:00'),
(181, 14298.00, '2024-10-20 14:00:02'),
(182, 14298.00, '2024-10-20 14:00:58'),
(183, 14298.00, '2024-10-20 14:03:12'),
(184, 14298.00, '2024-10-20 14:03:17'),
(185, 14298.00, '2024-10-20 14:03:21'),
(186, 14298.00, '2024-10-20 14:03:22'),
(187, 14298.00, '2024-10-20 14:03:27'),
(188, 14298.00, '2024-10-20 14:03:31'),
(189, 14298.00, '2024-10-20 14:03:40'),
(190, 14298.00, '2024-10-20 14:06:21'),
(191, 14298.00, '2024-10-20 14:06:31'),
(192, 14298.00, '2024-10-20 14:07:03'),
(193, 14298.00, '2024-10-20 14:07:14'),
(194, 14298.00, '2024-10-20 14:11:54'),
(195, 14298.00, '2024-10-20 14:12:26'),
(196, 14298.00, '2024-10-20 14:12:28'),
(197, 14298.00, '2024-10-20 14:12:30'),
(198, 14298.00, '2024-10-20 14:14:40'),
(199, 14298.00, '2024-10-20 14:15:31'),
(200, 14298.00, '2024-10-20 14:15:32'),
(201, 14298.00, '2024-10-20 14:15:32'),
(202, 14298.00, '2024-10-20 14:15:32'),
(203, 14298.00, '2024-10-20 14:15:32'),
(204, 14298.00, '2024-10-20 14:16:05'),
(205, 14298.00, '2024-10-20 14:16:33'),
(206, 14298.00, '2024-10-20 14:16:59'),
(207, 14298.00, '2024-10-20 14:17:12'),
(208, 14298.00, '2024-10-20 14:17:28'),
(209, 14298.00, '2024-10-20 14:17:29'),
(210, 14298.00, '2024-10-20 14:17:29'),
(211, 14298.00, '2024-10-20 14:18:02'),
(212, 14298.00, '2024-10-20 14:18:04'),
(213, 14298.00, '2024-10-20 14:18:05'),
(214, 14298.00, '2024-10-20 14:18:05'),
(215, 14298.00, '2024-10-20 14:18:05'),
(216, 14298.00, '2024-10-20 14:18:08'),
(217, 14298.00, '2024-10-20 14:18:08'),
(218, 14298.00, '2024-10-20 14:18:08'),
(219, 14298.00, '2024-10-20 14:18:12'),
(220, 14298.00, '2024-10-20 14:18:15'),
(221, 14298.00, '2024-10-20 14:18:16'),
(222, 14298.00, '2024-10-20 14:18:16'),
(223, 14298.00, '2024-10-20 14:18:17'),
(224, 14298.00, '2024-10-20 14:18:20'),
(225, 14298.00, '2024-10-20 14:18:20'),
(226, 14298.00, '2024-10-20 14:18:29'),
(227, 14298.00, '2024-10-20 14:21:02'),
(228, 14298.00, '2024-10-20 14:22:04'),
(229, 14298.00, '2024-10-20 14:22:08'),
(230, 14298.00, '2024-10-20 14:22:12'),
(231, 14298.00, '2024-10-20 14:22:14'),
(232, 14298.00, '2024-10-20 14:22:16'),
(233, 14298.00, '2024-10-20 14:22:25'),
(234, 14298.00, '2024-10-20 14:22:48'),
(235, 14298.00, '2024-10-20 14:22:48'),
(236, 14298.00, '2024-10-20 14:22:52'),
(237, 14298.00, '2024-10-20 14:23:00'),
(238, 14298.00, '2024-10-20 14:23:13'),
(239, 14298.00, '2024-10-20 14:25:15'),
(240, 14298.00, '2024-10-20 14:25:16'),
(241, 14298.00, '2024-10-20 14:25:23'),
(242, 14298.00, '2024-10-20 14:28:02'),
(243, 14298.00, '2024-10-20 14:28:03'),
(244, 14298.00, '2024-10-20 14:28:03'),
(245, 14298.00, '2024-10-20 14:28:03'),
(246, 14298.00, '2024-10-20 14:32:39'),
(247, 14298.00, '2024-10-20 14:32:40'),
(248, 14298.00, '2024-10-20 14:32:40'),
(249, 14298.00, '2024-10-20 14:32:40'),
(250, 14298.00, '2024-10-20 14:32:54'),
(251, 14298.00, '2024-10-20 14:32:54'),
(252, 14298.00, '2024-10-20 14:32:55'),
(253, 14298.00, '2024-10-20 14:33:38'),
(254, 14298.00, '2024-10-20 14:33:38'),
(255, 14298.00, '2024-10-20 14:33:38'),
(256, 14298.00, '2024-10-20 14:33:45'),
(257, 14298.00, '2024-10-20 14:33:49'),
(258, 14298.00, '2024-10-20 14:33:52'),
(259, 14298.00, '2024-10-20 14:33:55'),
(260, 14298.00, '2024-10-20 14:34:01'),
(261, 14298.00, '2024-10-20 14:34:23'),
(262, 14298.00, '2024-10-20 14:35:01'),
(263, 14298.00, '2024-10-20 14:35:13'),
(264, 14298.00, '2024-10-20 14:35:25'),
(265, 14298.00, '2024-10-20 14:37:39'),
(266, 14298.00, '2024-10-20 14:37:40'),
(267, 14298.00, '2024-10-20 14:37:57'),
(268, 14298.00, '2024-10-20 14:37:59'),
(269, 14298.00, '2024-10-20 14:39:55'),
(270, 14298.00, '2024-10-20 14:43:12'),
(271, 14298.00, '2024-10-20 14:43:13'),
(272, 14298.00, '2024-10-20 14:43:28'),
(273, 14298.00, '2024-10-20 14:43:58'),
(274, 14298.00, '2024-10-20 14:45:31'),
(275, 14298.00, '2024-10-20 14:45:36'),
(276, 14298.00, '2024-10-20 14:46:56'),
(277, 14298.00, '2024-10-20 14:46:56'),
(278, 14298.00, '2024-10-20 14:47:01'),
(279, 14298.00, '2024-10-20 14:51:49'),
(280, 14298.00, '2024-10-20 14:51:59'),
(281, 0.00, '2024-10-20 14:53:57'),
(282, 0.00, '2024-10-20 14:54:01'),
(283, 0.00, '2024-10-20 14:54:01'),
(284, 0.00, '2024-10-20 14:54:33'),
(285, 0.00, '2024-10-20 14:54:38'),
(286, 0.00, '2024-10-20 14:54:56'),
(287, 14298.00, '2024-10-20 14:56:16'),
(288, 14298.00, '2024-10-20 14:56:20'),
(289, 14298.00, '2024-10-20 14:59:18'),
(290, 14298.00, '2024-10-20 14:59:31'),
(291, 14298.00, '2024-10-20 15:00:12'),
(292, 14298.00, '2024-10-20 15:03:01'),
(293, 14298.00, '2024-10-20 15:03:10'),
(294, 14298.00, '2024-10-20 15:05:22'),
(295, 14298.00, '2024-10-20 15:05:32'),
(296, 14298.00, '2024-10-20 15:05:37'),
(297, 14298.00, '2024-10-20 15:07:05'),
(298, 14298.00, '2024-10-20 15:07:08'),
(299, 14298.00, '2024-10-20 15:09:10'),
(300, 14298.00, '2024-10-20 15:09:36'),
(301, 14298.00, '2024-10-20 15:13:05'),
(302, 14298.00, '2024-10-20 15:13:18'),
(303, 14298.00, '2024-10-20 15:13:22'),
(304, 14298.00, '2024-10-20 15:15:05'),
(305, 14298.00, '2024-10-20 15:15:48'),
(306, 14298.00, '2024-10-20 15:15:54'),
(307, 14298.00, '2024-10-20 15:15:56'),
(308, 14298.00, '2024-10-20 15:16:12'),
(309, 14298.00, '2024-10-20 15:16:13'),
(310, 14298.00, '2024-10-20 15:16:14'),
(311, 14298.00, '2024-10-20 15:16:15'),
(312, 14298.00, '2024-10-20 15:16:16'),
(313, 14298.00, '2024-10-20 15:16:17'),
(314, 14298.00, '2024-10-20 15:16:18'),
(315, 14298.00, '2024-10-20 15:16:18'),
(316, 14298.00, '2024-10-20 15:16:19'),
(317, 14298.00, '2024-10-20 15:16:21'),
(318, 14298.00, '2024-10-20 15:16:21'),
(319, 14298.00, '2024-10-20 15:16:22'),
(320, 14298.00, '2024-10-20 15:18:43'),
(321, 14298.00, '2024-10-20 15:19:21'),
(322, 14298.00, '2024-10-20 15:19:22'),
(323, 14298.00, '2024-10-20 15:19:26'),
(324, 14298.00, '2024-10-20 15:19:26'),
(325, 14298.00, '2024-10-20 15:19:26'),
(326, 14298.00, '2024-10-20 15:21:17'),
(327, 14298.00, '2024-10-20 15:21:18'),
(328, 14298.00, '2024-10-20 15:21:19'),
(329, 14298.00, '2024-10-20 15:21:19'),
(330, 14298.00, '2024-10-20 15:21:19'),
(331, 14298.00, '2024-10-20 15:21:19'),
(332, 14298.00, '2024-10-20 15:21:20'),
(333, 14298.00, '2024-10-20 15:21:21'),
(334, 14298.00, '2024-10-20 15:21:21'),
(335, 14298.00, '2024-10-20 15:21:22'),
(336, 14298.00, '2024-10-20 15:21:22'),
(337, 14298.00, '2024-10-20 15:21:22'),
(338, 14298.00, '2024-10-20 15:21:22'),
(339, 14298.00, '2024-10-20 15:21:23'),
(340, 14298.00, '2024-10-20 15:21:37'),
(341, 14298.00, '2024-10-20 15:25:34'),
(342, 14298.00, '2024-10-20 15:27:29'),
(343, 14298.00, '2024-10-20 15:27:52'),
(344, 14298.00, '2024-10-20 15:29:24'),
(345, 14298.00, '2024-10-20 15:30:03'),
(346, 14298.00, '2024-10-20 15:30:07'),
(347, 14298.00, '2024-10-20 15:30:18'),
(348, 14298.00, '2024-10-20 15:33:05'),
(349, 14298.00, '2024-10-20 15:33:06'),
(350, 14298.00, '2024-10-20 15:33:06'),
(351, 14298.00, '2024-10-20 15:33:07'),
(352, 14298.00, '2024-10-20 15:33:07'),
(353, 14298.00, '2024-10-20 15:33:07'),
(354, 14298.00, '2024-10-20 15:33:09'),
(355, 14298.00, '2024-10-20 15:33:09'),
(356, 14298.00, '2024-10-20 15:33:10'),
(357, 14298.00, '2024-10-20 15:36:13'),
(358, 14298.00, '2024-10-20 15:36:22'),
(359, 14298.00, '2024-10-20 15:36:51'),
(360, 14298.00, '2024-10-20 15:36:54'),
(361, 14298.00, '2024-10-20 15:43:45'),
(362, 14298.00, '2024-10-20 15:44:00'),
(363, 14298.00, '2024-10-20 15:45:00'),
(364, 14298.00, '2024-10-20 15:45:13'),
(365, 14298.00, '2024-10-20 15:45:18'),
(366, 14298.00, '2024-10-20 15:45:18'),
(367, 14298.00, '2024-10-20 15:46:11'),
(368, 14298.00, '2024-10-20 15:46:17'),
(369, 14298.00, '2024-10-20 15:46:20'),
(370, 14298.00, '2024-10-20 15:46:22'),
(371, 14298.00, '2024-10-20 15:48:10'),
(372, 14298.00, '2024-10-20 15:48:13'),
(373, 14298.00, '2024-10-20 15:48:57'),
(374, 14298.00, '2024-10-20 15:49:04'),
(375, 14298.00, '2024-10-20 15:49:08'),
(376, 14298.00, '2024-10-20 15:49:27'),
(377, 14298.00, '2024-10-20 15:49:27'),
(378, 14298.00, '2024-10-20 15:49:51'),
(379, 14298.00, '2024-10-20 15:49:59'),
(380, 14298.00, '2024-10-20 15:50:01'),
(381, 14298.00, '2024-10-20 15:50:11'),
(382, 14298.00, '2024-10-20 15:50:14'),
(383, 14298.00, '2024-10-20 15:51:30'),
(384, 14298.00, '2024-10-20 15:51:50'),
(385, 14298.00, '2024-10-20 15:51:53'),
(386, 14298.00, '2024-10-20 15:52:22'),
(387, 14298.00, '2024-10-20 15:52:27'),
(388, 14298.00, '2024-10-20 15:52:41'),
(389, 14298.00, '2024-10-20 15:52:42'),
(390, 14298.00, '2024-10-20 15:53:11'),
(391, 14298.00, '2024-10-20 15:53:13'),
(392, 14298.00, '2024-10-20 15:53:16'),
(393, 14298.00, '2024-10-20 15:55:05'),
(394, 14298.00, '2024-10-20 15:55:05'),
(395, 14298.00, '2024-10-20 15:55:10'),
(396, 14298.00, '2024-10-20 15:56:25'),
(397, 14298.00, '2024-10-20 15:56:34'),
(398, 14298.00, '2024-10-20 15:57:29'),
(399, 14298.00, '2024-10-20 15:58:06'),
(400, 14298.00, '2024-10-20 15:58:12'),
(401, 14298.00, '2024-10-20 15:58:18'),
(402, 14298.00, '2024-10-20 15:58:23'),
(403, 14298.00, '2024-10-20 16:00:25'),
(404, 14298.00, '2024-10-20 16:00:31'),
(405, 14298.00, '2024-10-20 16:00:36'),
(406, 14298.00, '2024-10-20 16:03:43'),
(407, 14298.00, '2024-10-20 16:03:48'),
(408, 14298.00, '2024-10-20 16:03:49'),
(409, 14298.00, '2024-10-20 16:03:54'),
(410, 14298.00, '2024-10-20 16:03:59'),
(411, 14298.00, '2024-10-20 16:04:02'),
(412, 14298.00, '2024-10-20 16:04:06'),
(413, 14298.00, '2024-10-20 16:04:10'),
(414, 14298.00, '2024-10-20 16:04:13'),
(415, 14298.00, '2024-10-20 16:04:17'),
(416, 14298.00, '2024-10-20 16:04:44'),
(417, 14298.00, '2024-10-20 16:04:50'),
(418, 14298.00, '2024-10-20 16:05:16'),
(419, 14298.00, '2024-10-20 16:06:32'),
(420, 14298.00, '2024-10-20 16:06:34'),
(421, 14298.00, '2024-10-20 16:06:40'),
(422, 14298.00, '2024-10-20 16:06:45'),
(423, 14298.00, '2024-10-20 16:06:49'),
(424, 14298.00, '2024-10-20 16:06:59'),
(425, 14298.00, '2024-10-20 16:07:35'),
(426, 14298.00, '2024-10-20 16:07:38'),
(427, 14298.00, '2024-10-20 16:07:42'),
(428, 14298.00, '2024-10-20 16:09:29'),
(429, 14298.00, '2024-10-20 16:11:44'),
(430, 14298.00, '2024-10-20 16:11:50'),
(431, 14298.00, '2024-10-20 16:11:55'),
(432, 14298.00, '2024-10-20 16:12:15'),
(433, 14298.00, '2024-10-20 16:13:25'),
(434, 14298.00, '2024-10-20 16:13:29'),
(435, 14298.00, '2024-10-20 16:13:32'),
(436, 14298.00, '2024-10-20 16:13:47'),
(437, 14298.00, '2024-10-20 16:14:18'),
(438, 14298.00, '2024-10-20 16:14:21'),
(439, 14298.00, '2024-10-20 16:14:23'),
(440, 14298.00, '2024-10-20 16:14:26'),
(441, 14298.00, '2024-10-20 16:16:30'),
(442, 14298.00, '2024-10-20 16:16:41'),
(443, 14298.00, '2024-10-20 16:16:42'),
(444, 14298.00, '2024-10-20 16:16:56'),
(445, 14298.00, '2024-10-20 16:16:57'),
(446, 14298.00, '2024-10-20 16:16:59'),
(447, 14298.00, '2024-10-20 16:17:10'),
(448, 14298.00, '2024-10-20 16:19:06'),
(449, 14298.00, '2024-10-20 16:19:12'),
(450, 14298.00, '2024-10-20 16:19:17'),
(451, 14298.00, '2024-10-20 16:20:34'),
(452, 14298.00, '2024-10-20 16:20:38'),
(453, 14298.00, '2024-10-20 16:20:44'),
(454, 14298.00, '2024-10-20 16:21:01'),
(455, 14298.00, '2024-10-20 16:21:21'),
(456, 14298.00, '2024-10-20 16:22:51'),
(457, 14298.00, '2024-10-20 16:22:54'),
(458, 14298.00, '2024-10-20 16:23:28'),
(459, 14298.00, '2024-10-20 16:23:31'),
(460, 14298.00, '2024-10-20 16:23:33'),
(461, 14298.00, '2024-10-20 16:23:35'),
(462, 14298.00, '2024-10-20 16:23:36'),
(463, 14298.00, '2024-10-20 16:25:32'),
(464, 14298.00, '2024-10-20 16:25:33'),
(465, 14298.00, '2024-10-20 16:25:34'),
(466, 14298.00, '2024-10-20 16:25:36'),
(467, 14298.00, '2024-10-20 16:25:38'),
(468, 14298.00, '2024-10-20 16:25:43'),
(469, 14298.00, '2024-10-20 16:25:48'),
(470, 14298.00, '2024-10-20 16:25:50'),
(471, 14298.00, '2024-10-20 16:25:52'),
(472, 14298.00, '2024-10-20 16:25:54'),
(473, 14298.00, '2024-10-20 16:25:58'),
(474, 14298.00, '2024-10-20 16:26:00'),
(475, 14298.00, '2024-10-20 16:26:00'),
(476, 14298.00, '2024-10-20 16:26:04'),
(477, 14298.00, '2024-10-20 16:26:06'),
(478, 14298.00, '2024-10-20 16:26:10'),
(479, 14298.00, '2024-10-20 16:27:44'),
(480, 14298.00, '2024-10-20 16:29:04'),
(481, 14298.00, '2024-10-20 16:29:13'),
(482, 14298.00, '2024-10-20 16:29:16'),
(483, 14298.00, '2024-10-20 16:30:56'),
(484, 14298.00, '2024-10-20 16:32:54'),
(485, 14298.00, '2024-10-20 16:32:59'),
(486, 14298.00, '2024-10-20 16:33:02'),
(487, 14298.00, '2024-10-20 16:33:26'),
(488, 14298.00, '2024-10-20 16:33:30'),
(489, 14298.00, '2024-10-20 16:33:34'),
(490, 14298.00, '2024-10-20 16:33:36'),
(491, 14298.00, '2024-10-20 16:33:47'),
(492, 14298.00, '2024-10-20 16:33:51'),
(493, 14298.00, '2024-10-20 16:34:10'),
(494, 14298.00, '2024-10-20 16:34:14'),
(495, 14298.00, '2024-10-20 16:34:46'),
(496, 14298.00, '2024-10-20 16:38:09'),
(497, 14298.00, '2024-10-20 16:38:14'),
(498, 14298.00, '2024-10-20 16:38:23'),
(499, 14298.00, '2024-10-20 16:39:38'),
(500, 14298.00, '2024-10-20 16:39:46'),
(501, 14298.00, '2024-10-20 16:39:51'),
(502, 14298.00, '2024-10-20 16:40:23'),
(503, 14298.00, '2024-10-20 16:40:46'),
(504, 14298.00, '2024-10-20 16:40:46'),
(505, 14298.00, '2024-10-20 16:40:50'),
(506, 14298.00, '2024-10-20 16:41:04'),
(507, 14298.00, '2024-10-20 16:41:05'),
(508, 14298.00, '2024-10-20 16:42:31'),
(509, 14298.00, '2024-10-20 16:42:59'),
(510, 14298.00, '2024-10-20 16:43:18'),
(511, 14298.00, '2024-10-20 16:43:26'),
(512, 14298.00, '2024-10-20 16:43:33'),
(513, 14298.00, '2024-10-20 16:43:52'),
(514, 14298.00, '2024-10-20 16:45:29'),
(515, 14298.00, '2024-10-20 16:45:31'),
(516, 14298.00, '2024-10-20 16:45:37'),
(517, 14298.00, '2024-10-20 16:47:53'),
(518, 14298.00, '2024-10-20 16:48:04'),
(519, 14298.00, '2024-10-20 16:48:17'),
(520, 14298.00, '2024-11-16 01:25:17'),
(521, 14298.00, '2024-11-26 04:04:21'),
(522, 14298.00, '2024-11-26 23:55:05'),
(523, 14298.00, '2024-11-26 23:55:46'),
(524, 14298.00, '2024-11-26 23:55:55'),
(525, 14298.00, '2024-11-26 23:56:02'),
(526, 14298.00, '2024-11-26 23:56:06'),
(527, 14298.00, '2024-11-30 00:32:56'),
(528, 14298.00, '2024-11-30 00:40:50'),
(529, 14298.00, '2024-12-01 00:08:08'),
(530, 14298.00, '2024-12-01 02:22:48'),
(531, 14298.00, '2024-12-01 02:22:58'),
(532, 14298.00, '2024-12-01 02:27:29'),
(533, 14298.00, '2024-12-01 02:31:59'),
(534, 14298.00, '2024-12-01 02:32:03'),
(535, 14298.00, '2024-12-01 02:37:36'),
(536, 14298.00, '2024-12-01 02:37:39'),
(537, 14298.00, '2024-12-01 02:37:46'),
(538, 14298.00, '2024-12-01 02:37:51'),
(539, 14298.00, '2024-12-01 02:37:59');

-- --------------------------------------------------------

--
-- Table structure for table `total_income`
--

CREATE TABLE `total_income` (
  `id` int(11) NOT NULL,
  `income` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `total_income`
--

INSERT INTO `total_income` (`id`, `income`, `created_at`) VALUES
(55, 3295.00, '2024-10-12 15:13:28'),
(56, 3295.00, '2024-10-12 15:13:28'),
(57, 3295.00, '2024-10-12 15:13:29'),
(58, 3295.00, '2024-10-12 15:13:29'),
(59, 3148.00, '2024-10-12 15:13:39'),
(60, 3148.00, '2024-10-12 15:15:50'),
(61, 3148.00, '2024-10-12 15:19:23'),
(62, 2992.00, '2024-10-12 15:19:41'),
(63, 2992.00, '2024-10-12 15:19:43'),
(64, 2992.00, '2024-10-12 15:28:10'),
(65, 2992.00, '2024-10-12 15:30:14'),
(66, 2784.00, '2024-10-12 15:30:43'),
(67, 2784.00, '2024-10-12 15:31:47'),
(68, 2588.00, '2024-10-12 15:31:51'),
(69, 2588.00, '2024-10-12 15:31:52'),
(70, 2588.00, '2024-10-12 15:39:37'),
(71, 2588.00, '2024-10-12 15:42:49'),
(72, 2588.00, '2024-10-12 15:44:22'),
(73, 2588.00, '2024-10-12 15:44:22'),
(74, 2588.00, '2024-10-12 15:44:22'),
(75, 2432.00, '2024-10-12 15:44:50'),
(76, 2432.00, '2024-10-12 15:44:51'),
(77, 2432.00, '2024-10-12 15:47:53'),
(78, 2432.00, '2024-10-12 15:48:03'),
(79, 2285.00, '2024-10-12 15:48:17'),
(80, 2285.00, '2024-10-12 15:48:19'),
(81, 2285.00, '2024-10-12 15:49:42'),
(82, 2285.00, '2024-10-12 15:49:42'),
(83, 2285.00, '2024-10-12 15:49:42'),
(84, 2138.00, '2024-10-12 15:50:19'),
(85, 2138.00, '2024-10-12 15:50:20'),
(86, 2138.00, '2024-10-12 15:50:33'),
(87, 2138.00, '2024-10-12 15:51:13'),
(88, 2138.00, '2024-10-12 15:51:18'),
(89, 2138.00, '2024-10-12 16:19:23'),
(90, 2138.00, '2024-10-12 16:19:23'),
(91, 2138.00, '2024-10-12 16:21:58'),
(92, 2138.00, '2024-10-12 16:21:58'),
(93, 2138.00, '2024-10-12 16:21:58'),
(94, 2138.00, '2024-10-12 16:24:12'),
(95, 2138.00, '2024-10-12 16:24:12'),
(96, 2138.00, '2024-10-12 16:26:31'),
(97, 1982.00, '2024-10-12 16:26:43'),
(98, 1982.00, '2024-10-12 16:27:07'),
(99, 1835.00, '2024-10-12 16:40:06'),
(100, 1835.00, '2024-10-12 16:41:55'),
(101, 1835.00, '2024-10-12 16:42:33'),
(102, 1835.00, '2024-10-12 16:42:35'),
(103, 1835.00, '2024-10-12 16:42:41'),
(104, 1835.00, '2024-10-12 16:42:41'),
(105, 1835.00, '2024-10-12 16:42:58'),
(106, 1835.00, '2024-10-12 16:42:59'),
(107, 1835.00, '2024-10-12 16:43:03'),
(108, 1835.00, '2024-10-12 16:43:03'),
(109, 1835.00, '2024-10-12 16:43:03'),
(110, 1835.00, '2024-10-12 16:43:04'),
(111, 1835.00, '2024-10-12 16:43:08'),
(112, 1835.00, '2024-10-12 16:43:10'),
(113, 1835.00, '2024-10-12 16:43:13'),
(114, 1835.00, '2024-10-12 16:43:16'),
(115, 1835.00, '2024-10-12 16:43:19'),
(116, 1835.00, '2024-10-12 16:43:22'),
(117, 1835.00, '2024-10-12 16:43:24'),
(118, 1835.00, '2024-10-12 16:43:27'),
(119, 1835.00, '2024-10-12 16:47:53'),
(120, 1835.00, '2024-10-12 16:48:08'),
(121, 1835.00, '2024-10-12 16:48:08'),
(122, 1688.00, '2024-10-12 16:48:17'),
(123, 1000.00, '2024-10-12 16:48:18'),
(124, 1720.00, '2024-10-12 16:57:21'),
(125, 1622.00, '2024-10-12 16:57:29'),
(126, 1622.00, '2024-10-12 17:02:10'),
(127, 1524.00, '2024-10-12 17:02:30'),
(128, 1524.00, '2024-10-12 17:02:31'),
(129, 1524.00, '2024-10-12 17:03:45'),
(130, 1524.00, '2024-10-12 17:03:45'),
(131, 1430.00, '2024-10-12 17:07:40'),
(132, 1430.00, '2024-10-12 17:08:02'),
(133, 1430.00, '2024-10-12 17:12:55'),
(134, 1332.00, '2024-10-12 17:13:15'),
(135, 1332.00, '2024-10-12 17:14:06'),
(136, 1254.00, '2024-10-12 23:21:31'),
(137, 1254.00, '2024-10-12 23:21:53'),
(138, 1003.00, '2024-10-12 23:26:47'),
(139, 1003.00, '2024-10-12 23:26:48'),
(140, 1003.00, '2024-10-12 23:34:21'),
(141, 862.00, '2024-10-12 23:34:39'),
(142, 862.00, '2024-10-12 23:53:03'),
(143, 982.00, '2024-10-12 23:53:33'),
(144, 1712.00, '2024-10-13 00:28:15'),
(145, 1712.00, '2024-10-13 00:31:36'),
(146, 1712.00, '2024-10-13 00:31:52'),
(147, 1812.00, '2024-10-13 06:03:59'),
(148, 1624.00, '2024-10-13 06:21:19'),
(149, 1295.00, '2024-10-13 06:21:33'),
(150, 1295.00, '2024-10-13 06:21:37'),
(151, 1154.00, '2024-10-13 06:22:21'),
(152, 1154.00, '2024-10-13 06:25:20'),
(153, 1013.00, '2024-10-13 06:26:58'),
(154, 1013.00, '2024-10-13 06:27:01'),
(155, 120.00, '2024-10-13 06:31:14'),
(156, 120.00, '2024-10-13 06:31:15'),
(157, 120.00, '2024-10-13 06:31:20'),
(158, -162.00, '2024-10-13 06:31:40'),
(159, -162.00, '2024-10-13 06:31:46'),
(160, -350.00, '2024-10-13 06:31:52'),
(161, -350.00, '2024-10-13 06:31:57'),
(162, -444.00, '2024-10-13 06:32:21'),
(163, 1368.00, '2024-10-13 07:27:54'),
(164, 1368.00, '2024-10-13 07:31:01'),
(165, 1368.00, '2024-10-13 07:31:13'),
(166, 1368.00, '2024-10-13 07:31:30'),
(167, 1368.00, '2024-10-13 07:31:34'),
(168, 1368.00, '2024-10-13 07:31:55'),
(169, 1368.00, '2024-10-13 07:32:42'),
(170, 1368.00, '2024-10-13 07:40:52'),
(171, 1368.00, '2024-10-13 07:49:54'),
(172, 1368.00, '2024-10-13 07:54:53'),
(173, 1368.00, '2024-10-13 07:54:54'),
(174, 1368.00, '2024-10-13 07:54:59'),
(175, 1368.00, '2024-10-13 07:55:08'),
(176, 1368.00, '2024-10-13 07:55:12'),
(177, 1180.00, '2024-10-13 08:03:24'),
(178, 1180.00, '2024-10-13 08:08:21'),
(179, 1180.00, '2024-10-13 08:08:23'),
(180, 1180.00, '2024-10-13 08:08:34'),
(181, 1180.00, '2024-10-13 08:08:36'),
(182, 1180.00, '2024-10-13 08:08:41'),
(183, 1180.00, '2024-10-13 08:09:17'),
(184, 1180.00, '2024-10-13 08:12:31'),
(185, 1180.00, '2024-10-13 08:12:36'),
(186, 1310.00, '2024-10-13 10:57:03'),
(187, 1310.00, '2024-10-13 11:12:19'),
(188, 1310.00, '2024-10-13 11:13:24'),
(189, 1430.00, '2024-10-13 11:27:43'),
(190, 1430.00, '2024-10-13 11:28:02'),
(191, 1430.00, '2024-10-13 11:28:06'),
(192, 1430.00, '2024-10-13 11:29:16'),
(193, 1430.00, '2024-10-13 11:29:17'),
(194, 1430.00, '2024-10-13 11:53:37'),
(195, 1430.00, '2024-10-13 11:54:15'),
(196, 1430.00, '2024-10-13 11:54:25'),
(197, 1430.00, '2024-10-13 11:54:33'),
(198, 1430.00, '2024-10-13 11:54:42'),
(199, 1430.00, '2024-10-13 11:55:05'),
(200, 1430.00, '2024-10-13 11:55:32'),
(201, 1336.00, '2024-10-13 12:02:43'),
(202, 1336.00, '2024-10-13 12:07:11'),
(203, 1336.00, '2024-10-13 12:07:23'),
(204, 1336.00, '2024-10-13 12:07:29'),
(205, 1289.00, '2024-10-13 12:11:11'),
(206, 2537.00, '2024-10-13 12:17:32'),
(207, 798.00, '2024-10-13 12:23:04'),
(208, 798.00, '2024-10-13 12:24:53'),
(209, 548.00, '2024-10-13 12:26:05'),
(210, 548.00, '2024-10-13 12:26:07'),
(211, 548.00, '2024-10-13 12:26:15'),
(212, 548.00, '2024-10-13 12:27:04'),
(213, 548.00, '2024-10-13 12:28:24'),
(214, 278.00, '2024-10-14 13:28:09'),
(215, 278.00, '2024-10-14 13:28:16'),
(216, 1450.00, '2024-10-14 12:23:19'),
(217, 936.00, '2024-10-14 12:24:44'),
(218, 1616.00, '2024-10-15 03:17:09'),
(219, 1616.00, '2024-10-15 03:17:47'),
(220, 1616.00, '2024-10-15 03:48:33'),
(221, 1696.00, '2024-10-15 03:53:25'),
(222, 1696.00, '2024-10-15 03:54:03'),
(223, 1696.00, '2024-10-15 03:54:41'),
(224, 1649.00, '2024-10-15 03:54:58'),
(225, 1649.00, '2024-10-15 03:55:18'),
(226, 1702.00, '2024-10-15 03:56:57'),
(227, 1702.00, '2024-10-15 03:57:02'),
(228, 1702.00, '2024-10-15 03:58:35'),
(229, 1802.00, '2024-10-20 03:27:40'),
(230, 1802.00, '2024-10-20 03:28:11'),
(231, 1802.00, '2024-10-20 03:28:13'),
(232, 1332.00, '2024-10-20 09:48:01'),
(233, 432.00, '2024-10-20 09:48:52'),
(234, 432.00, '2024-10-20 09:50:50'),
(235, 342.00, '2024-10-20 09:51:08'),
(236, 252.00, '2024-10-20 09:51:51'),
(237, -1548.00, '2024-10-20 09:53:58'),
(238, -1548.00, '2024-10-20 10:12:23'),
(239, -1548.00, '2024-10-20 10:20:36'),
(240, -1468.00, '2024-10-20 10:22:42'),
(241, -1468.00, '2024-10-20 11:05:56'),
(242, -1468.00, '2024-10-20 11:07:19'),
(243, -1348.00, '2024-10-20 11:43:30'),
(244, -1348.00, '2024-10-20 11:43:31'),
(245, -1348.00, '2024-10-20 11:49:33'),
(246, -1348.00, '2024-10-20 11:49:42'),
(247, -1348.00, '2024-10-20 11:49:42'),
(248, -1348.00, '2024-10-20 11:49:42'),
(249, -1348.00, '2024-10-20 11:49:42'),
(250, -1348.00, '2024-10-20 11:49:43'),
(251, -1348.00, '2024-10-20 11:49:47'),
(252, -1228.00, '2024-10-20 11:50:14'),
(253, -1228.00, '2024-10-20 11:50:16'),
(254, -1228.00, '2024-10-20 11:54:42'),
(255, -1228.00, '2024-10-20 11:55:06'),
(256, -1228.00, '2024-10-20 11:59:29'),
(257, -1228.00, '2024-10-20 11:59:59'),
(258, -1228.00, '2024-10-20 12:02:33'),
(259, -1228.00, '2024-10-20 12:03:14'),
(260, -1228.00, '2024-10-20 12:05:25'),
(261, -1228.00, '2024-10-20 12:12:16'),
(262, -1228.00, '2024-10-20 12:34:19'),
(263, -1228.00, '2024-10-20 12:41:26'),
(264, -1228.00, '2024-10-20 12:52:44'),
(265, -1228.00, '2024-10-20 12:53:08'),
(266, -1228.00, '2024-10-20 13:19:29'),
(267, -1108.00, '2024-10-20 13:19:45'),
(268, -1108.00, '2024-10-20 13:20:19'),
(269, -1108.00, '2024-10-20 13:24:11'),
(270, -1108.00, '2024-10-20 13:25:36'),
(271, -1108.00, '2024-10-20 13:28:09'),
(272, -1108.00, '2024-10-20 13:31:32'),
(273, -1108.00, '2024-10-20 13:34:46'),
(274, -1108.00, '2024-10-20 13:45:27'),
(275, -978.00, '2024-10-20 13:45:47'),
(276, -978.00, '2024-10-20 13:49:57'),
(277, -978.00, '2024-10-20 13:50:19'),
(278, -978.00, '2024-10-20 13:53:03'),
(279, -978.00, '2024-10-20 13:53:04'),
(280, -978.00, '2024-10-20 13:53:58'),
(281, -978.00, '2024-10-20 13:55:36'),
(282, -978.00, '2024-10-20 13:55:46'),
(283, -978.00, '2024-10-20 13:56:01'),
(284, -978.00, '2024-10-20 13:56:01'),
(285, -978.00, '2024-10-20 13:56:02'),
(286, -978.00, '2024-10-20 13:56:05'),
(287, -978.00, '2024-10-20 13:56:05'),
(288, -978.00, '2024-10-20 13:56:34'),
(289, -978.00, '2024-10-20 13:57:21'),
(290, -978.00, '2024-10-20 13:57:24'),
(291, -978.00, '2024-10-20 13:57:30'),
(292, -978.00, '2024-10-20 13:57:33'),
(293, -978.00, '2024-10-20 13:57:34'),
(294, -978.00, '2024-10-20 13:57:36'),
(295, -978.00, '2024-10-20 13:57:38'),
(296, -978.00, '2024-10-20 13:57:46'),
(297, -978.00, '2024-10-20 13:57:48'),
(298, -978.00, '2024-10-20 13:57:51'),
(299, -978.00, '2024-10-20 13:59:32'),
(300, -978.00, '2024-10-20 13:59:32'),
(301, -978.00, '2024-10-20 13:59:33'),
(302, -978.00, '2024-10-20 13:59:51'),
(303, -978.00, '2024-10-20 13:59:54'),
(304, -978.00, '2024-10-20 14:00:00'),
(305, -978.00, '2024-10-20 14:00:02'),
(306, -978.00, '2024-10-20 14:00:58'),
(307, -978.00, '2024-10-20 14:03:12'),
(308, -978.00, '2024-10-20 14:03:17'),
(309, -978.00, '2024-10-20 14:03:21'),
(310, -978.00, '2024-10-20 14:03:22'),
(311, -978.00, '2024-10-20 14:03:27'),
(312, -978.00, '2024-10-20 14:03:31'),
(313, -978.00, '2024-10-20 14:03:40'),
(314, -978.00, '2024-10-20 14:06:21'),
(315, -978.00, '2024-10-20 14:06:31'),
(316, -978.00, '2024-10-20 14:07:03'),
(317, -978.00, '2024-10-20 14:07:14'),
(318, -978.00, '2024-10-20 14:11:54'),
(319, -978.00, '2024-10-20 14:12:26'),
(320, -978.00, '2024-10-20 14:12:28'),
(321, -978.00, '2024-10-20 14:12:30'),
(322, -978.00, '2024-10-20 14:14:40'),
(323, -978.00, '2024-10-20 14:15:31'),
(324, -978.00, '2024-10-20 14:15:32'),
(325, -978.00, '2024-10-20 14:15:32'),
(326, -978.00, '2024-10-20 14:15:32'),
(327, -978.00, '2024-10-20 14:15:32'),
(328, -978.00, '2024-10-20 14:16:05'),
(329, -978.00, '2024-10-20 14:16:33'),
(330, -978.00, '2024-10-20 14:16:59'),
(331, -978.00, '2024-10-20 14:17:12'),
(332, -978.00, '2024-10-20 14:17:28'),
(333, -978.00, '2024-10-20 14:17:29'),
(334, -978.00, '2024-10-20 14:17:29'),
(335, -978.00, '2024-10-20 14:18:02'),
(336, -978.00, '2024-10-20 14:18:04'),
(337, -978.00, '2024-10-20 14:18:05'),
(338, -978.00, '2024-10-20 14:18:05'),
(339, -978.00, '2024-10-20 14:18:05'),
(340, -978.00, '2024-10-20 14:18:08'),
(341, -978.00, '2024-10-20 14:18:08'),
(342, -978.00, '2024-10-20 14:18:08'),
(343, -978.00, '2024-10-20 14:18:13'),
(344, -978.00, '2024-10-20 14:18:15'),
(345, -978.00, '2024-10-20 14:18:16'),
(346, -978.00, '2024-10-20 14:18:16'),
(347, -978.00, '2024-10-20 14:18:17'),
(348, -978.00, '2024-10-20 14:18:20'),
(349, -978.00, '2024-10-20 14:18:20'),
(350, -978.00, '2024-10-20 14:18:29'),
(351, -978.00, '2024-10-20 14:21:02'),
(352, -978.00, '2024-10-20 14:22:04'),
(353, -978.00, '2024-10-20 14:22:08'),
(354, -978.00, '2024-10-20 14:22:12'),
(355, -978.00, '2024-10-20 14:22:14'),
(356, -978.00, '2024-10-20 14:22:16'),
(357, -978.00, '2024-10-20 14:22:25'),
(358, -978.00, '2024-10-20 14:22:48'),
(359, -978.00, '2024-10-20 14:22:48'),
(360, -978.00, '2024-10-20 14:22:52'),
(361, -978.00, '2024-10-20 14:23:00'),
(362, -978.00, '2024-10-20 14:23:13'),
(363, -978.00, '2024-10-20 14:25:15'),
(364, -978.00, '2024-10-20 14:25:16'),
(365, -978.00, '2024-10-20 14:25:23'),
(366, -978.00, '2024-10-20 14:28:02'),
(367, -978.00, '2024-10-20 14:28:03'),
(368, -978.00, '2024-10-20 14:28:03'),
(369, -978.00, '2024-10-20 14:28:03'),
(370, -978.00, '2024-10-20 14:32:39'),
(371, -978.00, '2024-10-20 14:32:40'),
(372, -978.00, '2024-10-20 14:32:40'),
(373, -978.00, '2024-10-20 14:32:40'),
(374, -978.00, '2024-10-20 14:32:54'),
(375, -978.00, '2024-10-20 14:32:54'),
(376, -978.00, '2024-10-20 14:32:55'),
(377, -978.00, '2024-10-20 14:33:38'),
(378, -978.00, '2024-10-20 14:33:38'),
(379, -978.00, '2024-10-20 14:33:38'),
(380, -978.00, '2024-10-20 14:33:45'),
(381, -978.00, '2024-10-20 14:33:49'),
(382, -978.00, '2024-10-20 14:33:52'),
(383, -978.00, '2024-10-20 14:33:55'),
(384, -978.00, '2024-10-20 14:34:01'),
(385, -978.00, '2024-10-20 14:34:23'),
(386, -978.00, '2024-10-20 14:35:01'),
(387, -978.00, '2024-10-20 14:35:13'),
(388, -978.00, '2024-10-20 14:35:25'),
(389, -978.00, '2024-10-20 14:37:39'),
(390, -978.00, '2024-10-20 14:37:40'),
(391, -978.00, '2024-10-20 14:37:57'),
(392, -978.00, '2024-10-20 14:37:59'),
(393, -978.00, '2024-10-20 14:39:55'),
(394, -978.00, '2024-10-20 14:43:12'),
(395, -978.00, '2024-10-20 14:43:13'),
(396, -978.00, '2024-10-20 14:43:28'),
(397, -978.00, '2024-10-20 14:43:58'),
(398, -978.00, '2024-10-20 14:45:31'),
(399, -978.00, '2024-10-20 14:45:36'),
(400, -978.00, '2024-10-20 14:46:56'),
(401, -978.00, '2024-10-20 14:46:56'),
(402, -978.00, '2024-10-20 14:47:01'),
(403, -978.00, '2024-10-20 14:51:49'),
(404, -978.00, '2024-10-20 14:51:59'),
(405, 0.00, '2024-10-20 14:53:57'),
(406, 0.00, '2024-10-20 14:54:01'),
(407, 0.00, '2024-10-20 14:54:01'),
(408, 0.00, '2024-10-20 14:54:33'),
(409, 0.00, '2024-10-20 14:54:38'),
(410, 0.00, '2024-10-20 14:54:56'),
(411, -978.00, '2024-10-20 14:56:16'),
(412, -978.00, '2024-10-20 14:56:20'),
(413, -978.00, '2024-10-20 14:59:18'),
(414, -978.00, '2024-10-20 14:59:31'),
(415, -978.00, '2024-10-20 15:00:12'),
(416, -978.00, '2024-10-20 15:03:01'),
(417, -978.00, '2024-10-20 15:03:10'),
(418, -978.00, '2024-10-20 15:05:22'),
(419, -978.00, '2024-10-20 15:05:32'),
(420, -978.00, '2024-10-20 15:05:37'),
(421, -978.00, '2024-10-20 15:07:05'),
(422, -978.00, '2024-10-20 15:07:08'),
(423, -978.00, '2024-10-20 15:09:10'),
(424, -978.00, '2024-10-20 15:09:36'),
(425, -978.00, '2024-10-20 15:13:05'),
(426, -978.00, '2024-10-20 15:13:18'),
(427, -978.00, '2024-10-20 15:13:22'),
(428, -978.00, '2024-10-20 15:15:05'),
(429, -978.00, '2024-10-20 15:15:48'),
(430, -978.00, '2024-10-20 15:15:54'),
(431, -978.00, '2024-10-20 15:15:56'),
(432, -978.00, '2024-10-20 15:16:12'),
(433, -978.00, '2024-10-20 15:16:13'),
(434, -978.00, '2024-10-20 15:16:14'),
(435, -978.00, '2024-10-20 15:16:15'),
(436, -978.00, '2024-10-20 15:16:16'),
(437, -978.00, '2024-10-20 15:16:17'),
(438, -978.00, '2024-10-20 15:16:18'),
(439, -978.00, '2024-10-20 15:16:18'),
(440, -978.00, '2024-10-20 15:16:19'),
(441, -978.00, '2024-10-20 15:16:21'),
(442, -978.00, '2024-10-20 15:16:21'),
(443, -978.00, '2024-10-20 15:16:22'),
(444, -978.00, '2024-10-20 15:18:43'),
(445, -978.00, '2024-10-20 15:19:21'),
(446, -978.00, '2024-10-20 15:19:22'),
(447, -978.00, '2024-10-20 15:19:26'),
(448, -978.00, '2024-10-20 15:19:26'),
(449, -978.00, '2024-10-20 15:19:26'),
(450, -978.00, '2024-10-20 15:21:17'),
(451, -978.00, '2024-10-20 15:21:18'),
(452, -978.00, '2024-10-20 15:21:19'),
(453, -978.00, '2024-10-20 15:21:19'),
(454, -978.00, '2024-10-20 15:21:19'),
(455, -978.00, '2024-10-20 15:21:19'),
(456, -978.00, '2024-10-20 15:21:20'),
(457, -978.00, '2024-10-20 15:21:21'),
(458, -978.00, '2024-10-20 15:21:21'),
(459, -978.00, '2024-10-20 15:21:22'),
(460, -978.00, '2024-10-20 15:21:22'),
(461, -978.00, '2024-10-20 15:21:22'),
(462, -978.00, '2024-10-20 15:21:22'),
(463, -978.00, '2024-10-20 15:21:23'),
(464, -978.00, '2024-10-20 15:21:37'),
(465, -978.00, '2024-10-20 15:25:34'),
(466, -978.00, '2024-10-20 15:27:29'),
(467, -978.00, '2024-10-20 15:27:52'),
(468, -978.00, '2024-10-20 15:29:24'),
(469, -978.00, '2024-10-20 15:30:03'),
(470, -978.00, '2024-10-20 15:30:07'),
(471, -978.00, '2024-10-20 15:30:18'),
(472, -978.00, '2024-10-20 15:33:05'),
(473, -978.00, '2024-10-20 15:33:06'),
(474, -978.00, '2024-10-20 15:33:06'),
(475, -978.00, '2024-10-20 15:33:07'),
(476, -978.00, '2024-10-20 15:33:07'),
(477, -978.00, '2024-10-20 15:33:07'),
(478, -978.00, '2024-10-20 15:33:09'),
(479, -978.00, '2024-10-20 15:33:09'),
(480, -978.00, '2024-10-20 15:33:10'),
(481, -978.00, '2024-10-20 15:36:13'),
(482, -978.00, '2024-10-20 15:36:22'),
(483, -978.00, '2024-10-20 15:36:51'),
(484, -978.00, '2024-10-20 15:36:54'),
(485, -978.00, '2024-10-20 15:43:45'),
(486, -978.00, '2024-10-20 15:44:00'),
(487, -978.00, '2024-10-20 15:45:00'),
(488, -978.00, '2024-10-20 15:45:13'),
(489, -978.00, '2024-10-20 15:45:18'),
(490, -978.00, '2024-10-20 15:45:18'),
(491, -978.00, '2024-10-20 15:46:11'),
(492, -978.00, '2024-10-20 15:46:17'),
(493, -978.00, '2024-10-20 15:46:20'),
(494, -978.00, '2024-10-20 15:46:22'),
(495, -978.00, '2024-10-20 15:48:10'),
(496, -978.00, '2024-10-20 15:48:13'),
(497, -978.00, '2024-10-20 15:48:57'),
(498, -978.00, '2024-10-20 15:49:04'),
(499, -978.00, '2024-10-20 15:49:08'),
(500, -978.00, '2024-10-20 15:49:27'),
(501, -978.00, '2024-10-20 15:49:27'),
(502, -978.00, '2024-10-20 15:49:51'),
(503, -978.00, '2024-10-20 15:49:59'),
(504, -978.00, '2024-10-20 15:50:01'),
(505, -978.00, '2024-10-20 15:50:11'),
(506, -978.00, '2024-10-20 15:50:14'),
(507, -978.00, '2024-10-20 15:51:30'),
(508, -978.00, '2024-10-20 15:51:50'),
(509, -978.00, '2024-10-20 15:51:53'),
(510, -978.00, '2024-10-20 15:52:22'),
(511, -978.00, '2024-10-20 15:52:27'),
(512, -978.00, '2024-10-20 15:52:41'),
(513, -978.00, '2024-10-20 15:52:42'),
(514, -978.00, '2024-10-20 15:53:11'),
(515, -978.00, '2024-10-20 15:53:13'),
(516, -978.00, '2024-10-20 15:53:16'),
(517, -978.00, '2024-10-20 15:55:05'),
(518, -978.00, '2024-10-20 15:55:05'),
(519, -978.00, '2024-10-20 15:55:10'),
(520, -978.00, '2024-10-20 15:56:25'),
(521, -978.00, '2024-10-20 15:56:34'),
(522, -978.00, '2024-10-20 15:57:29'),
(523, -978.00, '2024-10-20 15:58:06'),
(524, -978.00, '2024-10-20 15:58:12'),
(525, -978.00, '2024-10-20 15:58:18'),
(526, -978.00, '2024-10-20 15:58:23'),
(527, -978.00, '2024-10-20 16:00:25'),
(528, -978.00, '2024-10-20 16:00:31'),
(529, -978.00, '2024-10-20 16:00:36'),
(530, -978.00, '2024-10-20 16:03:43'),
(531, -978.00, '2024-10-20 16:03:48'),
(532, -978.00, '2024-10-20 16:03:49'),
(533, -978.00, '2024-10-20 16:03:54'),
(534, -978.00, '2024-10-20 16:03:59'),
(535, -978.00, '2024-10-20 16:04:02'),
(536, -978.00, '2024-10-20 16:04:06'),
(537, -978.00, '2024-10-20 16:04:10'),
(538, -978.00, '2024-10-20 16:04:13'),
(539, -978.00, '2024-10-20 16:04:17'),
(540, -978.00, '2024-10-20 16:04:44'),
(541, -978.00, '2024-10-20 16:04:50'),
(542, -978.00, '2024-10-20 16:05:16'),
(543, -978.00, '2024-10-20 16:06:32'),
(544, -978.00, '2024-10-20 16:06:34'),
(545, -978.00, '2024-10-20 16:06:40'),
(546, -978.00, '2024-10-20 16:06:45'),
(547, -978.00, '2024-10-20 16:06:49'),
(548, -978.00, '2024-10-20 16:06:59'),
(549, -978.00, '2024-10-20 16:07:35'),
(550, -978.00, '2024-10-20 16:07:38'),
(551, -978.00, '2024-10-20 16:07:42'),
(552, -978.00, '2024-10-20 16:09:29'),
(553, -978.00, '2024-10-20 16:11:44'),
(554, -978.00, '2024-10-20 16:11:50'),
(555, -978.00, '2024-10-20 16:11:55'),
(556, -978.00, '2024-10-20 16:12:15'),
(557, -978.00, '2024-10-20 16:13:25'),
(558, -978.00, '2024-10-20 16:13:29'),
(559, -978.00, '2024-10-20 16:13:32'),
(560, -978.00, '2024-10-20 16:13:47'),
(561, -978.00, '2024-10-20 16:14:18'),
(562, -978.00, '2024-10-20 16:14:21'),
(563, -978.00, '2024-10-20 16:14:23'),
(564, -978.00, '2024-10-20 16:14:26'),
(565, -978.00, '2024-10-20 16:17:10'),
(566, -978.00, '2024-10-20 16:19:06'),
(567, -978.00, '2024-10-20 16:19:12'),
(568, -978.00, '2024-10-20 16:19:17'),
(569, -978.00, '2024-10-20 16:20:34'),
(570, -978.00, '2024-10-20 16:20:38'),
(571, -978.00, '2024-10-20 16:20:44'),
(572, -978.00, '2024-10-20 16:21:01'),
(573, -978.00, '2024-10-20 16:21:21'),
(574, -978.00, '2024-10-20 16:22:51'),
(575, -978.00, '2024-10-20 16:22:54'),
(576, -978.00, '2024-10-20 16:23:28'),
(577, -978.00, '2024-10-20 16:23:31'),
(578, -978.00, '2024-10-20 16:23:33'),
(579, -978.00, '2024-10-20 16:23:35'),
(580, -978.00, '2024-10-20 16:23:36'),
(581, -978.00, '2024-10-20 16:25:32'),
(582, -978.00, '2024-10-20 16:25:33'),
(583, -978.00, '2024-10-20 16:25:34'),
(584, -978.00, '2024-10-20 16:25:36'),
(585, -978.00, '2024-10-20 16:25:38'),
(586, -978.00, '2024-10-20 16:25:43'),
(587, -978.00, '2024-10-20 16:25:48'),
(588, -978.00, '2024-10-20 16:25:50'),
(589, -978.00, '2024-10-20 16:25:52'),
(590, -978.00, '2024-10-20 16:25:54'),
(591, -978.00, '2024-10-20 16:25:58'),
(592, -978.00, '2024-10-20 16:26:00'),
(593, -978.00, '2024-10-20 16:26:00'),
(594, -978.00, '2024-10-20 16:26:04'),
(595, -978.00, '2024-10-20 16:26:06'),
(596, -978.00, '2024-10-20 16:26:10'),
(597, -978.00, '2024-10-20 16:27:44'),
(598, -978.00, '2024-10-20 16:29:04'),
(599, -978.00, '2024-10-20 16:29:13'),
(600, -978.00, '2024-10-20 16:29:16'),
(601, -978.00, '2024-10-20 16:30:56'),
(602, -978.00, '2024-10-20 16:32:54'),
(603, -978.00, '2024-10-20 16:32:59'),
(604, -978.00, '2024-10-20 16:33:02'),
(605, -978.00, '2024-10-20 16:33:26'),
(606, -978.00, '2024-10-20 16:33:30'),
(607, -978.00, '2024-10-20 16:33:34'),
(608, -978.00, '2024-10-20 16:33:36'),
(609, -978.00, '2024-10-20 16:33:47'),
(610, -978.00, '2024-10-20 16:33:51'),
(611, -978.00, '2024-10-20 16:34:10'),
(612, -978.00, '2024-10-20 16:34:14'),
(613, -978.00, '2024-10-20 16:34:46'),
(614, -978.00, '2024-10-20 16:38:09'),
(615, -978.00, '2024-10-20 16:38:14'),
(616, -978.00, '2024-10-20 16:38:23'),
(617, -978.00, '2024-10-20 16:39:38'),
(618, -978.00, '2024-10-20 16:39:46'),
(619, -978.00, '2024-10-20 16:39:51'),
(620, -978.00, '2024-10-20 16:40:23'),
(621, -978.00, '2024-10-20 16:40:46'),
(622, -978.00, '2024-10-20 16:40:46'),
(623, -978.00, '2024-10-20 16:40:50'),
(624, -978.00, '2024-10-20 16:41:04'),
(625, -978.00, '2024-10-20 16:41:05'),
(626, -978.00, '2024-10-20 16:42:31'),
(627, -978.00, '2024-10-20 16:42:59'),
(628, -978.00, '2024-10-20 16:43:18'),
(629, -978.00, '2024-10-20 16:43:26'),
(630, -978.00, '2024-10-20 16:43:33'),
(631, -858.00, '2024-10-20 16:43:52'),
(632, -738.00, '2024-10-20 16:45:29'),
(633, -738.00, '2024-10-20 16:45:31'),
(634, -738.00, '2024-10-20 16:45:37'),
(635, -738.00, '2024-10-20 16:47:53'),
(636, -738.00, '2024-10-20 16:48:04'),
(637, -608.00, '2024-10-20 16:48:17'),
(638, -608.00, '2024-11-16 01:25:17'),
(639, -608.00, '2024-11-26 04:04:21'),
(640, -488.00, '2024-11-26 23:55:05'),
(641, -488.00, '2024-11-26 23:55:46'),
(642, -488.00, '2024-11-26 23:55:55'),
(643, -488.00, '2024-11-26 23:56:02'),
(644, -488.00, '2024-11-26 23:56:06'),
(645, -328.00, '2024-11-30 00:32:56'),
(646, -328.00, '2024-11-30 00:40:50'),
(647, 3722.00, '2024-12-01 00:08:08'),
(648, 3852.00, '2024-12-01 02:22:48'),
(649, 3852.00, '2024-12-01 02:22:58'),
(650, -978.00, '2024-12-01 02:27:29'),
(651, -688.00, '2024-12-01 02:31:59'),
(652, -688.00, '2024-12-01 02:32:03'),
(653, -688.00, '2024-12-01 02:37:36'),
(654, -688.00, '2024-12-01 02:37:39'),
(655, -688.00, '2024-12-01 02:37:46'),
(656, -688.00, '2024-12-01 02:37:51'),
(657, -688.00, '2024-12-01 02:37:59');

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `transaction_id` int(11) NOT NULL,
  `customerID` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `date` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customer_id` (`customer_id`);

--
-- Indexes for table `categorized_expenses`
--
ALTER TABLE `categorized_expenses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `categorized_purchases`
--
ALTER TABLE `categorized_purchases`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`customerID`);

--
-- Indexes for table `financial_summary`
--
ALTER TABLE `financial_summary`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`id`),
  ADD KEY `supplier_id` (`supplier_id`);

--
-- Indexes for table `login_logs`
--
ALTER TABLE `login_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `payment`
--
ALTER TABLE `payment`
  ADD PRIMARY KEY (`paymentID`),
  ADD KEY `purchaseID` (`purchaseID`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `purchases`
--
ALTER TABLE `purchases`
  ADD PRIMARY KEY (`purchaseID`);

--
-- Indexes for table `receipts`
--
ALTER TABLE `receipts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `customerID` (`customerID`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `store`
--
ALTER TABLE `store`
  ADD PRIMARY KEY (`storeID`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `total_expense`
--
ALTER TABLE `total_expense`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `total_income`
--
ALTER TABLE `total_income`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`transaction_id`),
  ADD KEY `customerID` (`customerID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cart`
--
ALTER TABLE `cart`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `categorized_expenses`
--
ALTER TABLE `categorized_expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `categorized_purchases`
--
ALTER TABLE `categorized_purchases`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `customerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=145;

--
-- AUTO_INCREMENT for table `financial_summary`
--
ALTER TABLE `financial_summary`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `login_logs`
--
ALTER TABLE `login_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=72;

--
-- AUTO_INCREMENT for table `payment`
--
ALTER TABLE `payment`
  MODIFY `paymentID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `purchases`
--
ALTER TABLE `purchases`
  MODIFY `purchaseID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=145;

--
-- AUTO_INCREMENT for table `receipts`
--
ALTER TABLE `receipts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT for table `staff`
--
ALTER TABLE `staff`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `store`
--
ALTER TABLE `store`
  MODIFY `storeID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `total_expense`
--
ALTER TABLE `total_expense`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=540;

--
-- AUTO_INCREMENT for table `total_income`
--
ALTER TABLE `total_income`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=658;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `transaction_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`);

--
-- Constraints for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD CONSTRAINT `suppliers_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `inventory` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`customerID`) REFERENCES `customers` (`customerID`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
