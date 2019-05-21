#!/bin/sh
#
# Upgrade Script for Concrete5
# ----------
# Version 0.1
# By Derek Cameron & Katz Ueno

# INSTRUCTION:
# ----------
# https://github.com/katzueno/concrete5-upgrade-shell

# USE IT AT YOUR OWN RISK!

# VARIABLES
# ----------

# Production Details to import from or to upgrade
PROD_DB_HOST="localhost"
PROD_DB_USERNAME=""
PROD_DB_PASSWORD=""
PROD_DB_DATABASE=""
# Use Import file instead of production database
USE_IMPORT_FILE="NO"
IMPORT_FILE=""

# Development details to backup/import to
DEV_DB_HOST="localhost"
DEV_DB_USERNAME=""
DEV_DB_PASSWORD=""
DEV_DB_DATABASE=""

# Concrete5 Variables
SITE_NAME="Concrete5"
WHERE_IS_CONCRETE5="/var/www/vhosts/concrete5"

C5_Version="8.5.1"
CONCRETE5_PACKAGE_DOWNLOAD="https://www.concrete5.org/download_file/-/view/109615/8497/"

# Concrete 5 Download Links
#   '5.7.5.13'=>'http://www.concrete5.org/download_file/-/view/93075/8497/',
#   '8.0.0'=>'http://www.concrete5.org/download_file/-/view/92663/8497/',
#   '8.0.1'=>'http://www.concrete5.org/download_file/-/view/92834/8497/',
#   '8.0.2'=>'http://www.concrete5.org/download_file/-/view/92910/8497/',
#   '8.0.3'=>'http://www.concrete5.org/download_file/-/view/93074/8497/',
#   '8.1.0'=>'http://www.concrete5.org/download_file/-/view/93797/8497/',
#   '8.2.0'=>'http://www.concrete5.org/download_file/-/view/96765/8497/',
#    '8.2.1'=>'http://www.concrete5.org/download_file/-/view/96959/8497/',
#    '8.3.0'=>'http://www.concrete5.org/download_file/-/view/99806/8497/',
#    '8.3.1'=>'http://www.concrete5.org/download_file/-/view/99963/8497/',
#    '8.3.2'=>'http://www.concrete5.org/download_file/-/view/100595/8497/',
#    '8.4.0'=>'http://www.concrete5.org/download_file/-/view/104344/',
#    '8.4.0'=>'http://www.concrete5.org/download_file/-/view/104344/'
#    '8.4.1'=>'http://www.concrete5.org/download_file/-/view/105022/'
#    '8.4.2'=>'http://www.concrete5.org/download_file/-/view/105477/'
#    '8.4.3'=>'http://www.concrete5.org/download_file/-/view/106698/'
#    '8.4.4'=>'https://www.concrete5.org/download_file/-/view/108181/8497/'
#    '8.4.5'=>'https://www.concrete5.org/download_file/-/view/108839/8497/'
#    '8.5.0'=>'https://www.concrete5.org/download_file/-/view/109116/8497/'
#    '8.5.1'=>'https://www.concrete5.org/download_file/-/view/109615/8497/'

# Backup Variables
WHERE_TO_SAVE="/var/www/vhosts/backups"
FILE_NAME="${C5_Version}-upgrade"
USER_PERMISSIONS="apache:apache"


# ==============================
#
# DO NOT TOUCH BELOW THIS LINE (unless you're really a cool person.)
#
# ==============================

DELETE_WORKFILE="No"
DO_EVERYTHING="No"
NOW_TIME=$(date "+%Y%m%d%H%M%S")
TAR_FILE="${SITE_NAME}_${FILE_NAME}"_"${NOW_TIME}.tar.gz"

if [ "$C5_Version" = "5.7.5.13" ]; then
    CONCRETE5_PACKAGE_DIRECTORY_NAME="concrete5.7.5.13"
