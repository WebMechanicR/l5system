<?php
/**
 * класс для работы с изображениями
 * @author riol
 *
 */
class Image extends System {
	private	$allowed_extentions = array('png', 'gif', 'jpg', 'jpeg');

	public function __construct()
	{
		parent::__construct();
	}

	public function upload_image($file, $name, $dir)
	{
		$uploaded_file = $new_name = pathinfo($name, PATHINFO_BASENAME);
		$ext = pathinfo($uploaded_file, PATHINFO_EXTENSION);
		if(in_array(strtolower($ext), $this->allowed_extentions))
		{
			$new_name = $this->get_unique_name_image($name, ROOT_DIR_IMAGES.$dir."original/");
			if(@move_uploaded_file($file['tmp_name'], ROOT_DIR_IMAGES.$dir."original/".$new_name)) {
				chmod(ROOT_DIR_IMAGES.$dir."original/".$new_name,0755);
				return $new_name;
			}
			else return null;
		}

		return false;
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
	 * Создает уникальное название файла картинки с помощью транслита и добавления цифр у одинаковых названий
	 * @param string $name исходное название
	 * @param string $dir директория, где будет сохранена картинка
	 * @return $new_name
	 */
	public function get_unique_name_image($name, $dir)
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

	/**
	 * создание изображения нужного размера из загруженного оригинала
	 * @param string $dir - папка с изображениями модуля
	 * @param string $dir_new - папка, куда сохранятется картинка
	 * @param string $image_orig - название оригинального файла
	 * @param string $image - название конечного файла
	 * @param array $image_sizes - ширина, высота, crop, watermark
	 */
	public function create_image($image_orig, $image, $image_sizes) {
		if(USE_IMAGICK and class_exists('Imagick', false))
			return $this->image_constrain_imagick($image_orig, $image, $image_sizes[0], $image_sizes[1], $image_sizes[2], $image_sizes[3]);
		else
			return $this->image_constrain_gd($image_orig, $image, $image_sizes[0], $image_sizes[1], $image_sizes[2], $image_sizes[3]);
	}

	/**
	 * Создание превью средствами gd
	 * @param $src_file исходный файл
	 * @param $dst_file файл с результатом
	 * @param max_w максимальная ширина
	 * @param max_h максимальная высота
	 * @return bool
	 */
	private function image_constrain_gd($src_file, $dst_file, $max_w, $max_h, $crop=false, $watermark=false)
	{
		$quality = 90;

		// Параметры исходного изображения
		@list($src_w, $src_h, $src_type) = array_values(getimagesize($src_file));
		$src_type = image_type_to_mime_type($src_type);

		if(empty($src_w) || empty($src_h) || empty($src_type))
			return false;

		// Нужно ли ресайзить?
		if (!$watermark && ($src_w <= $max_w) && ($src_h <= $max_h))
		{
			// Нет - просто скопируем файл
			if (!copy($src_file, $dst_file))
				return false;
			return true;
		}

		// Размеры превью при пропорциональном уменьшении
		if($crop) {
			$dst_w = $max_w;
			$dst_h = $max_h;
		}
		else @list($dst_w, $dst_h) = $this->calc_contrain_size($src_w, $src_h, $max_w, $max_h);

		// Читаем изображение
		switch ($src_type)
		{
			case 'image/jpeg':
				$src_img = imageCreateFromJpeg($src_file);
				break;
			case 'image/gif':
				$src_img = imageCreateFromGif($src_file);
				break;
			case 'image/png':
				$src_img = imageCreateFromPng($src_file);
				imagealphablending($src_img, true);
				break;
			default:
				return false;
		}

		if(empty($src_img))
			return false;
			
		$src_colors = imagecolorstotal($src_img);

		// create destination image (indexed, if possible)
		if ($src_colors > 0 && $src_colors <= 256)
			$dst_img = imagecreate($dst_w, $dst_h);
		else
			$dst_img = imagecreatetruecolor($dst_w, $dst_h);

		if (empty($dst_img))
			return false;

		$transparent_index = imagecolortransparent($src_img);
		if ($transparent_index >= 0 && $transparent_index < $src_colors)
		{
			$t_c = imagecolorsforindex($src_img, $transparent_index);
			$transparent_index = imagecolorallocate($dst_img, $t_c['red'], $t_c['green'], $t_c['blue']);
			if ($transparent_index === false)
				return false;
			if (!imagefill($dst_img, 0, 0, $transparent_index))
				return false;
			imagecolortransparent($dst_img, $transparent_index);
		}
		// or preserve alpha transparency for png
		elseif ($src_type === 'image/png')
		{
			if (!imagealphablending($dst_img, false))
				return false;
			$transparency = imagecolorallocatealpha($dst_img, 0, 0, 0, 127);
			if (false === $transparency)
				return false;
			if (!imagefill($dst_img, 0, 0, $transparency))
				return false;
			if (!imagesavealpha($dst_img, true))
				return false;
		}
			
		$src_x = $src_y = 0;
		if($crop) {
			$src_x = $src_y = 0;
			$src_w_t = $src_w;
			$src_h_t = $src_h;

			$cmp_x = $src_w_t  / $dst_w;
			$cmp_y = $src_h_t / $dst_h;

			// calculate x or y coordinate and width or height of source

			if ( $cmp_x > $cmp_y ) {
				$src_w = round( ( $src_w_t / $cmp_x * $cmp_y ) );
				$src_x = round( ( $src_w_t - ( $src_w_t / $cmp_x * $cmp_y ) ) / 2 );
			}
			elseif ( $cmp_y > $cmp_x ) {
				$src_h = round( ( $src_h_t / $cmp_y * $cmp_x ) );
				$src_y = round( ( $src_h_t - ( $src_h_t / $cmp_y * $cmp_x ) ) / 2 );
			}
		}

		// resample the image with new sizes
		if (!imagecopyresampled($dst_img, $src_img, 0, 0, $src_x, $src_y, $dst_w, $dst_h, $src_w, $src_h))
			return false;
			
		// Watermark
		if($watermark and ($this->settings->site_watermark and file_exists(ROOT_DIR_IMAGES.'img/big/'.$this->settings->site_watermark)))
		{
			$watermark_file = ROOT_DIR_IMAGES.'img/big/'.$this->settings->site_watermark;
			if(is_readable($watermark_file)) {
                                $watermark_type = getimagesize($watermark_file);
                                $overlay = false;
                                switch($watermark_type[2]){
                                    case IMAGETYPE_JPEG:
                                        $overlay = imagecreatefromjpeg($watermark_file);
                                    break;
                                
                                    case IMAGETYPE_PNG:
                                        $overlay = imagecreatefrompng($watermark_file);
                                    break;
                                }
				
                                if($overlay){
                                    // Get the size of overlay
                                    $owidth = imagesx($overlay);
                                    $oheight = imagesy($overlay);

                                    $watermark_x = min(($dst_w-$owidth), $dst_w);
                                    $watermark_y = min(($dst_h-$oheight), $dst_h);

                                    imagecopy($dst_img, $overlay, $watermark_x, $watermark_y, 0, 0, $owidth, $oheight);
                                }
			}
		}


		// Сохраняем изображение
		$result = false;
		switch ($src_type)
		{
			case 'image/jpeg':
				$result = imageJpeg($dst_img, $dst_file, $quality);
				break;
			case 'image/gif':
				$result = imageGif($dst_img, $dst_file, $quality);
				break;
			case 'image/png':
				imagesavealpha($dst_img, true);
				$result = imagePng($dst_img, $dst_file);
				break;
		}

		@imagedestroy($dst_img);
		@chmod($dst_file,0755);
		return $result;
	}

	/**
	 * Создание превью средствами imagick
	 * @param $src_file исходный файл
	 * @param $dst_file файл с результатом
	 * @param max_w максимальная ширина
	 * @param max_h максимальная высота
	 * @return bool
	 */
	private function image_constrain_imagick($src_file, $dst_file, $max_w, $max_h, $crop=false, $watermark=false)
	{
		$thumb = new Imagick();

		// Читаем изображение
		if(!$thumb->readImage($src_file))
			return false;

		// Размеры исходного изображения
		$src_w = $thumb->getImageWidth();
		$src_h = $thumb->getImageHeight();

		// Нужно ли ресайзить?
		if (!$watermark && ($src_w <= $max_w) && ($src_h <= $max_h))
		{
			// Нет - просто скопируем файл
			if (!copy($src_file, $dst_file))
				return false;
			return true;
		}
			
		// Размеры превью при пропорциональном уменьшении
		if($crop) {
			$dst_w = $max_w;
			$dst_h = $max_h;
		}
		else @list($dst_w, $dst_h) = $this->calc_contrain_size($src_w, $src_h, $max_w, $max_h);

		// Уменьшаем
		if($crop) $thumb->cropThumbnailImage($dst_w, $dst_h);
		else $thumb->thumbnailImage($dst_w, $dst_h);

		// Устанавливаем водяной знак
		if($watermark and ($this->settings->site_watermark and file_exists(ROOT_DIR_IMAGES.'img/big/'.$this->settings->site_watermark)))
		{
			$watermark_file = ROOT_DIR_IMAGES.'img/big/'.$this->settings->site_watermark;
			if(is_readable($watermark_file)) {
				$overlay = new Imagick($watermark_file);
				//$overlay->setImageOpacity(1);
				$overlay_compose = $overlay->getImageCompose();

				// Get the size of overlay
				$owidth = $overlay->getImageWidth();
				$oheight = $overlay->getImageHeight();

				$watermark_x = min(($dst_w-$owidth), $dst_w);
				$watermark_y = min(($dst_h-$oheight), $dst_h);
			}
		}


		// Анимированные gif требуют прохода по фреймам
		foreach($thumb as $frame)
		{
			// Уменьшаем
			$frame->thumbnailImage($dst_w, $dst_h);

			/* Set the virtual canvas to correct size */
			$frame->setImagePage($dst_w, $dst_h, 0, 0);

			if(isset($overlay) && is_object($overlay))
			{
				$frame->compositeImage($overlay, $overlay_compose, $watermark_x, $watermark_y, imagick::COLOR_ALPHA);
			}

		}

		// Убираем комменты и т.п. из картинки
		$thumb->stripImage();

		//		$thumb->setImageCompressionQuality(100);

		// Записываем картинку
		if(!$thumb->writeImages($dst_file, true))
			return false;

		// Уборка
		$thumb->destroy();
		if(isset($overlay) && is_object($overlay))
			$overlay->destroy();
		@chmod($dst_file,0755);
		return true;
	}

	/**
	 * Вычисляет размеры изображения, до которых нужно его пропорционально уменьшить, чтобы вписать в квадрат $max_w x $max_h
	 * @param src_w ширина исходного изображения
	 * @param src_h высота исходного изображения
	 * @param max_w максимальная ширина
	 * @param max_h максимальная высота
	 * @return array(w, h)
	 */
	function calc_contrain_size($src_w, $src_h, $max_w = 0, $max_h = 0)
	{
		if($src_w == 0 || $src_h == 0)
			return false;
			
		$dst_w = $src_w;
		$dst_h = $src_h;

		if($src_w > $max_w && $max_w>0)
		{
			$dst_h = $src_h * ($max_w/$src_w);
			$dst_w = $max_w;
		}
		if($dst_h > $max_h && $max_h>0)
		{
			$dst_w = $dst_w * ($max_h/$dst_h);
			$dst_h = $max_h;
		}
		return array($dst_w, $dst_h);
	}

}