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

// Fetch categorized data
$categorizedPurchases = getCategorizedPurchases();
$categorizedExpenses = getCategorizedExpenses();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Financial Summary</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(to right, #e9f1f5, #ffffff); /* Soft gradient background */
            color: #333;
            line-height: 1.6;
        }

        header {
            background: #004f2d; /* Green header */
            color: white;
            padding: 20px;
            text-align: center;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15); /* Shadow for depth */
        }

        h3, h4, h5 {
            margin: 10px 0;
            font-weight: bold;
        }

        .summary {
            margin: 20px;
            background-color: #ffffff; /* White background for tables */
            padding: 20px;
            border-radius: 10px; /* Rounded corners */
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1); /* Subtle shadow effect */
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }

        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: left;
            transition: background-color 0.3s; /* Smooth transition for hover effect */
        }

        th {
            background-color: #004f2d; /* Green header */
            color: white;
        }

        tr:hover {
            background-color: #f1f1f1; /* Highlight row on hover */
        }

        .total-row {
            font-weight: bold;
            background-color: #004f2d; /* Light green for total row */
        }

        .summary h5 {
            color: #4CAF50; /* Green color */
            border-bottom: 2px solid #004f2d; /* Underline for subheadings */
            padding-bottom: 5px;
        }

        .footer {
            text-align: center;
            margin-top: 30px;
            padding: 20px;
            background: #004f2d;
            color: white;
            position: relative;
        }

        .back-button {
            background-color: #004f2d; /* Green button */
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-size: 16px;
            transition: background-color 0.3s;
            margin: 20px;
            display: inline-block;
        }

        .back-button:hover {
            background-color: #45a049; /* Darker green on hover */
        }

        @media (max-width: 600px) {
            body {
                margin: 10px;
            }

            th, td {
                padding: 8px;
            }

            h3 {
                font-size: 24px;
            }
        }
    </style>
</head>
<body>

<header>
    <h3>Categorized Financial Summary</h3>
</header>

<!-- Back Button -->
<a href="transaction.php" class="back-button">Back to Transactions</a>

<!-- View Graph Button -->
<a href="graph.php" class="back-button">View Graph</a>

<div class="summary">
    <h4>Purchases</h4>
    <h5>Daily</h5>
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Total Amount</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($categorizedPurchases['day'] as $purchase): ?>
                <tr>
                    <td><?php echo htmlspecialchars($purchase['date']); ?></td>
                    <td><?php echo '₱' . number_format($purchase['total_amount'], 2); ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>

    <h5>Weekly</h5>
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Total Amount</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($categorizedPurchases['week'] as $purchase): ?>
                <tr>
                    <td><?php echo htmlspecialchars($purchase['date']); ?></td>
                    <td><?php echo '₱' . number_format($purchase['total_amount'], 2); ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>

    <h5>Monthly</h5>
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Total Amount</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($categorizedPurchases['month'] as $purchase): ?>
                <tr>
                    <td><?php echo htmlspecialchars($purchase['date']); ?></td>
                    <td><?php echo '₱' . number_format($purchase['total_amount'], 2); ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>

    <h5>Yearly</h5>
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Total Amount</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($categorizedPurchases['year'] as $purchase): ?>
                <tr>
                    <td><?php echo htmlspecialchars($purchase['date']); ?></td>
                    <td><?php echo '₱' . number_format($purchase['total_amount'], 2); ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</div>

<div class="summary">
    <h4>Expenses</h4>
    <h5>Daily</h5>
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Total Cost</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($categorizedExpenses['day'] as $expense): ?>
                <tr>
                    <td><?php echo htmlspecialchars($expense['date']); ?></td>
                    <td><?php echo '₱' . number_format($expense['total_cost'], 2); ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>

    <h5>Weekly</h5>
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Total Cost</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($categorizedExpenses['week'] as $expense): ?>
                <tr>
                    <td><?php echo htmlspecialchars($expense['date']); ?></td>
                    <td><?php echo '₱' . number_format($expense['total_cost'], 2); ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>

    <h5>Monthly</h5>
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Total Cost</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($categorizedExpenses['month'] as $expense): ?>
                <tr>
                    <td><?php echo htmlspecialchars($expense['date']); ?></td>
                    <td><?php echo '₱' . number_format($expense['total_cost'], 2); ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>

    <h5>Yearly</h5>
    <table>
        <thead>
            <tr>
                <th>Date</th>
                <th>Total Cost</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($categorizedExpenses['year'] as $expense): ?>
                <tr>
                    <td><?php echo htmlspecialchars($expense['date']); ?></td>
                    <td><?php echo '₱' . number_format($expense['total_cost'], 2); ?></td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</div>

<div class="footer">
    &copy; <?php echo date("Y"); ?> Coffee Town. All rights reserved.
</div>

</body>
</html>