else
    CONCRETE5_PACKAGE_DIRECTORY_NAME="concrete5-${C5_Version}"
fi
CONCRETE5_WORKING_DIRECTORY_NAME="${C5_Version}upgrade_working"


# ---- Checking The Options -----

show_main_menu()
{
  
  echo "-- Concrete5 Upgrade Script --"
  echo "1. Backup data from concrete5"
  echo "2. Import data from production"
  echo "3. Upgrade Concrete5 to version ${C5_Version}"
  echo "4. Do all of the above"
  echo "5. Set Options"
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
    DEV_DB_HOST=""
    DEV_DB_USERNAME=""
    DEV_DB_PASSWORD=""
    DEV_DB_DATABASE=""
}

reset_prod_settings() {
    PROD_DB_HOST=""
    PROD_DB_USERNAME=""
    PROD_DB_PASSWORD=""
    PROD_DB_DATABASE=""
}

show_backup() {
selection="nothing"
    echo
    echo "Please Select which type of Backup you would like to do"
    echo "1. Backup database only"
    echo "2. Backup files only"
    echo "3. Backup files and database"
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
    SQL_FILE="${SITE_NAME}_${FILE_NAME}_prod_${NOW_TIME}.sql"
    echo "c5 Backup: Backing up production database to ${WHERE_TO_SAVE}/${SQL_FILE}"
    if [ -n "$PROD_DB_PASSWORD" ]; then
        set +e
        mysqldump -h ${PROD_DB_HOST} -u ${PROD_DB_USERNAME} --password=${PROD_DB_PASSWORD} --single-transaction --default-character-set=utf8 "${PROD_DB_DATABASE}" > "${WHERE_TO_SAVE}"/"${SQL_FILE}"
        ret=$?
        if [ "$ret" = 0 ]; then
            echo ""
            echo "c5 Backup: MySQL Database was dumped successfully."
        else
            echo "c5 Backup: ERROR: MySQL password failed. You must type MySQL password manually. OR hit ENTER if you want to stop this script now."
            set -e
            mysqldump -h ${PROD_DB_HOST} -u ${PROD_DB_USERNAME} -p --single-transaction --default-character-set=utf8 "${PROD_DB_DATABASE}" > "${WHERE_TO_SAVE}"/"${SQL_FILE}"
        fi
            set -e
    else
        echo "c5 Backup: Enter the MySQL password..."
        mysqldump -h ${PROD_DB_HOST} -u ${PROD_DB_USERNAME} -p --single-transaction --default-character-set=utf8 "${PROD_DB_DATABASE}" > "${WHERE_TO_SAVE}"/"${SQL_FILE}"
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
    SQL_FILE="${SITE_NAME}_${FILE_NAME}_prod_${NOW_TIME}.sql"
    if [ "${USE_IMPORT_FILE}" != "Yes" ]; then
        do_prod_db_backup
    else 
        set_import_file_location
    fi
    set_develop_db_details
    echo "c5 Import: Begining import process..."
    if [ -n "$DEV_DB_PASSWORD" ]; then
        set +e
        if [ "$USE_IMPORT_FILE" = "Yes" ]; then
            mysql -h ${DEV_DB_HOST} -u ${DEV_DB_USERNAME} --password=${DEV_DB_PASSWORD} "${DEV_DB_DATABASE}" < "${IMPORT_FILE}"
        else
            mysql -h ${DEV_DB_HOST} -u ${DEV_DB_USERNAME} --password=${DEV_DB_PASSWORD} "${DEV_DB_DATABASE}" < "${WHERE_TO_SAVE}"/"${SQL_FILE}"
        fi
        ret=$?
        if [ "$ret" = 0 ]; then
            echo ""
            echo "c5 Import: Production data imported"
            echo ""
            echo "c5 Import: Replacing email addresses with dummy address"
            echo "c5 Import: Setting storage to 'Default'"
            mysql -h ${DEV_DB_HOST} -u ${DEV_DB_USERNAME} --password=${DEV_DB_PASSWORD} --database=${DEV_DB_DATABASE} -e "UPDATE Users SET uEmail='dummy@localhost' WHERE uEmail NOT LIKE '%concrete5.co.jp';UPDATE FileStorageLocations SET fslIsDefault='0';UPDATE FileStorageLocations SET fslIsDefault='1' WHERE fslID='1';"

        else
            echo "c5 Import: ERROR: MySQL password failed. You must type MySQL password manually. OR hit ENTER if you want to stop this script now."
            set -e
            if [ "$USE_IMPORT_FILE" = "Yes" ]; then
                mysql -h ${DEV_DB_HOST} -u ${DEV_DB_USERNAME} -p  "${DEV_DB_DATABASE}" < "${IMPORT_FILE}"
            else
                mysql -h ${DEV_DB_HOST} -u ${DEV_DB_USERNAME} -p  "${DEV_DB_DATABASE}" < "${WHERE_TO_SAVE}"/"${SQL_FILE}"
            fi
            echo ""
            echo "c5 Import: Production data imported"
            echo ""
            echo "c5 Import: Replacing email addresses with dummy address"
            echo "c5 Import: Setting storage to 'Default'"
            mysql -h ${DEV_DB_HOST} -u ${DEV_DB_USERNAME} -p --database=${DEV_DB_DATABASE} -e "UPDATE Users SET uEmail='dummy@localhost' WHERE uEmail NOT LIKE '%concrete5.co.jp';UPDATE FileStorageLocations SET fslIsDefault='0';UPDATE FileStorageLocations SET fslIsDefault='1' WHERE fslID='1';"
        fi
        set -e
    else
        echo "c5 Backup: Enter the MySQL password..."
        if [ "$USE_IMPORT_FILE" = "Yes" ]; then
            mysql -h ${DEV_DB_HOST} -u ${DEV_DB_USERNAME} -p  "${DEV_DB_DATABASE}" < "${IMPORT_FILE}"
        else
            mysql -h ${DEV_DB_HOST} -u ${DEV_DB_USERNAME} -p  "${DEV_DB_DATABASE}" < "${WHERE_TO_SAVE}"/"${SQL_FILE}"
        fi
        echo ""
        echo "c5 Import: Production data imported"
        echo ""
        echo "c5 Import: Replacing email addresses with dummy address"
        echo "c5 Import: Setting storage to 'Default'"
        mysql -h ${DEV_DB_HOST} -u ${DEV_DB_USERNAME} -p --database=${DEV_DB_DATABASE} -e "UPDATE Users SET uEmail='dummy@localhost' WHERE uEmail NOT LIKE '%concrete5.co.jp'" -e"UPDATE FileStorageLocations SET fslIsDefault='0';UPDATE FileStorageLocations SET fslIsDefault='1' WHERE fslID='1';"
        
    fi
    echo "c5 Backup: Zipping SQL"
    if [ "$USE_IMPORT_FILE" = "Yes" ]; then
        tar -cvzpf "${WHERE_TO_SAVE}"/"${TAR_FILE}" "${IMPORT_FILE}"
        echo "c5 Backup: Now removing SQL dump file..."
        rm -f "${IMPORT_FILE}"
    else
        tar -cvzpf "${WHERE_TO_SAVE}"/"${TAR_FILE}" "${WHERE_TO_SAVE}/${SQL_FILE}"
        echo "c5 Backup: Now removing SQL dump file..."
        rm -f "${WHERE_TO_SAVE}/${SQL_FILE}"
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
    if [ -z "$DEV_DB_HOST" ] || [ "$DEV_DB_HOST" = " " ]; then
        echo -en "Please enter the address of the development MYSQL server (leave blank for localhost) : "
        read DEV_DB_HOST
        case "$DEV_DB_HOST" in
            "") DEV_DB_HOST="localhost";;
        esac
    fi
    if [ -z "$DEV_DB_USERNAME" ] || [ "$DEV_DB_USERNAME" = " " ]; then
        while [ -z "$DEV_DB_USERNAME" ]; do 
            echo -en "Please enter the MYSQL user for the development server's database : "
            read DEV_DB_USERNAME
            case "$DEV_DB_USERNAME" in
                ""|" ") DEV_DB_USERNAME=""; echo "You must enter a username";;
            esac
        done;
    fi
    if [ -z "$DEV_DB_DATABASE" ] || [ "$DEV_DB_DATABASE" = " " ]; then
        while [ -z "$DEV_DB_DATABASE" ]; do 
            echo -en "Please enter the database name which you would like to use : "
            read DEV_DB_DATABASE
            case "$DEV_DB_DATABASE" in
                ""|" ") DEV_DB_DATABASE=""; echo "You must enter a database name";;
            esac
        done  
    fi
    echo "We will log in with ${DEV_DB_USERNAME} on ${DEV_DB_HOST} and use the database called ${DEV_DB_DATABASE}"
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
        else
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
                "development"|"dev"|"d") do_dev_db_backup;;
                ""|" ") echo "backing up development database"; do_dev_db_backup;;
                "q"|"quit") echo "This script was not meant for this world... Goodbye..."; exit 0;;
                *) backupwhat="nothing";;
            esac
        done

    else
        do_dev_db_backup
    fi

    echo "c5 Backup: Zipping SQL"
    tar -cvzpf "${WHERE_TO_SAVE}"/"${TAR_FILE}" "${WHERE_TO_SAVE}/${SQL_FILE}"
    echo "c5 Backup: Now removing SQL dump file..."
    rm -f "${WHERE_TO_SAVE}/${SQL_FILE}"
}

