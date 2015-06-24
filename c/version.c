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

#include "version.h"


/*! \brief Print version number and information about the build
 *
 *  Print version number and information about the build
 * 
 */
void version(char* info)
{
  sprintf(info,"Version: %d.%d.%d OS: %s FIELD CHOICE: %s CURVE TYPE: %s WORD_LENGTH: %d", MiotCL_VERSION_MAJOR, MiotCL_VERSION_MINOR, MiotCL_VERSION_PATCH, OS, FIELD_CHOICE, CURVE_TYPE, CHUNK);
}

