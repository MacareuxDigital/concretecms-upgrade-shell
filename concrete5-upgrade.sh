#!/bin/bash
#
# Upgrade Script for Concrete CMS
# Supports Version 8.x only.
# ----------
# Version 3.0.5
# By Derek Cameron & Katz Ueno

# INSTRUCTION:
# ----------
# https://github.com/concrete5-community/concrete5-upgrade-shell

# USE IT AT YOUR OWN RISK!

# VARIABLES
# ----------


# Server Config
## Concrete CMS Location
WHERE_IS_CONCRETE5="/var/www/vhosts/concrete5"
# enter sudo command OR comment it out to execute as SSH user without sudo
DO_SUDO="sudo -u apache " # Make sure to have a space at the end.
## Permissions
USER_PERMISSIONS="apache:apache"

# Backup Variables
## name of backup files
PROJECT_NAME="Concrete"
WHERE_TO_SAVE="/var/www/vhosts/backups"

# Set DB's default charaset. Make sure to set the proper MySQL character encoding to avoid character corruption
MYSQL_CHARASET="utf8mb4"

# Production DB Details to backup
PROD_DB_HOST="localhost"
PROD_DB_USERNAME="c5"
PROD_DB_PASSWORD="12345"
PROD_DB_DATABASE="c5"
PROD_DB_PORT="3306"
# Set "true" if you're using MySQL 5.7.31 or later. (true or false)
PROD_DB_IF_NO_TABLESPACE="false"

# Database Copy Feature
## Use Import file instead of production database (Yes / No)
USE_IMPORT_FILE="No"
## Specify the SQL file absolute path if you want to import certain file
IMPORT_FILE=""

## Backup DB details to backup/import to
BACKUP_DB_HOST="localhost"
BACKUP_DB_USERNAME=""
BACKUP_DB_PASSWORD=""
BACKUP_DB_DATABASE=""
BACKUP_DB_PORT="3306"
# Set "true" if you're using MySQL 5.7.31 or later. (true or false)
BACKUP_DB_IF_NO_TABLESPACE="false"
# Set "yes" if you want to empty all database data before importing. It is recommended to do so especially if you are restoring from upgrade failure because schema may have changed.
BACKUP_DB_EMPTY_DB="yes"
# Set "yes" if you want to anonymize user's email to "dummy@example.com"
BACKUP_DB_ANONYMIZE_USERS="no"
# Even you set yes to anonymize emails, you can skip anonymizing email which contains the following letters.
BACKUP_DB_ANONYMIZE_USERS_EXCEPT="concrete5.co.jp"
# If you use multiple file storage, You can set default file storage to "0" when copying, then you can avoid accidental file upload to production area.
BACKUP_DB_SET_DEFAULT_FILESTORAGELOCATION="no"
## Option DEBUG
#echo "----------"
#echo "DEBUG: option 1 $1"
#echo "DEBUG: option 2 $2"
#echo "----------"

C5_Version=$1
CONCRETE5_PACKAGE_DOWNLOAD=$2

if [ ! "$C5_Version" ]; then
    C5_Version="8.5.12"
fi

if [ ! "$CONCRETE5_PACKAGE_DOWNLOAD" ]; then
    CONCRETE5_PACKAGE_DOWNLOAD="https://www.concretecms.org/download_file/2bba0898-1539-48ff-b273-0cbddc7588da"
fi

## Option DEBUG
#echo "----------"
#echo "DEBUG: C5_Version $C5_Version"
#echo "DEBUG: CONCRETE5_PACKAGE_DOWNLOAD: $CONCRETE5_PACKAGE_DOWNLOAD"
#echo "----------"

# CONCRETE5_PACKAGE_DOWNLOAD="https://marketplace.concretecms.com/latest.zip"

# Concrete 5 Download Links
#    '9.1.3'=>'https://www.concretecms.com/download_file/f7867cc1-3cbd-45b6-8df7-66ea2151eda0'
#    '9.1.2'=>'https://www.concretecms.com/download_file/e005c931-9ee3-4fb7-895f-760bb01f2c4d'
#    '9.1.1'=>'https://www.concretecms.com/download_file/c8c925b8-9a63-4b23-aff3-cb0e76a0e168'
#    '9.1.0'=>'https://www.concretecms.com/download_file/fc6337ea-3e83-4cb6-b6a0-bd292fe2e2a8/'
#    '9.0.2'=>'https://www.concretecms.org/download_file/3254ddbf-35f0-4c92-8ed1-1fb6b9c0f0d4'
#    '9.0.1'=>'https://www.concretecms.org/download_file/dc6d0589-6639-40ac-8c21-8f9f025b7e34'
#    '9.0.0'=>'https://www.concretecms.com/download_file/29fd2f63-3f52-47d8-80a7-08be47d4ed07'
#    '8.5.12'=>'https://www.concretecms.org/download_file/2bba0898-1539-48ff-b273-0cbddc7588da'
#    '8.5.11'=>'https://www.concretecms.org/download_file/3808aac2-1640-4d89-9157-f0a95762f511'
#    '8.5.9'=>'https://www.concretecms.org/download_file/7730d563-57d5-4433-b0ae-147db99fbf0d'
#    '8.5.8'=>'https://www.concretecms.com/download_file/15c31837-ffdf-45fd-9f7c-d353ec60a2d9'
#    '8.5.7'=>'https://www.concretecms.org/download_file/ae9cca19-d76c-458e-a63a-ce9b7b963e1d'
#    '8.5.6'=>'https://www.concretecms.com/download_file/61dab82f-fb01-47bc-8cf1-deffff890224/9'
#    '8.5.5'=>'https://marketplace.concretecms.com/download_file/-/view/115589/'
#    '8.5.4'=>'https://marketplace.concretecms.com/download_file/-/view/113632/'
#    '8.5.3'=>'https://marketplace.concretecms.com/download_file/-/view/113591/'
#    '8.5.2'=>'https://marketplace.concretecms.com/download_file/-/view/111592/'
#    '8.5.1'=>'https://marketplace.concretecms.com/download_file/-/view/109615/'
#    '8.5.0'=>'https://marketplace.concretecms.com/download_file/-/view/109116/'
#    '8.4.5'=>'https://marketplace.concretecms.com/download_file/-/view/108839/'
#    '8.4.4'=>'https://marketplace.concretecms.com/download_file/-/view/108181/'
#    '8.4.3'=>'https://marketplace.concretecms.com/download_file/-/view/106698/'
#    '8.4.2'=>'https://marketplace.concretecms.com/download_file/-/view/105477/'
#    '8.4.1'=>'https://marketplace.concretecms.com/download_file/-/view/105022/'
#    '8.4.0'=>'https://marketplace.concretecms.com/download_file/-/view/104344/'
#    '8.4.0'=>'https://marketplace.concretecms.com/download_file/-/view/104344/',
#    '8.3.2'=>'https://marketplace.concretecms.com/download_file/-/view/100595/',
#    '8.3.1'=>'https://marketplace.concretecms.com/download_file/-/view/99963/',
#    '8.3.0'=>'https://marketplace.concretecms.com/download_file/-/view/99806/',
#    '8.2.1'=>'https://marketplace.concretecms.com/download_file/-/view/96959/',
#    '8.2.0'=>'https://marketplace.concretecms.com/download_file/-/view/96765/',
#    '8.1.0'=>'https://marketplace.concretecms.com/download_file/-/view/93797/',
#    '8.0.3'=>'https://marketplace.concretecms.com/download_file/-/view/93074/',
#    '8.0.2'=>'https://marketplace.concretecms.com/download_file/-/view/92910/',
#    '8.0.1'=>'https://marketplace.concretecms.com/download_file/-/view/92834/',
#    '8.0.0'=>'https://marketplace.concretecms.com/download_file/-/view/92663/',

