<?php
/**
 * Библиотека основных функций
 */
class Func {

	/**
	 * очищает строку от html тегов
	 * @param string $string
	 * @return string
	 */
	static function clean($string) {
		$string = htmlspecialchars ($string);
		$string = str_replace ("'", "&#39", $string);
		//$string = nl2br($string, false);
		$string = str_replace(array("\r\n", "\r", "\n"), "<br>", $string);
		$string = preg_replace("'\\0'","",$string);
		$string = trim($string);
		return $string;
	}

	/**
	 * возвращает в строку html теги, используется для вывода данных в форму только в панели управления.
	 * @param string $string
	 * @return string
	 */  
	static function unclean($string) {
		$trans = get_html_translation_table(HTML_SPECIALCHARS);
		$trans = array_flip($trans);
		$string = str_replace (array_keys($trans), $trans, $string);
		$string = str_replace ("&#39", "'", $string);
		$string = F::br2nl($string);
		$string = trim($string);
		return $string;
	}
	
	static function unclean2($string) {
		$string = html_entity_decode($string, ENT_QUOTES, "UTF-8");
		return $string;
	}
	
	static function get_html_translation_table_CP1252($type) {
		$trans = get_html_translation_table($type);
		$trans[chr(130)] = '&sbquo;';    // Single Low-9 Quotation Mark
		$trans[chr(131)] = '&fnof;';    // Latin Small Letter F With Hook
		$trans[chr(132)] = '&bdquo;';    // Double Low-9 Quotation Mark
		$trans[chr(133)] = '&hellip;';    // Horizontal Ellipsis
		$trans[chr(134)] = '&dagger;';    // Dagger
		$trans[chr(135)] = '&Dagger;';    // Double Dagger
		$trans[chr(136)] = '&circ;';    // Modifier Letter Circumflex Accent
		$trans[chr(137)] = '&permil;';    // Per Mille Sign
		$trans[chr(138)] = '&Scaron;';    // Latin Capital Letter S With Caron
		$trans[chr(139)] = '&lsaquo;';    // Single Left-Pointing Angle Quotation Mark
		$trans[chr(140)] = '&OElig;';    // Latin Capital Ligature OE
		$trans[chr(145)] = '&lsquo;';    // Left Single Quotation Mark
		$trans[chr(146)] = '&rsquo;';    // Right Single Quotation Mark
		$trans[chr(147)] = '&ldquo;';    // Left Double Quotation Mark
		$trans[chr(148)] = '&rdquo;';    // Right Double Quotation Mark
		$trans[chr(149)] = '&bull;';    // Bullet
		$trans[chr(150)] = '&ndash;';    // En Dash
		$trans[chr(32)] = '&nbsp;';    // En Dash
		$trans[chr(151)] = '&mdash;';    // Em Dash
		$trans[chr(152)] = '&tilde;';    // Small Tilde
		$trans[chr(153)] = '&trade;';    // Trade Mark Sign
		$trans[chr(154)] = '&scaron;';    // Latin Small Letter S With Caron
		$trans[chr(155)] = '&rsaquo;';    // Single Right-Pointing Angle Quotation Mark
		$trans[chr(156)] = '&oelig;';    // Latin Small Ligature OE
		$trans[chr(159)] = '&Yuml;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(177)] = '&plusmn;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(32)] = '&Delta;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(226)] = '&hellip;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(194)] = '&deg;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(194)] = '&frac14;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(194)] = '&deg;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(194)] = '&deg;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(171)] = '&laquo;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(187)] = '&raquo;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(181)] = '&micro;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(32)] = '&ensp;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(120)] = '&times;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(47)] = '&divide;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(183)] = '&middot;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(34)] = '&quot;';    // Latin Capital Letter Y With Diaeresis
		$trans[chr(177)] = '&quot;';    // Latin Capital Letter Y With Diaeresis
		$trans['euro'] = '&euro;';    // euro currency symbol
		ksort($trans);
		return $trans;
	}
	

	/**
	 * преобразует строку в url
	 * @param string $string
	 * @return string
	 */
	static function url($string) {
		$ar_search = array("'", "<", ">", "\r\n");
		$ar_replace = array("&#39", "&lt;", "&gt;", "");
		$string = str_replace ($ar_search, $ar_replace, $string);
		$string = trim($string);
		if (mb_substr($string,0,7)!= "http://" and mb_substr($string,0,8)!= "https://" and mb_strlen($string)>0) $string = "http://".$string;
		return $string;
	}


	/**
	 * проверяет, является ли строка email адресом
	 * @param string $email
	 * @return boolean
	 */
	static function is_email($email) {
		if(preg_match("'^[-\w_\.]+@(.*)\.[a-zA-Z]{2,6}$'",$email)) return true;
		else return false;
	}

	/**
	 * обрезает текст до нужного кол-ва символов
	 * @param string $txt
	 * @param integer $amount
	 * @param string $postfix
	 * @return string
	 */
	static function truncate_txt($txt, $amount, $postfix = "...") {
		$txt = preg_replace('@<script[^>]*?>.*?</script>@si', '', $txt);
		$txt = preg_replace('@<style[^>]*?>.*?</style>@si', '', $txt);
		$txt = strip_tags($txt);
		if ( mb_strlen($txt) <= $amount ) $echo_out = ''; 
		else $echo_out = $postfix;
		if ($echo_out == $postfix) $txt = mb_substr($txt, 0, mb_strrpos(mb_substr($txt, 0, $amount), ' '));
		else $txt = mb_substr($txt, 0, $amount);

		return ($txt . $echo_out);
	}
	
	/**
	 * возвращает правильное окончание у слова после числа (например 4 товара)
	 * @param int $numeric
	 * @param string $many
	 * @param string $one
	 * @param string $two
	 * @return string
	 */
	static function get_right_okonch($numeric, $many, $one, $two) {
		$numeric = (int) abs($numeric);
		if ($numeric % 100 == 1 || ($numeric % 100 > 20) && ( $numeric % 10 == 1 )) return $one;
		if ($numeric % 100 == 2 || ($numeric % 100 > 20) && ( $numeric % 10 == 2 )) return $two;
		if ($numeric % 100 == 3 || ($numeric % 100 > 20) && ( $numeric % 10 == 3 )) return $two;
		if ($numeric % 100 == 4 || ($numeric % 100 > 20) && ( $numeric % 10 == 4 )) return $two;
		return $many;
	}
	
	/**
	 * возвращает строку в транслите
	 * @param string $str
	 * @return string
	 */
	static function translit($str) {
		$str = trim($str);
		$str = mb_strtolower(preg_replace("/[\s]+/ui", '-',$str));
		
		//$str = preg_replace("'[^\w\-_\.]'","",$str);
		$rus_en = array(
				"й"=>"y",
				"ц"=>"ts",
				"у"=>"u",
				"к"=>"k",
				"е"=>"e",
				"н"=>"n",
				"г"=>"g",
				"ш"=>"sh",
				"щ"=>"sh",
				"з"=>"z",
				"х"=>"h",
				"ъ"=>"",
				"ф"=>"f",
				"ы"=>"y",
				"в"=>"v",
				"а"=>"a",
				"п"=>"p",
				"р"=>"r",
				"о"=>"o",
				"л"=>"l",
				"д"=>"d",
				"ж"=>"zh",
				"э"=>"e",
				"я"=>"ya",
				"ч"=>"ch",
				"с"=>"s",
				"м"=>"m",
				"и"=>"i",
				"т"=>"t",
				"ь"=>"",
				"б"=>"b",
				"ю"=>"u",
				" "=>"_",
				"ё"=>"yo",
				";"=>"",
				"%"=>"",
				":"=>"",
				"?"=>"",
				"!"=>"",
				"№"=>"",
				"`"=>"",
				"~"=>"",
				"'"=>"",
				"\""=>"",
				"<"=>"",
				">"=>"",
				"("=>"",
				","=>"",
				")"=>"",
				"/"=>"",
				"\\"=>"",
				"+"=>"",
				"&"=>"_"
		);
		$str = str_ireplace(array_keys($rus_en),$rus_en,$str);
		$str = preg_replace("/[^0-9a-z_-]+/i", '',$str);
		return mb_strtolower($str);
	}
	
	/**
	 * преобразует блок хтмл код с виде (любой embed также) в нужный размер и wmode opaque
	 * @param string $code
	 * @param int $w
	 * @param int $h
	 * @return mixed
	 */
	static function normaliz_video($code, $w, $h) {
		$ar_repl = array(
			'?wmode="opaque"'=> '',
			'wmode="opaque"'=> '',
			'<object'=>'<object wmode="opaque"',
			'<embed'=>'<embed wmode="opaque"',
			'?rel=0'=>''
		);
		$code = str_replace(array_keys($ar_repl),$ar_repl,$code);
		$code = preg_replace('/width=("|\')\d+("|\')/si','width="'.$w.'"',$code);
		$code = preg_replace('/height=("|\')\d+("|\')/si','height="'.$h.'"',$code);
		return preg_replace('/src=("|\')(\S+)("|\')/si','src="$2?wmode=opaque"', $code);
	}
	
	/**
	 * задает iframe требуемый размер
	 * @param string $code
	 * @param int $w
	 * @param int $h
	 * @return mixed
	 */
	static function resize_frame($code, $w, $h) {
		$code = preg_replace('/width=("|\')\d+("|\')/si','width="'.$w.'"',$code);
		$code = preg_replace('/height=("|\')\d+("|\')/si','height="'.$h.'"',$code);
		$code = preg_replace('/width: \d+px/si','width: '.$w.'px',$code);
		$code = preg_replace('/height: \d+px/si','height: '.$h.'px',$code);
		return $code;
	}
	
	/**
	 * функция для отладки, возвращает var_dump обернутый тегами pre
	 * @param mixed $obj
	 */
	static function var_dump($obj) {
		echo "<pre>";
		var_dump($obj);
		echo "</pre>";
	}
	
	/**
	 * убирает из строки урл протокол и завершающие слеши
	 * @param unknown_type $url
	 */
	static function get_url_for_text($url) {
		$ar_url = parse_url($url);
		if($ar_url = parse_url($url)) {
			$str = $ar_url['host'];
			if(isset($ar_url['path'])) $str .= $ar_url['path'];
			return trim($str, "/");
		}
	}
	
	static function br2nl($string)
	{
		return preg_replace('/\<br(\s*)?\/?\>/i', "\n", $string);
	}
	
	
	static function number_format($number) {
		if($number-floor($number)) $number = number_format($number, 2, '.', ' ');
		else $number = number_format($number, 0, '.', ' ');
		return str_replace(" ", "&nbsp;", $number);
	}
	
	static function count_nums_point($number)
	{
		$mantisa = $number-floor($number);
		if($mantisa) return min(2, mb_strlen((string)$mantisa));
		return 0;
	}
	
	static function ucfirst($string, $e ='utf-8') {
		if (function_exists('mb_strtoupper') && function_exists('mb_substr') && !empty($string)) {
			$string = mb_strtolower($string, $e);
			$upper = mb_strtoupper($string, $e);
			preg_match('#(.)#us', $upper, $matches);
			$string = $matches[1] . mb_substr($string, 1, mb_strlen($string, $e), $e);
		} else {
			$string = ucfirst($string);
		}
		return $string;
	}
	
	/**
	 * запретим создавать объекты класса
	 */
	private function __construct() {}

}

/**
 * Класс-алиас
 */
class F extends Func {

}