<?php
session_start();
include 'db.php'; // Include your database connection

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
    $stmt = $pdo->prepare("INSERT INTO users (username, email, password) VALUES (:username, :email, :password)");
    $stmt->execute(['username' => $username, 'email' => $email, 'password' => $hashed_password]);

    // Retrieve the user id of the newly created user
    $user_id = $pdo->lastInsertId();

    // Store the user id in the session
    $_SESSION['user_id'] = $user_id;

    // Redirect to login.php after successful signup
    header("Location: login.php");
    exit;
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
<link rel="icon" href="images/favicon.ico" type="image/x-icon">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - Coffee Town</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(130deg, #ffddcc, #f0f0f0, #004f2d);
            background-size: 300% 300%;
            animation: gradientBG 10s ease infinite;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        @keyframes gradientBG {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        .signup-container {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 60px 40px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
            width: 400px;
            text-align: center;
            position: relative;
        }

        .signup-container h1 {
            font-size: 36px;
            color: #006241;
            margin-bottom: 20px;
            position: relative;
        }

        .signup-container h1::after {
            content: '';
            position: absolute;
            bottom: -5px;
            left: 50%;
            transform: translateX(-50%);
            width: 70px;
            height: 4px;
            background-color: #006241;
            border-radius: 2px;
            animation: titleUnderline 1.5s infinite alternate ease-in-out;
        }

        @keyframes titleUnderline {
            from { width: 0; }
            to { width: 70px; }
        }

        .signup-container input {
            width: 100%;
            padding: 15px;
            margin: 15px 0;
            border: none;
            border-radius: 50px;
            background: #f7f7f7;
            box-shadow: inset 4px 4px 8px rgba(0, 0, 0, 0.1), inset -4px -4px 8px rgba(255, 255, 255, 0.7);
            font-size: 16px;
            transition: all 0.3s ease;
        }

        .signup-container input:focus {
            outline: none;
            box-shadow: inset 4px 4px 10px rgba(0, 0, 0, 0.15), inset -4px -4px 10px rgba(255, 255, 255, 0.9);
        }

        .signup-container button {
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 50px;
            background-color: #006241;
            color: white;
            font-size: 18px;
            cursor: pointer;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
            transition: background-color 0.3s ease, transform 0.3s ease;
        }

        .signup-container button:hover {
            background-color: #004f2d;
            transform: translateY(-2px);
        }

        .signup-container button:active {
            transform: translateY(2px);
        }

        .error {
            color: #d32f2f;
            margin-top: 15px;
            font-size: 16px;
        }

        .link {
            margin-top: 30px;
            display: block;
            color: #006241;
            font-size: 14px;
            text-decoration: none;
            transition: color 0.3s;
        }

        .link:hover {
            color: #004f2d;
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="signup-container">
        <h1>Sign Up</h1>
        <?php if (isset($_GET['error'])): ?>
            <p class="error"><?php echo htmlspecialchars($_GET['error']); ?></p>
        <?php endif; ?>
        <form action="signup_process.php" method="POST">
            <input type="text" name="username" placeholder="Username" required>
            <input type="email" name="email" placeholder="Email" required>
            <input type="password" name="password" placeholder="Password" required>
            <button type="submit">Sign Up</button>
            <a href="login.php" class="link">Already have an account? Login</a>
        </form>
    </div>
</body>
</html>
