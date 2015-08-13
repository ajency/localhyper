<!DOCTYPE html>
<html>
<head>
<meta http-equiv="content-type" content="text/html;charset=UTF-8" />
<meta charset="utf-8" />
<title>LocalHyper</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
<meta content="" name="description" />
<meta content="" name="author" />
<meta name="csrf-token" content="{{ csrf_token() }}" />    
    
<!-- BEGIN PLUGIN CSS -->
<link href="{{ asset('plugins/pace/pace-theme-flash.css') }}" rel="stylesheet" type="text/css" media="screen"/>
<!-- END PLUGIN CSS -->
<!-- BEGIN CORE CSS FRAMEWORK -->
<link href="{{ asset('plugins/boostrapv3/css/bootstrap.min.css') }}" rel="stylesheet" type="text/css"/>
<link href="{{ asset('plugins/boostrapv3/css/bootstrap-theme.min.css') }}" rel="stylesheet" type="text/css"/>
<link href="{{ asset('plugins/font-awesome/css/font-awesome.css') }}" rel="stylesheet" type="text/css"/>
<link href="{{ asset('css/animate.min.css') }}" rel="stylesheet" type="text/css"/>

<link href="{{ asset('plugins/jquery-scrollbar/jquery.scrollbar.css') }}" rel="stylesheet" type="text/css"/>
<!-- END CORE CSS FRAMEWORK -->
<!-- BEGIN CSS TEMPLATE -->
<link href="{{ asset('plugins/select2/select2_metro.min.css') }}" rel="stylesheet" type="text/css" media="screen">
<link href="{{ asset('css/style.css') }}" rel="stylesheet" type="text/css"/>
<link href="{{ asset('css/responsive.css') }}" rel="stylesheet" type="text/css"/>
<link href="{{ asset('css/custom-icon-set.css') }}" rel="stylesheet" type="text/css"/>
<script>
    var BASEURL = '{{ url() }}';
    var JAVASCRIPT_KEY = '{{ config("constants.parse_sdk.javascript_key") }}';
    var APPLICATION_ID = '{{ config("constants.parse_sdk.app_id") }}';
    var REST_API_KEY = '{{ config("constants.parse_sdk.rest_api_key") }}';

</script>
<script src="{{ asset('plugins/jquery-1.8.3.min.js') }}" type="text/javascript"></script>     
<!-- END CSS TEMPLATE -->

</head>
<!-- END HEAD -->

<!-- BEGIN BODY -->
<body class="">
<!-- BEGIN HEADER -->

<!-- END HEADER -->
<div class="page-container row-fluid">
 
  
  <!-- END SIDEBAR --> 
  <!-- BEGIN PAGE CONTAINER-->
<div class="page-content no-sidebar"> 
    <!-- BEGIN SAMPLE PORTLET CONFIGURATION MODAL FORM-->
 
  @yield('content')

<!-- END CHAT --> 
 </div>     
 </div>    
 
<script type="text/javascript" src="http://www.parsecdn.com/js/parse-1.4.2.min.js"></script> 
<script src="{{ asset('plugins/boostrapv3/js/bootstrap.min.js') }}" type="text/javascript"></script> 


</body>
</html>
