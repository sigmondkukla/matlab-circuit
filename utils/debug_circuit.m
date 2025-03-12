function debug_circuit(circuit)
    % circuit has nodes and netlist

    % nodes is Nx2 where N is the number of uniqe nodes.
    % each row is then an [x,y] coordinate of the node

    n_nodes = size(circuit.nodes, 1);
    disp("Circuit has " + n_nodes + " nodes");
    for i=1:n_nodes
        disp("Node " + i + " at (" + circuit.nodes(i,1) + "," + circuit.nodes(i,2) + ")")
    end

    % netlist is a struct with type, value, and pinNodes
    % it contains each element, its value, and the node indices it is
    % connected to

    %disp(circuit.netlist);

    n_elements = size(circuit.netlist, 2);
    
    disp("Circuit has " + n_elements + " elements");

    for i=1:n_elements
        element = circuit.netlist(i);
        if strcmp(element.type, "wire") % value have isempty = 1 because it is a [] for a wire
            disp("Element " + i + " is a wire connecting nodes " + ...
            circuit.netlist(i).pinNodes(1) + " and " + circuit.netlist(i).pinNodes(2))
        else
            disp("Element " + i + " is a " + circuit.netlist(i).type + " with value " ...
                + circuit.netlist(i).value + " and connects to nodes " + circuit.netlist(i).pinNodes)
        end
    end
end