<?php
session_start();
include 'db.php'; // Include your database connection

if (!isset($_SESSION['customer_id'])) {
    header('Location: login.php'); // Redirect if no customer ID is found
    exit;
}

// Get the customer ID and total amount paid
$customer_id = $_SESSION['customer_id'];
$total_amount_paid = $_SESSION['total_amount_paid'];

// Fetch the customer's information
$stmt = $pdo->prepare("SELECT * FROM customers WHERE customerID = :id");
$stmt->execute(['id' => $customer_id]);
$customer = $stmt->fetch(PDO::FETCH_ASSOC);

// Fetch purchase items for this customer
$stmt = $pdo->prepare("SELECT item_name, quantity, price, total_amount FROM purchases WHERE customerID = :customerID");
$stmt->execute(['customerID' => $customer_id]);
$purchases = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Premium Receipt</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap');

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(to right, #e8f5e9, #d7e8d3); /* Soft green gradient background */
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        .receipt-container {
            max-width: 600px; /* Adjusted width for compactness */
            width: 100%;
            background-color: #ffffff;
            padding: 40px 30px; /* Reduced padding */
            border-radius: 20px;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2); /* Slightly softer shadow */
            border: 8px solid #006241; /* Thinner premium green border */
            position: relative;
            border-top-left-radius: 30px; /* Custom corner rounding for luxury feel */
            border-top-right-radius: 15px;
            border-bottom-left-radius: 15px;
            border-bottom-right-radius: 15px;
        }

        .receipt-container:before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url('https://i.imgur.com/CyHGZ8S.png'); /* Faint background texture */
            opacity: 0.08;
            z-index: -1;
        }

        h1 {
            text-align: center;
            color: #006241;
            font-size: 36px; /* Slightly smaller */
            margin-bottom: 15px;
            font-weight: 700;
            letter-spacing: 1.5px;
        }

        h2 {
            text-align: center;
            font-size: 26px; /* Slightly smaller */
            margin-bottom: 30px;
            color: #333;
            font-weight: 600;
        }

        .customer-info {
            text-align: left;
            font-size: 18px; /* Slightly smaller */
            margin-bottom: 30px;
            line-height: 1.4; /* Reduced line height */
        }

        .customer-info strong {
            font-weight: 700;
            color: #006241;
        }

        .receipt-table {
            margin-bottom: 30px;
            width: 100%;
            border-collapse: collapse;
            font-size: 16px; /* Slightly smaller */
            color: #333;
        }

        .receipt-table th {
            text-align: left;
            padding: 12px 8px; /* Reduced padding */
            background-color: #cfe8d1;
            border-bottom: 2px solid #ddd;
            font-weight: 600;
            color: #006241;
        }

        .receipt-table td {
            padding: 12px 8px; /* Reduced padding */
            border-bottom: 1px solid #eee;
        }

        .receipt-table tr:hover {
            background-color: #e1f0e8; /* Green hover effect */
        }

        .total {
            text-align: right;
            font-size: 24px; /* Slightly smaller */
            font-weight: 700;
            color: #e74c3c;
            margin-top: 25px;
        }

        .thank-you {
            text-align: center;
            font-size: 20px; /* Slightly smaller */
            color: #555;
            margin-top: 40px;
            font-style: italic;
            letter-spacing: 1px;
        }

        .button-container {
            display: flex;
            justify-content: space-between;
            margin-top: 40px;
        }

        .button {
            background-color: #006241;
            color: white;
            padding: 15px 25px; /* Adjusted padding */
            border: none;
            border-radius: 12px;
            cursor: pointer;
            font-size: 16px; /* Slightly smaller */
            font-weight: 600;
            text-align: center;
            transition: background-color 0.3s ease, transform 0.2s;
        }

        .button:hover {
            background-color: #008a58;
            transform: scale(1.05); /* Subtle scaling on hover */
        }

        .button-container a {
            display: inline-block;
            background-color: #006241;
            color: white;
            padding: 15px 25px; /* Adjusted padding */
            border-radius: 12px;
            text-decoration: none;
            font-size: 16px; /* Slightly smaller */
            font-weight: 600;
            text-align: center;
            transition: background-color 0.3s ease, transform 0.2s;
        }

        .button-container a:hover {
            background-color: #008a58;
            transform: scale(1.05);
        }

        @media print {
            .button-container {
                display: none;
            }
        }
    </style>
</head>
<body>
    <div class="receipt-container">
        <h1>Coffee Town</h1>
        <h2>Receipt</h2>

        <div class="customer-info">
            <strong>Customer Name:</strong> <?php echo htmlspecialchars($customer['name']); ?><br>
            <strong>Contact Number:</strong> <?php echo htmlspecialchars($customer['contact_number']); ?>
        </div>

        <table class="receipt-table">
            <thead>
                <tr>
                    <th>Item Name</th>
                    <th>Quantity</th>
                    <th>Price</th>
                    <th>Total</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($purchases as $purchase): ?>
                    <tr>
                        <td><?php echo htmlspecialchars($purchase['item_name']); ?></td>
                        <td><?php echo htmlspecialchars($purchase['quantity']); ?></td>
                        <td>₱<?php echo number_format($purchase['price'], 2); ?></td>
                        <td>₱<?php echo number_format($purchase['total_amount'], 2); ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>

        <p class="total">Total Amount Paid: ₱<?php echo number_format($total_amount_paid, 2); ?></p>

        <div class="button-container">
            <button class="button" onclick="window.print();">Print Receipt</button>
            <a href="view_sales.php">View Sales</a>
            <a href="index.php">Home</a>
        </div>

        <p class="thank-you">Thank you for choosing Coffee Town!</p>
    </div>
</body>
</html>