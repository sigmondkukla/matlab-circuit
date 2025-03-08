function main_gui()
    clc;
    clear; %#ok because this only runs at the beginning
    close all;

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

    controlPanel = uipanel(fig, 'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.1]);

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

    function ax_click(~, ~)
        % Get mouse position and snap to grid.
        pt = get(ax, 'CurrentPoint');
        x = pt(1,1); y = pt(1,2);
        [x, y] = snap_to_grid(x, y);
        
        % Ensure mode and rotation exist.
        if ~isfield(fig.UserData, 'mode')
            fig.UserData.mode = 'cursor';
        end
        if ~isfield(fig.UserData, 'rotation')
            fig.UserData.rotation = 'right';
        end
        mode = fig.UserData.mode;
        direction = fig.UserData.rotation;
        
        % Initialize element storage if needed.
        if ~isfield(fig.UserData, 'elements')
            fig.UserData.elements = {};
        end
        
        switch mode
            case 'voltage'
                % Create a new VoltageSource and draw it.
                vs = VoltageSource([x y], direction);
                vs.draw(ax);
                fig.UserData.elements{end+1} = vs;
            case 'resistor'
                rElem = Resistor([x y], direction);
                rElem.draw(ax);
                fig.UserData.elements{end+1} = rElem;
            case 'wire'
                % For wires, use two clicks to define endpoints.
                if ~isfield(fig.UserData, 'wireStart')
                    fig.UserData.wireStart = [x y];
                else
                    w = Wire(fig.UserData.wireStart, [x y]);
                    w.draw(ax);
                    fig.UserData.elements{end+1} = w;
                    fig.UserData = rmfield(fig.UserData, 'wireStart'); % Reset for next wire.
                end
            case 'cursor'
                % In cursor mode, do nothing.
                return;
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
