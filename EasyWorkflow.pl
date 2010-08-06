package MT::Plugin::EasyWorkflow;
use strict;
use MT;
use MT::Mail;
use MT::Plugin;

require MT::Plugin;

our $VERSION = '0.5';

use base qw( MT::Plugin );

@MT::Plugin::EasyWorkflow::ISA = qw(MT::Plugin);
my $cfg = MT::ConfigMgr->instance;

my $plugin = new MT::Plugin::EasyWorkflow({
    id => 'EasyWorkflow',
    key => 'easyworkflow',
    name => '<MT_TRANS phrase="NAME">',
    author_name => '<MT_TRANS phrase="AUTHOR_NAME">',
    author_link => 'http://smallworld.west-tokyo.com',
    doc_link => 'http://smallworld.west-tokyo.com/200811/easyworkflow.html',
    description =>  '<MT_TRANS phrase="DESCRIPTION">',
    l10n_class => 'EasyWorkflow::L10N',
    blog_config_template => 'mailconfig.tmpl',
	settings => new MT::PluginSettings([
		['post_mail_address'],
	]),
    'version' => $VERSION,
});

MT->add_plugin($plugin);

sub init_registry {
    my $plugin = shift;
    $plugin->registry({
        callbacks => {
            'template_param.edit_entry'
                => \&_set_status_review,
            'template_source.list_entry'
                => \&_add_list_status,
            'template_source.edit_entry'
                => \&_replace_template,
            'cms_post_save.entry'
            	=> \&_post_save_entry,
            'cms_post_save.page'
            	=> \&_post_save_entry,
                
        },
   });
}

sub is_mt4 {
    my $plugin = shift;
    my $version = MT->version_number;
    return substr($version, 0, 1) eq '4' ? 1 : 0;
}

sub instance { $plugin; }

sub post_mail_address {
    my $plugin = shift;
    my ($blog_id) = @_;
    my %param;
    $plugin->load_config(\%param, 'blog:'.$blog_id);
    $param{post_mail_address};
}

sub _set_status_review {
    my ($cb, $app, $param) = @_;
    $param->{'status_reviactive'} = 1;
    if ($param->{'status'} == MT::Entry::REVIEW) {
        $param->{'status_review'} = 1;
    }
}

sub _add_list_status {
    my ($cb, $app, $tmpl) = @_;
    my $opt = '<option value="1"><__trans phrase="Unpublished (Draft)"></option>';
    $opt .= '<option value="3"><__trans phrase="Unpublished (Review)"></option>';
    $$tmpl =~ s/<option\svalue="1"><__trans\sphrase="unpublished"><\/option>/$opt/g;
}


