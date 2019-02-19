#!/bin/bash 

# ------------------------------------
# Download Tiles and save to one Image (based on https://opentopomap.org/files/montage.sh)
# Prerequisites:  
# * This sh file is expected in C:\progs\limexMapDownloader
# * In the same folder: awk (download from http://gnuwin32.sourceforge.net/packages/gawk.htm)
# * and ImageMagick () is expected in folder C:\progs\ImageMagick
# What it does:
# * Script stores the tiles in /in Folder and deletes them before the next run for the selected Map and zoom
# * Script stores the merged map in /out and adds a scale bar at the lower right corner
# What you need to config for each map download:
# * Change the Lat Long "Box" of the downloadable Map (Line 87 and 88)
# * Change the Zoom (Line 102): i.e. Z=15  
# * Change the Tile Server (Line 120): Uncomment i.e. Line with TILE_NAME="SigmaCycle"; .....
# ------------------------------------

# ------------------------------------
# Functions (from https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Lon..2Flat._to_tile_numbers)
# ------------------------------------

xtile2long()
{
 xtile=$1
 zoom=$2
 echo "${xtile} ${zoom}" | awk '{printf("%.9f", $1 / 2.0^$2 * 360.0 - 180)}'
} 

long2xtile()  
{ 
 long=$1
 zoom=$2
 echo "${long} ${zoom}" | awk '{ xtile = ($1 + 180.0) / 360 * 2.0^$2; 
  xtile+=xtile<0?-0.5:0.5;
  printf("%d", xtile ) }'
}

ytile2lat()
{
 ytile=$1;
 zoom=$2;
 tms=$3;
 if [ ! -z "${tms}" ]
 then
 #  from tms_numbering into osm_numbering
  ytile=`echo "${ytile}" ${zoom} | awk '{printf("%d\n",((2.0^$2)-1)-$1)}'`;
 fi
 lat=`echo "${ytile} ${zoom}" | awk -v PI=3.14159265358979323846 '{ 
       num_tiles = PI - 2.0 * PI * $1 / 2.0^$2;
       printf("%.9f", 180.0 / PI * atan2(0.5 * (exp(num_tiles) - exp(-num_tiles)),1)); }'`;
 echo "${lat}";
}

lat2ytile() 
{ 
 lat=$1;
 zoom=$2;
 tms=$3;
 ytile=`echo "${lat} ${zoom}" | awk -v PI=3.14159265358979323846 '{ 
   tan_x=sin($1 * PI / 180.0)/cos($1 * PI / 180.0);
   ytile = (1 - log(tan_x + 1/cos($1 * PI/ 180))/PI)/2 * 2.0^$2; 
   ytile+=ytile<0?-0.5:0.5;
   printf("%d", ytile ) }'`;
 if [ ! -z "${tms}" ]
 then
  #  from oms_numbering into tms_numbering
  ytile=`echo "${ytile}" ${zoom} | awk '{printf("%d\n",((2.0^$2)-1)-$1)}'`;
 fi
 echo "${ytile}";
}

lat2tile_dist()
{ lat=$1;
  zoom=$2;
  echo "${lat} ${zoom}" | awk -v PI=3.14159265358979323846 '{ dist = 40075017.0 * cos($1 * PI / 180) / 2.0^$2; printf("%d", dist ) }'
}

# ------------------------------------
# Main
# ------------------------------------

# ------------------------------------
# Fill the Coordinate of the Box
# ------------------------------------

# Paste the the "Copy Position (Grid)" from i.e. QMapShack
LATLONG1="46.698312 15.006967"
LATLONG2="46.675872 15.052422"

LAT1=`echo "${LATLONG1}" | awk '{split($0,a," "); printf ("%f",a[1])}'`;
LONG1=`echo "${LATLONG1}" | awk '{split($0,a," "); printf ("%f",a[2])}'`;

LAT2=`echo "${LATLONG2}" | awk '{split($0,a," "); printf ("%f",a[1])}'`;
LONG2=`echo "${LATLONG2}" | awk '{split($0,a," "); printf ("%f",a[2])}'`;

# Uncomment if you want to use Lat Long seperately
#LONG1=15.382761;
#LAT1=47.231169;
#LONG2=15.539048;
#LAT2=47.194697;

Z=15; #best for A3 Prints: 15, Resulting in a Print Zoom of 50%

TMS=""; # when NOT empty: tms format assumed

X1=$( long2xtile ${LONG1} ${Z} );
Y1=$( lat2ytile ${LAT1} ${Z} ${TMS} );
X2=$( long2xtile ${LONG2} ${Z} );
Y2=$( lat2ytile ${LAT2} ${Z} ${TMS} );
SCALE=$( lat2tile_dist ${LAT1} ${Z} );

TILE_TOTAL=$(( (X2-X1+1) * (Y2-Y1+1) ));
TILE_LOOP=1;

echo "Download from ${LONG1}/${LAT1} -> ${X1}/${Y1}"
echo "         to ${LONG2}/${LAT2} -> ${X2}/${Y2}"
echo "Start Download of ${TILE_TOTAL} Tiles"

