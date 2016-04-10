<?php
/**
 * класс для работы с ревизиями контента
 * @author riol
 *
 */
class Revision extends System {
	/**
	 * максимальное количество ревизий объекта
	 */
	private $limit_revisions = 10;
	
	/**
	 * Создает ревизию обекта и удаляет старые (превышающие лимит)
	 * @param int $for_id
	 * @param string $content_type
	 * @param array $content
	 * @return int
	 */
	public function add_revision($for_id, $content_type, $content) {
		if($this->limit_revisions>0) {
			//eдаляем старые ревизии
			$revisions = $this->get_list_revisions($for_id, $content_type);
			if(count($revisions)>=$this->limit_revisions) {
				$i = 1;
				foreach($revisions as $revision) {
					if($i>=$this->limit_revisions) {
						$this->db->query("DELETE FROM ?_revisions WHERE id=? AND for_id=? AND content_type=?", $revision['id'], (int)$for_id, $content_type);
					}
					$i++;
				}
			}
			return $this->db->query("INSERT INTO ?_revisions (for_id, content_type, date_add, content) VALUES (?, ?, ?, ?)", (int)$for_id, $content_type, time(), serialize($content));
		}
		else return null;
	}
	
	/**
	 * возвращает объект из ревизии
	 * @param int $id
	 * @param int $for_id
	 * @param string $content_type
	 */
	public function get_from_revision($id, $for_id, $content_type) {
		if($content = $this->db->selectCell("SELECT content  FROM ?_revisions WHERE id=? AND for_id=? AND content_type=? ORDER BY id DESC", intval($id), intval($for_id), $content_type)) {
			return unserialize($content);
		}
		return null;
	}
	
	/**
	 * удаляет все ревизии объекта
	 * @param int $for_id
	 * @param string $content_type
	 */
	public function clear_revisions($for_id, $content_type) {
		return $this->db->query("DELETE FROM ?_revisions WHERE for_id=? AND content_type=?", (int)$for_id, $content_type);
	}
	
	/**
	 * возвращает все ревизии объекта
	 * @param int $for_id
	 * @param string $content_type
	 */
	public function get_list_revisions($for_id, $content_type) {
		return $this->db->select("SELECT id, for_id, content_type, date_add  FROM ?_revisions WHERE for_id=? AND content_type=? ORDER BY id DESC", intval($for_id), $content_type);
	}
}