function batch = fmr_BrandRec_Model(fmr, sub)
%Accepts subject number as input. Builds 1st level model, estimates, and
%builds contrasts.

% Composed by Anthony Resnick 6/26/2017

% Directory
subID = num2str(sub.subID);

cd(sub.mriDir)


movement = sub.Scans.Functional.brandrec.movementParameters;


%   Create Model Directory
modelDir = fullfile(sub.Scans.Functional.brandrec.directory,'BrandRec_Model');

if ~exist(modelDir)
    mkdir(modelDir);
end


%   Read in regressors
cd(sub.regressorDir)
Regressors = csvread(fullfile(sub.regressorDir, sprintf('BrandRecRegressor%s',subID)));
Regressors(:,[1,3,5]) = Regressors(:,[1,3,5]) - 4;

BrandName_Regressor = Regressors(:,[1,2]);

PE_Regressor = Regressors(Regressors(:,8)==1 & Regressors(:,9)==1,[3,4]);
PF_Regressor = Regressors(Regressors(:,8)==2 & Regressors(:,9)==1,[3,4]);
PM_Regressor = Regressors(Regressors(:,8)==3 & Regressors(:,9)==1,[3,4]);
DE_Regressor = Regressors(Regressors(:,8)==1 & Regressors(:,9)==2,[3,4]);
DF_Regressor = Regressors(Regressors(:,8)==2 & Regressors(:,9)==2,[3,4]);
DM_Regressor = Regressors(Regressors(:,8)==3 & Regressors(:,9)==2,[3,4]);

Ratings_Regressor = Regressors(:,[5,6,7]);
%% First Level Specification
matlabbatch{1}.spm.stats.fmri_spec.dir = {modelDir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 36;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = sub.Scans.Functional.brandrec.smoothNormalizedScans;
%%  Brand Name Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Brand_Name_Shown';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = BrandName_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = BrandName_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
%%  Physical Emotional Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'Physical_Emotional';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = PE_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration = PE_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;

%%  Physical Functional Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).name = 'Physical_Functional';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).onset = PF_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).duration = PF_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(3).tmod = 0;

%%  Physical Metaphorical Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).name = 'Physical_Metaphorical';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).onset = PM_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).duration = PM_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(4).tmod = 0;

%%  Digital Emotional Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).name = 'Digital_Emotional';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).onset = DE_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).duration = DE_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(5).tmod = 0;

%%  Digital Functional Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).name = 'Digital_Functional';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).onset = DF_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).duration = DF_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(6).tmod = 0;

%%  Digital Metaphorical Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).name = 'Digital_Metaphorical';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).onset = DM_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).duration = DM_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(7).tmod = 0;
%%  Vividness Regressor
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).name = 'Vividness_Rating';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).onset = Ratings_Regressor(:,1);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).duration = Ratings_Regressor(:,2);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).pmod.name = 'Vividness';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).pmod.param = Ratings_Regressor(:,3);
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).pmod.poly = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(8).orth = 1;

%%
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = movement;
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
matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [0 1];
matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Physical_Functional';
matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [0 0 1];
matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Physical_Metaphorical';
matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = 'Digital_Emotional';
matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.name = 'Digital_Functional';
matlabbatch{3}.spm.stats.con.consess{5}.tcon.weights = [0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.name = 'Digital_Metaphorical';
matlabbatch{3}.spm.stats.con.consess{6}.tcon.weights = [0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{7}.tcon.name = 'PhysEmoOverDigEmo';
matlabbatch{3}.spm.stats.con.consess{7}.tcon.weights = [0 1 0 0 -1 0 0];
matlabbatch{3}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{8}.tcon.name = 'PhysFuncOverDigFunc';
matlabbatch{3}.spm.stats.con.consess{8}.tcon.weights = [0 0 1 0 0 -1 0];
matlabbatch{3}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{9}.tcon.name = 'PhysMetaOverDigMeta';
matlabbatch{3}.spm.stats.con.consess{9}.tcon.weights = [0 0 0 1 0 0 -1];
matlabbatch{3}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{10}.tcon.name = 'PhysicalOverDigital';
matlabbatch{3}.spm.stats.con.consess{10}.tcon.weights = [0 1 1 1 -1 -1 -1];
matlabbatch{3}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{11}.tcon.name = 'FunctionalOverEmotional';
matlabbatch{3}.spm.stats.con.consess{11}.tcon.weights = [0 -1 1 0 -1 1 0];
matlabbatch{3}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{12}.tcon.name = 'FunctionalOverMetaphorical';
matlabbatch{3}.spm.stats.con.consess{12}.tcon.weights = [0 0 1 -1 0 1 -1];
matlabbatch{3}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.name = 'EmotionalOverMetaphorical';
matlabbatch{3}.spm.stats.con.consess{13}.tcon.weights = [0 1 0 -1 1 0 -1];
matlabbatch{3}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.name = 'Brand Name';
matlabbatch{3}.spm.stats.con.consess{14}.tcon.weights = [1];
matlabbatch{3}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.name = 'Vividness Duration';
matlabbatch{3}.spm.stats.con.consess{15}.tcon.weights = [0 0 0 0 0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{16}.tcon.name = 'Vividness Response';
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