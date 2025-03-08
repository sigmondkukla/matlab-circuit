function netlist = get_netlist(elements, allPins, nodeIndices)
% finds the node indices from the merged pins and adds a netlist entry
% containing the element type, value, and connection nodes
%
% args:
%   - elements: (from schematic capture)
%   - allPins
%   - nodeIndices
% returns:
%   netlist structure

    netlist = struct('type', {}, 'value', {}, 'pinNodes', {});
    
    for i = 1:length(elements)
        % Find the rows in allPins that correspond to this element.
        rows = find(allPins(:,3) == i); % get rows in allPins for this element TODO: warning on 17
        connections = nodeIndices(rows)'; % get node indices for element pins.
        
        netlist(i).type = elements{i}.Type; % str
        netlist(i).value = elements{i}.Value; % value depends on type or may not exist
        netlist(i).pinNodes = connections; % node indices
    end
end