<?php
include 'db.php';

if (isset($_GET['id'])) {
    $productId = $_GET['id'];
    $stmt = $pdo->prepare("SELECT id, product_name, price, quantity FROM products WHERE id = :id");
    $stmt->execute(['id' => $productId]);
    $product = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode($product); // Return product details as JSON
}
?>
