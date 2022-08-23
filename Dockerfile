FROM ubuntu:22.04
MAINTAINER gh0stwin <fabiovital@tecnico.ulisboa.pt>

ENV DEBIAN_FRONTEND noninteractive

############################################
# Basic dependencies
############################################
RUN apt-get update --fix-missing && apt-get install -y \
        linux-headers-$(uname -r) build-essential curl \
        cmake zlib1g-dev libjpeg-dev xvfb libav-tools \
        xorg-dev libboost-all-dev libsdl2-dev swig git \
        wget openjdk-8-jdk ffmpeg unzip libosmesa6-dev \
        libgl1-mesa-glx libglfw3 pkg-config patchself \
        qtbase5-dev libqt5opengl5-dev libassimp-dev \
        libffi-dev mlocate less vim lxterminal \
        mesa-utils updatedb \
    && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

############################################
# Add user (Change env $USER to whatever you want)
############################################
ENV USER user
RUN useradd -ms /bin/bash $USER
USER $USER
ENV HOME /home/$USER/

############################################
# Install CUDA
############################################
ARG JAX_CUDA_VERSION=11.2
COPY install_cuda.sh /install_cuda.sh
RUN chmod +x /install_cuda.sh
RUN /bin/bash -c 'if [[ ! "$CUDA_VERSION" =~ ^$JAX_CUDA_VERSION.*$ ]]; then \
  /install_cuda.sh $JAX_CUDA_VERSION; \
  fi'

############################################
# Install mujoco
############################################
WORKDIR $HOME
RUN wget https://github.com/deepmind/mujoco/releases/download/2.1.0/mujoco210-linux-x86_64.tar.gz
RUN tar -xf mujoco210-linux-x86_64.tar.gz
RUN mkdir /opt/.mujoco && mv mujoco210 $HOME
ENV MUJOCO_PY_MUJOCO_PATH $HOME/.mujoco/mujoco210

############################################
# Install pyenv & poetry
############################################
RUN curl https://pyenv.run | bash
RUN curl -sSL https://install.python-poetry.org | python - -p

############################################
# Use oh-my-zsh
############################################
ENV SHELL /bin/zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

RUN apt autoremove \
  && apt autoclean \
  && apt clean