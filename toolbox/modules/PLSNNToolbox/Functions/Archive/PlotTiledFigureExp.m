function PlotTiledFigureExp(ax2,xPlot_R,yPlot_R,titlePlot,legendOn,xLabel,yLabel,xLim,yLim,markerSize,color,lineType) % Theory and Simulation Plot, one phosphosite
    
        % Set plotting parameters and code parameters and call the plot
        % routine
        
        hold on; % Allows for multiple curves on one plot

        % Plot data
        plot(xPlot_R,yPlot_R,lineType, 'Color',color, 'LineWidth',1 ,'MarkerSize',markerSize,'MarkerFaceColor',color);

        
        % Boilerplate
        pbaspect([3 3 1]);
        xlim(xLim);
        ylim(yLim);
        title([titlePlot]);
        xlabel(xLabel,'FontSize',20);
        ylabel(yLabel,'FontSize',20) ;
        if legendOn
           legend(ax2,'All Cont.',  'Expert', 'NN', 'Location','south', 'NumColumns',4, 'Box', 'on');
        end
        % Set font size
        set(gca,'FontSize',11);
        
        hold off;
    end
    