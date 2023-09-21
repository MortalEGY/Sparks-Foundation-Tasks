<!DOCTYPE html>
<html>
<head>
    <title>Simple Banking System</title>
</head>
<body>
    <h1>Banking System</h1>

    <?php
    // Database connection
    $host = "localhost";
    $username = "root";
    $password = "";
    $database = "bank";

    $conn = new mysqli($host, $username, $password, $database);
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    // Home Page
    if (!isset($_GET['customer']) && !isset($_GET['transfer'])) {
        echo "<h2>Welcome to our Banking System</h2>";
        echo "<a href='?view_customers'>View All Customers</a>";
    }

    // View all Customers
    if (isset($_GET['view_customers'])) {
        $sql = "SELECT * FROM customers";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            echo "<h2>Customers:</h2>";
            echo "<ul>";
            while ($row = $result->fetch_assoc()) {
                echo "<li><a href='?customer=" . $row['id'] . "'>" . $row['name'] . "</a></li>";
            }
            echo "</ul>";
        } else {
            echo "No customers found.";
        }
    }

    // View one Customer
    if (isset($_GET['customer'])) {
        $customer_id = $_GET['customer'];
        $sql = "SELECT * FROM customers WHERE id = $customer_id";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            $customer = $result->fetch_assoc();
            echo "<h2>Customer: " . $customer['name'] . "</h2>";
            echo "Email: " . $customer['email'] . "<br>";
            echo "Balance: $" . $customer['balance'] . "<br>";
            echo "<a href='?transfer=" . $customer['id'] . "'>Transfer Money</a>";
        } else {
            echo "Customer not found.";
        }
    }

    // Transfer Money
    if (isset($_GET['transfer'])) {
        $sender_id = $_GET['transfer'];
        $sql = "SELECT * FROM customers WHERE id = $sender_id";
        $result = $conn->query($sql);

        if ($result->num_rows > 0) {
            $sender = $result->fetch_assoc();
            echo "<h2>Transfer Money from " . $sender['name'] . "</h2>";
            
            // Display list of customers to transfer to
            $sql = "SELECT * FROM customers WHERE id != $sender_id";
            $result = $conn->query($sql);

            if ($result->num_rows > 0) {
                echo "<h3>Select a customer to transfer to:</h3>";
                echo "<ul>";
                while ($row = $result->fetch_assoc()) {
                    echo "<li><a href='?do_transfer=$sender_id&receiver=" . $row['id'] . "'>" . $row['name'] . "</a></li>";
                }
                echo "</ul>";
            } else {
                echo "No customers available for transfer.";
            }
        } else {
            echo "Sender not found.";
        }
    }

    // Perform Money Transfer
    if (isset($_GET['do_transfer'])) {
        $sender_id = $_GET['do_transfer'];
        $receiver_id = $_GET['receiver'];
        
        // Check if the form is submitted
        if (isset($_POST['amount'])) {
            $amount = $_POST['amount'];

            // Check if sender has enough balance
            $sql = "SELECT balance FROM customers WHERE id = $sender_id";
            $result = $conn->query($sql);
            
            if ($result->num_rows > 0) {
                $sender_balance = $result->fetch_assoc()['balance'];
                if ($sender_balance >= $amount) {
                    // Update sender's balance
                    $new_sender_balance = $sender_balance - $amount;
                    $sql = "UPDATE customers SET balance = $new_sender_balance WHERE id = $sender_id";
                    $conn->query($sql);

                    // Update receiver's balance
                    $sql = "SELECT balance FROM customers WHERE id = $receiver_id";
                    $result = $conn->query($sql);
                    if ($result->num_rows > 0) {
                        $receiver_balance = $result->fetch_assoc()['balance'];
                        $new_receiver_balance = $receiver_balance + $amount;
                        $sql = "UPDATE customers SET balance = $new_receiver_balance WHERE id = $receiver_id";
                        $conn->query($sql);

                        // Record the transfer
                        $sql = "INSERT INTO transfers (sender_id, receiver_id, amount) VALUES ($sender_id, $receiver_id, $amount)";
                        if ($conn->query($sql) === TRUE) {
                            echo "Money transfer successful!";
                        } else {
                            echo "Error: " . $sql . "<br>" . $conn->error;
                        }
                    } else {
                        echo "Receiver not found.";
                    }
                } else {
                    echo "Insufficient balance.";
                }
            } else {
                echo "Sender not found.";
            }
        } else {
            // If the form is not submitted, display the form to enter the amount
            echo "<h3>Enter the transfer amount:</h3>";
            echo "<form method='POST' action='?do_transfer=$sender_id&receiver=$receiver_id'>";
            echo "Amount: <input type='text' name='amount'><br>";
            echo "<input type='submit' value='Transfer'>";
            echo "</form>";
        }
    }

    $conn->close();
    ?>

    <p><a href="/Banking-System/banking_system.php">Back to Home</a></p>
</body>
</html>
