package Dist::Zilla::PluginBundle::DOY;
BEGIN {
  $Dist::Zilla::PluginBundle::DOY::VERSION = '0.02';
}
use Moose;
# ABSTRACT: Dist::Zilla plugins for me

use Dist::Zilla;
with 'Dist::Zilla::Role::PluginBundle::Easy';


has dist => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has is_task => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { shift->dist =~ /^Task-/ ? 1 : 0 },
);

has is_test_dist => (
    is      => 'ro',
    isa     => 'Bool',
    lazy    => 1,
    default => sub { shift->dist =~ /^Foo-/ ? 1 : 0 },
);

has github_url => (
    is  => 'ro',
    isa => 'Str',
    lazy => 1,
    default => sub {
        my $self = shift;
        my $dist = $self->dist;
        $dist = lc($dist);
        "git://github.com/doy/$dist.git";
    },
);

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;
    my $args = $class->$orig(@_);
    return { %{ $args->{payload} }, %{ $args } };
};

sub configure {
    my $self = shift;

    if ($self->is_test_dist) {
        $self->add_bundle(
            '@Filter' => { bundle => '@Basic', remove => ['UploadToCPAN'] }
        );
        $self->add_plugins('FakeRelease');
    }
    else {
        $self->add_bundle('@Basic');
    }

    $self->add_plugins(
        'MetaConfig',
        'MetaJSON',
        ['NextRelease' => { format => '%-5v %{yyyy-MM-dd}d' }],
        'CheckChangesHasContent',
        'PkgVersion',
        'PodCoverageTests',
        'PodSyntaxTests',
        'NoTabsTests',
        'EOLTests',
        'CompileTests',
        ['Repository' => { git_remote => $self->github_url, github_http => 0 }],
        ['Git::Check' => { allow_dirty => '' }],
        ['Git::Tag'   => { tag_format => '%v', tag_message => '' }],
        ['BumpVersionFromGit' => { version_regexp => '^(\d+\.\d+)$', first_version => '0.01'}],
    );

    $self->add_plugins($self->is_task ? 'TaskWeaver' : 'PodWeaver');
}


__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__
=pod

=head1 NAME

Dist::Zilla::PluginBundle::DOY - Dist::Zilla plugins for me

=head1 VERSION

version 0.02

=head1 SYNOPSIS

  # dist.ini
  [@DOY]
  dist = Dist-Zilla-PluginBundle-DOY

=head1 DESCRIPTION

My plugin bundle. Roughly equivalent to:

    [@Basic]

    [MetaConfig]
    [MetaJSON]

    [NextRelease]
    format = %-5v %{yyyy-MM-dd}d
    [CheckChangesHasContent]

    [PkgVersion]

    [PodCoverageTests]
    [PodSyntaxTests]
    [NoTabsTests]
    [EOLTests]
    [CompileTests]

    [Repository]
    git_remote = git://github.com/doy/${lowercase_dist}
    github_http = 0

    [Git::Check]
    allow_dirty =
    [Git::Tag]
    tag_format = %v
    tag_message =
    [BumpVersionFromGit]
    version_regexp = ^(\d+\.\d+)$
    first_version = 0.01

    [PodWeaver]

=for Pod::Coverage   configure

=head1 BUGS

No known bugs.

Please report any bugs through RT: email
C<bug-dist-zilla-pluginbundle-doy at rt.cpan.org>, or browse to
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Dist-Zilla-PluginBundle-DOY>.

=head1 SEE ALSO

=over 4

=item *

L<Dist::Zilla>

=item *

L<Task::BeLike::DOY>

=back

=head1 SUPPORT

You can find this documentation for this module with the perldoc command.

    perldoc Dist::Zilla::PluginBundle::DOY

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Dist-Zilla-PluginBundle-DOY>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Dist-Zilla-PluginBundle-DOY>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Dist-Zilla-PluginBundle-DOY>

=item * Search CPAN

L<http://search.cpan.org/dist/Dist-Zilla-PluginBundle-DOY>

=back

=head1 AUTHOR

  Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Jesse Luehrs.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

