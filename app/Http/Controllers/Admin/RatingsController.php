<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Parse\ParseObject;
use Parse\ParseQuery;
use App\Http\Requests;
use App\Http\Controllers\Controller;
use \PHPExcel;
use App\Http\Helper\FormatPhpExcel;

class RatingsController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
        $ratingsData = $this->getRatings('LIST');
        
        $ratingsList = $ratingsData['list'];
        $numOfPages = $ratingsData['numOfPages'];
        $page = $ratingsData['page'];

        return view('admin.ratingslist')->with('ratingsList',$ratingsList)
                                         ->with('page',$page+1)
                                         ->with('numOfPages',$numOfPages)
                                         ->with('activeMenu','ratings');
    }
    
    public function getRatings($type)
    {
        $page = (isset($_GET['page']))? ($_GET['page']-1) :0; 
        $numOfPages = 0;
        
        $ratings = new ParseQuery("Ratings");
        $ratings->includeKey('ratingBy');
        $ratings->includeKey('ratingFor');
        $ratings->equalTo("ratingForType", "seller");
        
        if($type == 'LIST')
        {   //Pagination
            
            $displayLimit = config('constants.page_limit'); 
 
            $ratingsCount = $ratings->count();  
            $ratings->limit($displayLimit);
            $ratings->skip($page * $displayLimit);
            
            $numOfPages = ceil($ratingsCount/$displayLimit);
        }
        
        $ratingsData = $ratings->find();   
        $ratingsList =[];
        
        foreach($ratingsData as $rating)
        {  
 
            if($type=='LIST')
            {
               $ratingsList[]= [  'id' => $rating->getObjectId(),
                                  'ratingBy' => $rating->get("ratingBy")->get("displayName"),
                                  'ratingFor' => $rating->get("ratingFor")->get("displayName"),
                                  'count' => $rating->get("count"),
                                  'comments' => $rating->get("comments"),
                                  'date' => $rating->getCreatedAt()->format('d-m-Y'),    
                              ];
            }
            else
            {
                $ratingsList[]= [ 
                                  'date' => $rating->getCreatedAt()->format('d-m-Y'), 
                                  'ratingFor' => $rating->get("ratingFor")->get("displayName"),
                                  'count' => $rating->get("count"),    
                                  'comments' => $rating->get("comments"),
                                  'ratingBy' => $rating->get("ratingBy")->get("displayName"),
                                  
                                  
                              ]; 
            }
             
        }
        
        $data =[];
        $data['list']=$ratingsList;
        $data['numOfPages']=$numOfPages;
        $data['page']=$page;
        
        return $data;
    }
    
  //   public function ratingsExport()
  //   { 
  //       $excel = new PHPExcel();
  //       $ratingSheet = $excel->getSheet(0);
		// $ratingSheet->setTitle('Ratings');
        
        
  //       $ratingsData = $this->getRatings('EXPORT');
  //       $ratingsList = $ratingsData['list'];  
  //       $headers = [];
 
  //       $headers []= 'Date' ;
  //       $headers []= 'Seller' ;
  //       $headers []= 'Rating' ;
  //       $headers []= 'Comments' ;
  //       $headers []= 'Seller' ;
 
  //       $ratingSheet->fromArray($headers, ' ', 'A1');
  //       $ratingSheet->fromArray($ratingsList, ' ','A2');


  //       //Headr row height
  //       $ratingSheet->getRowDimension('1')->setRowHeight(20);

  //       //Format header row
  //       FormatPhpExcel::format_header_row($ratingSheet, array(
  //           'background_color'=>'FFFF00',
  //           'border_color'=>'000000',
  //           'font_size'=>'9',
  //           'font_color'=>'000000',
  //           'vertical_alignment'=>'VERTICAL_CENTER',
  //           'font-weight'=>'bold'
  //           ), '1'
  //       );
        
  //       header('Content-Type: application/vnd.ms-excel');
  //       header('Content-Disposition: attachment;filename="ratings-export.xls"');
  //       header('Cache-Control: max-age=0');
  //       // If you're serving to IE 9, then the following may be needed
  //       header('Cache-Control: max-age=1');
  //       // If you're serving to IE over SSL, then the following may be needed
  //       header ('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
  //       header ('Last-Modified: '.gmdate('D, d M Y H:i:s').' GMT'); // always modified
  //       header ('Cache-Control: cache, must-revalidate'); // HTTP/1.1
  //       header ('Pragma: public'); // HTTP/1.0
  //       $objWriter = \PHPExcel_IOFactory::createWriter($excel, 'Excel5');
  //       $objWriter->save('php://output'); 
    
  //   }

    public function ratingsExport()
    {      
        
        $ratingsData = $this->getRatings('EXPORT');
        $ratings = $ratingsData['list'];  
        $headers = [];
 
        $headers []= 'Date' ;
        $headers []= 'Seller' ;
        $headers []= 'Rating' ;
        $headers []= 'Comments' ;
        $headers []= 'Seller' ;
 
        $filename = "exports/ratings-export.csv";
        $handle = fopen($filename, 'w+');
        fputcsv($handle, $headers);

        foreach ($ratings as $rating) {
          fputcsv($handle, $rating);
        }
        fclose($handle);

        $headers = array(
        'Content-Type' => 'text/csv',
        );

        return response()->download($filename, 'ratings-export.csv', $headers)->deleteFileAfterSend(true);
         
    
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  Request  $request
     * @return Response
     */
    public function store(Request $request)
    {
        //
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return Response
     */
    public function show($id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return Response
     */
    public function edit($id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  Request  $request
     * @param  int  $id
     * @return Response
     */
    public function update(Request $request, $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return Response
     */
    public function destroy($id)
    {
        //
    }
}
