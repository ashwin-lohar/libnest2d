set(_tools_h "${NLopt_SOURCE_DIR}/src/algs/stogo/tools.h")

if(EXISTS "${_tools_h}")
  file(READ "${_tools_h}" _tools_h_content)
  string(REPLACE
    "class TrialGT : public unary_function<Trial, bool>"
    "class TrialGT : public std::unary_function<Trial, bool>"
    _tools_h_content
    "${_tools_h_content}"
  )
  string(REPLACE
    "#include <iostream>"
    "#include <iostream>\n#include <functional>"
    _tools_h_content
    "${_tools_h_content}"
  )
  file(WRITE "${_tools_h}" "${_tools_h_content}")
endif()
