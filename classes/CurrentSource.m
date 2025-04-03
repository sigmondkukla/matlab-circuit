classdef CurrentSource < Element
    methods
        function obj = CurrentSource(position, orientation, value)
            % If current value not specified, ask the user.
            if nargin < 3 || isempty(value)
                answer = inputdlg('Enter Current Value (A):', 'Current Source');
                if isempty(answer)
                    value = 0;
                else
                    value = str2double(answer{1});
                end
            end
            % Call parent constructor; store current value in "value".
            obj@Element(position, orientation, value);
            obj.Type = 'current';
        end
        
        function draw(obj, ax)
            % Draw a current source as a green circle with an arrow in the center.
            x = obj.Position(1);
            y = obj.Position(2);
            r = 0.5;         % circle radius
            conn_len = 0.5;  % connection line length
            
            % Draw the circle.
            hCircle = rectangle(ax, 'Position', [x - r, y - r, 2*r, 2*r], ...
                'Curvature', [1, 1], 'EdgeColor', 'g', 'LineWidth', 2, 'HitTest', 'off');
            
            % Depending on orientation, calculate connection endpoints and draw arrow.
            switch obj.Orientation
                case 'right'
                    % Left connection (pin1) and right connection (pin2).
                    x1_start = x - r - conn_len; x1_end = x - r;
                    x2_start = x + r;            x2_end = x + r + conn_len;
                    obj.PinPositions = [[x1_start, y]; [x2_end, y]];
                    hConn1 = line(ax, [x1_start, x1_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x2_start, x2_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hArrow = text(ax, x, y, '←', 'FontSize', 16, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'g', 'HitTest', 'off');
                case 'left'
                    % Right connection (pin1) and left connection (pin2).
                    x1_start = x + r + conn_len; x1_end = x + r;
                    x2_start = x - r;            x2_end = x - r - conn_len;
                    obj.PinPositions = [[x1_start, y]; [x2_end, y]];
                    hConn1 = line(ax, [x1_start, x1_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x2_start, x2_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hArrow = text(ax, x, y, '→', 'FontSize', 16, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'g', 'HitTest', 'off');
                case 'up'
                    % Bottom connection (pin1) and top connection (pin2).
                    y1_start = y - r - conn_len; y1_end = y - r;
                    y2_start = y + r;            y2_end = y + r + conn_len;
                    obj.PinPositions = [[x, y1_start]; [x, y2_end]];
                    hConn1 = line(ax, [x, x], [y1_start, y1_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x, x], [y2_start, y2_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hArrow = text(ax, x, y, '↓', 'FontSize', 16, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'g', 'HitTest', 'off');
                case 'down'
                    % Top connection (pin1) and bottom connection (pin2).
                    y1_start = y + r + conn_len; y1_end = y + r;
                    y2_start = y - r;            y2_end = y - r - conn_len;
                    obj.PinPositions = [[x, y1_start]; [x, y2_end]];
                    hConn1 = line(ax, [x, x], [y1_start, y1_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x, x], [y2_start, y2_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hArrow = text(ax, x, y, '↑', 'FontSize', 16, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'Color', 'g', 'HitTest', 'off');
                otherwise
                    error('Unknown orientation');
            end

            % label pin numbers
            hPin1 = text(ax, obj.PinPositions(1,1), obj.PinPositions(1,2)-0.3, '1', 'FontSize', 10, ...
                'HorizontalAlignment', 'center', 'HitTest', 'off');
            hPin2 = text(ax, obj.PinPositions(2,1), obj.PinPositions(2,2)-0.3, '2', 'FontSize', 10, ...
                'HorizontalAlignment', 'center', 'HitTest', 'off');
            
            % Store graphics handles.
            obj.Handles = [hCircle, hConn1, hConn2, hArrow, hPin1, hPin2];
        end
    end
end
