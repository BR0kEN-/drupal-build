#!/usr/bin/env bash

# Dependencies:
# - Drush >= 6.0
# - Bash >= 3.0
#
# Building the site from remote repository:
# - Git >= 1.7

# ==============================================================================
# The script assumes no benefit if the parameters "--no-make" and "--no-si"
# specified together.
if ${no_si} && ${no_make}; then
    status_message "You cannot execute script with \"--no-si\" and \"--no-make\". Only one parameter allowed." error
fi

# ==============================================================================
# Set installation directory to current if it does no specified.
if [ -z "${path}" ]; then
    if ask "The \"--path\" parameter does not specified. Would you like to start installation in current directory?"; then
        path=`pwd`
    else
        status_message "Installation cannot be completed while script does not know where it will be." error
    fi
else
    readonly dir=${path}
    path=`cd ${dir} > /dev/null 2>&1 && pwd`

    if [ $? -gt 0 ]; then
        if ask "Directory \"${dir}\" does not exist. Would you like to create it?"; then
            path=`get_full_path ${dir}`

            mkdir ${path}
        else
            status_message "Cannot start installation in non-existent directory." error
        fi
    fi
fi

if ${y}; then
    agree="--yes"
fi

# ==============================================================================
# Building the site from remote repository.
if [ ! -z "${git}" ]; then
    chech_global_utility "git --version:Git"

    # If we've got the code from a repository, then we'll cannot perform
    # the operation without running a "drush make".
    if ${no_make}; then
        if ask "You are attempting to get the code from remote repository. Due to that, you should renounce the usage of a \"--no-make\" parameter, because the build system does not know which data will be obtained and cannot analyze their in advance."; then
            no_make=false
        else
            status_message "An installation cannot be extended with usage of unknown data." error
        fi
    fi

    if [[ `ls -A ${path}` ]]; then
        # If directory is not empty, then we clean it and clone the repo.
        if ask "Installation directory is not empty. Do you really want to remove all data from ${path} directory and initialize project there?"; then
            # Make an installation directory accessible.
            chmod -R 777 ${path}
            # Go to parent catalog.
            cd ${path%/*}
            # Remove an installation directory for successful cloning via Git.
            rm -rf ${path}
        else
            status_message "Could not clone repository to a non-empty directory." error
        fi
    fi

    git clone -b ${branch} ${git} ${path}
    catch_last_error "Cannot clone from remote repository: ${path}"
fi

readonly path agree git branch no_make no_si y

cd ${path}

# ==============================================================================
# Define a profile name by the ".make" file name.
silent_execution "ls -A ${path}/*.make"
catch_last_error "Cannot find the \".make\" file. Installation cannot be completed."

readonly _makefile=`ls -A ${path}/*.make | head -1`
readonly _profile=`basename ${_makefile%.*}`

# ==============================================================================
# Set default DB driver to MySQL and allow to use the PgSQL.
if [ ! -z "${pgsql}" ]; then
    driver="pgsql"
fi

# ==============================================================================
# If "--site-name" parameter was not defined, then set it to profile name.
if [ -z "${site_name}" ]; then
    site_name=${_profile}
fi

# ==============================================================================
# Temporary folder for store code during installation.
readonly _tmp_path=${path}/tmp

# ==============================================================================
# Path to "sites/default" in temporary folder.
readonly _tmp_sites_default=${_tmp_path}/sites/default

# ==============================================================================
# Drupal root directory.
readonly _drupal_path=${path}/${docroot_name}

# ==============================================================================
# Profiles path relative to a Drupal root folder.
readonly _profile_relative_path=profiles/${_profile}

# ==============================================================================
# Path to installation profile relative to Drupal root directory.
readonly _profile_path=${_drupal_path}/${_profile_relative_path}

# ==============================================================================
# Absolute path to "sites/default" folder in Drupal root directory.
readonly _sites_default_path=${_drupal_path}/sites/default

# ==============================================================================
# Absolute path to "sites/default/settings.php" file.
readonly _default_settings_file=${_sites_default_path}/settings.php

# ==============================================================================
# Check existence of the profile directory and ".info" file inside.
if [[ ! -d "${_profile_path}" || ! -f "${_profile_path}/${_profile}.info" ]]; then
    status_message "An installation profile \"${_profile}\" does not exist." error
fi

# ==============================================================================
# Include ".preinstall" Bash file.
_hook_installation ${path} ${_profile} preinstall

_default_settings_file_exist=false

# Create temporary folder for store files during installation process.
if [ -d "${_tmp_path}" ]; then
    chmod -R 777 ${_tmp_path}
    rm -rf ${_tmp_path}
fi

mkdir ${_tmp_path}

if ${no_make}; then
    if [ -f "${_default_settings_file}" ]; then
        mkdir -p ${_tmp_sites_default}
        cp ${_default_settings_file} ${_tmp_sites_default}

        _default_settings_file_exist=true
    fi
else
    # Remove site root folder for successfull installation via Drush.
    chmod -R 777 ${_drupal_path}
    rm -rf ${_drupal_path}

    # Run execution of the makefile.
    drush make ${_makefile} --working-copy --contrib-destination=${_profile_relative_path} ${_drupal_path} ${agree}
    catch_last_error "The build cannot be completed because something cannot to be downloaded or patched."

    git checkout ${_drupal_path}

    # Generate the ".gitignore".
    echo "# ==============================================================================
# DO NOT MODIFY THIS FILE, because it is does not placed under version control
# system. All directives, that was written below, cover your development
# process and allow you to put under VCS only your own code.
# ==============================================================================
# This file was automatically generated by \"drupal-builder\" script.
# GitHub: https://github.com/BR0kEN-/drupal-builder
/*
!*.md
!composer.json
!${_profile}.make
!${_profile}.preinstall
!${_profile}.postinstall
!${docroot_name}/
!behat/
!scripts/

# Do not ignore \"profiles\" and \"drush\" folders in document root.
${docroot_name}/*
!${docroot_name}/drush/
!${docroot_name}/profiles/

# Do not ignore \"${_profile_relative_path}\" folder in document root,
# because it is our main Drupal installation profile.
${docroot_name}/profiles/*
!${docroot_name}/${_profile_relative_path}/

# Ignore all files and folders, which located in \"contrib\" subdirectories
# in the \"${_profile}\" profile.
#
# For example, a module \"Administration menu\", that located in
# \"${docroot_name}/${_profile_relative_path}/modules/contrib/admin_menu\", will be ignored.
${docroot_name}/${_profile_relative_path}/*/contrib

# Do not ignore \"sites\" folder, but ignore all data from it.
!drupal/sites/
drupal/sites/*

# Do not ignore \"sites/<SUBSITE>\" folder, but ignore all data from it.
!drupal/sites/*/
drupal/sites/*/*

# Do not ignore any folders in \"sites/<SUBSITE>\" folder, but ignore all
# data from it.
!drupal/sites/*/*/
drupal/sites/*/*/*

# Do not ignore custom modules and themes in subsite directories.
!drupal/sites/*/*/custom

# Do not ignore site settings and multi domain settings.
!drupal/sites/*/settings.php
!drupal/sites/sites.php

# Ignore all files that start with \".\", except \".htaccess\".
.*
!drupal/.htaccess

# Ignore all files that start with \"~\".
~*

# Ignore the custom Behat configurations.
*.behat.yml" > ${path}/.gitignore
fi

# Remove temporary folder.
rm -rf ${_tmp_path}

drush_cc drush

cd ${_drupal_path}

# Remove default ".gitignore".
if [ -f ".gitignore" ]; then
    rm .gitignore
fi

if ! ${no_si}; then
    # Check that DB credentials was specified.
    for i in "db:name of" "user:username for" "pass:password for"; do
        var=${i%:*}
        string=${i#*:}

        if [ -z "${!var}" ]; then
            declare "${var}"=`user_input "The ${string} database was not specified in \"--${var}\" parameter. Type it"`
        fi

        if [ -z "${!var}" ]; then
            status_message "You are not specified the ${string} database." error
        fi
    done

    # Remove settings and tell to Drupal that it is not already installed.
    # https://www.drupal.org/node/1308308
    if ${_default_settings_file_exist}; then
        rm ${_default_settings_file}
    fi

    # Start site installation.
    drush si ${_profile} --db-url="${driver}://${user}:${pass}@${host}/${db}" --account-name="${account_name}" --site-name="${site_name}" ${agree}

    if ${_default_settings_file_exist}; then
        # Move "settings.php" file after installation process, because it will
        # not be original.
        chmod -R 755 ${_sites_default_path}
        mv ${_tmp_sites_default}/settings.php ${_sites_default_path}
    fi
fi

# ==============================================================================
# Include ".postinstall" Bash file.
_hook_installation ${path} ${_profile} postinstall
