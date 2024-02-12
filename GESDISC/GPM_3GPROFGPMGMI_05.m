%
%  This example code illustrates how to access and visualize GPM L3 file
% in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org 
% or post it at the HDF-EOS Forum (http://hdfeos.org/forums).
% Usage:save this script and run (without .m at the end)
%                                   
%
% $matlab -nosplash -nodesktop -r GPM_3GPROFGPMGMI_05
%
% Tested under: MATLAB R2017a
% Last updated: 2018-01-30

clear

% Open the HDF5 File.
FILE_NAME = '3A-MO.GPM.GMI.GRID2017R1.20140701-S000000-E235959.07.V05A.HDF5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = 'Grid/cloudWater';
data_id = H5D.open (file_id, DATAFIELD_NAME);


% Read the dataset.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Create lat/lon.
lon = (-180 + 0.125) : 0.25 : (180 - 0.125);
lat = (-90 + 0.125) : 0.25 : (90 - 0.125);


% Read the fill value.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the units.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');


% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Subset data.
dataf = data(:,:,1);

% Plot the data using surfm and axesm.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...
           'visible', 'off');

if isempty(ver('map'))
    warning('Mapping Toolbox not present.')
    pcolor(lon,lat,dataf); shading flat;
else
    axesm('MapProjection','eqdcylin', ...
          'Frame','on','Grid','on', ...
          'MeridianLabel','on','ParallelLabel','on', ...
          'MLabelParallel','south');
    surfm(lat, lon, dataf);

    coast = load('coast.mat');
    plotm(coast.lat,coast.long,'k')
    tightmap;
end

% Change the value if you want to have more than 10 tick marks.
ntickmarks = 10;
colormap('Jet');
h = colorbar();

unit = sprintf('%s', units);
set(get(h, 'title'), 'string', unit, 'FontSize', 8,'FontWeight', ...
                   'bold');

plotm(coast.lat,coast.long,'k');

name = sprintf('%s', DATAFIELD_NAME);
title({FILE_NAME; name}, ... 
      'Interpreter', 'None', 'FontSize', 8,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;


