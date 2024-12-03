
    
    % **************************************************************************** 
    % Individual Plots: Plots the four tiles
    % **************************************************************************** 
    
    
    
    

function PlotTiledFigurePLS(ax2,xCD,yCD,xUCD,yUCD,titlePlot,legendOn,xLabel,yLabel,xLim,yLim,markerSize) % Theory and Simulation Plot, one phosphosite
         %PlotTiledFigure(ax2,xDCD,yDCD,xDUCD,yDUCD,titlePlot,legendOn,xLabel,yLabel,xLim,yLim,markerSize+3)
    
        % Set plotting parameters and code parameters and call the plot
        % routine
        
        hold on; % Allows for multiple curves on one plot

        % Plot data
        color = 'k';
        xPlot = [ 20,100];
        yPlot = [-5,-5];
        plot(xPlot,yPlot,'-', 'Color',color, 'LineWidth',1 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
        yPlot = [-10,-10];
        plot(xPlot,yPlot,'--', 'Color',color, 'LineWidth',1 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
        
        % Secondary Data
        colorModel = 'r';
        xPlot = xUCD;
        yPlot = yUCD;
        %plot(xPlot,yPlot,'+', 'Color',colorModel, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',colorModel);
        plot(xPlot,yPlot,'+', 'Color',colorModel, 'LineWidth',1 ,'MarkerSize',markerSize);
        
        % Baseline Data
        colorModel = 'b';
        xPlot = xCD;
        yPlot = yCD;
        %plot(xPlot,yPlot,'o', 'Color',colorModel, 'LineWidth',1 ,'MarkerSize',markerSize,'MarkerFaceColor',colorModel);
        plot(xPlot,yPlot,'o', 'Color',colorModel, 'LineWidth',1 ,'MarkerSize',markerSize);

        % Boilerplate
        pbaspect([3 3 1]);
        xlim(xLim);
        ylim(yLim);
        title([titlePlot]);
        xlabel(xLabel,'FontSize',20);
        ylabel(yLabel,'FontSize',20) ;
        if legendOn
           legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
        end
        % Set font size
        set(gca,'FontSize',11);
        
        hold off;
    end
    
    