do_dev_db_backup() {
    set_develop_db_details
    echo "c5 Backup: Executing MySQL Dump..."
    SQL_FILE="${SITE_NAME}_${FILE_NAME}_dev_${NOW_TIME}.sql"
    if [ -n "$DEV_DB_PASSWORD" ]; then
        set +e
        mysqldump -h ${DEV_DB_HOST} -u ${DEV_DB_USERNAME} --password=${DEV_DB_PASSWORD} --single-transaction --default-character-set=utf8 "${DEV_DB_DATABASE}" > "${WHERE_TO_SAVE}"/"${SQL_FILE}"
        ret=$?
        if [ "$ret" = 0 ]; then
            echo ""
            echo "c5 Backup: MySQL Database was dumped successfully."
        else
            echo "c5 Backup: ERROR: MySQL password failed. You must type MySQL password manually. OR hit ENTER if you want to stop this script now."
            set -e
            mysqldump -h ${DEV_DB_HOST} -u ${DEV_DB_USERNAME} -p --single-transaction --default-character-set=utf8 "${DEV_DB_DATABASE}" > "${WHERE_TO_SAVE}"/"${SQL_FILE}"
        fi
        set -e
    else
        echo "c5 Backup: Enter the MySQL password..."
        mysqldump -h ${DEV_DB_HOST} -u ${DEV_DB_USERNAME} -p --single-transaction --default-character-set=utf8 "${DEV_DB_DATABASE}" > "${WHERE_TO_SAVE}"/"${SQL_FILE}"
    fi
}

