#!/usr/bin/env python

"""
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
"""


"""
   Find any duplicates in a list of x values
"""

import sys
import json
import json

values = json.load(open("./randomX.json", "r"))
s = set()
for x in values:
    if x in s:
        print "TEST FAILED"
        sys.exit(1)
    else:
        s.add(x)
print "TEST PASSED"
      
