function editpic --description 'preview, select and edit an image in satty using fzf'
    set IMAGE_NAME $(ls ~/Pictures/*.png -t | fzf --preview 'fzf-preview.sh {}' --preview-window='up,85%')
    if test -f "$IMAGE_NAME"
        satty --filename "$IMAGE_NAME" --output-filename $HOME/Pictures/edited_$(date +'%Y-%m-%d-%H-%M-%S.png')
    end
end
