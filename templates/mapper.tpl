<?php 

class General_Model_{Name}Mapper extends General_Model_ParentMapper
{
    protected $_dbTable;
 
    public function setDbTable($dbTable)
    {
        if (is_string($dbTable)) {
            $dbTable = new $dbTable();
        }
        if (!$dbTable instanceof Zend_Db_Table_Abstract) {
            throw new Exception('Invalid table data gateway provided');
        }
        $this->_dbTable = $dbTable;
        return $this;
    }
 
    public function getDbTable()
    {
        if (null === $this->_dbTable) {
            $this->setDbTable('General_Model_DBTable_{Name}');
        }
        return $this->_dbTable;
    }
 
    public function save(General_Model_{Name} ${name})
    {
        {data}
 
        if (null === (${id} = ${name}->get{Id}())) {
            unset($data['{id}']);
            return $this->getDbTable()->insert($data);
        } else {
            return $this->getDbTable()->update($data, array('{id} = ?' => ${id}));
        }
    }
    
    public function setFields(General_Model_{Name} $entry, $row)
    {
        {entry_set}
    }    	

 
    public function find(${id})
    {
        ${name} = new General_Model_{Name}();
        $result = $this->getDbTable()->find(${id});
        if (0 == count($result)) {
            return;
        }
        $row = $result->current();
        self::setFields(${name}, $row);
        return ${name};
    }

    public function findWhere($where_stmt)
    {                            	
        $query = $this->getDbTable()->select();
        $query->where($where_stmt);
        $resultSet = $this->getDbTable()->fetchAll($query);
        $entries   = array();
        foreach ($resultSet as $row) {
            $entry = new General_Model_{Name}();
            self::setFields($entry, $row);
            $entries[] = $entry;
        }
        return $entries;
    }
 
    public function fetchAll()
    {
        $resultSet = $this->getDbTable()->fetchAll();
        $entries   = array();
        foreach ($resultSet as $row) {
            $entry = new General_Model_{Name}();
            self::setFields($entry, $row);
            $entries[] = $entry;
        }
        return $entries;
    }

    public function deleteObject($id) 
    {
        $table = $this->getDbTable();
        $where = $table->getAdapter()->quoteInto(
            'id{Name} = ?', $id);
        $table->delete($where);
    }
}