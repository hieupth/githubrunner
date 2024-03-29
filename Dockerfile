FROM ubuntu:20.04
# set the github runner version
ARG RUNNER_VERSION="2.296.2"
# update the base packages and add a non-sudo user
RUN apt-get update -y && apt-get upgrade -y && useradd -m docker
# install python and the packages the your code depends on along with jq so we can parse JSON
# add additional packages as necessary
ENV DEBIAN_FRONTEND=noninteractive 
RUN apt-get install -y --no-install-recommends \
        curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip \
    && apt-get autoremove --prune && sudo apt-get clean
# cd into the user directory, download and unzip the github actions runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner \
    && curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && rm -rf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
# install some additional dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh \
    && && apt-get autoremove --prune && sudo apt-get clean
# copy over the start.sh script
COPY entrypoint.sh entrypoint.sh
# make the script executable
RUN chmod +x entrypoint.sh
# since the config and run script for actions are not allowed to be run by root,
# set the user to "docker" so all subsequent commands are run as the docker user
USER docker
# set the entrypoint to the start.sh script
ENTRYPOINT ["./entrypoint.sh"]