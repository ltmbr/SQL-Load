use Test::More;
use SQL::Load::Util qw/
    name_list
    parse
    remove_extension
    trim
/;

my $sql_1 = q{
-- #foo
SELECT * FROM foo;

-- [bar]
SELECT * FROM bar;

-- (baz)
SELECT * FROM baz;
};

my %parse_1 = (parse($sql_1));

for my $name (keys %parse_1) {
    my $value = $parse_1{$name};

    like($name, qr/(foo|bar|baz)/, 'Test name ' . $name . ' from parse');
    like($value, qr/SELECT \* FROM (foo|bar|baz);/, 'Test value ' . $name . ' from parse');
}

my $sql_2 = q{
SELECT * FROM foo;

SELECT * FROM bar;

SELECT * FROM baz;
};

my %parse_2 = (parse($sql_2));

for my $number (keys %parse_2) {
    my $value = $parse_2{$number};
    
    like($number, qr/(1|2|3)/, 'Test name ' . $number . ' from parse');
    like($value, qr/SELECT \* FROM (foo|bar|baz);/, 'Test value ' . $number . ' from parse');
}

my $sql_3 = q{
SELECT 
    id,
    name,
    email
FROM 
    users
WHERE
    id = ?
LIMIT 
    1;
};

my %parse_3 = (parse($sql_3));
is($parse_3{1}, trim($sql_3), 'Test if default is same sql');

done_testing;
