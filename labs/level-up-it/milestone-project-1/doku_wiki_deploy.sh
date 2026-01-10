#!/usr/bin/env bash
set -euo pipefail

##########################
# Update system packages #
##########################

sudo apt-get update -y
sudo apt-get upgrade -y

##########################
# Install Apache         #
##########################

sudo apt install apache2 -y

##########################
# Install PHP            #
##########################

sudo apt install php php-xml php-gd php-cli php-curl php-mbstring libapache2-mod-php -y

####################################################
# Make dokuwiki directory: to host the application #
####################################################

sudo mkdir /var/www/html/dokuwiki

####################################################
# Make staging directory to download package       #
####################################################

sudo mkdir /opt/doku_wiki

####################################################
# Download DokuWiki                                #
####################################################

cd /opt/doku_wiki
sudo wget https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz

####################################################
# Extract the latest stable real-ease              #
####################################################

sudo tar xvf dokuwiki-stable.tgz

####################################################
# Move contents to parent folder                   #
####################################################

sudo mv dokuwiki-*/* /var/www/html/dokuwiki/

####################################################
# Set proper ownership.                            #
####################################################

sudo chown -R www-data:www-data /var/www/html/dokuwiki

####################################################
# Set proper permissions                           #
####################################################

sudo find /var/www/html/dokuwiki -type d -exec chmod 755 {} \;
sudo find /var/www/html/dokuwiki -type f -exec chmod 644 {} \;


##########################################################################
# Configure Apache Create an Apache virtual host file for your DokuWiki: #
##########################################################################

sudo tee /etc/apache2/sites-available/dokuwiki.conf>/dev/null<<'EOF'
<VirtualHost *:80>
    DocumentRoot /var/www/html/dokuwiki
    <Directory /var/www/html/dokuwiki>
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/dokuwiki_error.log
    CustomLog ${APACHE_LOG_DIR}/dokuwiki_access.log combined
</VirtualHost>
EOF

###################################################
# Create the essential wiki pages                 #
###################################################

sudo tee /var/www/html/dokuwiki/data/pages/home.txt>/dev/null<<'EOF'
===================Welcome Page============================
Welcome to DevOPS wiki page.
This is a collection of notes and information that I accumulated over the years.
I hope you find this site useful
EOF


sudo tee /var/www/html/dokuwiki/data/pages/aws_notes.txt>/dev/null<<'EOF'
===================AWS Notes============================
See my notes below


IAM: Manages authentication (verifying who you are) and authorization (determining what you are allowed to do)

EC2: Provides resizable virtual machines for running applications, hosting websites, or performing compute-intensive tasks.

S3: Stores any amount of data (images, videos, backups, static website content, data lakes) and makes it accessible from anywhere on the web.
EOF


sudo tee /var/www/html/dokuwiki/data/pages/linux_commands.txt>/dev/null<<'EOF'

===================Linux Notes============================
ls command:  is used to list files and directories present in the current working

pwd command: is used to display the present working directory.

mkdir command: is used to create new directories.

cd command: used to change the current working directory
EOF


####################################################
# Enable the new site and Apache rewrite module:   #
####################################################

sudo a2ensite dokuwiki.conf
sudo a2enmod rewrite


####################################################
# Restart services (apache).                       #
####################################################

sudo systemctl reload apache2




