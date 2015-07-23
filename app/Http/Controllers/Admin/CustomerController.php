<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Parse\ParseObject;
use Parse\ParseQuery;
use App\Http\Requests;
use App\Http\Controllers\Controller;

class CustomerController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
        $customers = new ParseQuery("_User");
        $customers->equalTo("userType", "customer");
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
                
                if($customer->get("status")=='cancelled')
                    $requestCancelledCount = $requestCancelledCount+1;
                
                if($customer->get("status")=='successfull')
                    $requestSuccessfullCount = $requestSuccessfullCount+1;
                
                if($customer->get("deliverStatus")=='failed')
                    $deliverStatusCount = $deliverStatusCount+1;
                
            }
            
            /*$requestExpired = new ParseQuery("Request");
            $requestExpired->greaterThan("createdAt", date('Y-m-d H:i:s'));
            $requestExpiredCount = $requestExpired->count();
             
            
            $requestCancelled = new ParseQuery("Request");
            $requestCancelled->equalTo("status", 'cancelled');
            $requestCancelledCount = $requestCancelled->count();
            
            $requestSuccessfull = new ParseQuery("Request");
            $requestSuccessfull->equalTo("status", 'successfull');
            $requestSuccessfullCount = $requestSuccessfull->count();
            
            $deliverStatus = new ParseQuery("Request");
            $deliverStatus->equalTo("deliverStatus", 'failed');
            $deliverStatusCount = $deliverStatus->count();*/
            
             $customerList[]= ['id' => $custId,
                              'name' => $customer->get("displayName"),
                              'createdAt' =>$customer->getCreatedAt()->format('d-m-Y'),
                              'lastLogin' =>'',
                              'numOfRequest' =>$requestMadeCount,
                              'requestExpired' =>$requestExpiredCount,
                              'requestCancelled' =>$requestCancelledCount,
                              'requestSuccessfull' =>$requestSuccessfullCount,
                              'deliveryStatus' =>$deliverStatusCount,
                              ];   
 
            
        } 
        return view('admin.customerlist')->with('customers',$customerList);
    }
    
    public function date_diff($date2, $date1) { 
      $start_ts = strtotime($date1);
      $end_ts = strtotime($date2);
      $diff = $end_ts - $start_ts;
      return round($diff / 86400); 
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
        
        return view('admin.customerdetails')->with('customer',$customer);
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