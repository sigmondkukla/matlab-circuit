function [uniqueNodes, nodeIndices] = merge_nodes(allPins)
% args:
%   allPins: [x, y, elementIndex, pinIndex]
% returns:
%   - uniqueNodes: nx2 array of node coordinates [x y]
%   - nodeIndices: Vector mapping each row of allPins to a node index

    epsilon = 1e-6; % distance tolerance
    uniqueNodes = []; % list of unique node coords
    % nodeIndices = zeros(size(allPins,1),1);  % preallocate

    for i = 1:size(allPins,1) % for each pin
        p = allPins(i,1:2);  % get current pin position
        found = false;
        for j = 1:size(uniqueNodes,1) % for each unique node
            if norm(p - uniqueNodes(j,:)) < epsilon % check it it matches current pin
                nodeIndices(i) = j;
                found = true;
                break;
            end
        end
        if ~found % this is a new uniqe node
            uniqueNodes = [uniqueNodes; p];
            nodeIndices(i) = size(uniqueNodes,1);
        end
    end
end