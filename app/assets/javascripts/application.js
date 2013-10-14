    // This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui.min
//= require_tree .

$(document).ready(function(){

    $("img").tooltip();

    // This is used for validation when the user first tries to create a pmu object for an event
    $("a#validation").click(function(e){
        $("#validation_modal").modal();
    });

    //This is the actual AJAX command that sends the code that user has input to the server and checks whether it's vaild or not
    $("#validation_form").submit(function(e){
        e.preventDefault();
        $.ajax({
            url: "/events/"+$("#event").val()+"/confirm",
            data: {
                code: $("#validation_code").val()
            },
            success:function(data){
              //If correct,
              if(data.confirmed){
                $("#validation_modal").modal('hide');

                // Direct the user to actual PMU creation page
                window.location.href = "/events/"+ $("#event").val() + "/pmus/new";
                return true;
              }else{
                $("#info_validation").addClass("validationError");
                $("#info_validation").text("Wrong verification code!");
                return false;
              }
            },
            type: 'POST'
        })
    });

    //PMU confirmation information modal
    $("a#pmu_about_code_modal_toggle").click(function(e){
        $("#pmu_about_code_modal").modal();
    });

    //CSV about modal
    $("a#about_csv_modal_toggle").click(function(e){
        $("#about_csv_modal").modal();
    })

    // Popup window for the Organizer login
    $("a#organizer_log_in").click(function(e){
        $("#organizer_login_modal").modal();
    });

    $("a#driving_modal_toggle").click(function(e){
        $("#driving_modal").modal();
    });

    $("a#driving_modal_toggle2").click(function(e){
        $("#driving_modal2").modal();
    });

    $("a#driving_request_join_modal_toggle").click(function(e){
        $("#driving_request_join_modal").modal();
    });

    /*
    This handles the logic behind the checkboxes in the PMU form
     For example, If the user tries to request for cab sharing, he won't be able to request driving a car.
     */

    $("input:checkbox[name=sharing_type]").change(function(e){
        if($("#car_share_toggle").is(':checked')){
            if($("#cab_share_toggle").is(':checked')){
                $("#drive_radio").attr("disabled",true);
            }else{
                $("#drive_radio").attr("disabled",false);
            }

            $("#ride_radio").attr("disabled",false);
            $("#no_share_toggle").attr("disabled",true);
        }else{
            $("#drive_radio").attr("disabled",true);
            $("#ride_radio").attr("disabled",true);

            if($("#cab_share_toggle").is(':checked')){
                $("#no_share_toggle").attr("disabled",true);
            }else if($("#no_share_toggle").is(':checked')){
                $("#car_share_toggle").attr("disabled",true);
                $("#cab_share_toggle").attr("disabled",true);
            }else if(!($("#no_share_toggle").is(':checked')) && $("#car_share_toggle").is(':disabled') && $("#cab_share_toggle").is(':disabled')){
                $("#car_share_toggle").attr("disabled",false);
                $("#cab_share_toggle").attr("disabled",false);
            }else if(!($("#cab_share_toggle").is(':checked'))){
                $("#no_share_toggle").attr("disabled",false);
            }
        }
    });

    // JQuery UI for the datetimepicker
    $('.datetime').datetimepicker(
      {dateFormat: 'yy-mm-dd ',
      ampm: true,
      timeFormat: 'HH:mm z',
      timezone: '-0400',
      stepMinute: 15,
      showTimezone: true});

    // Search input box for live search of the suggested users
    $("#search_box").keyup(function() {
        $.get($("#name_search").attr("action"), $("#name_search").serialize(), null, "script");
        return false;
    });

    // live filtering of location and datetime
    $("#location,#time").on('change',function() {
        $.get($("#name_search").attr("action"), $("#name_search").serialize(), null, "script");
        return false;
    });

   // live search based on facebook friends
   $("#friends").change(function() {
        $.get($("#name_search").attr("action"), $("#name_search").serialize(), null, "script");
        return false;
    });
});

// Triggers "Details" modal about the request, when the user presses "Details" button on the suggested users.
var pmuToggle=function(id){
    $("#pmu_modal_"+id).modal();
}
