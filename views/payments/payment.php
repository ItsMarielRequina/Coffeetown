<?php
session_start();

// Check if user is logged in
if (!isset($_SESSION['user_id'])) {
    header('Location: /Coffeetown/views/auth/login.php');
    exit;
}

require_once __DIR__ . '/../../config/db.php'; // Include database connection

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Collect selected product IDs and their quantities
    $selected_products = $_POST['products'];
    $quantities = $_POST['quantities'];

    foreach ($selected_products as $product_id) {
        $quantity = isset($quantities[$product_id]) ? intval($quantities[$product_id]) : 0;
        // Process the order with $product_id and $quantity
    }

    // Validate input data
    if (!empty($buyer_name) && !empty($buyer_address) && !empty($products)) {
        foreach ($products as $product_id) {
            $quantity = $_SESSION['cart'][$product_id]; // Get the quantity from the session cart

            $total_amount = $product['price'] * $quantity; // Calculate total amount for the product

            // Insert the sale details into the sales table
            $stmt = $pdo->prepare("INSERT INTO sales (buyer_name, buyer_address, product_id, product_name, quantity, price, total_amount) VALUES (:buyer_name, :buyer_address, :product_id, :product_name, :quantity, :price, :total_amount)");
            $stmt->execute([
                'buyer_name' => $buyer_name,
                'buyer_address' => $buyer_address,
                'product_id' => $product_id,
                'product_name' => $product['product_name'],
                'quantity' => $quantity,
                'price' => $product['price'],
                'total_amount' => $total_amount
            ]);
        }

        // Clear the cart after the sale
        unset($_SESSION['cart']);

        // Redirect to the view_sales.php page after successful payment
        header("Location: /Coffeetown/views/reports/view_sales.php");
        exit;
    } else {
        // Redirect back to the previous page with an error message
        $_SESSION['error'] = "Please fill in all the required fields.";
        header("Location: " . $_SERVER['HTTP_REFERER']);
        exit;
    }
} else {
    echo "Invalid request method.";
}
?>
