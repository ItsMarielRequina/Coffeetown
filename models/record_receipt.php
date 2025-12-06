<?php
session_start();
header('Content-Type: application/json');
require_once __DIR__ . '/../config/db.php';

try {
    // Check if user is authenticated
    if (!isset($_SESSION['user_id'])) {
        throw new Exception('User not authenticated');
    }

    // Get and validate input data
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!$data || !isset($data['order_id']) || !isset($data['items'])) {
        throw new Exception('Invalid request data');
    }

    $order_id = filter_var($data['order_id'], FILTER_VALIDATE_INT);
    $user_id = $_SESSION['user_id'];
    
    if ($order_id === false) {
        throw new Exception('Invalid order ID');
    }

    // Begin transaction
    $pdo->beginTransaction();

    try {
        // Prepare receipt header
        $receiptStmt = $pdo->prepare("
            INSERT INTO receipts (
                order_id, 
                user_id, 
                total_amount, 
                payment_method, 
                receipt_date, 
                created_at
            ) 
            SELECT 
                o.id,
                :user_id,
                o.total_amount,
                o.payment_method,
                NOW(),
                NOW()
            FROM orders o
            WHERE o.id = :order_id
            AND o.customer_id = :user_id
        ");

        $receiptStmt->execute([
            ':user_id' => $user_id,
            ':order_id' => $order_id
        ]);

        $receipt_id = $pdo->lastInsertId();

        if (!$receipt_id) {
            throw new Exception('Failed to create receipt header');
        }

        // Prepare receipt items statement
        $itemStmt = $pdo->prepare("
            INSERT INTO receipt_items (
                receipt_id,
                product_id,
                product_name,
                quantity,
                unit_price,
                total_price
            )
            SELECT 
                :receipt_id,
                oi.product_id,
                p.product_name,
                oi.quantity,
                oi.price_per_unit,
                oi.total_price
            FROM order_items oi
            JOIN products p ON oi.product_id = p.id
            WHERE oi.order_id = :order_id
        ");

        $itemStmt->execute([
            ':receipt_id' => $receipt_id,
            ':order_id' => $order_id
        ]);

        // Update order status to indicate receipt was generated
        $updateOrderStmt = $pdo->prepare("
            UPDATE orders 
            SET status = 'completed', 
                receipt_generated = 1,
                updated_at = NOW()
            WHERE id = :order_id
            AND customer_id = :user_id
        ");

        $updateOrderStmt->execute([
            ':order_id' => $order_id,
            ':user_id' => $user_id
        ]);

        // Commit transaction
        $pdo->commit();

        // Get the complete receipt data
        $receiptData = $pdo->prepare("
            SELECT 
                r.id as receipt_id,
                r.order_id,
                r.receipt_date,
                r.total_amount,
                r.payment_method,
                (
                    SELECT JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'product_id', ri.product_id,
                            'product_name', ri.product_name,
                            'quantity', ri.quantity,
                            'unit_price', ri.unit_price,
                            'total_price', ri.total_price
                        )
                    )
                    FROM receipt_items ri
                    WHERE ri.receipt_id = r.id
                ) as items
            FROM receipts r
            WHERE r.id = :receipt_id
            AND r.user_id = :user_id
        ");

        $receiptData->execute([
            ':receipt_id' => $receipt_id,
            ':user_id' => $user_id
        ]);

        $receipt = $receiptData->fetch(PDO::FETCH_ASSOC);
        $receipt['items'] = json_decode($receipt['items'], true);

        // Return success response
        echo json_encode([
            'success' => true,
            'message' => 'Receipt generated successfully',
            'receipt' => $receipt
        ]);

    } catch (Exception $e) {
        $pdo->rollBack();
        throw $e;
    }

} catch (Exception $e) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to generate receipt: ' . $e->getMessage()
    ]);
}
?>
