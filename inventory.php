<?php 
session_start();

if (!isset($_SESSION['user_id'])) {
    header('Location: login.php'); // Redirect to login page if not logged in
    exit;
}

include 'db.php'; // Include your database connection

// Function to fetch all products from the inventory table
function getAllProducts() {
    global $pdo; // Access the $pdo variable defined in db.php
    $stmt = $pdo->prepare("SELECT id, product_name, total_cost, quantity, stock_supply, supplier_id FROM inventory");
    $stmt->execute();
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

// Fetch all products
$products = getAllProducts();

// Automatically add a new product from the products database
function addNewProduct($productId, $totalCost, $quantity, $stockSupply, $supplierId) {
    global $pdo;

    // Fetch the product name from the products database
    $stmt = $pdo->prepare("SELECT product_name FROM products WHERE id = :product_id");
    $stmt->execute(['product_id' => $productId]);
    $product = $stmt->fetch(PDO::FETCH_ASSOC);

    // Debugging output: Check if the product was found
    if ($product) {
        $productName = $product['product_name'];
        echo "Product found: $productName<br>"; // Debugging output

        // Check if the product already exists in inventory
        $stmt = $pdo->prepare("SELECT COUNT(*) FROM inventory WHERE product_name = :product_name");
        $stmt->execute(['product_name' => $productName]);
        $exists = $stmt->fetchColumn();

        // Debugging output: Check if the product exists in inventory
        echo "Product exists in inventory: " . ($exists > 0 ? 'Yes' : 'No') . "<br>"; // Debugging output

        if ($exists == 0) {
            // Prepare the SQL statement to insert the new product
            $stmt = $pdo->prepare("INSERT INTO inventory (product_name, total_cost, quantity, stock_supply, supplier_id, is_new) 
            VALUES (:product_name, :total_cost, :quantity, :stock_supply, :supplier_id, 1)");

            // Bind the parameters
            $stmt->execute([
                'product_name' => $productName,
                'total_cost' => $totalCost,
                'quantity' => $quantity,
                'stock_supply' => $stockSupply,
                'supplier_id' => $supplierId
            ]);

            // Optionally, you can return a success message or perform additional actions here
            return "New product '$productName' added automatically to inventory!";
        } else {
            return "Product '$productName' already exists in inventory.";
        }
    } else {
        return "Product ID: $productId not found in products database.";
    }
}

// Check if the order form has been submitted
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['order_product_id']) && isset($_POST['order_quantity'])) {
    $productId = intval($_POST['order_product_id']);
    $orderQuantity = intval($_POST['order_quantity']);

    // Get the product details
    $stmt = $pdo->prepare("SELECT total_cost, quantity, stock_supply, supplier_id FROM inventory WHERE id = :product_id");
    $stmt->execute(['product_id' => $productId]);
    $product = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($product) {
        if ($product['stock_supply'] >= $orderQuantity) {
            $pricePerProduct = floatval($product['total_cost']);
            $totalCost = $pricePerProduct * $orderQuantity;

            // Record the expense in the expenses table
            $stmt = $pdo->prepare("INSERT INTO expenses (product_id, order_quantity, total_cost) VALUES (:product_id, :order_quantity, :total_cost)");
            $stmt->execute([
                'product_id' => $productId,
                'order_quantity' => $orderQuantity,
                'total_cost' => $totalCost
            ]);

            // Update the inventory
            $newQuantity = intval($product['quantity']) + $orderQuantity;
            $newStockSupply = intval($product['stock_supply']) - $orderQuantity;

            $stmt = $pdo->prepare("UPDATE inventory SET quantity = :new_quantity, stock_supply = :new_stock_supply WHERE id = :product_id");
            $stmt->execute([
                'new_quantity' => $newQuantity,
                'new_stock_supply' => $newStockSupply,
                'product_id' => $productId
            ]);

            // Deduct stock from suppliers table based on the order quantity
            $stmt = $pdo->prepare("UPDATE suppliers SET stock_supply = stock_supply - :order_quantity WHERE id = :supplier_id");
            $stmt->execute([
                'order_quantity' => $orderQuantity,
                'supplier_id' => $product['supplier_id']
            ]);

            // Set a success message in session
            $_SESSION['flash_message'] = "Ordered $orderQuantity units of Product ID: $productId. Inventory updated.";
        } else {
            $_SESSION['flash_message'] = "Not enough stock or supply for Product ID: $productId.";
        }
    } else {
        $_SESSION['flash_message'] = "Product not found.";
    }

    // Redirect to the same page to prevent form resubmission
    header("Location: " . $_SERVER['PHP_SELF']);
    exit;
}

