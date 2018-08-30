function plot_timeseries()
timeseriesDir = '/Users/CNDM/Dropbox/USPS2017_ET_fMRI/fMRI_USPS/Scripts/TimeSeries/';
ts = load([timeseriesDir 'fmrAdapt2_timeseries.mat']);
do_plot_timeseries(ts.timeseries)

end




function do_plot_timeseries(timeseries)
ROI = fieldnames(timeseries);
for roiIdx = 1:length(ROI)
    contrasts = fieldnames(timeseries.(ROI{roiIdx}));
    for contrastIdx = 1:length(contrasts)
        for subIdx = 1:size(timeseries.(ROI{roiIdx}),2)
            temp = timeseries.(ROI{roiIdx})(subIdx).(contrasts{contrastIdx});
            temp2 = [];
            for i = 1:length(temp)
                temp2 = [temp2;temp{i}];
            end
            temp3 = temp2(:,1) - temp2(:,1);
            for i = 2:length(temp2)
                temp3(:,i) = (temp2(:,i)-temp2(:,1))./temp2(:,1);
            end
            avg_timeseries.(ROI{roiIdx})(subIdx).(contrasts{contrastIdx}) = mean(temp2);
            scaled_timeseries.(ROI{roiIdx})(subIdx).(contrasts{contrastIdx}) = mean(temp3);
        end
    end
end
analysis_type = {'average','scaled'};
source_selection = listdlg('ListString',analysis_type,...
    'SelectionMode','multiple',...
    'PromptString','Choose conditions to analyze.');
if isempty(source_selection)==1; return; end

switch source_selection
    case 1
        ts = avg_timeseries;
    case 2
        ts = scaled_timeseries
end


for roiIdx = 1:length(ROI)
    contrasts = fieldnames(ts.(ROI{roiIdx}));
    for contrastIdx = 1:length(contrasts)
        stderror = [];
        temp = [];
        for subIdx = 1:size(ts.(ROI{roiIdx}),2)
            temp(subIdx,:) = ts.(ROI{roiIdx})(subIdx).(contrasts{contrastIdx});
        end
        for i = 1:size(temp,2)
            stderror(1,i) = std(temp(:,i)) / sqrt(length(temp));
        end
        collapse_timeseries.(ROI{roiIdx}).(contrasts{contrastIdx}) = temp;
        se_timeseries.(ROI{roiIdx}).(contrasts{contrastIdx}) = stderror;
    end
end

BySubject = listdlg('ListString',{'Collapse Subjects','Show all Subjects'},...
    'SelectionMode','single',...
    'PromptString','Choose one ROI to analyze.');
if isempty(BySubject)==1; return; end


ROI_selection = listdlg('ListString',ROI,...
    'SelectionMode','multiple',...
    'PromptString','Choose one ROI to analyze.');
if isempty(ROI_selection)==1; return; end

Contrast_selection = listdlg('ListString',contrasts,...
    'SelectionMode','multiple',...
    'PromptString','Choose contrasts to analyze.');
if isempty(Contrast_selection)==1; return; end



    
    if BySubject == 1
        for ridx = 1:length(ROI_selection)
            c = fields(ts.(ROI{ROI_selection(ridx)}));
            figure()
            hold on
            for cidx = Contrast_selection
                y = se_timeseries.(ROI{ROI_selection(ridx)}).(contrasts{cidx})
                x = mean(collapse_timeseries.(ROI{ROI_selection(ridx)}).(contrasts{cidx}))
                errorbar(x,y)
            end
            legend(c(Contrast_selection))
            title(sprintf('REGION: %s     %s',ROI{ROI_selection(ridx)},upper(analysis_type{source_selection})));
        end
        
    elseif BySubject == 2
        for ridx = 1:length(ROI_selection)
            
            figure()
            hold on
            for i = 1:length(scaled_timeseries.(ROI{ROI_selection(ridx)}))
                plot(collapse_timeseries.(ROI{ROI_selection(ridx)}).(contrasts{Contrast_selection})(i,:))
            end
            legend(sprintfc('%d',[1:27]))
                    title(sprintf('REGION: %s   CONTRAST: %s     %s',ROI{ROI_selection(ridx)},contrasts{            title(sprintf('REGION: %s   CONTRAST: %s     %s',ROI{ROI_selection(ridx)},contrasts{cidx},upper(analysis_type(source_selection))))},upper(analysis_type{source_selection})));
        end
    end
end
