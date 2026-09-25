function mezlogo_status
    for repo in $HOME/repos/mezlogo/*
        echo "Status for: $repo"
        cd $repo
        git status -s
        echo "Finished: $repo"
    end
end
