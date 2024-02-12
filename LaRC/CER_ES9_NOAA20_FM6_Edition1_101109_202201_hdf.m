%
%    This example code illustrates how to access and visualize LaRC
%  CERES ES9 NOAA20 HDF4 file in MATLAB. 
%
%   If you have any questions, suggestions, comments on this
%  example, please use the HDF-EOS Forum
%  (http://hdfeos.org/forums). 
%
%    If you would like to see an  example of any other NASA
%  HDF/HDF-EOS data product that is not listed in the HDF-EOS
%  Comprehensive Examples page (http://hdfeos.org/zoo), 
% feel free to contact us at eoshelp@hdfgroup.org  or
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
%
% Usage:save this script and run (without .m at the end)
%
%  $matlab -nosplash -nodesktop -r CER_ES9_NOAA20_FM6_Edition1_101109_202201_hdf
%
% Tested under: MATLAB R2021a
% Last updated: 2022-12-07

import matlab.io.hdf4.*

% Open the HDF-EOS2 Grid file.
FILE_NAME='CER_ES9_NOAA20-FM6_Edition1_101109.202201.hdf';
DATAFIELD_NAME='Longwave flux';

SD_id = sd.start(FILE_NAME, 'rdonly');

%  This product requires Vgroup handling because 
% there are multple datasets with same SDS names [1]:
% 
%  idx = nameToIndex(sdID,sdsname) returns the index of the data 
%  set with the name specified by sdsname. If there is more than 
%  one data set with the same name, the routine returns the index 
%  of the first one.

% Open Vgroup.
file_id = hdfh('open', FILE_NAME, 'DFACC_READ', 0);
status = hdfv('start', file_id);
vgroup_ref = hdfv('find', file_id, 'Hourbox Data');
vgroup_id = hdfv('attach', file_id, vgroup_ref, 'r');
maxsize = hdfv('ntagrefs', vgroup_id);
[tag, refs, count] = hdfv('gettagrefs', vgroup_id, maxsize);

for n = 1:count
  sds_index = sd.refToIndex(SD_id, refs(n));
  sds_id = sd.select(SD_id, sds_index);
  [name, dims, datatype, nattrs] = sd.getInfo(sds_id);
  if strcmp(name, DATAFIELD_NAME)
    data = sd.readData(sds_id);
    % Read _FillValue from data field.
    fillvalue_index = sd.findAttr(sds_id, '_FillValue');
    fillvalue = sd.readAttr(sds_id, fillvalue_index);
    % Get the long name from data field.
    long_name_index = sd.findAttr(sds_id, 'long_name');
    long_name = sd.readAttr(sds_id, long_name_index);
    % Read units from the data field.
    units_index = sd.findAttr(sds_id, 'units');
    units = sd.readAttr(sds_id, units_index);
  end 

  if strcmp(name, 'Colatitude')
     colat = sd.readData(sds_id);
  end

  if strcmp(name, 'Longitude')
     lon = sd.readData(sds_id);
  end

  % Terminate access to the corresponding data set.
  sd.endAccess(sds_id);
end
vgroup_id = hdfv('detach', vgroup_id);
status = hdfv('end', file_id);
hdfh('close', file_id);

% Close the file.
sd.close(SD_id);

% Convert the data to double type for plot.
data = double(data);
lon = double(lon);
colat = double(colat);

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;
colat(data==fillvalue) = NaN;
lon(data==fillvalue) = NaN;

% Convert colat to lat.
lat = 90 - colat;

% Plot the data using surfm and axesm.
f = figure('Name', FILE_NAME, 'visible', 'off');
axesm('MapProjection','eqdcylin', ...
      'Frame','on','Grid','on', ...
      'FontSize', 8, ...
      'MeridianLabel','on','ParallelLabel','on',...
      'MLabelParallel','south');
coast = load('coastlines.mat');
scatterm(lat(:), lon(:), 1, data(:));
plotm(coast.coastlat, coast.coastlon,'k');

% Put color bar.
colormap('Jet');
h=colorbar();

% Set unit.
set (get(h, 'title'), 'string', units);
tightmap;

% Put title. 
tstring = {FILE_NAME; [DATAFIELD_NAME ' (' long_name ')']};
title(tstring, 'Interpreter', 'none', 'FontSize', 10, ...
      'FontWeight','bold');
saveas(f,[FILE_NAME '.m.png']);
exit;


% Reference
%
% [1] https://www.mathworks.com/help/matlab/ref/matlab.io.hdf4.sd.nametoindex.html
