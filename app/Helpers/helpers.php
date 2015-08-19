<?php

//*** PAGINATION

function displayPagination($pageNo , $numOfPages , $link)
{
    $pageNo = ($pageNo=='')? 1 :$pageNo;
    $url =  url($link);  
    $html = '';
    if($numOfPages > 1) 
    {
        /*Page : <select name="number_of_pages" onchange="location.href='{{ url('admin/seller') }}?page='+this.value">
            @for($i=1 ;$i<=$numOfPages ;$i++)
           <option {{ ($i == $page)?'selected':'' }}  value="{{ $i }}">{{ $i }}</option>                         
            @endfor
        </select> */
        $prevPageLink = ($pageNo > 1) ? $url.'?page='.($pageNo -1) :'#' ;
        $nextPageLink = ($pageNo < $numOfPages) ? $url.'?page='.($pageNo +1) :'#' ;  
        
        $html = '<a href="'.$prevPageLink.'"> previous </a> ';
        $html .= $pageNo .' of '.$numOfPages ;
        $html .= '<a href="'.$nextPageLink.'"> next </a> ';
 
    }
    
    return $html;
}

function convertToIST($dateTime)
{
    $date = new DateTime($dateTime, new DateTimeZone('UTC'));
    $date->setTimezone(new DateTimeZone('IST'));
    return $date->format('d-m-Y H:i:s');
}
