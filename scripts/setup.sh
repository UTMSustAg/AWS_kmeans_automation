#!/bin/bash
echo "Starting update of packages..."
sudo apt-get update -y
#Install gdal
echo "Installing gdal..."
sudo apt-get install gdal-bin proj-bin libgdal-dev libproj-dev -y
#Install R
echo "Starting install of R..."
echo "Installing dependancies..."
sudo apt install dirmngr gnupg apt-transport-https ca-certificates software-properties-common -y
echo "Adding CRAN repo to system sources..."
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
echo "Installing R..."
sudo apt install r-base -y
R --version
