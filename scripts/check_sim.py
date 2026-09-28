#!/usr/bin/env python3
"""Supporting tooling: validate the report's complete simulation summary."""

import argparse
from pathlib import Path
import re
import sys


EXPECTED = "PASS: 3584 single-cycle checks + 512 MUL/DIV checks, 0 errors"


def check_log(log: str):
    """Require a complete PASS and reject failure diagnostics anywhere in the log."""
    if re.search(r"\b(?:FAIL(?:ED|URE)?|FATAL|ERROR)\b", log, re.IGNORECASE):
        return False, "failure diagnostic found in simulation log"
    if re.search(r"\b[1-9]\d*\s+errors?\b", log, re.IGNORECASE):
        return False, "nonzero error count found in simulation log"
    summaries = [
        " ".join(line.split())
        for line in log.splitlines()
        if re.match(r"\s*PASS\b", line)
    ]
    if summaries != [EXPECTED]:
        return False, "expected exactly one complete 3584 + 512 PASS summary"
    return True, "4096 exhaustive cases passed with zero errors"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("log", nargs="?", default="-", help="log file, or - for stdin")
    args = parser.parse_args()
    try:
        log = sys.stdin.read() if args.log == "-" else Path(args.log).read_text(encoding="utf-8")
    except (OSError, UnicodeError) as exc:
        print(f"FAIL: cannot read simulation log: {exc}", file=sys.stderr)
        return 1
    passed, message = check_log(log)
    print(f"{'PASS' if passed else 'FAIL'}: {message}", file=sys.stdout if passed else sys.stderr)
    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
