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

use Data::Dumper;
use XML::Writer;
use XML::Simple;
use XML::Twig;
use IO;

  sub main'bar {
    print "Hello World\n"
  }

  sub main'newREGMAP {
    my  ($name,$ver,$dwidth,$xmlStyle) = @_;

    my  $file = new IO::File(">$name.xml");
    my  $writer = new XML::Writer(OUTPUT=>$file, 
                                  DATA_MODE=>'true',
                                  DATA_INDENT=>'2',
                                  ENCODING=>'utf-8'
                                );

    $writer->xmlDecl("UTF-8");

    if($xmlStyle  eq  'xsl')  {
      $writer->pi('xml-stylesheet', "type=\"text/xsl\" href=\"$name.xsl\"");
    } elsif($xmlStyle eq  'css')  {
      $writer->pi('xml-stylesheet', "type=\"text/css\" href=\"$name.css\"");
    } else  {
      print "Unknown XML Style : $xmlStyle\n";
      die;
    }

    # $writer->doctype('regmap');
    $writer->startTag('regmap');
      $writer->dataElement('ver', $ver);
      $writer->dataElement('repo', 'https://github.com/mammenx/regmap');
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
              $writer->startTag('table', 'border'=>"1", 'bgcolor'=>"#ffffff");
                writeRawElement($writer, 'p', "Register Name : <xsl:value-of select=\"name\"/>");
                writeRawElement($writer, 'p', "Node          : <xsl:value-of select=\"node\"/>");
                writeRawElement($writer, 'p', "Target        : <xsl:value-of select=\"target\"/>");
                writeRawElement($writer, 'p', "Offset        : <xsl:value-of select=\"offset\"/>");
                writeRawElement($writer, 'p', "Register Addr : <xsl:value-of select=\"addr\"/>");
                writeRawElement($writer, 'p', "Description   : <xsl:value-of select=\"desc\"/>");

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
              $writer->endTag('table');
              writeRawElement($writer, 'p', "");
            $writer->endTag('xsl:for-each');
          $writer->endTag('body');
        $writer->endTag('html');
      $writer->endTag('xsl:template');
    $writer->endTag('xsl:stylesheet');
    $writer->end();

  }

  sub main'addNewReg  {
    my  ($prj,$name,$node,$target,$offset,$desc) = @_;

    my $twig  = new XML::Twig;

    $twig->parsefile("$prj.xml");

    my $regmap= $twig->root;  #get the root of the twig

    my $ereg = new XML::Twig::Elt('reg');  #Create new reg element

    my $ewidth  = new XML::Twig::Elt('width', $main::dwidth);
    $ewidth->paste('last_child', $ereg);   #Append under reg tag

    my $ename  = new XML::Twig::Elt('name', $name);
    $ename->paste('last_child', $ereg);   #Append under reg tag

    my $enode  = new XML::Twig::Elt('node', $node);
    $enode->paste('last_child', $ereg);   #Append under reg tag

    my $etarget= new XML::Twig::Elt('target', $target);
    $etarget->paste('last_child', $ereg);   #Append under reg tag

    my $eoffset  = new XML::Twig::Elt('offset', $offset);
    $eoffset->paste('last_child', $ereg);   #Append under reg tag

    my $eaddr   = new XML::Twig::Elt('addr', "$node.$target.$offset");
    $eaddr->paste('last_child', $ereg);   #Append under reg tag

    my $edesc  = new XML::Twig::Elt('desc', $desc);
    $edesc->paste('last_child', $ereg);   #Append under reg tag

    $ereg->paste('last_child', $regmap);   #Append under regmap tag

    #Sort registers based on address
    $regmap->sort_children_on_field('addr' , type => 'alpha', order => 'normal');

    my  $fclose = new IO::File(">$prj.xml");
    #$twig->flush($fclose,  pretty_print => 'indented');
    $twig->print($fclose,  pretty_print => 'indented');
  }

  sub main'addNewField  {
    my  ($prj,$name,$reg,$acc,$msidx,$lsidx,$desc) = @_;

    my $twig  = new XML::Twig(
      twig_handlers =>  { reg =>  sub { # Anonymous sub
          my( $twig, $ereg)= @_;

          #print  "ereg:addr - " . $ereg->first_child('addr')->text;

          my  $reg_addr = $ereg->first_child('addr')->text;  # Get the addr of this register

          #if($reg_name  eq  $reg) { #Add field here
          if($reg_addr  eq  $reg) { #Add field here
            my  $efield = new XML::Twig::Elt('field');  #Create new field element
            my  $ename  = new XML::Twig::Elt('name',  $name);   #Create new name element
            my  $eacc   = new XML::Twig::Elt('access',  $acc); #Create new access element
            my  $emsidx = new XML::Twig::Elt('msidx',  $msidx); #Create new msidx element
            my  $elsidx = new XML::Twig::Elt('lsidx',  $lsidx); #Create new lsidx element
            my  $edesc  = new XML::Twig::Elt('desc',  $desc); #Create new desc element

            $ename->paste('last_child', $efield);   #Append under field tag
            $eacc->paste('last_child', $efield);   #Append under field tag
            $emsidx->paste('last_child', $efield);   #Append under field tag
            $elsidx->paste('last_child', $efield);   #Append under field tag
            $edesc->paste('last_child', $efield);   #Append under field tag

            $efield->paste('last_child', $ereg);   #Append under regmap tag
          }
        }
      }
    );

    $twig->parsefile("$prj.xml");

    my $regmap= $twig->root;  #get the root of the twig
    my @eregs = $regmap->children('reg'); #Get list of registers

    foreach my  $ereg (@eregs)  {
      #Sort fields based on indexes
      #print "Sorting ereg : " . $ereg->first_child('name')->text . "\n";
      #$ereg->sort_children_on_field('lsidx' , type => 'alpha', order => 'normal');
      $ereg->sort_children_on_field('lsidx' , type => 'numeric', order => 'normal');
    }

    my  $fclose = new IO::File(">$prj.xml");
    #$twig->flush($fclose,  pretty_print => 'indented');
    $twig->print($fclose,  pretty_print => 'indented');

    return 1;
 }

 sub  sortFields  {
    my  ($prj,$name,$reg) = @_;
 }

  sub main'displayREGMAP  {
    my  ($name) = @_;

    my $xml = XMLin("$name.xml");

    print Dumper($xml);
  }

1;
