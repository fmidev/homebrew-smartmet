// macOS prelude — injected via clang's -include flag in Makefile.mac.
//
// Linux glibc/sys headers expose `uint` / `ushort` / `uchar` / `ulong` as
// non-portable typedefs without needing an explicit feature macro. macOS
// gates them behind _DARWIN_C_SOURCE (and even with that macro, headers
// that pull in <string> alone don't see them). The smartmet-library-grid-files
// source assumes these names are visible globally.
//
// We inject them once here so we don't need to patch ~50 headers.

#pragma once

#ifdef __APPLE__
#  include <sys/types.h>  // pull in u_int / u_short / u_char / u_long
typedef unsigned int   uint;
typedef unsigned short ushort;
typedef unsigned char  uchar;
typedef unsigned long  ulong;

// macgyver's Fmi::to_string is "intentionally" missing long long overloads
// (StringConversion.h says so). On macOS arm64 std::int64_t is long long
// (not long, as on Linux x86_64), so call sites passing int64_t become
// ambiguous between to_string(int) / to_string(long). Add inline shims that
// delegate to std::to_string for the missing types.
//
// Wrapped in __cplusplus and a once-flag because this prelude is force-
// included into every TU.
#  ifdef __cplusplus
#    include <string>
namespace Fmi
{
inline std::string to_string(long long value) { return std::to_string(value); }
inline std::string to_string(unsigned long long value) { return std::to_string(value); }
}  // namespace Fmi
#  endif
#endif