do_file_backup() {
    # Extend this to do more types of file backup
    echo "c5 Backup: Zipping All files"
    tar -cvzpf "${WHERE_TO_SAVE}"/"${TAR_FILE}" "${WHERE_IS_CONCRETE5}"
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
    wget -O ${BASE_PATH_NEW_VERSION}/concrete5.zip ${CONCRETE5_PACKAGE_DOWNLOAD}
    echo "c5 Upgrade: Unzipping new concrete5.zip"
    unzip -q ${BASE_PATH_NEW_VERSION}/concrete5.zip
    echo "c5 Upgrade: Moving all concrete5 core file to parent directory"
    mv ${BASE_PATH_NEW_VERSION}/${CONCRETE5_PACKAGE_DIRECTORY_NAME}/* ./
    echo "c5 Upgrade: Deleting concrete5 version folder"
    rm -r ${BASE_PATH_NEW_VERSION:?}/${CONCRETE5_PACKAGE_DIRECTORY_NAME}
    echo "c5 Upgrade: Moving concrete core folder and rename it as concrete_new folder on concrete5 root directory"
    mv ${BASE_PATH_NEW_VERSION}/concrete ${WHERE_IS_CONCRETE5}/concrete5_new
    echo "c5 Upgrade: Now Replacing languages file to new languages file."
    echo "c5 Upgrade: Moving new languages folder as languages_new folder under application folder."
    echo "mv ${BASE_PATH_NEW_VERSION}/application/languages ${WHERE_IS_CONCRETE5}/application/languages_new"
    mv ${BASE_PATH_NEW_VERSION}/application/languages ${WHERE_IS_CONCRETE5}/application/languages_new
    echo "c5 Upgrade: Switching to application folder"
    echo "cd ${WHERE_IS_CONCRETE5}/application"
    cd ${WHERE_IS_CONCRETE5}/application

    BASE_PATH_APPLICATION="${WHERE_IS_CONCRETE5}/application"

    echo "c5 Upgrade: BASE_PATH_APPLICATION is: ${BASE_PATH_APPLICATION} (for debug purpose)"


    echo "c5 Upgrade: Moving old 'languages' folder to inside of '${CONCRETE5_WORKING_DIRECTORY_NAME}' folder as 'languages_old' folder"
    echo "mv ${BASE_PATH_APPLICATION}/languages ${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}/languages_old"
    mv ${BASE_PATH_APPLICATION}/languages ${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}/languages_old
    echo "c5 Upgrade: Renaming 'languages_new' folder to 'languages' folder"
    echo "mv ${BASE_PATH_APPLICATION}/languages_new mv ${BASE_PATH_APPLICATION}/languages"
    mv ${BASE_PATH_APPLICATION}/languages_new ${BASE_PATH_APPLICATION}/languages

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
        ${WHERE_IS_CONCRETE5}/concrete/bin/concrete5 c5:update
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

    update_file_permissions
    install_languages
    disable_maintenance_mode

    echo "c5 Upgrade: ..."
    echo "c5 Upgrade: ..."
    echo "c5 Upgrade: ..."
    echo "c5 Upgrade: Upgrade process completed!"
}

update_file_permissions() {
    echo "c5 Upgrade: Updating file folder permissions"
    chown -R ${USER_PERMISSIONS} ${WHERE_IS_CONCRETE5}/application/config
    chown -R ${USER_PERMISSIONS} ${WHERE_IS_CONCRETE5}/application/files
    chown -R ${USER_PERMISSIONS} ${WHERE_IS_CONCRETE5}/application/languages
    chown -R ${USER_PERMISSIONS} ${WHERE_IS_CONCRETE5}/concrete
    #chown -R ${USER_PERMISSIONS} ${WHERE_IS_CONCRETE5}/packages
}

install_languages() {
    echo "c5 Upgrade: Copying old languages to new languages folder"
    echo "cp -rf ${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}/languages_old/* ${BASE_PATH_APPLICATION}/languages/"
    cp -rf ${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}/languages_old/* ${BASE_PATH_APPLICATION}/languages/

    echo "c5 Upgrade: Updating all the outdated language files (for the concrete5 core and for all the packages)"
    ${WHERE_IS_CONCRETE5}/concrete/bin/concrete5 c5:language-install --update
}
disable_maintenance_mode() {
    echo "c5 Upgrade: Disabling maintenance mode"
    ${WHERE_IS_CONCRETE5}/concrete/bin/concrete5 c5:config -g set concrete.maintenance_mode false
}


do_main_menu
