# Build Steps

These notes describe the builds that worked on this machine. Use the MSVC build
if your consuming project is built with Visual Studio/MSVC.

## Requirements

- CMake
- Visual Studio 2022 with MSVC, or MinGW `mingw32-make`
- A C++ compiler with C++11 support
- Boost headers

On this machine, Boost was available at:

```powershell
C:\Apps\boost_1_78_0
```

## Recommended: Build With MSVC

Use this if your other project uses MSVC.

From the repository root:

```powershell
cmake -S . -B build-msvc -G "Visual Studio 17 2022" -A x64 `
  -DLIBNEST2D_HEADER_ONLY=OFF `
  -DRP_ENABLE_DOWNLOADING=ON `
  -DBOOST_ROOT=C:/Apps/boost_1_78_0 `
  -DBOOST_INCLUDEDIR=C:/Apps/boost_1_78_0 `
  -DBoost_NO_SYSTEM_PATHS=ON `
  -DBoost_HEADERS_FOUND=ON `
  -DRP_INSTALL_PREFIX=C:/Users/ashwi/Desktop/libnest2d/build-msvc/dependencies
```

Then build Release:

```powershell
cmake --build build-msvc --config Release
```

The resulting MSVC static library is:

```text
build-msvc/Release/libnest2d_clipper_nlopt.lib
```

The MSVC-built dependency libraries are:

```text
build-msvc/dependencies/lib/polyclipping.lib
build-msvc/dependencies/lib/nlopt.lib
```

Debug dependency libraries are also generated:

```text
build-msvc/dependencies/lib/polyclippingd.lib
build-msvc/dependencies/lib/nloptd.lib
```

## Alternative: Build With MinGW

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

If you want to use the compiled MSVC static library from this build instead,
add the include directories and link the library plus its dependencies:

```cmake
target_include_directories(your_target PRIVATE
    path/to/libnest2d/include
    path/to/libnest2d/build-msvc/dependencies/include
    C:/Apps/boost_1_78_0
)

target_link_libraries(your_target PRIVATE
    path/to/libnest2d/build-msvc/Release/libnest2d_clipper_nlopt.lib
    path/to/libnest2d/build-msvc/dependencies/lib/polyclipping.lib
    path/to/libnest2d/build-msvc/dependencies/lib/nlopt.lib
)

target_compile_definitions(your_target PRIVATE
    LIBNEST2D_GEOMETRIES_clipper
    LIBNEST2D_OPTIMIZER_nlopt
    LIBNEST2D_STATIC
)
```

Use forward slashes or escaped backslashes in CMake paths.

Important: use the same compiler family for your project and the static library.
For an MSVC project, use the `build-msvc` `.lib` files. For a MinGW project, use
the `build-mingw-apps` `.a` files.

## Header Files You Need

For normal use, include:

```cpp
#include <libnest2d/libnest2d.hpp>
```

Make sure your compiler can find:

- `include`
- `build-msvc/dependencies/include`
- the Boost include directory, for example `C:/Apps/boost_1_78_0`

The dependency include directory contains the generated/installed headers for
Clipper and NLopt.

## Notes For Modern Visual Studio

This repository needed two small compatibility updates for the MSVC build:

- `external/+Boost/CMakeLists.txt` now recognizes MSVC 19.4x as Boost toolset
  `msvc-14.4`.
- `external/+NLopt` applies a small patch to NLopt 2.6.1 so its old Stogo code
  builds with current MSVC.

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
