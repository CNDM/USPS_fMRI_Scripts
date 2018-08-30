%subs = [101:102,104:107,109:118,120:124,127,128,204,205,206,208,209];
subs = [201,202,210,215,219,301:305,307:309,311,315:322,324,325,330];
%subs = [318:322,324,325,330];
%subs = 219
for s = 1:length(subs)
    %Build_AdViewRegressor(subs(s)); %Done
    %Build_BrandRecRegressor(subs(s)); %Done
    %Build_BrandRec2Regressor(subs(s)); %Need to get Post Score
    %Build_fmrAdaptRegressor(subs(s),1); %Done
    %Build_fmrAdapt2Regressor(subs(s),1); %Done
    Build_RecogRegressor(subs(s),1);
end