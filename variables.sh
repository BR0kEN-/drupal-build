#!/usr/bin/env bash

# All presented variables can be overridden in "*.preinstall" hook file.

# Will skip all installation questions.
y=false
# Weather of "drush site-install" operation.
no_si=false
# Weather of "drush make" operation.
no_make=false
# Do not use the "drush pm-download" caching.
no_cache=false
# Indicates installation for development. For example, you can perform some
# operations in "preinstall" or "postinstall" hooks using conditions with
# this variable.
local_copy=false
# Do not put CSS under VCS (generate rule in .gitignore).
ignore_themes_css=true

# Name of *.make file.
make=""
# Installation profile name.
profile=""
# The name of database for a project.
db=""
# Permitted user for work with DB.
user=""
# Password from an account of DB user.
pass=""
# Database host.
host="localhost"
# Database driver.
driver="mysql"

# Project location. You able to use relative or absolute paths. Directory must
# contain the "*.make" file and subfolder with Drupal (set in "docroot_name").
path=""
# Human name of the project (site).
site_name=""
# Name for Drupal administrative account.
account_name="admin"
# Name of subfolder with Drupal sources.
docroot_name="drupal"

# URL for "git clone".
git=""
# Git branch for clone with.
branch="master"
