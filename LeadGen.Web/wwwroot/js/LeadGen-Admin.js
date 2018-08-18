moment.locale('ru');
$(document).ready(function () {

    //Override unobtrusive date validation to work with russian locale
    //http://stackoverflow.com/questions/15147080/unobtrusive-validation-on-en-gb-dates
    $.validator.methods.date = function (value, element) {
        if (value) {
            //https://github.com/moment/moment/issues/665
            return (moment(value, "L").isValid());
        } else {
            return true;
        }

    }

    //Enable datetime pickers
    $(".datetimepicker").datetimepicker({
        locale: 'en',
        allowInputToggle: true
        //format: 'DD.MM.YYYY'
    })


    $('.search-orders [type="submit"]').click(function () {
        $('#LoadingWindowSplash').show();
    });
    $('ul.pagination li a').click(function () {
        $('#LoadingWindowSplash').show();
    });
    $('.nav-orders a').click(function () {
        $('#LoadingWindowSplash').show();
    });

});