# ==============================
#
# DO NOT TOUCH BELOW THIS LINE (unless you're really a cool person.)
#
# ==============================

CONCRETE5_WORKING_DIRECTORY_NAME="${C5_Version}upgrade_working"

# ---- tablespace option after MySQL 5.7.31
if [ "$PROD_DB_IF_NO_TABLESPACE" = "TRUE" ] || [ "$PROD_DB_IF_NO_TABLESPACE" = "True" ] || [ "$PROD_DB_IF_NO_TABLESPACE" = "true" ] || [ "$PROD_DB_IF_NO_TABLESPACE" = "t" ]; then
    PROD_MYSQLDUMP_OPTION_TABLESPACE="--no-tablespaces"
elif [ "$PROD_DB_IF_NO_TABLESPACE" = "FALSE" ] || [ "$PROD_DB_IF_NO_TABLESPACE" = "False" ] || [ "$PROD_DB_IF_NO_TABLESPACE" = "false" ] || [ "$PROD_DB_IF_NO_TABLESPACE" = "f" ]; then
    PROD_MYSQLDUMP_OPTION_TABLESPACE=""
else
    echo "c5 Backup ERROR: PROD_DB_IF_NO_TABLESPACE variable is not properly set in the shell script"
    exit
fi
# ---- tablespace option after MySQL 5.7.31
if [ "$BACKUP_DB_IF_NO_TABLESPACE" = "TRUE" ] || [ "$BACKUP_DB_IF_NO_TABLESPACE" = "True" ] || [ "$BACKUP_DB_IF_NO_TABLESPACE" = "true" ] || [ "$BACKUP_DB_IF_NO_TABLESPACE" = "t" ]; then
    BACKUP_MYSQLDUMP_OPTION_TABLESPACE="--no-tablespaces"
elif [ "$BACKUP_DB_IF_NO_TABLESPACE" = "FALSE" ] || [ "$BACKUP_DB_IF_NO_TABLESPACE" = "False" ] || [ "$BACKUP_DB_IF_NO_TABLESPACE" = "false" ] || [ "$BACKUP_DB_IF_NO_TABLESPACE" = "f" ]; then
    BACKUP_MYSQLDUMP_OPTION_TABLESPACE=""
else
    echo "c5 Backup ERROR: BACKUP_DB_IF_NO_TABLESPACE variable is not properly set in the shell script"
    exit
fi

DELETE_WORKFILE="No"
DO_EVERYTHING="No"
NOW_TIME=$(date "+%Y%m%d%H%M%S")
TAR_FILE="${PROJECT_NAME}_${NOW_TIME}.tar.gz"

# https://unix.stackexchange.com/questions/285924/how-to-compare-a-programs-version-in-a-shell-script
requiredver="8.0.0"
if [ "$(printf '%s\n' "$requiredver" "${C5_Version}" | sort -V | head -n1)" = "$requiredver" ]; then 
  echo "Greater than or equal to ${requiredver}. We are proceeding"
else
  echo "Less than ${requiredver}"
fi

requiredver="8.5.8"
if [ "$(printf '%s\n' "$requiredver" "${C5_Version}" | sort -V | head -n1)" = "$requiredver" ]; then 
  CONCRETE5_PACKAGE_DIRECTORY_NAME="concrete-cms-${C5_Version}"
else
  CONCRETE5_PACKAGE_DIRECTORY_NAME="concrete5-${C5_Version}"
fi

# ---- Checking The Options -----

show_main_menu()
{
  
  echo "-- Concrete5 Upgrade Script --"
  echo "1. Backup data from Concrete CMS"
  echo "2. Import DB data from production DB to backup DB"
  echo "3. Upgrade Concrete CMS to version ${C5_Version}"
  echo "4. Do all of the above"
  echo "5. Set Options"
  echo "6. Enable maintainance mode"
  echo "7. Dsiable maintainance mode"
  echo " -- -- -- -- -- -- -- -- -- -- --"
  echo "q. Quit"
  echo -en "Enter your selection: "
}

