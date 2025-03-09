classdef Wire < Element % wire is just a fancy element
    methods
        function obj = Wire(startPoint, endPoint) % constructor
            obj@Element(startPoint, 'wire', []); % orientation and value unused
            obj.PinPositions = [startPoint; endPoint];
            obj.Type = 'wire'; % duh
        end
        
        function draw(obj, ax)
            % a wire is a line between endpoints
            hWire = line(ax, [obj.PinPositions(1,1), obj.PinPositions(2,1)], ...
                           [obj.PinPositions(1,2), obj.PinPositions(2,2)], ...
                           'Color', 'k', 'LineWidth', 2, 'HitTest', 'off');
            obj.Handles = hWire; % save the handle
        end
        
        % function connected = isConnected(obj, other) % check if this is connected to another object
        %     epsilon = 1e-6; % to avoid floating point error
        %     pts1 = obj.PinPositions; % ends of this element
        %     pts2 = other.PinPositions; % pins of other element
        %     connected = any(vecnorm(pts1 - pts2(1,:), 2, 2) < epsilon) || ...
        %                 any(vecnorm(pts1 - pts2(2,:), 2, 2) < epsilon);
        % end
    end
end
