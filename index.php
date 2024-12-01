<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

session_start();
if (!isset($_SESSION['user_id'])) {
    header('Location: login.php'); // Redirect to login page if not logged in
    exit;
}

include 'db.php'; // Include your database connection

// Handle the product addition
if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_POST['add_product'])) {
    $productName = $_POST['product_name'];
    $price = $_POST['price'];
    $quantity = $_POST['quantity'];
    $type = $_POST['type']; // Dropdown value
    $supplierName = $_POST['supplier_name']; // New field for supplier name

    // Handle image upload
    $image = $_FILES['image']['name'];
    $target_dir = "uploads/"; // Ensure this directory exists
    $target_file = $target_dir . basename($image);

    // Validate user input
    if (empty($productName) || empty($price) || empty($quantity) || empty($type) || empty($image) || empty($supplierName)) {
        $error = 'Please fill out all fields.';
    } elseif (!is_numeric($price) || !is_numeric($quantity)) {
        $error = 'Price and quantity must be numbers.';
    } else {
        // Move uploaded file to target directory
        if (move_uploaded_file($_FILES['image']['tmp_name'], $target_file)) {
            // Insert new product into the products table (referencing images column)
            $stmt = $pdo->prepare("INSERT INTO products (product_name, price, type, images) VALUES (?, ?, ?, ?)");
            $stmt->execute([$productName, $price, $type, $target_file]);

            // Get the last inserted product ID
            $productId = $pdo->lastInsertId();

            // Automatically divide the price into four categories
            $rawMaterialCost = $price * 0.40; // 40% for raw material cost
            $laborCost = $price * 0.20;       // 20% for labor cost
            $overheadCost = $price * 0.25;    // 25% for overhead cost
            $packagingCost = $price * 0.15;   // 15% for packaging cost
            $totalCost = $rawMaterialCost + $laborCost + $overheadCost + $packagingCost;

            // Insert into inventory with the split costs
            $stmtInventory = $pdo->prepare("
                INSERT INTO inventory (product_name, raw_material_cost, labor_cost, overhead_cost, packaging_cost, total_cost, quantity, stock_supply, supplier_id, is_new) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
            ");
            $stmtInventory->execute([
                $productName, 
                $rawMaterialCost, 
                $laborCost, 
                $overheadCost, 
                $packagingCost, 
                $totalCost, 
                $quantity, 
                $quantity, // Assuming stock_supply matches quantity for now
                $supplierId // You need to get this value, see below
            ]);

            // Insert supplier name into suppliers table
            $stmtSupplier = $pdo->prepare("INSERT INTO suppliers (supplier_name, product_id) VALUES (?, ?)");
            $stmtSupplier->execute([$supplierName, $productId]);

            // Redirect or show success message
            header('Location: success_page.php'); // Change to your desired location
            exit;
        } else {
            echo "Sorry, there was an error uploading your file.";
        }
    }
}


function getProducts($type, $search = '') {
    global $pdo;
    
    $sql = "SELECT p.*, i.quantity 
            FROM products p 
            LEFT JOIN inventory i ON p.id = i.id 
            WHERE p.type = :type";
    
    if (!empty($search)) {
        $search = '%' . $search . '%';
        $sql .= " AND (p.product_name LIKE :search OR p.description LIKE :search)";
    }

    $stmt = $pdo->prepare($sql);
    $params = ['type' => $type];
    if (!empty($search)) {
        $params['search'] = $search;
    }
    $stmt->execute($params);
    
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

// Handle AJAX search request
if (isset($_GET['ajax_search'])) {
    $searchQuery = isset($_GET['search']) ? $_GET['search'] : '';
    $coffeeProducts = getProducts('coffee', $searchQuery);
    $milkTeaProducts = getProducts('milktea', $searchQuery);
    
    // Return JSON response for AJAX
    echo json_encode([
        'coffee' => $coffeeProducts,
        'milktea' => $milkTeaProducts
    ]);
    exit;
}

$searchQuery = isset($_GET['search']) ? $_GET['search'] : '';
$coffeeProducts = getProducts('coffee', $searchQuery);
$milkTeaProducts = getProducts('milktea', $searchQuery);


// Fetch coffee and milk tea products
$coffeeProducts = getProducts('coffee');
$milkTeaProducts = getProducts('milktea');


// Handle the checkout process
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $buyerName = $_POST['buyer_name'];
    $contactNumber = $_POST['contact_number'];

    // Validate user input
    if (empty($buyerName) || empty($contactNumber)) {
        $error = 'Please fill out all fields.';
    } elseif (!preg_match('/^09\d{9}$/', $contactNumber)) {
        $error = 'Invalid phone number. Please provide an 11-digit number starting with 09.';
    } else {
        // Insert buyer information into the customers table
        $stmt = $pdo->prepare("INSERT INTO customers (name, contact_number) VALUES (?, ?)");
        $stmt->execute([$buyerName, $contactNumber]);

        // Get the last inserted customer ID
        $customerId = $pdo->lastInsertId();

        // Store the customer ID in the session
        $_SESSION['customer_id'] = $customerId;

        // Initialize total amount for the purchase
        $totalAmountPaid = 0;

        // Get the cart data from the session
        $cart = $_SESSION['cart'];

        // Insert products into the purchases table
        foreach ($cart as $item) {
            // Check inventory before proceeding
            $inventoryStmt = $pdo->prepare("SELECT quantity FROM inventory WHERE id = :product_id");
            $inventoryStmt->execute(['product_id' => $item['id']]);
            $inventory = $inventoryStmt->fetch(PDO::FETCH_ASSOC);

            if ($inventory && $inventory['quantity'] >= $item['quantity']) {
                // Insert sale record
                $stmt = $pdo->prepare("INSERT INTO purchases (customerID, item_name, quantity, price, total_amount) VALUES (?, ?, ?, ?, ?)");
                $totalAmount = $item['price'] * $item['quantity'];
                $stmt->execute([$customerId, $item['name'], $item['quantity'], $item['price'], $totalAmount]);

                // Deduct the quantity from inventory
                $updateStmt = $pdo->prepare("UPDATE inventory SET quantity = quantity - :quantity WHERE id = :product_id");
                $updateStmt->execute(['quantity' => $item['quantity'], 'product_id' => $item['id']]);

                // Accumulate total amount paid
                $totalAmountPaid += $totalAmount;
            } else {
                // Optionally, you could handle the case when inventory is insufficient
                // e.g., show an error message to the user
                echo "Not enough stock for " . htmlspecialchars($item['name']);
            }
        }

        // Now store the total amount paid (you can also store it in the purchases table if necessary)
        $_SESSION['total_amount_paid'] = $totalAmountPaid;

        // Clear cart data after checkout
        unset($_SESSION['cart']);

        // Redirect to view_sales.php or customer_purchased_items.php
        header('Location: generate_receipt.php');
        exit;
    }
}
$searchQuery = isset($_GET['search']) ? $_GET['search'] : ''; // Get the search query from the URL

// Fetch coffee and milk tea products based on the search query
$coffeeProducts = getProducts('coffee', $searchQuery);
$milkTeaProducts = getProducts('milktea', $searchQuery);



?>

<!DOCTYPE html>
<html lang="en">

<head>
    <link rel="icon" href="images/favicon.ico" type="image/x-icon">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-mQ93WB5K/sswH6CpvcC/taeO1pSHfGRp5W8FfGjphB5fgCiNSkGe9RlgI9mOr+2z" crossorigin="anonymous">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="icon" href="C:\xampp\htdocs\favicon">
    <title>Coffee Town POS</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
                /* Global Styles */
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            color:  #004f2d;
            display: flex;
            flex-direction: column;
            height: 100vh;
        }

        h2 {
            color: #006241;
            font-size: 28px;
            margin-bottom: 20px;
            text-transform: uppercase;
            text-align: center;
        }

        /* Search Bar */
        .search-bar {
            padding: 20px;
            text-align: center;
            background-color: #006241;
            color: white;
        }

        .search-bar input[type="text"] {
            width: 50%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 16px;
            margin-bottom: 10px; /* Add space below input */
        }

        .search-bar button {
            background-color: white;
            color: #006241;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
        }

        .search-bar button:hover {
            background-color: #004f2d;
            color: white;
        }

        /* Main Container */
        .main-container {
            display: flex;
            flex-grow: 1;
            overflow: hidden;
        }

        /* Product Section */
        .products-section {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
        }

        .product-list {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); /* Responsive grid */
            gap: 20px;
        }

        .product {
            background-color: white;
            border: 1px solid #ddd;
            border-radius: 10px;
            padding: 15px;
            text-align: center;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            transition: transform 0.3s, box-shadow 0.3s;
            position: relative;
            overflow: hidden;
        }

        .product img {
            width: 100%;
            height: auto;
            border-radius: 8px;
            transition: transform 0.3s;
        }

        .product:hover img {
            transform: scale(1.05);
        }

        .product:hover {
            transform: translateY(-5px);
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.1);
        }

        /* Cart Section */
        .cart-section {
            width: 300px;
            background-color: #ffffff;
            border-left: 1px solid #ddd;
            padding: 20px;
            box-shadow: -2px 0px 10px rgba(0, 0, 0, 0.1);
            overflow-y: auto;
            height: 100vh;
            position: relative;
        }

        .cart-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 8px;
            background-color: #f9f9f9;
        }

        .cart-item span {
            flex: 1;
            text-align: center;
        }

        .cart-total {
            font-weight: bold;
            font-size: 18px;
            text-align: center;
            margin-top: 20px;
        }

        .checkout-button {
            background-color: #006241;
            color: white;
            border: none;
            padding: 15px;
            width: 100%;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 10px;
            transition: background-color 0.3s, transform 0.3s;
        }

        .checkout-button:hover {
            background-color: #004f2d;
            transform: scale(1.05);
        }

        /* Sidenav */
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

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.4);
        }

        .modal-content {
            background-color: #fefefe;
            margin: 2% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 80%;
            max-width: 500px;
            border-radius: 5px;
            box-shadow: 0 4px 8px 0 rgba(0,0,0,0.2);
            position: relative;
        }

        .close {
            position: absolute;
            top: 10px;
            right: 20px;
            color: #333;
            font-size: 20px;
            font-weight: bold;
            cursor: pointer;
        }

        .close:hover,
        .close:focus {
            color: black;
            text-decoration: none;
            cursor: pointer;
        }

        .modal input[type="text"],
        .modal input[type="tel"] {
            width: 100%;
            padding: 12px 20px;
            margin: 8px 0;
            display: inline-block;
            border: 1px solid #ccc;
            box-sizing: border-box;
            border-radius: 4px;
        }

        .modal button {
            background-color: #4CAF50;
            border: none;
            color: white;
            padding: 15px 32px;
            font-size: 16px;
            margin: 4px 2px;
            cursor: pointer;
        }

        .modal button:hover {
            background-color: #3e8e41;
        }

        /* Product Add/Delete Buttons */
        .add-product-button,
        .delete-product-button {
            background-color: #006241;
            color: white;
            border: none;
            padding: 10px 20px;
            margin-left: 10px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }

        .add-product-button:hover,
        .delete-product-button:hover {
            background-color: #004c32;
        }

        /* Add Product Form */
        .add-product-container {
            max-width: 400px;
            margin: 0 auto;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            padding: 20px;
        }

        .form-group {
            margin-bottom: 15px;
        }

        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }

        input[type="text"],
        input[type="number"],
        select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }

        input[type="text"]:focus,
        input[type="number"]:focus,
        select:focus {
            border-color: #3e8e41;
            outline: none;
        }

        .submit-button {
            width: 100%;
            padding: 10px;
            background-color: #3e8e41;
            color: #fff;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }

        .submit-button:hover {
            background-color: #2c6e30;
        }

        /* Responsive Styles */
        @media (max-width: 768px) {
            .search-bar input[type="text"] {
                width: 80%;
            }

            .product-list {
                grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); /* Adjust grid columns */
            }

            .cart-section {
                width: 100%;
                height: auto;
                border-left: none;
                box-shadow: none;
            }

            .main-container {
                flex-direction: column;
            }
        }

    </style>
        </head>

        <body>

            <div class="container">
                <!-- Search Bar Section -->
                <form method="GET" action="" class="search-bar" onsubmit="checkSearchInput(event)">
                <h1>CoffeeTown</h1>
                    <div class="input-group">
                        <input type="text" name="search" class="form-control" placeholder="Search for products..." value="<?php echo htmlspecialchars($searchQuery); ?>">
                        <button type="submit" class="btn btn-primary">Search</button>
                        <button type="button" class="btn add-product-button" onclick="openAddProductModal()">Add Product</button>
                        <button type="button" class="btn delete-product-button" onclick="openDeleteProductModal()">Delete Product</button>
                    </div>
                </form>

                <!-- Main Container for Products and Cart -->
                <div class="main-container">
                    <div class="products-section">
                        <!-- Coffee Products -->
                        <h2>Our Coffee</h2>
                        <div class="product-list">
                            <?php foreach ($coffeeProducts as $product): ?>
                                <div class="product">
                                    <img src="<?php echo htmlspecialchars($product['images']); ?>" alt="<?php echo htmlspecialchars($product['product_name']); ?>">
                                    <h3><?php echo htmlspecialchars($product['product_name']); ?></h3>
                                    <p class="price">₱<?php echo number_format($product['price'], 2); ?></p>
                                    <?php if ($product['quantity'] > 0): ?>
                                        <button onclick="addToCart(<?php echo $product['id']; ?>, '<?php echo htmlspecialchars($product['product_name']); ?>', <?php echo $product['price']; ?>, <?php echo $product['quantity']; ?>)">Add</button>
                                    <?php else: ?>
                                        <p style="color: red;">Out of Stock</p>
                                    <?php endif; ?>
                                </div>
                            <?php endforeach; ?>
                        </div>

                        <!-- Milk Tea Products -->
                        <h2>Our Milk Tea</h2>
                        <div class="product-list">
                            <?php foreach ($milkTeaProducts as $product): ?>
                                <div class="product">
                                    <img src="<?php echo htmlspecialchars($product['images']); ?>" alt="<?php echo htmlspecialchars($product['product_name']); ?>">
                                    <h3><?php echo htmlspecialchars($product['product_name']); ?></h3>
                            
                                    <p class="price">₱<?php echo number_format($product['price'], 2); ?></p>
                                    <?php if ($product['quantity'] > 0): ?>
                                        <button onclick="addToCart(<?php echo $product['id']; ?>, '<?php echo htmlspecialchars($product['product_name']); ?>', <?php echo $product['price']; ?>, <?php echo $product['quantity']; ?>)">Add</button>
                                    <?php else: ?>
                                        <p style="color: red;">Out of Stock</p>
                                    <?php endif; ?>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    </div>

                    <!-- Cart Section -->
                    <div class="cart-section">
                        <h2>Cart</h2>
                        <div id="cart-items"></div>
                        <div class="cart-total">
                            <h3>Total: ₱<span id="cart-total">0.00</span></h3>
                        </div>
                        <form method="POST" id="checkout-form">
                            <input type="hidden" name="buyer_name" id="buyer-name">
                            <input type="hidden" name="contact_number" id="contact-number">
                            <button type="button" class="checkout-button" onclick="charge()">Purchase</button>
                        </form>
                    </div>
                </div>

                <!-- Modal for Customer Details -->
                <div id="customerModal" class="modal">
                    <div class="modal-content">
                        <span class="close" onclick="closeCustomerModal()">&times;</span>
                        <h2>Customer Details</h2>
                        <form id="customer-form">
                            <label for="buyer-name-modal">Name:</label>
                            <input type="text" id="buyer-name-modal" name="buyer_name" required>

                            <label for="contact-number-modal">Contact Number:</label>
                            <input type="text" id="contact-number-modal" name="contact_number" required>
                            <small id="phone-error" style="color:red;display:none;">Invalid phone number. Please provide an 11-digit number starting with 09.</small>

                            <label for="payment-method-modal">Mode of Payment:</label>
                            <select id="payment-method-modal" name="payment_method" required>
                                <option value="cash">Cash</option>
                                <option value="credit_card">Credit Card</option>
                                <option value="mobile_payment">Mobile Payment</option>
                            </select>

                            <button type="button" onclick="submitCustomerForm()">Confirm Purchase</button>
                        </form>
                    </div>
                </div>

                <!-- Modal for Add Product -->
                <div id="add-product-modal" class="modal">
                    <div class="modal-content">
                        <span class="close" onclick="closeAddProductModal()">&times;</span>
                        <h2>Add New Product</h2>
                        <form method="POST" action="" enctype="multipart/form-data">
                            <label for="product_name">Product Name</label>
                            <input type="text" name="product_name" required>

                            <label for="price">Price</label>
                            <input type="number" name="price" required>

                            <label for="quantity">Quantity</label>
                            <input type="number" name="quantity" required>

                            <label for="type">Type</label>
                            <select name="type" required>
                                <option value="coffee">Coffee</option>
                                <option value="milktea">Milk Tea</option>
                            </select>

                            <label for="supplier_name">Supplier Name</label>
                            <input type="text" name="supplier_name" required>

                            <label for="image">Product Image</label>
                            <input type="file" name="image" required>

                            <button type="submit" name="add_product" class="submit-button">Add Product</button>
                        </form>
                    </div>
                </div>

               
                <!-- Modal for Delete Product -->
                <div id="delete-product-modal" class="modal">
                    <div class="modal-content">
                        <span class="close" onclick="closeDeleteProductModal()">&times;</span>
                        <h2>Delete Product</h2>
                        <form method="POST" action="delete_product.php">
                            <label for="product_name_delete">Product Name</label>
                            <input type="text" name="product_name_delete" required>
                            <button type="submit" name="delete_product" class="submit-button">Delete Product</button>
                        </form>
                    </div>
                </div>


                <!-- Sidebar Navigation -->
                <div class="sidenav">
                    <a href="view_sales.php">💰 Sales</a>
                    <a href="expenses.php">🧾 Expenses</a>
                    <a href="inventory.php">📦 Inventory</a>
                    <a href="supplier.php">👤 Supplier</a>
                    <a href="transaction.php">🔄 Transaction</a>
                    <a href="logout.php">🚪 Logout</a>
                </div>
            </div>


 <script>
