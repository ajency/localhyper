$.ajaxSetup({
    headers: {
        'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content')
    }
});

function getChildCategory(obj) {
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
}

function showAttibuteExport()
{
    var department = $("select[name='department']").val(); 
    var category = $("select[name='category']").val();
    var filterable = $("select[name='filterable']").val();
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
    
    if(filterable =='')
    {
        alert('Please Select Filterable');
        error = true;
    }
    
    if(!error){
        var url = URL +'/admin/attribute/exportattributes/'+category+'/'+filterable;
        $(".export_attributes").attr('href',url);
        $(".export_block").removeClass('hidden');
    
    }
    else
        $(".export_attributes").attr('href','#');
    
}
