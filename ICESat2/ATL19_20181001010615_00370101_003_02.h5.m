%
%  This example code illustrates how to access and visualize an
%  NSIDC ICESat-2 ATL19 L3 HDF5 file in Octave.
%
%  If you have any questions, suggestions, comments on this example, please 
% use the HDF-EOS Forum (http://hdfeos.org/forums). 
%
%  If you would like to see an  example of any other NASA HDF/HDF-EOS data 
% product that is not listed in the HDF-EOS Comprehensive Examples page 
% (http://hdfeos.org/zoo), feel free to contact us at eoshelp@hdfgroup.org or 
% post it at the HDF-EOS Forum (http://hdfeos.org/forums).
% 
% Usage: save this script and run
%
%  $octave ATL19_20181001010615_00370101_003_02.h5.m
% 
%
% Tested under: Octave 8.4.0_3
% Last updated: 2024-02-12

% pkg install -forge netcdf
pkg load netcdf

addpath ./m_map;

fname = 'ATL19_20181001010615_00370101_003_02.h5';

% Use Octave's built-in HDF5 reader for reading data.
h5 = load(fname);
lat = h5.mid_latitude.latitude;
lon = h5.mid_latitude.longitude;
data = h5.mid_latitude.beam_1.dot_avg;

% Although ncinfo() fails, reading attribute is fine.
long_name = ncreadatt(fname, '/mid_latitude/beam_1/dot_avg', ...
                      'long_name')
units = ncreadatt(fname, '/mid_latitude/beam_1/dot_avg', ...
                  'units')
fillvalue = ncreadatt(fname, '/mid_latitude/beam_1/dot_avg', ...
                  '_FillValue')
                                
% Remove a garbage character at the end.
long_name = long_name(1:end-1)
units = units(1:end-1)

% Replace the fill value with NaN.
data(data==fillvalue) = NaN;

% Plot data.
clf;
cmap = jet();

colormap(cmap);
m_proj('miller');
% m_scatter(lon, lat, 1, data);
m_pcolor(lon, lat, data.');                                
shading flat;
m_grid();
m_coast('color', 'black');
h = colorbar();
% ax=m_contfbar(1, [.5 .8], CS, CH);
% title(ax,{'Level/m',''}); % Move up by inserting a blank line

                                
% Annotate the plot.
title_str = [fname '\n', long_name];
set(get(h, 'title'), 'string', units);
title(sprintf(title_str), 'Interpreter', 'None', 'FontSize', 10);
print('-dpng', '-r300', [fname, '.m.png']);
