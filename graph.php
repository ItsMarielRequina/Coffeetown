<?php
session_start();

if (!isset($_SESSION['user_id'])) {
    header('Location: login.php'); // Redirect to login page if not logged in
    exit;
}

include 'db.php'; // Include your database connection

// Function to categorize purchases
function getCategorizedPurchases() {
    global $pdo;
    $categories = ['day', 'week', 'month', 'year'];
    $data = [];

    foreach ($categories as $category) {
        $stmt = $pdo->prepare("
            SELECT 
                DATE(purchase_date) AS date,
                SUM(total_amount) AS total_amount
            FROM 
                purchases 
            WHERE 
                purchase_date >= DATE_SUB(NOW(), INTERVAL 1 " . strtoupper($category) . ")
            GROUP BY 
                DATE(purchase_date)
        ");
        $stmt->execute();
        $data[$category] = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    return $data;
}

// Function to categorize expenses
function getCategorizedExpenses() {
    global $pdo;
    $categories = ['day', 'week', 'month', 'year'];
    $data = [];

    foreach ($categories as $category) {
        $stmt = $pdo->prepare("
            SELECT 
                DATE(order_date) AS date,
                SUM(total_cost) AS total_cost
            FROM 
                expenses 
            WHERE 
                order_date >= DATE_SUB(NOW(), INTERVAL 1 " . strtoupper($category) . ")
            GROUP BY 
                DATE(order_date)
        ");
        $stmt->execute();
        $data[$category] = $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    return $data;
}

// Function to get total sales and total expenses for the pie chart
function getTotalSalesAndExpenses() {
    global $pdo;
    
    // Get total sales
    $stmtSales = $pdo->prepare("
        SELECT SUM(total_amount) AS total_sales 
        FROM purchases
    ");
    $stmtSales->execute();
    $totalSales = $stmtSales->fetch(PDO::FETCH_ASSOC)['total_sales'];

    // Get total expenses
    $stmtExpenses = $pdo->prepare("
        SELECT SUM(total_cost) AS total_expenses 
        FROM expenses
    ");
    $stmtExpenses->execute();
    $totalExpenses = $stmtExpenses->fetch(PDO::FETCH_ASSOC)['total_expenses'];

    return ['total_sales' => $totalSales, 'total_expenses' => $totalExpenses];
}

// Function to get total products
function getTotalProducts() {
    global $pdo;
    $stmt = $pdo->prepare("
        SELECT COUNT(*) AS total_products 
        FROM inventory
    ");
    $stmt->execute();
    return $stmt->fetch(PDO::FETCH_ASSOC)['total_products'];
}

// Function to get total unique customers who ordered
function getTotalCustomers() {
    global $pdo;
    $stmt = $pdo->prepare("
        SELECT COUNT(DISTINCT customerID) AS total_customers 
        FROM purchases
    ");
    $stmt->execute();
    return $stmt->fetch(PDO::FETCH_ASSOC)['total_customers'];
}

// Fetch categorized data
$categorizedPurchases = getCategorizedPurchases();
$categorizedExpenses = getCategorizedExpenses();
$totalSalesAndExpenses = getTotalSalesAndExpenses();
$totalProducts = getTotalProducts();
$totalCustomers = getTotalCustomers();

// Function to insert financial summary data into the database
function insertFinancialSummary($date, $sales, $expenses, $category) {
    global $pdo;

    // Create a human-readable summary name based on the category
    $summaryNames = [
        'day' => 'Daily Summary',
        'week' => 'Weekly Summary',
        'month' => 'Monthly Summary',
        'year' => 'Yearly Summary'
    ];

    $summary_name = $summaryNames[$category]; // Get the corresponding name

    $stmt = $pdo->prepare("
        INSERT INTO financial_summary (summary_date, total_sales, total_expenses, category, summary_name) 
        VALUES (:summary_date, :total_sales, :total_expenses, :category, :summary_name)
    ");
    $stmt->execute([
        ':summary_date' => $date,
        ':total_sales' => $sales,
        ':total_expenses' => $expenses,
        ':category' => $category,
        ':summary_name' => $summary_name // Include the summary name in the insert
    ]);
}

// Function to save daily, weekly, monthly, and yearly totals in the database
function saveFinancialSummary() {
    $categories = ['day', 'week', 'month', 'year'];
    $categorizedPurchases = getCategorizedPurchases();
    $categorizedExpenses = getCategorizedExpenses();

    foreach ($categories as $category) {
        // Assuming you only want the first entry from the categorized data for each category
        $salesTotal = $categorizedPurchases[$category] ? $categorizedPurchases[$category][0]['total_amount'] : 0;
        $expensesTotal = $categorizedExpenses[$category] ? $categorizedExpenses[$category][0]['total_cost'] : 0;
        $date = date('Y-m-d', strtotime("-1 $category")); // Get date for the specific category
        insertFinancialSummary($date, $salesTotal, $expensesTotal, $category);
    }
}

// Call the function to save financial summary data
saveFinancialSummary();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Financial Summary - Graphs</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script> <!-- Include Chart.js -->
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f5f5f5;
            color: #333;
        }

        header {
            background-color: #004f2d;
            color: white;
            padding: 20px;
            text-align: center;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
        }

        .container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .chart-section {
            display: flex;
            justify-content: space-between;
            gap: 30px;
            margin-bottom: 40px;
        }

        .chart-container {
            flex: 1;
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease-in-out;
        }

        .chart-container:hover {
            transform: scale(1.02);
        }

        canvas {
            margin: 20px 0;
        }

        .back-button {
            background-color: #004f2d;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-size: 16px;
            transition: background-color 0.3s ease-in-out;
        }

        .back-button:hover {
            background-color: #34495e;
        }

        footer {
            text-align: center;
            padding: 20px;
            background-color: #004f2d;
            color: white;
            margin-top: 30px;
            box-shadow: 0 -4px 10px rgba(0, 0, 0, 0.15);
        }
    </style>
</head>
<body>

<header>
    <h3>Financial Summary - Sales, Expenses, Products, and Customers</h3>
</header>

<div class="container">
    <!-- Back Button -->
    <a href="transaction.php" class="back-button">Back to Transactions</a>

    <!-- Charts Section -->
    <div class="chart-section">
        <!-- Bar Chart Container -->
        <div class="chart-container">
            <canvas id="salesExpensesChart"></canvas>
        </div>

        <!-- Pie Chart Container -->
        <div class="chart-container">
            <canvas id="salesExpensesPieChart"></canvas>
        </div>
    </div>
</div>

<footer>
    &copy; <?php echo date("Y"); ?> Coffee Town. All rights reserved.
</footer>

<script>
// Prepare the sales and expenses data for the bar chart
const salesData = {
    daily: <?php echo json_encode(array_column($categorizedPurchases['day'], 'total_amount')); ?>,
    weekly: <?php echo json_encode(array_column($categorizedPurchases['week'], 'total_amount')); ?>,
    monthly: <?php echo json_encode(array_column($categorizedPurchases['month'], 'total_amount')); ?>,
    yearly: <?php echo json_encode(array_column($categorizedPurchases['year'], 'total_amount')); ?>
};

const expensesData = {
    daily: <?php echo json_encode(array_column($categorizedExpenses['day'], 'total_cost')); ?>,
    weekly: <?php echo json_encode(array_column($categorizedExpenses['week'], 'total_cost')); ?>,
    monthly: <?php echo json_encode(array_column($categorizedExpenses['month'], 'total_cost')); ?>,
    yearly: <?php echo json_encode(array_column($categorizedExpenses['year'], 'total_cost')); ?>
};

// Set up labels for the chart (these are placeholders, adjust based on actual dates if needed)
const labels = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

// Bar Chart Configuration
const ctx = document.getElementById('salesExpensesChart').getContext('2d');
const salesExpensesChart = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: labels,
        datasets: [{
            label: 'Sales',
            data: [salesData.daily[0], salesData.weekly[0], salesData.monthly[0], salesData.yearly[0]],
            backgroundColor: 'rgba(39, 174, 96, 0.6)', // Coffee Town green
            borderColor: 'rgba(39, 174, 96, 1)',
            borderWidth: 1
        },
        {
            label: 'Expenses',
            data: [expensesData.daily[0], expensesData.weekly[0], expensesData.monthly[0], expensesData.yearly[0]],
            backgroundColor: 'rgba(231, 76, 60, 0.6)', // Red for expenses
            borderColor: 'rgba(231, 76, 60, 1)',
            borderWidth: 1
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: {
                position: 'top',
                labels: {
                    font: {
                        size: 14
                    }
                }
            }
        }
    }
});

// Pie Chart Configuration
const pieCtx = document.getElementById('salesExpensesPieChart').getContext('2d');
const salesExpensesPieChart = new Chart(pieCtx, {
    type: 'pie',
    data: {
        labels: ['Total Products', 'Total Customers'],
        datasets: [{
            data: [<?php echo $totalProducts; ?>, <?php echo $totalCustomers; ?>],
            backgroundColor: ['rgba(39, 174, 96, 0.6)', 'rgba(52, 152, 219, 0.6)'], // Green for products, blue for customers
            borderColor: ['rgba(39, 174, 96, 1)', 'rgba(52, 152, 219, 1)'],
            borderWidth: 1
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: {
                position: 'top',
                labels: {
                    font: {
                        size: 14
                    }
                }
            }
        }
    }
});
</script>

</body>
</html>
