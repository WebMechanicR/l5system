<?php
/**
 * класс для отправки почты
 * @author riol
 *
 */
class Mail extends System {

	public function __construct() {
		parent::__construct();
		/**
		 * подключаем необходимые файлы
		 */
		require_once dirname(__FILE__).'/external/PHPMailer/class.phpmailer.php';
	}

	/**
	 * отправляет письмо
	 * @param array $to = array(email, имя)
	 * @param string $subject
	 * @param string $html_mail
	 */
	public function send_mail($to, $subject, $html_mail) {
		$mail = new PHPMailer(); // defaults to using php "mail()"
		$mail->SetFrom($this->settings->site_email, $this->settings->site_title);
		$mail->AddReplyTo($this->settings->site_email, $this->settings->site_title);
		$mail->AddAddress($to[0], $to[1]);
		$mail->Subject    = $subject;
		$mail->MsgHTML($html_mail);
		$mail->Send();
	}
	
}