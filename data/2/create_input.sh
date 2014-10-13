#!/usr/bin/env sh
# Create the imagenet leveldb inputs
# N.B. set the path to the imagenet train + val data dirs

#TOOLS=~/Repositories/caffe/build/tools

TRAIN_DATA_ROOT=./img/
VAL_DATA_ROOT=./img/

# Set RESIZE=true to resize the images to 256x256. Leave as false if images have
# already been resized using another tool.
RESIZE=false
if $RESIZE; then
  RESIZE_HEIGHT=256
  RESIZE_WIDTH=256
else
  RESIZE_HEIGHT=0
  RESIZE_WIDTH=0
fi

if [ ! -d "$TRAIN_DATA_ROOT" ]; then
  echo "Error: TRAIN_DATA_ROOT is not a path to a directory: $TRAIN_DATA_ROOT"
  echo "Set the TRAIN_DATA_ROOT variable in create_imagenet.sh to the path" \
       "where the ImageNet training data is stored."
  exit 1
fi

if [ ! -d "$VAL_DATA_ROOT" ]; then
  echo "Error: VAL_DATA_ROOT is not a path to a directory: $VAL_DATA_ROOT"
  echo "Set the VAL_DATA_ROOT variable in create_imagenet.sh to the path" \
       "where the ImageNet validation data is stored."
  exit 1
fi

echo "Creating train leveldb..."

GLOG_logtostderr=1 $CAFFETOOLS/convert_imageset \
    -backend "leveldb" \
    $TRAIN_DATA_ROOT \
    ./labels_training.txt \
    lehedge_train_leveldb
#    $RESIZE_HEIGHT $RESIZE_WIDTH

echo "Creating val leveldb..."

GLOG_logtostderr=1 $CAFFETOOLS/convert_imageset \
    -backend "leveldb" \
    $VAL_DATA_ROOT \
     ./labels_validation.txt \
    lehedge_val_leveldb
#    $RESIZE_HEIGHT $RESIZE_WIDTH

echo "Done."