// Open Add Product Modal
function openAddProductModal() {
    const modal = document.getElementById('add-product-modal');
    modal.style.display = 'block'; // Show modal
}

// Close Add Product Modal
function closeAddProductModal() {
    const modal = document.getElementById('add-product-modal');
    modal.style.display = 'none'; // Hide modal
}

// Open Delete Product Modal
function openDeleteProductModal() {
    const modal = document.getElementById('delete-product-modal');
    modal.style.display = 'block'; // Show modal
}

// Close Delete Product Modal
function closeDeleteProductModal() {
    const modal = document.getElementById('delete-product-modal');
    modal.style.display = 'none'; // Hide modal
}

// Open Customer Modal
function openModal() {
    const modal = document.getElementById('customerModal');
    modal.style.display = 'block'; // Show modal
}

// Close Customer Modal
function closeModal() {
    const modal = document.getElementById('customerModal');
    modal.style.display = 'none'; // Hide modal
}

// Automatically reset when the input is cleared
document.addEventListener('DOMContentLoaded', function () {
    const searchInput = document.querySelector('input[name="search"]');
    searchInput.addEventListener('input', function () {
        if (searchInput.value.trim() === '') {
            // Redirect to the same page without the search query
            window.location.href = window.location.pathname;
        }
    });
});

