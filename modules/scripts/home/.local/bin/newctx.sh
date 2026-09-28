#!/usr/bin/env bash
#
# ctx.sh - build an LLM-friendly XML context from processes and files.
#
# Argument forms:
#   !command            Execute shell command -> <process> (name, exit, stdout, stderr)
#   ./path or /path     Literal file
#   *pattern*           fd -g <pattern>
#   pattern             fd <pattern>
#
# Examples:
#   ctx.sh '!date' '!uname -a' '*.py' './README.md' '/etc/hosts'
#   ctx.sh '!env | grep -i ssh' 'src/**/*.rs'

set -uo pipefail

CWD_DIR="$(pwd)"

# ---------------------------------------------------------------- helpers ---

xml_escape() {
    local s="$1"
    s="${s//&/&amp;}"
    s="${s//</&lt;}"
    s="${s//>/&gt;}"
    s="${s//\"/&quot;}"
    printf '%s' "$s"
}

is_binary() {
    local enc
    enc="$(file --mime-encoding -b -- "$1" 2>/dev/null || true)"
    [[ "$enc" == "binary" ]]
}

shebang_interpreter() {
    local first
    IFS= read -r first < "$1" || true
    [[ "$first" == '#!'* ]] || return 0
    first="${first#\#!}"
    first="${first#"${first%%[![:space:]]*}"}"
    first="${first%%[[:space:]]*}"
    if [[ "$(basename -- "$first")" == "env" ]]; then
        local line
        IFS= read -r line < "$1" || true
        line="${line#\#!}"
        # shellcheck disable=SC2206
        local parts=($line)
        local i=1
        while [[ $i -lt ${#parts[@]} ]]; do
            local p="${parts[$i]}"
            case "$p" in
                -S) i=$((i+1)); continue ;;
                -*) i=$((i+1)); continue ;;
                *)  basename -- "$p"; return ;;
            esac
        done
        return
    fi
    basename -- "$first"
}

