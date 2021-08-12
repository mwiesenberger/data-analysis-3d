#!/bin/bash

: ${FELTOR_PATH:="../feltor"}
# If feltor is not here then change the FELTOR_PATH enviromnent variable
# export FELTOR_PATH="path/to/feltor"

make -C $FELTOR_PATH/src/feltor/ interpolate_in_3d device=omp

input=$(echo $2 | sed -e 's/plot/data/')

$FELTOR_PATH/src/feltor/interpolate_in_3d "config.json" $input $2
