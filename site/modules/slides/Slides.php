<?php
class Slides extends Module implements IElement {

	protected $module_name = "slides";
	private $module_table = "slides";
	private $module_nesting = false; //возиожность владывать подстраницы в модуль

	private $module_settings = array(
			"dir_images" => "img/",
			"image_sizes"=> array (
					"normal"=> array(700, 330, true, false),// ширина, высота, crop, watermark
					"small"=> array(50, 50, false, false)
			),
			"images_content_type" => "slides",
			"revisions_content_type" => "slides"

	);


	/**
	 * добавляет новый элемент в базу
	*/
	public function add($slide) {
		//чистим кеш
		$this->cache->delete("list_slides");
		return $this->db->query("INSERT INTO ?_".$this->module_table." (?#) VALUES (?a)", array_keys($slide), array_values($slide));
	}

	/**
	 * обновляет элемент в базе
	 */
	public function update($id, $slide) {

		//чистим кеш
		$this->cache->delete("list_slides");
		if($this->db->query("UPDATE ?_".$this->module_table." SET ?a WHERE id IN (?a)", $slide, (array)$id))
			return $id;
		else
			return false;
	}

	/**
	 * удаляет элемент из базы
	 */
	public function delete($id) {
		if($slide = $this->get_slide($id)) {

			if($slide['img']!='') $this->delete_image($id);

			$this->db->query("DELETE FROM ?_".$this->module_table." WHERE id=?", $id);

			//чистим кеш
			$this->cache->delete("list_slides");

			$this->clear_revisions($id);
		}
	}

	/**
	 * создает копию элемента
	 */
	public function duplicate($id) {
		$new_id = null;
		if($slide = $this->get_slide($id)) {
				
			unset($slide['id']);
			$slide['title'] .= ' (копия)';
			$slide['enabled'] = 0;
				
			$new_id = (int)$this->add($slide);
		}
		return $new_id;
	}

	/**
	 * возвращает историю версий элемента
	 */
	public function get_list_revisions($for_id) {
		return $this->revision->get_list_revisions($for_id, $this->setting("revisions_content_type"));
	}

	/**
	 * добавляет версию элемента в историю
	 */
	public function add_revision($for_id) {
		if($content = $this->get_slide($for_id)) {
			return $this->revision->add_revision($for_id, $this->setting("revisions_content_type"), $content);
		}
		return null;
	}

	/**
	 * возвращает данные элемента из определенной ревизии
	 */
	public function get_from_revision($id, $for_id) {
		return $this->revision->get_from_revision($id, $for_id, $this->setting("revisions_content_type"));
	}

	/**
	 * удаляет все ревизии элемента
	 */
	public function clear_revisions($for_id) {
		return $this->revision->clear_revisions($for_id, $this->setting("revisions_content_type"));
	}

	/**
	 * возвращает новость по id
	 * @param mixed $id
	 * @return array
	 */
	public function get_slide($id) {
		return $this->db->selectRow("SELECT * FROM ?_".$this->module_table." WHERE id=?d", $id);
	}

	/**
	 * возвращает новости удовлетворяющие фильтрам
	 * @param array $filter
	 */
	public function get_list_slides($filter=array()) {
		$limit = "";
		$where = "";

		if(isset($filter['limit']) and count($filter['limit'])==2) {
			$filter['limit'] = array_map("intval", $filter['limit']);
			$limit = " LIMIT ".($filter['limit'][0]-1)*$filter['limit'][1].", ".$filter['limit'][1];
		}

		if(isset($filter['enabled'])) {
			$where .= (empty($where) ? " WHERE " : " AND ")."n.enabled=".intval($filter['enabled']);
		}

		return $this->db->select("SELECT n.*
				FROM ?_".$this->module_table." n".$where." ORDER BY n.sort ASC".$limit);
	}

	/**
	 * возвращает настройку модуля
	 * @param string $id
	 * @return Ambigous <NULL, multitype:string >
	 */
	public function setting($id) {
		return (isset($this->module_settings[$id]) ? $this->module_settings[$id] : null);
	}

	/**
	 * добавляет изображение
	 * @param int $slide_id
	 * @param string $image
	 * @param string $name
	 * @param int $sort
	 * @return boolean
	 */
	public function add_image($slide_id, $image) {
		$image_sizes = $this->setting("image_sizes");
		if(!$this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image, ROOT_DIR_IMAGES.$this->setting("dir_images")."normal/".$image, $image_sizes["normal"])) return false;
		if(!$this->image->create_image(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$image, ROOT_DIR_IMAGES.$this->setting("dir_images")."small/".$image, $image_sizes["small"])) return false;

		$this->update($slide_id, array("img"=>$image));
		return $slide_id;
	}

	public function delete_image($id){
		$slide = $this->get_slide($id);
		if($slide and $slide['img']!="") {
			//проверяем, не используется ли это изображение где-то еще
			$count = $this->db->selectCell("SELECT count(*) FROM ?_".$this->module_table." WHERE img=?", $slide['img']);
			if($count==1) {
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."original/".$slide['img']);
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."normal/".$slide['img']);
				@unlink(ROOT_DIR_IMAGES.$this->setting("dir_images")."small/".$slide['img']);
			}
			$this->update($id, array("img"=>""));
		}
	}

	/**
	 * возвращает порядок сортировки для добавляемой страницы
	 */
	public function get_new_slide_sort() {
		return $this->db->selectCell("SELECT MAX(sort) as sort FROM ?_".$this->module_table)+1;
	}

	/**
	 * @return boolean
	 */
	public function is_nesting() {
		return $this->module_nesting;
	}

}