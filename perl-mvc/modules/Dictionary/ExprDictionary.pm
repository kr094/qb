package ExprDictionary;
use Dictionary;
use Trim;
use Data::Dumper;

sub new {
	return bless {
		expr => [],
		dict => new Dictionary()
	}, shift;
}

sub add {
	my $expr_dict = shift;
	my $equality = Trim::trim(shift);
	my $field = Trim::trim(shift);
	my $value = Trim::trim(shift);
	
	my $expr_set = $expr_dict->{expr};
	my $dict = $expr_dict->{dict};
	
	if(!defined $expr) {
		$expr = '';
	}
	
	push(@$expr_set, $equality);
	$dict->push_dictionary($field, $value);
}

sub build_from_hash {
	my $dict = shift;
	my $query = shift;
	my $value;
	
	for(keys $query) {
		$value = $query->{$_};
		$dict->add($_, $value);
	}
}

sub print {
	my $ed = shift;
	my $expr_set = $ed->{expr};
	my $dict = $ed->{dict};
	my $field_set = $dict->{field};
	my $value_set = $dict->{value};
	my $expr = '';
	my $field = '';
	my $value = '';
	my $print = '';
	
	print Dumper($ed);
	
	for(0 .. $#$expr_set) {
		$expr = $expr_set[$_];
		$field = $field_set[$_];
		$value = $value_set[$_];
		$print .= "$field $expr $value";
	}
	
	return $print;
}

return 1;