do_main_menu()
{
  i=-1

  while [ "$i" != "q" ]; do
    show_main_menu
    read i
    i=`echo $i | tr '[A-Z]' '[a-z]'`
    case "$i" in 
	"1")
	show_backup
    echo "---------------------------"
    echo "---      Complete!      ---"
    echo "---------------------------"
    exit 0
	;;
	"2")
	show_import
    echo "---------------------------"
    echo "---      Complete!      ---"
    echo "---------------------------"
    exit 0
	;;
	"3")
	do_upgrade
    echo "---------------------------"
    echo "---      Complete!      ---"
    echo "---------------------------"
    exit 0
	;;
	"4")
	do_all
    echo "---------------------------"
    echo "---      Complete!      ---"
    echo "---------------------------"
    exit 0
	;;
    "o"|"options"|"5")
	set_options
	;;
	"6")
	enable_maintenance_mode
    echo "---------------------------"
    echo "---      Complete!      ---"
    echo "---------------------------"
    exit 0
	;;
	"7")
	disable_maintenance_mode
    echo "---------------------------"
    echo "---      Complete!      ---"
    echo "---------------------------"
    exit 0
	;;
	"q")
	echo "Sorry this is not the script you are looking for!"
	exit 0
	;;
	*)
	echo "Unrecognised input."
	;;
    esac
  done
}

reset_backup_settings() {
    WHERE_TO_SAVE=""
}

reset_concrete5_settings() {
    WHERE_IS_CONCRETE5=""
}

reset_dev_settings() {
    BACKUP_DB_HOST=""
    BACKUP_DB_USERNAME=""
    BACKUP_DB_PASSWORD=""
    BACKUP_DB_DATABASE=""
    BACKUP_DB_PORT=""
    MYSQL_CHARASET=""
}

reset_prod_settings() {
    PROD_DB_HOST=""
    PROD_DB_USERNAME=""
    PROD_DB_PASSWORD=""
    PROD_DB_DATABASE=""
    PROD_DB_PORT=""
    MYSQL_CHARASET=""
}

show_backup() {
selection="nothing"
    echo
    echo "Please Select which type of Backup you would like to do"
    echo "1. Backup database only"
    echo "2. Backup files only"
    echo "3. Backup files and database"
    echo "4. Backup config and database"
    echo "q. Return to main menu"
    send_back() {
        do_main_menu
    }
    while [ "$selection" = "nothing" ]; do
        echo
        echo -en "Enter your selection: "
        read selection
        selection=`echo $selection | tr '[A-Z]' '[a-z]'`
        case "$selection" in 
            "1") backup_type="1"; do_backup;;
            "2") backup_type="2"; do_backup;;
            "3") backup_type="3"; do_backup;;
            "4") backup_type="4"; do_backup;;
            "q") echo "Returning you to main menu"; send_back;;
            *) selection="nothing"; echo "Unrecognised input."; echo "";;
        esac
    done
}

set_options() {
    echo
    echo "Options"
    send_back() {
        do_main_menu
    }
    selection="nothing"
    echo "1. Enter Development Settings Manually"
    echo "2. Enter Production Settings Manually"
    echo "3. Enter Backup Settings Manually"
    echo "4. Enter Concrete5 Settings Manually"
    echo "5. Enter all details manually"
    echo "q. Go Back"
    while [ "$selection" = "nothing" ]; do
        echo
        echo -en "Enter your selection: "
        read selection
        selection=`echo $selection | tr '[A-Z]' '[a-z]'`
        case "$selection" in 
            "1") 
             send_back() {
                set_options
            }
            send_forward() {
                reset_dev_settings
                set_develop_db_details
            }
            show_input() {
                set_options
            }
            echo "Do you wish to overwrite the current development settings?"
            manual_input
            ;;
            "2")
             send_back() {
                set_options
            }
            send_forward() {
                reset_prod_settings
                set_prod_db_details
            }
            show_input() {
                set_options
                
            }
            echo "Do you wish to overwrite the current production settings?"
            manual_input
            ;;
            "3") 
             send_back() {
                set_options
            }
            send_forward() {
                reset_backup_settings
                set_backup_directory
            }
            show_input() {
                set_options
            }
            echo "Do you wish to overwrite the current backup settings?"
            manual_input
            ;;
            "4")  send_back() {
                set_options
            }
            send_forward() {
                reset_concrete5_settings
                set_concrete_directory
            }
            show_input() {
                set_options
            }
            echo "Do you wish to overwrite the current concrete5 settings?"
            manual_input;;
            "5") 
              send_back() {
                set_options
            }
            send_forward() {
                reset_dev_settings
                reset_prod_settings
                reset_backup_settings
                reset_concrete5_settings
                set_develop_db_details
                set_prod_db_details
                set_backup_directory
                set_concrete_directory
                echo ""
                echo "All settings updated"
                do_main_menu
            }
            show_input() {
                set_options
            }
            echo "Do you wish to overwrite all current settings?"
            manual_input
            ;;
            "q") echo "Returning you to main menu"; send_back;;
            *) selection="nothing"; echo "Unrecognised input."; echo "";;
        esac
    done
}

send_back() {
        do_main_menu
    }

do_all(){
    backup_type="3"
    do_backup
    do_import
    do_upgrade
}


show_import() {
set_backup_directory
    send_back() {
        do_main_menu
    }
    show_input() {
        echo
        echo -en "Please enter the production server's database host address : "
        read PROD_DB_HOST
        echo -en "Please enter the production server's database name : "
        read PROD_DB_DATABASE
        echo -en "Please enter the production server's database user : "
        read PROD_DB_USERNAME
        echo -en "Please enter the database user's password : "
        read PROD_DB_PASSWORD
        echo -en "Please enter the database port : "
        read PROD_DB_PORT
        echo -en "Please enter the database character collation : "
        read MYSQL_CHARASET
        echo 
        echo 'You entered the following:' 
    }
    echo "Would you like to use the settings stored in the shell script?"
    send_forward() {
        do_import
    }

    manual_input
    
}

do_import() {
    echo " ========================================"
    echo "      Importing Production Database      "
    echo " ========================================"
    echo 
    set_prod_db_details
    if [ "$DO_EVERYTHING" != "Yes" ]; then
    send_back() {
        show_import
    }
    show_input(){
        do_db_import
    }
    send_forward() {
        do_db_backup
        do_db_import
    }
    echo "Would you like to backup the local database"
    manual_input
    fi
}

