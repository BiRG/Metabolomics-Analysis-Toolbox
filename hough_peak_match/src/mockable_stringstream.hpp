#ifndef STD_MOCK_ISTRINGSTREAM_HPP
#define STD_MOCK_ISTRINGSTREAM_HPP

#include <sstream>

#ifdef USE_MOCK_ISTRINGSTREAM
#include "mockable_stringstream_declaration.hpp"

#define istringstream mock_istringstream
#endif //USE_MOCK_ISTRINGSTREAM

#endif //STD_MOCK_ISTRINGSTREAM_HPP
