#!/bin/sh

set -e # Comment if you do not want to stop the script when some command failed

echo "Please download CUDA8 from https://developer.nvidia.com/cuda-release-candidate-download"

read -p " Press [enter] when finished "

echo "Please download cuDNN5.1 from https://developer.nvidia.com/rdp/cudnn-download"

read -p " Press [enter] when finished"

echo "Installing dependencies..."

sudo apt-get install -y build-essential cmake git pkg-config

sudo apt-get install -y libprotobuf-dev libleveldb-dev libsnappy-dev libhdf5-serial-dev protobuf-compiler

sudo apt-get install -y libatlas-base-dev

sudo apt-get install -y --no-install-recommends libboost-all-dev

sudo apt-get install -y libgflags-dev libgoogle-glog-dev liblmdb-dev

sudo apt-get install -y python-pip

sudo apt-get install -y python-dev

sudo apt-get install -y python-numpy python-scipy

sudo apt-get install -y libopencv-dev

echo "Installing CUDA..."
sudo dpkg -i cuda-repo-ubuntu1604-8-0-rc_8.0.27-1_amd64.deb

sudo apt-get update

sudo apt-get install cuda

sudo apt-get install cuda-drivers

echo 'export LD_LIBRARY_PATH=/usr/local/cuda-8.0/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc

source ~/.bashrc

cd /usr/local/cuda-8.0/samples/

read -p "Please, open with software install (double click) the patch 1 you just downloaded: cuda-misc-headers-8-0_8.0.27.1-1_amd64.deb"

sudo make all -j $(($(nproc) + 1))

echo "Installing CUDNN..."
mkdir ~/code
cd ~/code
tar -xvzf cudnn-8.0-linux-x64-v5.1.tgz
cd cuda/lib64/
sudo cp lib* /usr/local/cuda-8.0/lib64/
cd cuda/include/
sudo cp cudnn.h /usr/local/cuda-8.0/include/

echo "Installing caffe"
cd code
git clone https://github.com/BVLC/caffe.git
cd caffe/python/
for req in $(cat requirements.txt); do sudo -H pip install $req --upgrade; done
sudo apt-get update
export PYTHONPATH=~/code/caffe/python:$PYTHONPATH
cd ..
cp Makefile.config.example Makefile.config

echo "Please, modify Makefile.config to fit your requirements. Default modifications are the following: \n USE_CUDNN := 1 \n WITH_PYTHON_LAYER:=1 \n CUDA_DIR:=/usr/local/cuda-8.0 \n PYTHON_INCLUDE := /usr/include/python2.7 /usr/lib/python2.7/dist-packages/numpy/core/include \n INCLUDE_DIRS := $(PYTHON_INCLUDE) /usr/local/include /usr/include/hdf5/serial \n LIBRARY_DIRS := $(PYTHON_LIB) /usr/local/lib /usr/lib /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/hdf5/serial \n "

read -p "Please, press [enter] when you have finished of modifying the file"

cd caffe/build
cmake ..
cd code/caffe
make all -j8
make test
sudo reboot
make runtest
cd code/caffe
make pycaffe
make distribute

echo "Finished! Try to import caffe on python to ensure that everything is working."
