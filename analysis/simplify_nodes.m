function circuit = simplify_nodes(circuit)
% second merging step combining together "connection nodes" into electrical
% nodes, implementing a union find structure to make it easy to merge nodes
% and also get the minimum set of nodes in the circuit all combined
% see https://www.cs.cmu.edu/~15122-archive/n18/lec/26-unionfind.pdf
%
% args: circuit (structure in get_circuit)
% returns: circuit (same structure, but with electrical nodes)

    n_nodes = size(circuit.nodes, 1);
    parent = 1:n_nodes; % array of "parent" nodes, each is its own parent to start

    n_elements = length(circuit.netlist);

    for i = 1:n_elements % for each element
        element = circuit.netlist(i);
        if strcmpi(element.type, 'wire') % if its a wire
            parent = union_nodes(parent, element.pinNodes(1), element.pinNodes(2)); % merge the nodes of each end
        end
    end
        
    root = zeros(n_nodes,1); % array of root nodes (the eldest parent) that each i node belongs to
    for i = 1:n_nodes
        root(i) = find_parent(parent, i); % root node is parent of combined
    end
    
    unique_roots = unique(root); % sorted roots with dups removed
    mapping = zeros(n_nodes,1); % mapping will be new electrical node indices
    for i = 1:length(unique_roots) % for each root
        mapping(root == unique_roots(i)) = i; % assign electrical node index to the ith node bc it matches
    end
    
    elecNodes = zeros(length(unique_roots), 2); % simplified list of electrical nodes
    for i = 1:length(unique_roots) % for each electrical node
        first_root = find(root == unique_roots(i), 1, 'first'); % if root belongs to this group of roots, take it as the representative for electrical
        elecNodes(i,:) = circuit.nodes(first_root,:); % bring circuit nodes (connections) into electrical nodes
    end
    
    circuit.nodes = elecNodes; % replace circuit nodes with electrical nodes
    for i = 1:length(circuit.netlist) % for each element
        circuit.netlist(i).pinNodes = mapping(circuit.netlist(i).pinNodes); % update pin nodes to be the electrical nodes
    end
    
    %% nested helpers
    function r = find_parent(parent, i)
        if parent(i) ~= i
            parent(i) = find_parent(parent, parent(i));
        end
        r = parent(i);
    end

    function parent = union_nodes(parent, i, j)
        ri = find_parent(parent, i);
        rj = find_parent(parent, j);
        if ri ~= rj
            parent(rj) = ri;
        end
    end
end