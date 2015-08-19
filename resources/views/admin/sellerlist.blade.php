@extends('layouts.master') 
@section('content')
<div class="content">  
       <button type="button" class="btn btn-default btn-cons pull-right" onclick="location.href='{{ url('admin/seller/sellerexport') }}'"><i class="fa fa-download"></i> Download CSV</button>
		<div class="page-title m-l-5">	
			<h3 class="inline"><span class="semi-bold">Sellers</span> List</h3>
		</div>
		<div class="grid simple vertical purple">
      
			<h4 class="grid-title">List Of Sellers</h4>
			<div class="grid-body">
         <table class="table table-bordered sellerList">
          <thead>
            <tr>
              <th>Seller Name</th>
              <th>Area</th>
              <th>Brands</th>
              <th>Category</th>    
              <th>Response Ratio</th>
              <th>No. of Successfull Offers</th>
              <th>Avg Ratings</th>
              <th>Balance Credits</th>
              <th>Registered Date</th>
              <th>Last Login</th>
            </tr>
          </thead>
          <tbody>
           @foreach($sellers as $seller)
              <tr >
                <td onclick="location.href='{{ url('admin/seller/'.$seller['id']) }}'">{{ $seller['name'] }}</td>
                <td onclick="location.href='{{ url('admin/seller/'.$seller['id']) }}'">{{ $seller['area'] }}</td>
                <td onclick="location.href='{{ url('admin/seller/'.$seller['id']) }}'">{{ $seller['brands'] }}</td>  
                <td onclick="location.href='{{ url('admin/seller/'.$seller['id']) }}'">{{ $seller['categories'] }}</td>
                <td onclick="location.href='{{ url('admin/seller/'.$seller['id']) }}'">{{ $seller['offersCount'] }}</td>
                <td onclick="location.href='{{ url('admin/seller/'.$seller['id']) }}'">{{ $seller['successfullCount'] }}</td>
                <td onclick="location.href='{{ url('admin/seller/'.$seller['id']) }}'">{{ $seller['avgRating'] }}</td>
                <td><span class="balance-credit" data-seller-id="{{ $seller['id'] }}">{{ $seller['balanceCredit'] }}</span> <a class="edit-balance-credit">edit</a></td>
                <td onclick="location.href='{{ url('admin/seller/'.$seller['id']) }}'">{{ $seller['createdAt'] }}</td>
                <td onclick="location.href='{{ url('admin/seller/'.$seller['id']) }}'">{{ $seller['lastLogin'] }}</td>
              </tr>
           @endforeach
          </tbody>
         </table>
 
     <?php echo displayPagination( $page, $numOfPages , 'admin/seller' ) ?>      
                
                        </div>
		</div>
    </div> 
@endsection