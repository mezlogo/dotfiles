function mezlogo_status
    for repo in $HOME/repos/mezlogo/*
        set -l repo_name (basename $repo)
        cd $repo

        # 2. not a git repo
        if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "$repo_name: no git found"
            continue
        end

        # 3. staged or unstaged changes
        set -l changes (git status -s)
        if test -n "$changes"
            echo "$repo_name: need commit"
            printf '  %s\n' $changes
            continue
        end

        # 4. commits ahead of upstream (only if an upstream is configured)
        if git rev-parse --abbrev-ref @{u} >/dev/null 2>&1
            set -l ahead (git rev-list --count @{u}..HEAD)
            if test $ahead -gt 0
                echo "$repo_name: need push $ahead commits"
                continue
            end
        end

        # 5. clean and up to date
        echo -n "$repo_name: "
        set_color green
        echo "SYNCED"
        set_color normal
    end
end
