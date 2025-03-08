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

    %% Tools buttons
    % cursor button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Cursor', ...
        'Units', 'normalized', 'Position', [0.1 0 0.1 1], 'Callback', @set_cursor_mode);

    % rotation button (TODO: don't call it toggle anymore as there are 4
    % rotations possible)
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Rotate', ...
        'Units', 'normalized', 'Position', [0.2 0 0.1 1], 'Callback', @toggle_rotation);
    
    %% Element buttons
    % voltage source button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Voltage Source', ...
        'Units', 'normalized', 'Position', [0.5 0 0.1 1], 'Callback', @set_voltage_mode);
    
    % resistor button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Resistor', ...
        'Units', 'normalized', 'Position', [0.6 0 0.1 1], 'Callback', @set_resistor_mode);
    
    % wire button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Wire', ...
        'Units', 'normalized', 'Position', [0.7 0 0.1 1], 'Callback', @set_wire_mode);

    % on mouse click on graph, neesd to handle all user intents
    function ax_click(~, ~)
        % get mouse position, snapped to grid
        pt = get(ax, 'CurrentPoint');
        x = pt(1,1); y = pt(1,2);
        [x, y] = snap_to_grid(x, y);
        
        % ensure that current mouse mode and element rotation are available
        if ~isfield(fig.UserData, 'mode')
            fig.UserData.mode = 'cursor';
        end
        if ~isfield(fig.UserData, 'rotation')
            fig.UserData.rotation = 'right';
        end
        mode = fig.UserData.mode;
        direction = fig.UserData.rotation;
        
        % if no elements have been created yet, the elements global wont
        % exist yet. thus create it before trying to add any elements
        if ~isfield(fig.UserData, 'elements')
            fig.UserData.elements = {};
        end
        
        switch mode
            case 'voltage'
                vs = VoltageSource([x y], direction); % Create a new VoltageSource object w/ current click pos and orientation
                vs.draw(ax); % draw voltage source
                fig.UserData.elements{end+1} = vs; % add to known elements
            case 'resistor'
                r = Resistor([x y], direction); % see voltage source above
                r.draw(ax);
                fig.UserData.elements{end+1} = r;
            case 'wire'
                % wires are special cases because they need state. it takes
                % two clicks to set the start and end point, but we don't
                % necessarily know if we're clicking the first or second
                % point
                if ~isfield(fig.UserData, 'wireStart') % if no wire positions have been entered
                    fig.UserData.wireStart = [x y]; % store the first wire endpoint (now we know it halfway exists)
                else % now the first wire position already exists, so this is the second
                    w = Wire(fig.UserData.wireStart, [x y]); % init wire with prev click and current click as endpoints
                    w.draw(ax); % draw duh
                    fig.UserData.elements{end+1} = w;
                    fig.UserData = rmfield(fig.UserData, 'wireStart'); % get rid of wire start for the next time
                    % TODO: could be issue with clicking out of wire editor
                    % when a wire has not fully been created. i.e. first
                    % point clicked but not second. fix by resetting this
                    % whenever tool switches to something other than wire.
                    % TODO: can we make the tool switching functions all
                    % into one function with an argument for the tool?
                end
            case 'cursor'
                return; % do nothing
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
