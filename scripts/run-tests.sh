#!/usr/bin/env bash
set -euo pipefail

# scripts/run-tests.sh
# Wrapper to run Qt QML tests for this project.
# Usage: scripts/run-tests.sh [additional qmltestrunner args]
# Environment variables:
#   QMLTEST_RUNNER - path to qmltestrunner binary to use (optional)

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CONTENTS_DIR="$ROOT_DIR/contents"
TESTS_DIR="$ROOT_DIR/tests"

# Validate all QML files in contents/ unless explicitly skipped
if [[ "${SKIP_QML_LINT:-}" != "1" ]]; then
  if [[ -n "${QMLLINT_BIN:-}" ]]; then
    QML_LINTER="$QMLLINT_BIN"
  elif [[ -x "/usr/lib/qt6/bin/qmllint" ]]; then
    QML_LINTER="/usr/lib/qt6/bin/qmllint"
  elif command -v qmllint >/dev/null 2>&1; then
    QML_LINTER="$(command -v qmllint)"
  else
    echo "Error: qmllint not found. Set QMLLINT_BIN or install `qt6-qmllint-plugins`" >&2
    echo "Set SKIP_QML_LINT=1 to bypass QML validation." >&2
    exit 2
  fi

  # Collect QML files using null-delimited output to handle spaces safely
  mapfile -d '' -t QML_FILES < <(find "$CONTENTS_DIR" -type f -name '*.qml' -print0)

  if (( ${#QML_FILES[@]} > 0 )); then
    echo "Running qmllint on ${#QML_FILES[@]} QML files..."

    QML_LINT_ARGS=()
    QML_LINTER_HELP="$("$QML_LINTER" --help 2>&1 || true)"
    if [[ "$QML_LINTER_HELP" == *"--strict"* ]]; then
      QML_LINT_ARGS+=("--strict")
    else
      echo "qmllint: --strict flag not supported; running without it."
    fi

    QML_LINTER_VERSION="$("$QML_LINTER" --version 2>/dev/null || true)"
    QML_LINTER_MAJOR=""
  if [[ "$QML_LINTER_VERSION" =~ ([0-9]+)\. ]]; then
      QML_LINTER_MAJOR="${BASH_REMATCH[1]}"
    fi

    declare -a _QMLDIR_CANDIDATES=("$CONTENTS_DIR" "$CONTENTS_DIR/ui")
    if [[ -n "${QML_IMPORT_PATH:-}" ]]; then
      IFS=':' read -r -a _IMPORT_PATHS <<< "${QML_IMPORT_PATH}"
      _QMLDIR_CANDIDATES+=("${_IMPORT_PATHS[@]}")
    fi
    if [[ -n "${QML2_IMPORT_PATH:-}" ]]; then
      IFS=':' read -r -a _IMPORT_PATHS2 <<< "${QML2_IMPORT_PATH}"
      _QMLDIR_CANDIDATES+=("${_IMPORT_PATHS2[@]}")
    fi
    if [[ -n "${QML_LINT_EXTRA_QMLDIRS:-}" ]]; then
      IFS=':' read -r -a _EXTRA_QMLDIRS <<< "${QML_LINT_EXTRA_QMLDIRS}"
      _QMLDIR_CANDIDATES+=("${_EXTRA_QMLDIRS[@]}")
    fi

    QT_QML_DIR=""
    if [[ "$QML_LINTER_MAJOR" == "6" ]]; then
      if command -v qtpaths6 >/dev/null 2>&1; then
        QT_QML_DIR="$(qtpaths6 --qt-query QT_INSTALL_QML 2>/dev/null || true)"
      fi
      _QMLDIR_CANDIDATES+=(
        "/usr/lib/qt6/qml"
        "/usr/lib/x86_64-linux-gnu/qt6/qml"
        "/usr/lib64/qt6/qml"
      )
    else
      if command -v qtpaths >/dev/null 2>&1; then
        QT_QML_DIR="$(qtpaths --qt-query QT_INSTALL_QML 2>/dev/null || true)"
      fi
      _QMLDIR_CANDIDATES+=(
        "/usr/lib/qt5/qml"
        "/usr/lib/x86_64-linux-gnu/qt5/qml"
        "/usr/lib64/qt5/qml"
      )
    fi
    if [[ -n "${QT_QML_DIR:-}" ]]; then
      _QMLDIR_CANDIDATES+=("$QT_QML_DIR")
    fi

    declare -A _QMLDIR_SEEN=()
    for _dir in "${_QMLDIR_CANDIDATES[@]}"; do
      if [[ -n "${_dir:-}" && -d "${_dir}" && -z "${_QMLDIR_SEEN[$_dir]:-}" ]]; then
        _QMLDIR_SEEN[$_dir]=1
        QML_LINT_ARGS+=("--qmldirs" "${_dir}")
      fi
    done

    if [[ -z "${QML_LINT_DISABLE_DEFAULT_FILTERS:-}" ]]; then
      QML_LINT_ARGS+=("--import" "info" "--missing-type" "info" "--unresolved-type" "info" "--missing-property" "info")
    fi

    if [[ -n "${QML_LINT_EXTRA_ARGS:-}" ]]; then
      # shellcheck disable=SC2206
      EXTRA_LINT_ARGS=(${QML_LINT_EXTRA_ARGS})
      QML_LINT_ARGS+=("${EXTRA_LINT_ARGS[@]}")
    fi

    "$QML_LINTER" "${QML_LINT_ARGS[@]}" "${QML_FILES[@]}"
  else
    echo "No QML files found under $CONTENTS_DIR; skipping validation."
  fi
else
  echo "Skipping QML validation (SKIP_QML_LINT=1)."
fi

# Locate qmltestrunner
if [[ -n "${QMLTEST_RUNNER:-}" ]]; then
  RUNNER="$QMLTEST_RUNNER"
elif [[ -x "/usr/lib/qt6/bin/qmltestrunner" ]]; then
  RUNNER="/usr/lib/qt6/bin/qmltestrunner"
elif command -v qmltestrunner >/dev/null 2>&1; then
  RUNNER=$(command -v qmltestrunner)
else
  echo "Error: qmltestrunner not found. Set QMLTEST_RUNNER or install Qt (qt6-qmltest / qt5-qmltest)." >&2
  exit 2
fi

# Default args: import project contents so tests can import JS helpers, and run tests from tests/ dir
DEFAULT_ARGS=("-import" "$CONTENTS_DIR" "-input" "$TESTS_DIR")

# Allow user to pass additional args which will be appended
exec "$RUNNER" "${DEFAULT_ARGS[@]}" "$@"