do_prod_db_backup() {
    set_prod_db_details
    SQL_FILE="${PROJECT_NAME}_prod_db_${NOW_TIME}.sql"
    echo "c5 Backup: Backing up production database to ${WHERE_TO_SAVE}/${SQL_FILE}"
    if [ -n "$PROD_DB_PASSWORD" ]; then
        set +e
        mysqldump -h ${PROD_DB_HOST} --port=${PROD_DB_PORT} -u ${PROD_DB_USERNAME} --password=${PROD_DB_PASSWORD} --single-transaction ${PROD_MYSQLDUMP_OPTION_TABLESPACE} --default-character-set=${MYSQL_CHARASET} "${PROD_DB_DATABASE}" > "${WHERE_TO_SAVE}"/"${SQL_FILE}"
        ret=$?
        if [ "$ret" = 0 ]; then
            echo ""
            echo "c5 Backup: MySQL Database was dumped successfully."
        else
            echo "c5 Backup: ERROR: MySQL password failed. You must type MySQL password manually. OR hit ENTER if you want to stop this script now."
            set -e
            mysqldump -h ${PROD_DB_HOST} --port=${PROD_MYSQL_PORT} -u ${PROD_DB_USERNAME} -p --single-transaction --default-character-set=${MYSQL_CHARASET} ${PROD_MYSQLDUMP_OPTION_TABLESPACE} "${PROD_DB_DATABASE}" > "${WHERE_TO_SAVE}"/"${SQL_FILE}"
        fi
            set -e
    else
        echo "c5 Backup: Enter the MySQL password..."
        mysqldump -h ${PROD_DB_HOST} --port=${PROD_MYSQL_PORT} -u ${PROD_DB_USERNAME} -p --single-transaction --default-character-set=${MYSQL_CHARASET} ${PROD_MYSQLDUMP_OPTION_TABLESPACE} "${PROD_DB_DATABASE}" > "${WHERE_TO_SAVE}"/"${SQL_FILE}"
    fi
}

do_db_import() {
    set_backup_directory
    send_back() {
        do_import
    }
    show_input() {
        USE_IMPORT_FILE="No"
    }
    send_forward() {
        USE_IMPORT_FILE="Yes"
    }
    echo "Would you like to import from a file?"
    manual_input
    SQL_FILE="${PROJECT_NAME}_prod_${NOW_TIME}.sql"
    if [ "${USE_IMPORT_FILE}" != "Yes" ] || [ "${USE_IMPORT_FILE}" != "YES" ] || [ "${USE_IMPORT_FILE}" != "yes" ] || [ "${USE_IMPORT_FILE}" != "TRUE" ] || [ "${USE_IMPORT_FILE}" != "True" ] || [ "${USE_IMPORT_FILE}" != "true" ]; then
        do_prod_db_backup
    else 
        set_import_file_location
    fi
    set_develop_db_details
    echo "c5 Import: Beginning import process..."
    if [ "$BACKUP_DB_EMPTY_DB" = "YES" ] || [ "$BACKUP_DB_EMPTY_DB" = "Yes" ] || [ "$BACKUP_DB_EMPTY_DB" = "yes" ] || [ "$BACKUP_DB_EMPTY_DB" = "TRUE" ] || [ "$BACKUP_DB_EMPTY_DB" = "True" ] || [ "$BACKUP_DB_EMPTY_DB" = "true" ]; then
      echo "c5 Import: Clearing the current database data"
      if [ -n "$BACKUP_DB_PASSWORD" ]; then
        set +e
        mysqldump -h ${BACKUP_DB_HOST} --port=${BACKUP_MYSQL_PORT} -u ${BACKUP_DB_USERNAME} --password=${BACKUP_DB_PASSWORD} --add-drop-table --no-data ${BACKUP_DB_DATABASE} | grep -e '^DROP \| FOREIGN_KEY_CHECKS' | mysql -h ${BACKUP_DB_HOST} --port=${BACKUP_MYSQL_PORT} -u ${BACKUP_DB_USERNAME} --password=${BACKUP_DB_PASSWORD} ${BACKUP_DB_DATABASE}
      fi
      ret=$?
      if [ "$ret" = 0 ]; then
        echo "c5 Import: Production data imported"
      fi
    fi
    echo "c5 Import: Importing Database Data..."
    if [ -n "$BACKUP_DB_PASSWORD" ]; then
        set +e
        if [ "$USE_IMPORT_FILE" = "YES" ] || [ "$USE_IMPORT_FILE" = "Yes" ] || [ "$USE_IMPORT_FILE" = "yes" ] || [ "$USE_IMPORT_FILE" = "TRUE" ] || [ "$USE_IMPORT_FILE" = "True" ] || [ "$USE_IMPORT_FILE" = "true" ]; then
            mysql -h ${BACKUP_DB_HOST} --port=${BACKUP_MYSQL_PORT} -u ${BACKUP_DB_USERNAME} --password=${BACKUP_DB_PASSWORD} --default-character-set=${MYSQL_CHARASET} "${BACKUP_DB_DATABASE}" < "${IMPORT_FILE}"
        else
            mysql -h ${BACKUP_DB_HOST} --port=${BACKUP_MYSQL_PORT} -u ${BACKUP_DB_USERNAME} --password=${BACKUP_DB_PASSWORD} --default-character-set=${MYSQL_CHARASET} "${BACKUP_DB_DATABASE}" < "${WHERE_TO_SAVE}"/"${SQL_FILE}"
        fi
        ret=$?
        if [ "$ret" = 0 ]; then
            echo ""
            echo "c5 Import: Production data imported"
            echo ""
            if [ "$BACKUP_DB_ANONYMIZE_USERS" = "YES" ] || [ "$BACKUP_DB_ANONYMIZE_USERS" = "Yes" ] || [ "$BACKUP_DB_ANONYMIZE_USERS" = "yes" ] || [ "$BACKUP_DB_ANONYMIZE_USERS" = "TRUE" ] || [ "$BACKUP_DB_ANONYMIZE_USERS" = "True" ] || [ "$BACKUP_DB_ANONYMIZE_USERS" = "true" ]; then
              echo "c5 Import: Replacing email addresses with dummy address"
              BACKUP_DB_ANONYMIZE_USERS_EXCEPT_OPTION="NOT LIKE '%${BACKUP_DB_ANONYMIZE_USERS_EXCEPT}%'"
              mysql -h ${BACKUP_DB_HOST} --port=${BACKUP_MYSQL_PORT} -u ${BACKUP_DB_USERNAME} --password=${BACKUP_DB_PASSWORD} --default-character-set=${MYSQL_CHARASET} --database=${BACKUP_DB_DATABASE} -e "UPDATE Users SET uEmail='dummy@example.com' WHERE uEmail {$BACKUP_DB_ANONYMIZE_USERS_EXCEPT_OPTION};"
            fi
            if [ "$BACKUP_DB_SET_DEFAULT_FILESTORAGELOCATION" = "YES" ] || [ "$BACKUP_DB_SET_DEFAULT_FILESTORAGELOCATION" = "Yes" ] || [ "$BACKUP_DB_SET_DEFAULT_FILESTORAGELOCATION" = "yes" ] || [ "$BACKUP_DB_SET_DEFAULT_FILESTORAGELOCATION" = "TRUE" ] || [ "$BACKUP_DB_SET_DEFAULT_FILESTORAGELOCATION" = "True" ] || [ "$BACKUP_DB_SET_DEFAULT_FILESTORAGELOCATION" = "true" ]; then
              echo "c5 Import: Setting storage to 'Default'"
              mysql -h ${BACKUP_DB_HOST} --port=${BACKUP_MYSQL_PORT} -u ${BACKUP_DB_USERNAME} --password=${BACKUP_DB_PASSWORD} --default-character-set=${MYSQL_CHARASET} --database=${BACKUP_DB_DATABASE} -e "UPDATE FileStorageLocations SET fslIsDefault='0';UPDATE FileStorageLocations SET fslIsDefault='1' WHERE fslID='1';"
            fi
        else
            echo "c5 Import: ERROR: MySQL password failed. You must type MySQL password manually. OR hit ENTER if you want to stop this script now."
            do_db_import_nomysqlpassword
        fi
        set -e
    else
        echo "c5 Import: Enter the MySQL password..."
        do_db_import_nomysqlpassword
    fi
    if [ "$USE_IMPORT_FILE" = "NO" ] || [ "$USE_IMPORT_FILE" = "No" ] || [ "$USE_IMPORT_FILE" = "no" ] || [ "$USE_IMPORT_FILE" = "FALSE" ] || [ "$USE_IMPORT_FILE" = "False" ] || [ "$USE_IMPORT_FILE" = "false" ]; then
        echo "c5 Import: Tar SQL"
        echo "c5 Import: Saving dumped SQL file as a tar as a backup..."
        tar -cvzpf "${WHERE_TO_SAVE}"/"${TAR_FILE}" "${WHERE_TO_SAVE}/${SQL_FILE}"
        echo "c5 Import: Now removing SQL dump file..."
        rm -f "${WHERE_TO_SAVE}/${SQL_FILE}"
    fi
}

