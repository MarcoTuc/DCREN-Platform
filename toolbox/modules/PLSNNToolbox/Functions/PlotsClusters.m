function PlotsClusters(DataStruct)
        Plot5(DataStruct);
end

function Plot5(DataStruct)
        figure
        tiledlayout(1,2); % Layout of figures
        titlePlot = "Window";
        xLabel = 'yNN';
        yLabel = 'yD';
        PlotTiledFigureD(DataStruct,titlePlot,xLabel,yLabel); % Plot 
        PlotTiledFigureD(DataStruct,titlePlot,xLabel,yLabel); % Plot
end

function PlotTiledFigureD(DataStruct,titlePlot,xLabel,yLabel)
            ax2 = nexttile; 
            hold on;
            color = 'k';
            markerSize = 2;
            xPlot = DataStruct.window.biomarkersWindow(:,2);
            yPlot = DataStruct.window.biomarkersWindow(:,1) ;
            plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',1 ,'MarkerSize',markerSize,'MarkerFaceColor',color); % Plot
                % Boilerplate
                pbaspect([3 3 1]);
                %xLim = [0,13];
                %yLim = [-2.5,2.5];
                %xlim(xLim);
                %ylim(yLim);
                title([titlePlot]);
                xlabel(xLabel,'FontSize',10);
                ylabel(yLabel,'FontSize',10) ;
            hold off;
                legendOn = false;
                if legendOn
                   legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
                end
            % Set font size
            set(gca,'FontSize',11);
end
        
        
        
        
        
        
        
 % ARCHIVE
 % ************************************************************************     
function PlotTiledFigure(xPlot,yPlot,titlePlot,xLabel,yLabel)
    %s = "Entering PlotTiledFigure"
    
    ax2 = nexttile;
    
    hold on;
    
    % Plot DEGFR_2 vs EGFR_1
    color = 'k';
    markerSize = 2;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',1 ,'MarkerSize',markerSize,'MarkerFaceColor',color);

    % Boilerplate
    pbaspect([3 3 1]);
    xLim = [min(xPlot),max(xPlot)]; % x axis bounds
    yLim = [min(yPlot),max(yPlot)]; % y axis bounds
    xlim(xLim);
    ylim(yLim);
    title([titlePlot]);

    xlabel(xLabel,'FontSize',20);
    ylabel(yLabel,'FontSize',20) ;
        legendOn = false;
        if legendOn
           legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
        end
    % Set font size
    set(gca,'FontSize',11);

    hold off;
end


function Plot1(DataStruct)

    s = "Entering Plot1"

    % Start figure plot
        figure
        tiledlayout(1,1);

        titlePlot = "RASI Alone";
        xLabel = 'EGFR';
        yLabel = '% \Delta';
        xPlot = DataStruct.EGFR_1;
        yPlot = DataStruct.DEGFR_2;
        %PlotTiledFigure(xPlot,yPlot,titlePlot,xLabel,yLabel);
        
        titlePlot = "RASI Alone";
        xLabel = 'ADIPOQ';
        yLabel = '% \Delta';
        xPlot = DataStruct.ADIPOQ_LUM_num_1;
        yPlot = DataStruct.DEGFR_2;
        %PlotTiledFigure(xPlot,yPlot,titlePlot,xLabel,yLabel);
        
        titlePlot = "RASI Alone";
        xLabel = 'ICAM1';
        yLabel = '% \Delta';
        xPlot = DataStruct.ICAM1_LUM_num_1;
        yPlot = DataStruct.DEGFR_2;
        %PlotTiledFigure(xPlot,yPlot,titlePlot,xLabel,yLabel);
        
        titlePlot = "RASI Alone";
        xLabel = 'ICAM1';
        yLabel = 'ADIPOQ';
        xPlot = DataStruct.ICAM1_LUM_num_1;
        yPlot = DataStruct.ADIPOQ_LUM_num_1;
        %PlotTiledFigure(xPlot,yPlot,titlePlot,xLabel,yLabel);
        
        titlePlot = "RASI Alone";
        xLabel = 'EGFR';
        yLabel = 'ADIPOQ';
        xPlot = DataStruct.EGFR_1;
        yPlot = DataStruct.ADIPOQ_LUM_num_1;
        %PlotTiledFigure(xPlot,yPlot,titlePlot,xLabel,yLabel);
        
        titlePlot = "RASI Alone";
        xLabel = 'EGFR';
        yLabel = 'ICAM1';
        xPlot = DataStruct.EGFR_1;
        yPlot = DataStruct.ICAM1_LUM_num_1;
        %PlotTiledFigure(xPlot,yPlot,titlePlot,xLabel,yLabel);
        
       
