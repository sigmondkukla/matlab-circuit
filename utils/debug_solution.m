function debug_solution(solution)
    % solution has V (node voltages) and I_voltage (current thru voltage
    % sources)

    V = solution.V;
    I_voltage = solution.I_voltage;

    disp(V)
    disp(I_voltage)

    n_nodes = length(V);
    disp("Solution has " + n_nodes + " nodes");
    for i=1:n_nodes
        disp("Node " + i + " voltage " + V(i))
    end

    n_voltage_sources = length(I_voltage);
    disp("Solution has " + n_voltage_sources + " voltage sources");
    for i=1:n_voltage_sources
        disp("Voltage source " + i + " has current " + I_voltage(i))
    end
end