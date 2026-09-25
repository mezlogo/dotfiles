function srcenv --description 'Source envs from file into shell' --argument-names envfile
    for line in (cat "$envfile" | grep -v '^#')
        set -gx (string split = $line)
    end
end
