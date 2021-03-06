$(document).on 'page:reloaded', ->
  $('.pdf-pages').each ->
    Galleria.run '.pdf-pages',
      responsive:true
      height:0.8
      transition: 'flash'
      swipe: true
      showInfo: false

    galleria = $('.pdf-pages').data('galleria')

    # listen to keyup event to support hotkey when preview slides
    $(document).keyup (event)->
      return if galleria.isFullscreen()
      switch event.which
        # left arrow key
        when 37 then galleria.prev()
        # right arrow key
        when 39 then galleria.next()
    $('.fullscreen').click ->
      galleria.enterFullscreen()
      false

  $likeSlideBtn = $('#like_slide_btn')
  $likeSlideBtn
    .on 'ajax:error', (xhr, data) ->
      noty({text: data.responseJSON.message})
    .on 'ajax:success', (xhr, data) ->
      $('#likes_count').text(data.likes_count)
      $likeSlideBtn.attr('disabled', 'disabled')

  $collectSlideBtn = $('#collect_slide_btn')
  $collectSlideBtn
    .on 'ajax:error', (xhr, data) ->
      noty({text: data.responseJSON.message})
    .on 'ajax:success', (xhr, data) ->
      $('#collections_count').text(data.collections_count)
      $collectSlideBtn.attr('disabled', 'disabled')

  $('.delete-slide-link').tooltip({placement: 'top'})

  $uploadForm = $('form#upload_form')
  if $uploadForm.length
    $selectFileBtn = $('#select_file')
    $uploadBtn = $('#upload')
    $uploadProgressBarContainer = $('#upload_progress_bar')
    $uploadProgressBar = $uploadProgressBarContainer.find('.progress-bar')

    $uploadForm.fileupload
      autoUpload: false
      add: (e, data) ->
        selectedFileName = data.files[0].name
        $uploadProgressBar.text selectedFileName
        $selectFileBtn.text(selectedFileName)
        $uploadBtn.unbind 'click'  # unbind previours bindings, otherwise the whole upload queue will be uploaded
        data.context = $uploadBtn.click ->
          uploadSlideForm = $(this).parents('form#upload_form');
          titleInput = uploadSlideForm.find("#title")
          descriptionInput = uploadSlideForm.find("#description")
          if (titleInput.val() == "") or (descriptionInput.val() == "")
            noty
              text: '请填写文稿的标题和简介'
              type: 'error'
          else
            $(this).text('上传讲稿中').attr('disabled', 'disabled')
            data.submit()
            false

      progressall: (e, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)

        # $uploadProgressBarContainer.show()
        $uploadProgressBar
          .css('width', "#{progress}%")
          .attr('aria-valuenow', progress)

      done: (e, data) ->
        slideUploadDoneHandler(data)

      failure: (e, data) ->
        console.log data

    $selectFileBtn.click ->
      $('#file').click()
      false

    slideUploadDoneHandler = (data) ->
      # hideAndResetProgressBar()
      resetUploadBtn()

      console.log data
      result = data.result
      if result.status == 'success'
        goToSlidePage(result.slide)
      else
        noty
          text: result.errors
          type: 'warning'

    hideAndResetProgressBar = ->
      $uploadProgressBarContainer.fadeOut()
      $uploadProgressBar
        .css('width', 0)
        .attr('aria-valuenow', 0)
        .text('')

    resetUploadBtn = ->
      $uploadBtn.text('重新上传').removeAttr('disabled')

    goToSlidePage = (slide) ->
      if slide.event_id
        location.href = "http://#{location.host}/events/#{slide.event_id}"
      else
        location.href = "http://#{location.host}/slides/#{slide.id}"

