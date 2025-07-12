#!/bin/sh
#-*- sh -*-

# internal vars dont touch #
ARGS=( $@ )
NARG=0
PROG_NAME=$0
############################

# $1 offset
getarg() {
  echo ${ARGS[$NARG + $1]}
}

argv() {
  R=${ARGS[@]:$NARG}
  echo ${R[@]}
}

target_build() {
  make all
}

target_run() {
  target_build
  bin/printf2_$1 `argv`
}

target_test() {
  make test/$1.test.out && test/$1.test.out
  rm -f test/$1.test.out
}

hasargs=1

# Fetch all sparse args
while [ $hasargs -eq 1 ]
do
  case `getarg 0` in
    *)
      hasargs=0
    ;;
  esac
done

case `getarg 0` in
  package)
    make package
  ;;
  test)
    target_test `getarg 1`
  ;;
  build)
    target_build
  ;;
  run)
    target_run `getarg 1`
  ;;
  *)
    echo "You can do: run, build"
  ;;
esac
