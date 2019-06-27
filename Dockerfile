FROM hasboeuf/raspbian:2018-11-13-raspbian-stretch-lite

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
	# Essentials
	build-essential \
	libfontconfig1-dev \
	libdbus-1-dev \
	libfreetype6-dev \
	libicu-dev \
	libinput-dev \
	libxkbcommon-dev \
	libsqlite3-dev \
	libssl-dev \
	libpng-dev \
	libjpeg-dev \
	libglib2.0-dev \
	libraspberrypi-dev \
	# Bluetooth
	bluez \
	libbluetooth-dev \
	# Multimedia
	libgstreamer1.0-dev \
	libgstreamer-plugins-base1.0-dev \
	gstreamer1.0-plugins-base \
	gstreamer1.0-plugins-good \
	gstreamer1.0-plugins-ugly \
	gstreamer1.0-plugins-bad \
	libgstreamer-plugins-bad1.0-dev \
	gstreamer1.0-pulseaudio \
	gstreamer1.0-tools \
	gstreamer1.0-alsa \
	# ALSA
	libasound2-dev \
	pulseaudio \
	libpulse-dev \
	# Database
	libpq-dev \
	libmariadbclient-dev \
	# Printing
	libcups2-dev \
	# Wayland
	libwayland-dev \
	# X11
	libx11-dev \
	libxcb1-dev \
	libxkbcommon-x11-dev \
	libx11-xcb-dev \
	libxext-dev \
	# Accessibility
	libatspi-dev \
	# SCTP
	libsctp-dev \
	# SSH
	openssh-server

RUN ln -s /opt/vc/lib/libbrcmEGL.so /opt/vc/lib/libEGL.so && \
	ln -s /opt/vc/lib/libbrcmGLESv2.so /opt/vc/lib/libGLESv2.so && \
	ln -s /opt/vc/lib/libbrcmOpenVG.so /opt/vc/lib/libOpenVG.so && \
	ln -s /opt/vc/lib/libbrcmWFC.so /opt/vc/lib/libWFC.so

# Setup ssh server
RUN mkdir /var/run/sshd
EXPOSE 22

# Remove default `pi` user
RUN deluser --remove-home pi

# Create worker user with same permissions than the caller of `build` script.
ARG UID=1000
ARG GID=1000
ENV USER worker
RUN groupadd --force --gid $GID worker
RUN useradd --create-home --gid $GID --uid $UID $USER --shell /bin/bash && \
    echo "$USER:worker" | chpasswd && \
    echo "worker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

WORKDIR /home/$USER
USER worker

# Back to root to run sshd
WORKDIR /
USER root

CMD ["/usr/sbin/sshd", "-D"]
