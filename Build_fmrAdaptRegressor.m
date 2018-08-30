function theData = Build_fmrAdaptRegressor(s,overwrite)

%%%% Takes Subject number as input, builds 3 files of onsets, Responses,
%%%% and RT, saves these into the saveDir as csv files. Please change the
%%%% dataDir and saveDir to match where your data is, and where you want to
%%%% save the new files. Will create folders for each sub number

% Composed by Anthony Resnick, June 8 2017



cwd = pwd;

%---------------------------------------------------------------
% ****************************************************************************
% *** Please change these to your data and save directories ***
% ****************************************************************************

% Anthony's Directory
if s < 200
    dataDir = '/Users/CNDM/Dropbox/USPS 2017/Results/Main_Study/Millenials';
elseif s < 300
    dataDir = '/Users/CNDM/Dropbox/USPS 2017/Results/Main_Study/GenX';
elseif s > 299
    dataDir = '/Users/CNDM/Dropbox/USPS 2017/Results/Main_Study/Baby_Boomers';
end
    
    saveDir = '/Users/CNDM/Dropbox/USPS2017_ET_fMRI/fMRI_USPS/Regressors';


%---------------------------------------------------------------

    subjectID = num2str(s);
    sourcename = fullfile(dataDir,subjectID);
    cd(sourcename)

    adapt1 = tdfread(sprintf('fmrAdapt_run_1_%s.tsv',subjectID));
    adapt2 = tdfread(sprintf('fmrAdapt_run_2_%s.tsv',subjectID));
    
    Times1 = [adapt1.pair1Onset,adapt1.pair1Offset,adapt1.pair2Onset,adapt1.pair2Offset,adapt1.questOnset,adapt1.questRT];
    Times2 = [adapt2.pair1Onset,adapt2.pair1Offset,adapt2.pair2Onset,adapt2.pair2Offset,adapt2.questOnset,adapt2.questRT]+314;
    timeTotal = [Times1;Times2] - 4;
    adapt.Condition = [adapt1.Condition;adapt2.Condition];
    adapt.Group = [cellstr(adapt1.Group);cellstr(adapt2.Group)];
    adapt.PairGroup = [cellstr(adapt1.PairGroup);cellstr(adapt2.PairGroup)];
  
        Header = {'CategoryOnset','CategoryOffset','BrandOnset','BrandOffset','MemoryOnset','MemoryRT','Type','Format'};
        CategoryOnset = timeTotal(:,1);
        CategoryOffset = timeTotal(:,2)-timeTotal(:,1);
        BrandOnset = timeTotal(:,3);
        BrandOffset = timeTotal(:,4)-timeTotal(:,3);
        MemoryOnset = timeTotal(:,5);
        MemoryRT = timeTotal(:,6)-timeTotal(:,5);
        

        for i = 1:length(timeTotal)
            if adapt.Condition(i) == 1
                switch adapt.Group{i}
                    case 'x'
                        Format(i) = 2;
                    case 'y'
                        Format(i) = 1;
                end
            elseif adapt.Condition(i)==2
                switch adapt.Group{i}
                    case 'x'
                        Format(i) = 1;
                    case 'y'
                        Format(i) = 2;
                end
            end
            switch adapt.PairGroup{i}
                case 'A'
                    Type(i) = 1;
                case 'B'
                    Type(i) = 2;
                case 'Foils'
                    Type(i) = 3;
                case 'Control'
                    Type(i) = 4;
            end
            
        end
        
                
        
        
        Recognition = [CategoryOnset,CategoryOffset,BrandOnset,BrandOffset,MemoryOnset,MemoryRT,Type',Format'];
                
        cd(saveDir)
        
        if exist(fullfile(saveDir,subjectID),'dir')==0
            mkdir(fullfile(saveDir,subjectID));
        end
        
        if overwrite == 1
            csvwrite(fullfile(saveDir,subjectID,sprintf('fmrAdaptRegressor%s',subjectID)),Recognition)
        else
            if exist(fullfile(saveDir,subjectID,sprintf('fmrAdaptRegressor%s',subjectID)))==2
                overwrite = input('WARNING: This file already exists \n Would you like to Overwrite it? (y/n)\n','s');
                if overwrite=='n'
                    cd(cwd)
                    return
                else
                    csvwrite(fullfile(saveDir,subjectID,sprintf('fmrAdaptRegressor%s',subjectID)),Recognition)
                end
                
            else
                csvwrite(fullfile(saveDir,subjectID,sprintf('fmrAdaptRegressor%s',subjectID)),Recognition)
            end
        end
        
        display(sprintf('Procedure successful for: %s',subjectID));
        cd(cwd)
end


