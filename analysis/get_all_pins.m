function allPins = get_all_pins(elements)
% returns [x, y, elementIndex, pinIndex]
    
    allPins = []; % Initialize empty matrix
    for i = 1:length(elements)
        pins = elements{i}.PinPositions; % Get the pin coordinates for this element
        % Skip element if PinPositions is empty.
        if isempty(pins)
            continue;
        end
        numPins = size(pins, 1); % Determine how many pins this element has
        for pinNum = 1:numPins
            % Append each pin: [x, y, element index, pin number]
            allPins = [allPins; pins(pinNum,:) i pinNum];
        end
    end
end