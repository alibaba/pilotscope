cd spark-3.3.2
if [ ! -d ".git" ]; then # the first run, we init a git on spark original src code
    git config --global --add safe.directory $(pwd)
    git init
    git add . 
    git commit -m "init" -q
    echo "The first time run. git init successfully." 
else # every update, the patch is a diff between the first commit and the lastet pilotscope extension. So we reset the src to the original status and then apply the patch
    git reset --hard
    git clean -f -q
fi

git apply "../$1"