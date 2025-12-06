<?php
session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php'); // Redirect to login page if not logged in
    exit;
}

include 'db.php'; // Include your database connection

// Check if customer ID is provided in the URL
if (!isset($_GET['id'])) {
    header('Location: customer_purchase.php'); // Redirect if no ID is provided
    exit;
}

$customerId = $_GET['id'];

// Fetch customer details
$customerStmt = $pdo->prepare("SELECT name, contact_number FROM customers WHERE customerID = :customer_id");
$customerStmt->bindValue(':customer_id', $customerId);
$customerStmt->execute();
$customer = $customerStmt->fetch(PDO::FETCH_ASSOC);

// Fetch purchased items for the customer
$purchasesStmt = $pdo->prepare("
    SELECT p.purchaseID, p.total_amount, p.purchase_date, p.item_name
    FROM purchases p
    WHERE p.customerID = :customer_id
    ORDER BY p.purchase_date DESC
");
$purchasesStmt->bindValue(':customer_id', $customerId);
$purchasesStmt->execute();
$purchasedItems = $purchasesStmt->fetchAll(PDO::FETCH_ASSOC);

// Calculate the total amount spent by the customer
$totalSpent = array_sum(array_column($purchasedItems, 'total_amount'));
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Receipt - Coffee Town POS</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #e7f0e9; /* Soft green background */
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }

        .receipt-container {
            max-width: 600px;
            width: 100%;
            padding: 40px;
            background-color: white;
            border-radius: 20px;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1); /* Subtle shadow for depth */
            text-align: center;
            transition: background-color 0.3s ease, transform 0.3s ease;
        }

        .receipt-container:hover {
            background-color: #f1f9f3; /* Light green background on hover */
            transform: scale(1.02); /* Slight zoom on hover */
        }

        .header {
            background-color: #006241;
            color: white;
            padding: 20px 0;
            border-radius: 15px 15px 0 0;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); /* Header shadow */
        }

        .header h2 {
            margin: 0;
            font-size: 36px;
            letter-spacing: 1.5px;
        }

        .customer-info {
            margin: 40px 0;
            font-size: 20px;
            font-weight: 500;
            text-align: left;
            padding-bottom: 10px;
            border-bottom: 2px solid #e0e0e0;
        }

        .customer-info strong {
            font-size: 22px;
        }

        .items {
            margin-top: 30px;
            font-size: 18px;
            font-weight: 400;
            color: #444;
        }

        .item {
            display: flex;
            justify-content: space-between;
            padding: 15px 0;
            border-bottom: 1px solid #ddd;
            transition: background-color 0.3s ease;
        }

        .item:hover {
            background-color: #f9f9f9; /* Highlight row on hover */
        }

        .item:last-child {
            border-bottom: none;
        }

        .total {
            margin-top: 40px;
            font-weight: bold;
            font-size: 24px;
            color: #006241;
            text-align: right;
        }

        .back-link {
            display: inline-block;
            margin-top: 40px;
            font-size: 18px;
            padding: 15px 25px;
            background-color: #006241;
            color: white;
            text-decoration: none;
            border-radius: 30px;
            transition: background-color 0.3s ease, transform 0.3s ease;
        }

        .back-link:hover {
            background-color: #004f2d;
            transform: scale(1.05); /* Zoom effect on hover */
        }

        .footer {
            margin-top: 40px;
            font-size: 16px;
            color: #999;
        }
    </style>
</head>
<body>

    <div class="receipt-container">
        <div class="header">
            <h2>Receipt</h2>
        </div>
        
        <div class="customer-info">
            <strong>Customer:</strong> <?php echo htmlspecialchars($customer['name']); ?><br>
            <strong>Contact:</strong> <?php echo htmlspecialchars($customer['contact_number']); ?>
        </div>

        <div class="items">
            <?php if (count($purchasedItems) > 0): ?>
                <?php foreach ($purchasedItems as $item): ?>
                    <div class="item">
                        <span><?php echo htmlspecialchars($item['item_name']); ?></span>
                        <span>₱<?php echo number_format($item['total_amount'], 2); ?></span>
                    </div>
                <?php endforeach; ?>
            <?php else: ?>
                <div>No purchased items found for this customer.</div>
            <?php endif; ?>
        </div>

        <div class="total">
            Total Amount: ₱<?php echo number_format($totalSpent, 2); ?>
        </div>

        <a href="view_sales.php" class="back-link">← Back to Customer Records</a>

        <div class="footer">
            Thank you for your purchase!<br>
            Buy Again!
        </div>
    </div>

</body>
</html>
