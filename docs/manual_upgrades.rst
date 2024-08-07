Manual upgrade instructions
###########################

Occasionally there is a change to devstack that requires existing devstack installations to be manually upgraded. When this happens, instructions should be added here.

Please add new instructions to the top, include a date, and make a post in the `Devstack forum <https://discuss.openedx.org/tags/c/development/11/devstack>`_.

(If you just need to update your devstack to the latest version of everything, see :any:`updating devstack`.)

2024-06-13 - Upgrade from Python 3.8 to 3.11
********************************************

As part of the Python upgrade in edx-platform, some manual steps are required for the Python 3.11 upgrade to allow you to pull Python dependencies.

1. Take latest ``git pull`` of ``devstack``

2. Take the latest pull of images::

    make dev.pull.without-deps.lms+cms

2024-04-29 - Moved Open edX analytics repositories
**************************************************

Several repositories were being deprecated by Open edX (`issue #227 <https://github.com/openedx/public-engineering/issues/227>`_).
We are forking some of those repositories to keep maintaining them.

If you use any of the following repositories, please make sure to update the remote URLs:

To update devstack and the local repositories::

    cd /path/to/devstack
    git pull

    cd ..
    cd edx-analytics-dashboard
    git remote set-url origin git@github.com:edx/edx-analytics-dashboard.git
    git pull

    cd ..
    cd edx-analytics-data-api
    git remote set-url origin git@github.com:edx/edx-analytics-data-api.git
    git pull

If you happen to use ``edx-analytics-data-api-client``::

    cd /path/to/edx-analytics-data-api-client
    git remote set-url origin git@github.com:edx/edx-analytics-data-api-client.git
    git pull

2024-02-25 - Mongo upgrade from version 4.4 to 5.0
**************************************************

As mongo 4.4 is reaching EOL, we have upgraded mongo version 4.4 to mongo version 5.0. Developers will need to follow the following instructions.

1. Take latest ``git pull`` of ``devstack``

2. Take the latest pull of images ::

    make dev.pull

3. Run mongo5 upgrade script, already added to devstack repo ::

    ./upgrade_mongo_5_0.sh

2023-10-05 - MySQL upgrade from version 5.7 to 8.0
**************************************************

The MySQL service has been upgraded from version 5.7 to 8.0. Developers will need to follow the following instructions.

1. Take latest ``git pull`` of ``devstack`` and ``edx-platform``.

2. Take the latest pull of images ::

    make dev.pull

3. Run provisioning command ::

    make dev.provision

4. [Optional] Additionally, there is a database copy command to help you transfer data from MySQL 5.7 to 8.0. After provisioning use the ``dev.dbcopyall8`` command. This command will stop all of your services, clean your ``mysql80`` container, and copy all of your databases from ``mysql57`` to ``mysql80``. ::

    make dev.dbcopyall8

This command copies the following databases:

- credentials
- discovery
- ecommerce
- registrar
- notes
- edxapp
- xqueue
- edxapp_csmh
- dashboard
- analytics-api
- reports
- reports_v1

If you prefer not to copy all databases, update ``DB_NAMES_LIST`` in the ``Makefile`` of devstack before running the dbcopy command.

5. Now start your desired services again using ``dev.up`` command. For example running following command will start ``lms``, ``cms`` ::

    make dev.up.lms+cms

6. You might need to apply latest migrations to your ``mysql80`` container for some services. To do that, you can use ``dev.migrate`` command. For example for ``lms`` you can run ::

    make dev.migrate.lms


2023-08-02 - Forum upgrade from Ruby 2 to 3
*******************************************

The forum service has been upgraded from Ruby 2 to Ruby 3. Developers who use forum will need to pull the new image and reprovision the service::

    make dev.pull.forum  # pull in new forum image
    make dev.provision.forum  # provision forum service
