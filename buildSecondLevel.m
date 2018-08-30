function fmr = buildSecondLevel(fmr,modelName)
    cwd=pwd;
    
    fmr.Model.(modelName).name = modelName;
    fmr.Model.(modelName).subs = fmr.sub;
    
    fmr.Model.(modelName).directory = [fmr.secondLevelDir '/' modelName '_' num2str(length(fmr.sub))];
    
    if ~exist(fmr.Model.(modelName).directory) % exist requires string format
         mkdir(fmr.Model.(modelName).directory)
    end
    
    tempDir = sprintf('fmr.Subject(1).%s_Batch{1,1}.spm.stats.fmri_spec.dir{:}',modelName);
    cd(eval(tempDir));
    conspm=[tempDir 'SPM.mat'];
    cmd = ['load ' ['SPM.mat']];
    eval(cmd);
    cd(cwd)
    %How many contrasts?
    cons=length(SPM.xCon);
    
    for c=1:cons
        fprintf('Working on Contrast %d / %d \n', c, cons)
        %Create condir if necessary
        fmr.Model.(modelName).Contrasts(c).directory = [fmr.Model.(modelName).directory '/' SPM.xCon(c).name];
        condir = fmr.Model.(modelName).Contrasts(c).directory
        if exist(condir)~=1 % exist requires string format
            mkdir(condir)
        end
        concell{1} =condir;
        
        scans=cell(length(fmr.sub),1);
        for sub=1:length(fmr.sub)
            modeldir = fullfile(fmr.Subject(sub).Scans.Functional.(model).directory,modelName);
            if c<10
                scans(sub)={[modeldir '/con_000' num2str(c) '.nii,1']};
            else
                scans(sub)={[modeldir '/con_00' num2str(c) '.nii,1']};
            end
        end %subj loop
        fmr.Model.(modelName).Contrasts(c).files = scans;
        
        matlabbatch{1}.spm.stats.factorial_design.dir = concell;
        matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = scans;
        matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
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
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = SPM.xCon(c).name;
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = 1;
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.delete = 1;
        
        % save(fullfile(condir,['AdView_BasicModel_SecondLevel -' date '.mat']),'matlabbatch');
% spm('defaults', 'FMRI');
% spm_jobman('serial', matlabbatch);
    fmr.Model.(modelName).Contrasts(c).batch = matlabbatch;

end %con loop
cd(cwd)
end   

