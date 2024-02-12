%   This example code illustrates how to access and visualize LaRC CERES
% NEWS CCCM Swath HDF4 file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r CER_NEWS_CCCM_Aqua_FM3_MODIS_CAL_CS_RelA2_903903_20070430_hdf
%
% Tested under: MATLAB R2012a
% Last updated: 2013-11-01

clear

% Open the HDF4 file.
FILE_NAME='CER-NEWS_CCCM_Aqua-FM3-MODIS-CAL-CS_RelA2_903903.20070430.hdf';
SD_id = hdfsd('start',FILE_NAME, 'rdonly');

% Read latitude.
DATAFIELD_NAME='Colatitude of CERES FOV at surface';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lat, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate the access to the corresponding data field.
hdfsd('endaccess', sds_id);


% Read longitude.
DATAFIELD_NAME='Longitude of CERES FOV at surface';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[lon, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), dimsizes);

% Terminate the access to the corresponding data field.
hdfsd('endaccess', sds_id);


% Read data from a data field.
% The data is under 'Clear Sky Constraintment Initial Flux Deltas'
% DATAFIELD_NAME='Shortwave flux adjustment at surface - upward -
% clear';
% The data is under 'TOA and Surface Fluxes'.
DATAFIELD_NAME='CERES SW TOA flux - upwards';
sds_index = hdfsd('nametoindex', SD_id, DATAFIELD_NAME);
sds_id = hdfsd('select',SD_id, sds_index);
[name, rank, dimsizes,data_type,nattrs, status] = hdfsd('getinfo', sds_id);
[m, n] = size(dimsizes);
[data, status] = hdfsd('readdata', sds_id, zeros(1,n), ones(1,n), ...
                       dimsizes);

% Read units attribute.
units_index = hdfsd('findattr', sds_id, 'units');
[units, status] = hdfsd('readattr',sds_id, units_index);

% Read fill value attribute.
fillvalue_index = hdfsd('findattr', sds_id, '_FillValue');
[fillvalue, status] = hdfsd('readattr',sds_id, fillvalue_index);


% Terminate the access to the corresponding data field.
hdfsd('endaccess', sds_id);

% Close the file.
hdfsd('end', SD_id);


lat = double(lat);
lon = double(lon);
data = double(data);

% Replace the fill value with NaN
data(data==fillvalue) = NaN;



% Plot the data using surfm and axesm.
f = figure('Name', FILE_NAME, 'visible', 'off');
cm = colormap('Jet');

latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'south');

k = size(data);
min_data=min(min(data));
max_data=max(max(data));
lon = lon - 180;

% Cell array of colros.
C = {'k','b','r','g','y',[.5 .6 .7],[.8 .2 .6]};

for i=1:k
    g = ceil(((data(i) - min_data) / (max_data - min_data)) * 7);     
    if isnan(g) 
        % disp(g);
    else
        x = mod(g,7);
        plotm(lat(i), lon(i), 'color', C{x+1});
        
    end
end

coast = load('coast.mat');

plotm(coast.lat,coast.long,'k');

% Put title.
tstring = {FILE_NAME;DATAFIELD_NAME};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');


scrsz = [1 1 800 600]
set(f,'position',scrsz,'PaperPositionMode','auto');
saveas(f,[FILE_NAME, '.m.jpg']);

exit