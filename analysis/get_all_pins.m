function allPins = get_all_pins(elements)
% returns [x, y, elementIndex, pinIndex]
    allPins = [];
    for i = 1:length(elements)
        pins = elements{i}.PinPositions; % Get the pin coordinates for this element
        % rows should be [x, y, element index, pin number]
        allPins = [allPins; pins(1,:) i 1; pins(2,:) i 2];
    end
end