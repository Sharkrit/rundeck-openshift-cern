FROM cern/cc7-base

EXPOSE 4440

# Configure env variables
ARG RUNDECK_VERSION='2.11.5'
ENV RDECK_BASE '/var/lib/rundeck'
ENV RDECK_CONFIG '/etc/rundeck'

# Where to store the DB and project definitions and logs
VOLUME ["/var/rundeck", "/var/lib/rundeck/logs"]

# Install java and xsltproc
RUN yum install -y java-1.8.0-openjdk gettext xmlstarlet \
    python-requests python-requests-kerberos bc openssh-clients cern-wrappers && yum clean all  # For CERN plugins


# Install rundeck
RUN yum install -y http://repo.rundeck.org/latest.rpm && yum install -y rundeck-${RUNDECK_VERSION} rundeck-config-${RUNDECK_VERSION} && yum clean all

# Install CERN plugins
RUN cd /var/lib/rundeck/libext/ && \
    curl -L -O https://github.com/cernops/rundeck-exec-kerberos/releases/download/v1.3/rundeck-ssh-krb-node-executor-plugin-1.3.zip && \
    curl -L -O https://github.com/cernops/rundeck-puppetdb-nodes/releases/download/v1.4.1/rundeck-puppetdb-nodes-plugin-1.4.1.zip

COPY run.sh /

# Create rundeck folders and give appropriate permissions
RUN mkdir -p $RDECK_BASE && chmod -R a+rw $RDECK_BASE && chmod -R a+rw /var/log/rundeck && \
    chmod -R a+rw /tmp/rundeck && mkdir -p /rundeck-config && chmod -R a+rw $RDECK_CONFIG && \
    chmod -R a+rwx /rundeck-config && chmod a+x /run.sh

ENTRYPOINT './run.sh'
