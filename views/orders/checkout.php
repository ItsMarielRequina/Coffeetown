<?php
session_start(); // Start the session
include 'db.php'; // Include your database connection

// Fetch cart items from the database
function fetchCartItems($userId) {
    global $db;
    $stmt = $db->prepare("SELECT ci.product_id, ci.quantity, p.price FROM cart_items ci JOIN products p ON ci.product_id = p.id WHERE ci.user_id = ?");
    $stmt->execute([$userId]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

// Ensure user is logged in
if (!isset($_SESSION['user_id'])) {
    echo "Please log in to view your cart.";
    exit;
}

$userId = $_SESSION['user_id'];
$cartItems = fetchCartItems($userId);

// Display cart items
if (empty($cartItems)) {
    echo "Your cart is empty.";
} else {
    foreach ($cartItems as $item) {
        echo "Product ID: " . htmlspecialchars($item['product_id']) . " - Quantity: " . htmlspecialchars($item['quantity']) . " - Price: ₱" . number_format($item['price'], 2) . "<br>";
    }
}
?>
