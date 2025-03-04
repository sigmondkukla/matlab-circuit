function mouse_test_gui()
    fig = figure('Position', [100 100 800 600]); % figure window must be larger

    fig.UserData.mode = 'cursor';
    fig.UserData.rotation = 'horizontal';

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
    controlPanel = uipanel(fig, 'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.1]);

    % in the meantime it will only be used for testing purposes
    % we can make a clear points button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Clear Points',...
        'Units', 'normalized', 'Position', [0 0 0.2 1], 'Callback', @clear_points);

    % Normal cursor mode button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Cursor', ...
        'Units', 'normalized', 'Position', [0.2 0 0.2 1], 'Callback', @set_cursor_mode);
    
    % Voltage source mode button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Voltage Source', ...
        'Units', 'normalized', 'Position', [0.4 0 0.2 1], 'Callback', @set_voltage_mode);
    
    % Resistor mode button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Resistor', ...
        'Units', 'normalized', 'Position', [0.6 0 0.2 1], 'Callback', @set_resistor_mode);

    % Toggle rotation button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Rotate', ...
        'Units', 'normalized', 'Position', [0.8 0 0.2 1], 'Callback', @toggle_rotation);

    % mouse click
    function ax_click(~, ~)
        % Get mouse position and snap to grid
        pt = get(ax, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2);
        [x, y] = snap_to_grid(x, y);
    
        % Ensure mode and rotation exist
        if ~isfield(fig.UserData, 'mode')
            fig.UserData.mode = 'cursor';
        end
        if ~isfield(fig.UserData, 'rotation')
            fig.UserData.rotation = 'horizontal';
        end
    
        mode = fig.UserData.mode;
        rotation = fig.UserData.rotation;
    
        % Define connection line length
        line_length = 0.5;
    
        % Create component based on mode and rotation
        p = [];
        line1 = [];
        line2 = [];
    
        switch mode
            case 'voltage'
                % Circle (voltage source)
                r = 0.5;
                p = rectangle(ax, 'Position', [x - r, y - r, 2*r, 2*r], ...
                    'Curvature', [1, 1], 'EdgeColor', 'r', 'LineWidth', 2, 'HitTest', 'off');
    
                if strcmp(rotation, 'horizontal')
                    line1 = line(ax, [x - r - line_length, x - r], [y, y], 'Color', 'k', 'LineWidth', 2, 'HitTest', 'off');
                    line2 = line(ax, [x + r, x + r + line_length], [y, y], 'Color', 'k', 'LineWidth', 2, 'HitTest', 'off');
                else
                    line1 = line(ax, [x, x], [y - r - line_length, y - r], 'Color', 'k', 'LineWidth', 2, 'HitTest', 'off');
                    line2 = line(ax, [x, x], [y + r, y + r + line_length], 'Color', 'k', 'LineWidth', 2, 'HitTest', 'off');
                end
    
            case 'resistor'
                % Rectangle (resistor)
                w = 1; h = 0.5;
    
                if strcmp(rotation, 'horizontal')
                    p = rectangle(ax, 'Position', [x - w/2, y - h/2, w, h], ...
                        'EdgeColor', 'b', 'LineWidth', 2, 'HitTest', 'off');
                    line1 = line(ax, [x - w/2 - line_length, x - w/2], [y, y], 'Color', 'k', 'LineWidth', 2, 'HitTest', 'off');
                    line2 = line(ax, [x + w/2, x + w/2 + line_length], [y, y], 'Color', 'k', 'LineWidth', 2, 'HitTest', 'off');
                else
                    p = rectangle(ax, 'Position', [x - h/2, y - w/2, h, w], ...
                        'EdgeColor', 'b', 'LineWidth', 2, 'HitTest', 'off');
                    line1 = line(ax, [x, x], [y - w/2 - line_length, y - w/2], 'Color', 'k', 'LineWidth', 2, 'HitTest', 'off');
                    line2 = line(ax, [x, x], [y + w/2, y + w/2 + line_length], 'Color', 'k', 'LineWidth', 2, 'HitTest', 'off');
                end
    
            otherwise
                return;
        end
    
        % Store created components if any
        if ~isempty(p)
            fig.UserData.points = [fig.UserData.points, p, line1, line2];
        end
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

    function set_cursor_mode(~, ~)
        fig.UserData.mode = 'cursor';
    end
    
    function set_voltage_mode(~, ~)
        fig.UserData.mode = 'voltage';
    end
    
    function set_resistor_mode(~, ~)
        fig.UserData.mode = 'resistor';
    end

    function toggle_rotation(~, ~)
        if strcmp(fig.UserData.rotation, 'horizontal')
            fig.UserData.rotation = 'vertical';
        else
            fig.UserData.rotation = 'horizontal';
        end
    end

end
