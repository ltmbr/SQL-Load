package SQL::Load::Util;

use strict;
use warnings;
use String::CamelCase qw/
    camelize 
    decamelize
/;
use base qw/Exporter/;
 
our @EXPORT_OK = qw/
    name_list
    parse
    remove_extension
    trim
/;

sub name_list {
    my $name = shift;
    
    my @list;
    
    $name = remove_extension($name);
    
    $name =~ s/-/_/xg;
    push @list, camelize $name;
    
    $name = decamelize $name;
    push @list, $name;
    
    $name =~ s/_/-/xg;
    push @list, $name;
    
    return wantarray ? @list : \@list;    
}

sub parse {
    my $content = shift;
    
    # get all sql by name
    my (@data) = $content =~ /--\s*(?:#|\[|\()\s*([\w-]+)\s*(?:|]|\))\n([^;]+;)/g;
    
    # get all sql without name
    unless (@data) {
        my (@list) = $content =~ /([^;]+;)/g;
        
        my $num = 1;
        for my $sql (@list) {
            push(@data, $num++);
            push(@data, trim($sql));
        }
        
        # if got one or nothing, set content as default
        unless (@data) {            
            push(@data, 'default');
            push(@data, trim($content));
        }        
    }
    
    return wantarray ? @data : \@data;    
}

sub remove_extension {
    my $value = shift;
    
    $value =~ s/\.sql$//i if $value;
    
    return $value;
}

sub trim {
    my $value = shift;
    
    $value =~ s/^\s+|\s+$//g;
    
    return $value;
}

1;
