/**
 * @license Copyright (c) 2003-2013, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.html or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here. For example:
	// config.language = 'fr';
	// config.uiColor = '#AADC6E';
	
	//config.contentsCss = '/templates/css/all.css';
	//config.extraPlugins = 'mediaembed,stylesheetparser';
	
	config.allowedContent = true;
	config.fillEmptyBlocks = false;
	
	config.toolbar = [
	{ name: 'document', groups: [ 'mode', 'document', 'doctools' ], items: [ 'Source' ] },
	{ name: 'clipboard', groups: [ 'clipboard', 'undo' ], items: [ 'Cut', 'Copy', 'Paste', 'PasteText', 'PasteFromWord', '-', 'Undo', 'Redo' ] },
	{ name: 'editing', groups: [ 'find', 'selection', 'spellchecker' ], items: [ 'Find', 'Replace', '-', 'SelectAll', '-', 'Scayt' ] },
	{ name: 'tools', items: [ 'Maximize', 'ShowBlocks' ] },
	{ name: 'about'},
	'/',
	{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ], items: [ 'Bold', 'Italic', 'Underline', 'Strike', 'Subscript', 'Superscript', '-', 'RemoveFormat' ] },
	{ name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align' ], items: [ 'JustifyLeft', 'JustifyCenter', 'JustifyRight', 'JustifyBlock', '-', 'NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', '-', 'Blockquote', 'CreateDiv', 'Table', 'Iframe', '-',  'SpecialChar', 'PageBreak' , '-', ] },
	'/',
	{ name: 'styles', items: [ /*'Styles',*/ 'Format', 'Font', 'FontSize' ] },
	{ name: 'colors', items: [ 'TextColor', 'BGColor' ] },
	{ name: 'links', items: [ 'Link', 'Unlink', 'Anchor' ] },
	{ name: 'insert', items: [ 'Image', 'Flash', 'MediaEmbed', 'oembed'] }
];


	
	// KCFinder
	config.filebrowserBrowseUrl = admin_url+'kcfinder/browse.php?type=files';
	config.filebrowserImageBrowseUrl = admin_url+'kcfinder/browse.php?type=images';
	config.filebrowserFlashBrowseUrl = admin_url+'kcfinder/browse.php?type=flash';
	config.filebrowserUploadUrl = admin_url+'kcfinder/upload.php?type=files';
	config.filebrowserImageUploadUrl = admin_url+'kcfinder/upload.php?type=images';
	config.filebrowserFlashUploadUrl = admin_url+'kcfinder/upload.php?type=flash';
	// ...
};
