function simple_gui2
% SIMPLE_GUI2 Select a data set from the pop-up menu, then
% click one of the plot-type push buttons. Clicking the button
% plots the selected data in the axes.

   %  Create and then hide the UI as it is being constructed.
   f = figure('Visible','off','Position',[360,500,750,485]);
   
   % Get values?
   t = timeseriesplot()
   %  Construct the components.
   hsurf = uicontrol('Style','listbox','String','Surf',...
           'Position',[20,400,140,75]);
   hmesh = uicontrol('Style','pushbutton','String','Mesh',...
           'Position',[20,350,70,25]);
   hcontour = uicontrol('Style','pushbutton',...
           'String','Contour',...
           'Position',[20,300,70,25]); 
   htext = uicontrol('Style','text','String','Select Data',...
           'Position',[20,250,60,15]);
   hpopup = uicontrol('Style','popupmenu',...
           'String',{'Peaks','Membrane','Sinc'},...
           'Position',[20,50,100,25]);
   ha = axes('Units','Pixels','Position',[400,60,300,300]); 
   align([hsurf,hmesh,hcontour,htext,hpopup],'Center','None');
   
   % Make the UI visible.
   f.Visible = 'on';

end

function t = timeseriesplot()
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
            t.avg_timeseries.(ROI{roiIdx})(subIdx).(contrasts{contrastIdx}) = mean(temp2);
            t.scaled_timeseries.(ROI{roiIdx})(subIdx).(contrasts{contrastIdx}) = mean(temp3);
        end
    end
end
end