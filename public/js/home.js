$(document).ready(function(){
  // Fake Random User Unique ID, I usually use Mixpanel or Kissmetrics UID here will a fallback function for people who block their JS libraries
  var uID = Math.floor((Math.random()*100)+1)


  // Instantiate Pusher
  var pusher = new Pusher('a92b1daa6fedc78d32a6', {
      encrypted: true
    });
  var channel = pusher.subscribe('sn_'+uID) // The Channel you want to subscribe to

  channel.bind('update', function(data) { // Bind to an event on our channel, in our case, update
    var messageBox = $('#fprogress-container').children('.messages')
    var progressBar = $('#realtime-progress-bar')

    progressBar.width(data.progress+"%")
    messageBox.html(data.message)
    $('#console').append('<p>' + data.message + '</p>');

    // Process is complete,Do whatever you want now, maybe redirect them to their freshly created account?
    if (data.progress == 100) {
      messageBox.html('Process Completed')
      
    }
  });

  // Submit the forms using AJAX, nothing to see here.
  $('form#fb-login').submit(function (e) {
    e.preventDefault();
    var username = $('#email').val() || ""
    var password = $('#password').val() || ""
    var form = this
    var btn = $(form).find('button')
    var progressBar = $('#progress-container').find('.progress')
    progressBar.removeClass('hide')
    $('#console').removeClass('hide')
    btn.prop('disabled', true)

    $.post( $(form).attr('action'),{email: username, password: password, uid: uID} , function () {
    }).done(function(response) {
      $('#final-output').append(response)
      $('#final-output').removeClass('hide')
      console.log('Finished')
      console.log(response)
      btn.prop('disabled', false)
      $('#final-output').removeClass('hide')
      //$('#final-output').append(response)
      progressBar.toggleClass('active')
      if (!$(form).attr('id')) {
        $(form).children('.messages').html(response)
        
      }
    })
  })
})