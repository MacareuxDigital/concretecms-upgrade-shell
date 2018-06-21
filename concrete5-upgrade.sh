#!/bin/sh
#
# concrete5 core uggrade shell:
# ----------
# Version 1.0
# By katzueno

# INSTRUCTION:
# ----------
# https://github.com/katzueno/concrete5-upgrade-shell

# USE IT AT YOUR OWN RISK!

set -e

# VARIABLES
# ----------
NOW_TIME=$(date "+%Y%m%d%H%M%S")
WHERE_IS_CONCRETE5="/var/www/html/www"
CONCRETE5_PACKAGE_DOWNLOAD="http://www.concrete5.org/download_file/-/view/93075/8497/"
CONCRETE5_PACKAGE_DIRECTORY_NAME="concrete5.7.5.13"
CONCRETE5_WORKING_DIRECTORY_NAME="concrete5_upgrade_working"
WHERE_TO_SAVE="/var/www/html/backup"
FILE_NAME="katzueno"
MYSQL_SERVER="localhost"
MYSQL_NAME="database"
MYSQL_USER="root"
# MYSQL_PASSWORD="pass"

# ==============================
#
# DO NOT TOUCH BELOW THIS LINE (unless you know what you're doing.)
#
# ==============================

# ---- Checking The Options -----
BASE_PATH=''
if [ "$4" = "-a" ] || [ "$4" = "--absolute" ]; then
    BASE_PATH="${WHERE_IS_CONCRETE5}"
elif [ "$4" = "-r" ] || [ "$4" = "--relative" ] || [ "$4" = "" ]; then
    BASE_PATH="."
else
    NO_4th_OPTION="1"
fi

if [ "$3" = "-n" ] || [ "$3" = "--no-upgrade" ]; then
    RUN_UPGRADE="no"
elif [ "$3" = "-r" ] || [ "$3" = "--run-upgrade" ] || [ "$3" = "" ]; then
    RUN_UPGRADE="yes"
else
    NO_3rd_OPTION="1"
fi

if [ "$2" = "-d" ] || [ "$2" = "--delete" ]; then
    DELETE_WORKFILE="yes"
elif [ "$2" = "-n" ] || [ "$2" = "--do-not-delete" ] || [ "$2" = "" ]; then
    DELETE_WORKFILE="no"
else
    NO_2nd_OPTION="1"
fi

if [ "$1" = "--all" ] || [ "$1" = "-a" ]; then
    echo "c5 Upgrade: You've chosen the ALL backup option. Now we're backing up all concrete5 directory files before upgrading concrete5"
    ZIP_OPTION="${BASE_PATH}"
    DO_BACKUP="yes"
    NO_OPTION="0"
elif [ "$1" = "--packages" ] || [ "$1" = "--package" ] || [ "$1" = "-p" ]; then
    echo "c5 Upgrade: You've chosen the PACKAGE option. Now we're backing up the SQL, application/files and packages/ folder before upgrading concrete5."
    ZIP_OPTION="${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.sql ${BASE_PATH}/application/files ${BASE_PATH}/packages"
    DO_BACKUP="yes"
    NO_OPTION="0"
elif [ "$1" = "--database" ] || [ "$1" = "-d" ]; then
    echo "c5 Upgrade: You've chosen the DATABASE backup option. Now we're only backing up the SQL file before upgrading concrete5."
    ZIP_OPTION="${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.sql"
    DO_BACKUP="yes"
    NO_OPTION="0"
elif [ "$1" = "--file" ] || [ "$1" = "--files" ] || [ "$1" = "-f" ] || [ "$1" = "" ]; then
    echo "c5 Upgrade: You've chosen the DEFAULT FILE option. Now we're backing up the SQL and application/files before upgrading concrete5."
    ZIP_OPTION="${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.sql ${BASE_PATH}/application/files"
    NO_OPTION="0"
    DO_BACKUP="yes"
elif [ "$1" = "--no-backup" ] || [ "$1" = "-n" ]; then
    echo "c5 Upgrade: You've chosen not to backup concrete5. It will only be upgrading concrete5 site."
    DO_BACKUP="no"
    NO_OPTION="0"
