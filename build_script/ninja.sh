#!/usr/bin/env bash
sudo git clone https://github.com/ninja-build/ninja.gitv1.11.1 && cd ninja
sudo git switch -c v1.11.1
sudo cmake -Bbuild-cmake -DCMAKE_C_COMPILER='clang' -DCMAKE_CXX_COMPILER='clang++'
sudo cmake --build build-cmake
sudo cmake --install build-cmake --prefix='/opt/ninja-1.11.1'
sudo ln -s /opt/ninja-1.11.1/bin/ninja /usr/bin/ninja-1.11.1
sudo ln -s /usr/bin/ninja-1.11.1 /usr/bin/ninja