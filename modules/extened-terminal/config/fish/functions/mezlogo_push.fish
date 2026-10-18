function mezlogo_push
    for repo in $HOME/repos/mezlogo/*
        echo "Pushing: $repo"
        cd $repo
        git add .
        if git diff --cached --quiet
            set -l ahead (git rev-list --count '@{u}..HEAD' 2>/dev/null)
            if test "$ahead" = "0"
                echo "Nothing to push: $repo"
                continue
            end
        else
            git commit -m next
        end
        git push
        echo "Finished: $repo"

    
    end
end
