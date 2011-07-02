<?php

class General_Model_ParentMapper 
{   
    public function setFields(General_Model_ParentModel $entry, Zend_Db_Table_Row $row)
    {
        foreach ($row->toArray() as $key => $value)
        {
            $method = 'set' . ucfirst($key);
            $entry->$method($row->$key);
        }
    }

    public function getModel()
    {
        $className = str_replace("Mapper", "", get_class($this));
        return new $className;
    }   
}