detect_language() {
    local file="$1"
    local base ext mime shebang
    base="$(basename -- "$file")"

    case "$base" in
        Dockerfile|dockerfile|Containerfile) echo dockerfile; return ;;
        Makefile|makefile|GNUmakefile)       echo makefile;   return ;;
        CMakeLists.txt)                      echo cmake;      return ;;
        Rakefile|Gemfile|Vagrantfile)        echo ruby;       return ;;
    esac

    if [[ "$base" == *.* ]]; then
        ext="${base##*.}"
    else
        ext=""
    fi
    ext="${ext,,}"

    if [[ -z "$ext" ]]; then
        shebang="$(shebang_interpreter "$file" || true)"
        case "$shebang" in
            bash|sh|dash|ksh)       echo bash; return ;;
            zsh)                    echo zsh;  return ;;
            fish)                   echo fish; return ;;
            python|python2|python3) echo python; return ;;
            ruby)                   echo ruby; return ;;
            perl)                   echo perl; return ;;
            node|nodejs)            echo javascript; return ;;
            php)                    echo php;  return ;;
            lua)                    echo lua;  return ;;
            awk|gawk)               echo awk;  return ;;
            *) ;;
        esac
    fi

    case "$ext" in
        py|pyw|pyi)             echo python ;;
        js|mjs|cjs)             echo javascript ;;
        ts|mts|cts)             echo typescript ;;
        tsx)                    echo tsx ;;
        jsx)                    echo jsx ;;
        rb)                     echo ruby ;;
        go)                     echo go ;;
        rs)                     echo rust ;;
        java)                   echo java ;;
        kt|kts)                 echo kotlin ;;
        scala)                  echo scala ;;
        c)                      echo c ;;
        h)                      echo c ;;
        cc|cpp|cxx|hpp|hxx|hh)  echo cpp ;;
        cs)                     echo csharp ;;
        php)                    echo php ;;
        swift)                  echo swift ;;
        m|mm)                   echo objectivec ;;
        sh)                     echo bash ;;
        bash)                   echo bash ;;
        zsh)                    echo zsh ;;
        fish)                   echo fish ;;
        ps1|psm1)               echo powershell ;;
        bat|cmd)                echo bat ;;
        sql)                    echo sql ;;
        html|htm)               echo html ;;
        css)                    echo css ;;
        scss)                   echo scss ;;
        sass)                   echo sass ;;
        less)                   echo less ;;
        json)                   echo json ;;
        jsonc)                  echo jsonc ;;
        json5)                  echo json5 ;;
        yaml|yml)               echo yaml ;;
        toml)                   echo toml ;;
        ini|cfg|conf)           echo ini ;;
        env)                    echo dotenv ;;
        xml)                    echo xml ;;
        svg)                    echo xml ;;
        md|markdown)            echo markdown ;;
        rst)                    echo rst ;;
        adoc)                   echo asciidoc ;;
        tex)                    echo latex ;;
        lua)                    echo lua ;;
        pl|pm)                  echo perl ;;
        r)                      echo r ;;
        dart)                   echo dart ;;
        vue)                    echo vue ;;
        svelte)                 echo svelte ;;
        tf|tfvars|hcl)          echo hcl ;;
        proto)                  echo protobuf ;;
        graphql|gql)            echo graphql ;;
        log|txt)                echo text ;;
        csv)                    echo csv ;;
        tsv)                    echo tsv ;;
        diff|patch)             echo diff ;;
        *)
            mime="$(file --mime-type -b -- "$file" 2>/dev/null || true)"
            case "$mime" in
                */json)          echo json ;;
                */xml)           echo xml ;;
                */html)          echo html ;;
                */x-shellscript) echo bash ;;
                */x-python)      echo python ;;
                */x-ruby)        echo ruby ;;
                */x-perl)        echo perl ;;
                */javascript)    echo javascript ;;
                text/*|*)        echo text ;;
            esac
            ;;
    esac
}

detect_type() {
    local file="$1"
    local base ext shebang
    base="$(basename -- "$file")"

    case "$base" in
        Dockerfile|dockerfile|Containerfile|Makefile|makefile|GNUmakefile|CMakeLists.txt)
            echo source; return ;;
    esac

    if [[ "$base" == *.* ]]; then
        ext="${base##*.}"
    else
        ext=""
    fi
    ext="${ext,,}"

    if [[ -z "$ext" ]]; then
        shebang="$(shebang_interpreter "$file" || true)"
        if [[ -n "$shebang" ]]; then
            echo script; return
        fi
    fi

    case "$ext" in
        log|out|err)                                        echo log ;;
        json|yaml|yml|toml|ini|cfg|conf|env|properties)     echo config ;;
        csv|tsv|parquet|avro)                               echo data ;;
        md|rst|txt|adoc)                                    echo doc ;;
        sh|bash|zsh|fish|ps1|psm1|bat|cmd)                  echo script ;;
        py|pyw|pyi|js|mjs|cjs|ts|mts|cts|tsx|jsx|rb|go|rs|java|kt|kts|scala|c|h|cc|cpp|cxx|hpp|hxx|hh|cs|php|swift|sql|html|htm|css|scss|sass|less|lua|pl|pm|r|dart|vue|svelte|tf|tfvars|hcl|proto|graphql|gql|diff|patch)
                                                            echo source ;;
        *)                                                  echo other ;;
    esac
}

# Return a backtick fence long enough to safely wrap the given file's content.
make_fence() {
    local n
    n="$(awk '
        {
            run = 0
            for (i = 1; i <= length($0); i++) {
                if (substr($0, i, 1) == "`") {
                    run++
                    if (run > max) max = run
                } else {
                    run = 0
                }
            }
        }
        END {
            if (max < 3) print 3
            else         print max + 1
        }
    ' "$1")"
    printf '%*s' "$n" '' | tr ' ' '`'
}

# ---------------------------------------------------------- pattern resolve ---

# Emit matching files, one per line, based on the input form.
resolve_pattern() {
    local pattern="$1"
    if [[ "$pattern" == ./* || "$pattern" == /* ]]; then
        [[ -f "$pattern" ]] && printf '%s\n' "$pattern"
    elif [[ "$pattern" == *'*'* ]]; then
        fd -t f -g -- "$pattern"
    else
        fd -t f -- "$pattern"
    fi
}

# -------------------------------------------------------------- rendering ---

print_stream() {
    local tag="$1" file="$2"
    if [[ -s "$file" ]]; then
        local fence
        fence="$(make_fence "$file")"
        printf '    <%s>\n' "$tag"
        printf '%s\n' "$fence"
        cat -- "$file"
        if [[ "$(tail -c1 -- "$file" | wc -l | tr -d ' ')" == "0" ]]; then
            echo
        fi
        printf '%s\n' "$fence"
        printf '    </%s>\n' "$tag"
    else
        printf '    <%s/>\n' "$tag"
    fi
}

print_process() {
    local cmd="$1"
    local out err code=0
    out="$(mktemp)"
    err="$(mktemp)"

    bash -c "$cmd" >"$out" 2>"$err" || code=$?

    printf '  <process name="%s" exit="%d">\n' "$(xml_escape "$cmd")" "$code"
    print_stream stdout "$out"
    print_stream stderr "$err"
    printf '  </process>\n\n'

    rm -f "$out" "$err"
}

print_file_block() {
    local f="$1"
    local path lang ftype fence needs_newline
    path="$(xml_escape "$f")"
    lang="$(detect_language "$f")"
    ftype="$(detect_type "$f")"
    fence="$(make_fence "$f")"

    printf '  <file path="%s" language="%s" type="%s">\n' "$path" "$lang" "$ftype"
    printf '%s%s\n' "$fence" "$lang"

    needs_newline=0
    if [[ -s "$f" ]] && [[ "$(tail -c1 -- "$f" | wc -l | tr -d ' ')" == "0" ]]; then
        needs_newline=1
    fi
    cat -- "$f"
    [[ $needs_newline -eq 1 ]] && echo

    printf '%s\n' "$fence"
    printf '  </file>\n\n'
}

# ---------------------------------------------------------------- main ---

show_help() {
    cat <<'EOF'
Usage: ctx.sh <item>...

Each item is one of:
  !command         Execute as shell; emit <process name=... exit=...>
                   with <stdout> and <stderr> children (markdown fenced).
  ./path or /path  Specific file (relative or absolute).
  *pattern*        File glob -> `fd -g <pattern>`.
  pattern          File search -> `fd <pattern>`.

Files are collected into a <manifest> at the top (deduplicated, in first-seen
order). Process and file blocks then appear in the order the arguments were
given.

Examples:
  ctx.sh '!date' '!uname -a' '*.py' './README.md'
  ctx.sh '!env | grep -i ssh' 'src/**/*.rs' '/etc/hosts'
