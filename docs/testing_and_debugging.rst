Testing and Debugging
=====================

.. contents:: Table of Contents

Debugging using PDB
-------------------

It's possible to debug any of the containers' Python services using PDB. To do so,
start up the containers as usual with:

.. code:: sh

    make dev.up

This command starts each relevant container with the equivalent of the '--it' option,
allowing a developer to attach to the process once the process is up and running.

To attach to a container and its process, use ``make dev.attach.<service>``. For example:

.. code:: sh

    make dev.attach.lms

Set a PDB breakpoint anywhere in the code using one of the following:

.. code:: sh

    breakpoint()                # Works in Python >= 3.7
    import pdb;pdb.set_trace()  # Works in any version of Python

and your attached session will offer an interactive PDB prompt when the breakpoint is hit.

You may be able to detach from the container with the ``Ctrl-P, Ctrl-Q`` key sequence.
If that doesn't work, you will have either close your terminal window or
stop the service with:

.. code:: sh

    make dev.stop.<service>

You can bring that same service back up with:

.. code:: sh

    make dev.up.<service>

Running LMS and CMS Tests
----------------------------

After entering a shell for the appropriate service via ``make lms-shell`` or
``make cms-shell``, you can run commands from the `edx-platform testing documentation`_
Tests can be run individually. Example:

.. code:: sh

    pytest openedx/core/djangoapps/user_api

Tests can also be easily run with a shortcut from the host machine,
so that you maintain your command history:

.. code:: sh

    ./in lms pytest openedx/core/djangoapps/user_api


.. _edx-platform testing documentation: https://docs.openedx.org/projects/edx-platform/en/latest/concepts/testing/testing.html#running-python-unit-tests
