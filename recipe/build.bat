cd python || exit 1

REM license file inclusion by pip fails with 'Failed to write to *.dist-info/licenses/licenses/deltalake_license.txt'
REM since we are including it in the conda package separately, let's not do it with pip too
sed -i.bak '/^license =/d' pyproject.toml || exit 1

REM avoid path too long problem
set CARGO_HOME=C:\
set PYTHONUTF8=1
set PYTHONIOENCODING=utf-8
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation || exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
