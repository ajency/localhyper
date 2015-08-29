@extends('layouts.master') 
@section('content')
<div class="content">  
      <ul class="breadcrumb">
        <li>
          <p>List of Requests</p>
        </li>
        <li><a href="#" class="active">Request</a></li>
      </ul>
      <!--<div class="pull-right">
        <button type="button" class="btn btn-default btn-cons" ><i class="fa fa-pencil"></i> Edit</button>
      </div>-->


      
<ul class="nav nav-tabs" id="tab-4">
<li class="active"><a href="#tab4hellowWorld">View Request Information</a></li>
<li  ><a href="#tab4FollowUs">View Request Offers</a></li>

</ul>
<div class="grid simple">
<div class="tab-content">
<div class="tab-pane active" id="tab4hellowWorld">
  <div class="user-description-box">
                <div class="row">
                  <div class="col-md-6">
                    <div class="row">
                      <div class="col-md-6">
                          <h4 class="semi-bold">Customer Name :</h4>
                          <p><strong>Category : </strong></p>
                          <p><strong>Product : </strong></p> 
                          <p><strong>Mrp : </strong></p>
                          <p><strong>Platform Price : </strong></p>
                          <p><strong>Request Address : </strong></p>
                          <p><strong>Area : </strong></p>
                          <p><strong>Offer Count : </strong></p>
                          <p><strong>Status : </strong></p>
                          <p><strong>Delivery Status : </strong></p>
                          <p><strong>Comments : </strong></p>
                          <p><strong>Date : </strong></p>  
                      </div>
                      <div class="col-md-6">
                          <h4  class="semi-bold">{{ $request['customerName'] }}</h4>
                          <p>{{ $request['category'] }}</p>
                          <p>{{ $request['productName'] }}</p>
                          <p>{{ $request['mrp'] }}</p>
                          <p>{{ $request['bestPlatformPrice']}}</p>
                          <p>{{ $request['address']['full'] }} 
                          </p>
                          <p>{{ $request['area'] }}</p>
                          <p>{{ $request['offerCount'] }}</p>
                          <p>{{ $request['status'] }}</p>
                          <p>{{ $request['deliveryStatus'] }}</p>
                          <p>{{ $request['comments'] }}</p>
                          <p>{{ $request['date'] }}</p>    
                      </div>
                    </div>
                    
                  </div>
                </div>
             </div>
      
</div>
<div class="tab-pane" id="tab4FollowUs"> 
<table class="table table-bordered" id="example2">
          <thead>
            <tr>
              <th>Product Name</th>
              <th>Model No</th>      
              <th>Seller Name</th>   
              <th>Mrp of Product</th>    
              <th>Online Price</th> 
              <th>Offer Price</th>    
              <th>Last Offer By Seller</th>      
              <th>Request Status</th>
              <th>Offer Status</th>  
              <th>Delivery Reason Failure</th>      
              <th class="date-sort">Created At</th>      
            </tr>
          </thead>
          <tbody>
           @foreach($offers as $offer)
              <tr >
                <td>{{ $offer['productName'] }}</td>
                <td>{{ $offer['modelNo'] }}</td>
                <td>{{ $offer['sellerName'] }}</td>
                <td>{{ $offer['mrpOfProduct'] }}</td>
                <td>{{ $offer['onlinePrice'] }}</td>
                <td>{{ $offer['offerPrice'] }}</td>
                <td>{{ $offer['lastOfferBySeller'] }}</td>
                <td>{{ $offer['requestStatus'] }}</td>
                <td>{{ $offer['offerStatus'] }}</td>  
                <td>{{ $offer['deliveryReasonFailure'] }}</td>
                <td class="center">{{ $offer['date'] }}</td>
              </tr>
           @endforeach
          </tbody>
         </table>
   
</div>

</div>
</div>

    </div>
@endsection