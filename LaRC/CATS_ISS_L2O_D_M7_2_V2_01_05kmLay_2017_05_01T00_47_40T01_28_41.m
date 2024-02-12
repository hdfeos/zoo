%
%  This example code illustrates how to access and visualize LaRC
%  CATS Level 2 HDF5 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, 
% please use the HDF-EOS Forum (http://hdfeos.org/forums). 
% 
%  If you would like to see an  example of any other NASA HDF/HDF-EOS
% data product that is not listed in the HDF-EOS  Comprehensive Examples 
% page (http://hdfeos.org/zoo), feel free to contact us at 
% eoshelp@hdfgroup.org or post it at the HDF-EOS Forum 
% (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  #matlab -nosplash -nodesktop -r CATS_ISS_L2O_D_M7_2_V2_01_05kmLay_2017_05_01T00_47_40T01_28_41UTC_hdf5
%
% Tested under: MATLAB R2017a
% Last updated: 2018-06-14

% Open the HDF5 File.
FILE_NAME = 'CATS-ISS_L2O_D-M7.2-V2-01_05kmLay.2017-05-01T00-47-40T01-28-41UTC.hdf5';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Read data.
DATAFIELD_NAME = 'layer_descriptor/Aerosol_Type_Fore_FOV';
data_id = H5D.open(file_id, DATAFIELD_NAME);
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');
% Read lat.
LATFIELD_NAME='geolocation/CATS_Fore_FOV_Latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
             'H5P_DEFAULT');

% Read lon.
LONFIELD_NAME='geolocation/CATS_Fore_FOV_Longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Close the file.


% Convert data to double type for plot.
data=double(data);
lon=double(lon);
lat=double(lat);

% Change 1 to other value to visualize other layer.
data = squeeze(data(1,:)');

% Get the geolocation data.
% Change 3 to 0 or 1 to check other location.
lat = squeeze(lat(3,:)');
lon = squeeze(lon(3,:)');


% Create a Figure to Plot the data.
f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto');


% Create a custom color map for 9 different Feature Type key value.
cmap=[                       %  Key              R   G   B
      [0.00 0.00 0.00];  ... %  0=invalid       [000,000,000]    
      [0.00 0.00 1.00];  ... %  1=marine        [000,000,255]
      [1.00 1.00 0.00];  ... %  2=p. marine     [255,255,000]
      [0.00 1.00 0.00];  ... %  3=dust          [000,255,000]
      [1.00 0.00 0.00];  ... %  4=dust mixture  [255,000,000]
      [0.78 0.39 1.00];  ... %  5=clean/bg      [200,100,255]                    
      [0.39 0.20 1.00];  ... %  6=p. continental[100,50,255]
      [0.50 0.50 0.50];  ... %  7=smoke         [128,128,128]
      [0.78 0.50 0.78];  ... %  8=volcanic      [200,128,200]                    
     ];     

colormap(cmap);
caxis([0 8]); 

% Load coastlines.
landareas = shaperead('landareas.shp', 'UseGeo', true);
coast.lat = [landareas.Lat];
coast.long = [landareas.Lon];

% Create the plot.
axesm('MapProjection','eqdcylin',...
      'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on','MLabelParallel', ...
      'south')
scatterm(lat, lon, 1, data);
geoshow(coast.lat, coast.long, 'Color', 'k');
tightmap;

% Put colorbar.
y = [0, 1, 2, 3, 4, 5, 6, 7, 8];
h = colorbar('YTickLabel', {'invalid', 'marine', 'p. marine ', 'dust', ...
                    'dust mixture', 'clean/bg', 'p. continental', ...
                    'smoke', 'volcanic'}, ...
             'YTick', y);

tstring = {FILE_NAME;DATAFIELD_NAME};
title(tstring, 'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;

