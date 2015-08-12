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
         <table class="table table-bordered sellerList">
          <thead>
            <tr>
              <th>Name</th>
              <th>User Type</th>
              <th>Phone</th>
              <th>Verification Code</th>
              <th>Attempt</th>
              <th>Update At</th>
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
                <td>{{ $smsVerify['updatedAt'] }}</td>
              </tr>
           @endforeach
          </tbody>
         </table>
        
        @if($numOfPages > 1)        
            Page : <select name="number_of_pages" onchange="location.href='{{ url('admin/smsverify') }}?page='+this.value">
            @for($i=1 ;$i<=$numOfPages ;$i++)
            <option {{ ($i == $page)?'selected':'' }}  value="{{ $i }}">{{ $i }}</option>                         
            @endfor
            </select>  
        @endif    
                        </div>
		</div>
    </div> 
@endsection