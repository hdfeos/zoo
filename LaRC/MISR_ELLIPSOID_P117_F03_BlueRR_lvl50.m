%   This example code illustrates how to access and visualize LaRC_MISR
% Grid file in MATLAB.
%
%   If you have any questions, suggestions, comments on this example,
% please use the HDF-EOS Forum (http://hdfeos.org/forums).
%
%   If you would like to see an  example of any other NASA HDF/HDF-EOS data
% product that is not listed in the HDF-EOS Comprehensive Examples page
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).

clear

% Open the HDF-EOS2 Grid File.
FILE_NAME='MISR_AM1_GRP_ELLIPSOID_GM_P117_O058421_BA_F03_0024.hdf';
file_id = hdfgd('open', FILE_NAME, 'rdonly');

% Read Data from a Data Field.
GRID_NAME='BlueBand';
grid_id = hdfgd('attach', file_id, GRID_NAME);

DATAFIELD_NAME='Blue Radiance/RDQI';

[dataRaw, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

[xdimsize, ydimsize, upleft, lowright, status] = ...
    hdfgd('gridinfo', grid_id);

% Read scale factor.
[scale, status] = hdfgd('readattr', grid_id, 'Scale factor');
scale_factor = scale(1);

% Read fill value from the data.
[fill_value,status] = hdfgd('getfillvalue',grid_id, DATAFIELD_NAME);

% Detach from the grid object.
hdfgd('detach', grid_id);

% Close the file.
hdfgd('close', file_id);

% Subset SOMBlockDim = 50. MATLAB's indexing starts with 1, not 0.
block = 51;
data2D = dataRaw(:,:,block);

% We need to shift bits for "RDQI" to get "Blue Band "only. 
% See the page 84 of "MISR Data Products Specifications (rev. S)".
% The document is available at [1].
data2Ds = bitshift(data2D, -2);

data2Df = double(data2Ds);

% Replace the fill values with NaN.
data2Df(data2D==fill_value) = NaN;

% Filter out values (> 16376) used for "Flag Data".
% See Table 1.2 in "Level 1 Radiance Scaling and Conditioning
% Algorithm  Theoretical Basis" document [2].
data2Df(data2Ds > 16376) = NaN;

data = data2Df;

% Apply scale facotr.
data = scale_factor * data;


% The file contains SOM projection. We need to use eosdump to generate 1D 
% lat and lon and then convert them to 2D lat and lon accordingly.
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check [3].

lat1D = load('lat_MISR_ELLIPSOID_P117_F03_lvl50.output');
lon1D = load('lon_MISR_ELLIPSOID_P117_F03_lvl50.output');

lat2D = reshape(lat1D, ydimsize, xdimsize);
lon2D = reshape(lon1D, ydimsize, xdimsize);


% Convert the lat/lon data to double type for plot
lat = double(lat2D);
lon = double(lon2D);


min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

figure('Name',strcat(FILE_NAME, ':',DATAFIELD_NAME));

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
    'MeridianLabel','on','ParallelLabel','on')
    
coast = load('coast.mat');

surfacem(lat, lon, data);
colormap('Jet');
caxis([min_data max_data]);


plotm(coast.lat, coast.long, 'k');

title({FILE_NAME;'Blue Radiance at SOMBlockDim=50'}, 'Interpreter', 'None', ...
    'FontSize',16,'FontWeight','bold');

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
granule = (max_data - min_data) / ntickmarks;
h = colorbar('YTick', min_data:granule:max_data);
set (get(h, 'title'), 'string', 'Wm^{-2}sr^{-1}{\mu}m^{-1}');


% References
% 
% [1] https://asdc.larc.nasa.gov/documents/misr/DPS_v50_RevS.pdf
% [2] https://eospso.gsfc.nasa.gov/atbd-category/45
% [3] http://hdfeos.org/zoo/note_non_geographic.php
