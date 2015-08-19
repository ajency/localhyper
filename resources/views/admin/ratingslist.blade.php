@extends('layouts.master') 
@section('content')
<div class="content">  
       <button type="button" class="btn btn-default btn-cons pull-right" onclick="location.href='{{ url('admin/ratings/ratingsexport') }}'"><i class="fa fa-download"></i> Download CSV</button>
		<div class="page-title m-l-5">	
			<h3 class="inline"><span class="semi-bold">Ratings</span> List</h3>
		</div>
		<div class="grid simple vertical purple">
      
			<h4 class="grid-title">List Of Ratings</h4>
			<div class="grid-body">
         <table class="table table-bordered sellerList">
          <thead>
            <tr>
              <th>DATE</th>				
              <th>SELLER</th>
              <th>RATINGS</th>
              <th>COMMENTS</th>
              <th>CUSTOMER</th>
            </tr>
          </thead>
          <tbody>
           @foreach($ratingsList as $rating)
              <tr>
                <td>{{ $rating['date'] }}</td>
                <td>{{ $rating['ratingFor'] }}</td>
                <td>{{ $rating['count'] }}</td>
                <td>{{ $rating['comments'] }}</td>
                <td>{{ $rating['ratingBy'] }}</td>
              </tr>
           @endforeach
          </tbody>
         </table>
 
         <?php echo displayPagination( $page, $numOfPages , 'admin/ratings' ) ?>     
                        </div>
		</div>
    </div> 
@endsection