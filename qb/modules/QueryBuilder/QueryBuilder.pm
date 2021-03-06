package QueryBuilder;
use strict;
use warnings;

use lib('../modules/common', '../modules/Data', '../modules/Dictionary');
use Data::Dumper;
use Data;
use Dictionary;
use ExprDictionary;
use Trim;

sub new {	
	my $_type = shift;
	my $_class = ref $_type || $_type;
	
	my $_self = {
		_data => new Data(),
		_last_call => '',
		query => new Dictionary(),
		where => new ExprDictionary(),
		from => new Dictionary(),
		join => new Dictionary(),
		type => '',
		limit => 0
	};
	
	bless $_self, $_class;
	return $_self;
}

sub build_query {
	my $dict = shift;
	my @split = ();
	my $query = undef;
	my $field = '';
	my $value = '';
	my $ref;
	
	for(@_) {
		$ref = ref;
		if($ref eq 'HASH') {
			$query = $_;
			for(keys $query) {
				$value = $query->{$_};
				$dict->add($_, $value);
			}
		} elsif($ref eq '') {
			for(split_csv($_)) {
				@split = split_alias($_);
				$field = shift @split;
				$value = shift @split;
				$dict->add($field, $value);
			}
		}
	}
}

sub select {
	my $t = shift;
	my $dict = $t->{query};
	$t->{_last_call} = 'select';
	$t->{type} = 'select';
	
	build_query($dict, @_);
	
	return $t;
}

sub from {
	my $t = shift;
	$t->{_last_call} = 'from';
	my $table = shift;
	my $join = shift;
	my $field;
	my $alias;
	my @split = ();
	my $ref;
	
	$ref = ref $table;
	
	if($ref eq 'HASH') {
		for(keys $table) {
			$alias = $table->{$_};
			$t->build_from($_, $alias, $join);
			last;
		}
	} else {
		for(split_csv($table)) {
			@split = split_equality($_, '');
			$field = shift @split;
			$alias = shift @split;
			$t->build_from($field, $alias, $join);
			last;
		}
	}
	
	return $t;
}

sub build_from {
	my $t = shift;
	my $dict = $t->{from};
	my $table = shift;
	my $alias = shift;
	my $join = shift;	
	
	$t->join($join);

	$dict->push_dictionary($table, $alias);	
}

sub join {
	my $t = shift;
	my $join = shift;
	my @join_members = $t->get_join_dict();
	my $dict = $join_members[1];
	
	if(!$join) {
		$join = 'inner';
	}
	
	if($dict->count() == 0) {
		$join = '';
	} else {
		$t->{_last_call} = 'join';
	}
	
	$dict->push_dictionary($join, '');
}

sub where {
	my $t = shift;
	my $last = $t->{_last_call};
	my $dict = undef;
	my @join_members = ();
	my $query = undef;
	my $ref;
	my $field = '';
	my $value = '';
	my $equality = '';
	my $join = '';
	my @split = ();
		
	if($last eq '' || $last eq 'select') {
		$dict = $t->{where};
	} elsif($last eq 'join') {
		@join_members = $t->get_join_dict();
		$dict = $join_members[1];
	} elsif($last eq 'from') {
		return $t;
	}
	
	while(@_) {
		$query = shift;
		$ref = ref $query;
		
		if($ref eq 'HASH') {
			for(keys $query) {
				$value = $query->{$_};
				
				@split = split_equality($_, '=');
				$field = shift @split;
				$equality = shift @split;
				$dict->add($equality, $_, $value);
			}
		} else {		
			$field = $query;
			$value = shift;
			
			@split = split_equality($field, '=');
			$field = shift @split;
			$equality = shift @split;
			$dict->add($equality, $field, $value);
		}
	}
	
	$t->{_last_call} = 'where';
	return $t;
}

sub limit {

}

sub get {

}

sub get_join_dict {
	my $t = shift;
	my $dict = $t->{join};
	my $count = 0;
	my @join_members = ();
	
	$count = $dict->count() - 1;
	if($count > 0 && $t->{_last_call} eq 'join') {
		$dict->add(new Dictionary(), new ExprDictionary());
	}
	
	push(@join_members, $dict->get_field($count));
	push(@join_members, $dict->get_value($count));
	
	return @join_members;
}

sub split_equality {
	my $field = Trim::trim(shift);
	my $default = shift;
	my @split = ();
	
	if(!defined $default || !$default) {
		$default = '';
	}
	
	if($field =~ /\s+/) {
		@split = split(/\s+/, $field, 2);
	} else {
		push(@split, $field, $default);
	}
	
	return @split;
}

sub split_csv {
	my $query = shift;
	my @strings = ();
	
	if($query =~ /\s*,\s+/) {
		@strings = split(/\s*,\s+/, $query);
	} else {
		push(@strings, $query);
	}
	
	return @strings;
}

sub split_alias {
	my $query = shift;
	my @split = ();
	my $field = '';
	my $value = '';
	
	if($query =~ /as/) {
		@split = split(/\s+as\s+/, $query, 2);
		$field = shift @split;
		$value = shift @split;
	} else {
		$field = $query;
	}
	
	@split = ();
	push(@split, $field, $value);
	
	return @split;
}

sub query {
	my $t = shift;
	my $data = $t->{_data};
	$data->query('SELECT SQLITE_VERSION() as version, 1 as version, 2 as version');
	# Very subtle bug. Concatenates a newline and returns a string...
	return $data->get_col('version');
}

return 1;
