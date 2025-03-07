classdef Element < handle
    properties
        Position    % [x, y]
        Orientation % string enum 'right', 'down', 'left', or 'up'
        Value       % eg voltage, resistance
        Handles     % array of graphics handles
        Type        % string type of element
    end
    
    methods
        function obj = Element(position, orientation, value)
            if nargin < 3
                value = [];  % leave value empty if not given at beginning
            end
            obj.Position = position;
            obj.Orientation = orientation;
            obj.Value = value;
            obj.Handles = [];
        end
        
        % function draw(obj, ax) % dont need these arguments
        function draw(~, ~)
            error("Element draw must be overridden in children");
        end
    end
end
