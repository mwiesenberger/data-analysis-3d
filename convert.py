import numpy as np
import json
from bs4 import BeautifulSoup
import matplotlib.colors as mcolors

def xml2cmap( file, name='custom-colormap') :
    """Converts a paraview compatible colormap xml file to a matplotlib colormap

    https://www.paraview.org/Wiki/Colormaps
    Parameters
    ----------
    file: file-like
        xml file containing colormap
    name: str
        name to give to the colormap.
    Returns
    -------
    cmap : matplotlib.colors.LinearSegmentedColormap
    """
    soup = BeautifulSoup(open(file), 'xml')
    unified = []
    for s in soup.find_all('Point'):
        position  = float(s['x'])
        color = (float(s['r']),float(s['g']),float(s['b']))
        unified.append( (position, color))
#duplicate entry if x!=0
    if unified[0][0] != 0:
        print( "WARNING: first position not zero in colormap; duplicating first entry")
        unified.insert( 0, (0, unified[1][1]))
    if unified[-1][0] != 1:
        print( "WARNING: last position not one in colormap, duplicating last entry")
        unified.append( (1, unified[-1][1]))

    return mcolors.LinearSegmentedColormap.from_list( name, unified)

def cmap2json(  cmap, file):
    """ Create a json file that can be imported into paraview

    Format inferred from paraview's export function
    Parameters
    ----------
    cmap : matplotlib.colors.Colormap
    file: file-like
        json file name where the colormap is written

    """
    gradient= np.linspace( 0,1, cmap.N)
    xrgb_list = []
    for g in gradient:
        rgb = mcolors.to_rgb( cmap(g))
        xrgb_list.append( (g, rgb[0],rgb[1],rgb[2])) # x r g b

    pc = [{"Colorspace": "User",
           "Creator": "Matthias",
           "Name" : cmap.name,
           "RGBPoints" : list( sum(xrgb_list,())) # flatten list
          }]
    with open( file, "w") as f:
        json.dump(pc, f, indent=4 )
