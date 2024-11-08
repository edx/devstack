Advanced Configuration Options
------------------------------

The file ``options.mk`` sets several configuration options to default values.
For example ``DEVSTACK_WORKSPACE`` (the folder where your Git repos are expected to be)
is set to this directory's parent directory by default,
and ``DEFAULT_SERVICES`` (the list of services that are provisioned and run by default)
is set to a fairly long list of services out of the box.
For more detail, refer to the comments in the file itself.

If you're feeling brave, you can create an git-ignored overrides file called
``options.local.mk`` in the same directory and set your own values. In general,
it's good to bring down containers before changing any settings.

Changing the Docker Compose Project Name
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``COMPOSE_PROJECT_NAME`` variable is used to define Docker namespaced volumes
and network based on this value, so changing it will give you a separate set of databases.
This is handled for you automatically by setting the ``OPENEDX_RELEASE`` environment variable in ``options.mk``
(e.g. ``COMPOSE_PROJECT_NAME=devstack-juniper.master``. Should you want to manually override this, edit the ``options.local.mk`` in the root of this repo and create the file if it does not exist. Change the devstack project name by adding the following line::

   # Example: COMPOSE_PROJECT_NAME=secondarydevstack
   COMPOSE_PROJECT_NAME=<your-alternate-devstack-name>

As a specific example, if ``OPENEDX_RELEASE`` is set in your environment as ``juniper.master``, then ``COMPOSE_PROJECT_NAME`` will default to ``devstack-juniper.master`` instead of ``devstack``.

Celery workers
~~~~~~~~~~~~~~

In devstack, edxapp and possibly other services are configured to run Celery tasks synchronously rather than requiring another worker service to handle them. However, there is some support for using a separate worker. To use Celery for LMS or CMS:

1. Edit ``docker-compose.yml`` to update the LMS and CMS ``command`` lines to use ``--settings devstack_with_worker`` instead of just ``--settings devstack``
2. Run ``make lms-worker-up cms-worker-up``
3. Start LMS and CMS as usual

To verify that Celery communication is working, try ``curl -sS 'http://localhost:18000/heartbeat?extended'`` and confirm that the ``celery`` component of the response shows success.
