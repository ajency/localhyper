<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class ProcessImage extends Model
{
    public function getImagesAttribute( $value ) {
        return unserialize( $value );
    }

    public function setImagesAttribute( $value ) {
         $this->attributes['images'] = serialize( $value );
    }    
}
