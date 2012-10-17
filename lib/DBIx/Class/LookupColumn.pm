package DBIx::Class::LookupColumn;
use base DBIx::Class::LookupColumn::LookupColumnComponent;


=head1 NAME

DBIx::Class::LookupColumn - DBIx::Class components to help using Lookup tables.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

L<DBIx::Class::LookupColumn::Auto> is probably what you need to apply this system on your schema.

 # User table with columns user_id, name, and user_type_id (foreign_key to UserType Lookup table)
 package MySchema::Result::User;
 __PACKAGE__->table("user");
 __PACKAGE__->add_columns( "user_id",{}, "name", {}, "user_type_id", {} );
 __PACKAGE__->belongs_to( "UserType" => "Schema3::Result::UserType", {"user_type_id" => "self.user_type_id"} );

 # UserType Lookup table, with 2 columns (user_type_id, name) with rows: ( 1 => 'Administrator' , 2 => 'User' , 3 => 'Guest' )

 # $user is a DBIx::Class::Row instance, e.g. $user=$schema->resultset('User')->find( name => 'Flash Gordon' )
 
 print $user->type; # print 'Administrator', not very impressive, could be written as $user->user_type()->name()
 print $user->type; # same thing, but we are sure that no database request is done thanks to the cache system
 
 print $user->is_type('Administrator')  ? 'Ok' : 'Access Restricted';
 # equivalent (but more efficient) to
 my $type = $schema->resultset('UserType')->find( name => 'Administrator')
   or die "Bad name 'Administrator' for Lookup table UserType";
 print $user->user_type_id eq $type->id  ? 'Ok' : 'Access Restricted';
 
 $user->set_type('User');
 # equivalent (but more efficient) to
 my $type = $schema->resultset('UserType')->find( name => 'User') or die "Bad name 'User' for Lookup table UserType";
 $user->user_type_id( $type->id );
 
 my @users = $schema->resultset('User')->all; # suppose there are 1000 users
 
 # how many database requests: at most one !
 # and if you mispelled 'Administrator' the code would die with a meaningful error message
 foreach my $user (@users) {
     print $user->name, " has admin rights\n" if $user->is_type('Administrator');
 }

=head1 DESCRIPTION

The objective of this module is to bring efficient and convenient methods for dealing with B<Lookup Tables>. 
We call Lookup tables tables that are actually catalogs of terms. 

A good example is the table UserType in the L<Synopsis>, 
that describles all the possible values for the user types. A normalized database has usually lots of such Lookup tables.
This is a good database design practice, basically avoiding using hard_coded strings in your database tables.
Unfortunately it tends to either moving the problem in your code by using hard-coded strings such as 'Administrator'
, or to complexifying your code.

This module tries to solve this problem by allowing the developer to use strings instead of IDs in his code
to increase readability (e.g. using 'Administrator' instead of the corresponding ID) without sacrificing performance
nor safety, thanks to the cache (see L<DBIx::Class::LookupColumn::Manager> ) and the constant value checking.

It works in a lazy slurpy way: the first time a Lookup table value is needed, the whole table is read and stored in 
the cache (see L<DBIx::Class::LookupColumn::Manager>).
The  L<DBIx::Class::LookupColumn::LookupColumnComponent> allows to generate accessors for convenience.
The  L<DBIx::Class::LookupColumn::Auto> allows to quickly add those accessors for all your tables.


=head1 Lookup Tables

What we call B<Lookup Tables>, as stated above, are catalogs of terms, hard-coded values.
This a quite fuzzy definition, and in our understanding these kinds of tables are also usually I<small> 
and I<stable>, making perfect candidates for caching.

The idea of this modules came when using a database schema with dozens of tables called PermissionType, UserType, DocumentType
each with less than 10 values. Using DBIx::Class objects, this leaded to very inefficient database queries.
Using this module solved this problem, and we hope it could be useful to others.


=head1 CAVEATS

Do not use this module on I<big> tables, it could actually slow down your code and eat all your memory.

=cut

1; # End of DBIx::Class::LookupColumn
