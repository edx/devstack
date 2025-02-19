"""Settings for devstack use."""

from codejail_service.settings.local import *  # pylint: disable=wildcard-import

ALLOWED_HOSTS = [
    # When called from outside of docker's network (dev's terminal)
    'localhost',
    # When called from another container (lms, cms)
    'edx.devstack.codejail',
]

CODEJAIL_ENABLED = True

CODE_JAIL = {
    # These values are coordinated with the Dockerfile (in edx/public-dockerfiles)
    # and the AppArmor profile (codejail.profile in edx/devstack).
    'python_bin': '/sandbox/venv/bin/python',
    'user': 'sandbox',

    # Configurable limits.
    'limits': {
        # CPU-seconds
        'CPU': 3,
        # 100 MiB memory
        'VMEM': 100 * 1024 * 1024,
        # Clock seconds
        'REALTIME': 3,
    },
}