sub _replace_template {



    my ($eh, $app, $tmpl_ref) = @_;

    my $old;
    my $new;

## 

    if (is_mt4()) {

    $old = <<'HTML';
            <mt:else>
                <mt:if name="can_publish_post">
HTML
    $new = <<"HTML";
            <mt:else>
                 <mt:unless name="can_edit_all_posts">
HTML
    $old = quotemeta($old);
    $$tmpl_ref =~ s!$old!$new!;    
    
    
    $old = <<'HTML';
                                <option value="1"<mt:if name="status_draft"> selected="selected"</mt:if>><__trans phrase="Unpublished (Draft)"></option>
                                <option value="2"<mt:if name="status_publish"> selected="selected"</mt:if>><__trans phrase="Published"></option>
                    <mt:if name="status_review">
                                <option value="3" selected="selected"><__trans phrase="Unpublished (Review)"></option>
HTML
    $new = <<"HTML";
                                <option value="1"<mt:if name="status_draft"> selected="selected"</mt:if>><__trans phrase="Unpublished (Draft)"></option>
                    <mt:if name="status_reviactive">
                                <option value="3"<mt:if name="status_review"> selected="selected"</mt:if>><__trans phrase="Unpublished (Review)"></option>
                    </mt:if>
                            </select>
                <mt:elseif name="can_edit_all_posts">
                            <select name="status" id="status" class="full-width" tabindex="9" onchange="highlightSwitch(this)">
                                <option value="1"<mt:if name="status_draft"> selected="selected"</mt:if>><__trans phrase="Unpublished (Draft)"></option>
                                <option value="2"<mt:if name="status_publish"> selected="selected"</mt:if>><__trans phrase="Published"></option>
                    <mt:if name="status_reviactive">
                                <option value="3"<mt:if name="status_review"> selected="selected"</mt:if>><__trans phrase="Unpublished (Review)"></option>
HTML
    $old = quotemeta($old);
    $$tmpl_ref =~ s!$old!$new!;    

    $old = <<'HTML';
                    <mt:if name="nobject">
                            <input type="hidden" name="status" id="status" value="1" /><span><__trans phrase="Unpublished"></span>
                    <mt:else>
                        <mt:if name="status_draft">
                            <input type="hidden" name="status" id="status" value="1" /><span><__trans phrase="Unpublished (Draft)"></span>
                        <mt:else name="status_publish">
                            <input type="hidden" name="status" id="status" value="2" /><span><__trans phrase="Published"></span>
                        <mt:else name="status_future">
                            <input type="hidden" name="status" id="status" value="4" /><span><__trans phrase="Scheduled"></span>
                        <mt:else name="status_review">
                            <input type="hidden" name="status" id="status" value="3" /><span><__trans phrase="Unpublished (Review)"></span>
HTML

    $new = <<"HTML";
                    <mt:if name="nobject">
                          <select name="status" id="status" class="full-width" tabindex="9" onchange="highlightSwitch(this)">
                                <option value="1"<mt:if name="status_draft"> selected="selected"</mt:if>><__trans phrase="Unpublished (Draft)"></option>
                                 <option value="3"<mt:if name="status_review"> selected="selected"</mt:if>><__trans phrase="Unpublished (Review)"></option>
							</select>
                    <mt:else>
                        <mt:if name="status_draft">
                          <select name="status" id="status" class="full-width" tabindex="9" onchange="highlightSwitch(this)">
                                <option value="1"<mt:if name="status_draft"> selected="selected"</mt:if>><__trans phrase="Unpublished (Draft)"></option>
                                 <option value="3"<mt:if name="status_review"> selected="selected"</mt:if>><__trans phrase="Unpublished (Review)"></option>
							</select>
                        <mt:else name="status_publish">
                            <input type="hidden" name="status" id="status" value="2" /><span><__trans phrase="Published"></span>
                        <mt:else name="status_future">
                            <input type="hidden" name="status" id="status" value="4" /><span><__trans phrase="Scheduled"></span>
                        <mt:else name="status_review">
                          <select name="status" id="status" class="full-width" tabindex="9" onchange="highlightSwitch(this)">
                                <option value="1"<mt:if name="status_draft"> selected="selected"</mt:if>><__trans phrase="Unpublished (Draft)"></option>
                                 <option value="3"<mt:if name="status_review"> selected="selected"</mt:if>><__trans phrase="Unpublished (Review)"></option>
							</select>
HTML
    $old = quotemeta($old);
    $$tmpl_ref =~ s!$old!$new!;  

    $old = <<'HTML';
                        </mt:if>
                    </mt:if>
                </mt:if>
            </mt:unless>
HTML

    $new = <<"HTML";
                        </mt:if>
                    </mt:if>
                </mt:unless>
            </mt:unless>
HTML
    $old = quotemeta($old);
    $$tmpl_ref =~ s!$old!$new!;  

	}
	
	else{
	
	
	$old = <<"HTML";
    <mt:setvar name="draft_button_text" value="<__trans phrase="Save Draft">">
    <mt:setvarblock name="draft_button_title"><__trans phrase="Draft this [_1]" params="<mt:var name="object_label">" escape="html"></mt:setvarblock>
HTML

	$new = <<HTML;
    <mt:setvar name="draft_button_text" value="<__trans phrase="Save Draft">">
    <mt:setvarblock name="draft_button_title"><__trans phrase="Draft this [_1]" params="<mt:var name="object_label">" escape="html"></mt:setvarblock>
    <mt:setvar name="review_button_text" value="<__trans phrase="Review">">
    <mt:setvarblock name="review_button_title"><__trans phrase="Review this [_1]" params="<mt:var name="object_label">" escape="html"></mt:setvarblock>
HTML

    $old = quotemeta($old);
    $$tmpl_ref =~ s!$old!$new!;    

	$old = <<"HTML";
<mt:if name="can_publish_post">
        <button
            mt:mode="save_entry"
            name="status"
            type="submit"
            title="<mt:var name="button_title">"
            class="publish action primary-button"
            value="2"
            ><mt:var name="button_text"></button>
HTML

	$new = <<HTML;
<mt:if name="can_manage_pages">
        <button
            mt:mode="save_entry"
            name="status"
            type="submit"
            title="<mt:var name="button_title">"
            class="publish action primary-button"
            value="2"
            ><mt:var name="button_text"></button>
        <button
            mt:mode="save_entry"
            name="status"
            type="submit"
            title="<mt:var name="review_button_title">"
            class="review action primary-button"
            value="3"
            ><__trans phrase="Review"></button>
HTML

    $old = quotemeta($old);
    $$tmpl_ref =~ s!$old!$new!;    
    
	$old = <<"HTML";
<mt:else>
    <mt:if name="new_object">
        <button
            mt:mode="save_entry"
            name="status"
            type="submit"
            title="<__trans phrase="Draft this [_1]" params="<mt:var name="object_label">" escape="html">"
            class="save draft action primary-button"
            value="1"
            ><__trans phrase="Save Draft"></button>
HTML

	$new = <<HTML;
<mt:else>
    <mt:if name="new_object">
        <button
            mt:mode="save_entry"
            name="status"
            type="submit"
            title="<mt:var name="review_button_title">"
            class="review action"
            value="3"
            ><mt:var name="review_button_text"></button>
HTML

    $old = quotemeta($old);
    $$tmpl_ref =~ s!$old!$new!;    


	$old = <<"HTML";
    <mt:else>
        <button
            mt:mode="save_entry"
            name="status"
            type="submit"
            title="<__trans phrase="Update this [_1]" params="<mt:var name="object_label">" escape="html">"
            class="update action primary-button"
            ><__trans phrase="Update"></button>
HTML

	$new = <<HTML;
    <mt:else>
        <button
            mt:mode="save_entry"
            name="status"
            type="submit"
            title="<__trans phrase="Update this [_1]" params="<mt:var name="object_label">" escape="html">"
            class="update action primary-button"
            ><__trans phrase="Update"></button>
        <button
            mt:mode="save_entry"
            name="status"
            type="submit"
            title="<mt:var name="review_button_title">"
            class="review action"
            value="3"
            ><mt:var name="review_button_text"></button>
HTML

    $old = quotemeta($old);
    $$tmpl_ref =~ s!$old!$new!;    

    
    $old = <<'HTML';
    jQuery('button.draft').click(function(event) {
        jQuery('form#entry_form > input[name=status]').val(1);
    });
HTML
    $new = <<'HTML';
    jQuery('button.draft').click(function(event) {
        jQuery('form#entry_form > input[name=status]').val(1);
    });
    jQuery('button.review').click(function(event) {
        jQuery('form#entry_form > input[name=status]').val(3);
    });
HTML

    $old = quotemeta($old);
    $$tmpl_ref =~ s!$old!$new!;  
    
	}

}

