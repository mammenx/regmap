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

use feature qw(switch);

use xmlManager;

  #Variables
  $main::regmapVer  = "0.1";
  $main::prompt     = "regmap/>";
  $main::prj_name   = "regmap";
  $main::dwidth     = "32";
  $main::xmlStyle   = "xsl";

  sub displayGreet  {
    print "REGMAP v$main::regmapVer\n";
    print "\nType 'help' for list of commands & options\n\n";
  }

  sub parseRegArgs  {
    my  (@args) = @_;

    #print "arguments:@args\n";

    my  $name = undef;
    my  $addr = undef;
    my  $desc = undef;

    for(my $idx=0; $idx<@args;  $idx++) {
      given($args[$idx])  {
        when("-name") {
          $name = $args[$idx+1];
          $idx++;
          #print "name:$name\n";
        }

        when("-addr") {
          $addr = $args[$idx+1];
          $idx++;
          #print "addr:$addr\n";
        }

        when("-desc") {
          #print "detected -desc\n";
          $desc = "";
          $idx++;

          do  {
            $desc = $desc . " " . $args[$idx];

            if($desc  =~  /".*"/) {
              ($desc) = $desc =~ m/"(.*?)"/;
              break;
            } else  {
              $idx++;
            }
          } while ($idx < @args);
        }

        default { print "Unknown argument : $args[$idx]\n"; }
      }
    }

    if(!(defined $name && length $name > 0))  {
      print "reg/add>Enter a name for this register\n";
      $name =  <STDIN>;
      chomp($name);
    }

    if(!(defined $addr && length $addr > 0))  {
      print "reg/add>Enter the addr for this register in hex\n";
      $addr =  <STDIN>;
      chomp($addr);
    }

    if(!(defined $desc && length $desc > 0))  {
      print "reg/add>Enter the description for this register\n";
      $desc =  <STDIN>;
      chomp($desc);
    }

    addNewReg($main::prj_name,$name,$addr,$desc);
  }

  sub parseFieldArgs  {
    my  (@args) = @_;

    #print "arguments:@args\n";

    my  $name = undef;
    my  $acc  = undef;
    my  $reg  = undef;
    my  $msidx = undef;
    my  $lsidx = undef;
    my  $desc = undef;

    for(my $idx=0; $idx<@args;  $idx++) {
      given($args[$idx])  {
        when("-name") {
          $name = $args[$idx+1];
          $idx++;
        }

        when("-reg") {
          $reg  = $args[$idx+1];
          $idx++;
        }

        when("-acc") {
          $acc  = $args[$idx+1];
          $idx++;
        }

        when("-msidx") {
          $msidx  = $args[$idx+1];
          $idx++;
        }

        when("-lsidx") {
          $lsidx  = $args[$idx+1];
          $idx++;
        }

        when("-desc") {
          $desc = "";
          $idx++;

          do  {
            $desc = $desc . " " . $args[$idx];

            if($desc  =~  /".*"/) {
              ($desc) = $desc =~ m/"(.*?)"/;
              break;
            } else  {
              $idx++;
            }
          } while ($idx < @args);
        }

        default { print "Unknown argument : $args[$idx]\n"; }
      }
    }

    if(!(defined $name && length $name > 0))  {
      print "field/add>Enter a name for this field\n";
      $name =  <STDIN>;
      chomp($name);
    }

    if(!(defined $reg && length $reg > 0))  {
      print "field/add>Enter the parent register for this field\n";
      $reg =  <STDIN>;
      chomp($reg);
    }

    if(!(defined $acc && length $acc > 0))  {
      print "field/add>Enter the access type for this field [RO,WO,RW]\n";
      $acc =  <STDIN>;
      chomp($acc);
    }

    if(!(defined $desc && length $desc > 0))  {
      print "field/add>Enter the description for this field\n";
      $desc =  <STDIN>;
      chomp($desc);
    }

    if(!(defined $msidx && length $msidx > 0))  {
      print "field/add>Enter the index of the most significant bit of this field\n";
      $msidx  =  <STDIN>;
      chomp($msidx);
    }

    if(!(defined $lsidx && length $lsidx > 0))  {
      print "field/add>Enter the index of the least significant bit of this field\n";
      $lsidx  =  <STDIN>;
      chomp($lsidx);
    }

    if(!addNewField($main::prj_name,$name,$reg,$acc,$msidx,$lsidx,$desc)) {
      print "add/field>ERROR Could not locate register : $reg!!\n";
    }
  }


  sub displayHelp {
    print "\tType 'quit' or 'exit' to exit\n";
    print "\n\tOptions  ->\n";
    print "\t\tproject   <name>\t- Update project name\n";
    print "\t\tcreate    <name>\t- Create blank xml database with [optional]project name\n";
    print "\t\tdisplay   <name>\t- Display contents of xml database with [optional]name\n";
    print "\t\tdwidth    <size>\t- Update the data width of the regspace\n";
    print "\t\txmlStyle  <name>\t- Change the XML Stylesheet type [xsl,css]\n";
    print "\n\tToo add a register->\n";
    print "\t\tadd reg -name <name> -addr <addr-hex> -desc \"<desription>\"\n";
    print "\n\tToo add a field->\n";
    print "\t\tadd field -name <name> -reg <parent-reg> -acc <access-type[RO,WO,RW]> -msidx <most-significant-bit-index>\n\t\t-lsidx <least-significant-bit-index> -desc \"<desription>\"\n";
  }

  sub parseCommand  {
    my  ($cmd)  = @_;
    my  @cmd_arry = split(/ /, $cmd);

    for(my $idx=0; $idx<@cmd_arry; $idx++)  {
      given($cmd_arry[$idx]) {

        when("add") {
          if($idx+1 ==  @cmd_arry)  { print "What do you want to add??\n";break; }

          my  $type = $cmd_arry[$idx+1];
          my  @args = splice(@cmd_arry, $idx+2);
          #print "arguments:@args\n";

          given($type) {
            when("reg") {
              parseRegArgs(@args);
            }

            when("field"){
              parseFieldArgs(@args);
            }

            default { print "Unknown type : $type\n";return; }
          }

          return;
        }

        when("project") {
          $main::prj_name = $cmd_arry[$idx+1];
          print "Updated project name to : $main::prj_name\n";
          $idx++;
        }

        when("create")  {
          if($idx+1 < @cmd_arry)  {
            $main::prj_name = $cmd_arry[$idx+1];
            print "Updated project name to : $main::prj_name\n";
            $idx++;
          }

          if($main::xmlStyle  eq  'xsl')  {
            print "Creating blank xsl file : $main::prj_name.xsl\n";
            createXSL("$main::prj_name");
          } elsif($main::xmlStyle eq  'css')  {
            print "Creating blank css file : $main::prj_name.css\n";
            createCSS("$main::prj_name");
          } else  {
            print "Unknown XML Stylesheet : $main::xmlStyle\n";
            return;
          }

          print "Creating blank xml file : $main::prj_name.xml\n";
          newREGMAP("$main::prj_name",$main::regmapVer,$main::dwidth,$main::xmlStyle);
        }

        when("display") {
          my  $tmp_prj = $main::prj_name;

          if($idx+1 < @cmd_arry)  {
            $tmp_prj = $cmd_arry[$idx+1];
            $idx++;
          }
          
          displayREGMAP("$tmp_prj");
        }

        when("dwidth") {
          $main::dwidth = $cmd_arry[$idx+1];
          print "Updated dwidth to : $main::dwidth\n";
          $idx++;
        }

        when("xmlStyle") {
          $main::xmlStyle = $cmd_arry[$idx+1];
          print "Updated xmlStyle to : $main::xmlStyle\n";
          $idx++;
        }

        default { print "Unknown command : $cmd_arry[$idx]\n"; }
      }
    }
  }

  # ------------------------  Main execution block  -------------
  # Comment this section if using as lib/.pm file
  
  displayGreet();

  for(;;) { # Main loop
    print "$main::prompt";

    $main::input  = <STDIN>; # Read user input
    chomp($main::input);

    given($main::input) {
      when("quit")  {
        print "Exiting regmap ...\n";
        exit;
      }

      when("exit")  {
        print "Exiting regmap ...\n";
        exit;
      }

      when("help")  {
        displayHelp();
      }

      default {
        parseCommand($main::input);
      }
    }

  }


  exit;
  # -------------------------------------------------------------
  
 1;
