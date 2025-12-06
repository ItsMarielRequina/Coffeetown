<?php
session_start();

// Check if user is logged in
if (!isset($_SESSION['user_id'])) {
    header('Location: /Coffeetown/views/auth/login.php');
    exit;
}

require_once __DIR__ . '/../config/db.php'; // Include database connection

// Function to replenish stock supply
function replenishStock() {
    global $pdo;

    // Update stock_supply for all products in inventory, capping at 100
    $stmt = $pdo->prepare("UPDATE inventory SET stock_supply = LEAST(stock_supply + 10, 100)");
    $stmt->execute();

    // Get all suppliers from the inventory
    $stmt = $pdo->prepare("SELECT DISTINCT supplier_id FROM inventory");
    $stmt->execute();
    $suppliers = $stmt->fetchAll(PDO::FETCH_ASSOC);

    // Update stock_supply for each supplier by decrementing the same amount
    foreach ($suppliers as $supplier) {
        $stmt = $pdo->prepare("UPDATE suppliers SET stock_supply = stock_supply - 10 WHERE id = :supplier_id");
        $stmt->execute(['supplier_id' => $supplier['supplier_id']]);
    }

    // Return a success message
    echo json_encode(["status" => "success", "message" => "Stock replenished successfully."]);
}

replenishStock();


?>
