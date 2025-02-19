Codejail service
################

The ``codejail`` devstack component (codejail-service) requires some additional configuration before it can be enabled. This page describes how to set it up and debug it.

Background
**********

The `codejail-service <https://github.com/openedx/codejail-service>`__ webapp is a wrapper around the `codejail <https://github.com/openedx/codejail>`__ library. See the READMEs of each repo for more information on the special requirements for deploying codejail, in particular the AppArmor-based sandboxing.

References to "codejail" can mean either the library or the service. In devstack, "codejail" usually refers to the service.

Configuration
*************

In order to run the codejail devstack component:

1. Install AppArmor: ``sudo apt install apparmor``
2. Add the codejail AppArmor profile to your OS, or update it: ``sudo apparmor_parser --replace -W codejail.profile``
3. Configure LMS and CMS to use the codejail-service by uncommenting ``# ENABLE_CODEJAIL_REST_SERVICE = True`` in ``py_configuration_files/{lms,cms}.py``
4. Run ``make codejail-up``

The service does not need any provisioning, and does not have dependencies.

Development
***********

Changes to the AppArmor profile must be coordinated with changes to the Dockerfile, as they need to agree on filesystem paths.

Any time you update the profile, you'll need to re-run the command to apply the profile.

The profile file contains the directive ``profile codejail_service``. That defines the name of the profile when it is installed into the kernel. In order to change that name, you must first remove the profile **under the old name**, then install a new profile under the new name. To remove a profile, use the ``--remove`` action instead of the ``-replace`` action: : ``sudo apparmor_parser --remove -W codejail.profile``

The profile name must also agree with the relevant ``security_opt`` line in devstack's ``docker-compose.yml``.

Debugging
*********

To check whether the profile has been applied, run ``sudo aa-status | grep codejail``. This won't tell you if the profile is out of date, but it will tell you if you have *some* version of it installed.

If you need to debug the confinement, either because it is restricting too much or too little, a good strategy is to run ``tail -F /var/log/kern.log | grep codejail`` and watch for ``DENIED`` lines. You should expect to see several appear during service startup, as the service is designed to probe the confinement as part of its initial healthcheck.
