function mezlogo_push
    for repo in $HOME/repos/mezlogo/*
        echo "Pushing: $repo"
        cd $repo
        git add .
        git commit -m next
        git push
        echo "Finished: $repo"
    end
end
