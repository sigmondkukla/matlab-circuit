classdef VoltageSource < Element
    methods
        function obj = VoltageSource(position, orientation, value)
            if nargin < 3 || isempty(value) % if voltage not specified
                answer = inputdlg('Enter Voltage Value:', 'Voltage Source');
                if isempty(answer)
                    value = 0;
                else
                    value = str2double(answer{1});
                end
            end
            obj@Element(position, orientation, value); % call the parent
            obj.Type = 'voltage'; % string type hardcoded into class
        end
        
        function draw(obj, ax)
            % Center of voltage source
            x = obj.Position(1);
            y = obj.Position(2);
            r = 0.5;        % circle radius
            conn_len = 0.5; % connection line length

            value_offset = 1; % distance from center for value text
            value_format = sprintf('%g V', obj.Value);
            
            % Draw the circle.
            hCircle = rectangle(ax, 'Position', [x - r, y - r, 2*r, 2*r], ...
                'Curvature', [1, 1], 'EdgeColor', 'r', 'LineWidth', 2, 'HitTest', 'off');
            
            switch obj.Orientation % handle rotation
                case 'right'
                    % left connection (pin1, positive), right (pin2, negative)
                    x1_start = x - r - conn_len; x1_end = x - r;
                    x2_start = x + r;            x2_end = x + r + conn_len;
                    obj.PinPositions = [[x1_start, y]; [x2_end, y]];
                    hConn1 = line(ax, [x1_start, x1_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x2_start, x2_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    
                    % label polarity
                    hPlus = text(ax, x - (r/2), y, '+', 'FontSize', 16, ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off', ...
                        'FontWeight', 'bold', 'Color', 'r');
                    hMinus = text(ax, x + (r/2), y, '-', 'FontSize', 16, ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off', ...
                        'FontWeight', 'bold', 'Color', 'r');
                    
                    % value label
                    hValue = text(ax, x, y - value_offset, value_format, 'FontSize', 12, 'Color', 'k', ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off');
                    
                case 'left'
                    % right connection becomes pin1, left is pin2.
                    x1_start = x + r + conn_len; x1_end = x + r;
                    x2_start = x - r;            x2_end = x - r - conn_len;
                    obj.PinPositions = [[x1_start, y]; [x2_end, y]];
                    hConn1 = line(ax, [x1_start, x1_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x2_start, x2_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    
                    % label polarity
                    hPlus = text(ax, x + (r/2), y, '+', 'FontSize', 16, ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off', ...
                        'FontWeight', 'bold', 'Color', 'r');
                    hMinus = text(ax, x - (r/2), y, '-', 'FontSize', 16, ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off', ...
                        'FontWeight', 'bold', 'Color', 'r');

                    % value label
                    hValue = text(ax, x, y - value_offset, value_format, 'FontSize', 12, 'Color', 'k', ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off');
                    
                case 'up'
                    % bottom connection is pin1, top is pin2.
                    y1_start = y - r - conn_len; y1_end = y - r;
                    y2_start = y + r;            y2_end = y + r + conn_len;
                    obj.PinPositions = [[x, y1_start]; [x, y2_end]];
                    hConn1 = line(ax, [x, x], [y1_start, y1_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x, x], [y2_start, y2_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    
                    % label polarity
                    hPlus = text(ax, x, y - (r/2), '+', 'FontSize', 16, ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off', ...
                        'FontWeight', 'bold', 'Color', 'r');
                    hMinus = text(ax, x, y + (r/2), '-', 'FontSize', 16, ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off', ...
                        'FontWeight', 'bold', 'Color', 'r');
                    
                    % value label
                    hValue = text(ax, x + value_offset, y, value_format, 'FontSize', 12, 'Color', 'k', ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off');
                    
                case 'down'
                    % top connection is pin1, bottom is pin2.
                    y1_start = y + r + conn_len; y1_end = y + r;
                    y2_start = y - r;            y2_end = y - r - conn_len;
                    obj.PinPositions = [[x, y1_start]; [x, y2_end]];
                    hConn1 = line(ax, [x, x], [y1_start, y1_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x, x], [y2_start, y2_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    
                    % label polarity
                    hPlus = text(ax, x, y + (r/2), '+', 'FontSize', 16, ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off', ...
                        'FontWeight', 'bold', 'Color', 'r');
                    hMinus = text(ax, x, y - (r/2), '-', 'FontSize', 16, ...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off', ...
                        'FontWeight', 'bold', 'Color', 'r');

                    % value label
                    hValue = text(ax, x + value_offset, y, value_format, 'FontSize', 12, 'Color', 'k', ...
                    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off');

                otherwise
                    error('Unknown orientation');
            end
            
            % Pin number labels
            hPin1 = text(ax, obj.PinPositions(1,1), obj.PinPositions(1,2)-0.3, '1', 'FontSize', 10, ...
                'HorizontalAlignment', 'center', 'HitTest', 'off');
            hPin2 = text(ax, obj.PinPositions(2,1), obj.PinPositions(2,2)-0.3, '2', 'FontSize', 10, ...
                'HorizontalAlignment', 'center', 'HitTest', 'off');
            
            % Store graphics handles.
            obj.Handles = [hCircle, hConn1, hConn2, hPlus, hMinus, hPin1, hPin2, hValue];
        end
    end
end
