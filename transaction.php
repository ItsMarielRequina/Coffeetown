<?php
session_start();

if (!isset($_SESSION['user_id'])) {
    header('Location: login.php'); // Redirect to login page if not logged in
    exit;
}

include 'db.php'; // Include your database connection

// Define currency symbol as a constant
define('CURRENCY_SYMBOL', '₱');

// Function to calculate total income
function getTotalIncome() {
    global $pdo;
    $stmt = $pdo->prepare("SELECT SUM(total_amount) AS total_income FROM purchases");
    $stmt->execute();
    return $stmt->fetch(PDO::FETCH_ASSOC)['total_income'] ?? 0;
}

// Function to calculate total expenses
function getTotalExpenses() {
    global $pdo;
    $stmt = $pdo->prepare("SELECT SUM(total_cost) AS total_expenses FROM expenses");
    $stmt->execute();
    return $stmt->fetch(PDO::FETCH_ASSOC)['total_expenses'] ?? 0;
}

// Function to store total expenses in the database
function storeTotalExpenses($totalExpenses) {
    global $pdo;
    $stmt = $pdo->prepare("INSERT INTO total_expense (expenses) VALUES (?)");
    if ($stmt->execute([$totalExpenses]) === false) {
        print_r($stmt->errorInfo()); // Debugging: show error if insert fails
    }
}

// Check if the form is submitted
$transactions = []; // Initialize transactions array
if ($_SERVER['REQUEST_METHOD'] == 'GET' && isset($_GET['category']) && isset($_GET['timeframe'])) {
    $category = $_GET['category'];
    $timeframe = $_GET['timeframe'];

    // Function to get categorized purchases or expenses
    function getCategorizedTransactions($category, $timeframe) {
        global $pdo; // Declare the $pdo variable as global here
        
        // Prepare SQL query based on category and timeframe
        $dateInterval = ($timeframe == 'daily') ? '1 DAY' : (($timeframe == 'weekly') ? '1 WEEK' : (($timeframe == 'monthly') ? '1 MONTH' : '1 YEAR'));
        
        if ($category == 'purchases') {
            $sql = "SELECT * FROM purchases WHERE DATE(purchase_date) >= DATE_SUB(CURDATE(), INTERVAL $dateInterval)";
        } elseif ($category == 'expenses') {
            $sql = "SELECT * FROM expenses WHERE DATE(order_date) >= DATE_SUB(CURDATE(), INTERVAL $dateInterval)";
        } else {
            return []; // Handle unexpected categories
        }
    
        $stmt = $pdo->prepare($sql);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Fetch the transactions based on selected category and timeframe
    $transactions = getCategorizedTransactions($category, $timeframe);
}

// Function to add a new expense
function addExpense($productId, $orderQuantity, $totalCost, $supplierId) {
    global $pdo;
    $stmt = $pdo->prepare("INSERT INTO expenses (product_id, order_quantity, total_cost, supplier_id) VALUES (?, ?, ?, ?)");
    $stmt->execute([$productId, $orderQuantity, $totalCost, $supplierId]);
}

// Function to update an existing expense
function updateExpense($expenseId, $productId, $orderQuantity, $totalCost, $supplierId) {
    global $pdo;
    $stmt = $pdo->prepare("UPDATE expenses SET product_id = ?, order_quantity = ?, total_cost = ?, supplier_id = ? WHERE id = ?");
    $stmt->execute([$productId, $orderQuantity, $totalCost, $supplierId, $expenseId]);
}

function updateTotalExpenses($expenses) {
    global $pdo;
    // First, check if an entry exists
    $stmtCheck = $pdo->prepare("SELECT COUNT(*) AS count FROM total_expense");
    $stmtCheck->execute();
    $count = $stmtCheck->fetch(PDO::FETCH_ASSOC)['count'];

    if ($count > 0) {
        // Update the existing total expenses
        $stmtUpdate = $pdo->prepare("UPDATE total_expense SET expenses = ?");
        if ($stmtUpdate->execute([$expenses]) === false) {
            print_r($stmtUpdate->errorInfo()); // Debugging: show error if update fails
        }
    } else {
        // If no entry exists, insert it
        $stmtInsert = $pdo->prepare("INSERT INTO total_expense (expenses) VALUES (?)");
        if ($stmtInsert->execute([$expenses]) === false) {
            print_r($stmtInsert->errorInfo()); // Debugging: show error if insert fails
        }
    }
}

// Handle form submission for adding or updating an expense
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $productId = $_POST['product_id'];
    $orderQuantity = $_POST['order_quantity'];
    $totalCost = $_POST['total_cost'];
    $supplierId = $_POST['supplier_id'];

    // Check if this is an update or an insert
    if (isset($_POST['expense_id'])) {
        // Update existing expense
        $expenseId = $_POST['expense_id'];
        updateExpense($expenseId, $productId, $orderQuantity, $totalCost, $supplierId);
    } else {
        // Add new expense
        addExpense($productId, $orderQuantity, $totalCost, $supplierId);
    }

    // Calculate total expenses after adding/updating
    $totalExpenses = getTotalExpenses();
    // Update total expenses in total_expense table
    updateTotalExpenses($totalExpenses);
    
    // Redirect or refresh page as needed
    header('Location: expenses.php');
    exit;
}

