function main_gui()
    fig = figure('Position', [100 100 800 600]); % figure window must be larger

    fig.UserData.mode = 'cursor';
    fig.UserData.rotation = 'right';

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
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Clear',...
        'Units', 'normalized', 'Position', [0 0 0.1 1], 'Callback', @clear_points);

    % Normal cursor mode button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Cursor', ...
        'Units', 'normalized', 'Position', [0.1 0 0.1 1], 'Callback', @set_cursor_mode);

    % Toggle rotation button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Rotate', ...
        'Units', 'normalized', 'Position', [0.2 0 0.1 1], 'Callback', @toggle_rotation);
    
    % Voltage source mode button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Voltage Source', ...
        'Units', 'normalized', 'Position', [0.5 0 0.1 1], 'Callback', @set_voltage_mode);
    
    % Resistor mode button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Resistor', ...
        'Units', 'normalized', 'Position', [0.6 0 0.1 1], 'Callback', @set_resistor_mode);
    
    % Wire mode button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Wire', ...
        'Units', 'normalized', 'Position', [0.7 0 0.1 1], 'Callback', @set_wire_mode);

    % mouse click
    function ax_click(~, ~)
        % Get mouse position and snap to grid
        pt = get(ax, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2);
        [x, y] = snap_to_grid(x, y);
    
        % initialize global vars if not already
        if ~isfield(fig.UserData, 'mode')
            fig.UserData.mode = 'cursor';
        end
        if ~isfield(fig.UserData, 'rotation')
            fig.UserData.rotation = 'right';
        end
        % get a convenient copy of them
        mode = fig.UserData.mode;
        direction = fig.UserData.rotation;
    
        % Define connection line length
        conn_len = 0.5;
        compHandles = [];  % to store handles for later deletion
    
        switch mode
            case 'voltage'
                % Draw a voltage source as a circle with radius 0.5.
                r = 0.5;
                circleH = rectangle(ax, 'Position', [x-r, y-r, 2*r, 2*r], ...
                    'Curvature', [1,1], 'EdgeColor', 'r', 'LineWidth', 2, 'HitTest', 'off');
                compHandles = [compHandles, circleH];
                
                % Compute connection endpoints and text positions based on direction.
                switch direction
                    case 'right'
                        % For 'right': left connection is pin1 (positive), right is pin2 (negative)
                        x1_start = x - r - conn_len; x1_end = x - r;
                        x2_start = x + r;         x2_end = x + r + conn_len;
                        y1 = y; y2 = y;
                        pos_plus = [x1_start, y1];
                        pos_minus = [x2_end, y2];
                    case 'left'
                        % For 'left': right connection becomes pin1, left is pin2.
                        x1_start = x + r + conn_len; x1_end = x + r;
                        x2_start = x - r;            x2_end = x - r - conn_len;
                        y1 = y; y2 = y;
                        pos_plus = [x1_start, y1];
                        pos_minus = [x2_end, y2];
                    case 'up'
                        % For 'up': bottom connection is pin1, top is pin2.
                        y1_start = y - r - conn_len; y1_end = y - r;
                        y2_start = y + r;            y2_end = y + r + conn_len;
                        x1 = x; x2 = x;
                        pos_plus = [x1, y1_start];
                        pos_minus = [x2, y2_end];
                    case 'down'
                        % For 'down': top connection is pin1, bottom is pin2.
                        y1_start = y + r + conn_len; y1_end = y + r;
                        y2_start = y - r;            y2_end = y - r - conn_len;
                        x1 = x; x2 = x;
                        pos_plus = [x1, y1_start];
                        pos_minus = [x2, y2_end];
                end
    
                % Draw connection lines
                if strcmp(direction, 'right') || strcmp(direction, 'left')
                    conn1 = line(ax, [x1_start, x1_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    conn2 = line(ax, [x2_start, x2_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                else
                    conn1 = line(ax, [x, x], [y1_start, y1_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    conn2 = line(ax, [x, x], [y2_start, y2_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                end
                compHandles = [compHandles, conn1, conn2];
                
                % Add polarity markings (text for '+' and '-') and pin numbers.
                text_plus = text(ax, pos_plus(1), pos_plus(2), '+', 'FontSize', 12, ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off');
                text_minus = text(ax, pos_minus(1), pos_minus(2), '-', 'FontSize', 12, ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off');
                compHandles = [compHandles, text_plus, text_minus];
                % Pin numbers near the connection endpoints (offset slightly for clarity)
                pin1 = text(ax, pos_plus(1), pos_plus(2)-0.3, '1', 'FontSize', 10, ...
                    'HorizontalAlignment', 'center', 'HitTest', 'off');
                pin2 = text(ax, pos_minus(1), pos_minus(2)-0.3, '2', 'FontSize', 10, ...
                    'HorizontalAlignment', 'center', 'HitTest', 'off');
                compHandles = [compHandles, pin1, pin2];
                
            case 'resistor'
                % Draw a resistor as a rectangle.
                % For horizontal orientations ('right' or 'left')
                if strcmp(direction, 'right') || strcmp(direction, 'left')
                    w = 1; h = 0.5;
                    rectH = rectangle(ax, 'Position', [x - w/2, y - h/2, w, h], ...
                        'EdgeColor', 'b', 'LineWidth', 2, 'HitTest', 'off');
                    compHandles = [compHandles, rectH];
                    if strcmp(direction, 'right')
                        x1_start = x - w/2 - conn_len; x1_end = x - w/2;
                        x2_start = x + w/2;         x2_end = x + w/2 + conn_len;
                        pinPos1 = [x1_start, y];     pinPos2 = [x2_end, y];
                    else % 'left'
                        x1_start = x + w/2 + conn_len; x1_end = x + w/2;
                        x2_start = x - w/2;            x2_end = x - w/2 - conn_len;
                        pinPos1 = [x1_start, y];        pinPos2 = [x2_end, y];
                    end
                    conn1 = line(ax, [x1_start, x1_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    conn2 = line(ax, [x2_start, x2_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                else
                    % For vertical orientations ('up' or 'down')
                    w = 0.5; h = 1;
                    rectH = rectangle(ax, 'Position', [x - w/2, y - h/2, w, h], ...
                        'EdgeColor', 'b', 'LineWidth', 2, 'HitTest', 'off');
                    compHandles = [compHandles, rectH];
                    if strcmp(direction, 'up')
                        y1_start = y - h/2 - conn_len; y1_end = y - h/2;
                        y2_start = y + h/2;            y2_end = y + h/2 + conn_len;
                        pinPos1 = [x, y1_start];         pinPos2 = [x, y2_end];
                    else  % 'down'
                        y1_start = y + h/2 + conn_len; y1_end = y + h/2;
                        y2_start = y - h/2;            y2_end = y - h/2 - conn_len;
                        pinPos1 = [x, y1_start];         pinPos2 = [x, y2_end];
                    end
                    conn1 = line(ax, [x, x], [y1_start, y1_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    conn2 = line(ax, [x, x], [y2_start, y2_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                end
                compHandles = [compHandles, conn1, conn2];
                
                % Add pin number labels (for a resistor, order can follow connection order)
                pin1 = text(ax, pinPos1(1), pinPos1(2)-0.3, '1', 'FontSize', 10, ...
                    'HorizontalAlignment', 'center', 'HitTest', 'off');
                pin2 = text(ax, pinPos2(1), pinPos2(2)-0.3, '2', 'FontSize', 10, ...
                    'HorizontalAlignment', 'center', 'HitTest', 'off');
                compHandles = [compHandles, pin1, pin2];
                
            otherwise
                return;  % in 'cursor' mode, no component is placed
        end
    
        % Store all created handles for later deletion (e.g., via a clear button)
        fig.UserData.points = [fig.UserData.points, compHandles];
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

    function set_wire_mode(~, ~)
        fig.UserData.mode = 'wire';
    end

    % cycle thru rotation options when rotate clicked
    function toggle_rotation(~, ~)
        switch fig.UserData.rotation % move to next rotation based on current rotation
            case 'right'
                fig.UserData.rotation = 'down'; % down is clockwise of right
            case 'down'
                fig.UserData.rotation = 'left'; % etc
            case 'left'
                fig.UserData.rotation = 'up';
            case 'up'
                fig.UserData.rotation = 'right';
            otherwise % rotation was undefined, start with right
                fig.UserData.rotation = 'right';
        end
end

end
