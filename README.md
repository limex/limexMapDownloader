# limexMapDownloader
Bash Script to download TMS Tiles and merge them for easy Printing with Scale Bar. 

### Prerequisites:  
* This .sh file is expected in C:\progs\limexMapDownloader
* Place in the same folder: awk (download from http://gnuwin32.sourceforge.net/packages/gawk.htm)
* Also ImageMagick () is expected in folder C:\progs\ImageMagick
### What it does:
* Script stores the tiles in /in Folder and deletes them before the next run for the selected Map and zoom
* Script stores the merged map in /out and adds a scale bar at the lower right corner
### What you need to config for each map download:
* Change the Lat Long "Box" of the downloadable Map (Line 87 and 88)
* Change the Zoom (Line 102): i.e. Z=15  
* Change the Tile Server (Line 120): Uncomment i.e. Line with TILE_NAME="SigmaCycle"; .....

### Code is based on:
https://opentopomap.org/files/montage.sh
Some Functions from https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Lon..2Flat._to_tile_numbers

### Remarks:
This is my first bash file, so please dont expect a masterpiece.
I used bash because the original downloader idea was in bash. Working with it I realized that some things are not as I expected.
The script is a quick and dirty hack to get the stuff done: Get a printable A3 Map without downloading expensive Apps or paying for printing service.
Everyone in invited to extend and change the code.

### Screenshots
Resulting Map with Scalebar in lower right corner:
![Resulting Map with Scalebar](https://github.com/limex/limexMapDownloader/blob/master/out/map_BergfexOSM_16_35500_23131-35508_23137.jpg)
