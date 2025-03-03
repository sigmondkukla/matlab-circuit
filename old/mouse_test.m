function mouse_test() % need an all encompassing function so other functions can access variables
    fig = figure;
    ax = axes(fig);
    hold(ax, 'on');
    axis([0 10 0 10]);

    xl = get(ax, 'XLim'); % xl[xmin,xmax]
    yl = get(ax, 'YLim'); % yl[ymin,ymax]
    v_crosshair = plot(ax, [0 0], yl, 'k-', 'HitTest', 'off'); % HitTest off so we don't click it
    h_crosshair = plot(ax, xl, [0 0], 'k-', 'HitTest', 'off');
    
    set(ax, 'ButtonDownFcn', @ax_click); % create mouse click callback
    set(fig, 'WindowButtonMotionFcn', @mouse_move); % mouse move callback (for crosshair)
    
    % mouse click callback
    function ax_click(~, ~)
        pt = get(ax, 'CurrentPoint');
        % CurrentPoint returns the viewing line through a 2D or 3D scene
        % where the first row is one end of the segment and second is
        % another, so for 2D we only need one of them (so the row index is
        % 1)
        x = pt(1,1);
        y = pt(1,2);
        
        % get limits
        xl = get(ax, 'XLim');
        yl = get(ax, 'YLim');
        % ensure within limits else skip it
        if x < xl(1) || x > xl(2) || y < yl(1) || y > yl(2)
            return;
        end
        
        plot(ax, x, y, 'r.', 'MarkerSize', 10, 'HitTest', 'off'); % plot pt
    end

    % mouse move callback
    function mouse_move(~, ~)
        % same as click
        pt = get(ax, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2);
        
        xl = get(ax, 'XLim');
        yl = get(ax, 'YLim');
        if x < xl(1) || x > xl(2) || y < yl(1) || y > yl(2)
            % hide crosshair if out of limits
            set(v_crosshair, 'Visible', 'off');
            set(h_crosshair, 'Visible', 'off');
        else
            % show cursor and move to mouse point
            set(v_crosshair, 'XData', [x x], 'YData', yl, 'Visible', 'on');
            set(h_crosshair, 'XData', xl, 'YData', [y y], 'Visible', 'on');
        end
    end
end
