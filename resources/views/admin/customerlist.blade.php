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
         <table class="table table-bordered customerList">
          <thead>
            <tr>
              <th>Customer Name</th>
              <th>Customer Registered Date</th>
              <th>Customer Last Login</th>
              <th>No. Of Requests Created</th>
              <th>No. Of Requests Expired</th>
              <th>No. Of Requests Cancelled</th>
              <th>No. Of Requests Successfull</th>
              <th>No. Of Failed Delivery</th>
              <th>No. Of Pending Delivery</th>
              <th>No. Of Sent Delivery</th>    
            </tr>
          </thead>
          <tbody>
           @foreach($customers as $customer)
              <tr onclick="location.href='{{ url('admin/customer/'.$customer['id']) }}'">
                <td>{{ $customer['name'] }}</td>
                <td>{{ $customer['createdAt'] }}</td>
                <td>{{ $customer['lastLogin'] }}</td>
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