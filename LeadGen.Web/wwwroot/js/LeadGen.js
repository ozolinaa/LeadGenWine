(function () {

    var LeadGen = window.LeadGen || (window.LeadGen = {});

    LeadGen.refreshUnobtrusiveValidation = function (formID) {
        var $form = $("#" + formID);
        //Refresh unobtrusive form validation (NEED REFRESH Validation TO HANDLE NEW FIELDS ERRORS)
        $form.removeData("validator").removeData("unobtrusiveValidation");
        $.validator.unobtrusive.parse($form);
    }

    LeadGen.ui = {
            //UI notifications
            showNotificationLabelForElement: function (addToElementID, labelText) {
                if (typeof labelText === "undefined" || labelText === null) {
                    labelText = "Success !";
                }
                labelText = '<span class="alert alert-success"><span>' + labelText + '</span></span>';
                $(labelText).insertAfter('#' + addToElementID).delay(1000).fadeOut(function () { $(this).remove(); });
            },
            showNotificationLabel: function (labelText, alertClass) {
                if (!labelText) {
                    labelText = "Success !";
                }
                if (!alertClass) {
                    alertClass = "success";
                }
                labelText = '<span class="NotificationLabel alert alert-' + alertClass + '"><span>' + labelText + '</span></span>';
                $('body').append(labelText);


                var fadeOutDelay = 2000;
                if (alertClass == 'danger') {
                    fadeOutDelay = fadeOutDelay * 3;
                };

                $('.NotificationLabel').delay(fadeOutDelay).fadeOut(function () { $(this).remove(); });
            },
            navigateToInputValidationError: function() {
                //Detect validation errors and focus on the input
                var invalidInputs = $('.input-validation-error,.field-validation-error');
                if (invalidInputs.length > 0)
                {
                    //http://stackoverflow.com/questions/18150090/jquery-scroll-element-to-the-middle-of-the-screen-instead-of-to-the-top-with-a
                    var $el = $(invalidInputs.toArray().reduce(function (a, b) {
                        return a.getBoundingClientRect().top < b.getBoundingClientRect().top ? a : b;
                    }));
                    var elOffset = $el.offset().top;
                    var elHeight = $el.height();
                    var windowHeight = $(window).height();
                    var offset;

                    if (elHeight < windowHeight) {
                        offset = elOffset - ((windowHeight / 2) - (elHeight / 2));
                    }
                    else {
                        offset = elOffset;
                    }

                    $('html, body').animate({
                        scrollTop: offset
                    }, 700);
                    $el.click().focus();
                }
        
            },
            window: {
                onResize: function () {
                    LeadGen.ui.window.adjustThumbnailGridItemsHeight();
                },
                adjustBodyPaddingTop: function () {
                    // apply dynamic padding at the top of the body according to the fixed navbar height
                    $("body").css("padding-top", $(".navbar-fixed-top").height());
                },
                adjustThumbnailGridItemsHeight: function () {
                    var items = $(".ThumbnailGrid .item");

                    if (items.length == 0)
                        return;

                    //set height to zero to make propper items destribution (using css)
                    items.css("height", 0);

                    var rows = [];
                    //distribute items in rows
                    var rowIndex = -1;
                    var lastTopPosition = -1;
                    items.each(function () {
                        var $el = $(this);
                        var elementTopPosition = $el.position().top;
                        if (elementTopPosition > lastTopPosition) {
                            lastTopPosition = elementTopPosition;
                            rowIndex++;
                            rows[rowIndex] = new Array();
                        }
                        rows[rowIndex].push($el);
                    });

                    //remove previously set height (make default height)
                    items.css("height", "");

                    //for each row change items height to the maxRowHeight
                    rows.forEach(function (row) {
                        var maxRowHeight = Math.max.apply(null, $(row).map(function () {
                            return $(this).height();
                        }).get());
                        row.forEach(function (item) {
                            item.css("height", maxRowHeight);
                        });
                    });



                    //    var topPosition = $el.position().top;

                    //    if (currentRowStart != topPosition) {
                    //        // we just came to a new row. Set all the heights on the completed row
                    //        for (currentDiv = 0 ; currentDiv < rowDivs.length ; currentDiv++)

                    //            setConformingHeight(rowDivs[currentDiv], currentTallest);
                    //        // set the variables for the new row rowDivs.length = 0; 
                    //        // empty the array 
                    //        currentRowStart = topPosition;
                    //        currentTallest = getOriginalHeight($el);
                    //        rowDivs.push($el);
                    //    }
                    //    else {
                    //        // another div on the current row. Add it to the list and check if it's taller 
                    //        rowDivs.push($el); currentTallest = (currentTallest < getOriginalHeight($el)) ? (getOriginalHeight($el)) : (currentTallest);
                    //    }
                    //});

                    //var maxHeight = Math.max.apply(null, items.map(function () {
                    //    return $(this).height();
                    //}).get());

                    //var images = $(".ThumbnailGrid .item img");
                    //var maxImageHeight = Math.max.apply(null, images.map(function () {
                    //    return $(this).height();
                    //}).get());

                    //if (maxImageHeight == 0)
                    //    maxHeight = maxHeight + 200;

                    //items.css("height", maxHeight);
                },
                redirectToUrlFromResponse: function (response) {
                    window.location.href = response.url;
                }
            },
            googleMapsActions: {
                initializeAll: function () {
                    //Check if there are any maps to initialize
                    if (LeadGen.googleMaps) {
                        //Load google maps library if needed
                        if ((window.google == null || window.google.maps == null)) {
                            var apiKey = LeadGen.settings.googleMapsAPIKey;
                            var file = "https://maps.googleapis.com/maps/api/js?key=" + apiKey + "&libraries=places";
                            //pass the same method as a callback this code will not be executed next time as window.google.maps will be initialized
                            LeadGen.util.loadScript(file, LeadGen.ui.googleMapsActions.initializeAll);
                            return;
                        }
                        //Initialize each visible map that is not yet initialized (instance == null)
                        for (var mapId in LeadGen.googleMaps) {
                            var map = LeadGen.googleMaps[mapId];
                            if (map.instance == null) {
                                if ($('#' + mapId).is(":visible")) {
                                    map.init();
                                }
                            }
                        }
                    }
                },
                refreshMapsInSelector: function (selector) {
                    if (!selector) {
                        selector = "body";
                    }
                    LeadGen.ui.googleMapsActions.initializeAll();
                    for (var mapId in LeadGen.googleMaps) {
                        if ($(selector).find("#" + mapId).length > 0) {
                            var map = LeadGen.googleMaps[mapId].instance;
                            if (map) {
                                google.maps.event.trigger(map, 'resize');
                                map.panTo(map.initialCenter);
                            }
                        }
                    }
                }
            },

    };

    LeadGen.order = {
        initializeCityCountrySwitch: function (args) {


            var setCountry = args.setCountry;

            var cityInputSelector = args.cityInputSelector;
            var countrySwitchWrapperID = args.countrySwitchWrapperID;
            var switchBegining = args.switchBegining;

            var countryData = args.countryData;
            var separator = args.separator;

            function switchCityCountry(setCountry) {
                if ($(cityInputSelector).attr("country") == setCountry) { return; }

                $(cityInputSelector + ' option').removeAttr('disabled');
                $(cityInputSelector + ' option[country!="' + setCountry + '"]').attr('disabled', true);

                var countryItem = $.grep(countryData, function (x) { return x.country == setCountry; })[0];

                $selectedOption = $(cityInputSelector + ' option[country="' + setCountry + '"]').filter(function () { return $(this).html() == countryItem.defaultText; });

                $(cityInputSelector).val($selectedOption.val());
                $(cityInputSelector).attr("country", setCountry)

                $('#' + countrySwitchWrapperID + ' span[data-country]').removeClass("active");
                $('#' + countrySwitchWrapperID + ' span[data-country="' + setCountry + '"]').addClass("active");

                $(cityInputSelector).select2();
            }

            function refactorCityCountry() {

                var currentCountryName;
                $(cityInputSelector + ' option').each(function (index) {
                    var name = $(this).text();
                    if (name.length == 0) { return }
                    if (name.substring(0, 1) != "-") {
                        currentCountryName = name
                    }
                    else {
                        //Add country attribute
                        $(this).attr('country', currentCountryName);
                        //Clear leading "-"
                        $(this).text(name.substring(1, name.length))
                    }
                });
            }

            function addCountrySelector() {

                $(cityInputSelector).after("<div id='" + countrySwitchWrapperID + "'>" + switchBegining + "</div>");

                countryData.forEach(function (element, index, list) {

                    if (index == list.length - 1) { separator = ""; }
                    $("#" + countrySwitchWrapperID).append("<span data-country='" + element.country + "'>" + element.display + "</span>" + separator);
                });

                $("#" + countrySwitchWrapperID + " span[data-country]").click(function () {
                    switchCityCountry($(this).attr("data-country"))
                });
            }

            refactorCityCountry();
            addCountrySelector();

            var selectedValue = $(cityInputSelector).val();
            var selectedText = $(cityInputSelector + ' option[value=' + selectedValue + ']').text();

            //countries do not have "country" attribute
            var selectedCountry;
            if (selectedValue) {
                selectedCountry = $(cityInputSelector + ' option[value=' + selectedValue + ']').attr("country");
            }

            //check if selectedValue was not a country
            //update setCountry with selectedCountry
            //countryData[i].defaultText to rhe selectedText
            if (selectedCountry != undefined) {
                setCountry = selectedCountry;
                for (var i = 0; i < countryData.length; i++) {
                    if (countryData[i].country == selectedCountry) {
                        countryData[i].defaultText = selectedText;
                    }
                }
            }

            switchCityCountry(setCountry);

        }
    };

    LeadGen.util = {
        loadScript: function (src, callbackfn) {
            var newScript = document.createElement("script");
            newScript.type = "text/javascript";
            newScript.setAttribute("async", "true");
            newScript.setAttribute("src", src);

            if (newScript.readyState) {
                newScript.onreadystatechange = function () {
                    if (/loaded|complete/.test(newScript.readyState)) callbackfn();
                }
            } else {
                newScript.addEventListener("load", callbackfn, false);
            }

            document.documentElement.firstChild.appendChild(newScript);
        }
    };

})();

