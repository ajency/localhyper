@extends('app')

@section('content')
<div class="container">
	<div class="row">
		<div class="col-md-10 col-md-offset-1">
			<div class="panel panel-default">
				<div class="panel-heading">Home</div>

				<div class="panel-body">
					<div class="row">
						<a class="btn btn-primary pull-right" href="admin/category/create"><i class="fa fa-plus"></i> Add Category</a>
					</div>
					<br/>
					<br/>
					<div class="row">
						<a class="btn btn-primary pull-right" href="admin/attribute/create"><i class="fa fa-plus"></i> Add Attributes</a>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
@endsection