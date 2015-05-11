# docker-vmware-view
Hack to get vmware-view running within a docker container. 

This simple script creates the necessary files need to launch vmware-view

I created this script because vmware-view on OpenSuse was unable to establish a connection with the Horizon server

Since folks at work use Ubuntu and were able to get this working it gave me the idea to dockerize vmware-view

This script makes quite a few assumptions

## Usage 

* Run the following script

sh -x vmware-view-builder.sh

If run successfully is will create a number of directories and files on of which is "launch.sh"

* Run the launch script

sh -x launch.sh 


