#!/bin/bash

## Generate the data
# change config time-reduction-factor to 1 and fine-grid-factor to 12
FILE='3ec81972a93bd5b7efb96fff8f32a128e879b6ea'
#for i in 0x9 0x8 0x7 0x6 0x5 0x4 0x3 0x2 0x1
#    do ~/Projekte/feltor/src/feltor/interpolate_in_3d ../data-analysis-3d/config.json ../resistivity-new-data/$FILE$i.nc ../resistivity-new-plot-uncompressed/$FILE$i.nc
#done
#~/Projekte/feltor/src/feltor/interpolate_in_3d ../data-analysis-3d/config.json ../resistivity-new-data/$FILE.nc ../resistivity-new-plot-uncompressed/$FILE.nc

## and the pictures
#SCRIPT='electrons-isovolume-light-below-extract.py'
#VIDEO='electrons-isovolume-light.mp4'

#SCRIPT='electrons-isovolume-dark-03-extract.py'
#VIDEO='electrons-isovolume-dark.mp4'

SCRIPT='electrons-isovolume-24-extract.py'
VIDEO='electrons-isovolume-24.mp4'
### In order to convert pvsm file to make a video:
### 1. Change Progressive Passes to 1 and Samples per Pixel to 10
### 2.1 Add Annotate Time Filter ( {time:.3f} ms, scale: 5.18e-5, Lower Right corner, Font 30, black)
### 2.2 Add PNG extractor (No compression, do not scale fonts)
### 3. Save State as py (Leave  defaults)
### 4. Open py file and change
###     import sys
###     Copy main function from electrons-isovolume-15-extract.py
###     Change SamplesPerPixel from 10 back to 1000
###     remove custom_kernel
###     in NetCDF reader change filename=sys.argv[1]
###     Change Isovolume upper boundary to 15 (to avoid black holes in middle)
### 5. Test by running pvpython script.py [file] extracts

### For dark background in script you need to
### Make paraview show Axis grid in order to turn it off again
### Visibility = 0
#### In Color Bar
### TitleColor = [1.0, 1.0, 1.0]
### LabelColor = [1.0, 1.0, 1.0]
### Will overwrite existing files
### Change colorscale upper boundary to ?? (12?)
#### in PNG
### forcing it to 1920 x 1080 may lead to wrong pictures, better leave and scale afterwards in ffmpeg
for i in 0x9 0x8 #0x7 0x6 0x5 0x4 0x3 0x2 0x1
#for i in 0x1 0x2 0x3 0x4 0x5 0x6 0x7 0x8 0x9
    do pvpython $SCRIPT ../resistivity-new-plot-uncompressed/$FILE$i.nc electrons-isovolume$i
done
pvpython $SCRIPT ../resistivity-new-plot-uncompressed/$FILE.nc electrons-isovolume0x0

# Create individual videos in ts format (because that format can be easily concatenated)
for i in 0x0 0x1 0x2 0x3 0x4 0x5 0x6 0x7 0x8 0x9
    do cd electrons-isovolume$i
    # We need to get the aspect ratio right to 16:9
    #https://superuser.com/questions/547296/resizing-videos-with-ffmpeg-avconv-to-fit-into-static-sized-player
    ffmpeg -framerate 20 -pattern_type glob -i 'RenderView1_*.png' -vf "scale='min(1920,iw)':'min(1080,ih)':force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=white" -c:v libx264 -pix_fmt yuv420p electrons-isovolume$i.ts
    #ffmpeg -framerate 20 -pattern_type glob -i 'RenderView1_*.png' -vf "scale='min(1920,iw)':'min(1080,ih)':force_original_aspect_ratio=decrease,pad=1920:1080:-1:-1:color=0x170000" -c:v libx264 -pix_fmt yuv420p electrons-isovolume$i.ts
    #ffmpeg -framerate 20 -pattern_type glob -i 'RenderView1_*.png' -c:v libx264 -pix_fmt yuv420p electrons-isovolume$i.ts
    cd ..
done

# Concatenate to one video
# remove existing one
rm $VIDEO
for i in 0x0 0x1 0x2 0x3 0x4 0x5 0x6 0x7 0x8 0x9
    do echo "file 'electrons-isovolume$i/electrons-isovolume$i.ts'" >> mylist.txt
done
ffmpeg -f concat -i mylist.txt -c copy $VIDEO
# Clean up
for i in 0x0 0x1 0x2 0x3 0x4 0x5 0x6 0x7 0x8 0x9
    do cd electrons-isovolume$i
        rm electrons-isovolume$i.ts
    cd ..
done
rm mylist.txt

## For IOP to accept videos it must
# - MPEG-4 encoded with H264 codec
# - max 10MB size
# - 15 frames / s
# - 480 x 360 px
# - 150 kB / s
## (Maybe convert resulting video to that, cut 2nd half to get to size limitation)
