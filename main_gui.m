function main_gui()
    clc;
    clear; %#ok because it only runs once
    close all;

    % subfolders
    addpath("analysis");
    addpath("classes");
    addpath("utils");

    fig = figure('Position', [100 100 800 600]); % figure window must be larger

    fig.UserData.mode = 'cursor';
    fig.UserData.rotation = 'right';

    % top panel for plot
    plotPanel = uipanel(fig, 'Units', 'normalized', 'Position', [0.05 0.25 0.6 0.7], 'Title', 'Schematic Capture');

    ax = axes('Parent', plotPanel); % axes for the plot
    hold(ax, 'on');
    axis(ax, [0 10 0 10]); % 10x10 unit grid square
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

    resultsPanel = uipanel(fig, 'Units','normalized', 'Position', [0.65 0.25 0.3 0.7], 'Title', 'Results');
    resultsText = uicontrol('Style','text','String','Enter a schematic and click Analyze','parent',resultsPanel, 'Units','normalized', 'Position', [0.05 0.05 0.9 0.9], 'FontSize', 14);

    controlPanel = uipanel(fig, 'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.2]);

    %% Tools buttons
    % clear button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Clear', ...
        'Units', 'normalized', 'Position', [0 0.5 0.1 0.5], 'Callback', @clear_elements);

    % cursor button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Cursor', ...
        'Units', 'normalized', 'Position', [0.1 0.5 0.1 0.5], 'Callback', {@set_mode,'cursor'});

    % rotate CW button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Rotate CW', ...
        'Units', 'normalized', 'Position', [0.2 0.5 0.1 0.5], 'Callback', {@change_rotation, 'cw'});

    % rotate CCW button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Rotate CCW', ...
        'Units', 'normalized', 'Position', [0.3 0.5 0.1 0.5], 'Callback', {@change_rotation, 'ccw'});
    
    %% Element buttons
    % current source button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Current Source', ...
        'Units', 'normalized', 'Position', [0 0 0.2 0.5], 'Callback', {@set_mode, 'current'});

    % voltage source button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Voltage Source', ...
        'Units', 'normalized', 'Position', [0.2 0 0.2 0.5], 'Callback', {@set_mode,'voltage'});
    
    % resistor button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Resistor', ...
        'Units', 'normalized', 'Position', [0.4 0 0.2 0.5], 'Callback', {@set_mode,'resistor'});
    
    % wire button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Wire', ...
        'Units', 'normalized', 'Position', [0.6 0 0.2 0.5], 'Callback', {@set_mode,'wire'});

    % ground button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Ground', ...
        'Units', 'normalized', 'Position', [0.8 0 0.2 0.5], 'Callback', {@set_mode,'ground'});

    % analyze button
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Analyze', ...
        'Units', 'normalized', 'Position', [0.9 0.5 0.1 0.5], 'Callback', @analyze);

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
                end

            case 'ground'
                gnd = Ground([x y]);
                gnd.draw(ax);
                fig.UserData.elements{end+1} = gnd;

            case 'current'
                cs = CurrentSource([x y], direction);
                cs.draw(ax);
                fig.UserData.elements{end+1} = cs;

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
    
    % changes what a click does
    function set_mode(~, ~, mode)
        fig.UserData.mode = mode;

        if ~strcmp(mode, 'wire') % if not wire, clear the wire start point b/c tool exited
            if isfield(fig.UserData, 'wireStart') % only delete if it exists
                fig.UserData = rmfield(fig.UserData, 'wireStart');
            end
        end
    end

    % edit the current rotation based on dir
    function change_rotation(~, ~, dir) % support 'cw' or 'ccw' rotation now
        rotations = {'right', 'down', 'left', 'up'}; % options
        index = find(strcmp(fig.UserData.rotation, rotations)); % figure out where in options we are rn

        switch dir % next rotation is cw, prev is ccw
            case 'cw'
                index = mod(index, 4) + 1; % wrapping increment
                % illustrate: index = 4 ("up")
                % then mod(index,4) = 0
                % and mod(index, 4)+1 = 1, ("right")
            case 'ccw'
                index = mod(index - 2, 4) + 1; % wrapping decrement
                % illustrate: index = 1 ("right")
                % then mod(index-2,4) = mod(-1,4) = 3
                % and mod(index-2,4)+1 = 4, ("up")
        end
        fig.UserData.rotation = rotations{index};
    end

    % delete everything off the schematic
    function clear_elements(~, ~)
        for i = 1 : length(fig.UserData.elements) % loop thru all elements
            fig.UserData.elements{i}.undraw(); % remove from plot
        end
        fig.UserData.elements = []; % drop elements from array

        clear_annotations(fig); % clear analysis result annotations
        set(resultsText,'String',"Enter a schematic and click Analyze") % clear results box
    end

    function analyze(~, ~)
        % don't do anything if there's nothing to analyze
        if ~isfield(fig.UserData, "elements") || isempty(fig.UserData.elements)
            error("No elements added to analyze")
        end

        circuit = get_circuit(fig.UserData.elements); % convert schematic to netlist
        debug_circuit(circuit); % debug netlist onto command window
        solution = solve_circuit(circuit); % nodal analysis
        debug_solution(solution); % debug results onto command window
        annotate_circuit(fig, ax, circuit, solution); % display results on graph
        display_results(resultsText, circuit, solution);
    end
end
