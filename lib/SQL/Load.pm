package SQL::Load;

use strict;
use warnings;
use Carp;
use SQL::Load::Util qw/
    name_list 
    remove_extension
/;
use SQL::Load::Method;

our $VERSION = '0.01';

sub new {
    my ($class, $path) = @_;
    
    # valid if path exists
    croak "Path not defined!" unless $path;
    croak "The '$path' path does not exist!" unless -d $path;    
    
    my $self = {
        _path => $path,
        _data => {},
        _keys => {}
    };    
    
    return bless $self, $class;
}

sub load {
    my ($self, $name) = @_;
    
    $name = remove_extension($name);
    
    if ($name && $name =~ /^[\w-]+$/) {
        # check if exist the key to get tmp
        my $key = $self->_key($name);
        
        # check if tmp exists, if true return
        return $self->_get_tmp($key) if $key;
        
        # get name list
        my $name_list = name_list($name);
        
        # get file from name list
        my $file = $self->_find_file($name_list);   
        
        # get content
        my $content = $self->_file_content($file);
        
        # set tmp
        $self->_set_tmp($content, $file, $name_list);
        
        return SQL::Load::Method->new($content);
    }
    
    croak "the name '$name' is invalid!";
}

sub _find_file {
    my ($self, $name_list) = @_;
    
    my $file;
    
    for my $name (@$name_list) {
        my $is_file = $self->{_path} . '/' . $name . '.sql';
        
        if (-e $is_file) {
            $file = $is_file;
            
            last;
        }
        
        last if $file;
    }
    
    return $file if $file;
    
    croak "The file does not exist!";    
}

sub _file_content {
    my ($self, $file) = @_;

    my $content = '';
    
    open FH, '<', $file or croak $!;
    while (<FH>) {
       $content .= $_;
    }
    close FH; 
    
    $content =~ s/^\s+|\s+$//g;
    
    return $content;
}

sub _key {
    my ($self, $name) = @_;
    
    return $self->{_keys}->{$name} if exists $self->{_keys}->{$name};
    
    return;
}

sub _generate_key {
    my @characters = ('0'..'9', 'A'..'Z', 'a'..'z');
    my $x = int scalar @characters;
    my $result = join '', map $characters[rand $x], 1..16;

    return $result;
}

sub _get_tmp {
    my ($self, $key) = @_;
    
    return $self->{_data}->{$key}->{content} 
        if exists $self->{_data}->{$key}->{content};
    
    return;
}

sub _set_tmp {
    my ($self, $content, $file, $name_list) = @_;
    
    # generate new key
    my $key = $self->_generate_key;
    
    # save name => key in tmp keys
    $self->{_keys}->{$_} = $key for @$name_list;
    
    # save data in tmp data
    $self->{_data}->{$key}->{content}   = $content;
}

1;
