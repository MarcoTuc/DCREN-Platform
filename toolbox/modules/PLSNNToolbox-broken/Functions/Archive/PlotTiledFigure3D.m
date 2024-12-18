function PlotTiledFigure3D(xR,yR,zR) % Theory and Simulation Plot, one phosphosite
    
        % Set plotting parameters and code parameters and call the plot
        % routine
        
        

        % Set plot parameters
        titlePlot = 'RASi Only';
        legendOn = false;
        xLabel = 'yPLS';
        yLabel = "CD/UCD";
        zLabel = '100 \times \Delta EGFR / EGFR';
        xLim = [-20,20]; % Plot limits on x axis
        yLim = [-20,20]; % Plot limits on y axis
        zLim = [-20,20]; % Plot limits on z axis
        % Plot data

        xPlot = xR;
        yPlot = yR;
        zPlot = zR;
        
        %xv = linspace(min(xPlot), max(xPlot), 25);
        %yv = linspace(min(yPlot), max(yPlot), 25);
        %[X,Y] = meshgrid(xv, yv);
        %Z = griddata(xPlot,yPlot,zPlot,X,Y,'v4');
        %mesh(X,Y,Z)
        %axis tight
        
        plot3(xPlot,yPlot,zPlot,'d', 'Color','k', 'LineWidth',1 ,'MarkerSize',5,'MarkerFaceColor','k');
        

        % Plot Boilerplate
        pbaspect([3 3 1]);
 
        xlim(xLim);
        ylim(yLim);
        zlim(zLim);
 
        title([titlePlot]);
        xlabel(xLabel,'FontSize',20);
        ylabel(yLabel,'FontSize',20) ;
        zlabel(zLabel,'FontSize',20) ;
        if legendOn
           legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
        end
        % Set font size
        set(gca,'FontSize',11);

    end
    
    
    