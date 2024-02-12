%
%  This example code illustrates how to access and visualize NSIDC ICESat-2 
% ATL10 HDF5 file in MATLAB. 
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%                                   
% $matlab -nosplash -nodesktop -r ATL10_02_20181227215113_13790101_001_01_h5
%
% Tested under: MATLAB R2018a
% Last updated: 2019-06-11

clear

% Open the HDF5 File.
FILE_NAME = 'ATL10-02_20181227215113_13790101_001_01.h5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
DATAFIELD_NAME = 'gt1r/freeboard_beam_segment/beam_freeboard/beam_fb_height';
data_id = H5D.open(file_id, DATAFIELD_NAME);

LATFIELD_NAME='gt1r/freeboard_beam_segment/beam_freeboard/latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LONFIELD_NAME='gt1r/freeboard_beam_segment/beam_freeboard/longitude';
lon_id=H5D.open(file_id, LONFIELD_NAME);

TIMEFIELD_NAME='gt1r/freeboard_beam_segment/beam_freeboard/delta_time';
time_id=H5D.open(file_id, TIMEFIELD_NAME);

% Read the datasets.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');
latitude=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL',...
                'H5P_DEFAULT');
lon=H5D.read(lon_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
time_tai=H5D.read(time_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');
time = (time_tai - time_tai(1));
  
% Read the attributes.
ATTRIBUTE = 'units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

ATTRIBUTE = 'long_name';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fill value attribute.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
fillvalue=H5A.read(attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Replace the filled value with NaN.
data(data==fillvalue) = NaN;

% Create the graphics figure.
f=figure('Name', FILE_NAME, ...
         'Renderer', 'zbuffer', ...
         'Position', [0,0,800,600], ...
         'visible','off');

% Time vs count.
subplot(2,1,1);
plot(time, data, '*b');
grid on;
axis square;
timelvl=datestr(datevec(datenum(2018, 1, 1, 0, 0, 0)+time_tai(1)/86400));
xlabel(['Seconds from ' timelvl]); 

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a vertical direction. This unit has '{}' so we need to cast
% the string according to [1].
units_data = sprintf('%s', char(units));
long_name_data = sprintf('%s', char(long_name));
ylabel(units_data);

% Put title.
tstring = {FILE_NAME; DATAFIELD_NAME; long_name_data};
title(tstring,...
      'Interpreter', 'none', 'FontSize', 10, ...
      'FontWeight','bold');

% Trajectory.
subplot(2,1,2);
axesm ('ortho', 'Frame', 'on', 'Grid', 'on', ...
       'origin', [latitude(1), lon(1)])
coast = load('coast.mat');

% Plot the satellite path in blue.
plotm(latitude, lon, 'b')

% Plot world map coast line.
plotm(coast.lat, coast.long, 'k');

% Annotate the starting point of the path.
textm(latitude(1), lon(1), '+', 'FontSize', 16, 'FontWeight','bold', ...
      'Color', 'red');

% Put title.
title('Trajectory (+:starting point)',...
      'Interpreter', 'none', 'FontSize', 12, ...
      'FontWeight','bold');
saveas(f, [FILE_NAME '.m.png']);
exit;

% References
%
% [1] http://desk.stinkpot.org:8080/tricks/index.php/2006/02/cast-a-cell-as-a-string/

