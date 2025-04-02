Codejail service
################

The ``codejail`` devstack component (codejail-service) requires some additional configuration before it can be enabled. This page describes how to set it up and debug it.

Background
**********

The `codejail-service <https://github.com/openedx/codejail-service>`__ webapp is a wrapper around the `codejail <https://github.com/openedx/codejail>`__ library. See the READMEs of each repo for more information on the special requirements for deploying codejail, in particular the AppArmor-based sandboxing.

References to "codejail" can mean either the library or the service. In devstack, "codejail" usually refers to the service.

Configuration
*************

These instructions are for Linux only. Additional research would be required to create instructions for a Mac, which probably involves accessing the Linux VM that docker is run inside of.

In order to run the codejail devstack component:

#. Install AppArmor: ``sudo apt install apparmor``
#. Clone the `<https://github.com/edx/public-dockerfiles>`__ repo as a sibling to your devstack checkout.
#. Add the provided codejail AppArmor profile to your OS: ``sudo apparmor_parser --replace -W --warn=all --warn=no-debug-cache --Werror ../public-dockerfiles/apparmor/openedx_codejail_service.profile``.

   * You can also copy the file into ``/etc/apparmor.d/`` to make it persistent across reboots.
   * During profile development you may need to remove the ``--Werror``, which is there to block loading of profiles that validate with warnings. Be sure to address all warnings before making a PR for any profile changes.

#. Configure LMS and CMS to use the codejail-service by uncommenting ``# ENABLE_CODEJAIL_REST_SERVICE = True`` in ``py_configuration_files/{lms,cms}.py``
#. Run ``make codejail-up``

The service does not need any provisioning, and does not have dependencies.

Over time, the AppArmor profile may need to be updated. Changes to the file do not automatically cause changes to the version that has been installed in the OS. When significant changes have been made to the profile, you'll need to update the profile using the same ``apparmor_parser`` command you used to install it in the first place. (The ``--replace`` option acts to either add or update, as appropriate.)

Development
***********

Changes to the AppArmor profile must be coordinated with changes to the Dockerfile, as they need to agree on filesystem paths.

Any time you update the profile file, you'll need to re-run the ``apparmor_parser`` command to add/replace the profile.

The profile file contains the directive ``profile openedx_codejail_service``. That defines the name of the profile when it is installed into the OS, and must agree with the relevant ``security_opt`` line in ``docker-compose.yml``. This name should not be changed, as it creates a confusing situation and would require every developer who uses codejail-service to do a number of manual steps. (Profiles can't be renamed *within* the OS; they must first be removed **under the old name**, and then a new profile must be installed under the new name.)

Debugging
*********

To check whether the profile has been applied, run ``sudo aa-status | grep codejail``. This won't tell you if the profile is out of date, but it will tell you if you have *some* version of it installed.

If you need to debug the confinement, either because it is restricting too much or too little, a good strategy is to run ``tail -F /var/log/kern.log | grep codejail`` and watch for ``DENIED`` lines. You should expect to see several appear during service startup, as the service is designed to probe the confinement as part of its initial healthcheck.

Unlike other devstack services, this one runs as the ``app`` user rather than as ``root``. (Although this isn't strictly needed to develop, it better matches our production environment, and allows proper testing of several aspects of the sandboxing.) In order to enter the container as root, you can use ``docker compose exec -it --user root codejail bash`` rather than ``make codejail-shell``.
