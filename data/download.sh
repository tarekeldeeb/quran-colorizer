#!/bin/bash

FLD_TAJ_COL=tajweed_color
FLD_TAJ_GRY=tajweed_gray
FLD_MAD_GRY=madina_gray

git clone --depth 1 https://github.com/tarekeldeeb/madina_images.git -b w1024 $FLD_MAD_GRY

mkdir $FLD_TAJ_COL
mkdir $FLD_TAJ_GRY
cd $FLD_TAJ_COL
echo "Downloading Images .."
for i in `seq 3 604` ; do
  outf=CTaj_page$(printf "%03d" $i).jpg
  outgf=GTaj_page$(printf "%03d" $i).png
  wget https://easyquran.com/quran-jpg/images/$i.jpg -O $outf
  if [ $((i%2)) -eq 0 ]; then 
    mogrify -crop 610x904+128+40 $outf; #even pages 
  else 
    mogrify -crop 610x904+32+40 $outf; #odd pages 
  fi
  convert $outf  -depth 4 -colorspace gray -define png:color-type=0 -define png:bit-depth=4 -level 75%,85% ../$FLD_TAJ_GRY/$outgf
done
cd .. && echo "Done!"
