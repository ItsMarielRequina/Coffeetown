<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: /Coffeetown/views/auth/login.php'); // Redirect to login page if not logged in
    exit;
}

require_once __DIR__ . '/../../config/db.php'; // Include database connection

// Fetch all expenses only
$stmt = $pdo->prepare("SELECT e.order_date, i.product_name, e.order_quantity, e.total_cost 
                       FROM expenses e 
                       JOIN inventory i ON e.product_id = i.id 
                       ORDER BY e.order_date DESC");
$stmt->execute();
$expenses = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="en">
<head>
<link rel="icon" href="/Coffeetown/public/images/favicon.ico" type="image/x-icon">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Expenses Records - Coffee Town POS</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/Coffeetown/public/css/styles.css">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            color: #333;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .main-container {
            padding: 40px;
            flex: 1;
            background: linear-gradient(135deg, #f4f4f4 0%, #e0e0e0 100%);
            margin-bottom: 30px auto;
            text-align: center;
        }

        h2 {
            color: #006241;
            font-size: 42px;
            margin-bottom: 30px;
            text-transform: uppercase;
            text-align: center;
            letter-spacing: 3px;
            display: inline-block;
            padding-bottom: 10px;

        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
            background-color: white;
            border-radius: 10px;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        th, td {
            padding: 20px;
            text-align: left;
            font-size: 18px;
            border-bottom: 1px solid #ddd;
            position: relative;
            transition: background-color 0.3s ease;
        }

        th {
            background-color: #004d40;
            color: white;
            text-transform: uppercase;
            font-size: 20px;
        }

        td {
            background-color: #fafafa;
            font-size: 16px;
        }

        tr:hover {
            background-color: #d7ffd9;
            transform: scale(1.01);
            cursor: pointer;
            transition: transform 0.2s ease-in-out;
        }

        tr:hover td {
            background-color: #d7ffd9;
        }

        td::after {
            content: "";
            position: absolute;
            width: 0;
            height: 2px;
            background-color: #004d40;
            bottom: 0;
            left: 50%;
            transition: width 0.4s ease, left 0.4s ease;
        }

        /* Fixed Bottom Navbar */
        .sidenav {
            position: fixed;
            bottom: 0;
            width: 100%;
            background-color: #006241;
            display: flex;
            justify-content: space-around;
            padding: 10px 0;
            z-index: 100;
        }

        .sidenav a {
            color: white;
            text-decoration: none;
            text-align: center;
            flex-grow: 1;
            padding: 10px;
            transition: background-color 0.3s;
        }

        .sidenav a:hover {
            background-color: #004f2d;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            th, td {
                padding: 15px;
                font-size: 16px;
            }

            .sidenav a {
                font-size: 16px;
            }

            h2 {
                font-size: 28px;
            }
        }
    </style>
</head>
<body>

    <!-- Main Container -->
    <div class="main-container">
        <h2>Expenses Records</h2>
        <table>
            <thead>
                <tr>
                    <th>Order Date</th>
                    <th>Product Name</th>
                    <th>Order Quantity</th>
                    <th>Total Cost</th>
                </tr>
            </thead>
            <tbody>
    <?php foreach ($expenses as $expense): ?>
        <tr>
            <td><?php echo date('F j, Y, g:i a', strtotime($expense['order_date'])); ?></td>
            <td><?php echo htmlspecialchars($expense['product_name']); ?></td>
            <td><?php echo htmlspecialchars($expense['order_quantity']); ?></td>
            <td>₱<?php echo number_format($expense['total_cost'], 2); ?></td>
        </tr>
    <?php endforeach; ?>
            </tbody>
        </table>
    </div>

    <!-- Fixed Bottom Navigation -->
    <div class="sidenav">
        <a href="/Coffeetown/public/index.php" class="back-button">Back to Dashboard</a>
        <a href="view_sales.php">💰 Sales</a>
        <a href="inventory.php">📦 Inventory</a>
        <a href="supplier.php">👤 Supplier</a>
        <a href="transaction.php">🔄 Transaction</a>
        <a href="logout.php">🚪 Logout</a>
    </div>

</body>
</html>
