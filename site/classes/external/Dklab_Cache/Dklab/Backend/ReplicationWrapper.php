<?php
/**
 * Dklab_Cache_Backend_ReplicationWrapper: synchronous statement-based 
 * replication of cache backends.
 * 
 * Replicates modifications (deletion or write) to a number of
 * cache backends. This is needed because memcache 3.x is not 
 * stable today (2008-12-14) and causes PHP to crash sometimes.
 *
 * $Id$
 */
require_once DKCACHE_PATH."Zend/Cache/Backend/Interface.php";

class Dklab_Cache_Backend_ReplicationWrapper implements Zend_Cache_Backend_Interface 
{
    const REPLICATE_REMOVE = 1;
    const REPLICATE_WRITE = 2;
    
    /**
     * Backends to replicate to. This array never contain $_mainBackend.
     */
    private $_backends = array();
    
    /**
     * Backend to read from and always to write to (or remove from).
     */
    private $_mainBackend = null;
    
    
    /**
     * Create replication wrapper.
     * 
     * @param aray $backends      Backends to replicate modification operations to.
     * @param $mainBackend        Backend to read from (it is also subject for replication).
     * @param $mode               Replication mode (only writes, only removes, or both).
     */
    public function __construct(array $backends, Zend_Cache_Backend_Interface $mainBackend = null, $mode = null)
    {
        $this->_mainBackend = $mainBackend? $mainBackend : current($backends);
        $this->_backends = array();
        foreach ($backends as $backend) {
            if ($backend != $this->_mainBackend) {
                $this->_backends[] = $backend;
            }
        }
        $this->_mode = $mode === null? (self::REPLICATE_REMOVE | self::REPLICATE_WRITE) : $mode;
    }
    
    
    public function setDirectives($directives)
    {
        foreach ($this->_backends as $backend) {
            $backend->setDirectives($directives);
        }
        return $this->_mainBackend->setDirectives($directives);
    }
    
    
    public function load($id, $doNotTestCacheValidity = false)
    {
        return $this->_mainBackend->load($id, $doNotTestCacheValidity);
    }
    
    
    public function test($id)
    {
        return $this->_mainBackend->test($id);
    }
    
    
    public function save($data, $id, $tags = array(), $specificLifetime = false)
    {
        if ($this->_mode & self::REPLICATE_WRITE) {
            foreach ($this->_backends as $backend) {
                $backend->save($data, $id, $tags, $specificLifetime);
            }
        }
        return $this->_mainBackend->save($data, $id, $tags, $specificLifetime);
    }
    
    
    public function remove($id)
    {
        if ($this->_mode & self::REPLICATE_REMOVE) {
            foreach ($this->_backends as $backend) {
                $backend->remove($id);
            }
        }
        return $this->_mainBackend->remove($id);
    }
    
    
    public function clean($mode = Zend_Cache::CLEANING_MODE_ALL, $tags = array())
    {
        if ($this->_mode & self::REPLICATE_REMOVE) {
            foreach ($this->_backends as $backend) {
                $backend->clean($mode, $tags);
            }
        }
        return $this->_mainBackend->clean($mode, $tags);
    }
}
