function parseStimulus(stim)
% This function sorts out and displays stimulus data.

%-----------------------------Plotting Parameters--------------------------
staticGratingPlotHeight = 0.1;
dynamicGratingPlotHeight = 0.2;
baseLineMarkerHeight = 0.3;

menuBarSize = 50;               %how big the start bar is

legendSize = 0.1;
centre = [0.05 0.8];             %where to put the direction legend (in 
                                %normalised units)

screenSize = get(0, 'ScreenSize');

%--------------------------------------------------------------------------

% Display figure for stimulus timeline
endTime = stim.stimuli(end).endTime;
figure('NumberTitle', 'off', 'Name', 'Stimulus Timeline', ...
    'outerPosition', [1 screenSize(4)/2 screenSize(3) screenSize(4)/2])
hold on
axis([0 endTime*1.1 0 1])
xlabel('Time (s)');
    %Turn off y axis
set(gca, 'YTick', [])
set(gca, 'Ycolor', 'white')

% Print diagnostic info about the baseline on to figure
switch stim.triggering
    case 'off'
        % Draw the desired end of baseline in dotted black if there's no
        % triggering. This may not be actually when it was.
        line([stim.baseLineTime stim.baseLineTime], [0 baseLineMarkerHeight], 'color', 'black', 'LineStyle', ':')
        xLim = get(gca, 'XLim');
        yLim = get(gca, 'YLim');
        % Display the overshoot time, in ms, just above the plot
        overshoot = sprintf('%3.2f', ((stim.actualBaseLineTime - stim.baseLineTime)*1000));
        text(xLim(1) + (xLim(2)-xLim(1))*0.01, yLim(2) * 1.05,strcat('Baseline period overshoot:', overshoot,  'ms'), 'Clipping', 'off')
    case 'on'
        % If there is triggering, draw a solid black line at the end of
        % baseline
        line([stim.actualBaseLineTime stim.actualBaseLineTime], [0 baseLineMarkerHeight], 'color', 'black')
        xLim = get(gca, 'XLim');
        yLim = get(gca, 'YLim');
         % Display the actual baseline time, in ms, just above the plot
        aBLT = sprintf('%3.3f', stim.actualBaseLineTime);
        text(xLim(1) + (xLim(2)-xLim(1))*0.01, yLim(2) * 1.05, strcat('Baseline Time: ', aBLT,  's'), 'Clipping', 'off')
end

