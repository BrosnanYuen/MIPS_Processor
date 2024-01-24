# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2014-2015, Lars Asplund lars.anders.asplund@gmail.com

from os.path import join, dirname
from vunit import VUnit

root = dirname(__file__)

ui = VUnit.from_argv()
lib = ui.add_library("lib",vhdl_standard="2008")
#lib.add_source_files(join(root, "nandop", "*.vhd"),vhdl_standard="2008")
#lib.add_source_files(join(root, "multiplier", "*.vhd"),vhdl_standard="2008")
#lib.add_source_files(join(root, "shl", "*.vhd"),vhdl_standard="2008")
#lib.add_source_files(join(root, "shr", "*.vhd"),vhdl_standard="2008")
#lib.add_source_files(join(root, "adder", "*.vhd"),vhdl_standard="2008")
lib.add_source_files(join(root, "*.vhd"),vhdl_standard="2008")
lib.add_source_files(join(root, "../", "cpu_consts.vhd"),vhdl_standard="2008")
ui.main()
