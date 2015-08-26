@extends('layouts.master') 
@section('content')
<div class="content">  
      <ul class="breadcrumb">
        <li>
          <p>List of Customers</p>
        </li>
        <li><a href="#" class="active">{{ $customer['name']}}</a></li>
      </ul>
      


      
<ul class="nav nav-tabs" id="tab-4">
<li class="{{ (!$showRequest)?'active':'' }}"><a href="#tab4hellowWorld">Customer Details</a></li>
<li class="{{ ($showRequest)?'active':'' }}"><a href="#tab4FollowUs">Customer Request History</a></li>

</ul>
<div class="grid simple vertical purple">
<div class="tab-content">
<div class="tab-pane {{ (!$showRequest)?'active':'' }}" id="tab4hellowWorld">
  <div class="user-description-box">
                  <h4 >{{ $customer['name']}}</h4>
                     <!--<p>johnsmith@gmail.com</p>-->
                      <p>{{ $customer['username']}}</p>
               
             </div>
            <h5><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold text-info">ADDRESS DETAILS</span></h5>
               <div class="user-description-box">
                <div class="row">
                <div class="col-md-6">
                <p>{{ (isset($customer['address']['address_line1']))?$customer['address']['address_line1'] :''}}</p>
                <p>{{ (isset($customer['address']['address_line2']))?$customer['address']['address_line2'] :''}}</p>
                <p>{{ (isset($customer['address']['address_line3']))?$customer['address']['address_line3'] :''}},</p>
                <p>{{ $customer['address']['city']}},</p>
                <p>{{ $customer['address']['postal_code']}}</p>
                <strong>Area : </strong><span> {{ $customer['area']}}, {{ $customer['city']}}</span>
              </div>
      
            </div>
            </div>
            
</div>
<div class="tab-pane {{ ($showRequest)?'active':'' }}" id="tab4FollowUs">
<table class="table table-bordered" id="example2">
          <thead>
            <tr>
              <th>Product Name</th>
              <th>Category</th>
              <th>MRP</th>
              <th>Online Price</th>
              <th>Sold Price</th>
              <th>Diff. From Online Price</th>
              <th>Request Status</th>
            </tr>
          </thead>
          <tbody>
              @foreach($requests as $request)
              <tr>
                <td>{{ $request['productName'] }}</td>
                <td>{{ $request['category'] }}</td>
                <td>{{ $request['mrp'] }}</td>
                <td>{{ $request['onlinePrice'] }}</td>
                 <td>{{ $request['soldPrice'] }}</td>
                <td>{{ $request['priceDiff'] }}</td>
                <td>{{ $request['status'] }}</td>
               </tr>
               @endforeach
          </tbody>
         </table>
 
 
    <?php echo displayPagination( $page, $numOfPages , 'admin/customer/'.$customer['id'] ) ?>     
</div>

</div>
</div>

    </div>
@endsection