<?php
session_start();

if (!isset($_SESSION['user_id'])) {
    echo json_encode(['success' => false, 'message' => 'User not logged in.']);
    exit;
}

include 'db.php'; // Include your database connection

// Get JSON input
$data = json_decode(file_get_contents('php://input'), true);
$productId = $data['product_id'] ?? null;
$orderQuantity = $data['order_quantity'] ?? null;

// Validate input
if ($productId === null || $orderQuantity === null) {
    echo json_encode(['success' => false, 'message' => 'Invalid input.']);
    exit;
}

// Fetch product details from the database
$stmt = $pdo->prepare("SELECT quantity FROM inventory WHERE id = :id");
$stmt->bindParam(':id', $productId);
$stmt->execute();
$product = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$product) {
    echo json_encode(['success' => false, 'message' => 'Product not found.']);
    exit;
}

// Check if enough stock is available
if ($product['quantity'] < $orderQuantity) {
    echo json_encode(['success' => false, 'message' => 'Not enough stock available.']);
    exit;
}

// Proceed to update the inventory
$newQuantity = $product['quantity'] - $orderQuantity;
$updateStmt = $pdo->prepare("UPDATE inventory SET quantity = :quantity WHERE id = :id");
$updateStmt->bindParam(':quantity', $newQuantity);
$updateStmt->bindParam(':id', $productId);

if ($updateStmt->execute()) {
    echo json_encode(['success' => true, 'message' => 'Order placed successfully.']);
} else {
    echo json_encode(['success' => false, 'message' => 'Failed to place order.']);
}
