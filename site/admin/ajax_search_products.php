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
$result = false;
if($site->request->isAJAX() and $site->admins->login() and $site->admins->get_level_access("catalog")) {
	$query = $site->request->get('query', 'string');
	if(mb_strlen($query)>=1) {
		$not_id = $site->request->get('not_id', 'intval');

		$filter = array("short_query"=>$query, "enabled"=>1);
		if($not_id) $filter['not_id'] = $not_id;
		$list_products = $site->catalog->get_list_products( $filter );
		$products = array();
		foreach($list_products as $product) {
			$products[] = array(
					"value"=>$product['name'],
					"data"=> array(
						"id"=>$product['id'],
						"name"=>$product['name'],
						"img"=>$product['img'],
						"price"=>$product['price']					
					)
					);
		}

		$result['query'] = $query;
		$result['suggestions'] = $products;
	}
}
header("Content-type: application/json; charset=UTF-8");
header("Cache-Control: must-revalidate");
header("Pragma: no-cache");
header("Expires: -1");
echo json_encode($result);