let cart = [];
let cartTotal = 0;

function addToCart(id, name, price, inventoryQuantity) {
    const existingItem = cart.find(i => i.id === id);

    // Debugging: Check current inventory quantity
    console.log("Adding to cart:", { id, name, price, inventoryQuantity });

    if (existingItem) {
        // Ensure we are not exceeding the available inventory
        if (existingItem.quantity < inventoryQuantity) {
            existingItem.quantity++;
        } else {
            alert("You cannot add more than the available stock.");
            return;
        }
    } else {
        if (inventoryQuantity > 0) {
            const item = { id, name, price, quantity: 1 };
            cart.push(item);
        } else {
            alert("This item is out of stock.");
            return;
        }
    }

    // Update cart total
    cartTotal = cart.reduce((total, item) => total + (item.price * item.quantity), 0);
    updateCart();
    showNotification(`${name} added to cart!`);
}

function removeFromCart(id) {
    const itemIndex = cart.findIndex(i => i.id === id);

    if (itemIndex > -1) {
        cartTotal -= cart[itemIndex].price * cart[itemIndex].quantity; // Subtract the total price of the item
        cart.splice(itemIndex, 1); // Remove the item from the cart
        updateCart(); // Update the cart view
        showNotification(`Item removed from cart!`);
    } else {
        console.log("Item not found in cart"); // You can log this to help with debugging
    }
}


