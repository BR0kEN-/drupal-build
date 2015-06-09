#!/usr/bin/env bash

_doc_param()
{
    local param="--${1}"

    if [ ! "${2}" ]; then
        param+="=*"
    fi

    status_message ${param} success true
}

_doc_yellow()
{
    status_message "${1}" warning true
}

_doc_blue()
{
    status_message "${1}" status true
}

echo "
  ██████╗ ██████╗ ██╗   ██╗██████╗  █████╗ ██╗         ██████╗ ██╗   ██╗██╗██╗     ██████╗ ███████╗██████╗
  ██╔══██╗██╔══██╗██║   ██║██╔══██╗██╔══██╗██║         ██╔══██╗██║   ██║██║██║     ██╔══██╗██╔════╝██╔══██╗
  ██║  ██║██████╔╝██║   ██║██████╔╝███████║██║         ██████╔╝██║   ██║██║██║     ██║  ██║█████╗  ██████╔╝
  ██║  ██║██╔══██╗██║   ██║██╔═══╝ ██╔══██║██║         ██╔══██╗██║   ██║██║██║     ██║  ██║██╔══╝  ██╔══██╗
  ██████╔╝██║  ██║╚██████╔╝██║     ██║  ██║███████╗    ██████╔╝╚██████╔╝██║███████╗██████╔╝███████╗██║  ██║
  ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝╚══════╝    ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝  ╚═╝

  `_doc_yellow "Database parameters:"`
    `_doc_param db`
      Databse name. Will be asked to input if not specified.
    `_doc_param user`
      Databse user. Will be asked to input if not specified.
    `_doc_param pass`
      Database password. Will be asked to input if not specified.
    `_doc_param host`
       Databse host. By default set to `_doc_blue localhost`.
    `_doc_param pgsql true`
       Set the database driver to `_doc_blue pgsql`. If not specified, `_doc_blue mysql` will be used.

  `_doc_yellow "Drupal installation configuration:"`
    `_doc_param path`
       Path, where Drupal site will be built. If not specified, then
       script ask you for building in a current directory.
    `_doc_param site-name`
       Human name of a project. By default will be set to profile name.
    `_doc_param account-name`
       Username for an administrator. By default set to `_doc_blue admin`.
    `_doc_param git`
       URL of remote Git repository from which project will be cloned.
    `_doc_param branch`
       Git branch for cloning the code. Will be used only if the `_doc_blue git`
       parameter specified. By default set to `_doc_blue master`.
    `_doc_param docroot-name`
       Name of a directory, in which will be located root directory of
       a Drupal project. By default is set to `_doc_blue drupal`.

  `_doc_yellow "Other:"`
    `_doc_param no-cache true`
       Do not use the \"drush pm-download\" caching.
    `_doc_param no-make true`
       Do not execute a \"drush make\" and perform only `_doc_blue "drush si"`.
    `_doc_param no-si true`
       Do not execute a \"drush si\" and perform only `_doc_blue "drush make"`.
    `_doc_param y true`
       Will give positive answer on all installation questions.

  `_doc_yellow "Examples:"`
    `_doc_blue "./bin/drupal-builder --db=test --user=test --pass=test --site-name=New project"`
    `_doc_blue "./bin/drupal-builder --git=git://git.example.com/project.git"`
    `_doc_blue "./bin/drupal-builder --no-si"`
"
