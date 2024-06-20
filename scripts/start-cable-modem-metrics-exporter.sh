#!/usr/bin/env bash
set -E -e -o pipefail

set_umask() {
    # Configure umask to allow write permissions for the group by default
    # in addition to the owner.
    umask 0002
}

start_cable_modem_metrics_exporter() {
    echo "Starting Cable Modem Metrics Exporter ..."
    echo

    exec prometheus_cable_modem_exporter "$@"
}

set_umask
start_cable_modem_metrics_exporter "$@"
