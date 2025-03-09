function solution = solve_circuit(circuit)
% solve circuit with nodal analysis
% args: circuit struct with nodes and netlist, already simplified
% returns: solution struct with:
%   - V: array of node voltages, node 1 is ground. V(i) is node i voltage
%   - I_voltage : array of currents thru voltage sources
    
    %% Setup
    n_nodes = size(circuit.nodes, 1); % get number of electrical nodes

    voltage_indices = find(arrayfun(@(x) strcmpi(x.type, 'voltage'), circuit.netlist)); % get netlist indices where voltage sources are
    n_voltage_source = length(voltage_indices);
    
    % nodal analysis is just a system of equations with these unknowns:
    %   - node voltages at every node except ground
    %   - current thru each voltage source

    % unknowns = # non-GND nodes + # voltage sources
    n_unknowns = (n_nodes - 1) + n_voltage_source;
    
    % Ax=b
    A = zeros(n_unknowns, n_unknowns); % system matrix
    b = zeros(n_unknowns, 1); % right hand side vector
    
    % make KCL for every node except ground
    % resistors I=V/R so add 1/R into matrix
    % EIout = 0
    for k = 1:length(circuit.netlist) % for all elements
        if strcmpi(circuit.netlist(k).type, 'resistor') % if it is a resistor
            % get resistor info
            resistor = circuit.netlist(k);
            n1 = resistor.pinNodes(1);
            n2 = resistor.pinNodes(2);
            R = resistor.value;
            
            if n1 ~= 1 % if the first node is not ground
                idx1 = node_index(n1); % get offset index for matrix
                A(idx1, idx1) = A(idx1, idx1) + (1/R); % insert 1/R for future use
                if n2 ~= 1 % if node 2 is not gnd
                    idx2 = node_index(n2);
                    A(idx1, idx2) = A(idx1, idx2) - (1/R); % subtract 1-R bc its the negative side
                end
            end
            if n2 ~= 1 % if the second node is not gnd, do the same thing
                idx2 = node_index(n2);
                A(idx2, idx2) = A(idx2, idx2) + (1/R);
                if n1 ~= 1
                    idx1 = node_index(n1);
                    A(idx2, idx1) = A(idx2, idx1) - (1/R);
                end
            end
        end
    end
    
    % voltage sources tell us that V(n1)-V(n2)=V_source
    % Also the current thru the source is an unknown
    voltage_counter = 0;
    for k = 1:length(circuit.netlist) % for each element
        if strcmpi(circuit.netlist(k).type, 'voltage') % if it is a voltage source
            voltage_counter = voltage_counter + 1; % increment counter
            voltage_source = circuit.netlist(k);

            % get the source's nodes
            n1 = voltage_source.pinNodes(1);
            n2 = voltage_source.pinNodes(2);
            
            % voltage source equations come after node equations
            % there are n_nodes - 1 equations bc no ground node
            % so the row to insert it is the number of node equations plus
            % number of voltage equations we've already added
            row = (n_nodes - 1) + voltage_counter;
            
            % insert voltage source equation
            if n1 ~= 1 % if n1 not ground
                idx1 = node_index(n1);
                A(row, idx1) = 1; % add +1 voltage source coefficient
            end
            if n2 ~= 1 % if n2 is not ground
                idx2 = node_index(n2);
                A(row, idx2) = -1; % add -1 coefficient
            end
            b(row) = circuit.netlist(k).value; % set RHS vector to this voltage source
            
            % we also have to add the voltage source's current unknown
            % into the KCL at n1 and n2
            col = (n_nodes - 1) + voltage_counter; % and it is shifted over same as for row of node
            if n1 ~= 1 % if n1 isn't grounded
                idx1 = node_index(n1);
                A(idx1, col) = A(idx1, col) + 1; % add coeff for current exiting n1
            end
            if n2 ~= 1 % if n2 isn't grounded
                idx2 = node_index(n2);
                A(idx2, col) = A(idx2, col) - 1; % coeff for current entering n2
            end
        end
    end
    
    % matlab will solve a system of linear equations Ax=b for us using the
    % backlash operator (mldivide).
    % x is the vector of all unknowns, where
    %   - x(1:n-1) gives the node voltages for nodes 2:n and 1 is ground
    %   - x(n:end) gives the current through voltage sources
    x = A \ b;
    
    % put all node voltages back into a properly indexed array, where V(1)
    % is 0, and then V(2:n) is matrix nodes 1:n-1
    V = zeros(n_nodes,1);
    V(1) = 0; % technically not necessary if we preallocate above
    V(2:end) = x(1:(n_nodes-1)); % map the solved voltages in as describe above
    
    I_voltage = x(n_nodes:end); % get currents thru voltage sources
    
    % put into solution structure
    solution.V = V;
    solution.I_voltage = I_voltage;

    % return
    
    % maps electrical node number to index in matrix which doesn't have
    % ground. now it is just versus the first node, but potentially the
    % ground node could be a different one in which case this might need to
    % be more complicated
    function idx = node_index(node)
        if node == 1
            error("You shouldn't be using the reference node!");
        else
            idx = node - 1;
        end
    end
end
