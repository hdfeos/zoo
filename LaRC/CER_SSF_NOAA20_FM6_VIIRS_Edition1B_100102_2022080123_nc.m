%
%  This example code illustrates how to access and visualize
% LaRC CERES SSF NOAA20 FM6 VIIRS L2 netCDF-4/HDF5 file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r CER_SSF_NOAA20_FM6_VIIRS_Edition1B_100102_2022080123_nc
%
% Tested under: MATLAB R2021a
% Last updated: 2022-10-25

% Open the netCDF-4/HDF5 file.
FILE_NAME='CER_SSF_NOAA20-FM6-VIIRS_Edition1B_100102.2022080123.nc';

% List file content.
% ncdisp(FILE_NAME)

ncid = netcdf.open(FILE_NAME, 'nowrite');

% Read data from a data field.
DATAFIELD_NAME='/TOA_and_Surface_Fluxes/toa_incoming_solar_radiation';

data = ncread(FILE_NAME, DATAFIELD_NAME);

% Read units.
units = ncreadatt(FILE_NAME, DATAFIELD_NAME, "units");

% Read long_name.
long_name = ncreadatt(FILE_NAME, DATAFIELD_NAME, "long_name");


% Read latitude data.
DATAFIELD_NAME='/Time_and_Position/instrument_fov_latitude';
lat = ncread(FILE_NAME, DATAFIELD_NAME);
lat = double(lat);

                 
% Read longitude data.
DATAFIELD_NAME='/Time_and_Position/instrument_fov_longitude';
lon = ncread(FILE_NAME, DATAFIELD_NAME);
lon = double(lon);

% Close the file.
netcdf.close(ncid);

[v,i] = max(data);
lat_c = lat(i);
lon_c = lon(i);

% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');
axesm ('ortho', 'Frame', 'on', 'Grid', 'on', ...
       'origin', [lat_c, lon_c]);
mlabel('equator')
plabel(0); 
plabel('fontweight','bold');

scatterm(lat, lon, 1, data);
colormap('Jet');
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));
caxis([min_data max_data]); 

coast = load('coastlines.mat');
plotm(coast.coastlat,coast.coastlon,'k')

% Change the value if you want to have more than 10 tick marks.
h = colorbar();
set (get(h, 'title'), 'string', units)
tightmap;

title({FILE_NAME;long_name}, 'Interpreter', 'None', ...
      'FontSize',10,'FontWeight','bold');


saveas(f, [FILE_NAME  '.m.png']);
exit