<?php
use App\Http\Controllers\JobsController;
use App\Http\Controllers\ProcessImageController;
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
        
        $html = '<a href="'.$prevPageLink.'"> <i class="pagination fa fa-angle-left"></i> </a> ';
        $html .= $pageNo .' of '.$numOfPages ;
        $html .= '<a href="'.$nextPageLink.'"> <i class="pagination fa fa-angle-left"></i> </a> ';
 
    }
    
    return $html;
}

//***CONVERT UTC TO IST

function convertToIST($dateTime)
{
    $date = new DateTime($dateTime, new DateTimeZone('UTC'));
    $date->setTimezone(new DateTimeZone('Asia/Calcutta'));
    return $date->format('d-m-Y H:i:s');
}

function dateDiffernce($date2, $date1) 
{ 
  $start_ts = strtotime($date1);
  $end_ts = strtotime($date2);
  $diff = $end_ts - $start_ts; 
  return round($diff / 86400); 
}

function runAutoBidOffers(){
    $JobsController = new JobsController();
    $JobsController->index();
}

function processImages(){
    $ProcessImageController = new ProcessImageController();
    $ProcessImageController->index();
}

