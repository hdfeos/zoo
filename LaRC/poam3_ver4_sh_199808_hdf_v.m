%
%  This example code illustrates how to access and visualize LaRC POAM3
% Level 2 HDF4 file in MATLAB. 
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
%  $matlab -nosplash -nodesktop -r poam3_ver4_sh_199808_hdf_v
%
% Tested under: MATLAB R2021a
% Last updated: 2022-05-19

import matlab.io.hdf4.*
  
% Open the HDF4 File.
FILE_NAME = 'poam3_ver4_sh_199808.hdf';
SD_id = sd.start(FILE_NAME, 'rdonly');

% Read data.
datafield_name='aerosol';
sds_index = sd.nameToIndex(SD_id, datafield_name);
sds_id = sd.select(SD_id, sds_index);
data = sd.readData(sds_id);

% Read units attribute from the data field.
units_index = sd.findAttr(sds_id, 'units');
units = sd.readAttr(sds_id, units_index);

% Read long_name attribute from data field.
long_name_index = sd.findAttr(sds_id, 'long_name');
long_name = sd.readAttr(sds_id, long_name_index);
sd.endAccess(sds_id);

% Read _FillValue from data field.
fill_value_index = sd.findAttr(sds_id, '_FillValue');
fill_value = sd.readAttr(sds_id, fill_value_index);
sd.endAccess(sds_id);

% Read dates.
date_name='date';
sds_index = sd.nameToIndex(SD_id, date_name);
sds_id = sd.select(SD_id, sds_index);
date = sd.readData(sds_id);
sd.endAccess(sds_id);

% Read seconds.
sec_name='sec';
sds_index = sd.nameToIndex(SD_id, sec_name);
sds_id = sd.select(SD_id, sds_index);
sec = sd.readData(sds_id);
sd.endAccess(sds_id);
d = duration(0,0, sec);

% Read wavelength.
wv_name='wavelength';
sds_index = sd.nameToIndex(SD_id, wv_name);
sds_id = sd.select(SD_id, sds_index);
wv = sd.readData(sds_id);

% Read long_name attribute from wavelength.
wv_long_name_index = sd.findAttr(sds_id, 'long_name');
wv_long_name = sd.readAttr(sds_id, wv_long_name_index);

% Read units attribute from wavelength
wv_units_index = sd.findAttr(sds_id, 'units');
wv_units = sd.readAttr(sds_id, wv_units_index);
sd.endAccess(sds_id);

% Read altitude.
alt_name='z_aerosol';
sds_index = sd.nameToIndex(SD_id, alt_name);
sds_id = sd.select(SD_id, sds_index);
alt = sd.readData(sds_id);

% Read long_name attribute from z_aerosol.
alt_long_name_index = sd.findAttr(sds_id, 'long_name');
alt_long_name = sd.readAttr(sds_id, alt_long_name_index);

% Read units attribute from the altitude.
alt_units_index = sd.findAttr(sds_id, 'units');
alt_units = sd.readAttr(sds_id, alt_units_index);
sd.endAccess(sds_id);

% Close the file.
sd.close(SD_id);

% Convert data to double type for plot.
data=double(data);
wv=double(wv);

% Replace the fill value with NaN.
data(data==fill_value) = NaN;

% Convert date integer to datetime type.
t = datetime(date, 'ConvertFrom', 'yyyymmdd');

% 1 is for 0.355 nm wavelength. Change this for different wavelength.
w = 1;
data = squeeze(data(:,w,:));

% Create a Figure to Plot the data.
f = figure('Name', FILE_NAME, ...
    'Renderer', 'zbuffer', ...
    'Position', [0,0,800,600], ...
    'Visible', 'off', ...
    'PaperPositionMode', 'auto');

dt = datenum(t+d);
[ch,ch] = contourf(dt, alt, data');
set(ch, 'edgecolor', 'none');

h = colorbar();
set (get(h, 'title'), 'string', units, 'FontSize', 8, ...
                   'Interpreter', 'None', ...
                   'FontWeight','bold');

% Put x-axis tick labels.
xData = linspace(dt(1), dt(length(dt)), 31);
ax = gca;
ax.XTick = xData;
% See [1] for the formatting number 6.
datetick('x', 6, 'keepticks'); 

% Put y-axis label.
ylabel([alt_long_name ' (' alt_units ')']);

% Put title.
var_name = sprintf(' at %s=%0.3f (%s)', wv_long_name, wv(w), wv_units);
tstring = {FILE_NAME; [long_name, var_name]};
title(tstring,...
      'Interpreter', 'none', 'FontSize', 16, ...
      'FontWeight','bold');

saveas(f, [FILE_NAME '.v.m.png']);
exit;

% Reference
% [1] https://www.mathworks.com/help/matlab/ref/datetick.html#btpmlwj-1-dateFormat