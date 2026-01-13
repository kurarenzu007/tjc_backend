
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


CREATE TABLE `app_settings` (
  `id` int(11) NOT NULL,
  `store_name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `contact_number` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `cash_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `gcash_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `cod_enabled` tinyint(1) NOT NULL DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `app_settings`
--

INSERT INTO `app_settings` (`id`, `store_name`, `address`, `contact_number`, `email`, `cash_enabled`, `gcash_enabled`, `cod_enabled`, `updated_at`) VALUES
(1, 'Your Store', 'Address', '09123456789', 'store@example.com', 1, 1, 0, '2025-10-20 17:07:48');

-- --------------------------------------------------------

--
-- Table structure for table `brands`
--

CREATE TABLE `brands` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `brands`
--

INSERT INTO `brands` (`id`, `name`, `description`, `created_at`) VALUES
(1, 'Bosch', 'German automotive parts manufacturer', '2025-10-11 11:11:18'),
(2, 'Akebono', 'Japanese brake system specialist', '2025-10-11 11:11:18'),
(3, 'KYB', 'Shock absorber and suspension specialist', '2025-10-11 11:11:18'),
(4, 'Gates', 'Belt and hose manufacturer', '2025-10-11 11:11:18'),
(5, 'Moog', 'Steering and suspension parts', '2025-10-11 11:11:18'),
(6, 'Honda', 'Automotive manufacturer', '2025-10-20 16:11:25'),
(7, 'Hyundai', 'Automotive manufacturer', '2025-10-20 16:11:25'),
(8, 'Isuzu', 'Automotive manufacturer', '2025-10-20 16:11:25'),
(9, 'Kia', 'Automotive manufacturer', '2025-10-20 16:11:25'),
(10, 'Mitsubishi', 'Automotive manufacturer', '2025-10-20 16:11:25'),
(11, 'Daewoo', 'Automotive manufacturer', '2025-10-20 16:11:25');

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `description`, `created_at`) VALUES
(1, 'Engine & Cooling', 'Engine parts and cooling system components', '2025-10-11 11:11:18'),
(2, 'Transmission', 'Transmission and drivetrain parts', '2025-10-11 11:11:18'),
(3, 'Suspension & Steering', 'Suspension and steering system components', '2025-10-11 11:11:18'),
(4, 'Brake Parts', 'Braking system components', '2025-10-11 11:11:18'),
(5, 'Body & Exterior', 'Body panels and exterior accessories', '2025-10-11 11:11:18');

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE `inventory` (
  `id` int(11) NOT NULL,
  `product_id` varchar(20) NOT NULL,
  `stock` int(11) DEFAULT 0,
  `reorder_point` int(11) DEFAULT 10,
  `supplier_id` int(11) DEFAULT NULL,
  `last_restock_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inventory`
--

INSERT INTO `inventory` (`id`, `product_id`, `stock`, `reorder_point`, `supplier_id`, `last_restock_date`, `created_at`, `updated_at`) VALUES
(4, 'PRD-006', 55, 12, NULL, '2025-11-11 02:20:19', '2025-10-11 13:58:28', '2025-11-11 02:20:19'),
(5, 'PRD-001', 18, 10, NULL, '2025-11-11 02:19:47', '2025-10-11 14:02:07', '2025-11-11 02:19:47'),
(6, 'PRD-002', 48, 12, NULL, '2025-10-11 14:02:12', '2025-10-11 14:02:12', '2025-10-14 19:24:58'),
(7, 'PRD-003', 3, 10, NULL, '2025-10-11 14:02:17', '2025-10-11 14:02:17', '2025-10-14 19:24:58'),
(8, 'PRD-004', 7, 10, NULL, '2025-11-05 15:10:38', '2025-10-11 14:02:24', '2025-11-05 15:10:38'),
(9, 'PRD-005', 50, 10, NULL, '2025-10-11 14:02:30', '2025-10-11 14:02:30', '2025-10-11 14:02:30'),
(10, 'P007', 12, 10, NULL, '2025-10-14 19:49:40', '2025-10-14 19:49:40', '2025-10-14 19:50:07'),
(11, 'P008', 20, 5, NULL, '2025-11-10 17:53:35', '2025-10-14 20:22:59', '2025-11-10 17:53:35');

-- --------------------------------------------------------

--
-- Table structure for table `inventory_transactions`
--

CREATE TABLE `inventory_transactions` (
  `id` int(11) NOT NULL,
  `transaction_id` varchar(20) NOT NULL,
  `inventory_id` int(11) NOT NULL,
  `product_id` varchar(20) NOT NULL,
  `transaction_type` enum('in','out') NOT NULL,
  `quantity` int(11) NOT NULL,
  `serial_number` varchar(100) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `transaction_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `inventory_transactions`
--

INSERT INTO `inventory_transactions` (`id`, `transaction_id`, `inventory_id`, `product_id`, `transaction_type`, `quantity`, `serial_number`, `notes`, `transaction_date`, `created_by`, `created_at`, `updated_at`) VALUES
(2, 'TRX-1760191108980-26', 4, 'PRD-006', 'in', 20, NULL, 'Stock update through admin interface', '2025-10-11 13:58:28', NULL, '2025-10-11 13:58:28', '2025-10-11 13:58:28'),
(3, 'TRX-1760191113392-50', 4, 'PRD-006', 'in', 20, NULL, 'Stock update through admin interface', '2025-10-11 13:58:33', NULL, '2025-10-11 13:58:33', '2025-10-11 13:58:33'),
(4, 'TRX-1760191117733-91', 4, 'PRD-006', 'in', 20, NULL, 'Stock update through admin interface', '2025-10-11 13:58:37', NULL, '2025-10-11 13:58:37', '2025-10-11 13:58:37'),
(5, 'TRX-1760191327021-61', 5, 'PRD-001', 'in', 20, NULL, 'Stock update through admin interface', '2025-10-11 14:02:07', NULL, '2025-10-11 14:02:07', '2025-10-11 14:02:07'),
(6, 'TRX-1760191332680-36', 6, 'PRD-002', 'in', 50, NULL, 'Stock update through admin interface', '2025-10-11 14:02:12', NULL, '2025-10-11 14:02:12', '2025-10-11 14:02:12'),
(7, 'TRX-1760191337996-89', 7, 'PRD-003', 'in', 7, NULL, 'Stock update through admin interface', '2025-10-11 14:02:17', NULL, '2025-10-11 14:02:17', '2025-10-11 14:02:17'),
(8, 'TRX-1760191344980-90', 8, 'PRD-004', 'in', 8, NULL, 'Stock update through admin interface', '2025-10-11 14:02:24', NULL, '2025-10-11 14:02:24', '2025-10-11 14:02:24'),
(9, 'TRX-1760191350347-19', 9, 'PRD-005', 'in', 50, NULL, 'Stock update through admin interface', '2025-10-11 14:02:30', NULL, '2025-10-11 14:02:30', '2025-10-11 14:02:30'),
(10, 'TRX-1760365637255-52', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:27:17', NULL, '2025-10-13 14:27:17', '2025-10-13 14:27:17'),
(11, 'TRX-1760365639003-78', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:27:19', NULL, '2025-10-13 14:27:19', '2025-10-13 14:27:19'),
(12, 'TRX-1760365640674-46', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:27:20', NULL, '2025-10-13 14:27:20', '2025-10-13 14:27:20'),
(13, 'TXN1760365968777', 4, 'PRD-006', 'out', 3, NULL, 'Sale deduction', '2025-10-13 14:32:48', 'System', '2025-10-13 14:32:48', '2025-10-13 14:32:48'),
(14, 'TRX-1760365971070-56', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:32:51', NULL, '2025-10-13 14:32:51', '2025-10-13 14:32:51'),
(15, 'TRX-1760365988969-73', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:33:08', NULL, '2025-10-13 14:33:08', '2025-10-13 14:33:08'),
(16, 'TRX-1760365989272-72', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:33:09', NULL, '2025-10-13 14:33:09', '2025-10-13 14:33:09'),
(17, 'TRX-1760365990152-53', 6, 'PRD-002', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:33:10', NULL, '2025-10-13 14:33:10', '2025-10-13 14:33:10'),
(18, 'TRX-1760365991289-22', 7, 'PRD-003', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:33:11', NULL, '2025-10-13 14:33:11', '2025-10-13 14:33:11'),
(19, 'TRX-1760365991777-31', 8, 'PRD-004', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:33:11', NULL, '2025-10-13 14:33:11', '2025-10-13 14:33:11'),
(20, 'TXN1760366003469', 4, 'PRD-006', 'out', 1, NULL, 'Sale deduction', '2025-10-13 14:33:23', 'System', '2025-10-13 14:33:23', '2025-10-13 14:33:23'),
(21, 'TXN1760366003470', 5, 'PRD-001', 'out', 1, NULL, 'Sale deduction', '2025-10-13 14:33:23', 'System', '2025-10-13 14:33:23', '2025-10-13 14:33:23'),
(22, 'TXN1760366003471', 6, 'PRD-002', 'out', 1, NULL, 'Sale deduction', '2025-10-13 14:33:23', 'System', '2025-10-13 14:33:23', '2025-10-13 14:33:23'),
(23, 'TXN1760366003472', 7, 'PRD-003', 'out', 1, NULL, 'Sale deduction', '2025-10-13 14:33:23', 'System', '2025-10-13 14:33:23', '2025-10-13 14:33:23'),
(24, 'TXN1760366003474', 8, 'PRD-004', 'out', 1, NULL, 'Sale deduction', '2025-10-13 14:33:23', 'System', '2025-10-13 14:33:23', '2025-10-13 14:33:23'),
(25, 'TRX-1760366005406-33', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:33:25', NULL, '2025-10-13 14:33:25', '2025-10-13 14:33:25'),
(26, 'TRX-1760366005504-39', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:33:25', NULL, '2025-10-13 14:33:25', '2025-10-13 14:33:25'),
(27, 'TRX-1760366005561-32', 6, 'PRD-002', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:33:25', NULL, '2025-10-13 14:33:25', '2025-10-13 14:33:25'),
(28, 'TRX-1760366005616-13', 7, 'PRD-003', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:33:25', NULL, '2025-10-13 14:33:25', '2025-10-13 14:33:25'),
(29, 'TRX-1760366005668-18', 8, 'PRD-004', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-13 14:33:25', NULL, '2025-10-13 14:33:25', '2025-10-13 14:33:25'),
(30, 'TRX-1760463945175-78', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 17:45:45', NULL, '2025-10-14 17:45:45', '2025-10-14 17:45:45'),
(31, 'TRX-1760463946843-30', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 17:45:46', NULL, '2025-10-14 17:45:46', '2025-10-14 17:45:46'),
(32, 'TXN1760463967164', 4, 'PRD-006', 'out', 1, NULL, 'Sale deduction', '2025-10-14 17:46:07', 'System', '2025-10-14 17:46:07', '2025-10-14 17:46:07'),
(33, 'TXN1760463967166', 5, 'PRD-001', 'out', 1, NULL, 'Sale deduction', '2025-10-14 17:46:07', 'System', '2025-10-14 17:46:07', '2025-10-14 17:46:07'),
(34, 'TRX-1760463968613-21', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 17:46:08', NULL, '2025-10-14 17:46:08', '2025-10-14 17:46:08'),
(35, 'TRX-1760463968864-12', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 17:46:08', NULL, '2025-10-14 17:46:08', '2025-10-14 17:46:08'),
(36, 'TRX-1760469872806-88', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:24:32', NULL, '2025-10-14 19:24:32', '2025-10-14 19:24:32'),
(37, 'TRX-1760469873682-13', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:24:33', NULL, '2025-10-14 19:24:33', '2025-10-14 19:24:33'),
(38, 'TRX-1760469874218-78', 6, 'PRD-002', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:24:34', NULL, '2025-10-14 19:24:34', '2025-10-14 19:24:34'),
(39, 'TRX-1760469874833-22', 7, 'PRD-003', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:24:34', NULL, '2025-10-14 19:24:34', '2025-10-14 19:24:34'),
(40, 'TRX-1760469877360-43', 7, 'PRD-003', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:24:37', NULL, '2025-10-14 19:24:37', '2025-10-14 19:24:37'),
(41, 'TRX-1760469877528-73', 7, 'PRD-003', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:24:37', NULL, '2025-10-14 19:24:37', '2025-10-14 19:24:37'),
(42, 'TXN1760469898982', 4, 'PRD-006', 'out', 1, NULL, 'Sale deduction', '2025-10-14 19:24:58', 'System', '2025-10-14 19:24:58', '2025-10-14 19:24:58'),
(43, 'TXN1760469898984', 5, 'PRD-001', 'out', 1, NULL, 'Sale deduction', '2025-10-14 19:24:58', 'System', '2025-10-14 19:24:58', '2025-10-14 19:24:58'),
(44, 'TXN1760469898985', 6, 'PRD-002', 'out', 1, NULL, 'Sale deduction', '2025-10-14 19:24:58', 'System', '2025-10-14 19:24:58', '2025-10-14 19:24:58'),
(45, 'TXN1760469898986', 7, 'PRD-003', 'out', 3, NULL, 'Sale deduction', '2025-10-14 19:24:58', 'System', '2025-10-14 19:24:58', '2025-10-14 19:24:58'),
(46, 'TRX-1760469900939-68', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:25:00', NULL, '2025-10-14 19:25:00', '2025-10-14 19:25:00'),
(47, 'TRX-1760469900984-34', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:25:00', NULL, '2025-10-14 19:25:00', '2025-10-14 19:25:00'),
(48, 'TRX-1760469901033-39', 6, 'PRD-002', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:25:01', NULL, '2025-10-14 19:25:01', '2025-10-14 19:25:01'),
(49, 'TRX-1760469901066-31', 7, 'PRD-003', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:25:01', NULL, '2025-10-14 19:25:01', '2025-10-14 19:25:01'),
(50, 'TRX-1760471226186-39', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:47:06', NULL, '2025-10-14 19:47:06', '2025-10-14 19:47:06'),
(51, 'TRX-1760471226316-13', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:47:06', NULL, '2025-10-14 19:47:06', '2025-10-14 19:47:06'),
(52, 'TXN1760471241220', 4, 'PRD-006', 'out', 1, NULL, 'Sale deduction', '2025-10-14 19:47:21', 'System', '2025-10-14 19:47:21', '2025-10-14 19:47:21'),
(53, 'TRX-1760471242032-66', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:47:22', NULL, '2025-10-14 19:47:22', '2025-10-14 19:47:22'),
(54, 'TRX-1760471380113-46', 10, 'P007', 'in', 15, NULL, 'Stock update through admin interface', '2025-10-14 19:49:40', NULL, '2025-10-14 19:49:40', '2025-10-14 19:49:40'),
(55, 'TRX-1760471386703-73', 10, 'P007', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:49:46', NULL, '2025-10-14 19:49:46', '2025-10-14 19:49:46'),
(56, 'TRX-1760471387240-25', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:49:47', NULL, '2025-10-14 19:49:47', '2025-10-14 19:49:47'),
(57, 'TRX-1760471388127-26', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:49:48', NULL, '2025-10-14 19:49:48', '2025-10-14 19:49:48'),
(58, 'TXN1760471407001', 10, 'P007', 'out', 3, NULL, 'Sale deduction', '2025-10-14 19:50:07', 'System', '2025-10-14 19:50:07', '2025-10-14 19:50:07'),
(59, 'TXN1760471407066', 4, 'PRD-006', 'out', 1, NULL, 'Sale deduction', '2025-10-14 19:50:07', 'System', '2025-10-14 19:50:07', '2025-10-14 19:50:07'),
(60, 'TXN1760471407068', 5, 'PRD-001', 'out', 1, NULL, 'Sale deduction', '2025-10-14 19:50:07', 'System', '2025-10-14 19:50:07', '2025-10-14 19:50:07'),
(61, 'TRX-1760471408390-33', 10, 'P007', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:50:08', NULL, '2025-10-14 19:50:08', '2025-10-14 19:50:08'),
(62, 'TRX-1760471408643-18', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:50:08', NULL, '2025-10-14 19:50:08', '2025-10-14 19:50:08'),
(63, 'TRX-1760471408717-19', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 19:50:08', NULL, '2025-10-14 19:50:08', '2025-10-14 19:50:08'),
(64, 'TRX-1760473379838-69', 11, 'P008', 'in', 5, NULL, 'Stock update through admin interface', '2025-10-14 20:22:59', NULL, '2025-10-14 20:22:59', '2025-10-14 20:22:59'),
(65, 'TRX-1760473387651-83', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 20:23:07', NULL, '2025-10-14 20:23:07', '2025-10-14 20:23:07'),
(66, 'TXN1760473403347', 11, 'P008', 'out', 1, NULL, 'Sale deduction', '2025-10-14 20:23:23', 'System', '2025-10-14 20:23:23', '2025-10-14 20:23:23'),
(67, 'TRX-1760473405304-81', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 20:23:25', NULL, '2025-10-14 20:23:25', '2025-10-14 20:23:25'),
(68, 'TRX-1760473961187-83', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 20:32:41', NULL, '2025-10-14 20:32:41', '2025-10-14 20:32:41'),
(69, 'TRX-1760473962011-21', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 20:32:42', NULL, '2025-10-14 20:32:42', '2025-10-14 20:32:42'),
(70, 'TRX-1760473962164-14', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 20:32:42', NULL, '2025-10-14 20:32:42', '2025-10-14 20:32:42'),
(71, 'TXN1760473973533', 11, 'P008', 'out', 1, NULL, 'Sale deduction', '2025-10-14 20:32:53', 'System', '2025-10-14 20:32:53', '2025-10-14 20:32:53'),
(72, 'TXN1760473973551', 4, 'PRD-006', 'out', 1, NULL, 'Sale deduction', '2025-10-14 20:32:53', 'System', '2025-10-14 20:32:53', '2025-10-14 20:32:53'),
(73, 'TRX-1760473974505-17', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 20:32:54', NULL, '2025-10-14 20:32:54', '2025-10-14 20:32:54'),
(74, 'TRX-1760473974611-53', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-14 20:32:54', NULL, '2025-10-14 20:32:54', '2025-10-14 20:32:54'),
(75, 'TRX-1760930016003-15', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-20 03:13:36', NULL, '2025-10-20 03:13:36', '2025-10-20 03:13:36'),
(76, 'TRX-1760930019902-14', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-20 03:13:39', NULL, '2025-10-20 03:13:39', '2025-10-20 03:13:39'),
(77, 'TRX-1760976698198-53', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-20 16:11:38', NULL, '2025-10-20 16:11:38', '2025-10-20 16:11:38'),
(78, 'TXN1760976708332', 11, 'P008', 'out', 2, NULL, 'Sale deduction', '2025-10-20 16:11:48', 'System', '2025-10-20 16:11:48', '2025-10-20 16:11:48'),
(79, 'TRX-1760976709605-71', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-10-20 16:11:49', NULL, '2025-10-20 16:11:49', '2025-10-20 16:11:49'),
(80, 'TRX-1762150242529-28', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-03 06:10:42', NULL, '2025-11-03 06:10:42', '2025-11-03 06:10:42'),
(81, 'TRX-1762153704572-86', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-03 07:08:24', NULL, '2025-11-03 07:08:24', '2025-11-03 07:08:24'),
(82, 'TRX-1762153708494-78', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-03 07:08:28', NULL, '2025-11-03 07:08:28', '2025-11-03 07:08:28'),
(83, 'TRX-1762153815048-11', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-03 07:10:15', NULL, '2025-11-03 07:10:15', '2025-11-03 07:10:15'),
(84, 'TXN1762153833016', 11, 'P008', 'out', 1, NULL, 'Sale deduction', '2025-11-03 07:10:33', 'System', '2025-11-03 07:10:33', '2025-11-03 07:10:33'),
(85, 'TRX-1762153838392-50', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-03 07:10:38', NULL, '2025-11-03 07:10:38', '2025-11-03 07:10:38'),
(86, 'TRX-1762153967163-40', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-03 07:12:47', NULL, '2025-11-03 07:12:47', '2025-11-03 07:12:47'),
(87, 'TRX-1762153967336-77', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-03 07:12:47', NULL, '2025-11-03 07:12:47', '2025-11-03 07:12:47'),
(88, 'TXN1762154042228', 4, 'PRD-006', 'out', 2, NULL, 'Sale deduction', '2025-11-03 07:14:02', 'System', '2025-11-03 07:14:02', '2025-11-03 07:14:02'),
(89, 'TRX-1762154050547-23', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-03 07:14:10', NULL, '2025-11-03 07:14:10', '2025-11-03 07:14:10'),
(90, 'TRX-1762154125458-44', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-03 07:15:25', NULL, '2025-11-03 07:15:25', '2025-11-03 07:15:25'),
(91, 'TRX-1762354281353-8', 4, 'PRD-006', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 14:51:21', 'Coco M.', '2025-11-05 14:51:21', '2025-11-05 14:51:21'),
(92, 'TRX-1762354292639-59', 4, 'PRD-006', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 14:51:32', 'Coco M.', '2025-11-05 14:51:32', '2025-11-05 14:51:32'),
(93, 'TRX-1762354325148-44', 4, 'PRD-006', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 14:52:05', 'Coco M.', '2025-11-05 14:52:05', '2025-11-05 14:52:05'),
(94, 'TRX-1762354338698-20', 4, 'PRD-006', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 14:52:18', 'Coco M.', '2025-11-05 14:52:18', '2025-11-05 14:52:18'),
(95, 'TRX-1762354352506-47', 11, 'P008', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 14:52:32', 'Coco M.', '2025-11-05 14:52:32', '2025-11-05 14:52:32'),
(96, 'TRX-1762355158738-70', 8, 'PRD-004', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 15:05:58', 'Coco M.', '2025-11-05 15:05:58', '2025-11-05 15:05:58'),
(97, 'TRX-1762355186271-75', 4, 'PRD-006', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 15:06:26', 'Coco M.', '2025-11-05 15:06:26', '2025-11-05 15:06:26'),
(98, 'TRX-1762355191762-24', 4, 'PRD-006', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 15:06:31', 'Coco M.', '2025-11-05 15:06:31', '2025-11-05 15:06:31'),
(99, 'TRX-1762355196138-92', 4, 'PRD-006', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 15:06:36', 'Coco M.', '2025-11-05 15:06:36', '2025-11-05 15:06:36'),
(100, 'TRX-1762355208654-88', 4, 'PRD-006', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 15:06:48', 'Coco M.', '2025-11-05 15:06:48', '2025-11-05 15:06:48'),
(101, 'TRX-1762355232702-60', 4, 'PRD-006', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 15:07:12', 'Coco M.', '2025-11-05 15:07:12', '2025-11-05 15:07:12'),
(102, 'TRX-1762355259595-67', 8, 'PRD-004', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 15:07:39', 'Coco M.', '2025-11-05 15:07:39', '2025-11-05 15:07:39'),
(103, 'TRX-1762355426701-78', 4, 'PRD-006', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 15:10:26', 'Coco M.', '2025-11-05 15:10:26', '2025-11-05 15:10:26'),
(104, 'TRX-1762355434900-44', 8, 'PRD-004', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 15:10:34', 'Coco M.', '2025-11-05 15:10:34', '2025-11-05 15:10:34'),
(105, 'TRX-1762355438503-68', 8, 'PRD-004', 'out', 0, NULL, 'Reorder point updated', '2025-11-05 15:10:38', 'Coco M.', '2025-11-05 15:10:38', '2025-11-05 15:10:38'),
(106, 'TRX-1762615530657-66', 8, 'PRD-004', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:25:30', 'System', '2025-11-08 15:25:30', '2025-11-08 15:25:30'),
(107, 'TRX-1762615531376-24', 8, 'PRD-004', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:25:31', 'System', '2025-11-08 15:25:31', '2025-11-08 15:25:31'),
(108, 'TRX-1762616307092-43', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:38:27', 'System', '2025-11-08 15:38:27', '2025-11-08 15:38:27'),
(109, 'TRX-1762616307203-30', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:38:27', 'System', '2025-11-08 15:38:27', '2025-11-08 15:38:27'),
(110, 'TRX-1762616307408-59', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:38:27', 'System', '2025-11-08 15:38:27', '2025-11-08 15:38:27'),
(111, 'TRX-1762616307575-61', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:38:27', 'System', '2025-11-08 15:38:27', '2025-11-08 15:38:27'),
(112, 'TRX-1762616307756-48', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:38:27', 'System', '2025-11-08 15:38:27', '2025-11-08 15:38:27'),
(113, 'TRX-1762616315973-99', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:38:35', 'System', '2025-11-08 15:38:35', '2025-11-08 15:38:35'),
(114, 'TRX-1762616316144-78', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:38:36', 'System', '2025-11-08 15:38:36', '2025-11-08 15:38:36'),
(115, 'TRX-1762616319417-19', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:38:39', 'System', '2025-11-08 15:38:39', '2025-11-08 15:38:39'),
(116, 'TRX-1762616319600-85', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:38:39', 'System', '2025-11-08 15:38:39', '2025-11-08 15:38:39'),
(117, 'TRX-1762616322682-41', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:38:42', 'System', '2025-11-08 15:38:42', '2025-11-08 15:38:42'),
(118, 'TRX-1762616836982-79', 8, 'PRD-004', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:47:16', 'System', '2025-11-08 15:47:16', '2025-11-08 15:47:16'),
(119, 'TRX-1762616838099-49', 8, 'PRD-004', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:47:18', 'System', '2025-11-08 15:47:18', '2025-11-08 15:47:18'),
(120, 'TRX-1762617350209-71', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:55:50', 'System', '2025-11-08 15:55:50', '2025-11-08 15:55:50'),
(121, 'TRX-1762617350379-41', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:55:50', 'System', '2025-11-08 15:55:50', '2025-11-08 15:55:50'),
(122, 'TRX-1762617350493-22', 5, 'PRD-001', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 15:55:50', 'System', '2025-11-08 15:55:50', '2025-11-08 15:55:50'),
(123, 'TRX-1762621386573-7', 11, 'P008', 'in', 1, NULL, 'Stock In Entry - Supplier: ednis | Received by: Coco M. | Serial: asdasd', '2025-11-08 09:00:00', 'Coco M.', '2025-11-08 17:03:06', '2025-11-08 17:03:06'),
(124, 'TRX-1762621938127-65', 11, 'P008', 'in', 2, NULL, 'Stock In Entry - Supplier: ednis | Received by: Coco M. | Serial: asdasd', '2025-11-07 21:11:00', 'Coco M.', '2025-11-08 17:12:18', '2025-11-08 17:12:18'),
(125, 'TRX-1762624832179-88', 11, 'P008', 'in', 1, NULL, 'Return from order SL251021001 - Wrong Item', '2025-11-08 18:00:32', 'Coco M.', '2025-11-08 18:00:32', '2025-11-08 18:00:32'),
(126, 'TRX-1762624888715-52', 4, 'PRD-006', 'in', 1, NULL, 'Return from order SL251015006 - Wrong Item', '2025-11-08 18:01:28', 'Coco M.', '2025-11-08 18:01:28', '2025-11-08 18:01:28'),
(127, 'TRX-1762624926880-58', 11, 'P008', 'in', 1, NULL, 'Return from order SL251015005 - Defective/Damaged', '2025-11-08 18:02:06', 'Coco M.', '2025-11-08 18:02:06', '2025-11-08 18:02:06'),
(128, 'TRX-1762630185464-12', 8, 'PRD-004', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 19:29:45', 'System', '2025-11-08 19:29:45', '2025-11-08 19:29:45'),
(129, 'TRX-1762630185642-40', 8, 'PRD-004', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 19:29:45', 'System', '2025-11-08 19:29:45', '2025-11-08 19:29:45'),
(130, 'TRX-1762630185810-21', 8, 'PRD-004', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 19:29:45', 'System', '2025-11-08 19:29:45', '2025-11-08 19:29:45'),
(131, 'TRX-1762630186138-46', 8, 'PRD-004', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 19:29:46', 'System', '2025-11-08 19:29:46', '2025-11-08 19:29:46'),
(132, 'TRX-1762630186291-68', 8, 'PRD-004', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 19:29:46', 'System', '2025-11-08 19:29:46', '2025-11-08 19:29:46'),
(133, 'TRX-1762630186455-17', 8, 'PRD-004', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 19:29:46', 'System', '2025-11-08 19:29:46', '2025-11-08 19:29:46'),
(134, 'TRX-1762630186606-96', 8, 'PRD-004', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 19:29:46', 'System', '2025-11-08 19:29:46', '2025-11-08 19:29:46'),
(135, 'TRX-1762630188363-56', 6, 'PRD-002', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 19:29:48', 'System', '2025-11-08 19:29:48', '2025-11-08 19:29:48'),
(136, 'TRX-1762630188522-72', 6, 'PRD-002', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 19:29:48', 'System', '2025-11-08 19:29:48', '2025-11-08 19:29:48'),
(137, 'TRX-1762630188667-15', 6, 'PRD-002', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 19:29:48', 'System', '2025-11-08 19:29:48', '2025-11-08 19:29:48'),
(138, 'TRX-1762630188826-70', 6, 'PRD-002', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-08 19:29:48', 'System', '2025-11-08 19:29:48', '2025-11-08 19:29:48'),
(139, 'TRX-1762794457024-31', 4, 'PRD-006', 'in', 1, NULL, 'Bulk Stock In - Supplier: asd | Serial: N/A | Received by: Coco M.', '2025-11-10 17:07:37', 'Coco M.', '2025-11-10 17:07:37', '2025-11-10 17:07:37'),
(140, 'TRX-1762794500159-50', 4, 'PRD-006', '', 1, NULL, 'Return to Supplier - Supplier: asd | Serial: asd-asd | Returned by: Coco M.', '2025-11-10 09:08:00', 'Coco M.', '2025-11-10 17:08:20', '2025-11-10 17:08:20'),
(141, 'TRX-1762794743619-17', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:23', 'System', '2025-11-10 17:12:23', '2025-11-10 17:12:23'),
(142, 'TRX-1762794745978-79', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:25', 'System', '2025-11-10 17:12:25', '2025-11-10 17:12:25'),
(143, 'TRX-1762794746264-48', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:26', 'System', '2025-11-10 17:12:26', '2025-11-10 17:12:26'),
(144, 'TRX-1762794746407-61', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:26', 'System', '2025-11-10 17:12:26', '2025-11-10 17:12:26'),
(145, 'TRX-1762794746568-57', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:26', 'System', '2025-11-10 17:12:26', '2025-11-10 17:12:26'),
(146, 'TRX-1762794746727-73', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:26', 'System', '2025-11-10 17:12:26', '2025-11-10 17:12:26'),
(147, 'TRX-1762794746895-68', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:26', 'System', '2025-11-10 17:12:26', '2025-11-10 17:12:26'),
(148, 'TRX-1762794747047-21', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:27', 'System', '2025-11-10 17:12:27', '2025-11-10 17:12:27'),
(149, 'TRX-1762794747223-43', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:27', 'System', '2025-11-10 17:12:27', '2025-11-10 17:12:27'),
(150, 'TRX-1762794747400-16', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:27', 'System', '2025-11-10 17:12:27', '2025-11-10 17:12:27'),
(151, 'TRX-1762794747567-25', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:27', 'System', '2025-11-10 17:12:27', '2025-11-10 17:12:27'),
(152, 'TRX-1762794747743-27', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:27', 'System', '2025-11-10 17:12:27', '2025-11-10 17:12:27'),
(153, 'TRX-1762794747928-91', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:27', 'System', '2025-11-10 17:12:27', '2025-11-10 17:12:27'),
(154, 'TRX-1762794748087-50', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:28', 'System', '2025-11-10 17:12:28', '2025-11-10 17:12:28'),
(155, 'TRX-1762794748271-33', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:28', 'System', '2025-11-10 17:12:28', '2025-11-10 17:12:28'),
(156, 'TRX-1762794749344-10', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:12:29', 'System', '2025-11-10 17:12:29', '2025-11-10 17:12:29'),
(157, 'TRX-1762794962903-52', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:16:02', 'System', '2025-11-10 17:16:02', '2025-11-10 17:16:02'),
(158, 'TRX-1762795073547-17', 4, 'PRD-006', 'in', 1, NULL, 'Bulk Stock In - Supplier: asdasd | Serial: N/A | Received by: Coco M.', '2025-11-10 17:17:53', 'Coco M.', '2025-11-10 17:17:53', '2025-11-10 17:17:53'),
(159, 'TRX-1762795080751-18', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:18:00', 'System', '2025-11-10 17:18:00', '2025-11-10 17:18:00'),
(160, 'TRX-1762795084025-37', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:18:04', 'System', '2025-11-10 17:18:04', '2025-11-10 17:18:04'),
(161, 'TRX-1762795413661-93', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:23:33', 'System', '2025-11-10 17:23:33', '2025-11-10 17:23:33'),
(162, 'TRX-1762795415392-54', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:23:35', 'System', '2025-11-10 17:23:35', '2025-11-10 17:23:35'),
(163, 'TRX-1762795416137-49', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:23:36', 'System', '2025-11-10 17:23:36', '2025-11-10 17:23:36'),
(164, 'TRX-1762795417528-32', 4, 'PRD-006', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:23:37', 'System', '2025-11-10 17:23:37', '2025-11-10 17:23:37'),
(165, 'TRX-1762795479205-68', 11, 'P008', 'in', 1, 'ASD123', 'Bulk Stock In - Supplier: ASD | Serial: N/A | Received by: Coco M.', '2025-11-10 17:24:39', 'Coco M.', '2025-11-10 17:24:39', '2025-11-10 17:24:39'),
(166, 'TRX-1762795491530-37', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:24:51', 'System', '2025-11-10 17:24:51', '2025-11-10 17:24:51'),
(167, 'TRX-1762795492887-68', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:24:52', 'System', '2025-11-10 17:24:52', '2025-11-10 17:24:52'),
(168, 'TRX-1762795493390-57', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:24:53', 'System', '2025-11-10 17:24:53', '2025-11-10 17:24:53'),
(169, 'TRX-1762795493591-82', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:24:53', 'System', '2025-11-10 17:24:53', '2025-11-10 17:24:53'),
(170, 'TRX-1762795493776-65', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:24:53', 'System', '2025-11-10 17:24:53', '2025-11-10 17:24:53'),
(171, 'TRX-1762795493951-99', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:24:53', 'System', '2025-11-10 17:24:53', '2025-11-10 17:24:53'),
(172, 'TRX-1762795495462-25', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:24:55', 'System', '2025-11-10 17:24:55', '2025-11-10 17:24:55'),
(173, 'TRX-1762795613188-58', 11, 'P008', '', 1, 'ASD123', 'Return to Supplier - Supplier: ASD | Serial: ASD123 | Returned by: Coco M.', '2025-11-10 09:26:00', 'Coco M.', '2025-11-10 17:26:53', '2025-11-10 17:26:53'),
(174, 'TRX-1762795792804-14', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:29:52', 'System', '2025-11-10 17:29:52', '2025-11-10 17:29:52'),
(175, 'TRX-1762795795891-24', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:29:55', 'System', '2025-11-10 17:29:55', '2025-11-10 17:29:55'),
(176, 'TRX-1762796132123-59', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:35:32', 'System', '2025-11-10 17:35:32', '2025-11-10 17:35:32'),
(177, 'TRX-1762796133767-57', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:35:33', 'System', '2025-11-10 17:35:33', '2025-11-10 17:35:33'),
(178, 'TRX-1762796572404-74', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:42:52', 'System', '2025-11-10 17:42:52', '2025-11-10 17:42:52'),
(179, 'TRX-1762796600930-27', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:43:20', 'System', '2025-11-10 17:43:20', '2025-11-10 17:43:20'),
(180, 'TRX-1762796647459-78', 11, 'P008', 'in', 3, 'asd124', 'Bulk Stock In - Supplier: asd | Serial: N/A | Received by: Coco M.', '2025-11-10 17:44:07', 'Coco M.', '2025-11-10 17:44:07', '2025-11-10 17:44:07'),
(181, 'TRX-1762796696475-25', 11, 'P008', 'in', 2, 'TB12', 'Bulk Stock In - Supplier: HAHAHA | Serial: N/A | Received by: Coco M.', '2025-11-10 17:44:56', 'Coco M.', '2025-11-10 17:44:56', '2025-11-10 17:44:56'),
(182, 'TRX-1762796735993-47', 11, 'P008', 'in', 2, 'TB32', 'Bulk Stock In - Supplier: ASD | Serial: N/A | Received by: Coco M.', '2025-11-10 17:45:35', 'Coco M.', '2025-11-10 17:45:35', '2025-11-10 17:45:35'),
(183, 'TRX-1762796744479-66', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:45:44', 'System', '2025-11-10 17:45:44', '2025-11-10 17:45:44'),
(184, 'TRX-1762796873740-16', 11, 'P008', 'in', 2, '1231', 'Bulk Stock In - Supplier: 132 | Serial: N/A | Received by: Coco M.', '2025-11-10 17:47:53', 'Coco M.', '2025-11-10 17:47:53', '2025-11-10 17:47:53'),
(185, 'TRX-1762796956178-75', 11, 'P008', 'in', 3, 'ASD111', 'Bulk Stock In - Supplier: HONDATKT | Serial: N/A | Received by: Coco M.', '2025-11-10 17:49:16', 'Coco M.', '2025-11-10 17:49:16', '2025-11-10 17:49:16'),
(186, 'TRX-1762796997580-71', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:49:57', 'System', '2025-11-10 17:49:57', '2025-11-10 17:49:57'),
(187, 'TRX-1762797027763-56', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:50:27', 'System', '2025-11-10 17:50:27', '2025-11-10 17:50:27'),
(188, 'TRX-1762797035133-34', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:50:35', 'System', '2025-11-10 17:50:35', '2025-11-10 17:50:35'),
(189, 'TRX-1762797157425-67', 11, 'P008', 'in', 1, 'ASD-123', 'Bulk Stock In - Supplier: ASDHAHAH | Serial: N/A | Received by: Coco M.', '2025-11-10 17:52:37', 'Coco M.', '2025-11-10 17:52:37', '2025-11-10 17:52:37'),
(190, 'TRX-1762797215055-90', 11, 'P008', 'in', 2, 'TBC-001', 'Bulk Stock In - Supplier: HondaSUpplier | Serial: N/A | Received by: Coco M.', '2025-11-10 17:53:35', 'Coco M.', '2025-11-10 17:53:35', '2025-11-10 17:53:35'),
(191, 'TRX-1762797460147-68', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 17:57:40', 'System', '2025-11-10 17:57:40', '2025-11-10 17:57:40'),
(192, 'TRX-1762797729652-15', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 18:02:09', 'System', '2025-11-10 18:02:09', '2025-11-10 18:02:09'),
(193, 'TRX-1762797753650-34', 11, 'P008', 'out', 0, NULL, 'Stock update through admin interface', '2025-11-10 18:02:33', 'System', '2025-11-10 18:02:33', '2025-11-10 18:02:33'),
(194, 'TRX-1762827587152-38', 5, 'PRD-001', 'in', 2, 'EOF001', 'Bulk Stock In - Supplier: Misaki | Serial: N/A | Received by: Coco M.', '2025-11-11 02:19:47', 'Coco M.', '2025-11-11 02:19:47', '2025-11-11 02:19:47'),
(195, 'TRX-1762827619595-32', 4, 'PRD-006', 'in', 4, 'HAHAHA01', 'Bulk Stock In - Supplier: SECRETSHOP | Serial: N/A | Received by: Coco M.', '2025-11-11 02:20:19', 'Coco M.', '2025-11-11 02:20:19', '2025-11-11 02:20:19');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `product_id` varchar(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `brand` varchar(100) NOT NULL,
  `category` varchar(100) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `vehicle_compatibility` text DEFAULT NULL,
  `requires_serial` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 if product requires serial number tracking'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `product_id`, `name`, `brand`, `category`, `price`, `status`, `description`, `image`, `created_at`, `updated_at`, `vehicle_compatibility`, `requires_serial`) VALUES
(1, 'PRD-001', 'Engine Oil Filter', 'Akebono', 'Engine & Cooling', 4500.00, 'Active', 'High-quality engine oil filter for various vehicle models', '/uploads/image-1761028296231-713914561.jpg', '2025-10-11 11:11:17', '2025-11-10 18:01:41', NULL, 1),
(2, 'PRD-002', 'Brake Pad Set', 'Honda', 'Brake Parts', 1200.00, 'Active', 'Front brake pad set for sedans and SUVs', '/uploads/image-1761028335428-830091597.jpg', '2025-10-11 11:11:17', '2025-11-10 18:01:52', NULL, 1),
(3, 'PRD-003', 'Shock Absorber', 'KYB', 'Suspension & Steering', 3500.00, 'Active', 'Rear shock absorber for pickup trucks', '/uploads/image-1761028355485-181145703.jpg', '2025-10-11 11:11:17', '2025-11-10 18:01:52', NULL, 1),
(4, 'PRD-004', 'Radiator Hose', 'Gates', 'Engine & Cooling', 680.00, 'Active', 'Upper radiator hose for diesel engines', '/uploads/image-1760189191563-350730914.jpg', '2025-10-11 11:11:17', '2025-11-10 18:01:52', NULL, 1),
(5, 'PRD-005', 'CV Joint Boot', 'Moog', 'Transmission', 320.00, 'Active', 'CV joint boot kit with clamps and grease', '/uploads/image-1760189149859-123979443.jpg', '2025-10-11 11:11:17', '2025-11-10 18:01:52', NULL, 1),
(6, 'PRD-006', 'GHAHAHAHA', 'Akebono', 'Brake Parts', 1600.00, 'Active', 'hahaha', '/uploads/image-1761028234398-382271106.jpg', '2025-10-11 12:10:49', '2025-11-10 18:01:41', NULL, 1),
(7, 'P007', 'GAGO', 'Akebono', 'Brake Parts', 5000.00, 'Inactive', 'GAGOGAGAOGAOGAO', '/uploads/image-1760471370435-377723803.jpg', '2025-10-14 19:49:30', '2025-11-10 18:01:52', NULL, 1),
(8, 'P008', 'Turbocharger', 'Akebono', 'Transmission', 50000.00, 'Active', 'this turbo is shit\r\n', '/uploads/image-1760473363109-453700899.jpg', '2025-10-14 20:22:43', '2025-11-10 18:01:41', 'Toyota hilux', 1);

-- --------------------------------------------------------

--
-- Table structure for table `refund_transactions`
--

CREATE TABLE `refund_transactions` (
  `id` int(11) NOT NULL,
  `transaction_id` varchar(50) NOT NULL,
  `return_id` varchar(50) NOT NULL,
  `order_id` int(11) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `refund_method` varchar(50) NOT NULL,
  `transaction_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `notes` text DEFAULT NULL,
  `processed_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `refund_transactions`
--

INSERT INTO `refund_transactions` (`id`, `transaction_id`, `return_id`, `order_id`, `amount`, `refund_method`, `transaction_date`, `notes`, `processed_by`, `created_at`) VALUES
(1, 'RFND-1762623468039-514', 'RET-1762623468008-1230', 11, 1600.00, 'Cash', '2025-11-08 17:37:48', 'Return processed: Defective/Damaged', 'Coco M.', '2025-11-08 17:37:48'),
(2, 'RFND-1762623512841-434', 'RET-1762623512668-2762', 10, 50000.00, 'Cash', '2025-11-08 17:38:32', 'Return processed: Not as Described', 'Coco M.', '2025-11-08 17:38:32'),
(3, 'RFND-1762624832182-8561', 'RET-1762624832134-3383', 9, 50000.00, 'Cash', '2025-11-08 18:00:32', 'Return processed: Wrong Item - ahahahah', 'Coco M.', '2025-11-08 18:00:32'),
(4, 'RFND-1762624888717-7979', 'RET-1762624888586-1420', 8, 1600.00, 'Cash', '2025-11-08 18:01:28', 'Return processed: Wrong Item', 'Coco M.', '2025-11-08 18:01:28'),
(5, 'RFND-1762624926882-376', 'RET-1762624926859-7610', 7, 50000.00, 'Cash', '2025-11-08 18:02:06', 'Return processed: Defective/Damaged', 'Coco M.', '2025-11-08 18:02:06');

-- --------------------------------------------------------

--
-- Table structure for table `returns`
--

CREATE TABLE `returns` (
  `id` int(11) NOT NULL,
  `return_id` varchar(50) NOT NULL,
  `order_id` int(11) NOT NULL,
  `sale_number` varchar(50) NOT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `return_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `return_reason` enum('Defective/Damaged','Wrong Item','Not as Described','Customer Changed Mind','Compatibility Issue','Other') NOT NULL,
  `refund_method` enum('Cash','Store Credit','Original Payment Method') NOT NULL,
  `reference_number` varchar(100) DEFAULT NULL,
  `refund_amount` decimal(10,2) NOT NULL,
  `restocked` tinyint(1) NOT NULL DEFAULT 1,
  `photo_proof` varchar(255) DEFAULT NULL,
  `additional_notes` text DEFAULT NULL,
  `processed_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `returns`
--

INSERT INTO `returns` (`id`, `return_id`, `order_id`, `sale_number`, `customer_name`, `return_date`, `return_reason`, `refund_method`, `reference_number`, `refund_amount`, `restocked`, `photo_proof`, `additional_notes`, `processed_by`, `created_at`, `updated_at`) VALUES
(1, 'RET-1762623468008-1230', 11, 'SL251103002', 'aa aa aa', '2025-11-08 17:37:48', 'Defective/Damaged', 'Cash', NULL, 1600.00, 0, NULL, NULL, 'Coco M.', '2025-11-08 17:37:48', '2025-11-08 17:37:48'),
(2, 'RET-1762623512668-2762', 10, 'SL251103001', 'ka haha gago', '2025-11-08 17:38:32', 'Not as Described', 'Cash', NULL, 50000.00, 0, NULL, NULL, 'Coco M.', '2025-11-08 17:38:32', '2025-11-08 17:38:32'),
(3, 'RET-1762624832134-3383', 9, 'SL251021001', 'asd', '2025-11-08 18:00:32', 'Wrong Item', 'Cash', NULL, 50000.00, 1, '/uploads/returns/return-1762624832114-8032.png', 'ahahahah', 'Coco M.', '2025-11-08 18:00:32', '2025-11-08 18:00:32'),
(4, 'RET-1762624888586-1420', 8, 'SL251015006', 'renz_test2', '2025-11-08 18:01:28', 'Wrong Item', 'Cash', NULL, 1600.00, 1, '/uploads/returns/return-1762624888581-9937.png', NULL, 'Coco M.', '2025-11-08 18:01:28', '2025-11-08 18:01:28'),
(5, 'RET-1762624926859-7610', 7, 'SL251015005', 'Renztesting', '2025-11-08 18:02:06', 'Defective/Damaged', 'Cash', NULL, 50000.00, 1, '/uploads/returns/return-1762624926854-9734.png', NULL, 'Coco M.', '2025-11-08 18:02:06', '2025-11-08 18:02:06');

-- --------------------------------------------------------

--
-- Table structure for table `return_items`
--

CREATE TABLE `return_items` (
  `id` int(11) NOT NULL,
  `return_id` varchar(50) NOT NULL,
  `sale_item_id` int(11) NOT NULL,
  `product_id` varchar(20) NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `sku` varchar(50) DEFAULT NULL,
  `quantity` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `return_items`
--

INSERT INTO `return_items` (`id`, `return_id`, `sale_item_id`, `product_id`, `product_name`, `sku`, `quantity`, `price`, `subtotal`, `created_at`) VALUES
(1, 'RET-1762623468008-1230', 22, 'PRD-006', 'GHAHAHAHA', NULL, 1, 1600.00, 1600.00, '2025-11-08 17:37:48'),
(2, 'RET-1762623512668-2762', 21, 'P008', 'Turbocharger', NULL, 1, 50000.00, 50000.00, '2025-11-08 17:38:32'),
(3, 'RET-1762624832134-3383', 20, 'P008', 'Turbocharger', NULL, 1, 50000.00, 50000.00, '2025-11-08 18:00:32'),
(4, 'RET-1762624888586-1420', 19, 'PRD-006', 'GHAHAHAHA', NULL, 1, 1600.00, 1600.00, '2025-11-08 18:01:28'),
(5, 'RET-1762624926859-7610', 17, 'P008', 'Turbocharger', NULL, 1, 50000.00, 50000.00, '2025-11-08 18:02:06');

-- --------------------------------------------------------

--
-- Table structure for table `sales`
--

CREATE TABLE `sales` (
  `id` int(11) NOT NULL,
  `sale_number` varchar(50) NOT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `customer_last_name` varchar(100) DEFAULT NULL,
  `customer_first_name` varchar(100) DEFAULT NULL,
  `customer_middle_name` varchar(100) DEFAULT NULL,
  `contact` varchar(50) DEFAULT NULL,
  `payment` varchar(50) NOT NULL,
  `delivery_type` enum('In-store','Company Delivery') NOT NULL DEFAULT 'In-store',
  `payment_status` enum('Paid','Unpaid','Refunded','Partially Refunded') NOT NULL DEFAULT 'Unpaid',
  `payment_reference` varchar(64) DEFAULT NULL,
  `total` decimal(10,2) NOT NULL,
  `refund_amount` decimal(10,2) DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `return_date` timestamp NULL DEFAULT NULL,
  `return_reason` text DEFAULT NULL,
  `status` enum('Pending','Processing','Completed','Cancelled','Returned','Partially Returned') DEFAULT 'Pending',
  `address` varchar(255) DEFAULT NULL,
  `delivery_proof` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sales`
--

INSERT INTO `sales` (`id`, `sale_number`, `customer_name`, `customer_last_name`, `customer_first_name`, `customer_middle_name`, `contact`, `payment`, `delivery_type`, `payment_status`, `payment_reference`, `total`, `refund_amount`, `created_at`, `return_date`, `return_reason`, `status`, `address`, `delivery_proof`) VALUES
(1, 'SL251013001', 'doggy', 'doggy', 'doggy', NULL, '09090909009', 'GCash', 'In-store', 'Paid', NULL, 4800.00, 0.00, '2025-10-13 14:32:48', NULL, NULL, 'Completed', NULL, NULL),
(2, 'SL251013002', 'gagsti', 'gagsti', 'gagsti', NULL, '121313113213223', 'Cash', 'In-store', 'Paid', NULL, 11480.00, 0.00, '2025-10-13 14:33:23', NULL, NULL, 'Cancelled', NULL, NULL),
(3, 'SL251015001', 'clarence', 'clarence', 'clarence', NULL, '09174205498', 'Cash', 'In-store', 'Paid', NULL, 6100.00, 0.00, '2025-10-14 17:46:06', NULL, NULL, 'Completed', NULL, NULL),
(4, 'SL251015002', 'testing_oct15', 'testing_oct15', 'testing_oct15', NULL, '09090909090', 'Cash', 'In-store', 'Paid', NULL, 17800.00, 0.00, '2025-10-14 19:24:58', NULL, NULL, 'Completed', NULL, NULL),
(5, 'SL251015003', 'asd', 'asd', 'asd', NULL, 'asd', 'GCash', 'In-store', 'Paid', NULL, 1600.00, 0.00, '2025-10-14 19:47:21', NULL, NULL, 'Completed', NULL, NULL),
(6, 'SL251015004', 'Renz', 'Renz', 'Renz', NULL, '09521784542', 'Cash', 'In-store', 'Paid', NULL, 21100.00, 0.00, '2025-10-14 19:50:06', NULL, NULL, 'Completed', NULL, NULL),
(7, 'SL251015005', 'Renztesting', 'Renztesting', 'Renztesting', NULL, '1231231321', 'Cash', 'In-store', 'Refunded', NULL, 50000.00, 50000.00, '2025-10-14 20:23:22', '2025-11-08 18:02:06', 'Defective/Damaged', 'Returned', NULL, NULL),
(8, 'SL251015006', 'renz_test2', 'renz_test2', 'renz_test2', NULL, '12221231321', 'Cash', 'In-store', 'Partially Refunded', NULL, 51600.00, 1600.00, '2025-10-14 20:32:53', '2025-11-08 18:01:28', 'Wrong Item', 'Partially Returned', NULL, NULL),
(9, 'SL251021001', 'asd', 'asd', 'asd', NULL, 'asd', 'Cash', 'In-store', 'Partially Refunded', NULL, 100000.00, 50000.00, '2025-10-20 16:11:48', '2025-11-08 18:00:32', 'Wrong Item', 'Partially Returned', 'asdas, Pampanga', NULL),
(10, 'SL251103001', 'ka haha gago', 'gago', 'ka', NULL, '09009', 'Cash', 'In-store', 'Refunded', NULL, 50000.00, 50000.00, '2025-11-03 07:10:33', '2025-11-08 17:38:32', 'Not as Described', 'Returned', 'asdasdsa, Manila', '/uploads/delivery-1762266722631-277806068.png'),
(11, 'SL251103002', 'aa aa aa', NULL, NULL, NULL, '123', 'Cash', 'In-store', 'Partially Refunded', NULL, 3200.00, 1600.00, '2025-11-03 07:14:02', '2025-11-08 17:37:48', 'Defective/Damaged', 'Partially Returned', 'asdsa, Manila', '/uploads/delivery-1762266541233-534785757.PNG'),
(12, 'SL251110001', 'Juan Dela Cruz', 'Dela Cruz', 'Juan', NULL, '09171234567', 'GCash', 'Company Delivery', 'Paid', 'REF998877665', 15500.00, 0.00, '2025-11-10 01:15:22', NULL, NULL, 'Completed', 'Block 5 Lot 2, Quezon City', '/uploads/delivery-1762266888123-998877.jpg'),
(13, 'SL251112001', 'Maria Clara', 'Clara', 'Maria', NULL, '09189876543', 'Cash', 'In-store', 'Unpaid', NULL, 8250.50, 0.00, '2025-11-12 03:30:45', NULL, NULL, 'Pending', NULL, NULL),
(14, 'SL251114001', 'Ricardo Dalisay', 'Dalisay', 'Ricardo', 'J', '09225554444', 'GCash', 'Company Delivery', 'Paid', 'REF112233445', 3400.00, 0.00, '2025-11-14 06:45:10', NULL, NULL, 'Completed', 'Unit 404, Makati Executive Tower, Makati', NULL),
(15, 'SL251115001', 'Leonor Rivera', 'Rivera', 'Leonor', NULL, '09998887777', 'Cash', 'In-store', 'Unpaid', NULL, 1200.00, 0.00, '2025-11-15 08:20:33', NULL, NULL, 'Cancelled', NULL, NULL),
(16, 'SL251116001', 'Pedro Penduko', 'Penduko', 'Pedro', NULL, '09151112222', 'Cash', 'In-store', 'Partially Refunded', NULL, 75000.00, 25000.00, '2025-11-16 02:00:55', '2025-11-18 01:00:00', 'Defective/Damaged', 'Partially Returned', '789 Coconut Ave, Pasig City', '/uploads/delivery-1762266999444-112233.PNG');

-- --------------------------------------------------------

--
-- Table structure for table `sale_items`
--

CREATE TABLE `sale_items` (
  `id` int(11) NOT NULL,
  `sale_id` int(11) NOT NULL,
  `product_id` varchar(20) NOT NULL,
  `product_name` varchar(100) NOT NULL,
  `brand` varchar(100) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `quantity` int(11) NOT NULL,
  `returned_quantity` int(11) DEFAULT 0,
  `subtotal` decimal(10,2) NOT NULL,
  `serial_numbers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Array of serial numbers for this sale item' CHECK (json_valid(`serial_numbers`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sale_items`
--

INSERT INTO `sale_items` (`id`, `sale_id`, `product_id`, `product_name`, `brand`, `price`, `quantity`, `returned_quantity`, `subtotal`, `serial_numbers`) VALUES
(1, 1, 'PRD-006', 'GHAHAHAHA', 'Akebono', 1600.00, 3, 0, 4800.00, NULL),
(2, 2, 'PRD-006', 'GHAHAHAHA', 'Akebono', 1600.00, 1, 0, 1600.00, NULL),
(3, 2, 'PRD-001', 'Engine Oil Filter', 'Akebono', 4500.00, 1, 0, 4500.00, NULL),
(4, 2, 'PRD-002', 'Brake Pad Set', 'Akebono', 1200.00, 1, 0, 1200.00, NULL),
(5, 2, 'PRD-003', 'Shock Absorber', 'KYB', 3500.00, 1, 0, 3500.00, NULL),
(6, 2, 'PRD-004', 'Radiator Hose', 'Gates', 680.00, 1, 0, 680.00, NULL),
(7, 3, 'PRD-006', 'GHAHAHAHA', 'Akebono', 1600.00, 1, 0, 1600.00, NULL),
(8, 3, 'PRD-001', 'Engine Oil Filter', 'Akebono', 4500.00, 1, 0, 4500.00, NULL),
(9, 4, 'PRD-006', 'GHAHAHAHA', 'Akebono', 1600.00, 1, 0, 1600.00, NULL),
(10, 4, 'PRD-001', 'Engine Oil Filter', 'Akebono', 4500.00, 1, 0, 4500.00, NULL),
(11, 4, 'PRD-002', 'Brake Pad Set', 'Akebono', 1200.00, 1, 0, 1200.00, NULL),
(12, 4, 'PRD-003', 'Shock Absorber', 'KYB', 3500.00, 3, 0, 10500.00, NULL),
(13, 5, 'PRD-006', 'GHAHAHAHA', 'Akebono', 1600.00, 1, 0, 1600.00, NULL),
(14, 6, 'P007', 'GAGO', 'Akebono', 5000.00, 3, 0, 15000.00, NULL),
(15, 6, 'PRD-006', 'GHAHAHAHA', 'Akebono', 1600.00, 1, 0, 1600.00, NULL),
(16, 6, 'PRD-001', 'Engine Oil Filter', 'Akebono', 4500.00, 1, 0, 4500.00, NULL),
(17, 7, 'P008', 'Turbocharger', 'Akebono', 50000.00, 1, 1, 50000.00, NULL),
(18, 8, 'P008', 'Turbocharger', 'Akebono', 50000.00, 1, 0, 50000.00, NULL),
(19, 8, 'PRD-006', 'GHAHAHAHA', 'Akebono', 1600.00, 1, 1, 1600.00, NULL),
(20, 9, 'P008', 'Turbocharger', 'Akebono', 50000.00, 2, 1, 100000.00, NULL),
(21, 10, 'P008', 'Turbocharger', 'Akebono', 50000.00, 1, 1, 50000.00, NULL),
(22, 11, 'PRD-006', 'GHAHAHAHA', 'Akebono', 1600.00, 2, 1, 3200.00, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `serial_numbers`
--

CREATE TABLE `serial_numbers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `serial_number` varchar(100) NOT NULL,
  `product_id` varchar(20) NOT NULL,
  `status` enum('available','sold','returned','defective') NOT NULL DEFAULT 'available',
  `sale_id` int(11) DEFAULT NULL,
  `sale_item_id` int(11) DEFAULT NULL,
  `supplier_id` int(11) DEFAULT NULL, -- [NEW COLUMN]
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_serial_per_product` (`serial_number`,`product_id`),
  KEY `idx_product_id` (`product_id`),
  KEY `idx_serial_number` (`serial_number`),
  KEY `idx_status` (`status`),
  KEY `idx_sale_id` (`sale_id`),
  KEY `fk_serial_supplier` (`supplier_id`), -- [NEW INDEX]
  CONSTRAINT `fk_serial_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_serial_sale` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_serial_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`id`) ON DELETE SET NULL -- [NEW FK]
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `serial_numbers`
--

INSERT INTO `serial_numbers` (`id`, `serial_number`, `product_id`, `status`, `sale_id`, `sale_item_id`, `notes`, `created_at`, `updated_at`) VALUES
(1, 'ASD-123', 'P008', 'available', NULL, NULL, 'Stock In - ASDHAHAH', '2025-11-10 17:52:37', '2025-11-10 17:52:37'),
(2, 'TBC-001', 'P008', 'available', NULL, NULL, 'Stock In - HondaSUpplier', '2025-11-10 17:53:35', '2025-11-10 17:53:35'),
(3, 'smpl-001', 'PRD-006', 'available', NULL, NULL, 'Stock In - sample', '2025-11-10 17:56:10', '2025-11-10 17:56:10'),
(4, 'smpl-002', 'PRD-006', 'available', NULL, NULL, 'Stock In - sample', '2025-11-10 17:56:10', '2025-11-10 17:56:10'),
(5, 'SAMPLE-123', 'P008', 'available', NULL, NULL, 'Stock In - sample2', '2025-11-10 17:59:55', '2025-11-10 17:59:55'),
(6, 'SAMPLE-321', 'P008', 'available', NULL, NULL, 'Stock In - sample2', '2025-11-10 17:59:55', '2025-11-10 17:59:55'),
(7, 'gago', 'P008', 'available', NULL, NULL, 'Stock In - gago', '2025-11-10 18:01:11', '2025-11-10 18:01:11'),
(8, 'TURBO-001', 'P008', 'available', NULL, NULL, 'Stock In - TURBOPH', '2025-11-10 18:03:55', '2025-11-10 18:03:55'),
(9, 'TURBO-002', 'P008', 'available', NULL, NULL, 'Stock In - TURBOPH', '2025-11-10 18:03:55', '2025-11-10 18:03:55'),
(10, 'TURBO-003', 'P008', 'available', NULL, NULL, 'Stock In - TURBOPH', '2025-11-10 18:06:34', '2025-11-10 18:06:34'),
(11, 'TURBO-004', 'P008', 'available', NULL, NULL, 'Stock In - TURBOPH', '2025-11-10 18:06:34', '2025-11-10 18:06:34'),
(12, 'TURBO-005', 'P008', 'available', NULL, NULL, 'Stock In - TURBOPH', '2025-11-10 18:07:32', '2025-11-10 18:07:32'),
(13, 'TURBO-006', 'P008', 'available', NULL, NULL, 'Stock In - TURBOPH', '2025-11-10 18:07:32', '2025-11-10 18:07:32'),
(15, 'EOF001', 'PRD-001', 'available', NULL, NULL, 'Stock In - Misaki', '2025-11-11 02:19:46', '2025-11-11 02:19:46'),
(16, 'EOF002', 'PRD-001', 'available', NULL, NULL, 'Stock In - Misaki', '2025-11-11 02:19:46', '2025-11-11 02:19:46'),
(17, 'HAHAHA01', 'PRD-006', 'available', NULL, NULL, 'Stock In - SECRETSHOP', '2025-11-11 02:20:19', '2025-11-11 02:20:19'),
(18, 'HAHAHA02', 'PRD-006', 'available', NULL, NULL, 'Stock In - SECRETSHOP', '2025-11-11 02:20:19', '2025-11-11 02:20:19'),
(19, 'HAHAHA03', 'PRD-006', 'available', NULL, NULL, 'Stock In - SECRETSHOP', '2025-11-11 02:20:19', '2025-11-11 02:20:19'),
(20, 'HAHAHA04', 'PRD-006', 'available', NULL, NULL, 'Stock In - SECRETSHOP', '2025-11-11 02:20:19', '2025-11-11 02:20:19');

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `id` int(11) NOT NULL,
  `supplier_id` varchar(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `contact_person` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(100) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `middle_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `avatar` varchar(255) DEFAULT NULL,
  `email` varchar(100) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('admin','manager','staff','driver') DEFAULT 'staff',
  `status` enum('Active','Inactive') DEFAULT 'Active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `username`, `first_name`, `middle_name`, `last_name`, `avatar`, `email`, `password_hash`, `role`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Coco M.', NULL, NULL, NULL, '/uploads/avatar-1762158868326-642667687.jpg', 'admin@gmail.com', '$2a$10$MpVMcstcDXulXAwf.CPzEOvWhpnMR2nXu5wKepRt4JVrvf8aJcvvG', 'admin', 'Active', '2025-10-20 17:05:18', '2025-11-03 08:34:28'),
(2, 'driver-nim', NULL, NULL, NULL, '/uploads/avatar-1762265933322-515944831.png', 'tjc_driver@gmail.com', '$2a$10$Xv3YuUayTfZKRMBeimeeqegRw.gdHObECa5iaJLkkKqRuHkY3OqwG', 'driver', 'Active', '2025-10-20 17:09:17', '2025-11-04 14:18:53'),
(3, 'rat, bu D.', 'bu', 'D.', 'rat', '/uploads/avatar-1762626057263-322459360.jpg', 'asdsadas@gmail.com', '$2a$10$Z.lgKyh.PidTp9opECcfN./W4N8fudnA2wj1xP2FvGrt0rhSN8HHa', 'admin', 'Active', '2025-11-08 18:20:57', '2025-11-08 19:29:17');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `app_settings`
--
ALTER TABLE `app_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `brands`
--
ALTER TABLE `brands`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `idx_name` (`name`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `idx_name` (`name`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_product_id` (`product_id`);

--
-- Indexes for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_transaction_id` (`transaction_id`),
  ADD KEY `inventory_id` (`inventory_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `product_id` (`product_id`),
  ADD KEY `idx_product_id` (`product_id`),
  ADD KEY `idx_name` (`name`),
  ADD KEY `idx_brand` (`brand`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_created_at` (`created_at`);

--
-- Indexes for table `refund_transactions`
--
ALTER TABLE `refund_transactions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `transaction_id` (`transaction_id`),
  ADD KEY `return_id` (`return_id`),
  ADD KEY `order_id` (`order_id`);

--
-- Indexes for table `returns`
--
ALTER TABLE `returns`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `return_id` (`return_id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `return_date` (`return_date`);

--
-- Indexes for table `return_items`
--
ALTER TABLE `return_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `return_id` (`return_id`),
  ADD KEY `sale_item_id` (`sale_item_id`),
  ADD KEY `product_id` (`product_id`);

--
-- Indexes for table `sales`
--
ALTER TABLE `sales`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `sale_number` (`sale_number`),
  ADD KEY `idx_sale_number` (`sale_number`),
  ADD KEY `idx_sales_status` (`status`),
  ADD KEY `idx_sales_created_at` (`created_at`);

--
-- Indexes for table `sale_items`
--
ALTER TABLE `sale_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sale_items_sale_id` (`sale_id`),
  ADD KEY `idx_sale_items_product_id` (`product_id`);

--
-- Indexes for table `serial_numbers`
--
ALTER TABLE `serial_numbers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_serial_per_product` (`serial_number`,`product_id`),
  ADD KEY `idx_product_id` (`product_id`),
  ADD KEY `idx_serial_number` (`serial_number`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_sale_id` (`sale_id`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_supplier_id` (`supplier_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_username` (`username`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_role` (`role`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_users_role` (`role`),
  ADD KEY `idx_users_status` (`status`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `app_settings`
--
ALTER TABLE `app_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `brands`
--
ALTER TABLE `brands`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=196;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `refund_transactions`
--
ALTER TABLE `refund_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `returns`
--
ALTER TABLE `returns`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `return_items`
--
ALTER TABLE `return_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `sales`
--
ALTER TABLE `sales`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `sale_items`
--
ALTER TABLE `sale_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `serial_numbers`
--
ALTER TABLE `serial_numbers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;

--
-- Constraints for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  ADD CONSTRAINT `inventory_transactions_ibfk_1` FOREIGN KEY (`inventory_id`) REFERENCES `inventory` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `inventory_transactions_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE;

--
-- Constraints for table `refund_transactions`
--
ALTER TABLE `refund_transactions`
  ADD CONSTRAINT `refund_transactions_ibfk_1` FOREIGN KEY (`return_id`) REFERENCES `returns` (`return_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `refund_transactions_ibfk_2` FOREIGN KEY (`order_id`) REFERENCES `sales` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `returns`
--
ALTER TABLE `returns`
  ADD CONSTRAINT `returns_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `sales` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `return_items`
--
ALTER TABLE `return_items`
  ADD CONSTRAINT `return_items_ibfk_1` FOREIGN KEY (`return_id`) REFERENCES `returns` (`return_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `return_items_ibfk_2` FOREIGN KEY (`sale_item_id`) REFERENCES `sale_items` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sale_items`
--
ALTER TABLE `sale_items`
  ADD CONSTRAINT `sale_items_ibfk_1` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `sale_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`);

--
-- Constraints for table `serial_numbers`
--
ALTER TABLE `serial_numbers`
  ADD CONSTRAINT `fk_serial_product` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_serial_sale` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
