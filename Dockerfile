# Use the official Ubuntu 20.04 image as a base
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC

##########################################
#           INSTALL COMMON LIB           #
##########################################

    RUN apt-get update && \
        apt-get install -y \
        build-essential \
        pkg-config \
        mesa-utils \
        git \
        wget \
        ffmpeg \
        python3 \
        python3-pip \
        && rm -rf /var/lib/apt/lists/*

##########################################
#           INSTALL ROS IRON           #
##########################################

    # Set Locale
    RUN apt-get update \
        && apt-get install locales \
        && locale-gen en_US en_US.UTF-8 \
        && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
        && export LANG=en_US.UTF-8

    # Enable Required Repositories        
    RUN apt-get install software-properties-common -y \
        && add-apt-repository universe \
        && apt-get update && apt-get install curl -y \
        && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

    # Install Development Tools
    RUN apt-get update \
        && apt-get install ros-dev-tools -y

    # Install ROS2 Iron
    RUN apt-get update \
        && apt-get upgrade -y \
        && apt-get install ros-iron-desktop -y \
        && apt-get install ros-iron-ros-base -y 

    # Environment setup
    RUN echo "source /opt/ros/iron/setup.bash" >> ~/.bashrc

##########################################
#           INSTALL GSTREAMER            #
##########################################

    # Update package lists and install necessary packages
    RUN apt-get update && \
        apt-get install -y \
        gstreamer-1.0 \
        gstreamer1.0-dev \
        libgstreamer1.0-0 \
        gstreamer1.0-plugins-base \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-plugins-ugly \
        gstreamer1.0-libav \
        gstreamer1.0-tools \
        gstreamer1.0-x \
        gstreamer1.0-libav \
        gstreamer1.0-tools \
        gstreamer1.0-x \
        gstreamer1.0-alsa \
        gstreamer1.0-gl \
        gstreamer1.0-gtk3 \
        gstreamer1.0-qt5 \
        gstreamer1.0-pulseaudio \
        gir1.2-gstreamer-1.0 \
        gstreamer1.0-python3-plugin-loader \
        libgstreamer1.0-dev \
        libgstreamer-plugins-base1.0-dev \
        libgstreamer-plugins-good1.0-dev \
        libgstreamer-plugins-bad1.0-dev \
        libgstrtspserver-1.0-dev \
        libglib2.0-dev \
        libglibmm-2.4-dev \
        libboost-all-dev \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

##########################################
#            SETUP WORKSPACE             #
##########################################

    # Copy your source code into the container
    RUN mkdir -p /workspace/src \
        && cd /workspace/

    # COPY . /catkin_ws
    
    # Set up a working directory
    WORKDIR /workspace

    # RUN g++ src/main.cpp -o main $(pkg-config --cflags --libs gstreamer-1.0) -std=c++11

    # # Define the entry point for your application if needed
    # # ENTRYPOINT ["./main"]

    # # Define a default command to run when the container starts if needed
    # CMD ["./main"]