switch stim.experimentType
    
    case 'Flip'
        %Draw each state
        for i = 1:size(stim.stimuli, 2)
            rectangle('Position', [stim.stimuli(i).startTime 0 (stim.stimuli(i).endTime - stim.stimuli(i).startTime) dynamicGratingPlotHeight], 'FaceColor', stim.stimuli(i).state)
        end
        
        % plot chart of flip times. We're looking for this to be as
        % tight as possible
        figure('NumberTitle', 'off', 'Name', 'Flip times', 'outerPosition', [1 menuBarSize screenSize(3) / 2 (screenSize(4)/2 - menuBarSize)])
             %Turn off y axis
        set(gca, 'YTick', [])
        set(gca, 'Ycolor', 'white')
        times = zeros(size(stim.stimuli, 2), 1);
        for i=1:size(stim.stimuli, 2)
            times(i) = (stim.stimuli(i).endTime - stim.stimuli(i).startTime) *1000;
        end
        plot(times, 'black')
        xLim = get(gca, 'XLim');
        yLim = get(gca, 'YLim');
            %Display flip time range just above the plot
        flipRange = sprintf('%3.2f', (range(times)));
        text(xLim(1), yLim(2) + (yLim(2) - yLim(1))*0.05, strcat('Range:', flipRange,  'ms'), 'Clipping', 'off')
        ylabel('Flip time (ms)');
        xlabel('Direction cycle')
    case 'D'
        plotColors = hsv(stim.directionsNum);
        % Plot a rectangle with the color representing direction
        for i = 1:size(stim.stimuli, 2)
            rectangle('Position', [stim.stimuli(i).startTime 0 (stim.stimuli(i).endTime-stim.stimuli(i).startTime) dynamicGratingPlotHeight], 'FaceColor', plotColors((stim.stimuli(i).direction / 360 * stim.directionsNum)+1, :))
        end
        
        
        % plot a direction legend in the top left corner
        xLim=get(gca, 'XLim');
        yLim=get(gca, 'YLim');
        % convert normalised centre point to actual graph units
        centre(1) = centre(1) * (xLim(2)-xLim(1)) ;
        centre(2) = centre(2) * (yLim(2)-yLim(1)) ;
        graphAspectRatio = (xLim(2) - xLim(1)) / (yLim(2)-yLim(1));
        for i = 1:stim.directionsNum
            x = sin((i-1)/stim.directionsNum *2*pi )*legendSize*graphAspectRatio / 4;
            y = cos((i-1)/stim.directionsNum *2*pi )*legendSize;
            line([centre(1) centre(1)+x], [centre(2) centre(2)+y], 'color', plotColors(i, :), 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 8)
        end
        
     
        % plot drift times. We're looking for these to be as
        % tight as possible
        figure('NumberTitle', 'off', 'Name', 'Drift times in ms', 'outerPosition', [0 menuBarSize screenSize(3) / 2 (screenSize(4)/2 - menuBarSize)])
        times = zeros(stim.repeats * stim.directionsNum,1);
        for i=1:size(stim.stimuli, 2)
            times(i) = (stim.stimuli(i).endTime-stim.stimuli(i).startTime)*1000;
        end
        plot(times, 'black')
        xLim = get(gca, 'XLim');
        yLim = get(gca, 'YLim');
        driftRange = sprintf('%3.2f', (range(times)));
            %display drift time range above the graph
        text(xLim(1), yLim(2) + (yLim(2) - yLim(1))*0.05, strcat('Range:', driftRange,  'ms'), 'Clipping', 'off')
        ylabel('Drift time (ms)');
        xlabel('Direction cycle');
    case 'DH'
        plotColors = hsv(stim.directionsNum);
        % Plot a rectangle with the color representing direction
        for i = 1:size(stim.stimuli, 2)
            switch stim.stimuli(i).type
                case 'Drift'
                    rectangle('Position', [stim.stimuli(i).startTime 0 (stim.stimuli(i).endTime-stim.stimuli(i).startTime) dynamicGratingPlotHeight], 'FaceColor', plotColors((stim.stimuli(i).direction / 360 * stim.directionsNum)+1, :))
                otherwise
                    % a stationary grating 
                    rectangle('Position', [stim.stimuli(i).startTime 0 (stim.stimuli(i).endTime-stim.stimuli(i).startTime) staticGratingPlotHeight], 'FaceColor', plotColors((stim.stimuli(i).direction / 360 * stim.directionsNum)+1, :))
            end
        end
        
         % plot a direction legend in the top left corner
        xLim=get(gca, 'XLim');
        yLim=get(gca, 'YLim');
        % convert normalised centre point to actual graph units
        centre(1) = centre(1) * (xLim(2)-xLim(1)) ;
        centre(2) = centre(2) * (yLim(2)-yLim(1)) ;
        graphAspectRatio = (xLim(2) - xLim(1)) / (yLim(2)-yLim(1));
        for i = 1:stim.directionsNum
            x = sin((i-1)/stim.directionsNum *2*pi )*legendSize*graphAspectRatio / 4;
            y = cos((i-1)/stim.directionsNum *2*pi )*legendSize;
            line([centre(1) centre(1)+x], [centre(2) centre(2)+y], 'color', plotColors(i, :), 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 8)
        end
        
        % plot histograms of drift and postDrift times. We're 
        % looking for these to be as tight as possible
        driftTimes = zeros(stim.repeats * stim.directionsNum,1); 
        postDriftTimes = zeros(stim.repeats * stim.directionsNum,1);
        for i=1:2:(size(stim.stimuli, 2))
            driftTimes(ceil(i/2)) = (stim.stimuli(i).endTime - stim.stimuli(i).startTime)*1000;
            postDriftTimes(ceil(i/2)) = (stim.stimuli(i+1).endTime - stim.stimuli(i+1).startTime)*1000;
        end
       
        figure('NumberTitle', 'off', 'Name', 'Drift times in ms', 'outerPosition', [0 menuBarSize screenSize(3) / 2 (screenSize(4)/2 - menuBarSize)])
        plot(driftTimes, 'black')
        xLim = get(gca, 'XLim');
        yLim = get(gca, 'YLim');
        driftRange = sprintf('%3.2f', (range(driftTimes)));
        text(xLim(1), yLim(2) + (yLim(2) - yLim(1))*0.05, strcat('Range:', driftRange,  'ms'), 'Clipping', 'off')
        xlabel('Direction cycle');
        ylabel('Drift time (ms)');
        
        figure('NumberTitle', 'off', 'Name', 'postDrift Hold times in ms', 'outerPosition', [screenSize(3)/2 menuBarSize screenSize(3) / 2 (screenSize(4)/2 - menuBarSize)])
        plot(postDriftTimes, 'black')
        xLim = get(gca, 'XLim');
        yLim = get(gca, 'YLim');
        driftRange = sprintf('%3.2f', (range(postDriftTimes)));
        text(xLim(1), yLim(2) + (yLim(2) - yLim(1))*0.05, strcat('Range:', driftRange,  'ms'), 'Clipping', 'off')
        xlabel('Direction cycle');
        ylabel('Post drift hold time (ms)');
    case 'HD'
        plotColors = hsv(stim.directionsNum);
        % Plot a rectangle with the color representing direction plotColors = hsv(stim.directionsNum);
        % Plot a rectangle with the color representing direction
        for i = 1:size(stim.stimuli, 2)
            switch stim.stimuli(i).type
                case 'Drift'
                    rectangle('Position', [stim.stimuli(i).startTime 0 (stim.stimuli(i).endTime-stim.stimuli(i).startTime) dynamicGratingPlotHeight], 'FaceColor', plotColors((stim.stimuli(i).direction / 360 * stim.directionsNum)+1, :))
                otherwise
                    % a stationary grating 
                    rectangle('Position', [stim.stimuli(i).startTime 0 (stim.stimuli(i).endTime-stim.stimuli(i).startTime) staticGratingPlotHeight], 'FaceColor', plotColors((stim.stimuli(i).direction / 360 * stim.directionsNum)+1, :))
            end
        end
        
         % plot a direction legend in the top left corner
        xLim=get(gca, 'XLim');
        yLim=get(gca, 'YLim');
        % convert normalised centre point to actual graph units
        centre(1) = centre(1) * (xLim(2)-xLim(1)) ;
        centre(2) = centre(2) * (yLim(2)-yLim(1)) ;
        graphAspectRatio = (xLim(2) - xLim(1)) / (yLim(2)-yLim(1));
        for i = 1:stim.directionsNum
            x = sin((i-1)/stim.directionsNum *2*pi )*legendSize*graphAspectRatio / 4;
            y = cos((i-1)/stim.directionsNum *2*pi )*legendSize;
            line([centre(1) centre(1)+x], [centre(2) centre(2)+y], 'color', plotColors(i, :), 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 8)
        end
        
        % plot histograms of drift and postDrift times. We're 
        % looking for these to be as tight as possible
        preDriftTimes = zeros(stim.repeats * stim.directionsNum,1); 
        driftTimes = zeros(stim.repeats * stim.directionsNum,1);
        for i=1:2:(size(stim.stimuli, 2))
            preDriftTimes(ceil(i/2)) = (stim.stimuli(i).endTime - stim.stimuli(i).startTime)*1000;
            driftTimes(ceil(i/2)) = (stim.stimuli(i+1).endTime - stim.stimuli(i+1).startTime)*1000;
        end
       
        figure('NumberTitle', 'off', 'Name', 'Predrift hold times in ms', 'outerPosition', [0 menuBarSize screenSize(3) / 2 (screenSize(4)/2 - menuBarSize)])
        plot(preDriftTimes, 'black')
        xLim = get(gca, 'XLim');
        yLim = get(gca, 'YLim');
        driftRange = sprintf('%3.2f', (range(preDriftTimes)));
        text(xLim(1), yLim(2) + (yLim(2) - yLim(1))*0.05, strcat('Range:', driftRange,  'ms'), 'Clipping', 'off')
        xlabel('Direction cycle');
        ylabel('Predrift hold time (ms)');
        
        figure('NumberTitle', 'off', 'Name', 'Drift times in ms', 'outerPosition', [screenSize(3)/2 menuBarSize screenSize(3) / 2 (screenSize(4)/2 - menuBarSize)])
        plot(driftTimes, 'black')
        xLim = get(gca, 'XLim');
        yLim = get(gca, 'YLim');
        driftRange = sprintf('%3.2f', (range(driftTimes)));
        text(xLim(1), yLim(2) + (yLim(2) - yLim(1))*0.05, strcat('Range:', driftRange,  'ms'), 'Clipping', 'off')
        xlabel('Direction cycle');
        ylabel('Drift time (ms)');

    case 'HDH'
         plotColors = hsv(stim.directionsNum);
        % Plot a rectangle with the color representing direction
        for i = 1:size(stim.stimuli, 2)
            switch stim.stimuli(i).type
                case 'Drift'
                    rectangle('Position', [stim.stimuli(i).startTime 0 (stim.stimuli(i).endTime-stim.stimuli(i).startTime) dynamicGratingPlotHeight], 'FaceColor', plotColors((stim.stimuli(i).direction / 360 * stim.directionsNum)+1, :))
                otherwise
                    % a stationary grating 
                    rectangle('Position', [stim.stimuli(i).startTime 0 (stim.stimuli(i).endTime-stim.stimuli(i).startTime) staticGratingPlotHeight], 'FaceColor', plotColors((stim.stimuli(i).direction / 360 * stim.directionsNum)+1, :))
            end
        end
        
         % plot a direction legend in the top left corner
        xLim=get(gca, 'XLim');
        yLim=get(gca, 'YLim');
        % convert normalised centre point to actual graph units
        centre(1) = centre(1) * (xLim(2)-xLim(1)) ;
        centre(2) = centre(2) * (yLim(2)-yLim(1)) ;
        graphAspectRatio = (xLim(2) - xLim(1)) / (yLim(2)-yLim(1));
        for i = 1:stim.directionsNum
            x = sin((i-1)/stim.directionsNum *2*pi )*legendSize*graphAspectRatio / 4;
            y = cos((i-1)/stim.directionsNum *2*pi )*legendSize;
            line([centre(1) centre(1)+x], [centre(2) centre(2)+y], 'color', plotColors(i, :), 'LineWidth', 2, 'Marker', '.', 'MarkerSize', 8)
        end
        
        % plot histograms of drift and postDrift times. We're 
        % looking for these to be as tight as possible
        preDriftTimes = zeros(stim.repeats * stim.directionsNum,1); 
        driftTimes = zeros(stim.repeats * stim.directionsNum,1); 
        postDriftTimes = zeros(stim.repeats * stim.directionsNum,1);
        for i=1:3:(size(stim.stimuli, 2))
            preDriftTimes(ceil(i/3)) = (stim.stimuli(i).endTime - stim.stimuli(i).startTime)*1000;
            driftTimes(ceil(i/3)) = (stim.stimuli(i+1).endTime - stim.stimuli(i+1).startTime)*1000;
            postDriftTimes(ceil(i/3)) = (stim.stimuli(i+2).endTime - stim.stimuli(i+2).startTime)*1000;
        end
       
        figure('NumberTitle', 'off', 'Name', 'Drift times in ms', 'outerPosition', [0 menuBarSize screenSize(3) / 2 (screenSize(4)/2 - menuBarSize)])
        plot(driftTimes, 'black')
        xLim = get(gca, 'XLim');
        yLim = get(gca, 'YLim');
        driftRange = sprintf('%3.2f', (range(driftTimes)));
        text(xLim(1), yLim(2) + (yLim(2) - yLim(1))*0.05, strcat('Range:', driftRange,  'ms'), 'Clipping', 'off')
        xlabel('Direction cycle');
        ylabel('Drift time (ms)');
        
        figure('NumberTitle', 'off', 'Name', 'preDrift Hold times in ms', 'outerPosition', [screenSize(3)/2 menuBarSize screenSize(3) / 2 (screenSize(4)/2 - menuBarSize)])
        plot(preDriftTimes, 'black')
        xLim = get(gca, 'XLim');
        yLim = get(gca, 'YLim');
        driftRange = sprintf('%3.2f', (range(preDriftTimes)));
        text(xLim(1), yLim(2) + (yLim(2) - yLim(1))*0.05, strcat('Range:', driftRange,  'ms'), 'Clipping', 'off')
        xlabel('Direction cycle');
        ylabel('Pre drift hold time (ms)');
        
        figure('NumberTitle', 'off', 'Name', 'postDrift Hold times in ms', 'outerPosition', [screenSize(3)/2 menuBarSize screenSize(3) / 2 (screenSize(4)/2 - menuBarSize)])
        plot(postDriftTimes, 'black')
        xLim = get(gca, 'XLim');
        yLim = get(gca, 'YLim');
        driftRange = sprintf('%3.2f', (range(postDriftTimes)));
        text(xLim(1), yLim(2) + (yLim(2) - yLim(1))*0.05, strcat('Range:', driftRange,  'ms'), 'Clipping', 'off')
        xlabel('Direction cycle');
        ylabel('Post drift hold time (ms)');
end


