$(document).ready ->
  $('a.destroy_page').off 'click'
  $('a.destroy_page').on 'click', (e)->

    destroy_button = $(this)
    href = destroy_button.attr('href')
    box = destroy_button.closest('.box')
    is_blog_entry = (box.closest('#blog_entries').size() > 0)

    box.trigger 'cancel'
    box.hide 'explode', 300, ->
      box.remove()

      # We trigger the request manually here in order not to
      # suppress the animation before.
      $.ajax({
        type: 'DELETE',
        url: href,
        success: (result) ->
          # If this is just a blog post, we don't need redirection.
          # If the current navable (Page) is destroyed, we need to redirect.
          Turbolinks.visit result.redirect_to unless is_blog_entry
        failure: (result) ->
          alert('Es ist etwas schief gegangen. Bitte laden Sie die Seite neu.')
      })

    return false

  if $('#page_settings_button') and $('#toolbar').size() > 0
    $('#page_settings_button').detach().appendTo($('#toolbar'))

$(document).on 'click', '.btn.publish_page', ->
  button = $(this)
  App.spinner.show(button)
  $.ajax({
    type: 'Post',
    url: button.attr('href'),
    success: (result) ->
      button.hide('highlight')
    failure: (result) ->
      console.log result
      alert('Es ist etwas schief gegangen. Bitte laden Sie die Seite neu.')
  })
  false
