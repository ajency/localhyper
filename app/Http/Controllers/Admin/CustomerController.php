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

        return view('admin.customerlist')->with('customers',$customerList)
                                         ->with('numOfPages',$numOfPages);
    }
    
    public function date_diff($date2, $date1) 
    { 
      $start_ts = strtotime($date1);
      $end_ts = strtotime($date2);
      $diff = $end_ts - $start_ts;
      return round($diff / 86400); 
    }
    
    public function getCustomers($type)
    {
        
        $page = (isset($_GET['page']))? ($_GET['page']-1) :0; 
        $displayLimit = config('constants.page_limit'); 
        $numOfPages = 0;
 
        $customers = new ParseQuery("_User");
        $customers->equalTo("userType", "customer");
        
        if($type == 'LIST')
        {
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
            
            $request = new ParseQuery("Request");
            $request->equalTo("customerId", $customer);
            $requestData = $request->find();
            $requestMadeCount = count($requestData);
            $deliverStatusCount = $requestSuccessfullCount = $requestCancelledCount = $requestExpiredCount = 0;
            foreach($requestData as $request)
            {   
                $datetime1 = date('Y-m-d H:i:s');
                $datetime2 = $request->getCreatedAt()->format('Y-m-d H:i:s');
                $interval = $this->date_diff($datetime1, $datetime2);  
                if($interval>=1)
                    $requestExpiredCount = $requestExpiredCount+1;
                
                if($request->get("status")=='cancelled')
                    $requestCancelledCount = $requestCancelledCount+1;
                
                if($request->get("status")=='successfull')
                    $requestSuccessfullCount = $requestSuccessfullCount+1;
                
                if($request->get("deliverStatus")=='failed')
                    $deliverStatusCount = $deliverStatusCount+1;
                
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
        $customer['name'] = $customerData->get("displayName"); 
        $customer['address'] = $customerData->get("address"); 
        $customer['area'] = $customerData->get("area"); 
        $customer['city'] = $customerData->get("city");
        
        $request = new ParseQuery("Request");
        $request->equalTo("customerId", $customerData);
        $request->includeKey('product');
        $request->includeKey('category');
        $requestData = $request->find();
        
        $requests =$product =[];
        foreach($requestData as $request)
        {
 
            $requests[] =[
                            'productName'=>$request->get("product")->get("name"),
                            'mrp'=>$request->get("product")->get("mrp"),
                            'category'=>$request->get("category")->get("name"),
                            'status'=>$request->get("status"),
                         ] ;
            
 

        }
 
 
        return view('admin.customerdetails')->with('customer',$customer)
                                            ->with('requests',$requests);
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
