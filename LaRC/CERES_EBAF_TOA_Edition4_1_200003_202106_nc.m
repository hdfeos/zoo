%
%  This example code illustrates how to access and visualize
% LaRC CERES EBAF TOA Edition 4.1 netCDF-3 Grid file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r CERES_EBAF_TOA_Edition4_1_200003_202106_nc
%
% Tested under: MATLAB R2021a
% Last updated: 2021-10-25

clear

% Open the netCDF-3 file.
FILE_NAME='CERES_EBAF-TOA_Edition4.1_200003-202106.nc';
ncid = netcdf.open(FILE_NAME,'nowrite');

% Read data from a data field.
DATAFIELD_NAME='toa_net_clr_c_mon';

varid = netcdf.inqVarID(ncid,DATAFIELD_NAME);

data = netcdf.getVar(ncid,varid,[0 0 0],[360 180 1]);

% Convert the data to double for plot, transpose as well.
data=double(data');

% Read units.
units = netcdf.getAtt(ncid,varid,'units');

% Read long_name.
long_name = netcdf.getAtt(ncid,varid,'long_name');


% Read latitude data.
DATAFIELD_NAME='lat';
varid = netcdf.inqVarID(ncid,DATAFIELD_NAME);
lat = netcdf.getVar(ncid,varid);
lat=double(lat);

% Read longitude data.
DATAFIELD_NAME='lon';
varid = netcdf.inqVarID(ncid,DATAFIELD_NAME);
lon = netcdf.getVar(ncid,varid);
lon=double(lon);

% Close the file.
netcdf.close(ncid);



% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
	 'Renderer', 'zbuffer', ...
	 'Position', [0,0,800,600], ...
	 'visible', 'off');

% Plot the data using surfm and axesm.
axesm('MapProjection','eqdcylin','Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', 'MLabelParallel','south', ...
      'FontSize', 8)

surfm(lat,lon,data);
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
