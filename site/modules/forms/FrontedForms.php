<?php
/**
 * класс отображения форм в пользовательской части сайта
 * @author riol
 *
 */

class FrontedForms extends View {
	
	public function question() {
		/**
		 * ошибки при заполнении формы
		*/
		$errors = array();
		$success = false;

		$form = array();

		if($this->request->method('post') && !empty($_POST)) {
			$form['name'] = $this->request->post('name', 'string');
			$form['email'] = $this->request->post('email', 'string');
			$form['message'] = $this->request->post('message', 'string');
			$last_name = $this->request->post('last_name', 'string');
				

			if(empty($form['name'])) $errors['name'] = 'no_name';
			if(empty($form['email'])) $errors['email'] = 'no_email';
			if(empty($form['message'])) $errors['message'] = 'no_message';
			
			//если поле заполнено - значит робот
			if(!empty($last_name)) $errors['last_name'] = 'no_man';


			if(count($errors)==0) {
				$success = true;
				//отправляем письма админу
				$this->tpl->add_var('form', $form);
				$html_mail_admin = $this->tpl->fetch("mail/forms_question");
				$this->mail->send_mail(array($this->settings->site_email, $this->settings->site_title), "Новый вопрос на ".$this->settings->site_title, $html_mail_admin);
			}
		}

		$this->tpl->add_var('form', $form);
		$this->tpl->add_var('success', $success);
		$this->tpl->add_var('errors', $errors);
		return $this->tpl->fetch("forms_question");
	}
	
	public function index() {
		header("Location: ".SITE_URL);
		exit();
	}
}