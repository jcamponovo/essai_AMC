FROM ubuntu:bionic
ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL /bin/bash


ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN groupadd \
        --gid ${NB_UID} \
        ${NB_USER} && \
    useradd \
        --comment "Default user" \
        --create-home \
        --gid ${NB_UID} \
        --no-log-init \
        --shell /bin/bash \
        --uid ${NB_UID} \
        ${NB_USER}
RUN apt-get -qq update && \
    apt-get -qq install --yes --no-install-recommends \
       less \
       nodejs \
       unzip \
       npm \
       > /dev/null && \
    apt-get -qq purge && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*
    
EXPOSE 8888

ENV APP_BASE /srv
ENV NPM_DIR ${APP_BASE}/npm
ENV NPM_CONFIG_GLOBALCONFIG ${NPM_DIR}/npmrc
ENV CONDA_DIR ${APP_BASE}/conda
ENV NB_PYTHON_PREFIX ${CONDA_DIR}/envs/notebook
ENV KERNEL_PYTHON_PREFIX ${NB_PYTHON_PREFIX}
# Special case PATH
ENV PATH ${NB_PYTHON_PREFIX}/bin:${CONDA_DIR}/bin:${NPM_DIR}/bin:${PATH}
# If scripts required during build are present, copy them
RUN mkdir -p ${NPM_DIR} && \
chown -R ${NB_USER}:${NB_USER} ${NPM_DIR}

USER ${NB_USER}
RUN npm config --global set prefix ${NPM_DIR}

USER root
# Allow target path repo is cloned to be configurable
ARG REPO_DIR=${HOME}
ENV REPO_DIR ${REPO_DIR}
WORKDIR ${REPO_DIR}

COPY . ${HOME}
#RUN chmod 744 ${HOME}/apt.txt
RUN chown -R ${NB_USER}:${NB_USER} ${REPO_DIR}
RUN apt-get -qq update && apt-get install -y software-properties-common apt-utils
#RUN apt-get update && ${HOME}/apt.txt | xargs apt-get install -y

RUN add-apt-repository ppa:jonathonf/texlive-2018
RUN apt-get -qq update

#RUN apt-get install -y texlive-latex-extra
RUN apt-get -qq install -y texlive-fonts-extra-links
RUN apt-get -qq install -y texlive-full

RUN add-apt-repository ppa:alexis.bienvenue/test

RUN apt-get -qq update && \
apt-get -qq install --yes auto-multiple-choice
RUN apt-get -qq install --yes auto-multiple-choice-common
RUN apt-get -qq install -y jupyter

RUN apt-get -qq update && \
apt-get -qq install --yes --no-install-recommends nano pandoc traceroute && \
apt-get -qq purge && \
apt-get -qq clean && \
rm -rf /var/lib/apt/lists/*

RUN apt-get -qq update && apt-get -qq dist-upgrade -y
# USER ${NB_USER}
# RUN ${KERNEL_PYTHON_PREFIX}/bin/pip install --no-cache-dir -r "requirements.txt"


# Copy and chown stuff. This doubles the size of the repo, because
# you can't actually copy as USER, only as root! Thanks, Docker!
# USER root
# COPY src/ ${REPO_DIR}
RUN chown -R ${NB_USER}:${NB_USER} ${REPO_DIR}

USER ${NB_USER}
RUN tlmgr init-usertree
RUN PATH=$PATH:/usr/share/texlive
RUN PATH=$PATH:/usr/share/texmf
RUN PATH=$PATH:/usr/bin
# RUN bash ./postBuild

# COPY /repo2docker-entrypoint /usr/local/bin/repo2docker-entrypoint
# ENTRYPOINT ["/usr/local/bin/repo2docker-entrypoint"]

CMD ["jupyter","notebook","--ip","0.0.0.0"]


WORKDIR ${HOME}
