%
%   This example code illustrates how to access and visualize LaRC
%   ASDC MISR L1B2 HDF-EOS2 Grid SOM pojrection file in MATLAB. 
%
%   If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%   If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024_hdf
%
% Tested under: MATLAB R2014a
% Last updated: 2021-09-02

clear

% Open the HDF-EOS2 Grid File.
FILE_NAME='MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read dataset.
GRID_NAME='BlueBand';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='Blue Radiance/RDQI';


[data3D, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

[xdimsize, ydimsize, upleft, lowright, status] = ...
    hdfgd('gridinfo', grid_id);

% Read scale factor attribute.
[scale, status] = hdfgd('readattr', grid_id, 'Scale factor');
scale_factor = scale(1);

% Read fill value attribute.
[fill_value,status] = hdfgd('getfillvalue',grid_id, DATAFIELD_NAME);


% Detach from the grid object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

% We need to shift bits for "RDQI" to get "Blue Band "only. 
% See the page 105 of "MISR Data Products Specifications (rev. M)".
% The document is available at [1].
data3Ds = bitshift(data3D, -2);

% Change short type to float for fill value processing.
data3Df = double(data3Ds);

% Replace the fill values with NaN.
data3Df(data3D==fill_value) = NaN;

% Filter out values (> 16376) used for "Flag Data".
% See Table 1.2 in "Level 1 Radiance Scaling and Conditioning
% Algorithm  Theoretical Basis" document [2].
data3Df(data3Ds > 16376) = NaN;

% Subset data per SOM block. NCL uses 0-based indexing. L1B dataset is huge. 
% Plotting all blocks will run out of memory.
data = data3Df(:,:,50);


% Apply scale facotr.
data = scale_factor * data;


% The file contains SOM projection. We need to use eosdump to generate 1D 
% lat and lon and then convert them to 2D lat and lon accordingly.
% That is, 
% 
% $eos2dump -c1 MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.hdf BlueBand 50 > lat_MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.output
%
% $eos2dump -c2 MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.hdf BlueBand 50 > lon_MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.output
%
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check [3].

lat1D = load('lat_MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.output');
lon1D = load('lon_MISR_AM1_GRP_TERRAIN_GM_P052_O000997_AA_F03_0024.output');

lat = reshape(lat1D, ydimsize, xdimsize);
lon = reshape(lon1D, ydimsize, xdimsize);

% Convert the lat/lon data to double type for plot
lat = double(lat);
lon = double(lon);

% Compute latitude and longitude limits for the map.
latlim = double([min(min(lat)),max(max(lat))]);
lonlim = double([min(min(lon)),max(max(lon))]);

% Load coastlines.
landareas = shaperead('landareas.shp', 'UseGeo', true);
coast.lat = [landareas.Lat];
coast.long = [landareas.Lon];


% Create a Figure to Plot the data.
cmap = colormap('Jet');
f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto', ...
    'Colormap', cmap);

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
    'MapLatLimit', latlim, 'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on', ...
    'MLabelLocation', 1.0, 'PLabelLocation', 1.0, ...
    'MLineLocation',  1.0, 'PlineLocation', 1.0, ...
    'MlabelParallel', min(latlim), 'LabelUnits', 'dm');

tightmap;



% Use geoshow to plot the data as a geolocated indexed image.
% geoshow(lat, lon, data, cmap, 'd','image');
surfacem(lat,lon,data);
geoshow(coast.lat, coast.long, 'Color', 'k');

% Put title.
title({FILE_NAME;'Blue Radiance'}, 'Interpreter', 'None', ...
    'FontSize',16,'FontWeight','bold');

% Create a colorbar. The colorbar can be moved to the right side of the
% plot by setting 'Location' to 'vertical'.
caxis auto;
h = colorbar();
set (get(h, 'title'), 'string', 'Wm^{-2}sr^{-1}{\mu}m^{-1}');

saveas(f, [FILE_NAME '.m.png']);

exit;

% References
% 
% [1] https://asdc.larc.nasa.gov/documents/misr/DPS_v33_RevM.pdf
% [2] https://eospso.gsfc.nasa.gov/atbd-category/45
% [3] http://hdfeos.org/zoo/note_non_geographic.php
