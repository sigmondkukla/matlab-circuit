classdef Resistor < Element
    methods
        function obj = Resistor(position, orientation, value)
            if nargin < 3 || isempty(value) % ask for resistance if not provided, see voltage source for details
                answer = inputdlg('Enter Resistance Value:', 'Resistor');
                if isempty(answer)
                    value = 0;
                else
                    value = str2double(answer{1});
                end
            end
            obj@Element(position, orientation, value);
            obj.Type = 'resistor';
        end
        
        function draw(obj, ax)
            x = obj.Position(1);
            y = obj.Position(2);
            conn_len = 0.5;
            
            if any(strcmp(obj.Orientation, {'right', 'left'})) % use same rectangle for right/left orientation
                w = 1; h = 0.5;
                hRect = rectangle(ax, 'Position', [x - w/2, y - h/2, w, h], ...
                    'EdgeColor', 'b', 'LineWidth', 2, 'HitTest', 'off');
                if strcmp(obj.Orientation, 'right') % right customizations
                    x1_start = x - w/2 - conn_len; x1_end = x - w/2;
                    x2_start = x + w/2;            x2_end = x + w/2 + conn_len;
                    obj.PinPositions = [[x1_start, y], [x2_end, y]];
                    hConn1 = line(ax, [x1_start, x1_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x2_start, x2_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                else % orientation 'left'
                    x1_start = x + w/2 + conn_len; x1_end = x + w/2;
                    x2_start = x - w/2;            x2_end = x - w/2 - conn_len;
                    obj.PinPositions = [[x1_start, y], [x2_end, y]];
                    hConn1 = line(ax, [x1_start, x1_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x2_start, x2_end], [y, y], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                end
            else % orientation must be vertical TODO what if orientation is not properly defined
                w = 0.5; h = 1; % for vertical orientations, swap the rectangle dimensions
                hRect = rectangle(ax, 'Position', [x - w/2, y - h/2, w, h], ...
                    'EdgeColor', 'b', 'LineWidth', 2, 'HitTest', 'off');
                if strcmp(obj.Orientation, 'up')
                    y1_start = y - h/2 - conn_len; y1_end = y - h/2;
                    y2_start = y + h/2;            y2_end = y + h/2 + conn_len;
                    obj.PinPositions = [[x, y1_start], [x, y2_end]];
                    hConn1 = line(ax, [x, x], [y1_start, y1_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x, x], [y2_start, y2_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                else % orientation 'down'
                    y1_start = y + h/2 + conn_len; y1_end = y + h/2;
                    y2_start = y - h/2;            y2_end = y - h/2 - conn_len;
                    obj.PinPositions = [[x, y1_start], [x, y2_end]];
                    hConn1 = line(ax, [x, x], [y1_start, y1_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                    hConn2 = line(ax, [x, x], [y2_start, y2_end], 'Color', 'k', 'LineWidth', 1, 'HitTest', 'off');
                end
            end
            
            % pin labels
            hPin1 = text(ax, obj.PinPositions(1,1), obj.PinPositions(1,2)-0.3, '1', 'FontSize', 10, 'HorizontalAlignment', 'center', 'HitTest', 'off');
            hPin2 = text(ax, obj.PinPositions(2,1), obj.PinPositions(2,2)-0.3, '2', 'FontSize', 10, 'HorizontalAlignment', 'center', 'HitTest', 'off');
            
            % save graphics handles
            obj.Handles = [hRect, hConn1, hConn2, hPin1, hPin2];
        end
    end
end
