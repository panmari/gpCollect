$ ->
  $('#show-runners-datatable').DataTable({
    filter: false,
    paging: false
    info: false,
    responsive: true,
    columnDefs: [
      { type: 'de_date', targets: 0 },
      { responsivePriority: 1, targets: [0, 4] },
      { responsivePriority: 2, targets: [2, 3] },
    ]
  })
