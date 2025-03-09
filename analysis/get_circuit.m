function circuit = get_circuit(elements)
    % args: cell array of elements
    % returns: circuit, a structure with these variables
    %   - nodes: array nx2 of node positions (x,y)
    %   - netlist: structure with these variables
    %       - type: str element type
    %       - value: for resistor, voltage source
    %       - pinNodes: 1xn vector of node index for each pin to n

    % get all pin coordinates [x, y, elementIndex, pinIndex]
    allPins = get_all_pins(elements);

    % merge overlapping pins into nodes
    % returns an M×2 array of unique node coordinates and a vector mapping each row of allPins to a node index
    [uniqueNodes, nodeIndices] = merge_nodes(allPins);
    
    % determine element node indices and also store the element type and value
    netlist = get_netlist(elements, allPins, nodeIndices);

    circuit.nodes = uniqueNodes;
    circuit.netlist = netlist;

    circuit = simplify_nodes(circuit); % convert to electrical nodes
end