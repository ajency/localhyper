@extends('app')

@section('content')
<div class="container">
	<div class="row">
		<div class="col-md-10 col-md-offset-1">
			<div class="panel panel-default">
				<div class="panel-heading">Home</div>

				<div class="panel-body">


				<div id="add-folder-div">
					<h5>Add a Category</h5>
					<hr>
					<div class="row">
						<div class="col-sm-4">
							<form id="add_project" method="POST" action="{{ url('admin/category') }}" data-parsley-validate>

								<div class="form-group fly-group">
							        <label class="fly-label classic">Category Name</label>           
							        <input type="text" class="form-control input-sm" id="" name="category_name" placeholder="Enter Category Name" data-parsley-required>
								</div>

							    <div class="form-group fly-group">
						            <label class="fly-label classic">Description </label>
						            <textarea class="form-control" rows="3" name="description" placeholder="Type your Description here"></textarea>
						        </div>

						        <div class="form-group fly-group">
						        	<label class="fly-label classic">Parent Category</label>

						        	<select class="form-control js-select-parent-folder-tree" name="parent_category" required=""data-parsley-required>
						        		<option value="">Select Parent</option>
						        		<option value="0">None</option>
						        		@foreach ($categories as $category)
						        		<option value="{{$category['cat_id']}}">{{$category['cat_name']}}</option>
						        		@endforeach
						        	</select> 
						        </div>
				                
							    <div class="form-group fly-group">
						            <label class="fly-label classic">Sort ID</label>
						        	<input type="text" class="form-control input-sm" id="" name="sort_id" placeholder="Enter sort id" data-parsley-required>
						                     
						        </div>	
							    <div class="form-group fly-group">
						            <label class="fly-label classic">Image Url</label>
						        	<input type="text" class="form-control input-sm" id="" name="image_url" placeholder="Enter image url" data-parsley-required>
						                     
						        </div>							        
						        <button type="submit" class="btn btn-primary btn-sm parsley-err-btn parsley-err-btn">Add New Category</button>
						        <a href="{{ url('admin/category') }}" class="btn btn-link">Cancel</a>
						        <input type="hidden" value="{{ csrf_token()}}" name="_token"/>

							</form>
						</div>
					</div>

				</div>
					
				</div>
			</div>
		</div>
	</div>
</div>
@endsection