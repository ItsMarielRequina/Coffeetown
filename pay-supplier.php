<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php'); // Redirect to login page if not logged in
    exit;
}

include 'db.php'; // Include your database connection

// Function to fetch total income from all purchases
function getTotalIncomeFromAllPurchases() {
    global $pdo;

    // Summing the total amount from purchases to get the total income
    $stmt = $pdo->prepare("SELECT SUM(total_amount) AS total_income FROM purchases");
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Return total income or 0 if no income is present
    return $result['total_income'] ? $result['total_income'] : 0;
}

// Function to calculate the total expenses
function getTotalExpenses() {
    global $pdo;
    
    // Summing the total cost from the expenses table
    $stmt = $pdo->prepare("SELECT SUM(total_cost) AS total_expenses FROM expenses");
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Return total expenses or 0 if no expenses are present
    return $result['total_expenses'] ? $result['total_expenses'] : 0;
}

// Function to calculate the balance
function getBalance() {
    $totalIncome = getTotalIncomeFromAllPurchases();
    $totalExpenses = getTotalExpenses();
    return $totalIncome - $totalExpenses;
}

// Check if the form is submitted
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Handle the payment logic
    paySupplier();
}

function paySupplier() {
    global $pdo;

    // Example data (you may want to collect these from the form)
    $supplierId = 1; // Example supplier ID, replace with the actual supplier ID you want to pay

    // Fetch the total amount owed to the supplier based on supplier_id
    $stmt = $pdo->prepare("SELECT total_cost FROM expenses WHERE supplier_id = ? LIMIT 1");
    $stmt->execute([$supplierId]);
    $expense = $stmt->fetch(PDO::FETCH_ASSOC);

    // Check if there is an expense record
    if ($expense) {
        $amount = $expense['total_cost']; // Get the amount owed from the expense record
        $paymentDate = date('Y-m-d H:i:s'); // Current date and time

        try {
            // Begin a transaction
            $pdo->beginTransaction();

            // Insert payment record into the payments table
            $stmt = $pdo->prepare("INSERT INTO payments (supplier_id, amount, payment_date) VALUES (?, ?, ?)");
            $stmt->execute([$supplierId, $amount, $paymentDate]);

            // Update the expenses table to mark the expense as paid (set to zero)
            $stmt = $pdo->prepare("UPDATE expenses SET total_cost = 0, status = 'paid' WHERE supplier_id = ? AND total_cost = ?");
            $stmt->execute([$supplierId, $amount]);

            // Commit the transaction
            $pdo->commit();

            echo "<script>alert('Payment of $amount to supplier successful!'); window.location.href='pay-supplier.php';</script>";
        } catch (Exception $e) {
            // Rollback the transaction if something fails
            $pdo->rollBack();
            echo "<script>alert('Payment failed: " . $e->getMessage() . "');</script>";
        }
    } else {
        echo "<script>alert('No expenses found for this supplier.');</script>";
    }
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pay Supplier - Coffee Town</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            color: #333;
        }

        h2 {
            color: #006241;
            text-align: center;
            margin: 20px 0;
            font-weight: 600;
        }

        .container {
            max-width: 800px;
            margin: auto;
            padding: 20px;
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
        }

        .summary {
            margin: 20px 0;
            padding: 15px;
            border: 1px solid #ddd;
            border-radius: 5px;
            background-color: #f9f9f9;
        }

        .summary p {
            margin: 5px 0;
            font-size: 16px;
        }

        input[type="submit"] {
            width: 100%;
            padding: 12px;
            margin: 20px 0;
            border: none;
            border-radius: 5px;
            background-color: #006241;
            color: white;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s;
        }

        input[type="submit"]:hover {
            background-color: #004f2d;
        }


    </style>
</head>
<body>
    <div class="container">
        <h2>Pay Supplier</h2>
        <div class="summary">
            <p>Total Income from Purchases: <strong><?php echo getTotalIncomeFromAllPurchases(); ?></strong></p>
            <p>Total Expenses: <strong><?php echo getTotalExpenses(); ?></strong></p>
            <p>Balance: <strong><?php echo getBalance(); ?></strong></p>
        </div>
        <form method="POST" action="">
            <input type="submit" value="Pay Supplier">
        </form>

        <div class="sidenav">
            <a href="index.php">🏠 Home</a>
            <a href="view_sales.php">💰 Sales</a>
            <a href="expenses.php">🧾 Expenses</a>
            <a href="inventory.php">📦 Inventory</a>
            <a href="supplier.php">👤 Supplier</a>
            <a href="transaction.php">👤 Transaction</a>
            <a href="logout.php">🚪 Logout</a>
        </div>
    </div>
</body>
</html>
