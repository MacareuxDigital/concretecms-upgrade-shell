# Concrete CMS Core Upgrade Shell:

This is simple shell script to upgrade your Concrete CMS (formerly concrete5) site overriding the core "concrete" directory.
This is suitable for someone who don't want to pile up Concrete CMS versions in "update" directory.

Since you're using GitHub, I assume you know what you're doing. This is the script that runs on your server.

This upgrade script supports Ver 8.0.0 and above.

It's no longer supporting 5.7.x. If you would like 5.7.x support, please use Version 0.3 and earlier.

# Features

- Execute Concrete CMS upgrade & update languages via shell
- Enable/Disable maintenance mode
- Backup dababase
- Backup database & copy it to backup database
- Or import database to backup database

# How to run

## Initialize

Enter the necessary server's info and database info.

### Required Variable

The following variables are required to fill

- `WHERE_IS_CONCRETE5`: the full server path of where Concrete CMS lives

### Semi-required Variable

- `DO_SUDO`: If web server is running as apache/nginx user rather than your SSH log-in user, you must set sudo prefix command
- `USER_PERMISSIONS`: If `DO_SUDO` variable is entered, you must set USER_PERMISSION. This shell will chown files, language, and concrete folders.

### Optional Variables

#### For Main Database Backup

This script has a feature back up your Concrete CMS database dump and files. If you want to use this feature, you must fill out the following variables

- `PROJECT_NAME`: This will become the prefix of your back-up files
- `WHERE_TO_SAVE`: The server full path of where to save the backup files
- `MYSQL_CHARASET`: Enter the database's character collation. If it's later than 8.5.0, it's usually `utf8mb4`. If it's old database, it's usually `utf8`.
- `PROD_DB_*`: Enter your main Concrete CMS database info such as host address, db username, db password, database name, and port.
    - Read commend carefully regarding tablespace for MySQL engine.

#### For Backup Database

This is intended to copy production database to backup database.
If production database backup failed, you can quickly point to this backup database.

- `USE_IMPORT_FILE` & `IMPORT_FILE` : True/False, then enter the full server path of SQL dump. We have this option to import additional SQL from server. You may want to import and debug from backup.
- `BACKUP_DB_*`: Enter your backup Concrete CMS database info such as host address, db username, db password, database name, and port.
    - Read commend carefully regarding tablespace for MySQL engine.

#### C5_Version & CONCRETE5_PACKAGE_DOWNLOAD

This script let you run without any option, if you do so, it will fetch the set Concrete CMS version.
If you want to change it to older version, change it accordingly.

## How to run

Obtain your desired Concrete CMS version and Download URL.

For legacy (newer) versions, visit [Concrete CMS website](https://marketplace.concretecms.com/developers/developer-downloads) and get download URL.

```
sh concrete5-upgrade.sh [Concrete CMS version] [ZIP Download URL]
```

In case of 8.5.6

```
sh concrete5-upgrade.sh 8.5.6 https://www.concretecms.com/download_file/61dab82f-fb01-47bc-8cf1-deffff890224
```

Enter the option that you would like to execute.

Wait until the commands finish processing.

# Version History

Version | Updates
----|----------
2.0 | - Enable/Disable Maintenance Mode<br>- New config & database backup option<br>- Change from wget to curl<br>- Bug fix: Was unable to run the script with no option<br>- Readme
1.0 | Drop Concrete CMS support for 5.7 and earlier version
0.3 | Ability to specify different Concrete CMS version and download zip by command


# MIT LICENSE and NO GUARANTEE

This script is licensed under The MIT License. **USE IT AT YOUR OWN RISK.**

# Legacy version

If you would like legacy version of 5.6 & earlier, visit the `legacy` branch
https://github.com/concrete5cojp/concrete5-upgrade-shell/tree/legacy
