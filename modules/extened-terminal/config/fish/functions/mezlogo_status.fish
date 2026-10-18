
function mezlogo_status
    for repo in $HOME/repos/mezlogo/*
        set -l repo_name (basename $repo)
        set -l old_pwd $PWD
        cd $repo; or continue

        if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "$repo_name: no git found"
        else
            set -l changes (git status -s)
            if test -n "$changes"
                echo "$repo_name: need commit"
                printf '  %s\n' $changes
            else
                set -l ahead 0
                if git rev-parse --abbrev-ref @{u} >/dev/null 2>&1
                    set ahead (git rev-list --count @{u}..HEAD)
                end
                if test $ahead -gt 0
                    echo "$repo_name: need push $ahead commits"
                else
                    echo -n "$repo_name: "
                    set_color green
                    echo "SYNCED"
                    set_color normal
                end
            end
        end

        cd $old_pwd
    end
end

    