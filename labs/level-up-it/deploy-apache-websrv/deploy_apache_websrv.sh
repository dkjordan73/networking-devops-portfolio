#!/usr/bin/env bash
set -euo pipefail

# DevOps Technical Portfolio - Apache Deployment Script
# Creates: Professional portfolio site with Home, About, and Projects pages
# Theme: Blue/Cyan color scheme with modern design
# Target: Ubuntu Server

WEB_ROOT="/var/www/html"
BACKUP_LOCATION="/var/www/html-backup-$(date +%Y%m%d-%H%M%S)"

##################################################
# 1. Install dependencies
# -y enables non-interactive automation
##################################################
echo "==> Installing Apache2 web server..."
sudo apt-get update -y
sudo apt-get install -y apache2

##################################################
# 2. Service Management:Enable and start Apache
# enable → persistent across reboots
# restart → apply changes immediately
##################################################
echo "==> Configuring Apache2 service..."
sudo systemctl enable apache2
sudo systemctl restart apache2

##################################################
# 3. Backup existing site
# Idempotency & Backups
##################################################
echo "==> Creating backup of existing content..."
if [ -d "$WEB_ROOT" ] && [ "$(ls -A "$WEB_ROOT" 2>/dev/null || true)" ]; then
  sudo mkdir -p "$BACKUP_LOCATION"
  sudo cp -a "$WEB_ROOT"/. "$BACKUP_LOCATION"/
  echo "    Previous content backed up to: $BACKUP_LOCATION"
fi

##################################################
# 4. Create CSS file
##################################################
echo "==> Generating stylesheet..."
sudo tee $WEB_ROOT/portfolio-styles.css >/dev/null <<'EOF'
:root {
  --primary-blue: #0891b2;
  --secondary-cyan: #06b6d4;
  --dark-bg: #0a1929;
  --card-bg: #132f4c;
  --text-primary: #e3f2fd;
  --text-secondary: #b0bec5;
  --accent-light: #4dd0e1;
  --border-color: #1e3a5f;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background: linear-gradient(135deg, var(--dark-bg) 0%, #001e3c 100%);
  color: var(--text-primary);
  line-height: 1.6;
  min-height: 100vh;
}

header {
  background: linear-gradient(to right, rgba(8, 145, 178, 0.2), rgba(6, 182, 212, 0.1));
  border-bottom: 3px solid var(--primary-blue);
  padding: 20px 0;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.3);
}

.container {
  max-width: 1100px;
  margin: 0 auto;
  padding: 0 30px;
}

.header-content {
  display: flex;
  align-items: center;
  gap: 18px;
  margin-bottom: 20px;
}

.icon-badge {
  width: 55px;
  height: 55px;
  background: linear-gradient(135deg, var(--primary-blue), var(--secondary-cyan));
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 26px;
  box-shadow: 0 8px 16px rgba(8, 145, 178, 0.4);
}

h1 {
  font-size: 2rem;
  color: var(--accent-light);
  font-weight: 600;
  margin-bottom: 5px;
}

.tagline {
  color: var(--text-secondary);
  font-size: 1.05rem;
}

nav {
  display: flex;
  gap: 15px;
  flex-wrap: wrap;
}

.nav-link {
  text-decoration: none;
  color: var(--text-primary);
  background: var(--card-bg);
  padding: 12px 20px;
  border-radius: 8px;
  border: 2px solid var(--border-color);
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  font-weight: 500;
}

.nav-link:hover {
  background: var(--primary-blue);
  border-color: var(--secondary-cyan);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(8, 145, 178, 0.3);
}

main {
  padding: 40px 0;
}

