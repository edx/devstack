Codejail service
################

The ``codejail`` devstack component (codejail-service) requires some additional configuration before it can be enabled. This page describes how to set it up and debug it.

Background
**********

The `codejail-service <https://github.com/openedx/codejail-service>`__ webapp is a wrapper around the `codejail <https://github.com/openedx/codejail>`__ library. See the READMEs of each repo for more information on the special requirements for deploying codejail, in particular the AppArmor-based sandboxing.

References to "codejail" can mean either the library or the service. In devstack, "codejail" usually refers to the service.

Configuration
*************

**TODO**: These instructions are for Linux. We need some instructions for how to do this on Mac; it probably involves accessing the Linux VM that docker is run inside of.

In order to run the codejail devstack component:

1. Install AppArmor: ``sudo apt install apparmor``
2. Add the provided codejail AppArmor profile to your OS: ``sudo apparmor_parser --add -W ./codejail.profile``
3. Configure LMS and CMS to use the codejail-service by uncommenting ``# ENABLE_CODEJAIL_REST_SERVICE = True`` in ``py_configuration_files/{lms,cms}.py``
4. Run ``make codejail-up``

The service does not need any provisioning, and does not have dependencies.

Over time, the AppArmor profile may need to be updated. Changes to the file do not automatically cause changes to the version that has been installed in the OS. When significant changes have been made to the profile, you'll need to re-install the profile. This can be done by passing ``--replace`` instead of ``--add``, like so: ``sudo apparmor_parser --replace -W ./codejail.profile``

Development
***********

Changes to the AppArmor profile must be coordinated with changes to the Dockerfile, as they need to agree on filesystem paths.

Any time you update the profile, you'll need to update the profile in your OS as well: ``sudo apparmor_parser --replace -W ./codejail.profile``

The profile file contains the directive ``profile codejail_service``. That defines the name of the profile when it is installed into the OS, and must agree with the relevant ``security_opt`` line in ``docker-compose.yml``. This name should not be changed, as it creates a confusing situation and would require every developer who uses codejail-service to do a number of manual steps. (Profiles can't be renamed *within* the OS; they must first be removed **under the old name**, and then a new profile must be installed under the new name.)

Debugging
*********

To check whether the profile has been applied, run ``sudo aa-status | grep codejail``. This won't tell you if the profile is out of date, but it will tell you if you have *some* version of it installed.

If you need to debug the confinement, either because it is restricting too much or too little, a good strategy is to run ``tail -F /var/log/kern.log | grep codejail`` and watch for ``DENIED`` lines. You should expect to see several appear during service startup, as the service is designed to probe the confinement as part of its initial healthcheck.
