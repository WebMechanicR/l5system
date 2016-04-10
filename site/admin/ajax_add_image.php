<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
// Засекаем время
$time_start = microtime(true);
$_SERVER['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest';

header('Content-type: application/json');

require_once '../config/config.php';
require_once '../classes/Func.php';
require_once '../classes/System.php';
$site = new System();

$session_id = $site->request->post('session_id', 'string');
if($session_id) session_id($session_id);
session_start();

$result = array("error"=>"Ошибка безопасности");
if($site->request->method('post') and !empty($_POST) and $site->admins->login() ) {
	$module = $site->request->post('module', 'string');
	$module = preg_replace("/[^-_\.A-Za-z0-9]+/", "", $module);
	$action = $site->request->post('action', 'string');
	$action = preg_replace("/[^-_\.A-Za-z0-9]+/", "", $action);
	$for_id = $site->request->post('for_id', 'integer');

	if($module and $site->admins->get_level_access($module)==2 and $action and $picture = $site->request->files('file')) {
		if(!isset($picture['error']) or $picture['error']==0) {
			if ($image_name = $site->image->upload_image($picture, $picture['name'], $site->$module->setting("dir_images"))) {
				$image_id = $site->$module->$action($for_id, $image_name, "", -1);
				if($image_id) {
					$result = array("success"=>true, "image"=>$image_name, "image_id"=>$image_id);
				}
				else $result = array("error"=>"папка загрузки недоступна для записи или недостаточно места");
			}
			else $result = array("error"=>"папка загрузки недоступна для записи или недостаточно места");
		}
		else $result = array("error"=>"Слишком большой файл");
	}
}

echo json_encode($result);