do_db_import_nomysqlpassword() {
  set -e
  if [ "$USE_IMPORT_FILE" = "YES" ] || [ "$USE_IMPORT_FILE" = "Yes" ]; then
      mysql -h ${BACKUP_DB_HOST} --port=${BACKUP_MYSQL_PORT} -u ${BACKUP_DB_USERNAME} -p --default-character-set=${MYSQL_CHARASET} "${BACKUP_DB_DATABASE}" < "${IMPORT_FILE}"
  else
      mysql -h ${BACKUP_DB_HOST} --port=${BACKUP_MYSQL_PORT} -u ${BACKUP_DB_USERNAME} -p --default-character-set=${MYSQL_CHARASET} "${BACKUP_DB_DATABASE}" < "${WHERE_TO_SAVE}"/"${SQL_FILE}"
  fi
  echo ""
  echo "c5 Import: Production data imported"
  echo ""
  if [ "$BACKUP_DB_ANONYMIZE_USERS" = "YES" ] || [ "$BACKUP_DB_ANONYMIZE_USERS" = "Yes" ] || [ "$BACKUP_DB_ANONYMIZE_USERS" = "yes" ] || [ "$BACKUP_DB_ANONYMIZE_USERS" = "TRUE" ] || [ "$BACKUP_DB_ANONYMIZE_USERS" = "True" ] || [ "$BACKUP_DB_ANONYMIZE_USERS" = "true" ]; then
    echo "c5 Import: Replacing email addresses with dummy address"
    BACKUP_DB_ANONYMIZE_USERS_EXCEPT_OPTION="NOT LIKE '%${BACKUP_DB_ANONYMIZE_USERS_EXCEPT}%'"
    mysql -h ${BACKUP_DB_HOST} --port=${BACKUP_MYSQL_PORT} -u ${BACKUP_DB_USERNAME} --default-character-set=${MYSQL_CHARASET} --database=${BACKUP_DB_DATABASE} -e "UPDATE Users SET uEmail='dummy@example.com' WHERE uEmail {$BACKUP_DB_ANONYMIZE_USERS_EXCEPT_OPTION};"
  fi
  if [ "$BACKUP_DB_SET_DEFAULT_FILESTORAGELOCATION" = "YES" ] || [ "$BACKUP_DB_SET_DEFAULT_FILESTORAGELOCATION" = "Yes" ] || [ "$BACKUP_DB_SET_DEFAULT_FILESTORAGELOCATION" = "yes" ] || [ "$BACKUP_DB_SET_DEFAULT_FILESTORAGELOCATION" = "TRUE" ] || [ "$BACKUP_DB_SET_DEFAULT_FILESTORAGELOCATION" = "True" ] || [ "$BACKUP_DB_SET_DEFAULT_FILESTORAGELOCATION" = "true" ]; then
    echo "c5 Import: Setting storage to 'Default'"
    mysql -h ${BACKUP_DB_HOST} --port=${BACKUP_MYSQL_PORT} -u ${BACKUP_DB_USERNAME} --default-character-set=${MYSQL_CHARASET} --database=${BACKUP_DB_DATABASE} -e "UPDATE FileStorageLocations SET fslIsDefault='0';UPDATE FileStorageLocations SET fslIsDefault='1' WHERE fslID='1';"
  fi
}

