@extends('layouts.master') 
@section('content')
<div class="content">  
       <button type="button" class="btn btn-default btn-cons pull-right" onclick="location.href='{{ url('admin/requests/requestexport') }}'"><i class="fa fa-download"></i> Download CSV</button>
		<div class="page-title m-l-5">	
			<h3 class="inline"><span class="semi-bold">Request</span> List</h3>
		</div>
		<div class="grid simple vertical purple">
      
			<h4 class="grid-title">List Of Requests</h4>
			<div class="grid-body">
         <table class="table table-bordered sellerList" id="example2">
          <thead>
            <tr>
              <th>Customer Name</th>
              <th>Category</th>       
              <th>Product Name</th>   
              <th>Mrp</th>    
              <th>Online Price</th> 
              <th>Best Platform Price</th>      
              <th>Area</th>
              <th>Offer Count</th>  
              <th>Status</th>      
            </tr>
          </thead>
          <tbody>
           @foreach($requestList as $request)
              <tr>
                <td>{{ $request['customerName'] }}</td>
                <td>{{ $request['productName'] }}</td>
                <td>{{ $request['category'] }}</td>
                <td>{{ $request['mrp'] }}</td>
                <td>{{ $request['onlinePrice'] }}</td>
                <td>{{ $request['bestPlatformPrice'] }}</td>
                <td>{{ $request['area'] }}</td>
                <td>{{ $request['offerCount'] }}</td>
                <td>{{ $request['status'] }}</td>
              </tr>
           @endforeach
          </tbody>
         </table>
   
 <?php echo displayPagination( $page, $numOfPages , 'admin/requests' ) ?>               
                        </div>
		</div>
    </div> 
@endsection