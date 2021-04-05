#!/bin/bash

#Check Dependencies
commands=('git' 'convert' 'parallel')
for c in "${commands[@]}"; do
  if ! command -v $c &> /dev/null ; then
      echo "Command: $c could not be found. Please install then rerun."
      exit
  fi
done

FLD_DATASET=quran_color
FLD_TAJ_COL=tajweed_color
FLD_TAJ_GRY=tajweed_gray
FLD_MAD_GRY=madina_gray

git clone --depth 1 https://github.com/tarekeldeeb/madina_images.git -b w1024 $FLD_MAD_GRY

mkdir -p $FLD_DATASET/test
mkdir -p $FLD_DATASET/train
mkdir -p $FLD_DATASET/val
mkdir $FLD_TAJ_COL
mkdir $FLD_TAJ_GRY
cd $FLD_TAJ_COL

echo "Downloading Images for Training.." 
seq 3 604   | parallel wget -nv https://easyquran.com/quran-jpg/images/{}.jpg -O CTaj_page_{}.jpg;

echo "Cropping Images .."
seq 4 2 604 | parallel --bar mogrify -crop 610x904+128+40 CTaj_page_{}.jpg; #even pages 
seq 3 2 604 | parallel --bar mogrify -crop 610x904+32+40 CTaj_page_{}.jpg; #odd pages 

echo "Generating Gray Images .."
seq 3 604   | parallel --bar convert CTaj_page_{}.jpg -depth 4 -colorspace gray -define png:color-type=0 -define png:bit-depth=4 -level 75%,85% ../$FLD_TAJ_GRY/GTaj_page_{}.png;

echo "Merging Training Images .."
seq 11 10 604 | parallel --bar convert CTaj_page_{}.jpg ../$FLD_TAJ_GRY/GTaj_page_{}.png \+append ../$FLD_DATASET/test/{}.jpg;
seq 11 10 604 | parallel --bar rm -f CTaj_page_{}.jpg ../$FLD_TAJ_GRY/GTaj_page_{}.png
seq 12 10 604 | parallel --bar convert CTaj_page_{}.jpg ../$FLD_TAJ_GRY/GTaj_page_{}.png \+append ../$FLD_DATASET/val/{}.jpg;
seq 12 10 604 | parallel --bar rm -f CTaj_page_{}.jpg ../$FLD_TAJ_GRY/GTaj_page_{}.png
ls | grep -oP 'CTaj_page_\K\w+' |  parallel --bar convert CTaj_page_{}.jpg ../$FLD_TAJ_GRY/GTaj_page_{}.png \+append ../$FLD_DATASET/train/{}.jpg;

cd .. && rm -fr $FLD_TAJ_COL $FLD_TAJ_GRY
echo "Dataset is now ready!"
