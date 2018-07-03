function [  ] = handleDynamicHeatmaps( accumulator, numOfAllCells,numberOfResults, p, option, featureName )
% This function will handle the heatmaps. It will compute and show
% different heatmaps depending on the given options in 'option'.

%% MAIN CODE

% -- if heatmaps should be computed -- %

if option.heatmaps.process == 1
    fprintf('Computing heatmaps...');
    
    % -- Convolve over the points -- %
    %convAcc = convolveAccumulator(accumulator,option.cellradius,2*option.cellradius+1);
    
    % -- Compute heatmap heatmaps -- %
    HMS = generateHeatmap(accumulator,option.heatmaps.types);
    
    % Save heatmap structure HMS
    %if option.heatmaps.saveHMmat == 1
    %    mat_name = [p.resultsPath ,'/heatmaps/','Heatmap_Structure.mat'];
    %    save(mat_name,'HMS');
    %end
    
    % Save accumulator
    if option.heatmaps.saveAccumulator == 1
        mat_name = [p.resultsPath ,'/heatmaps/','Accumulator.mat'];
        save(mat_name,'accumulator');
    end
    
    % -- Create the figures -- %
    vis = 'on';
    if option.heatmaps.disp == 0
        vis = 'off';
    end
    
    for i=1:size(option.heatmaps.types,2)
        currentType = option.heatmaps.types{i};
        figs = [figure('Visible','off'),figure('Visible','off'),...
            figure('Visible','off'),figure('Visible','off')];
        if strcmp(option.heatmaps.scaled,'true')||strcmp(option.heatmaps.scaled,'both')
            [f,pca] = creatStdFigure_scaled(numberOfResults,numOfAllCells,HMS,currentType);      
            figs(i+(2*(i-1))) = copyobj(f,0);
            %set(findobj(figs(i+(2*(i-1))).Children,'Tag','sp3'),'position',pca); % TODO: IS THIS REALLY NEEDED?
            set(figs(i+(2*(i-1))),'Visible',vis);
            
            if option.heatmaps.save == 1
                if ~exist([p.resultsPath '/heatmaps'],'dir')
                    mkdir(p.resultsPath, 'heatmaps');
                end
                for j=1:size(option.heatmaps.saveas,2)
                    fig_filename = [p.resultsPath ,'/heatmaps/',featureName,'_',currentType,'_Heatmaps'];
                    saveas(f,fig_filename,option.heatmaps.saveas{j});
                end
            end
        end
        if strcmp(option.heatmaps.scaled,'false')||strcmp(option.heatmaps.scaled,'both')
            % Create figure
            f = creatStdFigure_unscaled(numberOfResults,numOfAllCells,HMS,currentType); 
            figs(i+1+(2*(i-1))) = copyobj(f,0);
            set(figs(i+1+(2*(i-1))),'Visible',vis);
            
            if option.heatmaps.save == 1
                if ~exist([p.resultsPath '/heatmaps'],'dir')
                    mkdir(p.resultsPath, 'heatmaps');
                end
                for j=1:size(option.heatmaps.saveas,2)
                    fig_filename = [p.resultsPath ,'/heatmaps/',featureName,'_',currentType,'_Heatmaps(unscaled)'];
                    saveas(f,fig_filename,option.heatmaps.saveas{j});
                end
            end
        end
    end
    
    
end

end
