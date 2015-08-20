@extends('layouts.master') 
@section('content')
<div class="content">  
       <button type="button" class="btn btn-default btn-cons pull-right" onclick="location.href='{{ url('admin/customer/customersexport') }}'"><i class="fa fa-download"></i> Download CSV</button>
		<div class="page-title m-l-5">	
			<h3 class="inline"><span class="semi-bold">Customers</span> List</h3>
		</div>
		<div class="grid simple vertical purple">
      
			<h4 class="grid-title">List Of Customers</h4>
			<div class="grid-body">
         <table class="table table-bordered customerList" id="example2">
          <thead>
            <tr>
              <th colspan="3"></th>
              <th colspan="7" style="text-align: center;border-left: 1px solid #E1E2E2 !important;"> No of Requests</th>
            </tr>
            <tr>
              <th>Customer Name</th>
              <th class="date-sort">Customer Registered Date</th>
              <th class="date-sort">Customer Last Login</th>
              <th  style="border-left: 1px solid #E1E2E2 !important;">Created</th>
              <th>Expired</th>
              <th>Cancelled</th>
              <th>Successfull</th>
              <th>Failed Delivery</th>
              <th>Pending Delivery</th>
              <th>Sent Delivery</th>    
            </tr>
          </thead>
          <tbody>
           @foreach($customers as $customer)
              <tr onclick="location.href='{{ url('admin/customer/'.$customer['id']) }}'">
                <td>{{ $customer['name'] }}</td>
                <td class="center">{{ $customer['createdAt'] }}</td>
                <td class="center">{{ $customer['lastLogin'] }}</td>
                <td>{{ $customer['numOfRequest'] }}</td>
                <td>{{ $customer['requestExpired'] }}</td>
                <td>{{ $customer['requestCancelled'] }}</td>  
                <td>{{ $customer['requestSuccessfull'] }}</td>  
                <td>{{ $customer['deliveryStatus'] }}</td> 
                <td>{{ $customer['pendingDelivery'] }}</td> 
                <td>{{ $customer['sentDelivery'] }}</td>   
              </tr>
           @endforeach
          </tbody>
         </table>
 
          <?php echo displayPagination( $page, $numOfPages , 'admin/customer' ) ?> 
                
                        </div>
		</div>
    </div>

  
@endsection