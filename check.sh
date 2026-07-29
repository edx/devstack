#!/usr/bin/env bash
# Run health checks for the provided service(s).
# To specify multiple services, separate them with spaces or plus signs (+).
# To specify all running services, just pass in "all".
#
# Examples:
#  ./check.sh lms
#  ./check.sh lms+forum
#  ./check.sh lms+forum discovery
#  ./check.sh all
#
# Exits 0 if successful; non-zero otherwise.
#
# Fails if no services specified.
#
# Note that passing in a non-existent service will not fail if there are
# other successful checks.

set -eu -o pipefail

# Which checks succeeded and failed.
succeeded=""
failed=""

# Runs a check named $1 on service $2 using the host-side command $3.
run_check() {
    local check_name="$1"
    local service="$2"
    local cmd="$3"
    echo "> $cmd"
    set +e  # Disable exit-on-error
    if bash -c "$cmd"; then  # Run the command itself and check if it succeeded.
        succeeded="$succeeded $check_name"
    else
        docker compose logs --tail 500 "$service"  # Just show recent logs, not all history
        failed="$failed $check_name"
    fi
    set -e  # Re-enable exit-on-error
    echo  # Newline
}

# Print a service container's Docker healthcheck status, one of:
#   healthy | unhealthy | starting | none | missing
# "none" means the container exists but declares no healthcheck; "missing"
# means no container is running for the service.
container_health() {
    local service="$1" cid
    cid="$(docker compose ps -q "$service" 2>/dev/null || true)"
    if [[ -z "$cid" ]]; then
        echo "missing"
        return
    fi
    docker inspect \
        --format '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' \
        "$cid" 2>/dev/null || echo "missing"
}

# Default check: pass iff the service's container reports itself healthy.
# Services with no healthcheck (and no extra check) simply don't contribute a
# check, matching the old behavior for unrecognized services.
run_health_check() {
    local service="$1"
    local status
    status="$(container_health "$service")"
    case "$status" in
        healthy)
            echo "Checking $service: healthy"
            succeeded="$succeeded ${service}_health"
            echo
            ;;
        starting|unhealthy)
            echo "Checking $service: $status"
            docker compose logs --tail 500 "$service"
            failed="$failed ${service}_health"
            echo
            ;;
        none|missing)
            # No container healthcheck to consult; rely on any extra checks.
            :
            ;;
    esac
}

# Extra/override checks for services that need more than their container
# healthcheck can express. Keep this SMALL -- it is the only place service
# names should be enumerated.
run_extra_checks() {
    local service="$1"
    case "$service" in
        lms)
            echo "Validating LMS volume:"
            run_check lms_volume lms "make validate-lms-volume"
            ;;
    esac
}

# Expand the requested services into a plain, space-separated list. "all"
# means every service with a running container (word-splitting is safe here
# because compose service names contain no whitespace).
requested=" ${*//+/ } "
if [[ "$requested" == *" all "* ]]; then
    service_list="$(docker compose ps --services)"
else
    service_list="${*//+/ }"
fi

for service in $service_list; do
    run_health_check "$service"
    run_extra_checks "$service"
done

echo "Successful checks:${succeeded:- NONE}"
echo "Failed checks:${failed:- NONE}"
if [[ -z "$succeeded" ]] && [[ -z "$failed" ]]; then
    echo "No checks ran. Exiting as failure."
    exit 1
elif [[ -z "$failed" ]]; then
    echo "Check result: SUCCESS"
    exit 0
else
    echo "Check result: FAILURE"
    exit 2
fi
