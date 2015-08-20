@extends('layouts.master') 
@section('content')
<div class="content">  
       <button type="button" class="btn btn-default btn-cons pull-right" onclick="location.href='{{ url('admin/smsverify/smsverifyexport') }}'"><i class="fa fa-download"></i> Download CSV</button>
		<div class="page-title m-l-5">	
			<h3 class="inline"><span class="semi-bold">SMS Verify</span> List</h3>
		</div>
		<div class="grid simple vertical purple">
      
			<h4 class="grid-title">List Of SMS verify</h4>
			<div class="grid-body">
         <table class="table table-bordered sellerList" id="example2">
          <thead>
            <tr>
              <th>Name</th>
              <th>User Type</th>
              <th>Phone</th>
              <th>Verification Code</th>
              <th>Attempt</th>
              <th class="date-sort">Update At</th>
            </tr>
          </thead>
          <tbody>
           @foreach($smsVerifyList as $smsVerify)
              <tr>
                <td>{{ $smsVerify['name'] }}</td>
                <td>{{ $smsVerify['userType'] }}</td>
                <td>{{ $smsVerify['phone'] }}</td>
                <td>{{ $smsVerify['verificationCode'] }}</td>
                <td>{{ $smsVerify['attempts'] }}</td>
                <td class="center">{{ $smsVerify['updatedAt'] }}</td>
              </tr>
           @endforeach
          </tbody>
         </table>
 
         <?php echo displayPagination( $page, $numOfPages , 'admin/smsverify' ) ?>       
                        </div>
		</div>
    </div> 
@endsection