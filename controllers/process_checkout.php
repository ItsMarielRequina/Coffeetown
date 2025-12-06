<?php
session_start();
header('Content-Type: application/json');
require_once __DIR__ . '/../config/db.php';

// Check if the request is a POST request
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// Check if user is logged in
if (!isset($_SESSION['user_id'])) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Please log in to complete your order']);
    exit;
}

// Get and validate input data
$data = json_decode(file_get_contents('php://input'), true);

if (!$data) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Invalid request data']);
    exit;
}

try {
    // Validate required fields
    $required = ['customer_name', 'email', 'address', 'phone', 'payment_method', 'items'];
    foreach ($required as $field) {
        if (empty($data[$field])) {
            throw new Exception("Missing required field: $field");
        }
    }

    // Sanitize and validate input
    $customer_name = filter_var($data['customer_name'], FILTER_SANITIZE_STRING);
    $email = filter_var($data['email'], FILTER_VALIDATE_EMAIL);
    $address = filter_var($data['address'], FILTER_SANITIZE_STRING);
    $phone = filter_var($data['phone'], FILTER_SANITIZE_STRING);
    $payment_method = filter_var($data['payment_method'], FILTER_SANITIZE_STRING);
    $items = $data['items'];
    $user_id = $_SESSION['user_id'];
    $total_amount = 0;

    if (!$email) {
        throw new Exception('Invalid email address');
    }

    if (!is_array($items) || empty($items)) {
        throw new Exception('No items in the cart');
    }

    // Begin transaction
    $pdo->beginTransaction();

    try {
        // 1. Create order record
        $stmt = $pdo->prepare("
            INSERT INTO orders (
                user_id,
                customer_name,
                email,
                address,
                phone,
                payment_method,
                status,
                total_amount,
                created_at
            ) VALUES (
                :user_id,
                :customer_name,
                :email,
                :address,
                :phone,
                :payment_method,
                'pending',
                :total_amount,
                NOW()
            )
        ");

        // Calculate total amount
        foreach ($items as $item) {
            if (!isset($item['product_id'], $item['quantity'], $item['price'])) {
                throw new Exception('Invalid item data');
            }
            $total_amount += $item['price'] * $item['quantity'];
        }

        $stmt->execute([
            ':user_id' => $user_id,
            ':customer_name' => $customer_name,
            ':email' => $email,
            ':address' => $address,
            ':phone' => $phone,
            ':payment_method' => $payment_method,
            ':total_amount' => $total_amount
        ]);

        $order_id = $pdo->lastInsertId();

        if (!$order_id) {
            throw new Exception('Failed to create order');
        }

        // 2. Add order items and update product quantities
        $orderItemStmt = $pdo->prepare("
            INSERT INTO order_items (
                order_id,
                product_id,
                product_name,
                quantity,
                price_per_unit,
                total_price
            ) VALUES (
                :order_id,
                :product_id,
                :product_name,
                :quantity,
                :price_per_unit,
                :total_price
            )
        ");

        $updateProductStmt = $pdo->prepare("
            UPDATE products 
            SET quantity = quantity - :quantity 
            WHERE id = :product_id 
            AND quantity >= :quantity
        ");

        foreach ($items as $item) {
            // Add order item
            $orderItemStmt->execute([
                ':order_id' => $order_id,
                ':product_id' => $item['product_id'],
                ':product_name' => $item['product_name'],
                ':quantity' => $item['quantity'],
                ':price_per_unit' => $item['price'],
                ':total_price' => $item['price'] * $item['quantity']
            ]);

            // Update product quantity
            $updateProductStmt->execute([
                ':product_id' => $item['product_id'],
                ':quantity' => $item['quantity']
            ]);

            if ($updateProductStmt->rowCount() === 0) {
                throw new Exception('Insufficient stock for product ID: ' . $item['product_id']);
            }
        }

        // 3. Clear the user's cart
        $clearCartStmt = $pdo->prepare("DELETE FROM cart_items WHERE user_id = ?");
        $clearCartStmt->execute([$user_id]);

        // 4. Generate receipt
        $receiptData = [
            'order_id' => $order_id,
            'customer_name' => $customer_name,
            'email' => $email,
            'address' => $address,
            'phone' => $phone,
            'payment_method' => $payment_method,
            'total_amount' => $total_amount,
            'items' => array_map(function($item) {
                return [
                    'product_id' => $item['product_id'],
                    'product_name' => $item['product_name'],
                    'quantity' => $item['quantity'],
                    'price' => $item['price'],
                    'total' => $item['price'] * $item['quantity']
                ];
            }, $items),
            'order_date' => date('Y-m-d H:i:s')
        ];

        // 5. Commit the transaction
        $pdo->commit();

        // 6. Return success response with receipt data
        echo json_encode([
            'success' => true,
            'message' => 'Order placed successfully',
            'order_id' => $order_id,
            'receipt' => $receiptData,
            'redirect' => '/Coffeetown/views/orders/success_page.php?order_id=' . $order_id
        ]);

    } catch (Exception $e) {
        // Rollback the transaction on error
        $pdo->rollBack();
        throw $e;
    }

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
