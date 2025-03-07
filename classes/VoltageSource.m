classdef VoltageSource < Element
    methods
        function obj = VoltageSource(position, orientation, value)
            if nargin < 3 || isempty(value) % if voltage not specified
                answer = inputdlg('Enter Voltage Value:', 'Voltage Source'); % ask for it
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
            % center of source
            x = obj.Position(1); 
            y = obj.Position(2);
            r = 0.5; % circle radius
            conn_len = 0.5; % total size is 2x2 so a 1x1 circle needs 0.5 on either side
            
            % draw circle
            hCircle = rectangle(ax, 'Position', [x - r, y - r, 2*r, 2*r], ...
                'Curvature', [1, 1], 'EdgeColor', 'r', 'LineWidth', 2, 'HitTest', 'off');
            
            switch obj.Orientation % handle rotation
                case 'right'
                    % left connection (pin1, positive), right (pin2, negative)
                    x1_start = x - r - conn_len; x1_end = x - r;
                    x2_start = x + r;            x2_end = x + r + conn_len;
                    pos_plus = [x1_start, y];
                    pos_minus = [x2_end, y];
                    hConn1 = line(ax, [x1_start, x1_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x2_start, x2_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                case 'left'
                    % right connection becomes pin1, left is pin2.
                    x1_start = x + r + conn_len; x1_end = x + r;
                    x2_start = x - r;            x2_end = x - r - conn_len;
                    pos_plus = [x1_start, y];
                    pos_minus = [x2_end, y];
                    hConn1 = line(ax, [x1_start, x1_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x2_start, x2_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                case 'up'
                    % bottom connection is pin1, top is pin2.
                    y1_start = y - r - conn_len; y1_end = y - r;
                    y2_start = y + r;            y2_end = y + r + conn_len;
                    pos_plus = [x, y1_start];
                    pos_minus = [x, y2_end];
                    hConn1 = line(ax, [x, x], [y1_start, y1_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x, x], [y2_start, y2_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                case 'down'
                    % top connection is pin1, bottom is pin2.
                    y1_start = y + r + conn_len; y1_end = y + r;
                    y2_start = y - r;            y2_end = y - r - conn_len;
                    pos_plus = [x, y1_start];
                    pos_minus = [x, y2_end];
                    hConn1 = line(ax, [x, x], [y1_start, y1_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x, x], [y2_start, y2_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                otherwise
                    error('Unknown orientation'); % bruh
            end
            
            % label polarity
            hPlus = text(ax, pos_plus(1), pos_plus(2), '+', 'FontSize', 12, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off');
            hMinus = text(ax, pos_minus(1), pos_minus(2), '-', 'FontSize', 12, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'HitTest', 'off');
            
            % label pin numbers
            hPin1 = text(ax, pos_plus(1), pos_plus(2)-0.3, '1', 'FontSize', 10, ...
                'HorizontalAlignment', 'center', 'HitTest', 'off');
            hPin2 = text(ax, pos_minus(1), pos_minus(2)-0.3, '2', 'FontSize', 10, ...
                'HorizontalAlignment', 'center', 'HitTest', 'off');
            
            % store the graphics handles for later use
            obj.Handles = [hCircle, hConn1, hConn2, hPlus, hMinus, hPin1, hPin2];
        end
    end
end
