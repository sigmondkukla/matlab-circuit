classdef CurrentSource < Element
    methods
        function obj = CurrentSource(position, orientation, value)
            % If current value not specified, ask for it.
            if nargin < 3 || isempty(value)
                answer = inputdlg('Enter Current Value (A):', 'Current Source');
                if isempty(answer)
                    value = 0;
                else
                    value = str2double(answer{1});
                end
            end
            % Call the parent constructor and set type.
            obj@Element(position, orientation, value);
            obj.Type = 'current';
        end
        
        function draw(obj, ax)
            % Center of current source.
            x = obj.Position(1);
            y = obj.Position(2);
            r = 0.5;         % circle radius
            conn_len = 0.5;  % connection line length

            % Format the current value.
            value_format = formatCurrent(obj.Value);
            value_offset = 1;  % distance offset for the value label
            
            % Draw the circle.
            hCircle = rectangle(ax, 'Position', [x - r, y - r, 2*r, 2*r], ...
                'Curvature', [1, 1], 'EdgeColor', 'g', 'LineWidth', 2, 'HitTest', 'off');
            
            switch obj.Orientation
                case 'right'
                    % Left connection (pin1) and right connection (pin2).
                    x1_start = x - r - conn_len; x1_end = x - r;
                    x2_start = x + r;            x2_end = x + r + conn_len;
                    obj.PinPositions = [[x1_start, y]; [x2_end, y]];
                    hConn1 = line(ax, [x1_start, x1_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x2_start, x2_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    
                    % Draw arrow in the center (for right, arrow points left).
                    hArrow = text(ax, x, y, '←', 'FontSize', 16, 'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'middle', 'Color', 'g', 'HitTest', 'off');
                    
                    % Place the value label below the circle.
                    hValue = text(ax, x, y - value_offset, value_format, 'FontSize', 12, 'Color', 'k', ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off');
                    
                case 'left'
                    % Right connection (pin1) and left connection (pin2).
                    x1_start = x + r + conn_len; x1_end = x + r;
                    x2_start = x - r;            x2_end = x - r - conn_len;
                    obj.PinPositions = [[x1_start, y]; [x2_end, y]];
                    hConn1 = line(ax, [x1_start, x1_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x2_start, x2_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    
                    % For left, arrow points right.
                    hArrow = text(ax, x, y, '→', 'FontSize', 16, 'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'middle', 'Color', 'g', 'HitTest', 'off');
                    
                    % Place the value label below the circle.
                    hValue = text(ax, x, y - value_offset, value_format, 'FontSize', 12, 'Color', 'k', ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off');
                    
                case 'up'
                    % Bottom connection is pin1, top is pin2.
                    y1_start = y - r - conn_len; y1_end = y - r;
                    y2_start = y + r;            y2_end = y + r + conn_len;
                    obj.PinPositions = [[x, y1_start]; [x, y2_end]];
                    hConn1 = line(ax, [x, x], [y1_start, y1_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x, x], [y2_start, y2_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    
                    % For up, arrow points down.
                    hArrow = text(ax, x, y, '↓', 'FontSize', 16, 'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'middle', 'Color', 'g', 'HitTest', 'off');
                    
                    % Place the value label to the right of the circle.
                    hValue = text(ax, x + value_offset, y, value_format, 'FontSize', 12, 'Color', 'k', ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off');
                    
                case 'down'
                    % Top connection is pin1, bottom is pin2.
                    y1_start = y + r + conn_len; y1_end = y + r;
                    y2_start = y - r;            y2_end = y - r - conn_len;
                    obj.PinPositions = [[x, y1_start]; [x, y2_end]];
                    hConn1 = line(ax, [x, x], [y1_start, y1_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x, x], [y2_start, y2_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    
                    % For down, arrow points up.
                    hArrow = text(ax, x, y, '↑', 'FontSize', 16, 'HorizontalAlignment', 'center', ...
                        'VerticalAlignment', 'middle', 'Color', 'g', 'HitTest', 'off');
                    
                    % Place the value label to the right of the circle.
                    hValue = text(ax, x + value_offset, y, value_format, 'FontSize', 12, 'Color', 'k', ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off');
                    
                otherwise
                    error('Unknown orientation');
            end
            
            % Label pin numbers.
            hPin1 = text(ax, obj.PinPositions(1,1), obj.PinPositions(1,2)-0.3, '1', 'FontSize', 10, ...
                'HorizontalAlignment', 'center', 'HitTest', 'off');
            hPin2 = text(ax, obj.PinPositions(2,1), obj.PinPositions(2,2)-0.3, '2', 'FontSize', 10, ...
                'HorizontalAlignment', 'center', 'HitTest', 'off');
            
            % Store graphics handles.
            obj.Handles = [hCircle, hConn1, hConn2, hArrow, hPin1, hPin2, hValue];
            
            % choose between milliamps and amps format
            function str = formatCurrent(I)
                if abs(I) < 1
                    str = sprintf('%g mA', I*1e3);
                else
                    str = sprintf('%g A', I);
                end
            end
        end        
    end
end
