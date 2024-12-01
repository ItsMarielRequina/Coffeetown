<?php
include 'db.php'; // Include your database connection

if (isset($_GET['id'])) {
    $productId = $_GET['id'];
    
    // Fetch the product quantity from the inventory
    $stmt = $pdo->prepare("SELECT quantity FROM inventory WHERE id = ?");
    $stmt->execute([$productId]);
    $product = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($product) {
        echo json_encode(['quantity' => $product['quantity']]);
    } else {
        echo json_encode(['quantity' => 0]); // Return 0 if product doesn't exist
    }
}
