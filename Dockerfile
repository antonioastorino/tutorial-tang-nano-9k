FROM docker.io/library/ubuntu:latest
RUN apt update && apt upgrade -y
RUN apt install -y \
    make \
    build-essential \
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    git \
    cmake \
    libboost-all-dev \
    libeigen3-dev \
    libftdi1-2 \
    libftdi1-dev \
    libhidapi-hidraw0 \
    libhidapi-dev \
    libudev-dev \
    g++ \
    clang \
    bison \
    flex \
    gawk \
    tcl-dev \
    graphviz \
    xdot \
    pkg-config \
    zlib1g-dev

# install python
RUN curl https://pyenv.run | bash 
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc && \
    echo 'if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi' >> ~/.bashrc

RUN . ~/.bashrc && \
    pyenv install 3.9.13 && \
    pyenv global 3.9.13

RUN apt install -y python3-apycula
 
