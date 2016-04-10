<?php
/**
 * интерфейс любого элемента контента
 * @author riol
 *
 */
interface IElement {
	/**
	 * добавляет новый элемент в базу
	 */
	public function add($elem);
	
	/**
	 * обновляет элемент в базе
	 */
	public function update($id, $elem);
	
	/**
	 * удаляет элемент из базы
	 */
	public function delete($id);
	
	/**
	 * создает копию элемента
	 */
	public function duplicate($id);
	
	/**
	 * добавляет версию элемента в историю
	 */
	public function add_revision($for_id);
	
	/**
	 * возвращает историю версий элемента
	 */
	public function get_list_revisions($for_id);
	
	/**
	 * возвращает данные элемента из определенной ревизии
	 */
	public function get_from_revision($id, $for_id);
	
}