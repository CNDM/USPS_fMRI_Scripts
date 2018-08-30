function theData = Build_BrandRecRegressor(s)

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

    BrandRec = tdfread(sprintf('BrandRec_%s.tsv',subjectID))
        
        Header = {'BrandOnset','BrandDuration','RememberOnset','RememberDuration','VividOnset','VividDuration','VividResponse','Type','Format'};
        BrandOnset = BrandRec.BrandOnset;
        BrandDuration = BrandRec.RememberOnset - BrandRec.BrandOnset;
        RememberOnset = BrandRec.RememberOnset;
        RememberDuration = BrandRec.VividOnset - BrandRec.RememberOnset;
        VividOnset = BrandRec.VividOnset;
        VividDuration = BrandRec.VividRT - BrandRec.VividOnset;
        VividResponse = BrandRec.VividResponse;
        BrandRec.Type = cellstr(BrandRec.Type)
        for i = 1:length(BrandRec.Type)
            switch BrandRec.Type{i}
                case 'Emotional'
                    Type(i) = 1;
                case 'Functional'
                    Type(i) = 2;
                case 'Metaphorical'
                    Type(i) = 3;
            end
            if BrandRec.Condition(i) == 1
                switch BrandRec.Group(i)
                    case 'x'
                        Format(i) = 2
                    case 'y'
                        Format(i) = 1
                end
            elseif BrandRec.Condition(i)==2
                switch BrandRec.Group(i)
                    case 'x'
                        Format(i) = 1
                    case 'y'
                        Format(i) = 2
                end
            end
            
        end
        
                
        
        
        BrandRec = [BrandOnset,BrandDuration,RememberOnset,RememberDuration,VividOnset,VividDuration,VividResponse,Type',Format']
                
        cd(saveDir)
        
        if exist(fullfile(saveDir,subjectID),'dir')==0
            mkdir(fullfile(saveDir,subjectID));
        end
        
        if exist(fullfile(saveDir,subjectID,sprintf('BrandRecRegressor.%s',subjectID)))==2
            overwrite = input('WARNING: This file already exists \n Would you like to Overwrite it? (y/n)\n','s');
            if overwrite=='n'
                cd(cwd)
                return
            else
            csvwrite(fullfile(saveDir,subjectID,sprintf('BrandRecRegressor%s',subjectID)),BrandRec)
            end
        else
            csvwrite(fullfile(saveDir,subjectID,sprintf('BrandRecRegressor%s',subjectID)),BrandRec)
        end
        
    display(sprintf('Procedure successful for: %s',subjectID));
cd(cwd)
end