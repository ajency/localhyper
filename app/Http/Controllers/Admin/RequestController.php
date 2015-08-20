<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Parse\ParseObject;
use Parse\ParseQuery;
use App\Http\Requests;
use App\Http\Controllers\Controller;
use \PHPExcel;
use App\Http\Helper\FormatPhpExcel;

class RequestController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
      
        $requestsData = $this->getRequests('LIST');
        $requestList = $requestsData['list'];
        $numOfPages = $requestsData['numOfPages'];
        $page = $requestsData['page'];

        return view('admin.requestlist')->with('requestList',$requestList)
                                         ->with('page',$page+1)
                                         ->with('numOfPages',$numOfPages)
                                         ->with('activeMenu','requests');
    }
    
    public function getRequests($type)
    {
        $page = (isset($_GET['page']))? ($_GET['page']-1) :0; 
        $numOfPages = 0;
        
        $requests = new ParseQuery("Request");
        $requests->includeKey('customerId');
        $requests->includeKey('product');
        $requests->includeKey('category');
        if($type == 'LIST')
        {   //Pagination
            
            $displayLimit = config('constants.page_limit'); 
 
            $offersCount = $requests->count();  
            $requests->limit($displayLimit);
            $requests->skip($page * $displayLimit);
            
            $numOfPages = ceil($offersCount/$displayLimit);
        }
        $requestsData = $requests->find(); 
        
        $requestList = $productPriceArray=[];
        
        foreach($requestsData as $request)
        {
            $productId = $request->get("product")->get("objectId");
            if(!isset($productPriceArray[$productId]))
            {
                $productPrice = new ParseQuery("Price");
                $productPrice->equalTo("product", $productId);
                $productPriceData = $productPrice->find();
                $priceArray = [];
                $onlinePrice = $platformPrice = '';
                foreach($productPriceData as $price)
                {
                    $priceType = $price->get("type");
                    if($priceType == 'online_market_price')
                    {
                        $onlinePrice = $price->get("value");
                    }
                    else{
                        $priceArray[] = $price->get("value");
                    }
                }
                $platformPrice = (!empty($priceArray))? min($priceArray).'/-' :'N/A'; 
                
                $productPriceArray[$productId]['OnlinePrice'] = ($onlinePrice!='')?$onlinePrice.'/-':''; 
                $productPriceArray[$productId]['PlatformPrice'] = $platformPrice; 
            }
            else
            {
                $onlinePrice = $productPriceArray[$productId]['OnlinePrice']; 
                $platformPrice = $productPriceArray[$productId]['PlatformPrice']; 
            }
            
            if($type=='LIST')
            {
               $requestList[]= [ 'id' => $request->getObjectId(),
                              'customerName' => $request->get("customerId")->get("displayName"),
                              'category' =>$request->get("category")->get("name"),    
                              'productName' =>$request->get("product")->get("name"),
                              'mrp' =>$request->get("product")->get("mrp").'/-',
                              'onlinePrice' =>$onlinePrice,
                              'bestPlatformPrice' =>$platformPrice,
                              'area' =>$request->get("area"),
                              'offerCount' =>$request->get("offerCount"),
                              'status' =>$request->get("status"),
                              ]; 
            }
            else
            {
                $requestList[]= [ 
                              'customerName' => $request->get("customerId")->get("displayName"),
                              'category' =>$request->get("category")->get("name"),    
                              'productName' =>$request->get("product")->get("name"),
                              'mrp' =>$request->get("product")->get("mrp").'/-',
                              'onlinePrice' =>$onlinePrice.'/-',
                              'bestPlatformPrice' =>$platformPrice,
                              'area' =>$request->get("area"),
                              'offerCount' =>$request->get("offerCount"),
                              'status' =>$request->get("status"),
                              ]; 
            }
            
             
        }
        
        $data['list']=$requestList;
        $data['numOfPages']=$numOfPages;
        $data['page']=$page;
        return $data;
        
    }
    
    public function requestExport()
    { 
        $excel = new PHPExcel();
        $requestSheet = $excel->getSheet(0);
		$requestSheet->setTitle('Request');
 
        $requestsData = $this->getRequests('EXPORT');
        $requestList = $requestsData['list'];
        $headers = [];
 
        $headers []= 'CUSTOMER NAME' ;
        $headers []= 'CATEGORY' ;
        $headers []= 'PRODUCT NAME' ;
        $headers []= 'MRP' ;
        $headers []= 'ONLINE PRICE' ;
        $headers []= 'BEST PLATFORM PRICE' ;
        $headers []= 'AREA' ;
        $headers []= 'OFFER COUNT' ;
        $headers []= 'STATUS' ;
        						

        $requestSheet->fromArray($headers, ' ', 'A1');
        $requestSheet->fromArray($requestList, ' ','A2');


        //Headr row height
        $requestSheet->getRowDimension('1')->setRowHeight(20);

        //Format header row
        FormatPhpExcel::format_header_row($requestSheet, array(
            'background_color'=>'FFFF00',
            'border_color'=>'000000',
            'font_size'=>'9',
            'font_color'=>'000000',
            'vertical_alignment'=>'VERTICAL_CENTER',
            'font-weight'=>'bold'
            ), '1'
        );
        
        header('Content-Type: application/vnd.ms-excel');
        header('Content-Disposition: attachment;filename="requests-export.xls"');
        header('Cache-Control: max-age=0');
        // If you're serving to IE 9, then the following may be needed
        header('Cache-Control: max-age=1');
        // If you're serving to IE over SSL, then the following may be needed
        header ('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
        header ('Last-Modified: '.gmdate('D, d M Y H:i:s').' GMT'); // always modified
        header ('Cache-Control: cache, must-revalidate'); // HTTP/1.1
        header ('Pragma: public'); // HTTP/1.0
        $objWriter = \PHPExcel_IOFactory::createWriter($excel, 'Excel5');
        $objWriter->save('php://output'); 
    
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
     * @return Response
     */
    public function store()
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
     * @param  int  $id
     * @return Response
     */
    public function update($id)
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
