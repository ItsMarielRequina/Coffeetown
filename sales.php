<?php
session_start();

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action']) && $_POST['action'] === 'add') {
    // Assuming you have a database connection established
    include 'db.php'; // Make sure to include your database connection

    $name = $_POST['name'];
    $address = $_POST['address'];
    $productName = $_POST['product_name'];
    $productPrice = $_POST['price'];

    // Here you would typically insert the purchase into your database
    // This is a simplified version, adjust according to your database structure
    $stmt = $pdo->prepare("INSERT INTO sales (product_name, price, customer_name, address) VALUES (?, ?, ?, ?)");
    if ($stmt->execute([$productName, $productPrice, $name, $address])) {
        echo json_encode(['status' => 'success']);
    } else {
        echo json_encode(['status' => 'error']);
    }
    exit;
}
?>
