# Infrastructure Automation: Deploying Apache Web Servers with Bash

This repository contains a Bash script that automates the deployment of an Apache web server on an Ubuntu Linux host. The script is designed following core DevOps automation principles to install and configure the server, deploy a multi-page website, and ensure repeatable, idempotent execution. :contentReference[oaicite:0]{index=0}

---

## 📌 Overview

Automation is essential for modern DevOps workflows. Manual server provisioning is slow and prone to human error, especially at scale. This project:

- **Installs Apache2**
- **Starts and enables the Apache service**
- **Creates a custom landing page + additional HTML content**
- **Applies best practices for scripting (strict error handling, service management)** :contentReference[oaicite:1]{index=1}

---

## 📋 What's Included

### 🗂 Repository Contents

| File | Description |
|------|-------------|
| `deploy_apache.sh` | Bash script that installs and configures Apache, deploys HTML content, and manages services |
| `README.md` | This documentation |
| `example_output/` (optional) | Sample output visuals for how the site looks after deployment |

---

## 🚀 Prerequisites

To run this script successfully, ensure the following:

- You have access to a **Linux host (Ubuntu)** with a public IP. :contentReference[oaicite:2]{index=2}
- You have **sudo** privileges.
- The host can reach package repositories (internet access).

---

## 🧠 How It Works (High Level)

The Bash script performs:

1. **Safety first:** It enables strict error handling for robust execution.
2. **Package update + install:** Updates the system and installs Apache.
3. **Service management:** Enables and starts Apache so the server will run after reboot.
4. **Web content creation:** Generates a styled HTML landing page and additional navigation pages (e.g., About, Projects). :contentReference[oaicite:3]{index=3}
5. **Permissions:** Applies secure permissions to web files.
6. **Validation:** Confirms Apache configuration and reloads as required. :contentReference[oaicite:4]{index=4}

---

## ⚡ Running the Script

> ⚠️ **Important:** Run this on a fresh Ubuntu server or VM to avoid overwriting existing web content.

```bash
# Make the script executable
chmod +x deploy_apache.sh

# Execute as sudo
sudo ./deploy_apache.sh

