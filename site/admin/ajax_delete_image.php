<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
// Засекаем время
$time_start = microtime(true);

require_once '../config/config.php';
require_once '../classes/Func.php';
require_once '../classes/System.php';
$site = new System();

session_start();
$result = "error";
if($site->request->isAJAX() and $site->admins->login() ) {
	$module = $site->request->get('module', 'string');
	$module = preg_replace("/[^-_\.A-Za-z0-9]+/", "", $module);
	$action = $site->request->get('action', 'string');
	$action = preg_replace("/[^-_\.A-Za-z0-9]+/", "", $action);
	$id = $site->request->get('id', 'integer');

	if($module == 'settings' and $site->admins->get_level_access($module)==2 and $action == 'delete_watermark'){
		@unlink(ROOT_DIR_IMAGES."img/original/".$site->settings->site_watermark);
		@unlink(ROOT_DIR_IMAGES."img/big/".$site->settings->site_watermark);
		$site->settings->update_settings(array('site_watermark' => ""));
		echo 1;
		exit;
	}

	if($module == 'settings' and $site->admins->get_level_access($module)==2 and $action == 'delete_background'){
		@unlink(ROOT_DIR_IMAGES."img/original/".$site->settings->site_background);
		@unlink(ROOT_DIR_IMAGES."img/big/".$site->settings->site_background);
		$site->settings->update_settings(array('site_background' => ""));
		echo 1;
		exit;
	}

	if($module == 'settings' and $site->admins->get_level_access($module)==2 and $action == 'delete_favicon'){
		@unlink(ROOT_DIR_FILES.$site->settings->favicon);
		$site->settings->update_settings(array('favicon' => ""));
		echo 1;
		exit;
	}
	
	if($module == 'settings' and $site->admins->get_level_access($module)==2 and $action == 'delete_logo'){
		@unlink(ROOT_DIR_IMAGES."img/original/".$site->settings->site_logo);
		@unlink(ROOT_DIR_IMAGES."img/big/".$site->settings->site_logo);
		$site->settings->update_settings(array('site_logo' => ""));
		echo 1;
		exit;
	}

	if($module and $site->admins->get_level_access($module)==2 and $id and $action) {
		$result = $site->$module->$action($id);
	}
}

echo $result;