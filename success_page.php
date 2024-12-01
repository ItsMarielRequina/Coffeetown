<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Added</title>
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #e8f5e9; /* Subtle green background */
            color: #333;
        }

        .success-container {
            text-align: center;
            padding: 50px;
            margin-top: 100px;
        }

        .success-message {
            font-size: 24px;
            color: #28a745;
        }

        .back-link {
            margin-top: 20px;
            display: inline-block;
            padding: 10px 20px;
            background-color: #007bff;
            color: #fff;
            text-decoration: none;
            border-radius: 5px;
        }

        .back-link:hover {
            background-color: #0056b3;
        }

        /* Navbar Styles */
        .navbar {
            display: flex;
            justify-content: center;
            background-color: #007bff;
            padding: 10px;
        }

        .navbar a {
            color: white;
            text-decoration: none;
            padding: 10px 20px;
            margin: 0 10px;
            border-radius: 5px;
            font-size: 16px;
        }

        .navbar a:hover {
            background-color: #0056b3;
        }

        .navbar a.active {
            background-color: #0056b3;
        }

        /* Sidebar Styles */
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

<div class="success-container">
    <h1 class="success-message">Product added successfully!</h1>
    <a href="index.php" class="back-link">Add another product</a>
</div>

<!-- Navbar below the success message -->
<div class="sidenav">
    <a href="index.php">🏠 Home</a>
    <a href="view_sales.php">💰 Sales</a>
    <a href="expenses.php">🧾 Expenses</a>
    <a href="inventory.php">📦 Inventory</a>
    <a href="transaction.php">🔄 Transaction</a>
    <a href="logout.php">🚪 Logout</a>
</div>

</body>
</html>
