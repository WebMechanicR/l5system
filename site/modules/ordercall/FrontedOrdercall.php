<?php
/**
 * класс отображения формы заказа звонка в пользовательской части сайта
 * @author riol
 *
 */

class FrontedOrdercall extends View {
	public function index() {
		$page_url = $this->request->get('page_url', 'string');
		$page_t = $this->pages->get_page_withcache($page_url);
		
		$this->set_meta_title( ($page_t['meta_title']!='' ? $page_t['meta_title'] : $page_t['title']) );
		$this->set_meta_description($page_t['meta_description']);
		$this->set_meta_keywords($page_t['meta_keywords']);

		/**
		 * ошибки при заполнении формы
		*/
		$errors = array();
		$success = false;
		
		$call = array("date_add"=>time(), "is_new"=>1);
		
		if($this->request->method('post') && !empty($_POST)) {
			$call['name'] = $this->request->post('name', 'string');
			$call['subject'] = $this->request->post('subject', 'string');
			$call['phone'] = $this->request->post('phone', 'string');
			$call['besttime'] = $this->request->post('besttime', 'string');
			$call['message'] = $this->request->post('message', 'string');
			$last_name = $this->request->post('last_name', 'string');
			
		
			//if(empty($call['subject'])) $errors['subject'] = 'no_subject';
			if(empty($call['name'])) $errors['name'] = 'no_name';
			if(empty($call['phone'])) $errors['phone'] = 'no_phone';
			//if(empty($call['besttime'])) $errors['besttime'] = 'no_besttime';
			
			//если поле заполнено - значит робот
			if(!empty($last_name)) $errors['last_name'] = 'no_man';
		
		
			if(count($errors)==0) {
				if($call_id = (int)$this->ordercall->add($call)) {
					$success = true;
					
					//отправляем письма админу
					$this->tpl->add_var('call', $call);
					$html_mail_admin = $this->tpl->fetch("mail/ordercall");
					$this->mail->send_mail(array($this->settings->site_email, $this->settings->site_title), "Заказ звонка на ".$this->settings->site_title, $html_mail_admin);
				}
			}
		}
		
		
		$this->tpl->add_var('call', $call);
		$this->tpl->add_var('success', $success);
		$this->tpl->add_var('errors', $errors);
		$this->tpl->add_var('page_t', $page_t);
		return $this->tpl->fetch("ordercall");
	}
}