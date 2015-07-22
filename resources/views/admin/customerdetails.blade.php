@extends('layouts.master') 
@section('content')
<div class="content">  
      <ul class="breadcrumb">
        <li>
          <p>List of Customers</p>
        </li>
        <li><a href="#" class="active">{{ $customer['name']}}</a></li>
      </ul>
      


      
<ul class="nav nav-pills" id="tab-4">
<li class="active"><a href="#tab4hellowWorld">Customer Details</a></li>
<li><a href="#tab4FollowUs">Customer Request History</a></li>

</ul>
<div class="grid simple vertical purple">
<div class="tab-content">
<div class="tab-pane active" id="tab4hellowWorld">
  <div class="user-description-box">
                  <h4 >{{ $customer['name']}}</h4>
                     <!--<p>johnsmith@gmail.com</p>
                      <p>9158156284</p>-->
               
             </div>
            <h5><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold text-info">ADDRESS DETAILS</span></h5>
               <div class="user-description-box">
                <div class="row">
                <div class="col-md-6">
                <p>{{ $customer['address']['address_line1']}}</p>
                <p>{{ $customer['address']['address_line2']}}</p>
                <p>{{ $customer['address']['address_line3']}},</p>
                <p>{{ $customer['address']['city']}},</p>
                <p>{{ $customer['address']['postal_code']}}</p>
                <strong>Area : </strong><span> {{ $customer['area']}}, {{ $customer['city']}}</span>
              </div>
      
            </div>
            </div>
            
</div>
<div class="tab-pane" id="tab4FollowUs">
<table class="table table-bordered">
          <thead>
            <tr>
              <th>Product Name</th>
              <th>Category</th>
              <th>MRP</th>
              <th>Online Price</th>
              <th>Sold Price</th>
              <th>Diff. From Online Price</th>
              <th>Variants</th>
              <th>Request Status</th>
            </tr>
          </thead>
          <tbody>
              <tr>
                <td>Nexus</td>
                <td>Mobile</td>
                <td>Rs. 10000</td>
                <td>Rs. 8000</td>
                 <td>Rs. 6000</td>
                <td>Rs. 2000</td>
                <td>5%</td>
                <td>Closed</td>
               </tr>
               <tr>
                <td>Nexus</td>
                <td>Mobile</td>
                <td>Rs. 10000</td>
                <td>Rs. 8000</td>
                <td>Rs. 6000</td>
                <td>Rs. 2000</td>
                <td>5%</td>
                <td>Closed</td>
               </tr>
          </tbody>
         </table>
</div>

</div>
</div>

    </div>
@endsection