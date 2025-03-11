function clear_annotations(fig)
    if ~isfield(fig.UserData, 'annotations') % if annotations don't exist, make an array for it
        fig.UserData.annotations = [];
    else % if the field exists
        if ~isempty(fig.UserData.annotations)
            for i = 1:length(fig.UserData.annotations)
                delete(fig.UserData.annotations(i)); % delete annotation text
            end
            delete(fig.UserData.annotations);
            fig.UserData.annotations = []; % reset the array
        end
    end
end