// Calculate total income and expenses
$totalIncome = getTotalIncome();
$totalExpenses = getTotalExpenses();
$remainingIncome = $totalIncome - $totalExpenses;

// Store total expenses in the database
storeTotalExpenses($totalExpenses);

// Insert Remaining Income into total_income table
function insertTotalIncome($remainingIncome) {
    global $pdo;
    $stmt = $pdo->prepare("INSERT INTO total_income (income) VALUES (?)");
    if ($stmt->execute([$remainingIncome]) === false) {
        print_r($stmt->errorInfo()); // Debugging: show error if insert fails
    }
}

insertTotalIncome($remainingIncome);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transaction Overview - Coffee Town</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
            color: #333;
        }

        .main-container {
            padding: 40px;
            max-width: 1100px;
            margin: 0 auto;
            background-color: #fff;
            border-radius: 12px;
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.1);
        }

        h2 {
            color: #006241;
            font-size: 34px;
            font-weight: 600;
            text-align: center;
            margin-bottom: 40px;
            text-transform: uppercase;
            letter-spacing: 1.5px;
        }

        .summary {
            display: flex;
            justify-content: space-between;
            margin-bottom: 30px;
        }

        .summary div {
            background-color: #f9f9f9;
            padding: 30px;
            border-radius: 10px;
            width: 32%;
            text-align: center;
            box-shadow: 0 3px 12px rgba(0, 0, 0, 0.08);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .summary div:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);
        }

        .filter-form {
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
        }

        .filter-form label {
            font-weight: bold;
            margin-right: 10px;
        }

        .filter-form select {
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 5px;
            margin-right: 10px;
            background-color: #fff;
            cursor: pointer;
        }

        .filter-form button {
            padding: 10px 20px;
            background-color: #006241;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
        }

        .filter-form button:hover {
            background-color: #004d40;
        }

        .transaction-list {
            list-style: none;
            padding: 0;
            margin-top: 20px;
        }

        .transaction-list li {
            background-color: #fff;
            padding: 15px;
            border: 1px solid #eee;
            border-radius: 5px;
            margin-bottom: 10px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        .transaction-list li p {
            margin: 5px 0;
        }
        .add-button {
            text-align: center;
            margin-bottom: 30px;
        }

        .add-button button {
            padding: 12px 30px;
            background-color: #00796b;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s, transform 0.3s;
        }

        .add-button button:hover {
            background-color: #004d40;
            transform: translateY(-2px);
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
            border-radius: 4px; /* Rounded buttons */
        }

        .sidenav a:hover {
            background-color: #004f2d;
        }
    </style>
</head>
<body>

<div class="main-container">
    
    <h2>Transaction Overview</h2>

    <div class="summary">
        <div>
            <h3>Total Income</h3>
            <p><?php echo CURRENCY_SYMBOL . number_format($totalIncome, 2); ?></p>
        </div>
        <div>
            <h3>Total Expenses</h3>
            <p><?php echo CURRENCY_SYMBOL . number_format($totalExpenses, 2); ?></p>
        </div>
        <div>
            <h3>Remaining Income</h3>
            <p><?php echo CURRENCY_SYMBOL . number_format($remainingIncome, 2); ?></p>
        </div>
    </div>
    <div class="add-button">
        <button onclick="location.href='financial_summary.php'">View Financial Summary</button>
    </div>
    <form class="filter-form" method="GET" action="">
        <label for="category">Select Category:</label>
        <select name="category" id="category" required>
            <option value="">--Select--</option>
            <option value="purchases">Purchases</option>
            <option value="expenses">Expenses</option>
        </select>

        <label for="timeframe">Select Timeframe:</label>
        <select name="timeframe" id="timeframe" required>
            <option value="">--Select--</option>
            <option value="daily">Daily</option>
            <option value="weekly">Weekly</option>
            <option value="monthly">Monthly</option>
            <option value="yearly">Yearly</option>
        </select>

        <button type="submit">View Transactions</button>
    </form>

    <ul class="transaction-list">
        <?php if (empty($transactions)): ?>
            <li>No transactions found for the selected category and timeframe.</li>
        <?php else: ?>
            <?php foreach ($transactions as $transaction): ?>
                <li>
                    <h4><?php echo ($category == 'purchases') ? 'Purchase' : 'Expense'; ?> Details</h4>
                    <p><strong>ID:</strong> <?php echo $transaction['purchaseID'] ?? $transaction['id']; ?></p>
                    <p><strong>Date:</strong> <?php echo $transaction['purchase_date'] ?? $transaction['order_date']; ?></p>
                    <p><strong>Amount:</strong> <?php echo CURRENCY_SYMBOL . number_format($transaction['total_amount'] ?? $transaction['total_cost'], 2); ?></p>
                </li>
            <?php endforeach; ?>
        <?php endif; ?>
    </ul>
</div>
<!-- Bottom Navigation -->
<div class="sidenav">
        <a href="index.php">🏠 Home</a>
        <a href="view_sales.php">💰 Sales</a>
        <a href="expenses.php">🧾 Expenses</a>
        <a href="supplier.php">👤 Supplier</a>
        <a href="transaction.php"> Transaction</a>
        <a href="logout.php">🚪 Logout</a>
    </div>

</body>
</html>
