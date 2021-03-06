function batch = fmr_Recognition2_Model(fmr, sub)
%Accepts subject number as input. Builds 1st level model, estimates, and
%builds contrasts.

% Composed by Anthony Resnick 6/26/2017

% Directory
subID = num2str(sub.subID);

cd(sub.mriDir)


movement1 = load(sub.Scans.Functional.recog_1.movementParameters{:});
movement2 = load(sub.Scans.Functional.recog_2.movementParameters{:});
if ~strcmp(subID, '107')
    movement3 = load(sub.Scans.Functional.recog_3.movementParameters{:});
    R = [movement1;movement2;movement3];
else
    R = [movement1;movement2];
end

scans1 = [sub.Scans.Functional.recog_1.smoothNormalizedScans(:)];
scans2 = [sub.Scans.Functional.recog_2.smoothNormalizedScans(:)];
if ~strcmp(subID, '107')
    scans3 = [sub.Scans.Functional.recog_3.smoothNormalizedScans(:)];
    scans = [scans1;scans2;scans3];
else
    scans = [scans1;scans2];
end


%   Create Model Directory
modelDir = fullfile(sub.Scans.Functional.recog_1.directory,'Recognition_Model');

if ~exist(modelDir)
    mkdir(modelDir);
end
save(sprintf('%s/movementparameter.mat',modelDir),'R')





%   Read in regressors
cd(sub.regressorDir)
Regressors = csvread(fullfile(sub.regressorDir, sprintf('RecogRegressor%s',subID)));

AdOnset = Regressors(:,1);
Recog = Regressors(:,[2,3]);
Format = Regressors(:,[4,5]); Format = Format(~isnan(Format(:,1)),[1,2]);
Brand = Regressors(:,[6,7]); Brand = Brand(~isnan(Brand(:,1)),[1,2]);

PE_Regressor = AdOnset(Regressors(:,8)==1 & Regressors(:,9)==1,:);
PF_Regressor = AdOnset(Regressors(:,8)==2 & Regressors(:,9)==1,:);
PM_Regressor = AdOnset(Regressors(:,8)==3 & Regressors(:,9)==1,:);
DE_Regressor = AdOnset(Regressors(:,8)==1 & Regressors(:,9)==2,:);
DF_Regressor = AdOnset(Regressors(:,8)==2 & Regressors(:,9)==2,:);
DM_Regressor = AdOnset(Regressors(:,8)==3 & Regressors(:,9)==2,:);
%% First Level Specification
matlabbatch{1}.spm.stats.fmri_spec.dir = {modelDir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 36;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = scans;
%%  Physical Emotional Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Physical_Emotional';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = PE_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = 4;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;

%%  Physical Functional Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'Physical_Functional';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = PF_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = 4;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;

%%  Physical Metaphorical Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'Physical_Metaphorical';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = PM_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = 4;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;

%%  Digital Emotional Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).name = 'Digital_Emotional';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = DE_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).duration = 4;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;

%%  Digital Functional Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).name = 'Digital_Functional';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).onset = DF_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).duration = 4;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).tmod = 0;

%%  Digital Metaphorical Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).name = 'Digital_Metaphorical';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).onset = DM_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).duration = 4;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).tmod = 0;

%%  Recognition Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).name = 'Recognition_Question';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).onset = Recog(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).duration = Recog(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).tmod = 0;

%%  Format Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).name = 'Format_Question';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).onset = Format(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).duration = Format(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).tmod = 0;

%%  Brand Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(9).name = 'Brand_Question';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(9).onset = Brand(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(9).duration = Brand(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(9).tmod = 0;
%%
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {sprintf('%s/movementparameter.mat',modelDir)};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'none';

%% Estimation
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

%% Contrasts
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Physical_Emotional';
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Physical_Functional';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Physical_Metaphorical';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 1];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Digital_Emotional';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Digital_Functional';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Digital_Metaphorical';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'PhysFuncOverDigFunc';
matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [0 1 0 0 -1 0];
matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'PhysEmoOverDigEmo';
matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [1 0 0 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'PhysMetaOverDigMeta';
matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [0 0 1 0 0 -1];
matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = 'PhysicalOverDigital';
matlabbatch{3}.spm.stats.con.consess{10}.tcon.weights = [1 1 1 -1 -1 -1];
matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{11}.tcon.name = 'FunctionalOverEmotional';
matlabbatch{3}.spm.stats.con.consess{11}.tcon.weights = [-1 1 0 -1 1 0];
matlabbatch{3}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{12}.tcon.name = 'FunctionalOverMetaphorical';
matlabbatch{3}.spm.stats.con.consess{12}.tcon.weights = [0 1 -1 0 1 -1];
matlabbatch{3}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.name = 'EmotionalOverMetaphorical';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.weights = [1 0 -1 1 0 -1];
matlabbatch{3}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.name = 'Recognition Question';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.weights = [0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.name = 'Format Question';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.weights = [0 0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{16}.tcon.name = 'Brand Question';
matlabbatch{3}.spm.stats.con.consess{16}.tcon.weights = [0 0 0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 1;

%% Save Pre-processing batch file, Run job
% save(fullfile(modelDir,['AI_Decision' date '.mat']),'matlabbatch');
% cd(modelDir)
% spm('defaults', 'FMRI');
% spm_jobman('serial', matlabbatch);
batch = matlabbatch;
cd(fmr.scriptDir)
end