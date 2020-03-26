//
import Path

let env = ["PATH": "/usr/local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"]

let gitPreCommitShellScript =
  """
  #!/bin/bash
  # Stops accidental commits to master and develop. https://gist.github.com/stefansundin/9059706

  BRANCH=`git rev-parse --abbrev-ref HEAD`

  branches=(develop master)

  if [[ " ${branches[@]} " =~ " ${BRANCH} "  ]]; then
    echo "You are on branch $BRANCH. Are you sure you want to commit to this branch?"
    echo "If so, commit with -n to bypass this pre-commit hook."
    exit 1
  fi

  exit 0
  """

let gitPreCommitHookPath = Path.cwd / ".git/hooks/pre-commit"
