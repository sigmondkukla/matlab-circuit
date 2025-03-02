function schematic_editor_gui()
    % Create a larger figure window for the schematic editor.
    fig = figure('Position', [100 100 800 600], 'Name', 'Schematic Editor', 'NumberTitle', 'off');

    % Create a panel dedicated to the plot area.
    plotPanel = uipanel(fig, 'Units', 'normalized', 'Position', [0.05 0.25 0.9 0.7]);
    ax = axes('Parent', plotPanel);
    hold(ax, 'on');
    axis(ax, [0 10 0 10]);

    % Initialize dynamic crosshair lines.
    xl = get(ax, 'XLim');
    yl = get(ax, 'YLim');
    v_crosshair = plot(ax, [0 0], yl, 'k-', 'HitTest', 'off');
    h_crosshair = plot(ax, xl, [0 0], 'k-', 'HitTest', 'off');

    % Set up shared data: current mode and preview handle.
    fig.UserData.ax = ax;
    fig.UserData.mode = 'cursor';  % default mode is simply the crosshair
    fig.UserData.preview = [];

    % Establish callbacks for mouse interactions.
    set(ax, 'ButtonDownFcn', @ax_click);
    set(fig, 'WindowButtonMotionFcn', @mouse_move);

    % Construct a control panel with component selection buttons.
    controlPanel = uipanel(fig, 'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.15]);
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Voltage Source', ...
              'Units', 'normalized', 'Position', [0.05 0.3 0.28 0.5], 'Callback', @voltage_callback);
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Resistor', ...
              'Units', 'normalized', 'Position', [0.37 0.3 0.28 0.5], 'Callback', @resistor_callback);
    uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Cursor', ...
              'Units', 'normalized', 'Position', [0.69 0.3 0.28 0.5], 'Callback', @cursor_callback);

    % Callback for selecting voltage source mode.
    function voltage_callback(~, ~)
        fig.UserData.mode = 'voltage';
        delete_preview();
    end

    % Callback for selecting resistor mode.
    function resistor_callback(~, ~)
        fig.UserData.mode = 'resistor';
        delete_preview();
    end

    % Callback for reverting to the normal crosshair cursor.
    function cursor_callback(~, ~)
        fig.UserData.mode = 'cursor';
        delete_preview();
    end

    % Utility function to remove any existing preview.
    function delete_preview()
        if isfield(fig.UserData, 'preview') && ~isempty(fig.UserData.preview) && isvalid(fig.UserData.preview)
            delete(fig.UserData.preview);
            fig.UserData.preview = [];
        end
    end

    % Mouse click callback: finalize the placement of a schematic component.
    function ax_click(~, ~)
        pt = get(ax, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2);
        xl = get(ax, 'XLim');
        yl = get(ax, 'YLim');
        if x < xl(1) || x > xl(2) || y < yl(1) || y > yl(2)
            return;
        end

        mode = fig.UserData.mode;
        switch mode
            case 'voltage'
                % Finalize a voltage source as a red circle.
                r = 0.5;
                rectangle('Parent', ax, 'Position', [x-r, y-r, 2*r, 2*r], 'Curvature', [1,1], ...
                          'EdgeColor', 'r', 'LineWidth', 2);
            case 'resistor'
                % Finalize a resistor as a blue rectangle.
                w = 1; h = 0.5;
                rectangle('Parent', ax, 'Position', [x - w/2, y - h/2, w, h], 'EdgeColor', 'b', 'LineWidth', 2);
            otherwise
                % In 'cursor' mode, no component is placed.
        end
    end

    % Mouse move callback: update crosshair and component preview.
    function mouse_move(~, ~)
        pt = get(ax, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2);
        xl = get(ax, 'XLim');
        yl = get(ax, 'YLim');
        if x < xl(1) || x > xl(2) || y < yl(1) || y > yl(2)
            set(v_crosshair, 'Visible', 'off');
            set(h_crosshair, 'Visible', 'off');
            delete_preview();
        else
            set(v_crosshair, 'XData', [x x], 'YData', yl, 'Visible', 'on');
            set(h_crosshair, 'XData', xl, 'YData', [y y], 'Visible', 'on');
            mode = fig.UserData.mode;
            if strcmp(mode, 'voltage')
                % Create/update voltage source preview: a dashed red circle.
                r = 0.5;
                if isempty(fig.UserData.preview) || ~isvalid(fig.UserData.preview)
                    fig.UserData.preview = rectangle('Parent', ax, 'Position', [x-r, y-r, 2*r, 2*r], ...
                                                     'Curvature', [1,1], 'EdgeColor', 'r', 'LineStyle', '--');
                else
                    set(fig.UserData.preview, 'Position', [x-r, y-r, 2*r, 2*r], 'Visible', 'on');
                end
            elseif strcmp(mode, 'resistor')
                % Create/update resistor preview: a dashed blue rectangle.
                w = 1; h = 0.5;
                if isempty(fig.UserData.preview) || ~isvalid(fig.UserData.preview)
                    fig.UserData.preview = rectangle('Parent', ax, 'Position', [x-w/2, y-h/2, w, h], ...
                                                     'EdgeColor', 'b', 'LineStyle', '--');
                else
                    set(fig.UserData.preview, 'Position', [x-w/2, y-h/2, w, h], 'Visible', 'on');
                end
            else
                % In cursor mode, ensure no preview is displayed.
                delete_preview();
            end
        end
    end
end
