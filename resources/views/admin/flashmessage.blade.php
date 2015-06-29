   @if(Session::has('success_message'))
    <div class="alert alert-success">
    <button class="close" data-dismiss="alert"></button>
    <i class="fa fa-check-circle" style="font-size: 17px;"></i> {{ Session::get('success_message')}}
  </div>  
    @endif
   @if(Session::has('error_message'))
    <div class="alert alert-danger">
    <button class="close" data-dismiss="alert"></button>
    <i class="fa fa-error" style="font-size: 17px;"></i>
        @if(is_array(Session::get('error_message')))
            <ul>
            @foreach(Session::get('error_message') as $error)
                <li> {{ $error }}</li>
            @endforeach
            </ul>    
        @else    
            {{ Session::get('error_message') }}
        @endif
  </div>  
    @endif
 