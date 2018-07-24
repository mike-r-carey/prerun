#!/usr/bin/env bats

@test "default prerun command is help" {
  run src/prerun.sh

  [ "${output:0:7}" = "Usage: " ]
  [ $status -eq 0 ]
}

@test "command passed calls prerun.\$cmd" {
  function prerun.MOCK() {
    echo "mock"
  }
  export -f prerun.MOCK

  run src/prerun.sh MOCK

  [ "$output" = "mock" ]
  [ $status -eq 0 ]
}

@test "dir is affected by PRERUN_DIRECTORY" {
  PRERUN_DIRECTORY=$BATS_TMPDIR run src/prerun.sh dir

  [ "$output" = "$BATS_TMPDIR" ]
  [ $status -eq 0 ]
}

@test "lists all avaliable files in PRERUN_DIRECTORY" {
  local tmp=$( mktemp -d )

  touch $tmp/foo
  touch $tmp/bar

  PRERUN_DIRECTORY=$tmp run src/prerun.sh list

  [ "${lines[0]}" = bar ]
  [ "${lines[1]}" = foo ]
  [ $status -eq 0 ]

  rm -rf $tmp
}

@test "loads scripts before run executable" {
  local tmp=$( mktemp -d )

  function prerun.cat() {
    echo "cat prerun"
  }
  declare -f prerun.cat | sed '1d' | sed '1d' | sed '$ d' > $tmp/cat

  PRERUN_DIRECTORY=$tmp run src/prerun.sh hook

  [ "${output:0:11}" = "alias cat='" ]
  [ $status -eq 0 ]

  {
    echo "# Unset PRERUN_DISABLE if set"
    echo '[ -z "$PRERUN_DISABLE" ] && unset PRERUN_DISABLE'
    echo ""
    echo "# -- Output --"
    echo "${output:11: -1} $BATS_TMPDIR/foo"
  } > $BATS_TMPDIR/cat
  chmod +x $BATS_TMPDIR/cat

  echo "cat" > $BATS_TMPDIR/foo
  PRERUN_DIRECTORY=$tmp run $BATS_TMPDIR/cat

  [ "${lines[0]}" = "cat prerun" ]
  [ "${lines[1]}" = "cat" ]
  [ $status -eq 0 ]

  rm -rf $tmp
}

# test_prerun