LeadGen.ui.googleMapsActions.initializeAll();

window.mobileAndTabletcheck = function () {
    var check = false;
    (function (a) { if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino|android|ipad|playbook|silk/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))) check = true; })(navigator.userAgent || navigator.vendor || window.opera);
    return check;
};

// attach the function to the window ready,load and resize event
$(window).resize(LeadGen.ui.window.onResize);
$(document).ready(LeadGen.ui.window.onResize);

window.onload = function () { 
    // page is fully loaded, including all frames, objects and images
    LeadGen.ui.window.onResize()
};

function makeRadiosDeselectableInClass(className) {

    //For eack unique radioName in the class invoke "makeRadiosDeselectableByName" function
    var radioNameArr = [];
    $.each($('.' + className + ' input:radio'), function () {
        var radioName = this.name;
        if ($.inArray(radioName, radioNameArr) < 0) {
            radioNameArr.push(radioName);
            makeRadiosDeselectableInClassByName(className, radioName);
        }
    });

    function makeRadiosDeselectableInClassByName(className, radioName) {
        var RadioGroupSelector = '.' + className + ' input[name="' + radioName + '"]';
        $(RadioGroupSelector).click(function () {
            var previousValue = $(this).attr('previousValue');
            var name = $(this).attr('name');

            if (previousValue == 'checked') {
                $(this).removeAttr('checked');
                $(this).attr('previousValue', false);
            }
            else {
                $(RadioGroupSelector).attr('previousValue', false);
                $(this).attr('previousValue', 'checked');
            }
        });
    }
}


function AjaxOnCompleteExample(data) {
    if (data.hasOwnProperty('statusText') && data.statusText != "OK") {
        //System Error
        bootbox.alert({
            title: "Внимание, системная ошибка!",
            message: JSON.stringify(data)
        });
    }
    else if (data.hasOwnProperty('responseJSON')) {
        //JSON
        var json = data.responseJSON;
        if (json.status == "success" && json.hasOwnProperty('message')) {
            // Email Removed
            $(this).closest(".NotificationEmail").remove();
        }
        else if (json.status == "error") {
            bootbox.alert({
                title: "Внимание, ошибка!",
                message: "<p>Вероятно этот адрес уже добавлен.</p>"
            });
        }
    }
    else if (data.hasOwnProperty('responseText')) {
        //HTML
        var html = data.responseText;
        $("#NotificationEditor").replaceWith(html);
    }
}