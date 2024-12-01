<?php
session_start();

// Check if the user is logged in
if (!isset($_SESSION['user_id'])) {
    header("Location: login.php");
    exit;
}

// Calculate the duration of the session
$login_time = isset($_SESSION['login_time']) ? $_SESSION['login_time'] : time();
$duration = time() - $login_time;

// Clear the session data
session_unset();
session_destroy();

// Redirect to the login page with the duration message
header("Location: login.php?duration=" . urlencode($duration_message));
exit;
?>
