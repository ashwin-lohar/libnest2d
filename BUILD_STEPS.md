# Build Steps

These notes describe the build that worked on this machine with Strawberry
MinGW and CMake.

## Requirements

- CMake
- MinGW `mingw32-make`
- A C++ compiler with C++11 support
- Boost headers

On this machine, Boost was available at:

```powershell
C:\Apps\boost_1_78_0
```

## Build The Static Library

From the repository root:

```powershell
cmake -S . -B build-mingw-apps -G "MinGW Makefiles" `
  -DLIBNEST2D_HEADER_ONLY=OFF `
  -DRP_ENABLE_DOWNLOADING=ON `
  -DCMAKE_BUILD_TYPE=Release `
  -DBOOST_ROOT=C:/Apps/boost_1_78_0 `
  -DBOOST_INCLUDEDIR=C:/Apps/boost_1_78_0 `
  -DBoost_NO_SYSTEM_PATHS=ON `
  -DBoost_HEADERS_FOUND=ON `
  -DRP_INSTALL_PREFIX=C:/Users/ashwi/Desktop/libnest2d/build-mingw-apps/dependencies
```

Then build:

```powershell
cmake --build build-mingw-apps --config Release
```

The resulting static library is:

```text
build-mingw-apps/libnest2d_clipper_nlopt.a
```

The downloaded and built dependency headers/libraries are placed under:

```text
build-mingw-apps/dependencies
```

## Optional Test Command

```powershell
ctest --test-dir build-mingw-apps -C Release --output-on-failure
```

The current build does not enable unit tests, so this may report that no tests
were found.

## Using Libnest2D In A C++20 CMake Project

Your consuming project can use C++20. Libnest2D is written to be compatible
with older C++ standards, but it can be included and linked from a C++20 target.

For your application target, set C++20 as usual:

```cmake
set_property(TARGET your_target PROPERTY CXX_STANDARD 20)
set_property(TARGET your_target PROPERTY CXX_STANDARD_REQUIRED ON)
```

The easiest CMake integration is to add this repository as a subdirectory:

```cmake
add_subdirectory(path/to/libnest2d)
target_link_libraries(your_target PRIVATE libnest2d_headeronly)
```

If you want to use the compiled static library from this build instead, add the
include directories and link the library plus its dependencies:

```cmake
target_include_directories(your_target PRIVATE
    path/to/libnest2d/include
    path/to/libnest2d/build-mingw-apps/dependencies/include
    C:/Apps/boost_1_78_0
)

target_link_libraries(your_target PRIVATE
    path/to/libnest2d/build-mingw-apps/libnest2d_clipper_nlopt.a
    path/to/libnest2d/build-mingw-apps/dependencies/lib/libpolyclipping.a
    path/to/libnest2d/build-mingw-apps/dependencies/lib/libnlopt.a
)

target_compile_definitions(your_target PRIVATE
    LIBNEST2D_GEOMETRIES_clipper
    LIBNEST2D_OPTIMIZER_nlopt
    LIBNEST2D_STATIC
)
```

Use forward slashes or escaped backslashes in CMake paths.

Important: use the same compiler family for your project and this static
library. The library built here used MinGW/GCC, so a MinGW/GCC C++20 project is
the safest match. If your other project uses MSVC, rebuild Libnest2D with MSVC
instead of linking the MinGW `.a` file.

## Header Files You Need

For normal use, include:

```cpp
#include <libnest2d/libnest2d.hpp>
```

Make sure your compiler can find:

- `include`
- `build-mingw-apps/dependencies/include`
- the Boost include directory, for example `C:/Apps/boost_1_78_0`

The dependency include directory contains the generated/installed headers for
Clipper and NLopt.

## Minimal Example

```cpp
#include <cstdlib>
#include <iostream>
#include <vector>

#include <libnest2d/libnest2d.hpp>

int main() {
    using namespace libnest2d;

    std::vector<Item> input;
    input.emplace_back(std::vector<Point>{
        {0, 0},
        {1000000, 0},
        {1000000, 1000000},
        {0, 1000000},
        {0, 0},
    });

    size_t bins = nest(input, Box(10000000, 10000000));
    std::cout << "Bins used: " << bins << "\n";

    return EXIT_SUCCESS;
}
```
