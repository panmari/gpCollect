$ ->
  dt = $('#runners-datatable').DataTable({
    processing: true,
    serverSide: true,
    ajax: $('#runners-datatable').data('source'),
    paging: true,
    pagingType: 'full_numbers'
    columns: [
      {searchable: true, orderable: true, data: 'first_name'},
      {searchable: true, orderable: true, data: 'last_name'},
      {searchable: true, orderable: true, data: 'club_or_hometown'},
      {searchable: false, orderable: true, data: 'sex'},
      {searchable: false, orderable: true, data: 'nationality'},
      {searchable: false, orderable: true, data: 'runs_count'},
      {searchable: false, orderable: false, data: 'fastest_run_duration' },
      {searchable: false, orderable: false, data: 'runner_id' },
    ]
    "language": {
      "url": "/datatables." + window.locale + ".lang"
    }
    "createdRow": (row, data, index) ->
      runner_id = data['runner_id']
      # TODO(panmari): Add title attributes with hover hints.
      show_link = $('<a>', {class: 'btn btn-primary btn-sm', href: '/' + window.locale + '/runners/' + runner_id})
      show_link.html($('<i>', {class: 'fa fa-eye fa-lg'}))

      remember_link = $('<a>', {class: 'btn btn-info btn-sm', href: '#'})
      remember_link.attr('data-remember-runner', runner_id)
      remember_link.attr('data-remember-runner-name', data['first_name'] + ' ' + data['last_name'])
      remember_link.html($('<i>', {class: 'fa fa-lg'}))

      cell = $('td', row).eq(7)
      cell.empty()
      cell.append(show_link, remember_link)

    "aoColumnDefs": [
      # Add special class to buttons column.
      { "sClass": "buttons-column", "aTargets": [ 7 ] }
    ],
    "oSearch": {"sSearch": window.initial_search_term }
  })

  dt.on('draw', ->
    # Whenever the 'remember link is clicked, run this:
    $('a[data-remember-runner]').on('click', (e) ->
      e.preventDefault()
      id = $(this).data("remember-runner")
      name = $(this).data("remember-runner-name")
      toggle_remembered_runner(id, name)
    )
    update_all_remember_runner_icons()
  )

  update_all_remember_runner_icons = ->
    runner_hash = get_remembered_runners()
    $('a[data-remember-runner]').each ->
      id = $(this).data("remember-runner")
      update_remember_runner_icon(id, runner_hash, $(this).find('i'))

  get_remembered_runners = ->
    Cookies.getJSON('remembered_runners') || {}

  # Removes from remembered runners if present, adds otherwise. Name is only needed for adding, can be omitted removal.
  toggle_remembered_runner = (id, name) ->
    runner_hash = get_remembered_runners()
    if runner_hash[id]
    # Remove id from remembered runners.
      delete runner_hash[id]
    else
      runner_hash[id] = name
    Cookies.set('remembered_runners', runner_hash)
    update_remember_runner_icon(id, runner_hash, $('a[data-remember-runner=' + id + '] i'))
    update_remembered_runner_panel(runner_hash)
    update_remember_runner_link(runner_hash)


  update_remember_runner_icon = (id, runner_hash, icon) ->
    selected_icon = 'fa-star'
    deselected_icon = 'fa-star-o'
    if runner_hash[id]
      icon.removeClass(deselected_icon)
      icon.addClass(selected_icon)
    else
      icon.removeClass(selected_icon)
      icon.addClass(deselected_icon)

  update_remembered_runner_panel = (runner_hash) ->
    panel = $('#remembered-runners-panel')
    dismiss_button = '<button type="button" class="close" data-dismiss="alert" aria-label="Close"><span aria-hidden="true">&times;</span></button>'
    $('div[data-runner-id]').remove()
    runner_ids_sorted = Object.keys(runner_hash).sort( (a,b) ->
      -runner_hash[a].localeCompare(runner_hash[b])
    )
    for id in runner_ids_sorted
      name = runner_hash[parseInt(id)]
      link = $('<a>', {text: name, href: '/' + window.locale + '/runners/' + id})
      div = $('<div>', class: 'runner-alert alert alert-primary alert-dismissable')
      .append(link)
      .append(dismiss_button)
      .attr('data-runner-id', id)
      .on('close.bs.alert', ->
        toggle_remembered_runner(parseInt($(this).attr('data-runner-id')), null)
      ).prependTo(panel)

  update_remember_runner_link = (runner_hash) ->
    runner_ids = []
    for id, _ of runner_hash
      runner_ids.push(id)
    new_link = '/' + window.locale + '/runners/show_remembered?ids=' + runner_ids.join()
    $('#remembered-runners-link').attr('href', new_link)
    if runner_ids.length > 0
      $('.remembered-runners-interactible').removeClass('disabled')
      $('#remember-runners-hint').hide()
    else
      $('.remembered-runners-interactible').addClass('disabled')
      $('#remember-runners-hint').show()

  $('#runners-datatable').on('init.dt', ->
    # Only search after a minimum of 3 characters were entered
    searchWait = 0
    searchWaitInterval = null
    $('.dataTables_filter input')
      .unbind() # Unbind previous
      .bind('input', (e) ->
        item = $(this)
        searchWait = 0
        if !searchWaitInterval
          searchWaitInterval = setInterval(->
            if (item.val().length > 3 or item.val() == '') and searchWait >= 3
              clearInterval(searchWaitInterval)
              searchWaitInterval = null
              searchTerm = $(item).val()
              dt.search(searchTerm).draw()
              # TODO(panmari): Also push order of sorting (move this code to own function for that).
              history.pushState({"search": searchTerm}, '', '?locale=' + window.locale + '&search=' + searchTerm)
              searchWait = 0
            searchWait++
          ,200);
    )
  )

  $('a[data-forget-runners]').on('click', (e) ->
    e.preventDefault()
    Cookies.remove('remembered_runners')
    runner_hash = get_remembered_runners()
    update_remembered_runner_panel(runner_hash)
    update_all_remember_runner_icons()
    update_remember_runner_link(runner_hash)
  )
  update_remembered_runner_panel(get_remembered_runners())
  update_remember_runner_link(get_remembered_runners())

  # Going back one page pops the search state.
  $(window).bind('popstate', (event) ->
    if event.originalEvent.state
      searchTerm = event.originalEvent.state["search"]
    searchTerm ?= ''
    $('.dataTables_filter input').val(searchTerm)
    $('#runners-datatable').dataTable().api().search(searchTerm).draw()
  )
