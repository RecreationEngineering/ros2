#! /usr/bin/env bash
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo $ROOT

# check for V4L2 devices
V4L2_DEVICES=""

for i in {0..9}
do
	if [ -a "/dev/video$i" ]; then
		V4L2_DEVICES="$V4L2_DEVICES --device /dev/video$i "
	fi
done

# Discover available X displays
DISPLAY_DEVICE=""
for display_num in {0..5}; do
  export DISPLAY=":$display_num"

  if sudo xhost +si:localuser:root>/dev/null; then
    echo "Found available display: $DISPLAY"
	# enable SSH X11 forwarding inside container (https://stackoverflow.com/q/48235040)
	XAUTH=/tmp/.docker.xauth
	xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
	chmod 777 $XAUTH
    DISPLAY_DEVICE="-e DISPLAY=$DISPLAY -v /tmp/.X11-unix/:/tmp/.X11-unix"
    break
  else
    echo "Display $DISPLAY is not available."
  fi
done

# Display not found, exit with an error
if [ -z "$DISPLAY_DEVICE" ]; then
  echo "Error: No available X display found."
  # exit 1
fi

# check if sudo is needed
if id -nG "$USER" | grep -qw "docker"; then
	SUDO=""
else
	SUDO="sudo"
fi

if dpkg -l | grep -q nvidia-container-toolkit; then
    echo "NVIDIA Container Toolkit is installed."
else
    curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | $SUDO gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
	&& curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
		sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
		$SUDO tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

	sed -i -e '/experimental/ s/^#//g' /etc/apt/sources.list.d/nvidia-container-toolkit.list
	sudo apt-get update
	sudo apt-get install -y nvidia-container-toolkit

	sudo nvidia-ctk runtime configure --runtime=docker
	sudo systemctl restart docker
fi

# run the container
ARCH=$(uname -i)
CONTAINER=lozanomt/ubuntu:ros2-iron

if [ $ARCH = "aarch64" ]; then
	set -x
	$SUDO docker run --runtime nvidia -it --network host \
		--privileged \
		$DISPLAY_DEVICE \
        $V4L2_DEVICES \
		$CONTAINER

elif [ $ARCH = "x86_64" ]; then
	set -x
	$SUDO docker run --gpus all -it --network host \
		--privileged \
		$DISPLAY_DEVICE \
		$V4L2_DEVICES \
		$CONTAINER
fi