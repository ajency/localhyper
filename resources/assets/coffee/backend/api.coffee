getCategoriesData =() ->
    $.ajax
        async: true
        url: 'https://api.parse.com/1/functions/getCategories'
        type: 'POST'
        headers:
            'x-parse-application-id': '837yxeNhLEJUXZ0ys2pxnxpmyjdrBnn7BcD0vMn7'
            'x-parse-rest-api-key': 'zdoU2CuhK5S1Dbi2WDb6Rcs4EgprFrrpiWx3fUBy'
        data: 'sort_by': 'popularity'
        dataType: 'JSON'
        success: (response) ->
            window.categorieData = response.result.data
            getDepartment()
            return

getDepartments =() ->
    temp = window.categorieData
    deparments = _.where(temp, parent: null)
    str = ''
    $.each deparments, (index, items) ->
      str = '<option value="' + items.id + '">' + items.name + '</option>'
      $('#department').append str
      return  
    
    
getChildCategory =() ->
    deparmentId = $('#department').val
    temp = window.categorieData
    deparmentChildrens = _.where(temp, id: deparmentId)
    categoryData = deparmentChildrens[0].children
    #Reset caregories
    $('select[name=\'category\']').html '<option value="">Select Category</option>'
    $('select[name=\'category\']').select2 'val', ''
    $('.export_block').addClass 'hidden'
    str = ''
    $.each categoryData, (index, items) ->
      str = '<option value="' + items.id + '">' + items.name + '</option>'
      $('select[name=\'category\']').append str
      return  
    

getCustomers =() ->
    query = new (Parse.Query)("User")
    query.equalTo("userType", "customer")
    query.find success: (list) ->
        return