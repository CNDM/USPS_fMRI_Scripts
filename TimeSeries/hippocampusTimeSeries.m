function hippocampusTimeSeries()
    maskDir = '/Users/CNDM/Dropbox/USPS2017_ET_fMRI/fMRI_USPS/ROI';
    maskFile = [maskDir '/aal_hippocampus_roi.mat'];
    
    spm_name = '/Users/CNDM/Dropbox/USPS2017_ET_fMRI/fMRI_USPS/Preprocessed/101_4D/fmradapt_1/NonMoCo/fmrAdapt_Model/SPM.mat';
    roi_file = maskFile;

% Make marsbar design object
D  = mardo(spm_name);
% Make marsbar ROI object
R  = maroi(roi_file);
% Fetch data into marsbar data object
Y  = get_marsy(R, D, 'mean');
% Get contrasts from original design
xCon = get_contrasts(D);
% Estimate design on ROI data
E = estimate(D, Y);
% Put contrasts from original design back into design object
E = set_contrasts(E, xCon);
% get design betas
b = betas(E);
% get stats and stuff for all contrasts into statistics structure
marsS = compute_contrasts(E, 1:length(xCon));
% Get definitions of all events in model
[e_specs, e_names] = event_specs(E);
n_events = size(e_specs, 2);
% Bin size in seconds for FIR
bin_size = tr(E);
% Length of FIR in seconds
fir_length = 24;
% Number of FIR time bins to cover length of FIR
bin_no = fir_length / bin_size;
% Options - here 'single' FIR model, return estimated
opts = struct('single', 1, 'percent', 1);
% Return time courses for all events in fir_tc matrix
for e_s = 1:n_events
  fir_tc(:, e_s) = event_fitted_fir(E, e_specs(:,e_s), bin_size, ...
                                 bin_no, opts);
end


rois = maroi('load_cell', roi_file); % make maroi ROI objects
des = mardo(spm_name);  % make mardo design object
mY = get_marsy(rois{:}, des, 'mean'); % extract data into marsy data object
y  = summary_data(mY);  % get summary time course(s)
    