@extends('layouts.master') 
@section('content')
<div class="content">  
      <ul class="breadcrumb">
        <li>
          <p>List of Sellers</p>
        </li>
        <li><a href="#" class="active">{{ $seller['name']}}</a></li>
      </ul>
      <!--<div class="pull-right">
        <button type="button" class="btn btn-default btn-cons" ><i class="fa fa-pencil"></i> Edit</button>
      </div>-->


      
<ul class="nav nav-pills" id="tab-4">
<li class="{{ (!$showOffers)?'active':'' }}"><a href="#tab4hellowWorld">View Seller Information</a></li>
<li  class="{{ ($showOffers)?'active':'' }}"><a href="#tab4FollowUs">View Offer History</a></li>

</ul>
<div class="grid simple vertical purple">
<div class="tab-content">
<div class="tab-pane  {{ (!$showOffers)?'active':'' }}" id="tab4hellowWorld">
  <div class="user-description-box">
                <div class="row">
                  <div class="col-md-6">
                    <div class="row">
                      <div class="col-md-6">
                          <h4 class="semi-bold">Business Name :</h4>
                          <p><strong>Seller Name : </strong></p>
                          <!-- <p><strong>Email : </strong></p> -->
                          <p><strong>Mobile : </strong></p>
                          <p><strong>Delivery Area : </strong></p>
                      </div>
                      <div class="col-md-6">
                          <h4  class="semi-bold">{{ $seller['businessname']}}</h4>
                          <p>{{ $seller['name']}}</p>
                          <!-- <p>{{ $seller['email']}}</p> -->
                          <p>{{ $seller['mobile']}}</p>
                          <p>{{ $seller['deliveryRadius']}} kms from seller location</p>
                      </div>
                    </div>
                    
                  </div>
                  <!--<div class="col-md-2 text-center">
                     <h5 class="text-warning semi-bold m-b-30">Auto Bid</h5>  
                     <input type="checkbox" checked data-toggle="toggle" data-size="mini">
                  </div>
                  <div class="col-md-4 text-right">
                    <h5 class="text-warning semi-bold">Credit Counts Left : -</h5>  
                     <button type="button" class="btn btn-primary btn-info m-t-20" data-toggle="modal" data-target="#myModal"><i class="fa fa-dollar"></i> Add Credits</button>
                  </div>-->
                </div>
             </div>
            <h5><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold text-info">SHOP LOCATION</span></h5>
               <div class="user-description-box">
                <div class="row">
                <div class="col-md-6">
                <p>{{ (isset($seller['address']['address_line1']))?$seller['address']['address_line1'] :''}}</p>
                <p>{{ (isset($seller['address']['address_line2']))?$seller['address']['address_line2'] :''}}</p>
                <p>{{ (isset($seller['address']['address_line3']))?$seller['address']['address_line3'] :''}},</p>
                <p>{{ $seller['address']['city']}},</p>
                <p>{{ $seller['address']['postal_code']}}</p>
                <strong>Area : </strong><span> {{ $seller['area']}}, {{ $seller['city']}}</span>
              </div>
               
            </div>
            </div>
             <h5><i class="fa fa-angle-double-right text-muted"> </i> <span class="semi-bold text-info">PRODUCT CATEGORIES</span></h5>
            <div class="user-description-box">
                @foreach($seller['categories'] as $category)
                    <span class="label">{{ $category }}</span>
                @endforeach
            </div>
</div>
<div class="tab-pane  {{ ($showOffers)?'active':'' }}" id="tab4FollowUs">
<table class="table table-bordered" id="example2">
          <thead>
            <tr>
              <th class="date-sort">Date</th>
              <th>Product Name</th>
              <th>Category</th>
              <th>Offer Amount</th>
              <th>Offer Status</th>
              <th>Credits Used</th>
              <!--<th>Auto Bid</th>-->
            </tr>
          </thead>
          <tbody>
              @foreach($selleroffers as $offer)
              <tr>
                <td class="center">{{ $offer['date'] }}</td>
                <td>{{ $offer['productName'] }}</td>
                <td>{{ $offer['category'] }}</td>
                <td>{{ $offer['offerAmt'] }}</td>
                <td><span class="label label-info">{{ $offer['status'] }}</span></td>
                  <td>{{ $offer['creditUsed'] }}</td>
                <!--<td class="text-center">-</td>-->
              </tr>
              @endforeach
          </tbody>
         </table>
 
    <?php echo displayPagination( $page, $numOfPages , 'admin/seller/'.$seller['id'] ) ?>    
</div>

</div>
</div>

    </div>
@endsection