manual_input() {
    q="nothing"
    while [ "$q" = "nothing" ]; do
        echo -en "(Yes/No)  : "
        read q
        case "$q" in
            "yes"|"y") echo "yes...."; send_forward;;
            "no"|"n") echo "no...."; show_input;;
            "q"|"quit") echo "Sending you back" ;send_back;;
            *) q="nothing";echo "Acceptable answers are y/yes/n/no or q/quit";echo "";;
        esac
    done
}

set_import_file_location() {
    while [ "$IMPORT_FILE" = "" ]; do
        echo -en "Please enter where import file is located (absolute path) : "
        read IMPORT_FILE
        case "$IMPORT_FILE" in 
            *".sql") ;;
            *) echo "import file must be an .sql file!"
            IMPORT_FILE=""
            ;;
            esac
    done

}

set_backup_directory() {
    if [ -z "$WHERE_TO_SAVE" ] || [ "$WHERE_TO_SAVE" = " " ]; then
        echo -en "Please enter where to save backups : "
        read WHERE_TO_SAVE
        case "$WHERE_TO_SAVE" in
            ""|"."|"./") WHERE_TO_SAVE="./";; 
            "/"*) ;;
            *) WHERE_TO_SAVE="./${WHERE_TO_SAVE}";;
        esac
    fi
    echo "Directory is ${WHERE_TO_SAVE}"
    

}

set_concrete_directory() {
    if [ -z "$WHERE_IS_CONCRETE5" ] || [ "$WHERE_IS_CONCRETE5" = " " ]; then
        echo -en "Please enter where concrete5 is located : "
        read WHERE_IS_CONCRETE5
        case "$WHERE_IS_CONCRETE5" in
        ""|"."|"./") WHERE_IS_CONCRETE5="./" ;;
        "/"*) ;;
        *) WHERE_IS_CONCRETE5="./${WHERE_IS_CONCRETE5}" ;;
        esac
    fi
    echo "Concrete5 is located at ${WHERE_IS_CONCRETE5}"
}

set_develop_db_details() {
    if [ -z "$BACKUP_DB_HOST" ] || [ "$BACKUP_DB_HOST" = " " ]; then
        echo -en "Please enter the address of the development MYSQL server (leave blank for localhost) : "
        read BACKUP_DB_HOST
        case "$BACKUP_DB_HOST" in
            "") BACKUP_DB_HOST="localhost";;
        esac
    fi
    if [ -z "$BACKUP_DB_USERNAME" ] || [ "$BACKUP_DB_USERNAME" = " " ]; then
        while [ -z "$BACKUP_DB_USERNAME" ]; do 
            echo -en "Please enter the MYSQL user for the development server's database : "
            read BACKUP_DB_USERNAME
            case "$BACKUP_DB_USERNAME" in
                ""|" ") BACKUP_DB_USERNAME=""; echo "You must enter a username";;
            esac
        done;
    fi
    if [ -z "$BACKUP_DB_DATABASE" ] || [ "$BACKUP_DB_DATABASE" = " " ]; then
        while [ -z "$BACKUP_DB_DATABASE" ]; do 
            echo -en "Please enter the database name which you would like to use : "
            read BACKUP_DB_DATABASE
            case "$BACKUP_DB_DATABASE" in
                ""|" ") BACKUP_DB_DATABASE=""; echo "You must enter a database name";;
            esac
        done  
    fi
    echo "We will log in with ${BACKUP_DB_USERNAME} on ${BACKUP_DB_HOST} and use the database called ${BACKUP_DB_DATABASE}"
}

set_prod_db_details() {
    if [ -z "$PROD_DB_HOST" ] || [ "$PROD_DB_HOST" = " " ]; then
        echo -en "Please enter the address of the Production MYSQL server (leave blank for localhost) : "
        read PROD_DB_HOST
        case "$PROD_DB_HOST" in
            ""|" ") PROD_DB_HOST="localhost";;
        esac
    fi
    if [ -z "$PROD_DB_USERNAME" ] || [ "$PROD_DB_USERNAME" = " " ]; then
        while [ -z "$PROD_DB_USERNAME" ]; do 
            echo -en "Please enter the MYSQL user for the Production server's database : "
            read PROD_DB_USERNAME
            case "$PROD_DB_USERNAME" in
                ""|" ") PROD_DB_USERNAME=""; echo "You must enter a username";;
            esac
        done;
    fi
    if [ -z "$PROD_DB_DATABASE" ] || [ "$PROD_DB_DATBASE" = " " ]; then
        while [ -z "$PROD_DB_USERNAME" ]; do 
            echo -en "Please enter the database name which you would like to use : "
            read PROD_DB_DATABASE
            case "$PROD_DB_DATABASE" in
                ""|" ") PROD_DB_DATABASE=""; echo "You must enter a database name";;
            esac
        done;
    
  
    fi
    echo "We will log in with ${PROD_DB_USERNAME} on ${PROD_DB_HOST} and use the database called ${PROD_DB_DATABASE}"
}

do_backup () {
    echo " ========================================"
    echo "           BACKING UP concrete5          "
    echo " ========================================"
    echo 
    set_backup_directory
    
    echo "Starting concrete5 backup..."
    if [ "$backup_type" = "1" ]; then
        do_db_backup
    else
        set_concrete_directory
        # ---- Executing the commands -----
        echo "c5 Backup: Switching current directory to"
        echo "${WHERE_IS_CONCRETE5}"
        cd ${WHERE_IS_CONCRETE5}
        if [ "$backup_type" = "2" ]; then
            do_file_backup
        elif [ "$backup_type" = "4" ]; then
            do_db_backup
            do_config_backup
        else # $backup_type = "3"
            do_db_backup
            do_file_backup
        fi
    fi
    echo 
    echo "c5 Backup: Backup Completed"
    echo
}

