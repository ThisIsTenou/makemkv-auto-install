#!/bin/bash

if [ $USER != root ]; then
		echo "This script needs to be executed with sudo!"
		exit 1
fi
read -p 'Please enter the MKV version you would like to install: ' version
if ! curl -s --head https://www.makemkv.com/download/makemkv-bin-$version.tar.gz | head -n 1 | grep -q 200; then
	echo "Invalid version number!"
	exit 1
fi
prefix="makemkv-$(date +"%s")"
mkdir /tmp/$prefix
apt-get update
apt-get install -y build-essential pkg-config libc6-dev libssl-dev libexpat1-dev libavcodec-dev libgl1-mesa-dev qtbase5-dev zlib1g-dev nasm libfdk-aac-dev sed wget curl tar setcd
wget -q --show-progress -O /tmp/$prefix/makemkv-bin.tar.gz https://www.makemkv.com/download/makemkv-bin-$version.tar.gz
wget -q --show-progress -O /tmp/$prefix/makemkv-oss.tar.gz https://www.makemkv.com/download/makemkv-oss-$version.tar.gz
wget -q --show-progress -O /tmp/$prefix/ffmpeg.tar.bz2 https://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar -xf /tmp/$prefix/ffmpeg.tar.bz2 -C /tmp/$prefix/
tar -xf /tmp/$prefix/makemkv-oss.tar.gz -C /tmp/$prefix/
tar -xf /tmp/$prefix/makemkv-bin.tar.gz -C /tmp/$prefix/
/tmp/$prefix/ffmpeg/configure --prefix=/tmp/$prefix/ffmpeg-temp --enable-static --disable-shared --enable-pic --enable-libfdk-aac
cd /tmp/$prefix/ffmpeg
make install
cd /tmp/$prefix/makemkv-oss-$version
PKG_CONFIG_PATH=/tmp/$prefix/ffmpeg-temp/lib/pkgconfig ./configure
make
make install
cd /tmp/$prefix/makemkv-bin-$version
make
sudo make install
mkdir -p /home/$SUDO_USER/.MakeMKV
mkdir -p /home/$SUDO_USER/Videos
touch /home/$SUDO_USER/.MakeMKV/settings.conf
tee -a /home/$SUDO_USER/.MakeMKV/settings.conf > /dev/null <<EOT
app_DefaultOutputFileName = "{NAME2}{-:CMNT2}{-:DY}{unknown-title:+DFLT}{_t:AN2}"
pp_DestinationDir = "$(realpath ~/Videos)"
app_DestinationType = "3"
app_ExpertMode = "1"
app_InterfaceLanguage = "eng"
echo "app_Key = \"$(curl -s https://www.makemkv.com/forum/viewtopic.php?t=1053 | grep -o -P '(?<=\<code\>).*(?=\<\/code\>)')\""
dvd_MinimumTitleLength = "120"
io_SingleDrive = "1"
EOT
chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.MakeMKV/settings.conf
rm -rf /tmp/$prefix
