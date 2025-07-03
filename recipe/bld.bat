REM license file inclusion by pip fails with 'Failed to write to *.dist-info/licenses/licenses/deltalake_license.txt'
REM since we are including it in the conda package separately, let's not do it with pip too
sed -i.bak '/^license =/d' pyproject.toml

%PYTHON% -m pip install . -vv