# QMapShack Sequence: /%1/%2/%3 -> ZXY, /%1/%3/%2 -> ZYX
TILE_NAME="SigmaCycle"; TILE_URL="https://tiles1.sigma-dc-control.com/layer8/"; TILE_ST="ZXY"; TILE_PRE="sc_"; TILE_EXT="png"; 
#TILE_NAME="OpenTopo"; TILE_URL="https://b.tile.opentopomap.org/"; TILE_ST="ZXY"; TILE_PRE="ot_"; TILE_EXT="png";
#TILE_NAME="BergfexOSM"; TILE_URL="http://maps.bergfex.at/osm/standard/"; TILE_ST="ZXY"; TILE_PRE="bf-osm_"; TILE_EXT="jpg";  #Max Zoom: 16
#TILE_NAME="OutdoorActWinter"; TILE_URL="https://w2.outdooractive.com/map/AlpsteinWinter/"; TILE_ST="ZXY"; TILE_PRE="oa-w_"; TILE_PARA="?project=alpenverein" TILE_EXT="png";
#TILE_NAME="ThunderFKomoot"; TILE_URL="https://c.tile.hosted.thunderforest.com/komoot-2/"; TILE_ST="ZXY"; TILE_PRE="tf-kom_"; TILE_EXT="png"; 
#TILE_NAME="MTBCZ"; TILE_URL="http://tile.mtbmap.cz/mtbmap_tiles/"; TILE_ST="ZXY"; TILE_PRE="mtb_"; TILE_EXT="png"; 

rm -f ./in/${TILE_PRE}${Z}_*.${TILE_EXT} # Delete old in-Files for the current Map and current zoom
rm -f ./in/__*.${TILE_EXT} # Delete old temp File for the Scale


for x in `seq $X1 $X2`; do
    for y in `seq $Y1 $Y2`; do
	if [ -e in/${TILE_PRE}${Z}_${y}_${x}.${TILE_EXT} ]
		then
    		echo "${TILE_LOOP}/${TILE_TOTAL}   Keep '${TILE_NAME}' ${TILE_PRE}${Z}_${y}_${x}.${TILE_EXT}"
	else
		#echo "${TILE_LOOP}/${TILE_TOTAL}   Getting '${TILE_NAME}' ${x},${y}"
		echo "${TILE_LOOP}/${TILE_TOTAL}  ${TILE_URL}${Z}/${x}/${y}.${TILE_EXT}${TILE_PARA}  Getting '${TILE_NAME}' ${x},${y}"
			curl -s ${TILE_URL}${Z}/${x}/${y}.${TILE_EXT}${TILE_PARA} -o in/${TILE_PRE}${Z}_${y}_${x}.${TILE_EXT} &
		wait
	fi
	TILE_LOOP=$(( TILE_LOOP+1 ));
    done
done

echo "Scale of Tile: ${SCALE}m"
# lower right corner
SCALE_POSX=$(( X2 ));
SCALE_POSY=$(( Y2 ));

if [ ${TILE_EXT} = "jpg" ] 
then
	c:/progs/ImageMagick/convert.exe in/${TILE_PRE}${Z}_${SCALE_POSY}_${SCALE_POSX}.jpg in/${TILE_PRE}${Z}_${SCALE_POSY}_${SCALE_POSX}.png
fi
# draw scale over 6/8 of the width -> x: 31 to 223
SCALE=$(( SCALE/8*6 ));
c:/progs/ImageMagick/convert.exe -size 256x256 xc:none \
	-stroke black -strokewidth 6 -draw "line 31,150 223,150" -stroke white -strokewidth 2 -draw "line 31,150 223,150" \
	in/__scale.png
c:/progs/ImageMagick/convert.exe -background none -fill blue -font Arial -size 256x256 -gravity center -pointsize 40 label:"${SCALE}m" \
	in/__scale-txt.png
c:/progs/ImageMagick/composite.exe -watermark 50% -gravity center in/__scale.png in/${TILE_PRE}${Z}_${SCALE_POSY}_${SCALE_POSX}.png in/__tile_scale.png
c:/progs/ImageMagick/composite.exe -watermark 50% -gravity center in/__scale-txt.png in/__tile_scale.png in/__tile_scale_txt.png

if [ ${TILE_EXT} = "jpg" ] 
then
	c:/progs/ImageMagick/convert.exe in/__tile_scale_txt.png in/${TILE_PRE}${Z}_${SCALE_POSY}_${SCALE_POSX}.jpg
else
	c:/progs/ImageMagick/convert.exe in/__tile_scale_txt.png in/${TILE_PRE}${Z}_${SCALE_POSY}_${SCALE_POSX}.png
fi

echo "Start montage"
c:/progs/ImageMagick/montage.exe -limit thread 8 -limit memory 30000MB -mode concatenate -tile "$((X2-X1+1))x" "in/${TILE_PRE}${Z}_*.${TILE_EXT}" out/map_${TILE_NAME}_${Z}_${X1}_${Y1}-${X2}_${Y2}.${TILE_EXT}

read -p "Finished. Press enter to End Script"