EOF
}

main() {
    cd "$CWD_DIR" || exit 1

    if [[ $# -eq 0 ]]; then
        show_help >&2
        return 2
    fi

    # --- Pass 1: collect manifest -------------------------------------------
    local -a manifest_files=()
    declare -A seen_manifest=()
    local arg f
    for arg in "$@"; do
        [[ "$arg" == '!'* ]] && continue
        while IFS= read -r f; do
            [[ -z "$f" || ! -f "$f" ]] && continue
            is_binary "$f" && continue
            if [[ -z "${seen_manifest[$f]:-}" ]]; then
                seen_manifest[$f]=1
                manifest_files+=("$f")
            fi
        done < <(resolve_pattern "$arg")
    done

    # --- Header -------------------------------------------------------------
    echo "<context>"
    if [[ ${#manifest_files[@]} -gt 0 ]]; then
        echo "  <manifest>"
        for f in "${manifest_files[@]}"; do
            printf '    <file path="%s" language="%s" type="%s"/>\n' \
                "$(xml_escape "$f")" \
                "$(detect_language "$f")" \
                "$(detect_type "$f")"
        done
        echo "  </manifest>"
        echo
    fi

    # --- Pass 2: emit blocks in argument order ------------------------------
    declare -A seen_emit=()
    for arg in "$@"; do
        if [[ "$arg" == '!'* ]]; then
            print_process "${arg:1}"
        else
            while IFS= read -r f; do
                [[ -z "$f" || ! -f "$f" ]] && continue
                is_binary "$f" && continue
                [[ -n "${seen_emit[$f]:-}" ]] && continue
                seen_emit[$f]=1
                print_file_block "$f"
            done < <(resolve_pattern "$arg")
        fi
    done

    echo "</context>"
}

main "$@"
