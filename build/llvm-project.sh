#!/usr/bin/env bash
sudo git clone --depth 1 https://github.com/llvm/llvm-project.git && cd llvm-project
sudo git swicth -c llvmorg-16.0.6
sudo cmake -S llvm -B build -G "Ninja" -DCMAKE_C_COMPILER='clang' -DCMAKE_CXX_COMPILER='clang++' -DCMAKE_MAKE_PROGRAM='/usr/local/bin/ninja' -DCMAKE_ASM_COMPILER='clang++' -DCMAKE_BUILD_TYPE='Release' -DCMAKE_INSTALL_PREFIX='/opt/llvm-project-16.0.6'