function updateCart() {
    const cartItemsContainer = document.getElementById('cart-items');
    cartItemsContainer.innerHTML = '';
    cart.forEach(item => {
        const cartItem = document.createElement('div');
        cartItem.className = 'cart-item';
        cartItem.innerHTML = `<span>${item.name}</span>
                              <span>x ${item.quantity}</span> <!-- Added quantity here -->
                              <span>₱${item.price.toFixed(2)}</span>
                              <button class="remove-button" onclick="removeFromCart(${item.id})">Remove</button>`;
        cartItemsContainer.appendChild(cartItem);
    });
    document.getElementById('cart-total').innerText = cartTotal.toFixed(2);
}

function showNotification(message) {
    const notification = document.createElement('div');
    notification.innerText = message;
    notification.style.position = 'fixed';
    notification.style.top = '20px';
    notification.style.right = '20px';
    notification.style.backgroundColor = 'white';
    notification.style.color = '#006241';
    notification.style.padding = '10px';
    notification.style.borderRadius = '5px';
    notification.style.zIndex = '100';
    document.body.appendChild(notification);
    setTimeout(() => {
        document.body.removeChild(notification);
    }, 1000);
}

// Submit form and close modal
function submitCustomerForm() {
    const buyerName = document.getElementById('buyer-name-modal').value;
    const contactNumber = document.getElementById('contact-number-modal').value;
    const paymentMethod = document.getElementById('payment-method-modal').value;

    if (buyerName && contactNumber && paymentMethod) {
        const phoneRegex = /^09\d{9}$/;
        if (!phoneRegex.test(contactNumber)) {
            document.getElementById('phone-error').style.display = 'block';
            return;
        } else {
            document.getElementById('phone-error').style.display = 'none';
        }

        document.getElementById('buyer-name').value = buyerName;
        document.getElementById('contact-number').value = contactNumber;

        fetch('store_cart.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ cart, payment_method: paymentMethod })
        }).then(() => {
            document.getElementById('checkout-form').submit();
        });

        closeModal();
    } else {
        alert("Please fill out all fields.");
    }
}

// Open modal when clicking "Purchase" button
function charge() {
    openModal();
}

// Close the modal when clicking the close button
document.querySelectorAll('.close').forEach(closeButton => {
    closeButton.addEventListener('click', function(event) {
        const modal = event.target.closest('.modal');
        modal.style.display = 'none';
    });
});

// Close modal when user clicks outside of it
window.onclick = function(event) {
    const modal = document.getElementById('customerModal');
    const addProductModal = document.getElementById('add-product-modal');
    const deleteProductModal = document.getElementById('delete-product-modal');
    if (event.target == modal || event.target == addProductModal || event.target == deleteProductModal) {
        event.target.style.display = 'none';
    }
}

    </script>
</body>
</html>
