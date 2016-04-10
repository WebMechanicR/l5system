<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
// Засекаем время
$time_start = microtime(true);

require_once '../config/config.php';
require_once '../classes/Func.php';
require_once '../classes/System.php';
require_once '../classes/AdminView.php';
$site = new AdminView();
echo $site->display();
$site->antivirus->ScanInjectionAlerts();

// Отладочная информация
if(DEBUG_MODE)
{
	$time_end = microtime(true);
	$exec_time = $time_end-$time_start;
	
	$debug = "время генерации: ".round($exec_time, 5)." seconds\r\n";
	if(function_exists('memory_get_peak_usage')) $debug .= "memory peak usage: ".number_format(memory_get_peak_usage())." bytes\r\n";
	
	$debug .= "шаблонов: ".$site->tpl->get_num_templates()."\r\n";
	$debug .= "запросов к базе: ".$site->db->get_num_queries()."\r\n";
	$debug .= "скрытых инклудов: ".System::$num_includs;
	
	if(USE_CACHE) {
		$cahe_info = $site->cache->GetStats();
		$cahe_info_str = "время: ".round($cahe_info['time'], 5)." seconds\r\n";
		$cahe_info_str .= "обращений к кешу: ".$cahe_info['count']."\r\n";
		$cahe_info_str .= "чтений из кеша: ".$cahe_info['count_get']."\r\n";
		$cahe_info_str .= "записей в кеш: ".$cahe_info['count_set'];
		Debug_HackerConsole_Main::out($cahe_info_str, "Cache");
	}
	Debug_HackerConsole_Main::out($debug, "Summary");
}