.content-card {
  background: var(--card-bg);
  border: 2px solid var(--border-color);
  border-radius: 12px;
  padding: 25px;
  margin-bottom: 25px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.section-header {
  color: var(--secondary-cyan);
  font-size: 1.5rem;
  margin-bottom: 15px;
  padding-bottom: 10px;
  border-bottom: 2px solid var(--primary-blue);
  display: flex;
  align-items: center;
  gap: 10px;
}

.content-card p {
  color: var(--text-secondary);
  margin-bottom: 12px;
  font-size: 1.05rem;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 20px;
  margin-top: 20px;
}

.info-box {
  background: rgba(8, 145, 178, 0.1);
  border-left: 4px solid var(--secondary-cyan);
  padding: 18px;
  border-radius: 8px;
}

.info-box h3 {
  color: var(--accent-light);
  font-size: 1.15rem;
  margin-bottom: 8px;
}

.info-box p {
  font-size: 0.95rem;
}

footer {
  background: rgba(8, 145, 178, 0.1);
  border-top: 2px solid var(--primary-blue);
  padding: 20px 0;
  text-align: center;
  color: var(--text-secondary);
  margin-top: 40px;
}

code {
  background: rgba(0, 0, 0, 0.4);
  border: 1px solid var(--primary-blue);
  padding: 3px 8px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  color: var(--accent-light);
}

.highlight-box {
  background: linear-gradient(135deg, rgba(8, 145, 178, 0.2), rgba(6, 182, 212, 0.1));
  border: 2px solid var(--primary-blue);
  border-radius: 10px;
  padding: 20px;
  margin-top: 20px;
}
EOF

##################################################
# 5. Create landing page
##################################################
echo "==> Building home page..."
sudo tee $WEB_ROOT/index.html >/dev/null <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DevOps Portfolio - Home</title>
  <link rel="stylesheet" href="/portfolio-styles.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
</head>
<body>
  <header>
    <div class="container">
      <div class="header-content">
        <div class="icon-badge"><i class="fa-solid fa-gear"></i></div>
        <div>
          <h1>Welcome to my DevOps Portfolio</h1>
          <p class="tagline">Building, Automating, and Deploying Cloud Solutions</p>
        </div>
      </div>
      
      <nav>
        <a href="/" class="nav-link"><i class="fa-solid fa-house"></i> Home</a>
        <a href="/about.html" class="nav-link"><i class="fa-solid fa-user"></i> About</a>
        <a href="/projects.html" class="nav-link"><i class="fa-solid fa-briefcase"></i> Projects</a>
      </nav>
    </div>
  </header>

  <main class="container">
    <div class="content-card">
      <h2 class="section-header"><i class="fa-solid fa-bullseye"></i> Overview</h2>
      <p>Welcome to my professional DevOps portfolio! This site showcases my journey in cloud engineering, automation, and infrastructure management.</p>
      <p>I specialize in building scalable, reliable systems using modern DevOps practices and cloud-native technologies.</p>
    </div>

    <div class="info-grid">
      <div class="info-box">
        <h3><i class="fa-solid fa-cloud"></i> Cloud Infrastructure</h3>
        <p>Expertise in AWS, Azure, and Google Cloud Platform for deploying robust applications.</p>
      </div>
      
      <div class="info-box">
        <h3><i class="fa-solid fa-wrench"></i> Automation</h3>
        <p>Creating efficient CI/CD pipelines and infrastructure as code solutions.</p>
      </div>
      
      <div class="info-box">
        <h3><i class="fa-solid fa-chart-simple"></i> Monitoring</h3>
        <p>Implementing comprehensive monitoring and logging systems for production environments.</p>
      </div>
    </div>

    <div class="content-card highlight-box">
      <h2 class="section-header">🚀 Quick Start</h2>
      <p>Explore my portfolio to learn more about my technical skills and completed projects.</p>
      <p><strong>Navigation:</strong> Use the menu above to visit the About and Projects pages.</p>
    </div>
  </main>

  <footer>
    <div class="container">
      <p>DevOps Portfolio © 2025 | Deployed with Apache on Ubuntu Server</p>
    </div>
  </footer>
</body>
</html>
EOF

##################################################
# 6. Create additional pages
##################################################
echo "==> Building about page..."
sudo tee $WEB_ROOT/about.html >/dev/null <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>About - DevOps Portfolio</title>
  <link rel="stylesheet" href="/portfolio-styles.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
</head>
<body>
  <header>
    <div class="container">
      <div class="header-content">
        <div class="icon-badge"><i class="fa-solid fa-user"></i></div>
        <div>
          <h1>About Me</h1>
          <p class="tagline">DevOps Engineer & Cloud Enthusiast</p>
        </div>
      </div>
      
      <nav>
        <a href="/" class="nav-link"><i class="fa-solid fa-house"></i> Home</a>
        <a href="/about.html" class="nav-link"><i class="fa-solid fa-user"></i> About</a>
        <a href="/projects.html" class="nav-link"><i class="fa-solid fa-briefcase"></i> Projects</a>
      </nav>
    </div>
  </header>

  <main class="container">
    <div class="content-card">
      <h2 class="section-header">📋 Professional Background</h2>
      <p>I am a passionate DevOps engineer dedicated to streamlining software delivery and optimizing cloud infrastructure.</p>
      <p>My focus is on creating automated, efficient, and scalable solutions that empower development teams to ship code faster and more reliably.</p>
    </div>

    <div class="content-card">
      <h2 class="section-header">🛠️ Technical Skills</h2>
      <div class="info-grid">
        <div class="info-box">
          <h3>Programming & Scripting</h3>
          <p>Bash, Python, YAML, JSON</p>
        </div>
        
        <div class="info-box">
          <h3>Cloud Platforms</h3>
          <p>AWS, Azure, Google Cloud</p>
        </div>
        
        <div class="info-box">
          <h3>Containerization</h3>
          <p>Docker, Kubernetes, Container Orchestration</p>
        </div>
        
        <div class="info-box">
          <h3>CI/CD Tools</h3>
          <p>Jenkins, GitHub Actions, GitLab CI</p>
        </div>
        
        <div class="info-box">
          <h3>Infrastructure as Code</h3>
          <p>Terraform, Ansible, CloudFormation</p>
        </div>
        
        <div class="info-box">
          <h3>Version Control</h3>
          <p>Git, GitHub, GitLab</p>
        </div>
      </div>
    </div>

    <div class="content-card highlight-box">
      <h2 class="section-header">🎓 Education & Certifications</h2>
      <p>Currently pursuing advanced studies in Cloud Engineering and DevOps methodologies.</p>
      <p>Actively working toward industry certifications including AWS Solutions Architect and Kubernetes Administrator.</p>
    </div>
  </main>

  <footer>
    <div class="container">
      <p>DevOps Portfolio © 2025 | Deployed with Apache on Ubuntu Server</p>
    </div>
  </footer>
</body>
</html>
EOF

echo "==> Building projects page..."
sudo tee $WEB_ROOT/projects.html >/dev/null <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Projects - DevOps Portfolio</title>
  <link rel="stylesheet" href="/portfolio-styles.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" />
</head>
<body>
  <header>
    <div class="container">
      <div class="header-content">
        <div class="icon-badge"><i class="fa-solid fa-briefcase"></i></div>
        <div>
          <h1>My Projects</h1>
          <p class="tagline">Real-World DevOps Implementations</p>
        </div>
      </div>
      
      <nav>
        <a href="/" class="nav-link"><i class="fa-solid fa-house"></i> Home</a>
        <a href="/about.html" class="nav-link"><i class="fa-solid fa-user"></i> About</a>
        <a href="/projects.html" class="nav-link"><i class="fa-solid fa-briefcase"></i> Projects</a>
      </nav>
    </div>
  </header>

  <main class="container">
    <div class="content-card">
      <h2 class="section-header">🚀 Featured Projects</h2>
      <p>Below are some of my key DevOps and cloud engineering projects that demonstrate my technical capabilities.</p>
    </div>

    <div class="content-card">
      <h3 class="section-header">📦 Automated Apache Deployment</h3>
      <p><strong>Description:</strong> Automated deployment script for Apache web server with custom portfolio site.</p>
      <p><strong>Technologies:</strong> Bash scripting, Apache2, HTML/CSS, Linux system administration</p>
      <p><strong>Key Features:</strong></p>
      <ul style="color: var(--text-secondary); margin-left: 25px;">
        <li>Automated package installation and service configuration</li>
        <li>Backup mechanism for existing content</li>
        <li>Custom styled multi-page portfolio</li>
        <li>Proper file permissions and security settings</li>
      </ul>
    </div>

    <div class="content-card">
      <h3 class="section-header"><i class="fa-solid fa-cloud"></i> Cloud Infrastructure Project</h3>
      <p><strong>Description:</strong> Designed and deployed scalable cloud infrastructure for web applications.</p>
      <p><strong>Technologies:</strong> AWS EC2, VPC, Security Groups, Load Balancers</p>
      <p><strong>Outcomes:</strong> Reduced deployment time and improved application reliability.</p>
    </div>

    <div class="content-card">
      <h3 class="section-header">🔄 CI/CD Pipeline Implementation</h3>
      <p><strong>Description:</strong> Built automated continuous integration and deployment pipeline.</p>
      <p><strong>Technologies:</strong> GitHub Actions, Docker, Automated Testing</p>
      <p><strong>Impact:</strong> Streamlined code delivery process and minimized manual interventions.</p>
    </div>

    <div class="content-card highlight-box">
      <h2 class="section-header"><i class="fa-solid fa-chart-simple"></i> Server Management Commands</h2>
      <p><strong>Check Apache Status:</strong> <code>systemctl status apache2</code></p>
      <p><strong>View Access Logs:</strong> <code>tail -f /var/log/apache2/access.log</code></p>
      <p><strong>View Error Logs:</strong> <code>tail -f /var/log/apache2/error.log</code></p>
      <p><strong>Restart Service:</strong> <code>sudo systemctl restart apache2</code></p>
    </div>
  </main>

  <footer>
    <div class="container">
      <p>DevOps Portfolio © 2025 | Deployed with Apache on Ubuntu Server</p>
    </div>
  </footer>
</body>
</html>
EOF

##################################################
# 7. Set permissions
##################################################
echo "==> Configuring file permissions..."
sudo chown -R www-data:www-data "$WEB_ROOT"
sudo find "$WEB_ROOT" -type d -exec chmod 755 {} \;
sudo find "$WEB_ROOT" -type f -exec chmod 644 {} \;

##################################################
# 8. Validate Apache
##################################################
echo "==> Validating Apache configuration..."
sudo apache2ctl configtest

echo "==> Reloading Apache service..."
sudo systemctl reload apache2
