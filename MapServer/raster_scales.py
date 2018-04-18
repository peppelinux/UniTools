import sys
from osgeo import gdal

def get_scales(_min, _max, steps=5):
    dif = (_max - _min) / float(steps)
    scales = []
    for i in range(steps):
        scales.append( _min + (dif*(i+1)) )
    return scales

# example
# get min and max from gdalinfo

if __name__ == '__main__':
    gtif = gdal.Open(sys.argv[1])
    srcband = gtif.GetRasterBand(1)
   
    # Get raster statistics
    stats = srcband.GetStatistics(True, True)
    
    scales = get_scales(stats[0], stats[1])
    print(scales)
