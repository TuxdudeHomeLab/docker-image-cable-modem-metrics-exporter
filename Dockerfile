# syntax=docker/dockerfile:1

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG} AS with-scripts

COPY scripts/start-cable-modem-metrics-exporter.sh /scripts/

ARG BASE_IMAGE_NAME
ARG BASE_IMAGE_TAG
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ARG USER_NAME
ARG GROUP_NAME
ARG USER_ID
ARG GROUP_ID
ARG PROMETHEUS_CABLE_MODEM_EXPORTER_VERSION

RUN --mount=type=bind,target=/scripts,from=with-scripts,source=/scripts \
    set -E -e -o pipefail \
    && export HOMELAB_VERBOSE=y \
    # Create the user and the group. \
    && homelab add-user \
        ${USER_NAME:?} \
        ${USER_ID:?} \
        ${GROUP_NAME:?} \
        ${GROUP_ID:?} \
        --create-home-dir \
    && homelab install-tuxdude-go-package Tuxdude/prometheus_cable_modem_exporter ${PROMETHEUS_CABLE_MODEM_EXPORTER_VERSION#v} \
    # Copy the start-cable-modem-metrics-exporter.sh script. \
    && cp /scripts/start-cable-modem-metrics-exporter.sh /opt/prometheus_cable_modem_exporter \
    && ln -sf /opt/prometheus_cable_modem_exporter/start-cable-modem-metrics-exporter.sh /opt/bin/start-cable-modem-metrics-exporter \
    # Set up the permissions. \
    && chown -R ${USER_NAME:?}:${GROUP_NAME:?} \
        /opt/prometheus_cable_modem_exporter \
        /opt/bin/prometheus_cable_modem_exporter \
        /opt/bin/start-cable-modem-metrics-exporter \
    # Clean up. \
    && homelab cleanup

# Expose the HTTP server port used by Cable Modem Metrics Exporter.
EXPOSE 8080

ENV USER=${USER_NAME}
USER ${USER_NAME}:${GROUP_NAME}
WORKDIR /home/${USER_NAME}

CMD ["start-cable-modem-metrics-exporter"]
STOPSIGNAL SIGTERM
