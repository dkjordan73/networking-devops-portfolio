# Automated DokuWiki Deployment on Ubuntu (EC2)

## Overview

This Bash script automates the deployment of a **self-hosted DokuWiki instance** on an Ubuntu Linux system using Apache and PHP.  
It is designed to be executed on a fresh server (such as an AWS EC2 instance) and requires **no manual configuration** once started.

The script demonstrates foundational **Linux system administration**, **web server configuration**, and **infrastructure automation** principles.

---

## What This Script Accomplishes

At a high level, the script performs the following actions:

- Prepares the operating system
- Installs required web and application dependencies
- Deploys and configures DokuWiki
- Configures Apache with a dedicated virtual host
- Sets correct permissions for secure operation
- Seeds the wiki with initial content

---

## Key Automation Stages

### 1. System Preparation
- Updates package repositories
- Upgrades installed system packages
- Ensures a clean and up-to-date environment

### 2. Web Stack Installation
- Installs **Apache** as the web server
- Installs **PHP** and required extensions for DokuWiki compatibility
- Enables Apache–PHP integration

### 3. Application Staging and Deployment
- Creates a staging directory for downloading artifacts
- Downloads the latest **stable DokuWiki release**
- Extracts and deploys application files to the Apache web root

### 4. Permissions and Ownership
- Assigns ownership to the Apache service account (`www-data`)
- Applies secure directory and file permissions
- Ensures Apache can read and write required content safely

### 5. Apache Virtual Host Configuration
- Creates a dedicated Apache virtual host for DokuWiki
- Enables `.htaccess` support for clean URLs
- Configures separate access and error logs
- Enables required Apache modules

### 6. Initial Wiki Content
- Creates essential wiki pages automatically:
  - Home page
  - AWS notes page
  - Linux commands reference
- Demonstrates non-interactive content creation via automation

### 7. Service Enablement
- Enables the DokuWiki site configuration
- Reloads Apache to apply changes without downtime

---

## Why This Script Matters

This project highlights real-world skills used in Linux and DevOps roles:

- **Infrastructure as Code (IaC)** mindset using Bash
- **Idempotent-friendly automation patterns**
- **Secure Linux permissions management**
- **Web server configuration and troubleshooting**
- **Hands-off application deployment**

The script can be executed via:
- Manual SSH session
- Cloud-init / EC2 User Data
- CI/CD pipeline step

---

## Intended Use Cases

- Personal documentation system
- DevOps learning lab
- Linux automation portfolio project
- EC2 user-data automation example
- Lightweight internal knowledge base

---

## Requirements

- Ubuntu Linux
- Internet access
- Root or sudo privileges

---

## Outcome

After execution, the system hosts a fully functional **DokuWiki site** served by Apache, ready for configuration through the web interface and immediate content usage.