// Check if there is a flash message and store it for display
$flashMessage = '';
if (isset($_SESSION['flash_message'])) {
    $flashMessage = $_SESSION['flash_message'];
    unset($_SESSION['flash_message']); // Clear the flash message
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
<link rel="icon" href="images/favicon.ico" type="image/x-icon">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventory - Coffee Town</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f8f8f8; /* Lighter background */
            color: #333;
        }
        .main-container {
            padding: 20px;
            max-width: 1200px;
            margin: 60px auto;

        }

        h2 {
            color: #006241;
            font-size: 32px; /* Increased font size */
            margin-bottom: 20px;
            text-transform: uppercase;
            text-align: center;
            font-weight: 600;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }

        th, td {
            padding: 15px;
            text-align: left;
            border: 1px solid #ddd;
        }

        th {
            background-color: #006241;
            color: white;
        }

        tr:hover {
            background-color: #d7ffd9; /* Row hover effect */
        }

        .quantity {
            text-align: center;
        }

        .order-form {
            margin-top: 20px;
            text-align: center;
        }

        input[type="number"] {
            width: 60px;
            padding: 5px;
            font-size: 16px; /* Increased font size */
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        input[type="submit"] {
            background-color: #006241;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px; /* Increased font size */
            transition: background-color 0.3s, transform 0.2s; /* Added transition */
        }

        input[type="submit"]:hover {
            background-color: #004f2d;
            transform: scale(1.05); /* Scale effect on hover */
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0,0,0,0.5);
            justify-content: center;
            align-items: center;
        }

        .modal-content {
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            width: 300px;
            text-align: center;
            position: relative;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }

        .modal h2 {
            margin-top: 0;
            color: #006241;
            font-size: 24px; /* Increased modal title font size */
        }

        .modal p {
            margin: 10px 0;
            font-size: 16px; /* Increased modal message font size */
        }

        .modal .close {
            position: absolute;
            top: 10px;
            right: 10px;
            cursor: pointer;
            font-size: 20px;
            color: #333;
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

        @media (max-width: 768px) {
            h2 {
                font-size: 24px; /* Smaller headings on mobile */
            }

            input[type="number"] {
                width: 50px; /* Smaller input on mobile */
            }

            input[type="submit"] {
                padding: 8px 15px; /* Smaller button on mobile */
                font-size: 14px; /* Smaller button text */
            }

            .modal-content {
                width: 90%; /* Responsive modal */
            }
        }
    </style>
</head>
<body>
    <div class="main-container">
        <h2>Inventory Management</h2>
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Product Name</th>
                    <th>Total Cost Of The Supplier</th>
                    <th>Product Quantity Available</th>
                    <th>The Supplier's Stock Supply</th>
                    <th>Order Quantity</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($products as $product): ?>
                    <tr>
                        <td><?php echo htmlspecialchars($product['id']); ?></td>
                        <td><?php echo htmlspecialchars($product['product_name']); ?></td>
                        <td><?php echo htmlspecialchars($product['total_cost']); ?></td>
                        <td><?php echo htmlspecialchars($product['quantity']); ?></td>
                        <td><?php echo htmlspecialchars($product['stock_supply']); ?></td>
                        <td class="quantity">
                            <form method="POST" class="order-form">
                                <input type="hidden" name="order_product_id" value="<?php echo htmlspecialchars($product['id']); ?>">
                                <input type="number" name="order_quantity" min="1" max="<?php echo htmlspecialchars($product['stock_supply']); ?>" required>
                                <input type="submit" value="Order">
                            </form>
                        </td>
                    </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>

        <!-- Modal -->
        <div id="myModal" class="modal">
            <div class="modal-content">
                <span class="close">&times;</span>
                <h2 id="modal-title">Modal Title</h2>
                <p id="modal-message">Modal message goes here.</p>
            </div>
        </div>
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
    <script>
        // Get modal element
        const modal = document.getElementById("myModal");
        const modalTitle = document.getElementById("modal-title");
        const modalMessage = document.getElementById("modal-message");
        const closeBtn = document.getElementsByClassName("close")[0];
         // Optional: Close flash message after a few seconds
         setTimeout(() => {
            const flashMessage = document.querySelector('.flash-message');
            if (flashMessage) {
                flashMessage.style.opacity = '0';
                setTimeout(() => flashMessage.remove(), 500);
            }
        }, 3000);

        // Function to show the modal with custom title and message
        function showModal(title, message) {
            modalTitle.innerText = title;
            modalMessage.innerText = message;
            modal.style.display = "flex"; // Show the modal
        }

        // Close the modal when the user clicks on the "x" button
        closeBtn.onclick = function() {
            modal.style.display = "none";
        }

        // Close the modal when the user clicks anywhere outside of the modal
        window.onclick = function(event) {
            if (event.target === modal) {
                modal.style.display = "none";
            }
        }
         // Function to replenish stock via AJAX
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
    </script>
</body>
</html>
