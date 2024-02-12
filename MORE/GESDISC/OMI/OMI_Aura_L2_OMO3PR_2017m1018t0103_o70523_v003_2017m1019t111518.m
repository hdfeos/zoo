%
%  This example code illustrates how to access and visualize GES DISC OMI 
% HDF-EOS5 Swath file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r OMI_Aura_L2_OMO3PR_2017m1018t0103_o70523_v003_2017m1019t111518
%
% Tested under: MATLAB R2019b
% Last updated: 2019-11-05

% Open the HDF-EOS5 file.
FILE_NAME = 'OMI-Aura_L2-OMO3PR_2017m1018t0103-o70523_v003-2017m1019t111518.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open datasets.
DATAFIELD_NAME = 'HDFEOS/SWATHS/O3Profile/Data Fields/O3';
data_id = H5D.open (file_id, DATAFIELD_NAME);

PRESSURE_NAME='HDFEOS/SWATHS/O3Profile/Geolocation Fields/Pressure';
pre_id=H5D.open(file_id, PRESSURE_NAME);

TIME_NAME='HDFEOS/SWATHS/O3Profile/Geolocation Fields/Time';
time_id=H5D.open(file_id, TIME_NAME);

% Read datasets.
data1=H5D.read(data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
               'H5P_DEFAULT');

pressure1=H5D.read(pre_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                  'H5P_DEFAULT');

time=H5D.read(time_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
              'H5P_DEFAULT');

% Read the units attribute.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name(data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name(pre_id, ATTRIBUTE);
units_pre = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the title attribute.
ATTRIBUTE = 'Title';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (pre_id, ATTRIBUTE);
long_name_pre = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fillvalue attribute.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Read the missingvalue attribute.
ATTRIBUTE = 'MissingValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
missingvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');

% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Set subset index. At certain location and time, all values are
% fill values. Let's pick time dimension at 27 because it has valid
% values.

tdim = 27;
track = 1;

% Time dimension is 329.
% Lat/Lon dimensions are 30x329. 
% O3 dimension is 18x30x329.
% Pressure dimension is 19x30x329.
% According to [1], 30 is a cross track.
% Pressure has dimension size of 19 because [1] says:
% "The ozone profile is given in terms of the layer-columns of
% ozone in DU for an 18-layer atmosphere. The layers are nominally
% bounded by the pressure levels: [surface pressure, 700, 500, 300,
% 200, 150, 100, 70, 50, 30, 20, 10, 7, 5, 3, 2, 1, 0.5, and 0.3
% hPa."
% Thus, 19 indicates the bounds. 

% Convert 3-D data to 1-D data.
data=squeeze(data1(:,track,tdim));

% Subset 18 points from pressure data to match 18 O3 data size.
pressure=squeeze(pressure1(2:end,track,tdim));

% Time is second from TAI93.
% We don't handle leap second.
timelvl=datestr(datevec(datenum(1993,1,1, 0, 0, 0)+time(tdim)/86400));


% Replace the fill value with NaN
data(data==fillvalue) = NaN;

% Replace the missing value with NaN
data(data==missingvalue) = NaN;

% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a veritcal direction.
unit = sprintf('%s', units);
name = sprintf('%s', long_name);
unit_pre = sprintf('%s', units_pre);
name_pre = sprintf('%s', long_name_pre);

f = figure('Name', FILE_NAME, 'visible', 'off');

plot(data, pressure)
xlabel([name ' (' unit ')'], 'Interpreter', 'none'); 
ylabel([name_pre ' (' unit_pre ')']);

% Put title. We will use 0th-based notation for track.
tstring = {FILE_NAME;[name ' at ' timelvl ' (track=' num2str(track-1) ')' ]};
title(tstring, 'Interpreter', 'none', 'FontSize', 8, 'FontWeight','bold');

% Put highest pressure at the bottom of Y-axis.
ax = gca;
ax.YDir = 'reverse';

% Apply log scale along Y-axis get a better image.
set(gca, 'YScale', 'log')

% Turn off scientific notation (e.g., 10^3) in Y-axis tick labels.
yticks = get(gca,'ytick');
set(gca,'YTickLabel',yticks);

saveas(f, [FILE_NAME '.m.png']);
exit;

% References
% [1]
% https://aura.gesdisc.eosdis.nasa.gov/data//Aura_OMI_Level2/OMO3PR.003/doc/README.OMO3PR.pdf