sub _post_save_entry {
    my ($eh, $app, $obj, $original) = @_;

    require MT::Entry;
    require MT::Page;
    require MT::Author;
    require MT::Plugin;
    
    if( $obj->status == 3 ){
      my $entry_subject = $plugin->translate('MAIL_TITLE');
      my $page_subject = $plugin->translate('MAIL_PAGE_TITLE');
      my $subject;
      my $id = $obj->id;
      my $blog_id = $obj->blog_id;
	  my $base = $app->base;
	  my $path = $app->path;
	  my $script = $app->script;
      my $post_mail_address = $plugin->post_mail_address($blog_id);
      my $class = $obj->class;
      my $return_uri =$app->param('entry_title');
      my $uri = $base. $path .$script."?__mode=view&_type=".$class."&blog_id=".$blog_id."&id=".$id;
      my $title = $obj->title;
      my $text = $obj->text;
      my $modified = $obj->modified_on;
      my $author_id = $obj->author_id;
      my $author = MT::Author->load($author_id);
      my $author_name = $author->name;
      my $author_email = $author->email;
      my $from = $author_name."<".$author_email.">";
      my $entry_title = $plugin->translate('TITLE');
      my $entry_content = $plugin->translate('CONTENTS');
      my $entry_id = $obj->id;
      my $entry_last_modify = $plugin->translate('LAST_MODIFY');
      my $entry_writer = $plugin->translate('ENTRY_AUTHOR');
      my $mail_signature = $plugin->translate('MAIL_SIGNATURE');
      my $body = <<EOF;
$entry_title:$title

--
$uri

--

$entry_content:
--
$text

--


$entry_last_modify:$modified

$entry_writer:$author_name

--------------------------------------------
$mail_signature
--------------------------------------------
EOF

	if($class eq 'entry'){
	
	$subject = $entry_subject;
	
	} else {
	
	$subject = $page_subject;
	
	}
	
      my %head = ( To => $post_mail_address , Subject => $subject, From => $from);
      MT::Mail->send(\%head, $body);
  }
}

1;
