# AppArmor profile for running codejail-service in devstack.
#
#                         #=========#
#                         # WARNING #
#                         #=========#
#
# This is not a complete and secure apparmor profile! Do not use this
# in any deployed environment (even a staging environment) without
# careful inspection and modification to fit your needs.
#
# Failure to apply a secure apparmor profile *will* likely result in a
# compromise of your environment by an attacker.
#
# We may at some point make this file good enough for confinement in
# production, but for now it is only intended to be used in devstack.


#include <tunables/global>

# Declare ABI version explicitly to ensure that confinement is
# actually applied appropriately on newer Ubuntu.
abi <abi/3.0>,

# This outer profile applies to the entire container, and isn't as
# important. If the sandbox profile doesn't work, it's not likely that
# the outer one is going to help. But there may be some small value in
# defense-in-depth, as it's possible that a bug in the child (sandbox)
# profile isn't present in the outer one.
profile codejail_service flags=(attach_disconnected,mediate_deleted) {
    #include <abstractions/base>

    # Filesystem access -- self-explanatory
    file,

    # `network` is required for sudo
    # TODO: Restrict this so that general network access is not permitted
    network,

    # Various capabilities required for sudoing to sandbox (setuid,
    # setgid, audit_write) and for sending a kill signal (kill).
    capability setuid setgid audit_write kill,

    # Allow sending a kill signal to the sandbox when the execution
    # runs beyond time limits.
    signal (send) set=(kill) peer=codejail_service//child,

    # Allow executing this binary, but force a transition to the specified
    # profile (and scrub the environment).
    /sandbox/venv/bin/python Cx -> child,

    # This is the important apparmor profile -- the one that actually
    # constrains the sandbox Python process.
    profile child flags=(attach_disconnected,mediate_deleted) {
        #include <abstractions/base>

        # Read and run binaries and libraries in the virtualenv. This
        # includes the sandbox's copy of Python as well as any
        # dependencies that have been installed for inclusion in
        # sandboxes.
        /sandbox/venv/** rm,

        # Codejail has a hardcoded reference to this file path, although the
        # use of /tmp specifically may be controllable with environment variables:
        # https://github.com/openedx/codejail/blob/0165d9ca351/codejail/util.py#L15
        /tmp/codejail-*/ r,
        /tmp/codejail-*/** rw,

        # Allow interactive terminal during development
        /dev/pts/* rw,

        # Allow receiving a kill signal from the webapp when the execution
        # runs beyond time limits.
        signal (receive) set=(kill) peer=codejail_service,
    }
}
