$ ->
  $('#show-runners-datatable').DataTable({
    filter: false,
    paging: false
    columnDefs: [
      { type: 'de_date', targets: 0 }
    ]
  })
