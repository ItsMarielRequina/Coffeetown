<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php'); // Redirect to login page if not logged in
    exit;
}

include 'db.php'; // Include your database connection

// Fetch all customers
$stmt = $pdo->prepare("SELECT DISTINCT customerID, name, contact_number, created_at FROM customers ORDER BY created_at DESC");
$stmt->execute();
$customers = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Initialize an array to hold total amounts for each customer
$customerTotals = [];

// Fetch total amount for each customer from the purchase table
foreach ($customers as $customer) {
    $totalAmountStmt = $pdo->prepare("
        SELECT SUM(total_amount) AS total_amount 
        FROM purchases
        WHERE customerID = :customer_id
    ");
    $totalAmountStmt->bindValue(':customer_id', $customer['customerID']);
    $totalAmountStmt->execute();
    $totalAmountResult = $totalAmountStmt->fetch(PDO::FETCH_ASSOC);
    
    // Store the total amount in the array with the customer ID
    $customerTotals[$customer['customerID']] = $totalAmountResult['total_amount'] ? $totalAmountResult['total_amount'] : 0;
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Records - Coffee Town POS</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f0f0f0; /* Light grey background */
            color: #333;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .main-container {
            padding: 30px;
            flex: 1;
            margin: 60px auto;
        }

        h2 {
            color: #006241;
            font-size: 36px;
            margin-bottom: 30px;
            text-transform: uppercase;
            text-align: center;
            letter-spacing: 2px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
            background-color: white;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); /* Box shadow for depth */
            border-radius: 10px;
            overflow: hidden;
        }

        th, td {
            padding: 20px;
            text-align: left;
            border-bottom: 1px solid #ddd;
            font-size: 18px;
        }

        th {
            background-color: #006241;
            color: white;
        }

        tr:hover {
            background-color: #d7ffd9; /* Row hover effect */
            transition: background-color 0.3s ease;
        }

        /* Improved "View Details" Button */
        .view-details {
            display: inline-block;
            background-color: #006241;
            color: white;
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 16px;
            font-weight: bold;
            transition: background-color 0.3s ease, transform 0.2s ease;
        }

        .view-details:hover {
            background-color: #004f2d; /* Darker green on hover */
            transform: translateY(-2px); /* Slight lift effect */
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15); /* Add shadow on hover */
        }

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
                padding: 8px;
            }
        }
    </style>
</head>
<body>

    <!-- Main Container -->
    <div class="main-container">
        <h2>Customer Sales Records</h2>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Customer Name</th>
                    <th>Contact Number</th>
                    <th>Amount Paid</th>
                    <th>Date of Purchase</th>                    
                    <th>Purchase Details</th>
                </tr>
            </thead>
            <tbody>
                <?php $id = 1; foreach ($customers as $customer): ?>
                <tr>
                    <td><?php echo $id++; ?></td>
                    <td><?php echo htmlspecialchars($customer['name']); ?></td>
                    <td><?php echo htmlspecialchars($customer['contact_number']); ?></td>
                    <td>₱<?php echo number_format($customerTotals[$customer['customerID']], 2); ?></td> <!-- Display Total Amount from $customerTotals -->
                    <td><?php echo date('F j, Y, g:i a', strtotime($customer['created_at'])); ?></td>
                    <td><a href="customer_purchase.php?id=<?php echo $customer['customerID']; ?>" class="view-details">View Details</a></td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>

    <!-- Fixed Bottom Navigation -->
    <div class="sidenav">
    <a href="index.php">🏠 Home</a>
        <a href="expenses.php">🧾 Expenses</a>
        <a href="inventory.php">📦 Inventory</a>
        <a href="supplier.php">👤 Supplier</a>
        <a href="transaction.php">🔄 Transaction</a>
        <a href="logout.php">🚪 Logout</a>
    </div>

</body>
</html>
