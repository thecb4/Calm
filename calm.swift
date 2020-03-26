#!/usr/bin/swift sh

import Calm // ./

Calm.Flow.remote = "git@gitlab.com:thecb4/calm.git"

if #available(macOS 10.13, *) {
  Calm.main()
} else {
  print("Please at least run macOS 10.13")
}
