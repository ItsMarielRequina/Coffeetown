<?php 
session_start();

if (!isset($_SESSION['user_id'])) {
    header('Location: login.php'); // Redirect to login page if not logged in
    exit;
}

include 'db.php'; // Include your database connection

function replenishStock($productId, $quantity) {
    global $pdo;

    // Update inventory stock_supply
    $stmt = $pdo->prepare("UPDATE inventory SET stock_supply = stock_supply + :quantity WHERE id = :productId");
    $stmt->execute(['quantity' => $quantity, 'productId' => $productId]);

    // Update supplier stock_supply (assuming suppliers table has a product_id and stock_supply column)
    $stmtSupplier = $pdo->prepare("UPDATE suppliers SET stock_supply = stock_supply + :quantity WHERE product_id = :productId");
    $stmtSupplier->execute(['quantity' => $quantity, 'productId' => $productId]);
}



// Function to fetch all products with their corresponding supplier info
function getProductsWithSuppliers() {
    global $pdo; // Access the $pdo variable defined in db.php
    $stmt = $pdo->prepare("
        SELECT 
            inventory.product_name, 
            inventory.raw_material_cost, 
            inventory.labor_cost, 
            inventory.overhead_cost, 
            inventory.packaging_cost, 
            inventory.total_cost, 
            inventory.stock_supply, -- Fetch stock supply
            suppliers.supplier_name
        FROM 
            inventory
        LEFT JOIN 
            suppliers ON inventory.id = suppliers.product_id
    ");
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

// Fetch all products with supplier information
$products = getProductsWithSuppliers();
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Suppliers - Coffee Town</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #e8f5e9; /* Subtle green background */
            color: #333;
        }

        .main-container {
            padding: 30px;
            max-width: 1200px;
            margin: 60px auto;
        }

        h2 {
            color: #006241;
            font-size: 32px;
            margin-bottom: 30px;
            text-align: center;
            text-transform: uppercase;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1); /* Add some depth */
            background-color: #fff;
        }

        th, td {
            padding: 16px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        th {
            background-color: #004d40;
            color: white;
            text-transform: uppercase;
            font-weight: 600;
        }

        td {
            font-size: 14px;
        }

        tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        tbody tr:hover {
            background-color: #d7ffd9; /* Highlight row on hover */
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
            }

            h2 {
                font-size: 28px;
            }
        }
    </style>
</head>
<body>
    <div class="main-container">
        <h2>Suppliers</h2>
        <table>
            <thead>
                <tr>
                    <th>Product Name</th>
                    <th>Raw Material Cost</th>
                    <th>Labor Cost</th>
                    <th>Overhead Cost</th>
                    <th>Packaging Cost</th>
                    <th>Total Cost</th>
                    <th>Supplier Name</th>
                    <th>Stock Supply</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($products as $product): ?>
                    <tr>
                        <td><?php echo htmlspecialchars($product['product_name']); ?></td>
                        <td>₱<?php echo htmlspecialchars(number_format($product['raw_material_cost'], 2)); ?></td>
                        <td>₱<?php echo htmlspecialchars(number_format($product['labor_cost'], 2)); ?></td>
                        <td>₱<?php echo htmlspecialchars(number_format($product['overhead_cost'], 2)); ?></td>
                        <td>₱<?php echo htmlspecialchars(number_format($product['packaging_cost'], 2)); ?></td>
                        <td>₱<?php echo htmlspecialchars(number_format($product['total_cost'], 2)); ?></td>
                        <td><?php echo htmlspecialchars($product['supplier_name']); ?></td>
                        <td><?php echo htmlspecialchars($product['stock_supply']); ?></td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
    <div class="sidenav">
        <a href="index.php">🏠 Home</a>
        <a href="view_sales.php">💰 Sales</a>
        <a href="expenses.php">🧾 Expenses</a>
        <a href="inventory.php">📦 Inventory</a>
        <a href="transaction.php">🔄 Transaction</a>
        <a href="logout.php">🚪 Logout</a>
    </div>
    <script>
    function checkStockSupply() {
        const rows = document.querySelectorAll("tbody tr");

        rows.forEach(row => {
            const stockSupplyCell = row.querySelector("td:nth-last-child(1)"); // Get the stock supply cell
            const stockSupply = parseInt(stockSupplyCell.textContent); // Get the stock supply value

            if (stockSupply === 0) {
                const productName = row.cells[0].textContent; // Get the product name
                const productId = row.rowIndex; // Use the row index or a data attribute for product ID

                console.log(`Replenishing stock for ${productName}...`);
                replenishStock(productId);
            }
        });
    }

    function replenishStock() {
        fetch('replenish_stock.php')
            .then(response => response.json())
            .then(data => {
                if (data.status === "success") {
                    console.log(data.message); // Log success message to console
                } else {
                    console.error("Error replenishing stock.");
                }
            })
            .catch(error => console.error("Error:", error));
    }

    // Call replenishStock every 5 seconds
    setInterval(replenishStock, 5000);

    // Refresh the page every 5 seconds to reflect the updated inventory
    setInterval(() => {
        window.location.reload();
    }, 5000);
    </script>

</body>
</html>
