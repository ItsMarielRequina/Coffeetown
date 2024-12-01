<?php
// process_order.php  
session_start();  
include 'db.php'; // Include your database connection  

if ($_SERVER['REQUEST_METHOD'] == 'POST') {  
    $customer_name = htmlspecialchars($_POST['customer_name']);  
    $items = htmlspecialchars($_POST['items']);  
    $payment_method = htmlspecialchars($_POST['payment_method']);  
    
    // Store order in the database  
    $stmt = $pdo->prepare("INSERT INTO sales (customer_name, items, payment_method, created_at) VALUES (?, ?, ?, NOW())");  
    $stmt->execute([$customer_name, $items, $payment_method]);  

    // Fetch the last inserted ID for the receipt  
    $order_id = $pdo->lastInsertId();  

    // Display receipt  
    echo "<h2>Receipt</h2>";  
    echo "Order ID: " . $order_id . "<br>";  
    echo "Customer Name: " . $customer_name . "<br>";  
    echo "Items: " . $items . "<br>";  
    echo "Payment Method: " . $payment_method . "<br>";  
    echo "<a href='order_form.php'>Place Another Order</a>";  
}
?>
