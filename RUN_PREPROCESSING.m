function RUN_PREPROCESSING()
%This is where the magic happens. Let's see where it will take us.

%subs = [101,102,104:118,120,121,202,301]; COMPLETED
%subs = [122,123,201,205,206,302:305,307]; COMPLETED
%subs = [124,204,209];
%subs = [127,128];

% OLDER SUBJECTS (ROUND TWO!)
subs = [201,202,210,215,219,301:305,307:309,311,315:322,324,325,330];
%DicomConvert(); %Convert the files to 4D Files
%PreProcessing = fMRI_Preprocessing(subs,'4D'); %Grab the 4D files


% %Extract the brains.
%PreProcessing = BrainExtraction(PreProcessing);
% 
%Split into 3D
%PreProcessing = fMRI_Preprocessing(subs,'4D');
%PreProcessing = Run_splitTo3D(PreProcessing);

%Reorient
 PreProcessing = fMRI_Preprocessing(subs,'4D')
 %PreProcessing = ReOrient(PreProcessing);
% 
% 
% % Run FuncPrePro
% PreProcessing = Run_Funcprepro(PreProcessing);


% Run SNS
 PreProcessing = Run_SNS(PreProcessing);



end






    function PreProcessing = ReOrient(PreProcessing)
        for s_idx = 1:length(PreProcessing.sub)
            PreProcessing = fmr_Reorient4D(PreProcessing, PreProcessing.Subject(s_idx))
            Progress = PreProcessing.Progress;
            save(PreProcessing.ProgressPath,'Progress');
        end
    end

    function PreProcessing = BrainExtraction(PreProcessing)
        for s_idx = 1:length(PreProcessing.sub)
            PreProcessing = fmr_BrainExtraction(PreProcessing, PreProcessing.Subject(s_idx))
            Progress = PreProcessing.Progress;
            save(PreProcessing.ProgressPath,'Progress');
        end
    end

    function PreProcessing = Run_Funcprepro(PreProcessing)
        for s_idx = 1:length(PreProcessing.sub)
            PreProcessing = Run_Funcprepro_subfunc(PreProcessing, PreProcessing.Subject(s_idx))
            Progress = PreProcessing.Progress;
            save(PreProcessing.ProgressPath,'Progress');
        end
    end

    function PreProcessing = Run_Funcprepro_subfunc(fmr,sub)
        cwd = pwd;
        progress_sidx = find(fmr.Progress.Subject==str2num(sub.subID));
            cd(sub.mriDir);
            matlabbatch = sub.FuncpreproBatch;
            save(fullfile(sub.mriDir,['FuncPrePro' date '.mat']),'matlabbatch');
            spm('defaults', 'FMRI');
            spm_jobman('serial', matlabbatch);
            cd(cwd);
            fmr.Progress.Funcprepro(progress_sidx) = 1;
            PreProcessing = fmr;
    end
    
    function PreProcessing = Run_splitTo3D(PreProcessing)
    for s_idx = 1:length(PreProcessing.sub)
        PreProcessing = splitTo3D_subfunc(PreProcessing, PreProcessing.Subject(s_idx))
        Progress = PreProcessing.Progress;
        save(PreProcessing.ProgressPath,'Progress');
    end
    PreProcessing = fMRI_Preprocessing(PreProcessing.sub,'4D');
    end
    
    function PreProcessing = splitTo3D_subfunc(fmr,sub)
        cwd = pwd;
        defaults = spm('defaults','fmri');
        progress_sidx = find(fmr.Progress.Subject==str2num(sub.subID));
            for i = 1:length(fmr.runs)
                Run = sub.Scans.Functional.(fmr.runs{i});
                matlabbatch{1}.spm.util.split.vol = Run.rawScans;
                matlabbatch{1}.spm.util.split.outdir = {Run.directory};
                spm('defaults', 'FMRI');
                spm_jobman('serial', matlabbatch);
                cmd = sprintf('mv %s %s', Run.rawScans{1}, [Run.rawScans{1}(1:end-4) '_4D.nii']);
                system(cmd);
                cd(cwd);
            fmr.Progress.Split(progress_sidx);
        end
        PreProcessing = fmr;
    end
    
    
    
    
    
    function PreProcessing = Run_SNS(PreProcessing)
        for s_idx = 1:length(PreProcessing.sub)
            PreProcessing = Run_SNS_subfunc(PreProcessing, PreProcessing.Subject(s_idx))
            Progress = PreProcessing.Progress;
            save(PreProcessing.ProgressPath,'Progress');
        end
    end

    function PreProcessing = Run_SNS_subfunc(fmr,sub)
        cwd = pwd;
        progress_sidx = find(fmr.Progress.Subject==str2num(sub.subID));
            cd(sub.mriDir);
            matlabbatch = sub.SNSBatch;
            save(fullfile(sub.mriDir,['SNS' date '.mat']),'matlabbatch');
            spm('defaults', 'FMRI');
            spm_jobman('serial', matlabbatch);
            cd(cwd);
            fmr.Progress.SNS(progress_sidx) = 1;
            PreProcessing = fmr;
    end
        
 
        