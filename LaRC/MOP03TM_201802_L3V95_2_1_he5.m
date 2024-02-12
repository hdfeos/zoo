%
%  This example code illustrates how to access and visualize LaRC ASDC
%  MOP03TM vesion 7 HDF-EOS5 Grid file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r MOP03TM_201802_L3V95_2_1_he5
%
% Tested under: MATLAB R2017a
% Last updated: 2018-09-14

clear

% Open the HDF5 File.
FILE_NAME = 'MOP03TM-201802-L3V95.2.1.he5';
file_id = H5F.open(FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the dataset.
DATAFIELD_NAME = '/HDFEOS/GRIDS/MOP03/Data Fields/RetrievedSurfaceTemperatureDay';
data_id = H5D.open(file_id, DATAFIELD_NAME);

% Read the long_name attribute.
ATTRIBUTE = 'long_name';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
long_name = H5A.read(attr_id);

% Read the units attribute.
ATTRIBUTE = 'units';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
units = H5A.read(attr_id);

% Read the fill value attribute.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
fillvalue=H5A.read(attr_id, 'H5T_NATIVE_DOUBLE');


% Get dataspace. 
data_space = H5D.get_space(data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
data_dims=fliplr(data_dims');

% Read the dataset.
data=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');

% Release resources.
H5S.close(data_space)

% Open latitude.
DATAFIELD_NAME = '/HDFEOS/GRIDS/MOP03/Data Fields/Latitude';
data_id = H5D.open(file_id, DATAFIELD_NAME);

% Get dataspace. 
data_space = H5D.get_space(data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);

% Read the dataset.
lat=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
              'H5P_DEFAULT');

% Release resources.
H5S.close (data_space)

% Open longitude.
DATAFIELD_NAME = '/HDFEOS/GRIDS/MOP03/Data Fields/Longitude';
data_id = H5D.open(file_id, DATAFIELD_NAME);

% Get dataspace. 
data_space = H5D.get_space(data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);

% Read the dataset.
lon=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
              'H5P_DEFAULT');

% Release resources.
H5S.close (data_space)


% Close and release resources.
H5A.close (attr_id)
H5D.close(data_id);
H5F.close (file_id);


% Replace the fill value with NaN.
data(data==fillvalue) = NaN;


% Plot the data using surfm and axesm.
f = figure('Name', FILE_NAME, ...
           'Renderer', 'zbuffer', ...
           'Position', [0,0,800,600], ...           
           'visible', 'off');

latlim=[floor(min(min(lat))),ceil(max(max(lat)))];
lonlim=[floor(min(min(lon))),ceil(max(max(lon)))];

axesm('MapProjection','eqdcylin','MapLatLimit', ...
      latlim,'MapLonLimit',lonlim,'Frame','on','Grid','on', ...
      'MeridianLabel','on','ParallelLabel','on', ...
      'MLabelParallel','south');
surfm(lat,lon,data);

coast = load('coast.mat');
plotm(coast.lat,coast.long,'k')

tightmap;

% Change the value if you want to have more than 10 tick marks.
colormap('Jet');
h = colorbar();

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a veritcal direction.
unit = sprintf('%s', units);
name = sprintf('%s', long_name);
set(get(h, 'title'), 'string', unit, 'FontSize',16,'FontWeight', ...
                   'bold');

title({FILE_NAME; name}, ... 
      'Interpreter', 'None', 'FontSize',16,'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;
