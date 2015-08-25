@extends('layouts.master') 
@section('content')
<div class="content">  
       <button type="button" class="btn btn-default btn-cons pull-right" onclick="location.href='{{ url('admin/offers/offersexport') }}'"><i class="fa fa-download"></i> Download CSV</button>
		<div class="page-title m-l-5">	
			<h3 class="inline"><span class="semi-bold">Offer</span> List</h3>
		</div>
		<div class="grid simple vertical purple">
      
			<h4 class="grid-title">List Of Offers</h4>
			<div class="grid-body">
         <table class="table table-bordered sellerList" id="example2">
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
           @foreach($offerList as $offer)
              <tr  onclick="location.href='{{ url('admin/requests/'.$offer['requestId']) }}'">
                <td>{{ $offer['productName'] }}</td>
                <td>{{ $offer['modelNo'] }}</td>
                  <td><a href="{{ url('admin/seller/'.$offer['sellerId']) }}">{{ $offer['sellerName'] }}</a></td>
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
 
    <?php echo displayPagination( $page, $numOfPages , 'admin/offers' ) ?> 
    </div>
		</div>
    </div> 
@endsection