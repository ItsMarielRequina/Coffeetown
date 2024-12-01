<?php
include 'database_connection.php';

$data = json_decode(file_get_contents('php://input'), true);

if ($data) {
    $name = $data['product_name'];
    $description = $data['description'];
    $price = $data['price'];
    $quantity = $data['quantity'];
    $image = $data['image_url'];

    $stmt = $conn->prepare("INSERT INTO products (product_name, description, price, quantity, images) VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("ssdiss", $name, $description, $price, $quantity, $image);
    $stmt->execute();

    echo json_encode(['success' => true]);
}
?>
