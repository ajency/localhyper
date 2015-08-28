@extends('app')

@section('content')
<div class="content col-md-offset-3 col-md-6 login">  
    
		<div class="page-title m-l-5">	
			<h3 class="inline"><span class="semi-bold">Login</span></h3>
		</div>
		<div class="grid simple">
      		<div class="grid-body">
            	@if (count($errors) > 0)
						<div class="alert alert-danger">
							<strong>Whoops!</strong> There were some problems with your input.<br><br>
							<ul>
								@foreach ($errors->all() as $error)
									<li>{{ $error }}</li>
								@endforeach
							</ul>
						</div>
					@endif

					<form id="login-form" class="login-form" role="form" method="POST" action="{{ url('/auth/login') }}">
						<input type="hidden" name="_token" value="{{ csrf_token() }}">
<div class="row">
<div class="form-group col-md-12">
<label class="form-label">E-Mail Address</label>
<div class="controls">
<div class="input-with-icon  right">
<i class=""></i>
<input type="email" class="form-control" name="email" value="{{ old('email') }}">
</div>
</div>
</div>
</div>
<div class="row">
<div class="form-group col-md-12">
<label class="form-label">Password</label>
<span class="help"></span>
<div class="controls">
<div class="input-with-icon  right">
<i class=""></i>
<input type="password" class="form-control" name="password">
</div>
</div>
</div>
</div>
<div class="row">
<div class="control-group  col-md-12">
<div class="checkbox checkbox check-success"> <a href="{{ url('/password/email') }}">Trouble login in?</a>&nbsp;&nbsp;
<input type="checkbox" id="checkbox1" value="1">
<label for="checkbox1">Keep me reminded </label>
</div>
</div>
</div>
<div class="row">
<div class="col-md-12">
<button class="btn btn-primary btn-cons pull-right" type="submit">Login</button>
</div>
</div>
</form>

					<!-- <form class="form-horizontal" role="form" method="POST" action="{{ url('/auth/login') }}">
						<input type="hidden" name="_token" value="{{ csrf_token() }}">

						<div class="form-group">
							<label class="col-md-5 control-label">E-Mail Address</label>
							<div class="col-md-7">
								<input type="email" class="form-control" name="email" value="{{ old('email') }}">
							</div>
						</div>

						<div class="form-group">
							<label class="col-md-5 control-label">Password</label>
							<div class="col-md-7">
								<input type="password" class="form-control" name="password">
							</div>
						</div>

						<div class="form-group">
							<div class="col-md-6 col-md-offset-4">
								<div class="checkbox">
									<label>
										<input type="checkbox" name="remember"> Remember Me
									</label>
								</div>
							</div>
						</div>

						<div class="form-group">
							<div class="col-md-6 col-md-offset-4">
								<button type="submit" class="btn btn-primary">Login</button>

								<a class="btn btn-link" href="{{ url('/password/email') }}">Forgot Your Password?</a>
							</div>
						</div>
					</form> -->
			
			
                        </div>
		</div>
    </div>

@endsection
