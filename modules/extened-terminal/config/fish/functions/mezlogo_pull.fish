function mezlogo_pull
    for repo in $HOME/repos/mezlogo/*
        echo "Pulling: $repo"
        cd $repo
        git pull
        echo "Finished: $repo"
    end
end
