package EasyWorkflow::L10N::ja;

use strict;
use base 'EasyWorkflow::L10N::en_us';
use vars qw(%Lexicon );

%Lexicon = (
	'NAME' => '簡易ワークフロー',
	'DESCRIPTION' => '簡易な承認フローを実現します。<br />ブログ記事投稿後「承認待ち」を選んで保存すると、あらかじめ指定した承認者のメールアドレスへ通知が届きます。',
	'AUTHOR_NAME' => 'にっく',
	'ACKNOWLEDGER' => '承認者のメールアドレスを指定してください。',
	'MAIL_TITLE' => '承認待ちのブログ記事が投稿されました。',
	'MAIL_PAGE_TITLE' => '承認待ちのウェブページが投稿されました。',
	'TITLE' => 'ブログ記事名',
	'CONTENTS' => '記事内容',
	'LAST_MODIFY' => '最終更新日',
	'ENTRY_AUTHOR' => '記事投稿者',
	'MAIL_SIGNATURE' => 'この投稿はEasyWorkflowプラグインにより投稿されました。',
	);
1;
