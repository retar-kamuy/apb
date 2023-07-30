#!/usr/bin/env bash
sudo dnf -y install clang cmake
sudo git clone https://github.com/MikePopoloski/slang.git && cd slang
sudo git switch -c v3.0
sudo cmake -B build -DCMAKE_C_COMPILER='clang' -DCMAKE_CXX_COMPILER='clang++' -G Ninja -DCMAKE_INSTALL_PREFIX='/opt/slang-3.0'
cd build
sudo ninja
sudo cmake --build build -j$(nproc)
sudo cmake --install build --strip --prefix='/opt/slang-3.0'
sudo ln -s /opt/slang-3.0/bin/slang /usr/bin/slang-3.0
sudo ln -s /usr/bin/slang-3.0 /usr/bin/slang