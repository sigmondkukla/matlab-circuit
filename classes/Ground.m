classdef Ground < Element
    methods
        function obj = Ground(position)
            % only requires position, because it will always point down,
            % and doesn't have a value like other elements
            if nargin < 1
                error('Ground needs position argument');
            end
            obj@Element(position, 'none', 0);
            obj.Type = 'ground';
        end
        
        function draw(obj, ax) % draw a ground symbol (three lines)            
            x = obj.Position(1);
            y = obj.Position(2);
            pinLength = 0.2; % length of the vertical line
            hLineWidthStep = 0.1; % width of bottom line, gets multiplied for rest
            hLineSpacing = 0.15; % vertical spacing between horizontal lines
            
            hLine = line(ax, [x, x], [y, y - pinLength], 'Color', 'k', 'LineWidth', 2, 'HitTest', 'off'); % draw vertical line
            
            % draw horizontal lines
            hGround1 = line(ax, [x - hLineWidthStep, x + hLineWidthStep], [y - pinLength - hLineSpacing * 2, y - pinLength - hLineSpacing * 2], 'Color', 'k', 'LineWidth', 2, 'HitTest', 'off');
            hGround2 = line(ax, [x - hLineWidthStep * 2, x + hLineWidthStep * 2], [y - pinLength - hLineSpacing, y - pinLength - hLineSpacing], 'Color', 'k', 'LineWidth', 2, 'HitTest', 'off');
            hGround3 = line(ax, [x - hLineWidthStep * 3, x + hLineWidthStep * 3], [y - pinLength, y - pinLength], 'Color', 'k', 'LineWidth', 2, 'HitTest', 'off');
            
            obj.Handles = [hLine, hGround1, hGround2, hGround3]; % store for clearing later
            
            obj.PinPositions = obj.Position; % only one pin position
            
            hLabel = text(ax, x, y-1, 'GND', 'Color', 'k', 'FontSize', 10, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'HitTest', 'off'); % GND text

            obj.Handles = [obj.Handles, hLabel]; % store for clearing later
        end
    end
end
