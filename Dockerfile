 
FROM python:3.7-slim
# install the notebook package
RUN pip install --no-cache --upgrade pip && \
    pip install --no-cache notebook

# create user with a home directory
ARG NB_USER
ARG NB_UID
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:alexis.bienvenue/amc
RUN apt-get-update
RUN apt-get install -y auto-multiple-choice

WORKDIR ${HOME}
USER ${USER}

