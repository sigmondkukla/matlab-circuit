classdef Wire < Element % wire is just a fancy element
    properties
        EndPoint % startpoint is handled via element position, only need endpoint
    end
    methods
        function obj = Wire(startPoint, endPoint) % constructor
            obj@Element(startPoint, 'wire', []); % orientation and value unused
            obj.EndPoint = endPoint; % save the endpoint
            obj.Type = 'wire'; % duh
        end
        
        function draw(obj, ax)
            % a wire is a line between endpoints
            hWire = line(ax, [obj.Position(1), obj.EndPoint(1)], [obj.Position(2), obj.EndPoint(2)], ...
                'Color', 'k', 'LineWidth', 2, 'HitTest', 'off');
            obj.Handles = hWire; % save the handle
        end
        
        function connected = isConnected(obj, other) % check if this is connected to another object
            epsilon = 1e-6; % to avoid floating point error
            pts1 = [obj.Position; obj.EndPoint]; % ends of this element
            pts2 = other.PinPositions; % pins of other element
            connected = any(vecnorm(pts1 - pts2(1,:), 2, 2) < epsilon) || any(vecnorm(pts1 - pts2(2,:), 2, 2) < epsilon);
        end
    end
end