end


function Plot2(DataStruct)
        figure
        tiledlayout(2,3);

        titlePlot = "Clusters";
        xLabel = 'eGFR';
        yLabel = '% \Delta eGFR';

        PlotTiledFigureB(DataStruct,titlePlot,xLabel,yLabel);
        
end


function mean_Clusters = Plot3(DataStruct)
        figure
        tiledlayout(2,3);

        titlePlot = "Clusters";
        xLabel = 'eGFR';
        yLabel = '% \Delta eGFR';

        mean_Clusters = PlotTiledFigureC(DataStruct,titlePlot,xLabel,yLabel);
        
end


function Plot4(DataStruct)
        figure
        tiledlayout(1,2);

        titlePlot = "Biomarkers By Age";
        xLabel = 'Normalized Age';
        yLabel = 'Normalized Biomarker Value';

        PlotTiledFigureD(DataStruct,titlePlot,xLabel,yLabel);
        
end


function PlotTiledFigureB(DataStruct,titlePlot,xLabel,yLabel)
    s = "Entering PlotTiledFigureB"

    for j=1:DataStruct.numClusters
        
        ax2 = nexttile;
    
        hold on;
        
        % Plot boundaries on controlled and uncontrolled
        color = 'g';
        markerSize = 1;
        xPlot = [ 0,80];
        yPlot = [-5,-5];
        plot(xPlot,yPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
        yPlot = [-10,-10];
        plot(xPlot,yPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);

        color = 'k';
        markerSize = 5;
        individualClustersCell = DataStruct.individualClusters(j,:);
        individualClustersMat = cell2mat(individualClustersCell);
        
        xPlot = individualClustersMat(:,2); 
        yPlot = individualClustersMat(:,1); 
        plot(xPlot,yPlot,'d','Color',color, 'LineWidth',1 ,'MarkerSize',markerSize);
    

        % Boilerplate
        pbaspect([3 3 1]);

        titlePlot = "Cluster " + j;
        xLim = [0,80];
        yLim = [-80,80];
        xlim(xLim);
        ylim(yLim);
        title([titlePlot]);

        xlabel(xLabel,'FontSize',20);
        ylabel(yLabel,'FontSize',20) ;
            legendOn = false;
            if legendOn
               legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
            end
        % Set font size
        set(gca,'FontSize',11);

        hold off;
    end
end


function mean_Clusters = PlotTiledFigureC(DataStruct,titlePlot,xLabel,yLabel)
    s = "Entering PlotTiledFigureC"
        %DataStruct.numBiomarkers = 5
        xxx = zeros(DataStruct.numClusters,DataStruct.numBiomarkers);
        
        for j=1:DataStruct.numClusters
          ax2 = nexttile; 
          titlePlot = j;
            
          hold on;
          
                indClustCell = DataStruct.individualClusters(j,:);
                indClustMat = cell2mat(indClustCell);
                indClustMean = mean(indClustMat);

                indClustStd = std(indClustMat);

                DMean = indClustMean - DataStruct.mean_Biomarkers;
                sigmasq = indClustStd .* DataStruct.std_Biomarkers;
                sigma = sqrt(sigmasq);
                xxx = DMean ./ sigma;
                xxx = transpose(xxx);
                
                X = categorical({'\Delta','EGFR','UACR','ADIPOQ','ICAM1','BMI','SBP','DBP','HBA1C','TOTCHOL','HB','AGEV'});
                X = reordercats(X,{'\Delta','EGFR','UACR','ADIPOQ','ICAM1','BMI','SBP','DBP','HBA1C','TOTCHOL','HB','AGEV'});
                Y = xxx;
                bar(X,Y)
                
                xxx = transpose(xxx);
                mean_Clusters = xxx;
                writematrix(mean_Clusters,"ClusterOutput/230426BbinaryClusteringMatrix.csv",'WriteMode','append');
                

            % Boilerplate
            pbaspect([3 3 1]);
            
            %xLim = [0,13];
            yLim = [-2.5,2.5];
            %xlim(xLim);
            ylim(yLim);
            title([titlePlot]);

            %xlabel(xLabel,'FontSize',20);
            %ylabel(yLabel,'FontSize',20) ;
                legendOn = false;
                if legendOn
                   legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
                end
            % Set font size
            %set(gca,'FontSize',11);

            hold off;
        end
end
    
    
    

