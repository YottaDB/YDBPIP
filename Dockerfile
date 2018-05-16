FROM yottadb/yottadb

# Install prereqs
RUN apt-get update
RUN apt-get install git build-essential -y

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

EXPOSE 61012
ENTRYPOINT /home/pip/pip/pipstart-docker
