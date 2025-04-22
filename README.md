# MATLAB Static Circuit Simulator

Static circuit simulator built with MATLAB, supporting voltage and current sources as well as resistors.
Performs modified nodal analysis automatically based on an entered schematic diagram of a circuit.

## Installation

1. Extract the `matlab-circuit.zip` folder if it is not already.
2. Open `main_gui.m` and run it.

**Troubleshooting:** Ensure that the `analysis`, `classes`, and `utils` subdirectories are also added to the MATLAB path. This should, however, be handled automatically at the start of execution of `main_gui.m`.

## Usage

The single-window software contains three UI panels: the Schematic Capture panel in the upper left, the Results panel in the upper right, and the control panel at the bottom.

Tools and commands are located in the first row of the control panel, while circuit elements can be selected from the second row for placement in the schematic.

1. By default, the Cursor tool is active, meaning that crosshairs are visible, displaying where added components would be placed.
2. Also by default, components are oriented with terminal 1 on the left and terminal 2 on the right. This may be modified by clicking the Rotate CW and Rotate CCW buttons, which change the component placement orientation by 90 degrees in the clockwise or counter-clockwise direction, respectively.
3. To add a component to the schematic, first select it in the control panel, then move your mouse to the schematic capture panel.
4. Click on the schematic to place the component at the cursor's location.
5. A value entry dialog will appear. Enter a decimal number representing the value of the element, such as `0.123` for a 123 mA current source, or `4700` for a 4.7 kΩ resistor. Press Ok or the enter key to commit the entered value to the component.
6. Repeat this process for each component that you would like to add.
7. Select the wire tool to create nets between components. Wires are placed by clicking the start and end point of the wire on the schematic. Additional nodes (including component terminals and other wires) may be connected at endpoints of a wire, meaning that wires may cross each other without connecting if crossings do not occur at endpoints.
8. Adding a ground element to any node in the circuit will denote that node as zero volts. A ground element would often be placed at the negative terminal of a voltage source, for example.
9. The schematic may be cleared to start from scratch by clicking the Clear button in the control panel.
10. To analyze the circuit entered, click the Analyze button in the control panel. Results, including node voltages and voltage source currents will be annotated on the schematic, and a summary will be displayed in the Results panel.