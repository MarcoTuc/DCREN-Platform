function PlotTiledFigureA(ax2,xD,yD,yLR,yPLS,yNN,titlePlot,legendOn,xLabel,yLabel,xLim,yLim,markerSize) % Theory and Simulation Plot, one phosphosite
    
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
        
         % Actual Data
        colorModel = 'k';
        markerSize = 2;
        xPlot = xD;
        yPlot = yD;
        plot(xPlot,yPlot,'+', 'Color',colorModel, 'LineWidth',1 ,'MarkerSize',markerSize,'MarkerFaceColor',colorModel);
        
         % Linear Regression
        colorModel = '#FF7700';
        xPlot = xD;
        yPlot = yLR;
        %plot(xPlot,yPlot,'s', 'Color',colorModel, 'LineWidth',1 ,'MarkerSize',5);
        
        % Secondary Data
        colorModel = 'r';
        markerSize = markerSize + 2;
        xPlot = xD;
        yPlot = yPLS;
        plot(xPlot,yPlot,'d', 'Color',colorModel, 'LineWidth',1 ,'MarkerSize',markerSize);
        
        % Tertiary Data
        colorModel = 'b';
        xPlot = xD;
        yPlot = yNN;
        %plot(xPlot,yPlot,'+', 'Color',colorModel, 'LineWidth',1 ,'MarkerSize',markerSize);
        
       

        % Boilerplate
        titlePlot = "PLS Model of RASi Alone"
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