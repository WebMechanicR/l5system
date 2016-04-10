<?php
/**
 * класс отображения инструментов в административной части сайта
 * @author riol
 *
 */

class BackendTools extends View {
	public function index() {
		$this->admins->check_access_module('tools', 2);

		if($this->request->method('post') && !empty($_POST)) {
			$tool = $this->request->post('tool', 'string');
			if($tool) {
				switch($tool) {
					case "cache_clear_all":
						$this->cache->clean(array(), true);
						break;
						
					case "cache_clear_tags":
						$tags = $this->request->post('tags', 'string');
						$ar_tags = array_map("trim", explode(",", $tags));
						if(count($ar_tags)>0) {
							$this->cache->clean($ar_tags, true);
						}
						break;
					/*case "catalog_count":
						$this->catalog->update_catalog_count();
						break;*/
				}
				/**
				 * если загрузка аяксом возвращаем только 1 в ответе, чтобы обновилась только кнопка сохранения
				 */
				if($this->request->isAJAX()) return 1;
			}
		}

		return $this->tpl->fetch('tools');
	}
}