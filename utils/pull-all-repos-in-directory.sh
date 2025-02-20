#!/bin/bash

GIT_CLEANUP=0
REPOSITORIES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DIR=$REPOSITORIES
QUIET_FLAG=""
QUIET_REDIRECT=""
UNCLEAN=()

usage()
{
  echo "Usage: pull-all-repos-in-directory [ -d parent_dir ] [ -c ] [ -q ]"
  echo "    -d: top level directory if not location of script"
  echo "       parent_dir default: $REPOSITORIES"
  echo "    -c: git garbage collect, merged branch cleanup, etc"
  echo "    -q: make git be quiet"
  exit 2
}

while getopts ":cqd:" opt; do
  case ${opt} in
    c )
      GIT_CLEANUP=1
      ;;
    q )
      QUIET=1
      QUIET_FLAG="--quiet"
      # never redirect stderr
      QUIET_REDIRECT="> /dev/null"
      ;;
    d )
      DIR=$OPTARG
      ;;
    \? )
      usage
      ;;
  esac
done

sync_directory() {
  IFS=$'\n'

  for REPO in `ls "$1/"`
  do
    if [ -d "$1/$REPO" ]
    then
      if [ -e "$1/$REPO/.git" ]
      then
        if [[ -z ${QUIET+x} ]]
        then
          echo "Updating $1/$REPO at `date`"
        else
          echo "$1/$REPO"
        fi
        cmd_flags=(-C "${1}/${REPO}")
        if ! git "${cmd_flags[@]}"  pull ${QUIET_FLAG}
        then
            UNCLEAN+=($REPO)
        fi
        if [ $GIT_CLEANUP = 1 ]
        then
          git ${cmd_flags[@]} gc ${QUIET_FLAG}
          git ${cmd_flags[@]} remote prune origin
          master_branch=$( git "${cmd_flags[@]}"  symbolic-ref --short refs/remotes/origin/HEAD|cut -f2 -d'/' )
          git -C "${1}/${REPO}" checkout -q ${master_branch}
          for branch in $( git "${cmd_flags[@]}"  for-each-ref refs/heads/ "--format=%(refname:short)")
          do
            mergeBase=$( git "${cmd_flags[@]}"  merge-base ${master_branch} $branch)
            rev=$( git "${cmd_flags[@]}" rev-parse "$branch^{tree}" )
            committree=$( git "${cmd_flags[@]}"  commit-tree ${rev} -p $mergeBase -m _ )
            if [[ $( git  "${cmd_flags[@]}" cherry ${master_branch} ${committree} ) == "-"* ]]
            then
              git -C "${1}/${REPO}" branch -D ${branch}
            fi
            $( git "${cmd_flags[@]}" checkout -q ${master_branch} )
          done
          if [[ -z ${QUIET+x} ]]
          then
            echo "Done at `date`"
          fi
        fi
      else
        sync_directory "$1/$REPO"
      fi
    fi
  done
}


if [[ ! -z ${QUIET+x} &&  ${GIT_CLEANUP} -eq 1 ]]
then
  echo "WARNING: with both '-q' and '-c' the slow garbage collection on edx-platform might appear to hang. It will be fine."
fi
sync_directory $DIR

if [[ ${#UNCLEAN[@]} -gt 0 ]]
then
  echo "The following directories weren't in clean state and couldn't be updated:"
  echo ${UNCLEAN[@]}
fi
