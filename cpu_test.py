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
lib.add_source_files(join(root, "ROM_T1", "test_T1.vhd"),vhdl_standard="2008")
lib.add_source_files(join(root, "alu", "alu.vhd"),vhdl_standard="2008")


lib.add_source_files(join(root, "fetch", "fetch.vhd"),vhdl_standard="2008")
lib.add_source_files(join(root, "decode", "decode.vhd"),vhdl_standard="2008")
lib.add_source_files(join(root, "execute", "execute.vhd"),vhdl_standard="2008")
lib.add_source_files(join(root, "memory_access", "memory_access.vhd"),vhdl_standard="2008")
lib.add_source_files(join(root, "write_back", "write_back.vhd"),vhdl_standard="2008")

lib.add_source_files(join(root, "*.vhd"),vhdl_standard="2008")

ui.main()
