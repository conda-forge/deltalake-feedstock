# Taken from clangdev's recipe
# https://github.com/conda-forge/clangdev-feedstock/blob/01fc5e3e0fc690db85151dcb3ff512e6aa876be7/recipe/build.sh#L51-L56
# disable -fno-plt due to some GCC bug causing linker errors, see
# https://github.com/llvm/llvm-project/issues/51205
if [[ "$target_platform" == "linux-ppc64le" ]]; then
  export CFLAGS="$(echo $CFLAGS | sed 's/-fno-plt //g')"
  export CXXFLAGS="$(echo $CFLAGS | sed 's/-fno-plt //g')"
fi
# license file inclusion by pip fails with 'Failed to write to *.dist-info/licenses/licenses/deltalake_license.txt'
# since we are including it in the conda package separately, let's not do it with pip too
sed -i.bak '/^license =/d' pyproject.toml

if [[ "$target_platform" == "linux-"* && "$target_platform" != "linux-64" && "$target_platform" != "linux-aarch64" ]]; then
  export LIBCLANG_PATH=$BUILD_PREFIX/lib
  (
    # Needed to bootstrap itself into the conda ecosystem
    unset CARGO_BUILD_TARGET
    export CARGO_BUILD_RUSTFLAGS=$(echo $CARGO_BUILD_RUSTFLAGS | sed "s@$PREFIX@$BUILD_PREFIX@g")
    export RUSTFLAGS=$CARGO_BUILD_RUSTFLAGS
    export PKG_CONFIG_PATH=${BUILD_PREFIX}/lib/pkgconfig
    unset MACOSX_DEPLOYMENT_TARGET
    unset CFLAGS
    unset CPPFLAGS
    unset LDFLAGS
    unset PREFIX
    cargo install --verbose bindgen-cli
  )
  export PATH=$CARGO_HOME/bin:$PATH
  export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=$CONDA_BUILD_SYSROOT -target $HOST"
  echo "BINDGEN_EXTRA_CLANG_ARGS=${BINDGEN_EXTRA_CLANG_ARGS}"
  CONDA_RUST_HOST_LOWER=$(echo $CONDA_RUST_HOST | tr '[:upper:]' '[:lower:]')
  export CFLAGS_${CONDA_RUST_HOST_LOWER}="-isystem $BUILD_PREFIX/include"
  CONDA_RUST_TARGET_LOWER=$(echo $CONDA_RUST_TARGET | tr '[:upper:]' '[:lower:]')
  export CFLAGS_${CONDA_RUST_TARGET_LOWER}="$CFLAGS"
  unset CFLAGS
fi

${PYTHON} -m pip install . -vv

