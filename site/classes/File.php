<?php
/**
 * класс для работы с файлами
 * @author riol
 *
 */
class File extends System {
	//private	$allowed_extentions = array('png', 'gif', 'jpg', 'jpeg');

	public function __construct()
	{
		parent::__construct();
	}

	public function upload_file($file, $name, $dir, $allowed_extentions=array())
	{
		$uploaded_file = $new_name = pathinfo($name, PATHINFO_BASENAME);
		$ext = pathinfo($uploaded_file, PATHINFO_EXTENSION);


		if(count($allowed_extentions)==0 or in_array(strtolower($ext), $allowed_extentions))
		{
			$new_name = $this->get_unique_name_file($name, ROOT_DIR_FILES.$dir);
			if(@move_uploaded_file($file['tmp_name'], ROOT_DIR_FILES.$dir.$new_name)) {
				chmod(ROOT_DIR_FILES.$dir.$new_name,0755);
				return $new_name;
			}  
			else return null;
		}

		return false;
	}

	public function filesize($file, $dir) {
		return filesize(ROOT_DIR_FILES.$dir.$file);
	}

	private function translit($text)
	{
		$ru = explode('-', "А-а-Б-б-В-в-Ґ-ґ-Г-г-Д-д-Е-е-Ё-ё-Є-є-Ж-ж-З-з-И-и-І-і-Ї-ї-Й-й-К-к-Л-л-М-м-Н-н-О-о-П-п-Р-р-С-с-Т-т-У-у-Ф-ф-Х-х-Ц-ц-Ч-ч-Ш-ш-Щ-щ-Ъ-ъ-Ы-ы-Ь-ь-Э-э-Ю-ю-Я-я");
		$en = explode('-', "A-a-B-b-V-v-G-g-G-g-D-d-E-e-E-e-E-e-ZH-zh-Z-z-I-i-I-i-I-i-J-j-K-k-L-l-M-m-N-n-O-o-P-p-R-r-S-s-T-t-U-u-F-f-H-h-TS-ts-CH-ch-SH-sh-SCH-sch---Y-y---E-e-YU-yu-YA-ya");

		$res = str_replace($ru, $en, $text);
		$res = preg_replace("/[\s]+/ui", '-', $res);
		$res = strtolower($res);
		return $res;
	}

	/**
	 * Создает уникальное название файла с помощью транслита и добавления цифр у одинаковых названий
	 * @param string $name исходное название
	 * @param string $dir директория, где будет сохранена картинка
	 * @return $new_name
	 */
	public function get_unique_name_file($name, $dir)
	{
		// Имя оригинального файла
		$new_name = pathinfo($name, PATHINFO_BASENAME);
		$base = pathinfo($new_name, PATHINFO_FILENAME);
		$ext = pathinfo($new_name, PATHINFO_EXTENSION);


		$base = $this->translit($base);
		$base = preg_replace("/[^0-9a-z_-]+/i", '', $base);
		$new_name = $base.'.'.$ext;


		while(file_exists($dir.$new_name))
		{
			$new_base = pathinfo($new_name, PATHINFO_FILENAME);
			if(preg_match('/-([0-9]+)$/', $new_base, $parts))
				$new_name = preg_replace('/-([0-9]+)$/',"-".($parts[1]+1), $new_base).'.'.$ext;
			else
				$new_name = $base.'-2.'.$ext;
		}

		return $new_name;
	}


}