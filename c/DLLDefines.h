/*
Copyright 2015 CertiVox UK Ltd

This file is part of The CertiVox MIRACL IOT Crypto SDK (MiotCL)

MiotCL is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

MiotCL is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MiotCL.  If not, see <http://www.gnu.org/licenses/>.

You can be released from the requirements of the license by purchasing 
a commercial license.
*/

/* Use with Visual Studio Compiler for building Shared libraries */
#ifndef _DLLDEFINES_H_
#define _DLLDEFINES_H_

/* Cmake will define sok_EXPORTS and mpin_EXPORTS on Windows when it
configures to build a shared library. If you are going to use
another build system on windows or create the visual studio
projects by hand you need to define sok_EXPORTS and mpin_EXPORTS when
building a DLL on windows. */
/* #define sok_EXPORTS */
/* #define mpin_EXPORTS */


#if defined (_MSC_VER) 

 #define DLL_EXPORT extern
/* This code does not work with cl */
/*  #if defined(sok_EXPORTS) || defined(mpin_EXPORTS) */
/*    #define  DLL_EXPORT __declspec(dllexport) */
/*  #else */
/*    #define  DLL_EXPORT __declspec(dllimport) */
/*  #endif /\* sok_EXPORTS || mpin_EXPORTS *\/ */

#else /* defined (_WIN32) */

 #define DLL_EXPORT extern

#endif

#endif /* _DLLDEFINES_H_ */
