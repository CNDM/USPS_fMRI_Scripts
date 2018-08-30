function theData = Build_AdViewRegressor(s)

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

    AdView = tdfread(sprintf('AdView_%s.tsv',subjectID))
        
        Header = {'Onset','Duration','Type','Format'};
        AdView.Type = cellstr(AdView.Type)
        for i = 1:length(AdView.Type)
            switch AdView.Type{i}
                case 'Emotional'
                    Type(i) = 1;
                case 'Functional'
                    Type(i) = 2;
                case 'Metaphorical'
                    Type(i) = 3;
            end
            switch AdView.Format(i)
                case 'P'
                    Format(i) = 1
                case 'D'
                    Format(i) = 2
            end
        end
                
        
        
        AdView = [AdView.AdOnset,AdView.AdOffset - AdView.AdOnset,Type',Format']
                
        cd(saveDir)
        
        if exist(fullfile(saveDir,subjectID),'dir')==0
            mkdir(fullfile(saveDir,subjectID));
        end
        
        if exist(fullfile(saveDir,subjectID,sprintf('AdViewRegressor.%s',subjectID)))==2
            overwrite = input('WARNING: This file already exists \n Would you like to Overwrite it? (y/n)\n','s');
            if overwrite=='n'
                cd(cwd)
                return
            else
            csvwrite(fullfile(saveDir,subjectID,sprintf('AdViewRegressor%s',subjectID)),AdView)
            end
        else
            csvwrite(fullfile(saveDir,subjectID,sprintf('AdViewRegressor%s',subjectID)),AdView)
        end
        
    display(sprintf('Procedure successful for: %s',subjectID));
cd(cwd)
end