function [] = Batch_MovementPlots()

cwd = pwd;
mainDir = uigetdir(cwd, 'Select preprocessed directory');
%mainDir = '/Users/CNDM/Documents/USPS 2016/fMRI Preprocessed';
outputDir = uigetdir(cwd, 'Select output directory for plots');
%outputDir= '/Users/CNDM/Documents/USPS 2016/Movement Plots';

try
    dstore = get_any_files('.DS_Store',mainDir);
    for i = 1:length(dstore)
        delete(dstore{i});
    end
catch
end

%Get list of all folders containing dicoms (one per subject)
batchList = strsplit(sprintf('%s',strtrim(ls(mainDir))));

%Creating selection List
for index = 1:length(batchList)
    selectionOptions(index,1) = {batchList{index}};
end

subject_selection = listdlg('ListString',selectionOptions,...
    'SelectionMode','multiple',...
    'PromptString','Choose subjects for plot.');

temp = batchList; clear batchList
batchList = temp(subject_selection);

for subIndex = 1:length(batchList)
        movementfiles = get_any_files('rp',fullfile(mainDir,batchList{subIndex}));

        graph = figure;
        doOnce = true;
        for count = 1:length(movementfiles)
            movementparams.(['Run' num2str(count)]) = load(movementfiles{count});
            subplot(3,5,count), plot(movementparams.(['Run' num2str(count)])(:,1:3))
            ylim([-5 5])
            if count == 7
                title('Movement XYZ Rest');
            else
                title(['Movement XYZ Run ' num2str(count)]);
            end
            ylabel('mm')
            if doOnce
                legend('x','y','z','orientation','horizontal','location','s')
            end
            set(gca,'xlim',[0 size(movementparams.(['Run' num2str(count)]),1)+7])
            
            subplot(3,5,count+7), plot(movementparams.(['Run' num2str(count)])(:,4:6))
            ylim([-0.1 0.1])
            if count == 7
                title('Movement [pitch roll yaw] Rest');
            else
                title(['Movement [pitch roll yaw] Run ' num2str(count)]);
            end
            ylabel('radian')
            if doOnce
                legend('pitch','roll','yaw','orientation','horizontal','location','se')
                doOnce = false;
            end
            set(gca,'xlim',[0 size(movementparams.(['Run' num2str(count)]),1)+7])
        end
        subid=batchList(subIndex);
        suptitle(subid{1}(1:5))

        cd(outputDir)
        set(gcf,'PaperUnits','inches','PaperPosition',[0 0 20 14])
        print(graph, [batchList{subIndex}(1:5) '_movement'],'-dpng') % r = resolution (in dpi) - 1200 is best quality for print, can lower to lower file size (recommend dpi of  600 or higher)
        close all
        
        cd(cwd);
end
end
    

