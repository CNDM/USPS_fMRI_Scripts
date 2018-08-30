function RUN_MODEL()

cwd = pwd;
% subs = [101:102,104:107,109:118,120:124,127,128,204,205,206,208,209]; %Without 108
%subs = [101,104:118,120:124,127,128,204,205,206,208,209]; %With 108
subs = [101,104:107,109:118,120:124,127,128,204,205,206,208,209]; % For adaptation
PreProcessing = fMRI_Preprocessing(subs,'4D'); %Grab the 4D files


%% Add Contrasts (edit addContrasts file)
%   addContrasts('fmrAdapt2_Model',PreProcessing);

%% Get TimeSeries (only for fmrAdapt_Model for now)
models = {'AdView_Model',...        % 1
          'BrandRec_Model',...      % 2
          'BrandRec2_Model',...     % 3
          'Recognition_Model',...   % 4
          'fmrAdapt_Model',...      % 5
          'fmrAdapt2_Model'};     % 6
      model_select = [4];
      
cd([cwd '/TimeSeries']);
for m = 1:length(model_select)
    timeseries = get_timeSeries(PreProcessing,models{model_select(m)},0);
end
cd(cwd)

%% First Level Models Model
% PreProcessing = Run_Model(PreProcessing,'AdView_Model',0);
% PreProcessing = Run_Model(PreProcessing,'BrandRec_Model',0);
% PreProcessing = Run_Model(PreProcessing,'BrandRec2_Model',0);
% PreProcessing = Run_Model(PreProcessing,'Recognition_Model',1);
% PreProcessing = Run_Model(PreProcessing,'fmrAdapt_Model',1);
% PreProcessing = Run_Model(PreProcessing,'fmrAdapt2_Model',1);



%% Second Level Models

% Run_SecondLevel(PreProcessing,'AdView_Model');
% Run_SecondLevel(PreProcessing,'BrandRec_Model');
% Run_SecondLevel(PreProcessing,'BrandRec2_Model');
% Run_SecondLevel(PreProcessing,'Recognition_Model');
% Run_SecondLevel(PreProcessing,'fmrAdapt_Model');
% Run_SecondLevel(PreProcessing,'fmrAdapt2_Model');
% Run_SecondLevel(PreProcessing,'AdView_Model');




%% Generate ANOVAs
% PreProcessing = fmr_ANOVA_AdView_Model(PreProcessing);
% PreProcessing = fmr_ANOVA_BrandRec_Model(PreProcessing,0);
% PreProcessing = fmr_ANOVA_BrandRec_Model(PreProcessing,1);
% PreProcessing = fmr_ANOVA_Recognition_Model(PreProcessing);

end




%% SECOND LEVEL FUNCTIONS
function Run_SecondLevel(fmr,modelName)
    fmr = buildSecondLevel(fmr,modelName);
    
    for c = 1:length(fmr.Model.(modelName).Contrasts)
    cwd=pwd;
    cd(fmr.Model.(modelName).Contrasts(c).directory);
    matlabbatch = fmr.Model.(modelName).Contrasts(c).batch;
    save(fullfile(fmr.Model.(modelName).Contrasts(c).directory,['SecondLevel' date '.mat']),'matlabbatch');
            spm('defaults', 'FMRI');
            spm_jobman('serial', matlabbatch);
            cd(cwd);
    end
    
end


%% FIRST LEVEL FUNCTIONS

    
    function PreProcessing = Run_Model(fmr,modelName,overwrite)
    
    switch nargin
    case 2
        overwrite = 0;
    end
    
    switch modelName
        case 'AdView_Model'
            model = 'adview';
        case 'BrandRec_Model'
            model = 'brandrec';
        case 'BrandRec2_Model';
            model = 'brandrec'
        case 'Recognition_Model'
            model = 'recog_1'
        case 'fmrAdapt_Model';
            model = 'fmradapt_1';
        case 'fmrAdapt2_Model';
            model = 'fmradapt_1';
    end
    
    for s_idx = 1:length(fmr.sub)
        sub = fmr.Subject(s_idx);
        cwd = pwd;
        cd(sub.Scans.Functional.(model).directory);
        modelDir = [sub.Scans.Functional.(model).directory '/' modelName]
        
        if overwrite == 1
            if exist([modelDir '/mask.nii'])
                dirData = dir(modelDir);
                validIndex = ~ismember({dirData(:).name},{'.','..','.DS_Store'});
                batchList = sort({dirData(validIndex).name})';
                for i = 1:length(batchList)
                    if ~strcmp(batchList{i},'movementparameter.mat')
                        cmd = sprintf('rm %s', [modelDir '/' batchList{i}]);
                        system(cmd);
                    end
                end
            end
        end
        matlabbatch = sub.(sprintf('%s_Batch',modelName));
        save(fullfile(sub.Scans.Functional.(model).directory,[modelName date '.mat']),'matlabbatch');
        spm('defaults', 'FMRI');
        spm_jobman('serial', matlabbatch);
        cd(cwd);
        PreProcessing = fmr;
    end
    end