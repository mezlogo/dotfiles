function mkcd --description 'Create dir and cd' --argument-names target
    mkdir -p $target && cd $target
end
