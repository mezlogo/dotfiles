
function mezlogo_pull
    for repo in $HOME/repos/mezlogo/*
        echo "Pulling: $repo"
        set -l old_pwd $PWD
        cd $repo; or continue
        git pull
        cd $old_pwd
        echo "Finished: $repo"
    end
end

    