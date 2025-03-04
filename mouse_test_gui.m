function mouse_test_gui()
    fig = figure('Position', [100 100 800 600]); % figure window must be larger

    % top panel for plot
    plotPanel = uipanel(fig, 'Units', 'normalized', 'Position', [0.05 0.25 0.9 0.7]);

    ax = axes('Parent', plotPanel); % axes for the plot
    hold(ax, 'on');
    axis(ax, [0 10 0 10]);
    axis square;
    grid on;
    set(ax, 'XTick', 0:1:10);
    set(ax, 'YTick', 0:1:10);

    % crosshair lines from before
    xl = get(ax, 'XLim');
    yl = get(ax, 'YLim');
    v_crosshair = plot(ax, [0 0], yl, 'k-', 'HitTest', 'off');
    h_crosshair = plot(ax, xl, [0 0], 'k-', 'HitTest', 'off');

    % now it is more of a pain because we must store data in UserData for
    % the figure
    fig.UserData.ax = ax;
    fig.UserData.points = [];

    % callbacks for mouse click and move
    set(ax, 'ButtonDownFcn', @ax_click);
    set(fig, 'WindowButtonMotionFcn', @mouse_move);

    % control panel may in the future house buttons for each component etc
    controlPanel = uipanel(fig, 'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.15]);

    % in the meantime it will only be used for testing purposes
    % we can make a clear points button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Clear Points', 'Units', 'normalized', 'Position', [0.05 0.3 0.2 0.5], 'Callback', @clear_points);

    % and this slider for point size
    sliderHandle = uicontrol(controlPanel, 'Style', 'slider', 'Units', 'normalized', 'Position', [0.3 0.3 0.4 0.5],'Min', 1, 'Max', 100, 'Value', 10, 'Callback', @slider_callback);

    % label for the slider
    uicontrol(controlPanel, 'Style', 'text', 'String', 'Marker Size', 'Units', 'normalized', 'Position', [0.75 0.3 0.2 0.5]);

    % mouse click
    function ax_click(~, ~)
        % get mouse position
        pt = get(ax, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2);
        [x, y] = snap_to_grid(x, y);

        % check its within limits
        xl = get(ax, 'XLim');
        yl = get(ax, 'YLim');
        if x < xl(1) || x > xl(2) || y < yl(1) || y > yl(2)
            return;
        end

        markerSize = sliderHandle.Value; % make the slider useful

        p = plot(ax, x, y, 'r.', 'MarkerSize', markerSize, 'HitTest', 'off'); % plot the point
        fig.UserData.points = [fig.UserData.points, p]; % store for deletion later
    end

    % move crosshair
    function mouse_move(~, ~)
        pt = get(ax, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2);
        [x, y] = snap_to_grid(x, y);

        xl = get(ax, 'XLim');
        yl = get(ax, 'YLim');
        if x < xl(1) || x > xl(2) || y < yl(1) || y > yl(2)
            set(v_crosshair, 'Visible', 'off'); % hide crosshair if mouse not on plot
            set(h_crosshair, 'Visible', 'off');
        else
            set(v_crosshair, 'XData', [x x], 'YData', yl, 'Visible', 'on'); % show crosshair and move it
            set(h_crosshair, 'XData', xl, 'YData', [y y], 'Visible', 'on');
        end
    end

    % make the button useful
    function clear_points(~, ~)
        if isfield(fig.UserData, 'points') && ~isempty(fig.UserData.points)
            delete(fig.UserData.points);
            fig.UserData.points = [];
        end
    end
end
