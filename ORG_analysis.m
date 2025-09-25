% Copyright (C) 2025  Huakun Li, Yueming Zhuo, Daniel Palanker
%
%   This script provides an example for extracting ORG signals in response
%   to a flash sequence of green-UV-freen-UV.
%   OCT recording: 4000 repeated B-scans at a 10 kHz frame rate
%   Green flash: 1 ms, 340 μJ
%   UV flash: 1 ms, 112 μJ
%   Timing: pre-stimulus time was 10.04 ms (~100 frames), the interval
%   between ajacent flashes was 100 ms
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
% 
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
%   Lesser General Public License for more details.
% 
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
%   02110-1301 USA

%% Initialization and load data
clear; clc;
close all;

RegisteredDataFileName = 'example_data';
 
% download example dataset
if ~(exist(RegisteredDataFileName,'dir') || exist([RegisteredDataFileName '.zip'],'file'))
    disp('Downloading example dataset (data size is ~6.3 GB)...');
    websave([RegisteredDataFileName '.zip'],'https://zenodo.org/records/17193984/files/example_data.zip');
end

% unzip example dataset
if ~exist(RegisteredDataFileName,'dir')
    disp('Unzipping...');
    unzip([RegisteredDataFileName '.zip']);
end

% setup path
RegisteredDataFolder = ['./' RegisteredDataFileName '/']; % path to the registered data folder
file_name = 'I_reg';
FigSaveFolder = [RegisteredDataFolder 'figure/']; % path to the registered data folder
if ~exist(FigSaveFolder, 'dir')
    mkdir(FigSaveFolder);
end

% load data
load([RegisteredDataFolder, file_name, '.mat']);
N_z = size(I_reg, 1);
N_x = size(I_reg, 2);
N_t = size(I_reg, 3); 

% setup parameters
fs = 10e3; % frame rate (10 kHz)
phase_to_OPL = 840 / (4*pi);
samp_time = (1:N_t) / fs * 1e3 - 10.04; % sample time (ms), the onset of the first green flash was set to 0
baseline_frames = 1:100;
depth_refer = 100; % depth of IS/OS
depth_target = 112; % depth of ROST

%% Display the cross-sectional image
Stru = 20 * log10(mean(abs(I_reg(:,:,1:1e3)), 3));
figure;
imshow(Stru, [55, 90]);
ISOS_loc = yline(depth_refer, 'green');
ROST_loc = yline(depth_target, 'red');
legend([ISOS_loc, ROST_loc], {'IS/OS', 'ROST'}, 'Location', 'southeast');

%% Phase analysis
T_dZ = 1; % extract signals from the layer spanning across depth_target-T_dZ to depth_target+T_dZ
R_dX = 5; % for each pixel in the target layer, the reference region spans across (2*R_dZ+1) * (2*R_dX+1) pixels
R_dZ = 2; 

ORG_traces = zeros(N_x*(2*T_dZ+1), N_t); % ORG traces extracted from individual pixels in the target layer
loc = zeros(N_x*(2*T_dZ+1), 2); % indice of individual pixels in the target layer

I_Tref = I_reg .* conj(repmat(I_reg(:,:,1), 1, 1, N_t)); % calcualte time referenced OCT signals
processed_pixel_num = 0;
for i = 1:N_x
    for j = -T_dZ:T_dZ
        loc(processed_pixel_num+1, :) = [i, depth_target+j];

        [Rx, Rz] = meshgrid(max(i-R_dX, 1): min(i+R_dX, N_x), depth_refer-R_dZ: depth_refer+R_dZ); % reference region
        Rx = Rx(:); Rz = Rz(:);

        % Reference time series
        I_refer = zeros(length(Rx), size(I_Tref,3));
        for k = 1 : length(Rx)
            I_refer(k, :) = squeeze(I_Tref(Rz(k), Rx(k), :));
        end
        phi_r = angle(mean(I_refer, 1)); % temporal phase change in the reference region

        I_target = squeeze(I_Tref(depth_target+j, i, :)).';
        phi_tar_ref = angle(I_target .* exp(-1i * phi_r)); % self-referencing measurement
        ORG_traces(processed_pixel_num+1, :) = phi_tar_ref;
        processed_pixel_num = processed_pixel_num + 1;
    end
end

ORG_phase_trace = angle(mean(exp(1i*ORG_traces), 1)); % average across all pixels in the target layer
ORG_phase_trace = unwrap(ORG_phase_trace);
ORG_OPL_trace = ORG_phase_trace * phase_to_OPL; % convert phase change into OPL change

%% Plot ORG signal 
figure;
plot(samp_time, ORG_OPL_trace);
pbaspect([3 1 1])
xlim([-10, 400]);
ylim([-360, 20]);
xlabel('Time (ms)');
ylabel('\DeltaOPL (nm)');
ax = gca;
ax.FontSize = 14;
set(gcf, 'Color', 'w');
saveas(gcf, [FigSaveFolder, 'ORG_signal.tif']);
