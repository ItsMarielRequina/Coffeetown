-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 12, 2024 at 06:06 AM
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
(70, 'ma', '18', '2024-10-11 15:55:50'),
(71, 'sda', '1', '2024-10-11 16:01:11'),
(72, 'kharl', '09111115156', '2024-10-11 17:30:30'),
(73, 'sdasda', '09123456789', '2024-10-11 18:12:25'),
(74, 'as', '09123456789', '2024-10-11 18:13:57'),
(75, 'as', '09123456789', '2024-10-11 19:34:23'),
(76, 'as', '09123456789', '2024-10-11 19:34:53'),
(77, 'as', '09123456789', '2024-10-11 19:40:52'),
(78, 'as', '09123456789', '2024-10-12 03:25:10');

-- --------------------------------------------------------

--
-- Table structure for table `expenses`
--

CREATE TABLE `expenses` (
  `id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `order_quantity` int(11) NOT NULL,
  `total_cost` decimal(10,2) NOT NULL,
  `order_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `supplier_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `expenses`
--

INSERT INTO `expenses` (`id`, `product_id`, `order_quantity`, `total_cost`, `order_date`, `supplier_id`) VALUES
(95, 1, 1, 100.00, '2024-10-12 01:03:19', NULL),
(96, 2, 1, 120.00, '2024-10-12 01:03:21', NULL),
(97, 3, 1, 110.00, '2024-10-12 01:03:22', NULL),
(98, 1, 1, 100.00, '2024-10-12 01:36:52', NULL),
(99, 1, 2, 200.00, '2024-10-12 01:43:43', NULL),
(100, 1, 2, 200.00, '2024-10-12 01:51:51', NULL),
(101, 1, 1, 100.00, '2024-10-12 01:52:00', NULL),
(102, 1, 1, 100.00, '2024-10-12 01:52:02', NULL),
(103, 1, 1, 100.00, '2024-10-12 01:52:36', NULL),
(104, 1, 1, 100.00, '2024-10-12 01:53:58', NULL),
(105, 1, 1, 100.00, '2024-10-12 01:54:22', NULL),
(106, 2, 1, 120.00, '2024-10-12 03:01:23', NULL),
(107, 2, 1, 120.00, '2024-10-12 03:01:48', NULL);

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
  `stock_supply` int(11) DEFAULT 100
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inventory`
--

INSERT INTO `inventory` (`id`, `product_name`, `raw_material_cost`, `labor_cost`, `overhead_cost`, `packaging_cost`, `price`, `quantity`, `stock_supply`) VALUES
(1, 'Classic Milk Tea', 30.00, 10.00, 5.00, 2.00, 100.00, 4, 15),
(2, 'Brown Sugar Milk Tea', 35.00, 10.00, 5.00, 2.00, 120.00, 42, 95),
(3, 'Taro Milk Tea', 32.00, 10.00, 5.00, 2.00, 110.00, 39, 84),
(4, 'Wintermelon Milk Tea', 34.00, 10.00, 5.00, 2.00, 115.00, 40, 90),
(5, 'Matcha Milk Tea', 38.00, 10.00, 5.00, 2.00, 130.00, 42, 82),
(6, 'Okinawa Milk Tea', 36.00, 10.00, 5.00, 2.00, 125.00, 45, 95),
(7, 'Hokkaido Milk Tea', 35.00, 10.00, 5.00, 2.00, 120.00, 43, 93),
(8, 'Thai Milk Tea', 32.00, 10.00, 5.00, 2.00, 110.00, 50, 100),
(9, 'Chocolate Milk Tea', 31.00, 10.00, 5.00, 2.00, 105.00, 50, 100),
(10, 'Jasmine Milk Tea', 34.00, 10.00, 5.00, 2.00, 115.00, 50, 100),
(11, 'Espresso', 20.00, 10.00, 5.00, 1.00, 80.00, 50, 100),
(12, 'Americano', 18.00, 10.00, 5.00, 1.00, 90.00, 50, 100),
(13, 'Cappuccino', 30.00, 10.00, 5.00, 2.00, 120.00, 50, 100),
(14, 'Latte', 30.00, 10.00, 5.00, 2.00, 130.00, 50, 100),
(15, 'Mocha', 35.00, 10.00, 5.00, 2.00, 140.00, 47, 97),
(16, 'Macchiato', 33.00, 10.00, 5.00, 2.00, 135.00, 50, 100),
(17, 'Caramel Latte', 37.00, 10.00, 5.00, 2.00, 145.00, 50, 100),
(18, 'Flat White', 34.00, 10.00, 5.00, 2.00, 125.00, 51, 100);

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
(32, 6, '2024-10-11 15:46:27'),
(33, 6, '2024-10-11 15:46:43');

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
(78, 70, 'Caramel Latte', 4, '2024-10-11 23:55:50', 145.00, 580.00),
(79, 71, 'Cappuccino', 1, '2024-10-12 00:01:11', 120.00, 120.00),
(80, 72, 'Espresso', 1, '2024-10-12 01:30:30', 80.00, 80.00),
(81, 72, 'Americano', 1, '2024-10-12 01:30:30', 90.00, 90.00),
(82, 73, 'Americano', 2, '2024-10-12 02:12:25', 90.00, 180.00),
(83, 73, 'Cappuccino', 1, '2024-10-12 02:12:25', 120.00, 120.00),
(84, 73, 'Latte', 1, '2024-10-12 02:12:25', 130.00, 130.00),
(85, 74, 'Americano', 10, '2024-10-12 02:13:57', 90.00, 460.00),
(86, 75, 'Taro Milk Tea', 1, '2024-10-12 03:34:23', 110.00, 110.00),
(87, 76, 'Latte', 1, '2024-10-12 03:34:53', 130.00, 130.00),
(88, 76, 'Cappuccino', 1, '2024-10-12 03:34:53', 120.00, 120.00),
(89, 76, 'Flat White', 1, '2024-10-12 03:34:53', 125.00, 125.00),
(90, 76, 'Caramel Latte', 1, '2024-10-12 03:34:53', 145.00, 145.00),
(91, 76, 'Macchiato', 1, '2024-10-12 03:34:53', 135.00, 135.00),
(92, 77, 'Matcha Milk Tea', 2, '2024-10-12 03:40:52', 130.00, 260.00),
(93, 78, 'Cappuccino', 1, '2024-10-12 11:25:10', 120.00, 120.00),
(94, 78, 'Americano', 1, '2024-10-12 11:25:10', 90.00, 90.00),
(95, 78, 'Espresso', 1, '2024-10-12 11:25:10', 80.00, 80.00),
(96, 78, 'Latte', 2, '2024-10-12 11:25:10', 130.00, 260.00);

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
(1, 'testuser', 'test@example.com', '$2y$10$U7y5HcYg7zwgy1z1E2nDpe1Gzz1st8gbcE7U/y7yRXI8VZGFkhoKG', '2024-09-29 13:56:38'),
(2, 'mariel', 'mariel@gmail.com', '$2y$10$fuvDNQBTLc8fDqbUiK8kSOEULCECfTv9TQHrLl6HAy.SQI478nBg.', '2024-09-29 14:03:31'),
(3, 'mayie', 'hey@gmail.com', '$2y$10$BE/x0mg400/PqgGtc9VEHufgK3Al5UUrTgS0jyRHH0iVtLBsCEyIq', '2024-09-29 14:04:20'),
(4, 'abc', 'abc@gmail.com', '$2y$10$Pc7l4B2nlMowQKUSDIsG6.8V6gEWlHfeL9yMzRz2WQXkjAzgPb42q', '2024-09-29 14:20:53'),
(5, '123', '123@gmail.com', '$2y$10$tWWDzgU.0CFOmFUGMXku9erZyhdADCoy3qUI8mHhSOwBMaU/hMGNO', '2024-09-29 15:48:08'),
(6, 'zect', 'zect@gmail.com', '$2y$10$NDROrs.orIvwVGwJuMxVteYQ71XG7GYkY.J0sGisaPjayROvszGRC', '2024-09-29 15:48:28'),
(7, 'zachary', 'zjpt@gmail.com', '$2y$10$MC/ZTH6fkWp4qi5XKpJAUO46xLSJ0GGmSLr1i5ZswNchutNmQdLAe', '2024-09-30 02:37:03'),
(8, 'au', 'au@gmail.com', '$2y$10$iU4E4T8gkV5qaS2ByBe.V.gn4GgaFJmhx8Yom61RBVHEjdtsMmw4y', '2024-09-30 06:17:03'),
(9, 'stephen', 'stephen@gmail.com', '$2y$10$GA.iTShqUfRix.OdgjvrZ.tjizbz.sSmdSn59wNLjvnPz4Rs5eBuO', '2024-10-10 05:49:08'),
(10, 'meljay', 'sayaw@gmail.com', '$2y$10$Xm7DSt.20Ey40UpCQrv9AOUIW.Hai3B8pB/H8B6ZMu7pz0AXKGDZi', '2024-10-10 17:04:20');

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
(1, 1, 'Supplier A', 100),
(2, 2, 'Supplier B', 100),
(3, 3, 'Supplier C', 100),
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
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`customerID`);

--
-- Indexes for table `expenses`
--
ALTER TABLE `expenses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `login_logs`
--
ALTER TABLE `login_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `purchases`
--
ALTER TABLE `purchases`
  ADD PRIMARY KEY (`purchaseID`),
  ADD KEY `customerID` (`customerID`);

--
-- Indexes for table `staff`
--
ALTER TABLE `staff`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `product_id` (`product_id`);

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
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `customerID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=79;

--
-- AUTO_INCREMENT for table `expenses`
--
ALTER TABLE `expenses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=108;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `login_logs`
--
ALTER TABLE `login_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `purchases`
--
ALTER TABLE `purchases`
  MODIFY `purchaseID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=97;

--
-- AUTO_INCREMENT for table `staff`
--
ALTER TABLE `staff`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `transaction_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `purchases`
--
ALTER TABLE `purchases`
  ADD CONSTRAINT `purchases_ibfk_1` FOREIGN KEY (`customerID`) REFERENCES `customers` (`customerID`) ON DELETE CASCADE;

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
