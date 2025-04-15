% just like annotate_circuit but for the results text box. see
% annotate_circuit for comments and details.
function display_results(uicontrol, circuit, solution)
    text = "";

    num_nodes = size(circuit.nodes,1);
    text = text + sprintf("Circuit has %d nodes\n", num_nodes);

    text = text + sprintf("\nNode voltages\n");

    for i = 1:num_nodes
        text = text + sprintf('V%d=%.2fV\n', i, solution.V(i));
    end

    text = text + sprintf("\nVoltage source currents\n");

    % annotate currents through voltage sources
    voltageSourceCounter = 0;  % current voltage source index
    for k = 1:length(circuit.netlist) % for all elements
        if strcmpi(circuit.netlist(k).type, 'voltage') % if it is a voltage source
            voltageSourceCounter = voltageSourceCounter + 1; % now we know which it is
           
            text = text + sprintf('I_V%d=%.2fA\n', voltageSourceCounter, solution.I_voltage(voltageSourceCounter));
        end
    end

    set(uicontrol,'String',text)
end
