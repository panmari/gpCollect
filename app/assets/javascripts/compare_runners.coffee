$ ->
  $('#compare-runners-datatable').DataTable({
    filter: false,
    paging: false
    info: false,
    responsive: true,
    columnDefs: [
      { responsivePriority: 1, targets: [0, 5] },
      { responsivePriority: 2, targets: [4] },
      { responsivePriority: 3, targets: [3] },
      { responsivePriority: 4, targets: [1] },
      { responsivePriority: 5, targets: [2] },

      ]
  })
