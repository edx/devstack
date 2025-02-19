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
# See https://manpages.ubuntu.com/manpages/noble/man5/apparmor.d.5.html
# or `man apparmor.d` for documentation of syntax and options.
#
# Failure to apply a secure apparmor profile *will* likely result in a
# compromise of your environment by an attacker.
#
# We may at some point make this file good enough for confinement in
# production, but for now it is only intended to be used in devstack.



# Sets standard variables used by abstractions/base, later. Controlled
# by OS, see /etc/apparmor.d/tunables/global for contents.
include <tunables/global>

# Require that the system understands the feature set that this policy was written
# for. If we didn't include this, then on Ubuntu >= 22.04, AppArmor might assume
# the wrong feature set was requested, and some rules might become too permissive.
# See https://github.com/netblue30/firejail/issues/3659#issuecomment-711074899
abi <abi/3.0>,

# This outer profile applies to the entire container, and isn't as
# important. If the sandbox profile doesn't work, it's not likely that
# the outer one is going to help. But there may be some small value in
# defense-in-depth, as it's possible that a bug in the child (sandbox)
# profile isn't present in the outer one.
profile codejail_service flags=(mediate_deleted) {

    # Allow access to a variety of commonly needed, generally safe things
    # (such as reading /dev/random, free memory, etc.)
    #
    # Manpage: "Includes files that should be readable and writable in all profiles."
    include <abstractions/base>

    # Filesystem access -- self-explanatory
    file,

    # netlink is needed for sudo's interprocess communication
    network netlink raw,

    # Allow all of the various network operations required to listen, accept connection, etc.
    network tcp,
    # But then deny making a new *outbound* connection.
    deny network (connect) tcp,

    # Required for sudoing to sandbox
    capability setuid setgid audit_write,
    # Allow sending a kill signal
    capability kill,

    # Allow sending a kill signal to the child subprofile when the execution
    # runs beyond time limits.
    signal (send) set=(kill) peer=codejail_service//child,

    # The core of the confinement: When the sandbox Python is executed, switch to
    # the (extremely constrained) child profile.
    #
    # This path needs to be coordinated with the Dockerfile and Django settings.
    #
    # Manpage: "Cx: transition to subprofile on execute -- scrub the environment"
    /sandbox/venv/bin/python Cx -> child,

    # This is the important apparmor profile -- the one that actually
    # constrains the sandbox Python process.
    #
    # mediate_deleted is not well documented, but it seems to indicate that
    # apparmor will continue to make policy decisions in cases where a confined
    # executable has a handle to a file's inode even after the file is removed
    # from the filesystem.
    profile child flags=(mediate_deleted) {

        # This inner profile also gets general access to "safe"
        # actions; we could list those explicitly out of caution but
        # it could get pretty verbose.
        include <abstractions/base>

        # Read and run binaries and libraries in the virtualenv. This
        # includes the sandbox's copy of Python as well as any
        # dependencies that have been installed for inclusion in
        # sandboxes.
        /sandbox/venv/** rm,

        # Allow access to the temporary directories that are set up by
        # codejail, one for each code-exec call. Each /tmp/code-XXXXX
        # contains one execution.
        #
        # Codejail has a hardcoded reference to this file path, although the
        # use of /tmp specifically may be controllable with environment variables:
        # https://github.com/openedx/codejail/blob/0165d9ca351/codejail/util.py#L15
        /tmp/codejail-*/ r,
        /tmp/codejail-*/** rw,

        # Allow interactive terminal in devstack.
        /dev/pts/* rw,

        # Allow receiving a kill signal from the webapp when the execution
        # runs beyond time limits.
        signal (receive) set=(kill) peer=codejail_service,
    }
}
