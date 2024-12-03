function Plots()
    %s = "Entering Plots"
     % Get the inputs and outputs from the updated data set.

      %Plot1();
      Plot2();
end


function Plot1()
    % Start figure plot
        figure
        tiledlayout(2,2);
        
        xLim = [-125,25]; % x axis bounds
        yLim = [-50,25]; % y axis bounds
        
        titlePlot = "RASi Alone";
        PlotTiledFigureR(xLim,yLim,titlePlot);
        titlePlot = "RASi + GLP1";
        PlotTiledFigureG(xLim,yLim,titlePlot);
        titlePlot = "RASi + MCRa";
        PlotTiledFigureM(xLim,yLim,titlePlot);
        titlePlot = "RASi + SGLT2i";
        PlotTiledFigureS(xLim,yLim,titlePlot);

        saveas(gcf,'MasterOutput/DataExplorePlots.png'); 
end


function Plot2()
    % Start figure plot
        figure
        tiledlayout(2,2);
        
        xLim = [-125,25]; % x axis bounds
        yLim = [-50,25]; % y axis bounds
        
        titlePlot = "RASi Alone";
        PlotTiledFigureRR(xLim,yLim,titlePlot);
        titlePlot = "RASi + GLP1";
        PlotTiledFigureGG(xLim,yLim,titlePlot);
        titlePlot = "RASi + MCRa";
        PlotTiledFigureMM(xLim,yLim,titlePlot);
        titlePlot = "RASi + SGLT2i";
        PlotTiledFigureSS(xLim,yLim,titlePlot);

        saveas(gcf,'MasterOutput/DataExplorePlots.png'); 
end