do_db_backup() {
    if [ "$DO_EVERYTHING" != "Yes" ]; then
        backupwhat="nothing"
        echo "Which database do you want to backup?"
        while [ "$backupwhat" = "nothing" ]; do
        echo -en "production or development?"
        read backupwhat 
            case "$backupwhat" in
                "production"|"prod"|"p") do_prod_db_backup;;
                "development"|"dev"|"d"|"d"|"backup"|"b") do_dev_db_backup;;
                ""|" ") echo "backing up development database"; do_dev_db_backup;;
                "q"|"quit") echo "This script was not meant for this world... Goodbye..."; exit 0;;
                *) backupwhat="nothing";;
            esac
        done

    else
        do_dev_db_backup
    fi

    SQL_TAR_FILE="${PROJECT_NAME}"_"${NOW_TIME}_sql.tar.gz"
    echo "c5 Backup: Making tar from SQL"
    tar -cvzpf "${WHERE_TO_SAVE}"/"${SQL_TAR_FILE}" "${WHERE_TO_SAVE}/${SQL_FILE}"
    echo "c5 Backup: Now removing SQL dump file..."
    rm -f "${WHERE_TO_SAVE}/${SQL_FILE}"
}

do_dev_db_backup() {
    set_develop_db_details
    echo "c5 Backup: Executing MySQL Dump..."
    SQL_FILE="${PROJECT_NAME}_dev_${NOW_TIME}.sql"
    if [ -n "$BACKUP_DB_PASSWORD" ]; then
        set +e
        mysqldump -h ${BACKUP_DB_HOST} --port=${BACKUP_MYSQL_PORT} -u ${BACKUP_DB_USERNAME} --password=${BACKUP_DB_PASSWORD} --single-transaction --default-character-set=${MYSQL_CHARASET} ${BACKUP_MYSQLDUMP_OPTION_TABLESPACE} "${BACKUP_DB_DATABASE}" > "${WHERE_TO_SAVE}"/"${SQL_FILE}"
        ret=$?
        if [ "$ret" = 0 ]; then
            echo ""
            echo "c5 Backup: MySQL Database was dumped successfully."
        else
            echo "c5 Backup: ERROR: MySQL password failed. You must type MySQL password manually. OR hit ENTER if you want to stop this script now."
            set -e
            mysqldump -h ${BACKUP_DB_HOST} --port=${BACKUP_MYSQL_PORT} -u ${BACKUP_DB_USERNAME} -p --single-transaction --default-character-set=${MYSQL_CHARASET} ${BACKUP_MYSQLDUMP_OPTION_TABLESPACE} "${BACKUP_DB_DATABASE}" > "${WHERE_TO_SAVE}"/"${SQL_FILE}"
        fi
        set -e
    else
        echo "c5 Backup: Enter the MySQL password..."
        mysqldump -h ${BACKUP_DB_HOST} --port=${BACKUP_MYSQL_PORT} -u ${BACKUP_DB_USERNAME} -p --single-transaction --default-character-set=${MYSQL_CHARASET} ${BACKUP_MYSQLDUMP_OPTION_TABLESPACE} "${BACKUP_DB_DATABASE}" > "${WHERE_TO_SAVE}"/"${SQL_FILE}"
    fi
}

do_file_backup() {
    # Extend this to do more types of file backup
    echo "c5 Backup: Making a tar of All files"
    tar -cvzpf "${WHERE_TO_SAVE}"/"${TAR_FILE}" "${WHERE_IS_CONCRETE5}"
}

do_config_backup() {
    CONFIG_TAR_FILE="${PROJECT_NAME}"_"${NOW_TIME}_config.tar.gz"
    echo "c5 Backup: Making a tar of config files"
    tar -cvzpf "${WHERE_TO_SAVE}"/"${CONFIG_TAR_FILE}" "${WHERE_IS_CONCRETE5}/application/config"
}

