<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Parse\ParseObject;
use Parse\ParseQuery;
use App\Http\Requests;
use App\Http\Controllers\Controller;
use \PHPExcel;
use App\Http\Helper\FormatPhpExcel;

class CustomerController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
        $customerData = $this->getCustomers('LIST');
        $customerList = $customerData['list'];
        $numOfPages = $customerData['numOfPages'];
        $page = $customerData['page'];

        return view('admin.customerlist')->with('customers',$customerList)
                                         ->with('page',$page+1)
                                         ->with('numOfPages',$numOfPages)
                                         ->with('activeMenu','customers');
    }
 
    public function getCustomers($type)
    {
        $page = (isset($_GET['page']))? ($_GET['page']-1) :0; 
        $numOfPages = 0;
        
        $customers = new ParseQuery("_User");
        $customers->equalTo("userType", "customer");
        
        if($type == 'LIST')
        {   //Pagination
            
            $displayLimit = config('constants.page_limit'); 
 
            $customersCount = $customers->count();  
            $customers->limit($displayLimit);
            $customers->skip($page * $displayLimit);
            
            $numOfPages = ceil($customersCount/$displayLimit);
        }
        
        $customerData = $customers->find();  
        $customerList =[];
        foreach($customerData as $customer)
        {  
            $custId = $customer->getObjectId();
            
            $deliverStatusCount = $requestSuccessfullCount = $requestCancelledCount = $requestExpiredCount = $requestPendingDelivery = $requestSentDelivery =0;
            
            $request = new ParseQuery("Request");
            $request->equalTo("customerId", $customer);
            $requestData = $request->find();
            $requestMadeCount = count($requestData);
            
            foreach($requestData as $request)
            {   
                if($request->get("status")=='open')
                {
                    $datetime1 = date('Y-m-d H:i:s');
                    $datetime2 = $request->getCreatedAt()->format('Y-m-d H:i:s');
                    $interval = dateDiffernce($datetime1, $datetime2);  
                    if($interval>=1)
                        $requestExpiredCount = $requestExpiredCount+1;
                }
                
                if($request->get("status")=='cancelled')
                    $requestCancelledCount = $requestCancelledCount+1;
                
                if($request->get("status")=='successful')
                    $requestSuccessfullCount = $requestSuccessfullCount+1;
                
                if($request->get("status")=='failed_delivery')
                    $deliverStatusCount = $deliverStatusCount+1;
                
                if($request->get("status")=='pending_delivery')
                    $requestPendingDelivery = $requestPendingDelivery+1;
                
                if($request->get("status")=='sent_for_delivery')
                    $requestSentDelivery = $requestSentDelivery+1;
                
            }
            
            if($type=='LIST')
            {
                $customerList[]= [
                              'id' => $customer->getObjectId(),
                              'name' => $customer->get("displayName"),
                              'createdAt' =>$customer->getCreatedAt()->format('d-m-Y'),
                              'lastLogin' =>$customer->get("lastLogin")->format('d-m-Y'),
                              'numOfRequest' =>$requestMadeCount,
                              'requestExpired' =>$requestExpiredCount,
                              'requestCancelled' =>$requestCancelledCount,
                              'requestSuccessfull' =>$requestSuccessfullCount,
                              'deliveryStatus' =>$deliverStatusCount,
                              'pendingDelivery' =>$requestPendingDelivery,
                               'sentDelivery' =>$requestSentDelivery,
                              ]; 
            }
            else
            {
                $customerList[]= [
                               
                              'name' => $customer->get("displayName"),
                              'createdAt' =>$customer->getCreatedAt()->format('d-m-Y'),
                              'lastLogin' =>$customer->get("lastLogin")->format('d-m-Y'),
                              'numOfRequest' =>$requestMadeCount,
                              'requestExpired' =>$requestExpiredCount,
                              'requestCancelled' =>$requestCancelledCount,
                              'requestSuccessfull' =>$requestSuccessfullCount,
                              'deliveryStatus' =>$deliverStatusCount,
                              ]; 
            }
 
            
        }
        
         $data['list']=$customerList;
         $data['numOfPages']=$numOfPages;
         $data['page']=$page;
         return $data;
    }
    
    public function customersExport()
    {
        $excel = new PHPExcel();
        $customersSheet = $excel->getSheet(0);
		$customersSheet->setTitle('Customers');
        
        $customerData = $this->getCustomers('EXPORT');
        $customerList = $customerData['list'];

        
        $headers = [];
 
        $headers []= 'CUSTOMER NAME' ;
        $headers []= 'CUSTOMER REGISTERED DATE' ;
        $headers []= 'CUSTOMER LAST LOGIN' ;
        $headers []= 'NO. OF REQUESTS CREATED' ;
        $headers []= 'NO. OF REQUESTS EXPIRED' ;
        $headers []= 'NO. OF REQUESTS CANCELLED' ;
        $headers []= 'NO. OF REQUESTS SUCCESSFULL' ;
        $headers []= 'NO. OF FAILED DELIVERY' ;
		
 
        $customersSheet->fromArray($headers, ' ', 'A1');
        $customersSheet->fromArray($customerList, ' ','A2');


        //Headr row height
        $customersSheet->getRowDimension('1')->setRowHeight(20);

        //Format header row
        FormatPhpExcel::format_header_row($customersSheet, array(
            'background_color'=>'FFFF00',
            'border_color'=>'000000',
            'font_size'=>'9',
            'font_color'=>'000000',
            'vertical_alignment'=>'VERTICAL_CENTER',
            'font-weight'=>'bold'
            ), '1'
        );
        
        header('Content-Type: application/vnd.ms-excel');
        header('Content-Disposition: attachment;filename="customers-export.xls"');
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
        $customers = new ParseQuery("_User");
        $customers->equalTo("objectId", $id);
        $customerData = $customers->first(); 
        $customer['id'] = $customerData->getObjectId();
        $customer['username'] = $customerData->get("username"); 
        $customer['name'] = $customerData->get("displayName"); 
        $customer['address'] = $customerData->get("address"); 
        $customer['area'] = $customerData->get("area"); 
        $customer['city'] = $customerData->get("city");
        $showRequest = false;
         
        if(isset($_GET['page']))
        {
            $page =($_GET['page']-1);
            $showRequest = true;    
        }
        else
            $page =0; 
        $displayLimit = config('constants.page_limit'); 
        $numOfPages = 0;
        
        $request = new ParseQuery("Request");
        $request->equalTo("customerId", $customerData);
        $request->includeKey('product');
        $request->includeKey('category');
        
        $requestCount = $request->count();          //Pagination
        $request->limit($displayLimit);
        $request->skip($page * $displayLimit);

        $numOfPages = ceil($requestCount/$displayLimit);
        
        $requestData = $request->find();
        
        $requests =$productPriceArray =[];
        foreach($requestData as $request)
        {
            $productId = $request->get("product")->get("objectId");
            $requestStatus = $request->get("status");
            if(!isset($productPriceArray[$productId]))
            {
                $productPrice = new ParseQuery("Price");
                $productPrice->equalTo("product", $productId);
                $productPrice->equalTo("type", 'online_market_price');
                $productPrice->ascending("value");
                $onlinePriceData = $productPrice->first(); 
                $onlinePrice = (!empty($onlinePriceData))?$onlinePriceData->get("value"):'N/A';
 
                $productPriceArray[$productId]['OnlinePrice'] = $onlinePrice; 

            }
            else
            {
                $onlinePrice = $productPriceArray[$productId]['OnlinePrice']; 
            }
            $soldPrice = 'N/A';
            if($requestStatus == 'pending_delivery' || $requestStatus == 'sent_for_delivery' || $requestStatus == 'successful')
            {
                $requestOffer = new ParseQuery("Offer");
                $requestOffer->equalTo("request", $request);
                $requestOffer->includeKey('price');
                $soldPriceData = $requestOffer->first(); 
                $soldPrice = (!empty($soldPriceData))?$soldPriceData->get("price")->get("value"):'N/A';
            
            }
             $priceDiff = 'N/A';
            if(is_int($onlinePrice) && is_int($soldPrice))
            {
                $priceDiff =$onlinePrice - $soldPrice;
            }
 
            $requests[] =[
                            'productName'=>$request->get("product")->get("name"),
                            'mrp'=>$request->get("product")->get("mrp"),
                            'category'=>$request->get("category")->get("name"),
                            'onlinePrice' => $onlinePrice,
                            'soldPrice' => $soldPrice,
                            'priceDiff' => $priceDiff,
                            'status'=>$requestStatus,
                         ] ;
 

        }
 
        return view('admin.customerdetails')->with('customer',$customer)
                                            ->with('numOfPages',$numOfPages)
                                            ->with('page',$page+1)
                                            ->with('showRequest',$showRequest)
                                            ->with('requests',$requests)
                                            ->with('activeMenu','customers');
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
