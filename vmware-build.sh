#!/bin/bash

set -x

_user=$(id -un)
_e_grp=$(id -gn)
_uid=$(id -u)
_e_gid=$(id -g)
UPLOADDIR=/home/$_user/.vmware-upload
IMAGE="$(hostname)/local/vmware-view:latest"

mkdir /tmp/vmware-$_user -p
mkdir $HOME/.vmware -p
mkdir $UPLOADDIR -p 

cat <<EOF > launch.sh && chmod 0700 launch.sh
#!/bin/bash
set -x
xhost si:localuser:$_user
docker run --rm=true --name vmware-view --dns 8.8.8.8 -ti \ 
  -v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0:ro \
  -v $HOME/.Xauthority:$HOME/.Xauthority:ro \ 
  -v /tmp/vmware-$_user:/tmp/vmware-$_user  \ 
  -v $HOME/.vmware:$HOME/.vmware \ 
  -v $UPLOADDIR:$UPLOADDIR $IMAGE 
EOF

cat <<EOF > vmware-view.sh 
/usr/bin/vmware-view --rdpclient=rdesktop --rdesktopOptions="-r disk:share=$UPLOADDIR"
EOF

[[ ! -x $UPLOADDIR/vmware-view.sh ]] && chmod 0700 $UPLOADDIR/.vmware-view.sh 
 
cat <<EOF > Dockerfile
#
FROM ubuntu:14.04
MAINTAINER Chinedu Uzoka <acuzoka@gmail.com>
RUN dpkg --add-architecture i386
RUN apt-get update -y \ 
  && apt-get install -y software-properties-common \
  && add-apt-repository 'deb http://archive.canonical.com/ubuntu trusty partner'  
RUN apt-get update && apt-get install -y vmware-view-client rdesktop
RUN adduser --disabled-password --gecos "" --gid $_e_gid --uid $_uid $_user
RUN touch /home/$_user/.vmware-view-client.license-accepted && chown $_uid /home/$_user/.vmware-view-client.license-accepted
ENV DISPLAY=":0"

USER $_user
RUN mkdir -p /usr/local/bin
WORKDIR /home/$_user
#CMD /bin/bash
COPY vmware-view.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/vmware-view.sh"]
EOF

