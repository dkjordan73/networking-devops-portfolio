#!/usr/bin/env bash
set -euo pipefail

#Apache Website Deployment
echo "==> Starting Deployment..."

#Variables
SITE_DIR="/var/www/html"
BACKUP_DIR"=/var/www/html-backup-$(date +%F-%H%M%S)"

#Installing Dependencies
echo "Installing Apache..."
sudo apt-get update -y
sudo apt-get install -y apache2

#Enable and Start Apache
echo "Enabling and starting Apache service..."
sudo systemctl enable apache2
sudo systemctl start apache2

#Backup existing site
echo "Backing up existing website (if any)..."
if [ -d "$SITE_DIR"] && ["$(ls -A "$SITE_DIR)" 2>/dev/null)" ]; then 
    sudo mkdir -p  "$BACKUP_DIR"
    sudo cp -a "$SITE_DIR"/. "$BACKUP_DIR"/
    echo "Backup stored at $BACKUP_DIR"
fi

echo "==> Writing site files to $SITE_DIR..."

#Create the CSS Style Sheet
echo "Creating CSS styles..."
sudo tee "$SITE_DIR/styles.css" >/dev/null <<'CSS'
body {
  font-family: Arial, sans-serif;
  background-color: #1f2933;
  color: #e5e7eb;
  margin: 0;
}

header {
  background-color: #2563eb;
  padding: 20px;
  text-align: center;
}

nav a {
  margin: 0 10px;
  color: white;
  text-decoration: none;
  font-weight: bold;
}

section {
  padding: 20px;
}
CSS

#Create the landing page
echo "Creating landing page..."
sudo tee "$SITE_DIR/index.html" >/dev/null <<'HTML'
<!DOCTYPE html>
<html>
<head>
  <title>DevOps Demo Site</title>
  <link rel="stylesheet" href="styles.css">
  <link rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>

<header>
  <h1><i class="fa-solid fa-server"></i> Welcome to My DevOps Lab</h1>
  <nav>
    <a href="index.html">Home</a>
    <a href="about.html">About</a>
    <a href="projects.html">Projects</a>
  </nav>
</header>

<section>
  <p>This site was deployed using a custom Bash script on Apache.</p>
</section>

</body>
</html>
HTML

#Create the additional pages
echo "Creating additional pages..."

sudo tee "$SITE_DIR/about.html" >/dev/null <<'HTML'
<!DOCTYPE html>
<html>
<head>
  <title>About</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>

<header>
  <h1>About This Site</h1>
  <nav>
    <a href="index.html">Home</a>
    <a href="about.html">About</a>
    <a href="projects.html">Projects</a>
  </nav>
</header>

<section>
  <p>This project demonstrates automated Apache deployment using Bash.</p>
</section>

</body>
</html>
HTML


sudo tee "$SITE_DIR/projects.html" >/dev/null <<'HTML'
<!DOCTYPE html>
<html>
<head>
  <title>Projects</title>
  <link rel="stylesheet" href="styles.css">
</head>
<body>

<header>
  <h1>Projects</h1>
  <nav>
    <a href="index.html">Home</a>
    <a href="about.html">About</a>
    <a href="projects.html">Projects</a>
  </nav>
</header>

<section>
  <p>Future DevOps and cloud labs will be listed here.</p>
</section>

</body>
</html>
HTML

#Set Permissons
echo "Setting file permissions..."
sudo chown -R www-data:www-data "$SITE_DIR"
sudo find "$SITE_DIR" -type f -exec chmod 644 {} \;
sudo find "$SITE_DIR" -type d -exec chmod 755 {} \;

#Validate Apache
echo "Validating Apache configuration..."
sudo apachectl configtest
sudo systemctl reload apache2