do_upgrade() {
    set_concrete_directory
    echo "c5 Upgrade: ========================================"
    echo "c5 Upgrade: NOW PLACING concrete5 new core & lang files"
    echo "c5 Upgrade: ========================================"
    echo "c5 Upgrade:"
    echo "c5 Upgrade: Switching current directory to"
    echo "${WHERE_IS_CONCRETE5}"
    cd ${WHERE_IS_CONCRETE5}
    echo "c5 Upgrade: Creating a working concrete5 directory: ${CONCRETE5_WORKING_DIRECTORY_NAME}"
    mkdir ${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}
    echo "c5 Upgrade: Switching to inside of concrete5 directory"
    cd ${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}

    BASE_PATH_NEW_VERSION="${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}"
    echo "c5 Upgrade:..."
    echo "c5 Upgrade: BASE_PATH_NEW_VERSION is: ${BASE_PATH_NEW_VERSION} (for debug purpose)"
    echo "c5 Upgrade:..."

    echo "c5 Upgrade: Getting a new concrete5 core file"
    echo "c5 Upgrade: curl -L -o ${BASE_PATH_NEW_VERSION}/concrete5.zip ${CONCRETE5_PACKAGE_DOWNLOAD}"
    curl -L -o ${BASE_PATH_NEW_VERSION}/concrete5.zip ${CONCRETE5_PACKAGE_DOWNLOAD}
    echo "c5 Upgrade: Unzipping new concrete5.zip"
    unzip -q ${BASE_PATH_NEW_VERSION}/concrete5.zip
    echo "c5 Upgrade: Moving all concrete5 core file to parent directory"
    mv ${BASE_PATH_NEW_VERSION}/${CONCRETE5_PACKAGE_DIRECTORY_NAME}/* ./
    echo "c5 Upgrade: Deleting concrete5 version folder"
    rm -r ${BASE_PATH_NEW_VERSION:?}/${CONCRETE5_PACKAGE_DIRECTORY_NAME}
    echo "c5 Upgrade: Moving concrete core folder and rename it as concrete_new folder on concrete5 root directory"
    mv ${BASE_PATH_NEW_VERSION}/concrete ${WHERE_IS_CONCRETE5}/concrete5_new
    echo "c5 Upgrade: Switching to application folder"
    echo "cd ${WHERE_IS_CONCRETE5}/application"
    cd ${WHERE_IS_CONCRETE5}/application

    BASE_PATH_APPLICATION="${WHERE_IS_CONCRETE5}/application"

    echo "c5 Upgrade: BASE_PATH_APPLICATION is: ${BASE_PATH_APPLICATION} (for debug purpose)"


    echo "c5 Upgrade: Copying old 'languages' folder to inside of '${CONCRETE5_WORKING_DIRECTORY_NAME}' folder as 'languages_old' folder"
    echo "cp -r ${BASE_PATH_APPLICATION}/languages ${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}/languages_old"
    cp -r ${BASE_PATH_APPLICATION}/languages ${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}/languages_old

    echo "c5 Upgrade: Switching to concrete5 root folder"
    cd ${WHERE_IS_CONCRETE5}
    echo "c5 Upgrade: Moving concrete5 core folder to '/${CONCRETE5_WORKING_DIRECTORY_NAME}/concrete_old'"
    mv ${WHERE_IS_CONCRETE5}/concrete ${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}/concrete_old
    echo "c5 Upgrade: Renaming 'concrete_new' core folder to 'concrete'"
    mv ${WHERE_IS_CONCRETE5}/concrete5_new ${WHERE_IS_CONCRETE5}/concrete

    echo "c5 Upgrade: ..."

# ------------------------------
# UPGRADES
# ------------------------------

    if [ "$C5_Version" != "5.7.5.13" ]; then
        echo "c5 Upgrade: ========================================"
        echo "c5 Upgrade:           UPGRADING concrete5 Now"
        echo "c5 Upgrade: ========================================"
        echo "c5 Upgrade: If you're using concrete5.7.x, you will have to either"
        echo "c5 Upgrade: - Enable core update option, or"
        echo "c5 Upgrade: - visit [concrete5]/index.php/ccm/system/upgrade to execute upgrade"
        echo "c5 Upgrade: Executing Upgrade (Version 8 and above)"
        echo "c5 Upgrade: Making sure that CLI is executable"
        chmod u+x ${WHERE_IS_CONCRETE5}/concrete/bin/concrete5
        echo "c5 Upgrade: Now running upgrade script"
        ${DO_SUDO}${WHERE_IS_CONCRETE5}/concrete/bin/concrete5 c5:update
    else
        echo "c5 Upgrade: ========================================"
        echo "c5 Upgrade:         PLEASE upgrade MANUALLY!!"
        echo "c5 Upgrade: ========================================"
        echo "c5 Upgrade: Please execute upgrade."
        echo "c5 Upgrade: - Enable core update option, or"
        echo "c5 Upgrade: - visit [concrete5]/index.php/ccm/system/upgrade to execute upgrade"
    fi

    echo "c5 Upgrade: ..."
    echo "c5 Upgrade: ..."

    # ------------------------------
    # Delete working directory and old concrete5 files
    # ------------------------------

    if [ "$DELETE_WORKFILE" = "yes" ]; then
        echo "c5 Upgrade: ========================================"
        echo "c5 Upgrade:      DELETING upgrade working directory"
        echo "c5 Upgrade: ========================================"
        echo "c5 Upgrade: Now deleting working folder:"
        echo "c5 Upgrade: '${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}' directory"
        rm -r ${WHERE_IS_CONCRETE5:?}/${CONCRETE5_WORKING_DIRECTORY_NAME}
    else
        echo "c5 Upgrade: ========================================"
        echo "c5 Upgrade:      PLEASE delete working directory"
        echo "c5 Upgrade: ========================================"
        echo "c5 Upgrade: Update is about to finish"
        echo "c5 Upgrade: Please note that we put all old working file under"
        echo "c5 Upgrade: '${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}' directory"
        echo "c5 Upgrade: Make sure to delete them after you've checked if everything works."
    fi

    if [ -z "$DO_SUDO" ]; then
      update_file_permissions
    fi
    install_languages
    # disable_maintenance_mode
    if [ -z "$DO_SUDO" ]; then
      update_file_permissions
    fi

    echo "c5 Upgrade: ..."
    echo "c5 Upgrade: ..."
    echo "c5 Upgrade: ..."
    echo "c5 Upgrade: Upgrade process completed!"
}

update_file_permissions() {
    echo "c5 Upgrade: Updating file folder permissions"
    sudo chown -R ${USER_PERMISSIONS} ${WHERE_IS_CONCRETE5}/application/config/doctrine
    sudo chown -R ${USER_PERMISSIONS} ${WHERE_IS_CONCRETE5}/application/config/generated_overrides
    sudo chown -R ${USER_PERMISSIONS} ${WHERE_IS_CONCRETE5}/application/files
    sudo chown -R ${USER_PERMISSIONS} ${WHERE_IS_CONCRETE5}/application/languages
    sudo chown -R ${USER_PERMISSIONS} ${WHERE_IS_CONCRETE5}/concrete
    # chown -R ${USER_PERMISSIONS} ${WHERE_IS_CONCRETE5}/packages
}

install_languages() {
    echo "c5 Upgrade: Updating all the outdated language files (for the concrete5 core and for all the packages)"
    ${DO_SUDO}${WHERE_IS_CONCRETE5}/concrete/bin/concrete5 c5:language-install --update
}
disable_maintenance_mode() {
    echo "c5 Upgrade: Disabling maintenance mode"
    ${DO_SUDO}${WHERE_IS_CONCRETE5}/concrete/bin/concrete5 c5:config -g set concrete.maintenance_mode false
}
enable_maintenance_mode() {
    echo "c5 Upgrade: Enabling maintenance mode"
    ${DO_SUDO}${WHERE_IS_CONCRETE5}/concrete/bin/concrete5 c5:config -g set concrete.maintenance_mode true
}



do_main_menu
