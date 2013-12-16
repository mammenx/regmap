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
    $writer->pi('xml-stylesheet', "type=\"text/xsl\" href=\"$name.xsl\"");
    # $writer->doctype('regmap');
    $writer->startTag('regmap');
      $writer->dataElement('ver', '0.0');
      $writer->dataElement('repo', 'https://github.com/mammenx/regmap');

      $writer->startTag('reg');
        $writer->dataElement('width', '16');
        $writer->dataElement('addr', '0x0');
        $writer->dataElement('name', 'Control Register');
        $writer->dataElement('desc', 'This register contains fields to control the module');

        $writer->startTag('field');
          $writer->dataElement('lsidx', '0');
          $writer->dataElement('msidx', '7');
          $writer->dataElement('access', 'RW');
          $writer->dataElement('name', 'Mode');
          $writer->dataElement('desc', 'This field selects the mode of operation. Valid cases are: 0x0 - > mode0, 0x1->mode1');
        $writer->endTag('field');
      $writer->endTag('reg');
    $writer->endTag('regmap');
    $writer->end();
  }

  # Write a simple data element.
  sub writeRawElement {
    my ($self, $name, $data, @atts) = (@_);
    $self->startTag($name, @atts);
    $self->raw($data);
    $self->endTag($name);
  }

  sub main'createXSL {
    my  ($name) = @_;

    my  $file = new IO::File(">$name.xsl");
    my  $writer = new XML::Writer(OUTPUT=>$file, 
                                  DATA_MODE=>'true',
                                  UNSAFE=>'true',
                                  DATA_INDENT=>'2',
                                  ENCODING=>'utf-8'
                                );

    $writer->xmlDecl("UTF-8");
    $writer->startTag('xsl:stylesheet', 'version'=>'1.0', 'xmlns:xsl'=>'http://www.w3.org/1999/XSL/Transform');
      $writer->startTag('xsl:template', 'match'=>'/');
        $writer->startTag('html');
          $writer->startTag('body');
            writeRawElement($writer, 'h2', "REGMAP v<xsl:value-of select=\"regmap/ver\"/>");
 
            $writer->startTag('xsl:for-each', 'select'=>"regmap/reg");
              writeRawElement($writer, 'p', "Register Name : <xsl:value-of select=\"name\"/>");
              writeRawElement($writer, 'p', "Register Addr : <xsl:value-of select=\"addr\"/>");
              writeRawElement($writer, 'p', "Description : <xsl:value-of select=\"desc\"/>");

              # Construct Table
              $writer->startTag('table', 'border'=>"1");
                $writer->startTag('tr', 'bgcolor'=>"#9acd32");
                  $writer->dataElement('th', 'Field');
                  $writer->dataElement('th', 'Range');
                  $writer->dataElement('th', 'Access');
                  $writer->dataElement('th', 'Description');
                $writer->endTag('tr');

                $writer->startTag('xsl:for-each', 'select'=>"field");
                  $writer->startTag('tr');
                    writeRawElement($writer, 'td', "<xsl:value-of select=\"name\"/>");
                    writeRawElement($writer, 'td', "<xsl:value-of select=\"msidx\"/>:<xsl:value-of select=\"lsidx\"/>");
                    writeRawElement($writer, 'td', "<xsl:value-of select=\"access\"/>");
                    writeRawElement($writer, 'td', "<xsl:value-of select=\"desc\"/>");
                  $writer->endTag('tr');
                $writer->endTag('xsl:for-each');

              $writer->endTag('table');
            $writer->endTag('xsl:for-each');
          $writer->endTag('body');
        $writer->endTag('html');
      $writer->endTag('xsl:template');
    $writer->endTag('xsl:stylesheet');
    $writer->end();

  }

  sub main'displayREGMAP  {
    my  ($name) = @_;

    my $xml = XMLin("$name.xml");

    print Dumper($xml);
  }

1;
