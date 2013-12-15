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
#-- File Name         : xmlManager.pm
#-- Author            : mammenx
#-- Function          : This package contains subs to handle regmap data in
#                       xml files.
#--------------------------------------------------------------------------


package xmlManager;
use strict;
use warnings;

use XML::Simple;
use Data::Dumper;
use XML::Writer;
use IO;

  sub main'bar {
    print "Hello World\n"
  }

  sub main'newREGMAP {
    my  ($name) = @_;

    my  $file = new IO::File(">$name.xml");
    my  $writer = new XML::Writer(OUTPUT=>$file, 
                                  DATA_MODE=>'true',
                                  DATA_INDENT=>'2',
                                  ENCODING=>'utf-8'
                                );

    $writer->xmlDecl("UTF-8");
    $writer->doctype('regmap');
    $writer->comment('Blank REGMAP page');
    $writer->startTag('regmap', 'ver'=>'0.0', 'repo'=>'https://github.com/mammenx/regmap');
      $writer->startTag('reg', 'width'=>'16', 'addr'=>'0x0', 'name'=>'Control Register');
        $writer->comment("This register contains fields to control the module");
        $writer->startTag('field', 'lsbit'=>'0', 'msbit'=>'7', 'access'=>'RW', 'name'=>'Mode');
        $writer->characters("This field selects the mode of operation. Valid cases are: 0x0 - > mode0, 0x1->mode1");
      $writer->endTag('field');
      $writer->endTag('reg');
    $writer->endTag('regmap');
    $writer->end();
  }

  sub main'displayREGMAP  {
    my  ($name) = @_;

    my $xml = XMLin("$name.xml");

    print Dumper($xml);
  }

1;
