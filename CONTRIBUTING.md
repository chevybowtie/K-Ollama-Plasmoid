# Contributing to K-Ollama

Thanks for wanting to contribute! This project keeps UI code in QML and pure, stateless helper functions in `contents/js/utils.js`. Adding unit tests for the helpers makes contributions easier to review.

## Writing tests for JS helpers

We use Qt Quick Test (QML tests) to unit-test JavaScript helpers that live under `contents/js/`.

Guidelines

- Tests live under `tests/` and follow the file name pattern `tst_*.qml`.
- Test files should import the project helper JS directly so logic is single-sourced:

```qml
import QtQuick 2.15
import QtTest 1.3
import "../contents/js/utils.js" as Utils

TestCase {
    name: "UtilsTests"

    function test_myHelper() {
        compare(Utils.myHelper('input'), 'expected');
    }
}
```

- Prefer small, focused tests: happy path + 1-2 edge cases (empty/null, odd formatting, invalid types).
- When adding a new helper to `contents/js/utils.js`, add at least one new `tst_*.qml` file exercising the function.
- Run tests locally with the bundled wrapper from the repository root:

```bash
scripts/run-tests.sh
```

If your system uses multiple Qt versions, you can force a specific runner:

```bash
QMLTEST_RUNNER=/opt/qt/6.8.2/bin/qmltestrunner scripts/run-tests.sh
```

Tips

- Keep helpers pure and free of QML global state (Plasmoid, Qt objects). If you need configuration values, accept them as function parameters so tests can pass in mock objects.
- Add JSDoc-style comments above new helpers so other contributors understand inputs/outputs and error modes.
- Run the full test suite before opening a PR.

Thank you for contributing—small tests go a long way to keeping the project stable and reviewable.
