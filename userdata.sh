#!/bin/bash

apt update
apt install -y apache2

# Get the instance ID using the instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Install the AWS CLI
apt install -y awscli

# Download the images from S3 bucket
#aws s3 cp s3://myterraformprojectbucket2023/project.webp /var/www/html/project.png --acl public-read

# Create a simple HTML file with the portfolio content and display the images
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>My Portfolio</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
        }
        header {
            background-color: #333;
            color: #fff;
            padding: 10px 0;
            text-align: center;
        }
        .container {
            max-width: 1200px;
            margin: 20px auto;
            padding: 0 20px;
            text-align: center;
        }
        .profile-image {
            border-radius: 50%;
            width: 150px;
            height: 150px;
            object-fit: cover;
            margin: 20px auto;
            display: block;
        }
        h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        p {
            font-size: 1.2em;
            color: #555;
        }
        .instance-info {
            background-color: #fff;
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 15px;
            margin: 20px auto;
            max-width: 400px;
            font-size: 1em;
            color: #333;
        }
        footer {
            background-color: #333;
            color: #fff;
            text-align: center;
            padding: 10px 0;
            margin-top: 40px;
        }
    </style>
</head>
<body>
    <header>
        <h1>My Portfolio</h1>
    </header>
    <div class="container">
        <img src="project.png" alt="Profile Image" class="profile-image">
        <h1>Welcome to Jatin's Portfolio</h1>
        <p>This page is hosted on an AWS EC2 instance using Apache web server.</p>
        <div class="instance-info">
            <strong>EC2 Instance ID:</strong> ${INSTANCE_ID}
        </div>
        <p>
            I am a passionate developer with experience in cloud computing,
            infrastructure as code, and building scalable applications on AWS.
        </p>
    </div>
    <footer>
        <p>&copy; 2024 My Portfolio. All rights reserved.</p>
    </footer>
</body>
</html>
EOF

# Start and enable Apache
systemctl start apache2
systemctl enable apache2