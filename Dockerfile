#
# OWASP Dependency Checker container image.
#
#
#   $ ./scripts/build --push
#
# Build with custom arguments:
#
#   $ ./scripts/build --release 8.2.1 --jdk 17.0.6_10
#

ARG jdk=17.0.6_10

FROM eclipse-temurin:${jdk}-jre
ARG release=8.2.1
LABEL org.opencontainers.image.authors="Sascha Peilicke <sascha@peilicke.de"
LABEL org.opencontainers.image.title="OWASP Dependency Checker"
LABEL org.opencontainers.image.source="https://github.com/saschpe/docker-dependency-checker"
ENV user=dc

# Fetch and install
RUN apt-get update && apt-get install -y --no-install-recommends \
        mono-runtime unzip wget
RUN wget --quiet https://github.com/jeremylong/DependencyCheck/releases/download/v${release}/dependency-check-${release}-release.zip -O /tmp/dc.zip && \
    unzip -q /tmp/dc.zip -d /opt && \
    rm -r /tmp/dc.zip && \
    apt-get remove --purge -y unzip wget && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/*k && \
    useradd --system --no-create-home --user-group ${user} && \
    mkdir -p /opt/dependency-check/data && \
    chown -R ${user}:${user} /opt/dependency-check/

USER ${user}
# Update CVE database initially
RUN /opt/dependency-check/bin/dependency-check.sh --scan . || :

VOLUME /usr/share/dependency-check/data

CMD ["--help"]
ENTRYPOINT [ "/opt/dependency-check/bin/dependency-check.sh" ]
