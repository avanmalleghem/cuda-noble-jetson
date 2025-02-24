FROM docker.io/arm64v8/ubuntu:24.04

# general prerequisites
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -qq -y --no-install-recommends \
    sudo git cmake wget gnupg2 ca-certificates && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

# needed to install nvidia-l4t-core (prerequisite for cuda)
# More explanations here : https://forums.balena.io/t/getting-linux-for-tegra-into-a-container-on-balena-os/179421/20
COPY jetson-ota-public.key /etc/jetson-ota-public.key
RUN apt-key add /etc/jetson-ota-public.key
RUN echo "deb https://repo.download.nvidia.com/jetson/common r36.4 main" >> /etc/apt/sources.list \
    && echo "deb https://repo.download.nvidia.com/jetson/t234 r36.4 main" >>  /etc/apt/sources.list.d/nvidia.list \
    && mkdir -p /opt/nvidia/l4t-packages/ && touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall 

# install nvidia-l4t-core and cuda (from https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=aarch64-jetson&Compilation=Native&Distribution=Ubuntu&target_version=22.04&target_type=deb_local)
RUN apt-get update && apt-get install -y nvidia-l4t-core && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/arm64/cuda-ubuntu2204.pin && \
    sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
    wget https://developer.download.nvidia.com/compute/cuda/12.8.0/local_installers/cuda-tegra-repo-ubuntu2204-12-8-local_12.8.0-1_arm64.deb && \
    sudo dpkg -i cuda-tegra-repo-ubuntu2204-12-8-local_12.8.0-1_arm64.deb && \
    sudo cp /var/cuda-tegra-repo-ubuntu2204-12-8-local/cuda-*-keyring.gpg /usr/share/keyrings/ && \
    sudo apt-get update && \
    sudo apt-get -y install cuda-toolkit-12-8 cuda-compat-12-8

ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64"

# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/docker-specialized.html
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute

# build clock
RUN git clone https://github.com/NVIDIA/cuda-samples.git && \
    cd cuda-samples/Samples/0_Introduction/clock && mkdir build && cd build && cmake .. && make