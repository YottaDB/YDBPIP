FROM yottadb/yottadb

# Install prereqs
RUN apt-get update && \
    apt-get install \
                    git \
                    build-essential \
                    curl \
                    unzip \
                    default-jdk \
                    vim \
                    cmake \
                    -y

# Create PIP user
RUN useradd -ms /bin/bash pip
USER pip

# Copy PIP files to their proper place
ADD . /home/pip/pip
WORKDIR /home/pip/pip
USER root
RUN chown -R pip:pip /home/pip/pip
USER pip

# Install PIP
RUN ./build.sh

USER root

# Install Tomcat
RUN curl -fSsLO https://archive.apache.org/dist/tomcat/tomcat-6/v6.0.53/bin/apache-tomcat-6.0.53.tar.gz && \
    tar xzf apache-tomcat-*.tar.gz -C /opt && \
    rm -f apache-tomcat-*.tar.gz

# Install Derby jar
RUN curl -fSsLO http://www-us.apache.org/dist//db/derby/db-derby-10.14.2.0/db-derby-10.14.2.0-lib.zip && \
    unzip db-derby-*.zip && \
    mv db-derby-*-lib/lib/derbyclient.jar /opt/apache-tomcat-*/lib/ && \
    mv db-derby-*-lib/lib/derby.jar  /opt/apache-tomcat-*/lib/ && \
    mv db-derby-*-lib/lib/derbyrun.jar  /opt/apache-tomcat-*/lib/ && \
    mv db-derby-*-lib/lib/derbytools.jar  /opt/apache-tomcat-*/lib/ && \
    rm -rf db-derby-*-lib && \
    rm -f db-derby-*-lib.zip

# Extract Derby Database
RUN tar xvzf ProfileBrowserIDE/profile_ide_db.tgz -C /opt

# Fix permissions
RUN chown -R pip:pip /opt/apache-tomcat-* && \
    chown -R pip:pip /opt/profile_ide_db

USER pip

EXPOSE 61012
EXPOSE 8080

ENTRYPOINT /home/pip/pip/pipstart-docker
