function annotate_circuit(fig, ax, circuit, solution)
% write the nodes, node voltages, currents on the plot
% args:
%   ax: the plot axes
%   circuit: the struct from analyze process
%   solution: the struct from solve circuit process

    clear_annotations(fig);

    % annotate node numbers and node voltages
    for i = 1:size(circuit.nodes,1) % for each node
        % get coords
        x = circuit.nodes(i,1);
        y = circuit.nodes(i,2);
        
        label = sprintf('V%d=%.2fV', i, solution.V(i)); % assemble string like "V1: 2.34V"
        handle = text(ax, x, y, label, 'Color', 'magenta', 'FontSize', 10, ...
            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom'); % place label near node, maybe offset

        fig.UserData.annotations = [fig.UserData.annotations; handle];
    end

    % annotate currents through voltage sources
    voltageSourceCounter = 0;  % current voltage source index
    for k = 1:length(circuit.netlist) % for all elements
        if strcmpi(circuit.netlist(k).type, 'voltage') % if it is a voltage source
            voltageSourceCounter = voltageSourceCounter + 1; % now we know which it is
            voltageSource = circuit.netlist(k);
            
            % attached nodes
            n1 = voltageSource.pinNodes(1);
            n2 = voltageSource.pinNodes(2);
            
            % get positions of nodes
            pt1 = circuit.nodes(n1, :);
            pt2 = circuit.nodes(n2, :);
            
            mid = (pt1 + pt2) / 2; % current label midpoint between nodes (could be improved)
            
            % build string for label in the format "I_V1=2.34A"
            label = sprintf('I_V%d=%.2fA', voltageSourceCounter, solution.I_voltage(voltageSourceCounter));
            
            % add label
            handle = text(ax, mid(1), mid(2), label, 'Color', 'blue', 'FontSize', 10, ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

            fig.UserData.annotations = [fig.UserData.annotations; handle];
        end
    end
end
