%  This example code illustrates how to access and visualize
% LaRC CERES HDF4 file in MATLAB. 
%
%  If you have any questions, suggestions, comments  on this example, 
% pleaseuse the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA
% HDF/HDF-EOS data product that is not listed in the
% HDF-EOS Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org or post it at the
% HDF-EOS Forum (http://hdfeos.org/forums).
clear

% While the file has an HDF file extension, it is actually a netcdf file
% and should be read as such.  Support for reading netcdf files via HDF
% is deprecated and will be removed in a future release.
% NetCDF part of this code is contributed by MathWorks, Inc.

% Open the netCDF file.
FILE_NAME='CERES_EBAF_TOA_Terra_Edition1A_200003-200510.nc.hdf';
ncid = netcdf.open(FILE_NAME,'nowrite');

% Read data from a data field.
DATAFIELD_NAME='netclr';

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

% Plot the data.
f = figure('Name', ['CERES_EBAF_TOA_Terra_Edition1A_200003-' ...
                '200510.nc_netclr_time0'], 'visible', 'off');

% Plot the data using axesm, surfm and plotm if mapping toolbox exists.
if isempty(ver('map'))
    warning('Mapping Toolbox not present.')
	pcolor(lon,lat,double(data)); shading flat
else
    coast = load('coast.mat');
    latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
    lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];
    axesm('MapProjection','eqdcylin','Frame','on','Grid','on',...
          'MapLatLimit',latlim,'MapLonLimit',lonlim, ...
          'MeridianLabel','on','ParallelLabel','on')
    % You can use contourfm here but surfm is much faster.
    surfm(lat,lon,data);
    plotm(coast.lat,coast.long,'k')
end

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
min_data=floor(min(min(data)));
max_data=ceil(max(max(data)));
granule = (max_data - min_data) / ntickmarks;
colormap('Jet');
caxis([min_data max_data]); 
h = colorbar('YTick', min_data:granule:max_data);

set(get(h, 'title'), 'string', units, ...
                  'FontSize', 16, 'FontWeight','bold');

tstring = {FILE_NAME; long_name; ['at time=0']};
title(tstring, 'Interpreter', 'none', 'FontSize',16,'FontWeight','bold');

% Use the following if your screen isn't too big (> 1024 x 768). 
% scrsz = get(0,'ScreenSize');

% The following fixed-size screen size will look better in JPEG if
% your screen is too large.
scrsz = [1 1 1024 768];
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f,'CERES_EBAF_TOA_Terra_Edition1A_200003-200510.nc_netclr_time0_nc.m.jpg');
