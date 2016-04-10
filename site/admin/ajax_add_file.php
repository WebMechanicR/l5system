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

	if($module and $site->admins->get_level_access($module)==2 and $action and $file = $site->request->files('file')) {
		if(!isset($file['error']) or $file['error']==0) {
			if ($file_name = $site->file->upload_file($file, $file['name'], $site->$module->setting("dir_files"))) {
				$file_id = $site->$module->$action($for_id, $file_name, "", -1);
				if($file_id) {
					$file_size = $site->file->filesize($file_name, $site->$module->setting("dir_files"));
					$file_size = round($file_size/1024,2);
					if($file_size>1000) $file_size = str_replace(",",".",round($file_size/1024,2))." МБ";
					else $file_size = str_replace(",",".", $file_size)." КБ";
					$file_type = pathinfo($file_name, PATHINFO_EXTENSION);
					$result = array("success"=>true, "file_name"=>$file_name, "file_id"=>$file_id, "file_size"=>$file_size, "file_type"=>$file_type);
				}
				else $result = array("error"=>"папка загрузки недоступна для записи или недостаточно места");
			}
			else $result = array("error"=>"папка загрузки недоступна для записи или недостаточно места");
		}
		else $result = array("error"=>"Слишком большой файл");
	}
}

echo json_encode($result);