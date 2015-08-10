<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Parse\ParseObject;
use Parse\ParseQuery;
use App\Http\Requests;
use App\Http\Controllers\Controller;

class SmsVerifyController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Response
     */
    public function index()
    {
        $smsVerify = new ParseQuery("SMSVerify");
        $smsVerifyData = $smsVerify->find();   
        $smsVerifyList =[];
        
        foreach($smsVerifyData as $data)
        {  
            
             $smsVerifyList[]= [  'id' => $data->getObjectId(),
                                  'name' => $data->get("displayName"),
                                  'userType' => $data->get("userType"),
                                  'phone' => $data->get("phone"),
                                  'verificationCode' => $data->get("verificationCode"),
                                  'attempts' => $data->get("attempts"),    
                                  'updatedAt' => $data->getUpdatedAt()->format('d-m-Y'),    
                              ];
            
        }  
        return view('admin.smsverifylist')->with('smsVerifyList',$smsVerifyList);
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
