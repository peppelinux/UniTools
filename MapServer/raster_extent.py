#!/usr/bin/env python

# Copyright 2007 Regents of the University of California
# Written by David Isaacson at the University of California, Davis
# BSD License

import gdal, os
import sys
from gdalconst import *

def findGDALCoordinates(path):
    if not os.path.isfile(path):
        return []
    data = gdal.Open(path,GA_ReadOnly)
    if data is None:
        return []
    geoTransform = data.GetGeoTransform()
    minx = geoTransform[0]
    maxy = geoTransform[3]
    maxx = minx + geoTransform[1]*data.RasterXSize
    miny = maxy + geoTransform[5]*data.RasterYSize
    return [minx,miny,maxx,maxy]


if __name__ == '__main__':
    extent = findGDALCoordinates(sys.argv[1])
    print(extent)