elif [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "
    ====================
    c5 Upgrade: Options
    ====================
    --------------------
    First Option
    --------------------
    --no-backup OR -n: Do not backup the concrete5 and proceed to upgrade.
    --files OR --file OR -f: back up a SQL and the files in application/files. This is DEFAULT OPTION.
    --all OR -a: back up a SQL and all files under WHERE_IS_CONCRETE5 path
    --database OR -d: back up only a SQL dump
    --packages OR --package OR -p: back up a SQL, and the files in application/files, packages/
    --help OR -h: This help option.
    --------------------
    Second Option
    --------------------
    -n OR --do-not-delete: This is default option. Don't delete '${CONCRETE5_WORKING_DIRECTORY_NAME}' folder
    -d OR --delete: Delete '${CONCRETE5_WORKING_DIRECTORY_NAME}' where it stored old concrete, languages and other remaining files
    
    * Second option is optional. You must specify 1st option if you want to specify 2nd option.
    --------------------
    Third Option
    --------------------
    -r OR --run-upgrade: This is default option. Run upgrade script. (Only version 8.0.0 and later)
    -n OR --no-upgrade: It won't run upgrade script.

    * Third option is optional. You must specify 1st and 2nd options if you want to specify 3rd option.
    --------------------
    Forth Option
    --------------------
    -r OR --relative: This is default option. You can leave this option blank
    -a OR --absolute: The script will execute using absolute path. Zip file may contain the folder structure

    * Forth option is optional. You must specify 1st, 2nd and 3rd options if you want to specify 4th option.
    ====================
    
    Have a good day! from katzueno.com
"
    exit
else
    NO_OPTION="1"
fi

if [ "$NO_OPTION" = "1" ] || [ "$NO_2nd_OPTION" = "1" ] || [ "$NO_3rd_OPTION" = "1" ] || [ "$NO_4th_OPTION" = "1" ]; then
    echo "c5 Upgrade ERROR: You specified WRONG OPTION. Please try 'sh backup.sh -h' for the available options."
    echo "c5 Upgrade ERROR: Wrong Option: ${NO_OPTION}"
    echo "c5 Upgrade ERROR: Option 2(${NO_2nd_OPTION}), 3(${NO_3rd_OPTION}), 4(${NO_4th_OPTION})"
    exit
fi


# ==============================
#
# EXECUSION
#
# ==============================

# ---- Starting shell -----
echo "                                     #|         ##HH|| ";
echo " #HH|  #H|  ##H|   #HH| ## H|  #H|  ##HH|  #H|  ##     ";
echo "##    ## H| ## H| ##    ##H|  ##HH|  #|   ##HH| ##HH|  ";
echo "##    ## H| ## H| ##    ##    ##     #|   ##        || ";
echo " #HH|  #H|  ## H|  #HH| ##     #HH|  #H|   #HH| ##HH|  ";
echo "                                                       ";
echo "                                 H|                    ";
echo "## H| ##H|   #HH| ## H| ##|      H|  #H|               ";
echo "## H| ## H| ## H| ##H|    H|   #HH| ##HH|              ";
echo "## H| ##H|   #HH| ##    ##H|  ## H| ##                 ";
echo " #HH| ##       H| ##    ##HH|  #HH|  #HH|              ";
echo "      ##    ##H|                                       ";
echo "============================="
echo "c5 Upgrade: USE IT AT YOUR OWN RISK!"
echo "============================="
echo "c5 Upgrade:"

# ------------------------------
# Backup function
# ------------------------------
concrete5_backup () {
echo "c5 Upgrade:"
echo "c5 Upgrade: Back up option is enabled, we're now backing up your concrete5 site."
echo "c5 Upgrade:"
echo "c5 Upgrade: ========================================"
echo "c5 Upgrade:           BACKING UP concrete5 Now"
echo "c5 Upgrade: ========================================"
echo "c5 Upgrade:"
echo "c5 Upgrade: You may need to enter your MySQL password."
echo "c5 Upgrade: ZIP OPTION: ${ZIP_OPTION}"

# ---- Checking Variable -----
echo "c5 Backup: Checking variables..."
if [ -z "$WHERE_TO_SAVE" ] || [ "$WHERE_TO_SAVE" = " " ]; then
    echo "c5 Backup ERROR: WHERE_TO_SAVE variable is not set"
    exit
fi
if [ -z "$WHERE_IS_CONCRETE5" ] || [ "$WHERE_IS_CONCRETE5" = " " ]; then
    echo "c5 Backup ERROR: WHERE_IS_CONCRETE5 variable is not set"
    exit
fi
if [ -z "$NOW_TIME" ] || [ "$NOW_TIME" = " " ]; then
    echo "c5 Backup ERROR: NOW_TIME variable is not set"
    exit
fi
if [ -z "$MYSQL_SERVER" ] || [ "$MYSQL_SERVER" = " " ]; then
    echo "c5 Backup ERROR: MYSQL_SERVER variable is not set"
    exit
fi
if [ -z "$MYSQL_USER" ] || [ "$MYSQL_USER" = " " ]; then
    echo "c5 Backup ERROR: MYSQL_USER variable is not set"
    exit
fi
if [ -z "$MYSQL_NAME" ] || [ "$MYSQL_NAME" = " " ]; then
    echo "c5 Backup ERROR: MYSQL_NAME variable is not set"
    exit
fi

echo "c5 Upgrade: Starting concrete5 backup..."

# ---- Executing the commands -----
echo "c5 Backup: Switching current directory to"
echo "${WHERE_IS_CONCRETE5}"
cd ${WHERE_IS_CONCRETE5}
echo "c5 Backup: Executing MySQL Dump..."

if [ -n "$MYSQL_PASSWORD" ]; then
    set +e
        echo "mysqldump -h ${MYSQL_SERVER} -u ${MYSQL_USER} --password=[PASSWORD] --single-transaction --default-character-set=utf8 ${MYSQL_NAME} > ${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.sql"
        mysqldump -h "${MYSQL_SERVER}" -u "${MYSQL_USER}" --password="${MYSQL_PASSWORD}" --single-transaction --default-character-set=utf8 "${MYSQL_NAME}" > "${BASE_PATH}"/"${FILE_NAME}"_"${NOW_TIME}".sql
    ret=$?
    if [ "$ret" = 0 ]; then
        echo ""
        echo "c5 Backup: MySQL Database was dumped successfully."
    else
        echo "c5 Backup: ERROR: MySQL password failed. You must type MySQL password manually. OR hit ENTER if you want to stop this script now."
        set -e
        echo "mysqldump -h ${MYSQL_SERVER} -u ${MYSQL_USER} -p --single-transaction --default-character-set=utf8 ${MYSQL_NAME} > ${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.sql"
        mysqldump -h "${MYSQL_SERVER}" -u "${MYSQL_USER}" -p --single-transaction --default-character-set=utf8 "${MYSQL_NAME}" > "${BASE_PATH}"/"${FILE_NAME}"_"${NOW_TIME}".sql
    fi
    set -e
else
    echo "c5 Backup: Enter the MySQL password..."
    mysqldump -h "${MYSQL_SERVER}" -u "${MYSQL_USER}" -p --single-transaction --default-character-set=utf8 "${MYSQL_NAME}" > "${BASE_PATH}"/"${FILE_NAME}"_"${NOW_TIME}".sql
fi

echo "c5 Backup: Now zipping files..."
echo "c5 Backup: zip -r ${BASE_PATH}/${FILE_NAME}_${NOW_TIME}.zip ${ZIP_OPTION}"
zip -r "${BASE_PATH}"/"${FILE_NAME}"_"${NOW_TIME}".zip "${ZIP_OPTION}"
# tar cfz "${BASE_PATH}"/"${FILE_NAME}"_"${NOW_TIME}".tar "${ZIP_OPTION}"

echo "c5 Backup: Now removing SQL dump file..."
rm -f "${BASE_PATH}"/"${FILE_NAME}"_"${NOW_TIME}".sql

echo "c5 Backup: Now moving the backup file(s) to the final destination..."
echo "${WHERE_TO_SAVE}"
mv "${BASE_PATH}"/"${FILE_NAME}"_"${NOW_TIME}".zip "${WHERE_TO_SAVE}"
# mv "${BASE_PATH}"/"${FILE_NAME}"_"${NOW_TIME}".tar "${WHERE_TO_SAVE}"

echo "c5 Backup: Completed!"
}

# ------------------------------
# BACKUP SCRIPT
# ------------------------------

# Backup condition starts here

if [ "$DO_BACKUP" = "yes" ]; then
    concrete5_backup
elif [ "$DO_BACKUP" = "no" ]; then
    echo "c5 Upgrade: We're skipping the backup process. Proceeding to upgrade process."
else
    echo "c5 Upgrade: There is something wrong during backup process. Exiting the script."
    exit
fi
# Backup condition ends here


# ------------------------------
# Obtain and placing upgrade files
# ------------------------------

echo "c5 Upgrade:"
echo "c5 Upgrade: ========================================"
echo "c5 Upgrade: NOW PLACING concrete5 new core & lang files"
echo "c5 Upgrade: ========================================"
echo "c5 Upgrade:"
echo "c5 Upgrade: Switching current directory to"
echo "${WHERE_IS_CONCRETE5}"
cd ${WHERE_IS_CONCRETE5}
echo "c5 Upgrade: Creating a working concrete5 directory: ${CONCRETE5_WORKING_DIRECTORY_NAME}"
mkdir ${BASE_PATH}/${CONCRETE5_WORKING_DIRECTORY_NAME}
echo "c5 Upgrade: Switching to inside of concrete5 directory"
cd ${BASE_PATH}/${CONCRETE5_WORKING_DIRECTORY_NAME}

if [ "$BASE_PATH" = "." ]; then
    BASE_PATH_NEW_VERSION="${BASE_PATH}"
else
    BASE_PATH_NEW_VERSION="${BASE_PATH}/${CONCRETE5_WORKING_DIRECTORY_NAME}"
fi
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

if [ "$BASE_PATH" = "." ]; then
    BASE_PATH_APPLICATION="${BASE_PATH}"
else
    BASE_PATH_APPLICATION="${BASE_PATH}/application"
fi
echo "c5 Upgrade:..."
echo "c5 Upgrade: BASE_PATH_APPLICATION is: ${BASE_PATH_APPLICATION} (for debug purpose)"
echo "c5 Upgrade:..."

echo "c5 Upgrade: Moving old 'languages' folder to inside of '${CONCRETE5_WORKING_DIRECTORY_NAME}' folder as 'languages_old' folder"
echo "mv ${BASE_PATH_APPLICATION}/languages ${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}/languages_old"
mv ${BASE_PATH_APPLICATION}/languages ${WHERE_IS_CONCRETE5}/${CONCRETE5_WORKING_DIRECTORY_NAME}/languages_old
echo "c5 Upgrade: Renaming 'languages_new' folder to 'languages' folder"
echo "mv ${BASE_PATH_APPLICATION}/languages_new mv ${BASE_PATH_APPLICATION}/languages"
mv ${BASE_PATH_APPLICATION}/languages_new ${BASE_PATH_APPLICATION}/languages

echo "c5 Upgrade: Switching to concrete5 root folder"
cd ${WHERE_IS_CONCRETE5}
echo "c5 Upgrade: Moving concrete5 core folder to '/${CONCRETE5_WORKING_DIRECTORY_NAME}/concrete_old'"
mv ${BASE_PATH}/concrete ${BASE_PATH}/${CONCRETE5_WORKING_DIRECTORY_NAME}/concrete_old
echo "c5 Upgrade: Renaming 'concrete_new' core folder to 'concrete'"
mv ${BASE_PATH}/concrete5_new ${BASE_PATH}/concrete
echo "c5 Upgrade: ..."
echo "c5 Upgrade: ..."

# ------------------------------
# UPGRADES
# ------------------------------

if [ "$RUN_UPGRADE" = "yes" ]; then
    echo "c5 Upgrade: ========================================"
    echo "c5 Upgrade:           UPGRADING concrete5 Now"
    echo "c5 Upgrade: ========================================"
    echo "c5 Upgrade: If you're using concrete5.7.x, you will have to either"
    echo "c5 Upgrade: - Enable core update option, or"
    echo "c5 Upgrade: - visit [concrete5]/index.php/ccm/system/upgrade to execute upgrade"
    echo "c5 Upgrade: ..."
    echo "c5 Upgrade: ..."
    echo "c5 Upgrade: Executing Upgrade (Version 8 and above)"
    echo "c5 Upgrade: Making sure that CLI is executable"
    chmod u+x ${BASE_PATH}/concrete/bin/concrete5
    echo "c5 Upgrade: Now running upgrade script"
    ${BASE_PATH}/concrete/bin/concrete5 c5:update
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

echo "c5 Upgrade: ..."
echo "c5 Upgrade: ..."
echo "c5 Upgrade: ..."
echo "c5 Upgrade: Upgrade process completed!"
