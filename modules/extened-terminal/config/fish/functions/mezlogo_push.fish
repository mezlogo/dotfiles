
function mezlogo_push
    for repo in $HOME/repos/mezlogo/*
        echo "Pushing: $repo"
        set -l old_pwd $PWD
        cd $repo; or continue
        git add .
        if git diff --cached --quiet
            set -l ahead (git rev-list --count '@{u}..HEAD' 2>/dev/null)
            if test "$ahead" = "0"
                echo "Nothing to push: $repo"
            else
                git push
                echo "Finished: $repo"
            end
        else
            git commit -m next
            git push
            echo "Finished: $repo"
        end
        cd $old_pwd
    end
end

    