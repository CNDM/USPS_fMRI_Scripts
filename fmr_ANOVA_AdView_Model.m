function PreProcessed = fmr_ANOVA_AdView_Model(fmr)

cwd=pwd;
modelName = 'AdView_Model';
model = 'adview';

fmr.Model.(modelName).anova.name = modelName;
fmr.Model.(modelName).anova.subs = fmr.sub;

fmr.Model.(modelName).anova.directory = [fmr.secondLevelDir '/anova/' modelName '_' num2str(length(fmr.sub))];

if ~exist(fmr.Model.(modelName).anova.directory) % exist requires string format
    mkdir(fmr.Model.(modelName).anova.directory)
end


for c=1:6
    
    for sub=1:length(fmr.sub)
        modeldir = fullfile(fmr.Subject(sub).Scans.Functional.(model).directory,modelName);
        if c<10
            scans(sub,c)={[modeldir '/con_000' num2str(c) '.nii,1']};
        else
            scans(sub,c)={[modeldir '/con_00' num2str(c) '.nii,1']};
        end
    end %subj loop
end






matlabbatch{1}.spm.stats.factorial_design.dir = cellstr(fmr.Model.(modelName).anova.directory);
%% Define the levels
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).name = 'Format';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).levels = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).name = 'Type';
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).levels = 3;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fd.fact(2).ancova = 0;
%% Build the cells
%Physical Emotional
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).levels = [1,1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(1).scans = scans(:,1);
%Physical Functional
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).levels = [1,2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(2).scans = scans(:,2);
%Physical Metaphorical
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).levels = [1, 3];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(3).scans = scans(:,3);
%Digital Emotional
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).levels = [2, 1];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(4).scans = scans(:,4);
%Digital Functional
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).levels = [2, 2];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(5).scans = scans(:,5);
%Digital Metaphorical
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).levels = [2, 3];
matlabbatch{1}.spm.stats.factorial_design.des.fd.icell(6).scans = scans(:,6);
% Automatically generate contrasts
matlabbatch{1}.spm.stats.factorial_design.des.fd.contrasts = 1;

matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
%%
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
        %%
        matlabbatch{3}.spm.stats.con.spmmat = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'Main effect of Format';
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 1 1 -1 -1 -1];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'Main effect of Type';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 0 1 -1 0 1];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = 'Interaction';
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [-1 0 1 1 0 -1];
        matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        
        matlabbatch{3}.spm.stats.con.delete = 1;


fmr.Model.(modelName).anova.batch = matlabbatch;
PreProcessed = fmr;
cd(fmr.Model.(modelName).anova.directory);
    save(fullfile(fmr.Model.(modelName).anova.directory,['FullANOVA' date '.mat']),'matlabbatch');
            spm('defaults', 'FMRI');
            spm_jobman('serial', matlabbatch);
            cd(cwd);

