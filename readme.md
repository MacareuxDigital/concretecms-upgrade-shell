# concrete5 Core Upgrade Shell:

This is simple shell script to upgrade your concrete5 site overriding the core "concrete" directory.
This is suitable for someone who don't want to pile up concrete5 versions in "update" directory.

Since you're using GitHub, I assume you know what you're doing. This is the script that runs on your server.

This upgrade script supports Ver 8.0.0 and above fully, and 5.7.x partially


# MIT LICENSE and NO GUARANTEE

This script is licensed under The MIT License. **USE IT AT YOUR OWN RISK.**

# Video Tutorial

Video tutorial is available on YouTube

**English**

https://youtu.be/QTntnUkI5z0

[![concrete5 Upgrade Shell Script](https://img.youtube.com/vi/QTntnUkI5z0/0.jpg)](https://youtu.be/QTntnUkI5z0)

**日本語**

https://youtu.be/zsvnwtnm7_c


[![concrete5 アップグレードシェルスクリプト](https://img.youtube.com/vi/zsvnwtnm7_c/0.jpg)](https://youtu.be/zsvnwtnm7_c)


# Target

- Someone who's concrete5 site owners who runs many concrete5 sites.
- Someone who's using the servers that accepts SSH access.
- Someone who also runs concrete5 development site and test upgrade before running actual upgrade.
- Someone who has an idea of what this shell script does for you automatically, and know how dangerous this site could be.

# Credit & Contact

Katz Ueno (concrete5 Japan, Inc)

http://katzueno.com/

http://concrete5.co.jp

Please feel free to create an issue or send me a pull request.
Your feedback is always welcome!

Yes, we use this script to maintain our customers site at dedicated servers and cloud servers such as AWS.

We are one of the Amazon Web Services APN Technology Partners.

# Future Plan

- I would like your feedback.

# Version History

## 0.9 (December 15, 2016)

Release

# Set-up

You need to have the server that allows to run the shell script.

1. Obtain the shell script from GitHub. [https://github.com/katzueno/concrete5-upgrade-shell](https://github.com/katzueno/concrete5-upgrade-shell) Or [Click here to download zip file](https://github.com/katzueno/concrete5-upgrade-shell/archive/master.zip).
1. BACK UP YOUR concrete5 SITE, I highly recommend you to use the backup option. If you're interested in backup only option, you can check out my [concrete5 Backup Shell](https://github.com/katzueno/concrete5-backup-shell)
1. Add your server config in `concrete5-upgrade.sh`
1. Upload the `concrete5-upgrade.sh` to your server
1. Change the file permission `chmod 700 concrete5-upgrade.sh` Or whatever the permission you need to execute the file. But make sure to minimize the permission.

It's highly advised that you know what you're doing with this script. You MUST have certain amount of knowledge of what shell script is.

## CAUTION: Do upgrade test before you apply this to the live production site.

This script first save the SQL dump file onto concrete5 directory. If the script fails, it may leave the SQL file under the server. MAKE SURE to check the server occasionally.

I highly recommend that you make the duplicate of your concrete5 site somewhere else to do test upgrade. This script is making you easy to test upgrade. Why not do it now!?

## CAUTION: For concrete5.7.x sites

YOU MUST SPECIFY 1st, 2nd and 3rd option, and you must choose `-n` or `--no-upgrade` option.

If you're using concrete5.7.x, it cannot run upgrade from shell. You will need to run upgrade manually. You may want to change your concrete5 config to allow auto update core option.

- Create a text file `application/config/concrete.php` if you haven't done so.
- Place the following code onto the text file.
- OR you could use the text file that I prepare under /config/concrete.php
- Upload the file onto your concrete5 and make sure that you don't generate any error.

```
<?php
return array(
    'updates' => array(
        'enable_auto_update_core' => true
    ),
);
```

You may already made the concrete.php and enter another config setting, just place updates option accordingly.

# How to Run and Options

At default, you still need to enter the MySQL Password.

## Format

```
cd path/to/shell/file
sh concrete5-upgrade.sh [1st option] [2nd option] [3rd option] [4th option]
```

## Example

```
cd /var/www/html
sh concrete5-upgrade.sh --all --do-not-delete --run-upgrade --relative
```

## 1st Option: Backup option

1st option will determine if you want to back up concrete5 before upgrading

### No backup

- -n
- --no-backup

### FILES option (default)

back up a SQL and the files in application/files

- [no option]
- --files
- --file
- -f

### DATABASE option

back up only a SQL dump file under WHERE_IS_CONCRETE5 path

- --database
- -d

### ALL file option

back up a SQL and all files under WHERE_IS_CONCRETE5 path
- --all
- -a

### PACKAGE option

back up a SQL, and the files in application/files, packages/

- --packages 
- --package
- -p

### HELP option

Shows all the help options.

- --help
- -h

## 2nd Option: Keep older version and working file?

You MUST specify 1st option if you want to specify 2nd option.

When running this shell script, it will create `concrete5_upgrade_working` (default value) directory and save all upgrade related and store older version concrete5 core and language files.

At the end of the process, you can choose to keep or delete those directories.

### Keep directory (default)

- [no option]
- -n
- --do-not-delete


### Delete working directory

- -d
- --delete

## 3rd Option: Run upgrade script or not

You MUST specify 1st and 2nd option if you want to specify 3rd option.

At the end of the process, it will run concrete5 upgrade command from concrete5 command line tool.

HOWEVER, this upgrade command is only available from Version 8.0.0.

You should disable the option. OTHERWISE, the upgrade process will stop before

### Run upgrade command

- [no option]
- -r
- --run-upgrade

### Don't run upgrade command (must choose this option for concrete5.7.x)

- -n
- --no-upgrade


## 4th Option: Relative or Absolute Path to use

You MUST specify 1st~3rd option if you want to specify 4th option.

4th option determine if you need to work as absolute path or relative path. A Mac OS User reported that they need to be specify absolute path. You may need to use the ABSOLUTE option if you're running this as a cron job.


### RELATIVE option (default) 

The shell runs relative path.

- [default]
- -r
- --relative

### ABSOLUTE option

The shell always use absolute path when dumping and zipping files. 

- -a
- --absolute

# VARIABLES TO SET

Once you download the sh file, you must change the where VARIABLES are from line 15

## NOW_TIME

Default:`date "+%Y%m%d%H%M%S"`

It would add current year, month, date, hour, and seconds to the backup files.

For example, if you think you don't want to put all the minutes and second, remove `%M%S`.


## WHERE_IS_CONCRETE5

Enter the full server path of where your concrete5 site is installed

e.g.
`WHERE_IS_CONCRETE5="/var/www/html/concrete5"`


## CONCRETE5_PACKAGE_DOWNLOAD

Enter the URL of concrete5 zip package URL from concrete5.org

e.g.
`CONCRETE5_DOWNLOAD="http://www.concrete5.org/download_file/-/view/92910/"`

## CONCRETE5_PACKAGE_FOLDER_NAME

Enter the name of the folder name that concrete5 zip file.
It's usually like "concrete5-8.X.X" or "concrete5.7.X.X".

e.g.
`CONCRETE5_VERSION="concrete5-8.0.2"`

## WHERE_TO_SAVE_BKUP

Enter the server full path where you want to save your backup files to.

e.g.
`WHERE_TO_SAVE_BKUP="/var/www/html/backup"`

HINT: If you don't know where to find, use "pwd" command to find your current location of the server to find the full path of the server.

## WHERE_TO_SAVE_TEMP

Default: `/var/www/html/concrete5_upgrade_working`

The shell script will create the working directory to store zip file, older concrete5 core and language files.
You can change the working folder name.

e.g.
`WHERE_TO_SAVE_TEMP="/var/www/html/concrete5_upgrade_working"`

## FILE_NAME

Enter the identical file name. This will be the prefix of your file.

e.g.
`FILE_NAME="katzueno"`

## MYSQL_SERVER

Enter the MySQL server address.

e.g.
`MYSQL_SERVER="localhost"`

## MYSQL_NAME

Enter the name of your MySQL database.

e.g.
`MYSQL_NAME="database"`

## MYSQL_USER

Enter the MySQL username

e.g.
`MYSQL_USER="root"`


## MYSQL_PASSWORD (Option)

If you don't want to enter the password every time, uncomment the MYSQL_PASSWORD and enter the MySQL password.

e.g.
`MYSQL_PASSWORD="root"`


# Special Thanks

https://www.shellcheck.net/

[http://patorjk.com/software/taag/](http://patorjk.com/software/taag/#p=display&h=0&c=echo&f=Slide&t=concrete5%0Aupgrade)

