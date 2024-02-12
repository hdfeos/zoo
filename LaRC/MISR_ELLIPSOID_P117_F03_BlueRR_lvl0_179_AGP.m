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

[data3D, fail] = hdfgd('readfield', grid_id, DATAFIELD_NAME, [], [], []);

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


% We need to shift bits for "RDQI" to get "Blue Band "only. 
% See the page 84 of "MISR Data Products Specifications (rev. S)".
% The document is available at [1].
data3Ds = bitshift(data3D, -2);

data3Df = double(data3Ds);

% Replace the fill values with NaN
data3Df(data3D==fill_value) = NaN;

% Filter out values (> 16376) used for "Flag Data".
% See Table 1.2 in "Level 1 Radiance Scaling and Conditioning
% Algorithm  Theoretical Basis" document [2].
data3Df(data3Ds > 16376) = NaN;

% Convert 3-D data to 2-D data
nblocks = size(data3D, 3);
data = zeros(nblocks*ydimsize, xdimsize);
for i = 1:nblocks;
    data(((i-1)*ydimsize+1):(i*ydimsize),:) = data3Df(:,:,i);
end

% Apply scale facotr.
data = scale_factor * data;


% Read lat/lon from a different file with same path information.
% Please note that P117 matches.

% Open the HDF-EOS2 Grid File
FILE_NAME_GEO='MISR_AM1_AGP_P117_F01_24.hdf';
file_id = hdfgd('open', FILE_NAME_GEO, 'rdonly');

% Read Grid.
GRID_NAME='Standard';
grid_id = hdfgd('attach', file_id, GRID_NAME);

% Read lat and lon.
% It provides GeoLatitude and GeoLongitude in the datafield of group1.
[lat1, fail] = hdfgd('readfield', grid_id, 'GeoLatitude', [], [], []);
[lon1, fail] = hdfgd('readfield', grid_id, 'GeoLongitude', [], [], []);
% Convert M-D data to 2-D data
lat = zeros(nblocks*ydimsize, xdimsize);
lon = zeros(nblocks*ydimsize, xdimsize);
for i = 1:nblocks;
    lat(((i-1)*ydimsize+1):(i*ydimsize),:) = lat1(:,:,i);
end

for i = 1:nblocks;
    lon(((i-1)*ydimsize+1):(i*ydimsize),:) = lon1(:,:,i);
end


% Convert the lat/lon data to double type for plot
lat = double(lat);
lon = double(lon);

% Detach from the grid object.
hdfgd('detach', grid_id);
% Close the file
hdfgd('close', file_id);

latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

figure('Name',strcat(FILE_NAME, ':',DATAFIELD_NAME));

axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
    'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
    'MeridianLabel','on','ParallelLabel','on');

coast = load('coast.mat');

surfacem(lat, lon, data);
colormap('Jet');
caxis([min_data max_data]);

plotm(coast.lat, coast.long, 'k');

title({FILE_NAME;'Blue Radiance'}, 'Interpreter', 'None', ...
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

