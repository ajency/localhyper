@extends('layouts.master') 
@section('content')
<div class="content">  
       <button type="button" class="btn btn-default btn-cons pull-right"><i class="fa fa-download"></i> Download CSV</button>
		<div class="page-title m-l-5">	
			<h3 class="inline"><span class="semi-bold">Customers</span> List</h3>
		</div>
		<div class="grid simple vertical purple">
      
			<h4 class="grid-title">List Of Customers</h4>
			<div class="grid-body">
                           <table class="table table-bordered">
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
            </tr>
          </thead>
          <tbody>
              <tr onclick="location.href='single-customer.html'">
                <td>John Smith</td>
                <td>23-04-2014</td>
                <td>3 mins ago</td>
                <td>10</td>
                <td>5</td>
                <td>5</td>
                <td>0</td>
                <td class="text-center">0</td>
              </tr>
               <tr onclick="location.href='single-customer.html'">
                <td>Customer B</td>
                <td>23-04-2014</td>
                <td>3 mins ago</td>
                <td>10</td>
                <td>5</td>
                <td>5</td>
                <td>0</td>
                <td class="text-center">0</td>
              </tr>
          </tbody>
         </table>
                        </div>
		</div>
    </div>

@endsection