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
    # These values are coordinated with the Dockerfile and the AppArmor
    # profile (openedx_codejail_service.profile) both in edx/public-dockerfiles.
    'python_bin': '/sandbox/venv/bin/python',
    'user': 'sandbox',

    # Configurable limits.
    'limits': {
        # CPU-seconds
        'CPU': 3,
        # Clock seconds
        'REALTIME': 3,
        # Need at least 300 MiB memory for matplotlib alone. 512 MiB should be
        # enough headroom in general.
        'VMEM': 512 * 1024 * 1024,
        # 1 MB file size limit
        'FSIZE': 1 * 1024 * 1024,
        # 15 processes and threads (codejail default)
        'NPROC': 15,
        # Match production configuration
        'PROXY': 0,
    },
}
