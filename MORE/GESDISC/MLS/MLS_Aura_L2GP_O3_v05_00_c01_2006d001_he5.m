%  This example code illustrates how to access and visualize GES DISC MLS
% Ozone HDF-EOS5 Swath file in MATLAB. 
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
% $matlab -nosplash -nodesktop -r MLS_Aura_L2GP_O3_v05_00_c01_2006d001_he5
%
% Tested under: MATLAB R2023b
% Last updated: 2024-03-25

% Open the HDF5 File.
FILE_NAME = 'MLS-Aura_L2GP-O3_v05-00-c01_2006d001.he5';
file_id = H5F.open (FILE_NAME, 'H5F_ACC_RDONLY', 'H5P_DEFAULT');

% Open the datasets.
DATAFIELD_NAME = '/HDFEOS/SWATHS/O3/Data Fields/L2gpValue';
data_id = H5D.open (file_id, DATAFIELD_NAME);

LATFIELD_NAME='/HDFEOS/SWATHS/O3/Geolocation Fields/Latitude';
lat_id=H5D.open(file_id, LATFIELD_NAME);

LEVFIELD_NAME='/HDFEOS/SWATHS/O3/Geolocation Fields/Pressure';
lev_id=H5D.open(file_id, LEVFIELD_NAME);

TIMEFIELD_NAME='/HDFEOS/SWATHS/O3/Geolocation Fields/Time';
time_id=H5D.open(file_id, TIMEFIELD_NAME);

% Get dataspace.
data_space = H5D.get_space (data_id);
[data_numdims data_dims data_maxdims]= H5S.get_simple_extent_dims (data_space);
data_dims=fliplr(data_dims');

% Read the datasets.
data=H5D.read (data_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
                'H5P_DEFAULT');
lat=H5D.read(lat_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
lev=H5D.read(lev_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT');
time=H5D.read(time_id,'H5T_NATIVE_DOUBLE', 'H5S_ALL', 'H5S_ALL', ...
             'H5P_DEFAULT');

% Release resources.
H5S.close (data_space)

% Read the units.
ATTRIBUTE = 'Units';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
units = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (lat_id, ATTRIBUTE);
units_lat = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (lev_id, ATTRIBUTE);
units_lev = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the title.
ATTRIBUTE = 'Title';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
long_name = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (lat_id, ATTRIBUTE);
long_name_lat = H5A.read(attr_id, 'H5ML_DEFAULT');

attr_id = H5A.open_name (lev_id, ATTRIBUTE);
long_name_lev = H5A.read(attr_id, 'H5ML_DEFAULT');

% Read the fillvalue.
ATTRIBUTE = '_FillValue';
attr_id = H5A.open_name (data_id, ATTRIBUTE);
fillvalue=H5A.read (attr_id, 'H5T_NATIVE_DOUBLE');


% Close and release resources.
H5A.close (attr_id)
H5D.close (data_id);
H5F.close (file_id);

% Convert type.
data = double(data);
lat = double(lat);

% Replace the fill value with NaN.
data(data==double(fillvalue)) = NaN;

% Set subset index because
% vector X(=lat) must be strictly increasing or strictly decreasing for
% contour plot.
differences = diff(lat);
  
% Find indices where the difference changes sign from negative to
% positive
indices = find((differences < 0) & (differences([2:end 1]) >= 0));

% We will subset the first region that lat value decreases monotonically.
i = indices(1);

% Time is second from TAI93.
timelvl=datestr(datevec(datenum(1993,1,1, 0, 0, 0)+time(1)/86400));
timelvl2=datestr(datevec(datenum(1993,1,1, 0, 0, 0)+time(i)/ ...
                        86400));

% Subset data.
lats = lat(1:i);
datas = data(:,1:i);

% Plot the data.
f = figure('Name', FILE_NAME, 'visible', 'off');

% Don't draw a line.
[ch,ch] = contourf(lats, lev, datas);
set(ch, 'edgecolor', 'none');

% Put colorbar.
colormap('Jet');
h = colorbar();


% An HDF5 string attribute is an array of characters.
% Without the following conversion, the characters in unit will appear 
% in a veritcal direction.
unit = sprintf('%s', units);
name = sprintf('%s', long_name);
unit_lat = sprintf('%s', units_lat);
name_lat = sprintf('%s', long_name_lat);
unit_lev = sprintf('%s', units_lev);
name_lev = sprintf('%s', long_name_lev);

% Draw unit.
set(get(h, 'title'), 'string', unit, ...
                  'FontSize', 12, 'FontWeight','bold', ...
                  'Interpreter', 'none');

% Set axis labels.
xlabel([name_lat ' (' unit_lat ')'], 'Interpreter', 'none'); 
ylabel([name_lev ' (' unit_lev ')']);

% Put highest pressure at the bottom of Y-axis.
ax = gca;
ax.YDir = 'reverse';

% Apply log scale along Y-axis get a better image.
set(gca, 'YScale', 'log')

% Turn off scientific notation (e.g., 10^3) in Y-axis tick labels.
yticks = get(gca,'ytick');
set(gca,'YTickLabel',yticks);

% Put title.
tstring = {FILE_NAME; [name ' from ' timelvl ' to ' timelvl2 ] };
title(tstring, 'Interpreter', 'none', 'FontSize', 12, ...
      'FontWeight','bold');

scrsz = [1 1 800 600];
set(f, 'position', scrsz, 'PaperPositionMode', 'auto');
saveas(f, [FILE_NAME '.m.png']);
exit;
