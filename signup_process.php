<?php
session_start();
include 'db.php'; // Include database connection

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $username = trim($_POST['username']);
    $email = trim($_POST['email']);
    $password = $_POST['password'];
    
    // Simple validation (you can extend this)
    if (empty($username) || empty($email) || empty($password)) {
        die('All fields are required.');
    }
    
    // Check if the username or email already exists
    $stmt = $pdo->prepare("SELECT * FROM staff WHERE username = :username OR email = :email");
    $stmt->execute(['username' => $username, 'email' => $email]);
    $user = $stmt->fetch();

    if ($user) {
        die('Username or Email already exists.');
    }
    
    // Hash the password before saving
    $hashed_password = password_hash($password, PASSWORD_BCRYPT);

    // Insert new user into the database
    $stmt = $pdo->prepare("INSERT INTO staff (username, email, password) VALUES (:username, :email, :password)");
    $stmt->execute(['username' => $username, 'email' => $email, 'password' => $hashed_password]);

    // Retrieve the user id of the newly created user
    $user_id = $pdo->lastInsertId();

    // Store the user id in the session
    $_SESSION['user_id'] = $user_id;

    // Redirect to index.php after successful signup
    header("Location: login.php");
    exit;
}
?>