function PlotTiledFigureR(xLim,yLim,titlePlot)
    ax2 = nexttile;
    hold on;
    % Plot boundaries on controlled and uncontrolled
    color = 'g';
    markerSize = 1;
    
    xPlot = [ -100,100];
    yPlot = [-5,-5];
    plot(xPlot,yPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    yPlot = [-10,-10];
    plot(xPlot,yPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);

    DataStructR = load('MasterOutput/DataStructR.mat');
    yNNTestArray = DataStructR.yNNTestArray;
    yDTestArray = DataStructR.yDTestArray;
    color = "k";
    xPlot = yNNTestArray;
    yPlot = yDTestArray;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',2 ,'MarkerSize',2,'MarkerFaceColor',color);
    %PlotScatter(yNNTestArray,yDTestArray,color);
    hold off;  
    
    % Boilerplate
    
    xLabel = "\Delta_R";
    yLabel = "\Delta eGFR %";
    pbaspect([3 3 1]);
    xlim(xLim);
    ylim(yLim);
    title([titlePlot]);
    xlabel(xLabel,'FontSize',20);
    ylabel(yLabel,'FontSize',20) ;
        %if legendOn
           %legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
        %end
    % Set font size
    set(gca,'FontSize',9); 
end


function PlotTiledFigureRR(xLim,yLim,titlePlot)
    ax2 = nexttile;
    hold on;
    % Plot boundaries on controlled and uncontrolled
    color = 'g';
    markerSize = 1;
    
    xPlot = [ -100,100];
    yPlot = [-5,-5];
    plot(xPlot,yPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    yPlot = [-10,-10];
    plot(xPlot,yPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);

    DataStructR = load('MasterOutput/DataStructR.mat');
    yNNTestArray = DataStructR.yNNTestArray;
    yDTestArray = DataStructR.yNNTestArray;
    color = "k";
    xPlot = yNNTestArray;
    yPlot = yDTestArray;
    plot(xPlot,yPlot,'-', 'Color',color, 'LineWidth',2 ,'MarkerSize',2,'MarkerFaceColor',color);
    
    hold off;  
    
    % Boilerplate
    
    xLabel = "\Delta_R";
    yLabel = "\Delta eGFR %";
    pbaspect([3 3 1]);
    xlim(xLim);
    ylim(yLim);
    title([titlePlot]);
    xlabel(xLabel,'FontSize',20);
    ylabel(yLabel,'FontSize',20) ;
        %if legendOn
           %legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
        %end
    % Set font size
    set(gca,'FontSize',9); 
end


function PlotTiledFigureG(xLim,yLim,titlePlot)
    ax2 = nexttile;
    hold on;
    % Plot boundaries on controlled and uncontrolled
    color = 'g';
    markerSize = 1;
    
    xPlot = [ -100,100];
    yPlot = [-5,-5];
    plot(xPlot,yPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    yPlot = [-10,-10];
    plot(xPlot,yPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);

    DataStructR = load('MasterOutput/DataStructR.mat');
    yNNTestArray = DataStructR.yNNTestArray;
    yDTestArray = DataStructR.yDTestArray;
    color = "k";
    xPlot = yNNTestArray;
    yPlot = yDTestArray;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',2 ,'MarkerSize',2,'MarkerFaceColor',color);
    %PlotScatter(yNNTestArray,yDTestArray,color);
    
    DataStructG = load('MasterOutput/DataStructG.mat');
    yNNTestArray = DataStructG.yRTestArray;
    yDTestArray = DataStructG.yDTestArray;
    color = "b";
    xPlot = yNNTestArray;
    yPlot = yDTestArray;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',2 ,'MarkerSize',4,'MarkerFaceColor',color);
    %PlotScatter(yNNTestArray,yDTestArray,color);
    
    hold off;  
    
    % Boilerplate
    
    xLabel = "\Delta_R";
    yLabel = "\Delta eGFR %";
    pbaspect([3 3 1]);
    xlim(xLim);
    ylim(yLim);
    title([titlePlot]);
    xlabel(xLabel,'FontSize',20);
    ylabel(yLabel,'FontSize',20) ;
        %if legendOn
           %legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
        %end
    % Set font size
    set(gca,'FontSize',9); 
end


function PlotTiledFigureGG(xLim,yLim,titlePlot)
    ax2 = nexttile;
    hold on;
    % Plot boundaries on controlled and uncontrolled
    color = 'g';
    markerSize = 1;
    
    xPlot = [ -100,100];
    yPlot = [-5,-5];
    plot(xPlot,yPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    yPlot = [-10,-10];
    plot(xPlot,yPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);

    DataStructR = load('MasterOutput/DataStructR.mat');
    yNNTestArray = DataStructR.yNNTestArray;
    color = "k";
    xPlot = yNNTestArray;
    yPlot = yNNTestArray;
    plot(xPlot,yPlot,'-', 'Color',color, 'LineWidth',2 ,'MarkerSize',2,'MarkerFaceColor',color);
    
    DataStructG = load('MasterOutput/DataStructG.mat');
    yNNTestArray = DataStructG.yRTestArray;
    yDTestArray = DataStructG.yNNTestArray;
    color = "b";
    xPlot = yNNTestArray;
    yPlot = yDTestArray;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',1 ,'MarkerSize',6);
    
    hold off;  
    
    % Boilerplate
    
    xLabel = "\Delta_R";
    yLabel = "\Delta eGFR %";
    pbaspect([3 3 1]);
    xlim(xLim);
    ylim(yLim);
    title([titlePlot]);
    xlabel(xLabel,'FontSize',20);
    ylabel(yLabel,'FontSize',20) ;
        %if legendOn
           %legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
        %end
    % Set font size
    set(gca,'FontSize',9); 
end



function PlotTiledFigureM(xLim,yLim,titlePlot)
    ax2 = nexttile;
    hold on;
    % Plot boundaries on controlled and uncontrolled
    color = 'g';
    markerSize = 1;
    xPlot = [ -100,100];
    yPlot = [-5,-5];
    plot(xPlot,yPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    yPlot = [-10,-10];
    plot(xPlot,yPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);

    DataStructR = load('MasterOutput/DataStructR.mat');
    yNNTestArray = DataStructR.yNNTestArray;
    yDTestArray = DataStructR.yDTestArray;
    color = "k";
    xPlot = yNNTestArray;
    yPlot = yDTestArray;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',2 ,'MarkerSize',2,'MarkerFaceColor',color);
    %PlotScatter(yNNTestArray,yDTestArray,color);
    
    DataStructM = load('MasterOutput/DataStructM.mat');
    yNNTestArray = DataStructM.yRTestArray;
    yDTestArray = DataStructM.yDTestArray;
    color = "r";
    xPlot = yNNTestArray;
    yPlot = yDTestArray;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',2 ,'MarkerSize',4,'MarkerFaceColor',color);
    %PlotScatter(yNNTestArray,yDTestArray,color);
    hold off;  
    
    % Boilerplate
    %titlePlot = GetTitlePlot(DataStruct);
    
    xLabel = "\Delta_R";
    yLabel = "\Delta eGFR %";
    pbaspect([3 3 1]);
    xlim(xLim);
    ylim(yLim);
    title([titlePlot]);
    xlabel(xLabel,'FontSize',20);
    ylabel(yLabel,'FontSize',20) ;
        %if legendOn
           %legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
        %end
    % Set font size
    set(gca,'FontSize',9); 
end


function PlotTiledFigureMM(xLim,yLim,titlePlot)
    ax2 = nexttile;
    hold on;
    % Plot boundaries on controlled and uncontrolled
    color = 'g';
    markerSize = 1;
    xPlot = [ -100,100];
    yPlot = [-5,-5];
    plot(xPlot,yPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    yPlot = [-10,-10];
    plot(xPlot,yPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);

    DataStructR = load('MasterOutput/DataStructR.mat');
    yNNTestArray = DataStructR.yNNTestArray;
    color = "k";
    xPlot = yNNTestArray;
    yPlot = yNNTestArray;
    plot(xPlot,yPlot,'-', 'Color',color, 'LineWidth',2 ,'MarkerSize',2,'MarkerFaceColor',color);
    
    DataStructM = load('MasterOutput/DataStructM.mat');
    yNNTestArray = DataStructM.yRTestArray;
    yDTestArray = DataStructM.yNNTestArray;
    color = "r";
    xPlot = yNNTestArray;
    yPlot = yDTestArray;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',1 ,'MarkerSize',6);

    hold off;  
    
    % Boilerplate
    %titlePlot = GetTitlePlot(DataStruct);
    
    xLabel = "\Delta_R";
    yLabel = "\Delta eGFR %";
    pbaspect([3 3 1]);
    xlim(xLim);
    ylim(yLim);
    title([titlePlot]);
    xlabel(xLabel,'FontSize',20);
    ylabel(yLabel,'FontSize',20) ;
        %if legendOn
           %legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
        %end
    % Set font size
    set(gca,'FontSize',9); 
end



function PlotTiledFigureS(xLim,yLim,titlePlot)
    ax2 = nexttile;
    hold on;
    % Plot boundaries on controlled and uncontrolled
    color = 'g';
    markerSize = 1;
    xPlot = [ -100,100];
    yPlot = [-5,-5];
    plot(xPlot,yPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    yPlot = [-10,-10];
    plot(xPlot,yPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);

    DataStructR = load('MasterOutput/DataStructR.mat');
    yNNTestArray = DataStructR.yNNTestArray;
    yDTestArray = DataStructR.yDTestArray;
    color = "k";
    xPlot = yNNTestArray;
    yPlot = yDTestArray;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',2 ,'MarkerSize',2,'MarkerFaceColor',color);
    %PlotScatter(yNNTestArray,yDTestArray,color);
    
    DataStructS = load('MasterOutput/DataStructS.mat');
    yNNTestArray = DataStructS.yRTestArray;
    yDTestArray = DataStructS.yDTestArray;
    color = "m";
    xPlot = yNNTestArray;
    yPlot = yDTestArray;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',2 ,'MarkerSize',4,'MarkerFaceColor',color);
    %PlotScatter(yNNTestArray,yDTestArray,color);
    hold off;  
    
    % Boilerplate
    xLabel = "\Delta_R";
    yLabel = "\Delta eGFR %";
    pbaspect([3 3 1]);
    xlim(xLim);
    ylim(yLim);
    title([titlePlot]);
    xlabel(xLabel,'FontSize',20);
    ylabel(yLabel,'FontSize',20) ;
        %if legendOn
           %legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
        %end
    % Set font size
    set(gca,'FontSize',9); 
end


function PlotTiledFigureSS(xLim,yLim,titlePlot)
    ax2 = nexttile;
    hold on;
    % Plot boundaries on controlled and uncontrolled
    color = 'g';
    markerSize = 1;
    xPlot = [ -100,100];
    yPlot = [-5,-5];
    plot(xPlot,yPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,'--', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    yPlot = [-10,-10];
    plot(xPlot,yPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    plot(yPlot,xPlot,':', 'Color',color, 'LineWidth',2 ,'MarkerSize',markerSize,'MarkerFaceColor',color);

    DataStructR = load('MasterOutput/DataStructR.mat');
    yNNTestArray = DataStructR.yNNTestArray;
    color = "k";
    xPlot = yNNTestArray;
    yPlot = yNNTestArray;
    plot(xPlot,yPlot,'-', 'Color',color, 'LineWidth',2 ,'MarkerSize',2,'MarkerFaceColor',color);
    
    DataStructS = load('MasterOutput/DataStructS.mat');
    yNNTestArray = DataStructS.yRTestArray;
    yDTestArray = DataStructS.yNNTestArray;
    color = "m";
    xPlot = yNNTestArray;
    yPlot = yDTestArray;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',1 ,'MarkerSize',6);

    hold off;  
    
    % Boilerplate
    xLabel = "\Delta_R";
    yLabel = "\Delta eGFR %";
    pbaspect([3 3 1]);
    xlim(xLim);
    ylim(yLim);
    title([titlePlot]);
    xlabel(xLabel,'FontSize',20);
    ylabel(yLabel,'FontSize',20) ;
        %if legendOn
           %legend(ax2,'Bal',  'Sat', 'G_{\alpha}',  'Sat', '\beta arr',  'Sat', 'OFF',  'Sat', 'Location','southoutside', 'NumColumns',4, 'Box', 'on');
        %end
    % Set font size
    set(gca,'FontSize',9); 
end




function titlePlot = GetTitlePlot(DataStruct)
    if(DataStruct.TName == "TR")
        titlePlot = "RASi Alone";
    elseif(DataStruct.TName == "TG")
        titlePlot = "RASi + GLP1";
    elseif(DataStruct.TName == "TM")
        titlePlot = "RASi + MCRa";
    elseif(DataStruct.TName == "TS")
        titlePlot = "RASi + SGLT2i";
    end
end

function PlotScatter(yNNTestArray,yDTestArray,color)
    
    L = length(yNNTestArray);
    
    markerSize = 2;
    xx = zeros(1,L) - 1000;
    yy = xx;
    for i=1:L
        if(yNNTestArray(i) >= -5)
            if(yDTestArray(i) >= -5)
               xx(i) = yNNTestArray(i);
               yy(i) = yDTestArray(i);
            end
        end
    end
    xPlot = xx;
    yPlot = yy;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',1 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    
    %markerSize = 4;
    xx = zeros(1,L) - 1000;
    yy = xx;
    for i=1:L
        if(yNNTestArray(i) <= -10)
            if(yDTestArray(i) <= -10)
               xx(i) = yNNTestArray(i);
               yy(i) = yDTestArray(i);
            end
        end
    end
    xPlot = xx;
    yPlot = yy;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',1 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    
    %markerSize = 2;
    xx = zeros(1,L) - 1000;
    yy = xx;
    for i=1:L
        if(yNNTestArray(i) >= -5)
            if(yDTestArray(i) <= -10)
               xx(i) = yNNTestArray(i);
               yy(i) = yDTestArray(i);
            end
        end
    end
    xPlot = xx;
    yPlot = yy;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',1 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    
    %markerSize = 2;
    xx = zeros(1,L) - 1000;
    yy = xx;
    for i=1:L
        if(yNNTestArray(i) <= -10)
            if(yDTestArray(i) >= -5)
               xx(i) = yNNTestArray(i);
               yy(i) = yDTestArray(i);
            end
        end
    end
    xPlot = xx;
    yPlot = yy;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',1 ,'MarkerSize',markerSize,'MarkerFaceColor',color);

    %markerSize = 2;
    %L = length(xPlot);
    xx = zeros(1,L) - 1000;
    yy = xx;
    for i=1:L
        if(yNNTestArray(i) < -5)
            if(yNNTestArray(i) > -10)
               xx(i) = yNNTestArray(i);
               yy(i) = yDTestArray(i);
            end
        end
    end
    xPlot = xx;
    yPlot = yy;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',1 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
    
    %markerSize = 2;
    %L = length(xPlot);
    xx = zeros(1,L) - 1000;
    yy = xx;
    for i=1:L
        if(yDTestArray(i) < -5)
            if(yDTestArray(i) > -10)
               xx(i) = yNNTestArray(i);
               yy(i) = yDTestArray(i);
            end
        end
    end
    xPlot = xx;
    yPlot = yy;
    plot(xPlot,yPlot,'d', 'Color',color, 'LineWidth',1 ,'MarkerSize',markerSize,'MarkerFaceColor',color);
end




    % Explanation
    function [titlePlot,legendOn,xLabel,yLabel,xLim,yLim,markerSize] = PlotParametersExp(ncompMax)
        % Set plot parameters
        titlePlot = '% Explanation of RASi Output';
        legendOn = true;
        xLabel = 'Number of PLS components';
        yLabel = 'Percent Variance Explained in y';
        xLim = [0,ncompMax]; % Plot limits on x axis
        yLim = [0,100]; % Plot limits on y axis
        markerSize = 4;
    end
    


    % RASi
    function [titlePlot,legendOn,xLabel,yLabel,xLim,yLim,markerSize] = PlotParametersR()
        xNamePlot = "EGFR_1";
        yNamePlot = "DEGFR_2";
        % Set plot parameters
        titlePlot = 'RASI Alone';
        legendOn = false;
        xLabel = 'EGFR';
        yLabel = '% \Delta';
        xLim = [20,100]; % Plot limits on x axis
        yLim = [-60,60]; % Plot limits on y axis
        markerSize = 4;
    end
    
    % GLP-1
    function [titlePlot,legendOn,xLabel,yLabel,xLim,yLim,markerSize] = PlotParametersG()
        xNamePlot = "EGFR_1";
        yNamePlot = "DEGFR_2";
        % Set plot parameters
        titlePlot = 'RASI + GLP-1';
        legendOn = false;
        xLabel = 'EGFR';
        yLabel = '% \Delta';
        xLim = [20,100]; % Plot limits on x axis
        yLim = [-60,60]; % Plot limits on y axis
        markerSize = 4;
    end
    
    % SGLT2i
    function [titlePlot,legendOn,xLabel,yLabel,xLim,yLim,markerSize] = PlotParametersS()
        xNamePlot = "EGFR_1";
        yNamePlot = "DEGFR_2";
        % Set plot parameters
        titlePlot = 'RASI + SGLT2i';
        legendOn = false;
        xLabel = 'EGFR';
        yLabel = '% \Delta';
        xLim = [20,100]; % Plot limits on x axis
        yLim = [-60,60]; % Plot limits on y axis
        markerSize = 4;
    end
    
    % MCRA
    function [titlePlot,legendOn,xLabel,yLabel,xLim,yLim,markerSize] = PlotParametersM()
        xNamePlot = "EGFR_1";
        yNamePlot = "DEGFR_2";
        % Set plot parameters
        titlePlot = 'RASI + MCRA';
        legendOn = false;
        xLabel = 'EGFR';
        yLabel = '% \Delta';
        xLim = [20,100]; % Plot limits on x axis
        yLim = [-60,60]; % Plot limits on y axis
        markerSize = 4;
    end
    


    
