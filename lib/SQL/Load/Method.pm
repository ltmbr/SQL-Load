package SQL::Load::Method;

use strict;
use warnings;
use SQL::Load::Util qw/
    parse
    name_list
/;

sub new {
    my ($class, $content) = @_;
    
    my @data = parse($content);
    my %hash = @data;
    my %keys;
    my @list;
    
    for (my $i = 0; $i < scalar(@data); $i += 2) {
        my $name = $data[$i];
        my @name_list = name_list($name);
        
        for (@name_list) {
            $keys{$_} = $name;
        }
        
        push(@list, $data[$i + 1]);
    }    
    
    my $self = {
        _hash => \%hash,
        _keys => \%keys,
        _list => \@list,
        _next => 0
    };
    
    return bless $self, $class;
}

sub default {
    my $self = shift;
    
    return $self->{_hash}->{default} if exists $self->{_hash}->{default};
    return $self->{_list}->[0]       if exists $self->{_list}->[0];
    
    return;
}

sub name {
    my ($self, $name) = @_;
    
    my $real = exists $self->{_keys}->{$name} ? $self->{_keys}->{$name} : $name;   
                      
    return $self->{_hash}->{$real} if exists $self->{_hash}->{$real};
    
    return;
}

sub next {
    my $self = shift;
    
    if (defined $self->{_next}) {
        my $next = $self->{_next}++;
        
        return $self->{_list}->[$next] if exists $self->{_list}->[$next];
        
        $self->{_next} = undef;
    }
    
    return;
}

sub at {
    my ($self, $index) = @_;
    
    return $self->{_list}->[$index - 1] if exists $self->{_list}->[$index - 1];
    
    return;
}

sub first {
    my $self = shift;
    
    return $self->{_list}->[0];
}

sub last {
    my $self = shift;
    
    return $self->{_list}->[scalar(@{$self->{_list}})];
}

sub replace {
    my $self = shift;
    
    my %replace = @_;
    
    for my $name (keys %replace) {
        my $value = $replace{$name};
        
        # replace in hash
        for my $key (keys %{$self->{_hash}}) {
            $self->{_hash}->{$key} =~ s/${name}/${value}/g;
        }
        
        # replace in list
        for (my $i = 0; $i < scalar(@{$self->{_list}}); $i++) {
            $self->{_list}->[$i] =~ s/${name}/${value}/g;
        }
    }
    
    return $self;
}

1;
