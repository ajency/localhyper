@extends('app')

@section('content')
<div class="container">
    <div class="row">
        <div class="col-md-10 col-md-offset-1">
            <div class="panel panel-default">
                <div class="panel-heading">Home</div>               

                <div class="panel-body">

                    <div class="page-title">    
                        <h2><span class="semi-bold">View</span> Categories</h2>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <div class="grid simple">
                                @include('admin.flashmessage')
                                <div class="grid-title">
                                    <h4>List of <span class="semi-bold">Categories</span></h4>

                                </div>
                                <div class="grid-body">
                                    <table class="table table-bordered" id="example2" >
                                        <thead>
                                            <tr>
                                                <th>Category Name</th>
                                                <th>Created On</th>
                                                <th>Modified On</th>
                                            </tr>
                                        </thead>
                                        <tbody> 
                                        @foreach ($categories as $category)
                                            <tr class="" onclick="location.href='{{ url( '/admin/category/' . $category['id']) }}'">
                                                <td>{{ $category['name'] }}</td>
                                                <td>{{ date_format($category['created_at'], 'Y-m-d H:i:s')  }}</td>
                                                <td>{{ date_format($category['modified_at'], 'Y-m-d H:i:s') }}</td>
                                            </tr>
                                        @endforeach
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div> 

                </div>
            </div>
        </div>
    </div>
</div>
@endsection    

