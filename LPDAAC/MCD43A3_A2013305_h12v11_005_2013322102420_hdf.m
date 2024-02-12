%
%  This example code illustrates how to access and visualize 
%  LP DAAC MCD43A3 HDF-EOS2 Sinusoidal Grid file in MATLAB.
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage: save this script and run (without .m at the end)
%
% $matlab -nosplash -nodesktop -r MCD43A3_A2013305_h12v11_005_2013322102420_hdf
%
% Tested under: MATLAB R2017a
% Last updated: 2018-03-26

import matlab.io.hdfeos.*
import matlab.io.hdf4.*

% Open the HDF-EOS2 Grid file.
FILE_NAME='MCD43A3.A2013305.h12v11.005.2013322102420.hdf';
file_id = gd.open(FILE_NAME, 'rdonly');

% Open grid.
GRID_NAME='MOD_Grid_BRDF';
grid_id = gd.attach(file_id, GRID_NAME);

% Read data.
DATAFIELD_NAME='Albedo_BSA_Band1';
[data1, fail] = gd.readField(grid_id, DATAFIELD_NAME, [], [], []);

% Convert the data to double type for plot.
data=double(data1);

% Transpose the data to match the map projection.
data=data';

% Read grid information.
[xdimsize, ydimsize, upleft, lowright] = gd.gridInfo(grid_id);

% Detach grid.
gd.detach(grid_id);

% Close file.
gd.close(file_id);

% The file contains SINSOID projection. We need to use eos2dump
% tool to generate 1D lat/lon and then convert them to 2D lat/lon.
%
% $eos2dump -c1 MCD43A3.A2013305.h12v11.005.2013322102420.hdf > \
%   lat_MCD43A3.A2013305.h12v11.005.2013322102420.output       
%
% $eos2dump -c2 MCD43A3.A2013305.h12v11.005.2013322102420.hdf > \
%   lon_MCD43A3.A2013305.h12v11.005.2013322102420.output 
%
% To properly display the data, the latitude/longitude must be remapped.
% For information on how to obtain the lat/lon data, check this
% URL: http://hdfeos.org/zoo/note_non_geographic.php

lat1D = load('lat_MCD43A3.A2013305.h12v11.005.2013322102420.output');
lon1D = load('lon_MCD43A3.A2013305.h12v11.005.2013322102420.output');

lat = reshape(lat1D, xdimsize, ydimsize);
lon = reshape(lon1D, xdimsize, ydimsize);

clear lat1D lon1D;

lat = lat';
lon = lon';

% Open file using SD interface to read attributes from the data field.
SD_id = sd.start(FILE_NAME, 'rdonly');
sds_index = sd.nameToIndex(SD_id, DATAFIELD_NAME);
sds_id = sd.select(SD_id, sds_index);

% Read _FillValue attribute.
fillvalue_index = sd.findAttr(sds_id, '_FillValue');
fillvalue = sd.readAttr(sds_id, fillvalue_index);

% Read units attribute.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read scale_factor attribute.
scale_index = sd.findAttr(sds_id, 'scale_factor');
scale = sd.readAttr(sds_id, scale_index);

% Read add_offset attribute.
offset_index = sd.findAttr(sds_id, 'add_offset');
offset = sd.readAttr(sds_id, offset_index);

% Terminate access.
sd.endAccess(sds_id);

% Close the File.
sd.close(SD_id);

% Replace fill value with NaN.
data(data==fillvalue) = NaN;

% Apply MODIS scale/offset rule.
data = scale*(data-offset);

% Plot the data using contourfm and axesm.
latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));

f=figure('Name', FILE_NAME, ...
	 'Position', [0,0,800,600], ...         
         'Renderer', 'zbuffer', 'visible', 'off');

axesm('MapProjection','sinusoid','Frame','on','Grid','on', ...
      'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
      'MLineLocation', 4, 'MLabelParallel', 'south', ...
      'MeridianLabel','on','ParallelLabel','on',...
      'MLabelLocation', 4,'PLabelLocation', 2)

surfacem(lat,lon,data);
colormap('Jet');
coast = load('coast.mat');
plotm(coast.lat,coast.long,'k')

title({FILE_NAME;DATAFIELD_NAME}, 'Interpreter', 'None', ...
      'FontSize',12,'FontWeight','bold');
h = colorbar();
set (get(h, 'title'), 'string', units);
saveas(f, [FILE_NAME '.m.png']);
exit;
