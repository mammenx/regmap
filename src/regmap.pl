#--------------------------------------------------------------------------
#  regmap - Copyright (C) 2013 Gregory Matthew James.
#
#  This file is part of regmap.
#
#  regmap is free; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  regmap is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program. If not, see <http://www.gnu.org/licenses/>.
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
#-- Project Code      : regmap
#-- File Name         : regmap.pl
#-- Author            : mammenx
#-- Function          : This is the main runtime space for regmap.
#--------------------------------------------------------------------------

#!/usr/bin/perl

package main;
use strict;
use warnings;

use xmlManager;

  bar();
  newREGMAP("syn_reg_map");
  displayREGMAP("syn_reg_map");
  createXSL("syn_reg_map");

1;
