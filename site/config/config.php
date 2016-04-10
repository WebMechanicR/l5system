<?php
/** The name of the database */
define('DB_NAME', 'l5system_central_server');

/** MySQL database username */
define('DB_USER', 'root');

/** MySQL database password */
define('DB_PASSWORD', '');

/** MySQL hostname */
define('DB_HOST', 'localhost');

/** MySQL table prefix_ */
define('DB_PREFIX_', "");

/** режим отладки */
define('DEBUG_MODE', false);

/** использовать кеш */
define('USE_CACHE', true);

/**
 * тип кеша, если auto, то будет выбран лучший из доступных и настроеный (memcache)
 */
define('CACHE_TYPE', 'file');

/** директория для хранения файлового кеша */
define('CACHE_DIR', dirname(dirname(__FILE__))."/cache/");

/** директория для хранения связей тегов с ключами кэша */
define('CACHE_TAG_DIR', 'tag_storage/');

/** префикс кеша */
define('CACHE_PREFIX', "cs_");

/** соль, уникальная для каждого сайта */
define('SALT', 'NfTlCnJYeYi');

/** директория для хранения изображений */
define('ROOT_DIR_IMAGES', dirname(dirname(__FILE__))."/img/");

/** директория для хранения изображений */
define('ROOT_DIR_FILES', dirname(dirname(__FILE__))."/files/");

/** директория для хранения ceрвисных файлов */
define("ROOT_DIR_SERVICE", dirname(dirname(__FILE__))."/admin/service/");

/** директория для хранения изображений */
define('URL_IMAGES', "img/");

/** директория для хранения файлов */
define('URL_FILES', "files/");

/** обрабатывать изображения с помощью Imagick? Иначе GD */
define('USE_IMAGICK', true);

/** директория и файл для Яндекс.Маркет */
define('YML_FILE', dirname(dirname(__FILE__))."/files/yamarket.xml");

/** обработка ошибок в режиме разработки **/ 
define("ERROR_HANDLER_DEVELOPMENT", true);

/**Сервер разработчиков **/

define("DEVELOPMENT_SERVER_ADDRESS", "http://promocontrol/ajax/reciever.php");

/**Ключ лицензии **/
define("LICENSE_KEY", "Skipped connection.");

/**
 * Настройка memcache
 */
 /*
$CONFIG['memcache']['servers'][0]['host'] = 'localhost';
$CONFIG['memcache']['servers'][0]['port'] = '11211';
$CONFIG['memcache']['servers'][0]['persistent'] = true;
$CONFIG['memcache']['compression'] = true;
*/

$CONFIG['product_statuses'] = array("Доступен к заказу", "По запросу", "Снят с производства", "В разработке", "Поставка прекращена");
$CONFIG['order_statuses'] = array(
			0=>array(
					"name"=>"ожидает обработки",
					"name_admin"=>"новый",
					"percent"=>0
					),
			1=>array(
					"name"=>"заказ в обработке",
					"name_admin"=>"в обработке",
					"percent"=>20
					),
			2=>array(
					"name"=>"выполнен",
					"name_admin"=>"выполнен",
					"percent"=>100
					),
			3=>array(
					"name"=>"заказ отменен",
					"name_admin"=>"отменен",
					"percent"=>0
					)
		);
		
//include 'yandex_regions.php';
$CONFIG['yandex_regions'] = array();//&$yandex_regions;

$CONFIG['news_sources'] = array('investing.com');