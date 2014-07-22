use strict;
use warnings;
use Time::HiRes qw(time);

use lib('../modules/QueryBuilder');
use QueryBuilder;

my $q = new QueryBuilder();

sub test_select {
	$q->select('data, data, data');		
	return test('select');
}

sub test_where {
	$q->where('data >=', 23)
		->where(1, 2, 3, 4)
		->where('kittens', undef)
		->where({hash => 'test'})
		->where({data => 'data', someData => 'newData'})
		->where({hash => 'update'}, {field => 'value'}, 'data', 'newData');
	return test('where');
}

sub test {
	my $which_hash = shift;	
	return $q->{$which_hash}->print();
}

sub run_test {
	my $start = time();
	my $test_result = 
	"Testing Query\n" 
	.$q->query() ."\n"
	."Testing Select\n"
	.test_select() ."\n"
	."Testing Where\n"
	.test_where() ."\n"
	."Completed in "
	.sprintf("%.2f", time() - $start)
	."ms";
	return $test_result;
}

print run_test();
