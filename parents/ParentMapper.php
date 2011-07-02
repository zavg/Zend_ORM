<?php

class General_Model_ParentMapper 
{   
    public function getModel()
    {
        $className = str_replace("Mapper", "", get_class($this));
        return new $className;
    }   
}
