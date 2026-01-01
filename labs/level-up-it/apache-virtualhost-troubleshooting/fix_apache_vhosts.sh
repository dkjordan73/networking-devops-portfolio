
#!/usr/bin/env bash
set -euo pipefail

# Automation script to correct LUIT News Portal Deployment
# This script will correct errors with the Finance and World web pages

####################################### 
#Global variables                     #
#######################################

SITE_DIR="/var/www/levelup/finance"
SOURCE_FILE="/var/www/levelup/finance/inxe.mtlm" ## could be "/var/www/levelup/finance/inxe.mtlm
BACKUP_FILE="/var/www/levelup/finance/inxe-$(date +%Y%m%d-%H%M%S).html"
DESTINATION_FILE="/var/www/levelup/finance/index.html" ## could be "/var/www/levelup/finance/index.html
WORLD_DIR="/var/www/levelup/world"
WORLD_SOURCE_FILE="/var/www/levelup/world/index.html"
BACKUP_WORLD_FILE="/var/www/levelup/world/index-$(date +%Y%m%d-%H%M%S).html"
FILES=("index.html" "styles.css") 
SCRIPT_DIR="/home/ubuntu/.scripts"
TARGET_HTML="/home/ubuntu/.scripts/worldindex.html"
TARGET_CSS="/home/ubuntu/.scripts/styles.css"

#######################################################################
# Copy inxe.mtlm. in the finance directory to a backup file           #
# Copy index.html located in the world directory to a backup file     #
# Check for inxe.mtlm then copy to index.html in the finance directory#
#######################################################################

if [ -f "$SOURCE_FILE" ]; then
  # Copy source to destination (overwriting destination)
  cp "$SOURCE_FILE" "$BACKUP_FILE"
  echo "Successfully copied $SOURCE_FILE to $BACKUP_FILE in $SITE_DIR"
else
  echo "Error: Source file $SOURCE_FILE not found."
  exit 1
fi
 
#Take a backup of index.html in World Directory
if [ -f "$WORLD_SOURCE_FILE" ]; then
  # Copy source to destination (overwriting destination)
  cp "$WORLD_SOURCE_FILE" "$BACKUP_WORLD_FILE"
  echo "Successfully took backup of $WORLD_SOURCE_FILE"
else
  echo "Error: Source file $WORLD_SOURCE_FILE not found."
  exit 1
fi
 
 
#Check for inxe.mtlm in finance directory. If file exist, copy inxe.mtlm into correctly named index.html
if [ -f "$SOURCE_FILE" ]; then
  # Copy source to destination (overwriting destination)
  cp "$SOURCE_FILE" "$DESTINATION_FILE"
  echo "Successfully copied $SOURCE_FILE to $DESTINATION_FILE in $SITE_DIR"
else
  echo "Error: Source file $SOURCE_FILE not found."
  exit 1
fi


#################################
# move index.html and styles.css#
# into the world directory      #
#################################


# Check if target directory exists, create it if not

if [ ! -d "$WORLD_DIR" ]; then

    echo "Creating target directory $WORLD_DIR..."

    sudo mkdir -p "$WORLD_DIR"

fi

# Loop through files and move them


# 3. Move and rename the HTML file
if [ -f "$TARGET_HTML" ]; then
    mv "$TARGET_HTML" "$WORLD_SOURCE_FILE"
    echo "Moved and renamed $TARGET_HTML to $WORLD_SOURCE_FILE"
else
    echo "Warning: $TARGET_HTML not found."
fi

# 4. Move the CSS file
if [ -f "$TARGET_CSS" ]; then
    mv "$TARGET_CSS" "$WORLD_DIR/"
    echo "Moved $TARGET_CSS to $WORLD_DIR/"
else
    echo "Warning: $TARGET_CSS not found."
fi

echo "Done!"

# Ensure the directory is accessible by the web server

sudo chown -R www-data:www-data "$WORLD_DIR"
 
echo "Move complete. Assets are now in $WORLD_DIR."


