<?php

require_once(dirname(__FILE__)."/external/securimage/securimage.php");
 
class Captcha extends System{
	
	private $securimage;

	public function __construct(){
		parent::__construct();
		$this->securimage = new Securimage;
	}
	
	public function ShowHtml($name = "anyNameOfCaptcha"){
		$this->tpl->add_var('anyNameOfCaptcha', $name);
		$this->tpl->display('captcha');
	}
	
	public function Check($name = "anyNameOfCaptcha"){
		$method = $this->request->method();
		$captchaCode = $this->request->$method($name, 'string');
		$result = $this->securimage->check($captchaCode);
		if(!$result)
			$this->tpl->add_var('captchaError', true);
		return $result;
	}
}