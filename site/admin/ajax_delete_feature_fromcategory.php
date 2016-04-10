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
if($site->request->isAJAX() and $site->admins->login() and $site->admins->get_level_access("catalog")==2) {
	$category_id = $site->request->get('category_id', 'integer');
	$feature_id = $site->request->get('feature_id', 'integer');
	
	if($category_id>0 and $feature_id>0) {
		$result = $site->catalog->delete_feature_category($feature_id, $category_id);
	}
}

echo $result;