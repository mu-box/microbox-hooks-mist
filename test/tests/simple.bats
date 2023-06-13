# source docker helpers
. util/docker.sh

@test "Start Container" {
  start_container "test-single" "192.168.0.2"
}

@test "Configure" {
  # Run Hook
  run run_hook "test-single" "configure" "$(payload configure)"
  [ "$status" -eq 0 ]

  # Verify mist configuration
  run docker exec test-single bash -c "[ -f /etc/mist/config.yml ]"
  [ "$status" -eq 0 ]

  # Verify narc configuration
  run docker exec test-single bash -c "[ -f /opt/gomicro/etc/narc.conf ]"
  [ "$status" -eq 0 ]
}

@test "Start" {
  # Run hook
  run run_hook "test-single" "start" "$(payload start)"
  [ "$status" -eq 0 ]

  # Verify mist running
  run docker exec test-single bash -c "ps aux | grep [m]ist"
  [ "$status" -eq 0 ]

  # Verify narc running
  run docker exec test-single bash -c "ps aux | grep [n]arc"
  [ "$status" -eq 0 ]
}

@test "Verify Service" {
  skip
  # I need to figure out how to test this
}

@test "Stop" {
  # Run hook
  run run_hook "test-single" "stop" "$(payload stop)"
  [ "$status" -eq 0 ]

  # Test the double stop
  run run_hook "test-single" "stop" "$(payload stop)"
  [ "$status" -eq 0 ]

  # Wait until services shut down
  while docker exec "test-single" bash -c "ps aux | grep [m]ist"
  do
    sleep 1
  done

  # Verify mist is not running
  run docker exec test-single bash -c "ps aux | grep [m]ist"
  [ "$status" -eq 1 ]

  # Verify narc is not running
  run docker exec test-single bash -c "ps aux | grep [n]arc"
  [ "$status" -eq 1 ]
}

@test "Stop Container" {
  stop_container "test-single"
}
