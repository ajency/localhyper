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
        $page = (isset($_GET['page']))? ($_GET['page']-1) :0; 
        $displayLimit = config('constants.page_limit');
        $requestsData = $this->getRequests('LIST',$page ,$displayLimit);
        $requestList = $requestsData['list'];
        $numOfPages = $requestsData['numOfPages'];
        $page = $requestsData['page'];

        return view('admin.requestlist')->with('requestList',$requestList)
                                         ->with('page',$page+1)
                                         ->with('numOfPages',$numOfPages)
                                         ->with('activeMenu','requests');
    }
    
    public function getRequests($type ,$page ,$displayLimit)
    {
        $numOfPages = 0;
        
        $requests = new ParseQuery("Request");
        $requests->includeKey('customerId');
        $requests->includeKey('product');
        $requests->includeKey('category');
        $requests->descending("createdAt");
          //Pagination

        $offersCount = $requests->count();  
        $requests->limit($displayLimit);
        $requests->skip($page * $displayLimit);
        
        $numOfPages = ceil($offersCount/$displayLimit);
        $requestsData = $requests->find();
        
        $requestList = $productPriceArray=[];
        
        foreach($requestsData as $request)
        {
            $productId = $request->get("product")->get("objectId");
            if(!isset($productPriceArray[$productId]))
            {
                $productPrice = new ParseQuery("Price");
                $productPrice->equalTo("product", $productId);
                $productPrice->ascending("value");
                $productPriceData = $productPrice->find();
                $onlinePriceArray = $priceArray = [];
                $onlinePrice = $platformPrice = '';
                foreach($productPriceData as $price)
                {
                    $priceType = $price->get("type");
                    if($priceType == 'online_market_price')
                    {
                        $onlinePriceArray[] = $price->get("value");
                    }
                    else{
                        $priceArray[] = $price->get("value");
                    }
                }
                $onlinePrice = (!empty($onlinePriceArray))? min($onlinePriceArray)  :''; 
                $platformPrice = (!empty($priceArray))? min($priceArray) :'N/A'; 
                
                $productPriceArray[$productId]['OnlinePrice'] = ($onlinePrice!='')?$onlinePrice:''; 
                $productPriceArray[$productId]['PlatformPrice'] = $platformPrice; 
            }
            else
            {
                $onlinePrice = $productPriceArray[$productId]['OnlinePrice']; 
                $platformPrice = $productPriceArray[$productId]['PlatformPrice']; 
            }
            
            $offers = new ParseQuery("Offer");
            $offers->equalTo("request", $request);
            $offers->equalTo("status", 'accepted');
            $offersStatus = $offers->count();
            
            $requestStatus = $request->get("status");
            $deliveryStatus = ($offersStatus)?$requestStatus:'N/A';
            
            
            if($requestStatus=='open')
            {
                $datetime1 = date('Y-m-d H:i:s');
                $datetime2 = $request->getCreatedAt()->format('Y-m-d H:i:s');
                $interval = dateDiffernceInHours($datetime1, $datetime2);  
                if($interval>=1)
                    $requestStatus = 'expired';
            }
            
            if($type=='LIST')
            {
               $requestList[]= [ 'id' => $request->getObjectId(),
                              'customerName' => $request->get("customerId")->get("displayName"),
                              'customerId' => $request->get("customerId")->getObjectId(),    
                              'category' =>$request->get("category")->get("name"),    
                              'productName' =>$request->get("product")->get("name"),
                              'mrp' =>$request->get("product")->get("mrp"),
                              'onlinePrice' =>$onlinePrice,
                              'bestPlatformPrice' =>$platformPrice,
                              'area' =>$request->get("area"),
                              'offerCount' =>$request->get("offerCount"),
                              'status' =>$requestStatus,
                              'deliveryStatus' =>$deliveryStatus,
                              'date'=>convertToIST($request->getCreatedAt()->format('d-m-Y H:i:s')),    
                              ]; 
            }
            else
            {
                $requestList[]= [ 
                              'customerName' => $request->get("customerId")->get("displayName"),
                              'category' =>$request->get("category")->get("name"),    
                              'productName' =>$request->get("product")->get("name"),
                              'mrp' =>$request->get("product")->get("mrp"),
                              'onlinePrice' =>$onlinePrice,
                              'bestPlatformPrice' =>$platformPrice,
                              'area' =>$request->get("area"),
                              'offerCount' => $request->get("offerCount"),
                              'status' =>$requestStatus,
                              'deliveryStatus' =>$deliveryStatus,
                              'date'=>convertToIST($request->getCreatedAt()->format('d-m-Y H:i:s')),  
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
        $headers []= 'Delivery STATUS' ;
        $headers []= 'Date' ;

        $requestSheet->fromArray($headers, ' ', 'A1');

        $page = 0; 
        $limit = 50;
        $requests =[];
        while (true) {
          
          $requestsData = $this->getRequests('EXPORT',$page ,$limit); //dd($requestsData);
          
          if(empty($requestsData['list']))
            break;

          $requests = array_merge($requests,$requestsData['list']);   
         
          $page++; 
         
        }
        
        $requestSheet->fromArray($requests, ' ','A2',true);
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
    public function show($requestId)
    {
        $requests = new ParseQuery("Request");
        $requests->equalTo("objectId", $requestId);
        $requests->includeKey('customerId');
        $requests->includeKey('product');
        $requests->includeKey('category');
        $innerRequestQuery = $requests;
        $request = $requests->first();
        
        $productObj = $request->get("product");
        
        $productId = $productObj->get("objectId");
            
        $productPrice = new ParseQuery("Price");
        $productPrice->equalTo("product", $productId);
        $productPrice->ascending("value");
        $productPriceData = $productPrice->find();
        $onlinePriceArray = $priceArray = [];
        $onlinePrice = $platformPrice = '';
        foreach($productPriceData as $price)
        {
            $priceType = $price->get("type");
            if($priceType == 'online_market_price')
            {
                $onlinePriceArray[] = $price->get("value");
            }
            else{
                $priceArray[] = $price->get("value");
            }
        }
        $onlinePrice = (!empty($onlinePriceArray))? min($onlinePriceArray)  :''; 
        $platformPrice = (!empty($priceArray))? min($priceArray).'/-' :'N/A'; 

        $productPriceArray= ($onlinePrice!='')?$onlinePrice.'/-':''; 
        $productPriceArray = $platformPrice; 
        
        $requestId = $request->getObjectId();
 
 
        $offers = new ParseQuery("Offer");
        $offers->equalTo("request", $request);
        $offers->includeKey('seller');
        $offers->includeKey('price');
        $offersData = $offers->find();
  
         
        
        $offersList = $productRequests= $offerStatus =  [];
        
        foreach($offersData as $offer)
        {
            $requestObj= $offer->get("request");
            $priceObj = $offer->get('price');
            
            $requestsinnerQuery  = new ParseQuery("Request");
            $requestsinnerQuery ->equalTo("product", $productObj);
            
            $lastSellerOffer = new ParseQuery("Offer");
            $lastSellerOffer->matchesQuery("request",$requestsinnerQuery);
            $lastSellerOffer->descending("createdAt");
            $lastOfferBySeller = $lastSellerOffer->first(); 
            $offerStatus[] = $offer->get("status");
            
          
             $offersList[] =[
                        'productName'=>$productObj->get("name"),
                        'modelNo'=>$productObj->get("model_number"),
                        'sellerName'=>$offer->get("seller")->get("displayName"),
                        'area'=>$offer->get("area"),
                        'mrpOfProduct'=>$productObj->get("mrp").'/-',   
                        'onlinePrice'=>$onlinePrice,
                        'offerPrice'=>$priceObj->get("value").'/-',
                        'lastOfferBySeller'=>$lastOfferBySeller->get("offerPrice").'/-',
                        'requestStatus'=>$request->get("status"),
                        'offerStatus'=>$offer->get("status"),
                        'deliveryReasonFailure'=>($request->get("failedDeliveryReason")!='')?$request->get("failedDeliveryReason"):'N/A',
                        'date'=>convertToIST($offer->getCreatedAt()->format('d-m-Y H:i:s')),
                         ] ;    
        }
        
        $deliveryStatus = (in_array('accepted',$offerStatus))?$request->get("status"):'N/A';
 
        
        $requestData= [  'id' => $requestId,
                          'customerName' => $request->get("customerId")->get("displayName"),
                          'category' =>$request->get("category")->get("name"),    
                          'productName' =>$request->get("product")->get("name"),
                          'mrp' =>$request->get("product")->get("mrp").'/-',
                          'onlinePrice' =>$onlinePrice,
                          'bestPlatformPrice' =>$platformPrice,
                          'area' =>$request->get("area"),
                          'offerCount' =>$request->get("offerCount"),
                          'comments' =>$request->get("comments"),
                          'address' =>$request->get("address"),
                          'status' =>$request->get("status"),
                          'deliveryStatus' =>$deliveryStatus,
                          'date'=>convertToIST($request->getCreatedAt()->format('d-m-Y H:i:s')),  
                      ];     
        
        return view('admin.requestdetails')->with('request',$requestData)
                                          ->with('offers',$offersList)
                                          ->with('activeMenu','requests');
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
