mkdir -p ./bochs-src
tar -zxvf ./bochs-2.6.11.tar.gz -C ./bochs-src
cd ./bochs-src/bochs-2.6.11
./configure --prefix=$(readlink -f ../../) --enable-gdb-stub --enable-disasm --enable-iodebug --enable-x86-debugger --with-x --with-x11 LDFLAGS='-pthread'
make
make install
