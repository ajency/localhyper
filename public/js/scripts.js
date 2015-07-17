/*$.ajaxSetup({
    headers: {
        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
    }
});*/
var categorieData;

$( document ).ready(function() {
   $.ajax({
        async :true, 
        url: "https://api.parse.com/1/functions/getCategories",
        type: "POST",
        headers: {
                    "x-parse-application-id": "837yxeNhLEJUXZ0ys2pxnxpmyjdrBnn7BcD0vMn7",
                    "x-parse-rest-api-key": "zdoU2CuhK5S1Dbi2WDb6Rcs4EgprFrrpiWx3fUBy"
                  },
        data: {
            "sort_by": "popularity",
        },
        dataType: "JSON",
        success: function (response) {
          window.categorieData = response.result.data; 
            
          getDepartment();     
 
        }
    });
    
   
});

function getDepartment()
{   var temp= window.categorieData;
    var deparments = _.where(temp, {parent: null});

    $.each(deparments, function( index, items ) {
      str = '<option value="'+items.id+'">'+items.name+'</option>';    
      $('#department').append(str);
    });
    
}

function getChildCategory(obj) {
    var deparmentId =obj.value;  
    var temp= window.categorieData;
    var deparmentChildrens = _.where(temp, {id: deparmentId});
    var categoryData = deparmentChildrens[0].children;
    
    //Reset caregories
    $("select[name='category']").html('<option value="">Select Category</option>');
    $("select[name='category']").select2('val', '');
    $(".export_block").addClass('hidden');
    
    $.each(categoryData, function( index, items ) {
      str = '<option value="'+items.id+'">'+items.name+'</option>';    
      $("select[name='category']").append(str);
    });
    
}
/*function getChildCategory(obj) {
    var catId =obj.value;
    if(catId=='')
    {
        alert('Please Select Department');
        return;
    }
    $.ajax({
        url: "/admin/category/getchildcategories/"+catId,
        type: "POST",
        data: {
            catId: obj.value,
        },
        dataType: "JSON",
        success: function (response) {
            $("select[name='category']").html(response.data.html);
            $(".export_block").addClass('hidden');
 
        }
    });
}*/

$("select[name='category']").change(function(){
    $(".export_block").addClass('hidden');
});
    

function showAttibuteExport()
{
    var department = $("select[name='department']").val(); 
    var category = $("select[name='category']").val();
 
    var error = false;
    if(department =='')
    {
        alert('Please Select Department');
        error = true;
    }
    
    if(category=='')
    {
        alert('Please Select Category');
        error = true;
    }
 
    
    if(!error){
        var attributeUrl = BASEURL +'/admin/attribute/exportattributes/'+category;
        var productUrl = BASEURL +'/admin/product/exportproducts/'+category;
        $(".export_attributes").attr('href',attributeUrl);
        $(".export_product").attr('href',productUrl);
        
        $(".export_block").removeClass('hidden');
    
    }
    else
    {
        $(".export_attributes").attr('href','#');
        $(".export_product").attr('href','#');
    }
    
}
