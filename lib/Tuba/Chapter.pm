=head1 NAME

Tuba::Chapter : Controller class for chapters.

=cut

package Tuba::Chapter;
use Mojo::Base qw/Tuba::Controller/;
use Tuba::DB::Objects qw/-nicknames/;

sub list {
    my $c = shift;
    my $report = $c->stash('report_identifier');
    my $all = $c->param('all');
    my @page = $all ? () : (page => $c->page);
    $c->stash(objects => Chapters->get_objects(query => [ report_identifier => $report ],
             with_objects => [qw/figures findings tables/],
             sort_by => 'chapter.number',
             @page,
         )
    );
    $c->set_pages( Chapters->get_objects_count( query => [ report_identifier => $report ] )) unless $all;
    $c->title('Chapters in report '.$report);
    $c->stash(cols => [
        qw/number identifier report figures findings tables/
        ]);
    $c->SUPER::list(@_);
}

sub show {
    my $c = shift;
    my $identifier = $c->stash('chapter_identifier');
    my $report = $c->stash('report_identifier');
    my $chapter =
      Chapter->new( identifier => $identifier, report_identifier => $report )
          ->load( speculative => 1, with => [qw/figures findings report/] );
    if (!$chapter && $identifier =~ /^\d+$/) {
      $chapter = Chapter->new( number => $identifier, report_identifier => $report )
        ->load( speculative => 1, with => [qw/figures findings report/] );
      if ($chapter) {
        $c->stash(chapter_identifier => $chapter->identifier);
        return $c->redirect_to( $c->current_route, { chapter_identifier => $chapter->identifier } );
      }
    }
    return $c->render_not_found unless $chapter;

    $c->stash(object => $chapter);
    $c->stash(meta => Chapter->meta);
    $c->stash(relationships => [ map Chapter->meta->relationship($_), qw/report figures findings tables/ ]);
    $c->SUPER::show(@_);
}

sub update_rel_form {
    my $c = shift;
    $c->stash(relationships => [ map Chapter->meta->relationship($_), qw/report figures findings tables/ ]);
    $c->stash(controls => {
            figure  => { template => 'one_to_many', },
            finding => { template => 'one_to_many' },
            table   => { template => 'one_to_many' },
        });
    $c->SUPER::update_rel_form(@_);
}

1;

