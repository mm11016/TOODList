<?php
# Start a PHP session
session_start();

# Set the error flag to false
$error = false;
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    # Define an error flag
    $wsError = false;

    # Grab the user credentials from the $_POST array
    $username = $_POST['username'];
    $password = $_POST['password'];

    if (empty($password) | empty($username)) {
        $error = true;
    } else {

        # Build your JSON string
        $data = array("Username" => $username, "Password" => $password);
        $data_string = json_encode($data);

        # Specify the url of the web service and initialize
        $url = 'https://wlbl4tuvvf.execute-api.us-east-1.amazonaws.com/prod/TestUserLoginFunction';
        $handle = curl_init($url);
        curl_setopt($handle, CURLOPT_RETURNTRANSFER, TRUE);
        curl_setopt($handle, CURLOPT_CUSTOMREQUEST, "POST");
        curl_setopt($handle, CURLOPT_POSTFIELDS, $data_string);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array(
            'Content-Type: application/json',
            'Content-Length: ' . strlen($data_string))
        );

        # Get the response from the web service
        $response = curl_exec($handle);

        # Check the HTTP response code
        $httpCode = curl_getinfo($handle, CURLINFO_HTTP_CODE);
        if($httpCode == 200) {
            # A good response code means we can parse the JSON
            $login_data = json_decode($response, true);
            # Store the login token as a cookie with the 30 day expiration date
            setcookie('token', $login_data['Token'], time() + (86400 * 30), "/");
            $_SESSION["token"] = $login_data['Token'];
        } else if ($httpCode == 404) {
            # A 404 means the user was not found
            $error = true;
        } else {
            # A bad response code means we should display an error message
            $wsError = true;
        }
    }
    if (!$error) {
        header('Location: list.php');
    } else {
        $error = true;
    }
}
?>
<html lang="en">
<head>
  <meta charset="utf-8">

  <title>Login</title>
  <meta name="description" content="Login page">
  <meta name="author" content="Russell Thackston">
  <meta name="viewport" content="width=device-width, initial-scale=2.0">

  <link rel="stylesheet" href="styles.css">

</head>

<body>
    <?php if ($wsError) { ?>
        <p class="err">Web Service Error</p>
    <?php } else if ($error) { ?>
        <p class="err">Login Error</p>
    <?php } ?>

    <form method="post" action="login.php" id="loginform">
        <input type="text" placeholder="Username" id="username" name="username" value="<?php echo $username; ?>"/>
        <br>
        <input type="password" placeholder="Password" id="password" name="password" value="<?php echo $password; ?>" />
        <br>
        <input type="submit" title="Login" alt="Login" id="loginButton" />
        </form>
</body>
</html>
